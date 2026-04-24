# Determine branch name
if [[ -z "${args[branch]}" ]]; then
  branch="wt-$(uuidgen 2>/dev/null | tr '[:upper:]' '[:lower:]' | cut -c1-8 || cat /proc/sys/kernel/random/uuid 2>/dev/null | cut -c1-8 || date +%s | sha256sum | head -c 8)"
else
  branch="${args[branch]}"
fi

# Folder name: --name override, or derive from branch (slashes → dashes)
if [[ -n "${args[--name]}" ]]; then
  folder_name="../${args[--name]}"
else
  folder_name="../$(echo "$branch" | tr '/' '-')"
fi

# Determine base branch
from_branch="${args[--from]:-}"

# Check if branch exists locally or remotely
if git show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
  git worktree add "$folder_name" "$branch"
elif git show-ref --verify --quiet "refs/remotes/$(get_remote)/$branch" 2>/dev/null; then
  git worktree add --track -b "$branch" "$folder_name" "$(get_remote)/$branch"
else
  if [[ -n "$from_branch" ]]; then
    git worktree add -b "$branch" "$folder_name" "$from_branch"
  else
    git worktree add -b "$branch" "$folder_name"
  fi
fi

if [[ $? -ne 0 ]]; then
  echo "Error: Failed to create worktree."
  exit 1
fi

# Resolve main worktree path
main_worktree=$(git worktree list --porcelain | head -1 | sed 's/^worktree //')

# Symlink one env/config file from main into the new worktree.
link_file_from_main() {
  local relative="$1"
  local target_dir="$folder_name/$(dirname "$relative")"
  # Ensure the parent exists. Subdirs that contain only gitignored files
  # (typical for .env-only dirs) are NOT checked out by `git worktree add`.
  mkdir -p "$target_dir"
  ln -sf "$(cd "$main_worktree" && pwd)/$relative" "$folder_name/$relative"
  echo "  Linked $relative"
}

# Scan the main worktree for .env* files and symlink them, skipping
# build artifacts, vendor dirs, and .claude.
scan_and_link_envs() {
  find "$main_worktree" \
    \( -name node_modules -o -name .git -o -name dist -o -name build \
       -o -name .next -o -name .turbo -o -name .cache -o -name .vercel \
       -o -name .expo -o -name .output -o -name .nuxt -o -name .svelte-kit \
       -o -name .astro -o -name .parcel-cache -o -name .docusaurus \
       -o -name .venv -o -name venv -o -name target -o -name __pycache__ \
       -o -name .pytest_cache -o -name .mypy_cache -o -name .ruff_cache \
       -o -name coverage -o -name .angular -o -name .gradle \
       -o -name .claude -o -name .serena -o -name .tickets \) -prune \
    -o -type f \( -name '.env' -o -name '.env.*' \) \
       ! -name '*.example' ! -name '*.sample' ! -name '*.template' \
       -print 2>/dev/null |
  while read -r envfile; do
    local relative="${envfile#$main_worktree/}"
    # Don't clobber a tracked file already in the worktree checkout.
    if [[ -f "$folder_name/$relative" && ! -L "$folder_name/$relative" ]]; then
      continue
    fi
    link_file_from_main "$relative"
  done
}

# Link per-user configuration into the new worktree (unless --no-link).
# Two modes:
#   1. .sgitlinks present → respect it verbatim (plain paths + @envs dirs)
#   2. .sgitlinks absent  → auto-scan the repo for .env* files
if [[ -z "${args[--no-link]}" ]]; then
  sgitlinks_file="$main_worktree/.sgitlinks"

  if [[ -f "$sgitlinks_file" ]]; then
    echo "Linking configurations from .sgitlinks..."
    envs_dirs=()
    while IFS= read -r line || [[ -n "$line" ]]; do
      line=$(echo "$line" | xargs)
      [[ -z "$line" ]] && continue
      [[ "$line" == \#* ]] && continue

      if [[ "$line" == "@envs "* ]]; then
        # Parse @envs directive: "@envs apps workers packages"
        read -ra envs_dirs <<< "${line#@envs }"
        continue
      fi

      # Skip .claude directory
      [[ "$line" == ".claude" || "$line" == ".claude/"* ]] && continue

      # Regular symlink path
      if [[ -e "$main_worktree/$line" ]]; then
        mkdir -p "$folder_name/$(dirname "$line")"
        rm -rf "$folder_name/$line"
        ln -sf "$(cd "$main_worktree" && pwd)/$line" "$folder_name/$line"
        echo "  Linked $line"
      fi
    done < "$sgitlinks_file"

    # Process @envs directories
    for envdir in "${envs_dirs[@]}"; do
      if [[ -d "$main_worktree/$envdir" ]]; then
        find "$main_worktree/$envdir" -maxdepth 2 -name '.env*' -not -name '*.example' -not -name '*.sample' -type f 2>/dev/null | while read envfile; do
          relative="${envfile#$main_worktree/}"
          link_file_from_main "$relative"
        done
      fi
    done
  else
    # No .sgitlinks → scan the repo for .env* files
    echo "Auto-linking .env files (no .sgitlinks found)..."
    scan_and_link_envs
  fi
fi

# Process -s flag symlinks
if [[ -n "${args[--symlink]}" ]]; then
  # bashly stores repeatable flags as a shell-quoted space-separated string.
  # `eval` is the idiomatic way to parse it into an array. Input is the user's
  # own shell args, so no untrusted-input concern.
  eval "symlinks=(${args[--symlink]})"
  for spath in "${symlinks[@]}"; do
    [[ -z "$spath" ]] && continue
    if [[ -e "$main_worktree/$spath" ]]; then
      mkdir -p "$folder_name/$(dirname "$spath")"
      rm -rf "$folder_name/$spath"
      ln -sf "$(cd "$main_worktree" && pwd)/$spath" "$folder_name/$spath"
      echo "  Linked $spath"
    else
      echo "  Warning: $spath not found in main worktree"
    fi
  done
fi

# Auto-detect and install dependencies (unless --no-install)
if [[ -z "${args[--no-install]}" ]]; then
  pushd "$folder_name" > /dev/null
  if [[ -f "pnpm-lock.yaml" ]]; then
    echo "Installing dependencies (pnpm)..."
    pnpm install --frozen-lockfile 2>/dev/null
  elif [[ -f "yarn.lock" ]]; then
    echo "Installing dependencies (yarn)..."
    yarn install --frozen-lockfile 2>/dev/null
  elif [[ -f "package-lock.json" ]]; then
    echo "Installing dependencies (npm)..."
    npm ci 2>/dev/null
  elif [[ -f "bun.lockb" ]]; then
    echo "Installing dependencies (bun)..."
    bun install --frozen-lockfile 2>/dev/null
  elif [[ -f "Cargo.toml" ]]; then
    echo "Fetching dependencies (cargo)..."
    cargo fetch 2>/dev/null
  elif [[ -f "go.mod" ]]; then
    echo "Downloading dependencies (go)..."
    go mod download 2>/dev/null
  fi
  popd > /dev/null
fi

# Print result
resolved_path=$(cd "$folder_name" && pwd)
echo ""
echo "Worktree ready!"
echo "  Path:   $resolved_path"
echo "  Branch: $branch"
echo "  Run:    cd $folder_name"
