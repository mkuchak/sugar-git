# Target directories to search for
target_dirs=(
  "node_modules" ".next" "out" "dist" "build" ".turbo" ".cache" ".vercel"
  ".expo" "storybook-static" ".output" ".nuxt" ".svelte-kit" ".astro"
  ".vite" ".parcel-cache" ".docusaurus" ".contentlayer" ".swc" ".nx"
  ".angular" ".vitest" ".eslintcache" ".stylelintcache"
  "target"
  "__pycache__" ".pytest_cache" ".mypy_cache" ".ruff_cache" ".venv" "venv"
  "htmlcov" ".tox" ".nox"
  ".gradle"
  "coverage" "tmp" "logs" ".nyc_output" ".sass-cache"
  "__generated__" ".metro"
  ".terraform" ".serverless" ".aws-sam"
  ".dart_tool" ".pub-cache"
)

# Target file patterns
target_files=("*.tsbuildinfo" "*.log" ".DS_Store" "Thumbs.db" "*.pyc" "*.pyo" "*.class")

# Lock files (only with --locks or --all)
lock_files=("pnpm-lock.yaml" "yarn.lock" "package-lock.json" "bun.lockb" "Cargo.lock" "poetry.lock" "Pipfile.lock" "Gemfile.lock" "composer.lock")

include_locks=false
if [[ -n "${args[--locks]}" || -n "${args[--all]}" ]]; then
  include_locks=true
fi

# Build find expressions for directories
found_dirs=""
for dir in "${target_dirs[@]}"; do
  results=$(find . -type d -name "$dir" -not -path "./.git/*" 2>/dev/null)
  if [[ -n "$results" ]]; then
    found_dirs+="$results"$'\n'
  fi
done

# Build find expressions for files
found_files=""
for pattern in "${target_files[@]}"; do
  results=$(find . -type f -name "$pattern" -not -path "./.git/*" 2>/dev/null)
  if [[ -n "$results" ]]; then
    found_files+="$results"$'\n'
  fi
done

# Find lock files if requested
found_locks=""
if [[ "$include_locks" == true ]]; then
  for lockfile in "${lock_files[@]}"; do
    if [[ -f "$lockfile" ]]; then
      found_locks+="./$lockfile"$'\n'
    fi
  done
fi

# Remove trailing newlines
found_dirs=$(echo "$found_dirs" | sed '/^$/d')
found_files=$(echo "$found_files" | sed '/^$/d')
found_locks=$(echo "$found_locks" | sed '/^$/d')

# Check if anything was found
if [[ -z "$found_dirs" && -z "$found_files" && -z "$found_locks" ]]; then
  echo "Nothing to purge."
  exit 0
fi

# Dry run mode
if [[ -n "${args[--dry-run]}" ]]; then
  echo "Would delete:"
  echo ""

  if [[ -n "$found_dirs" ]]; then
    echo "$found_dirs" | while read -r dir; do
      [[ -z "$dir" ]] && continue
      size=$(du -sh "$dir" 2>/dev/null | cut -f1)
      printf "  %-50s %s\n" "$dir/" "$size"
    done
  fi

  if [[ -n "$found_files" ]]; then
    echo "$found_files" | while read -r file; do
      [[ -z "$file" ]] && continue
      printf "  %s\n" "$file"
    done
  fi

  if [[ -n "$found_locks" ]]; then
    echo ""
    echo "Lock files:"
    echo "$found_locks" | while read -r lock; do
      [[ -z "$lock" ]] && continue
      printf "  %s\n" "$lock"
    done
  fi

  echo ""
  echo "Run without --dry-run to delete."
  exit 0
fi

# Show what will be deleted
echo "Will delete:"
echo ""

if [[ -n "$found_dirs" ]]; then
  echo "$found_dirs" | while read -r dir; do
    [[ -z "$dir" ]] && continue
    size=$(du -sh "$dir" 2>/dev/null | cut -f1)
    printf "  %-50s %s\n" "$dir/" "$size"
  done
fi

if [[ -n "$found_files" ]]; then
  file_count=$(echo "$found_files" | wc -l | tr -d ' ')
  echo "  + $file_count files (*.tsbuildinfo, *.log, .DS_Store, etc.)"
fi

if [[ -n "$found_locks" ]]; then
  echo ""
  echo "Lock files:"
  echo "$found_locks" | while read -r lock; do
    [[ -z "$lock" ]] && continue
    printf "  %s\n" "$lock"
  done
fi

echo ""

# Confirmation
if [[ -z "${args[--yes]}" ]]; then
  echo "Proceed? (y/N)"
  read REPLY
  if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
fi

# Delete directories
if [[ -n "$found_dirs" ]]; then
  echo "$found_dirs" | while read -r dir; do
    [[ -z "$dir" ]] && continue
    rm -rf "$dir"
  done
fi

# Delete files
if [[ -n "$found_files" ]]; then
  echo "$found_files" | while read -r file; do
    [[ -z "$file" ]] && continue
    rm -f "$file"
  done
fi

# Delete lock files
if [[ -n "$found_locks" ]]; then
  echo "$found_locks" | while read -r lock; do
    [[ -z "$lock" ]] && continue
    rm -f "$lock"
  done
fi

echo "Done. Project purged."
