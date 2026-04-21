# Determine branch name
if [[ -z "${args[branch]}" ]]; then
  branch="wt-$(uuidgen 2>/dev/null | tr '[:upper:]' '[:lower:]' | cut -c1-8 || cat /proc/sys/kernel/random/uuid 2>/dev/null | cut -c1-8 || date +%s | sha256sum | head -c 8)"
else
  branch="${args[branch]}"
fi

# Convert slashes to dashes for folder name
folder_name="../$(echo "$branch" | tr '/' '-')"

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

# Symlink from .sgitlinks file (unless --no-link)
if [[ -z "${args[--no-link]}" ]] && [[ -f "$main_worktree/.sgitlinks" ]]; then
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
  done < "$main_worktree/.sgitlinks"

  # Process @envs directories
  for envdir in "${envs_dirs[@]}"; do
    if [[ -d "$main_worktree/$envdir" ]]; then
      find "$main_worktree/$envdir" -maxdepth 2 -name '.env*' -not -name '*.example' -not -name '*.sample' -type f 2>/dev/null | while read envfile; do
        relative="${envfile#$main_worktree/}"
        target_dir="$folder_name/$(dirname "$relative")"
        # Ensure the target directory exists. Subdirs that contain only
        # gitignored files (typical for .env-only dirs) are NOT checked out
        # by `git worktree add`, so the symlink target's parent would be
        # missing without this.
        mkdir -p "$target_dir"
        ln -sf "$envfile" "$folder_name/$relative"
        echo "  Linked $relative"
      done
    fi
  done
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
