main_dir=$(git worktree list --porcelain | head -1 | sed 's/^worktree //')
current_top=$(git rev-parse --show-toplevel 2>/dev/null)

# Resolve the target name.
if [[ -z "${args[name]:-}" ]]; then
  # No name provided — infer from the current worktree.
  if [[ -z "$current_top" ]]; then
    echo "Error: not in a git repository." >&2
    exit 1
  fi
  if [[ "$current_top" == "$main_dir" ]]; then
    echo "Error: no worktree name given, and you're in the main worktree." >&2
    echo "Usage: sgit wt rm <name>" >&2
    exit 1
  fi
  target_name=$(basename "$current_top")
else
  target_name="${args[name]}"
fi

# sgit-created worktrees live as siblings of the main worktree: ../<name>
target_path="$main_dir/../$target_name"

# If we're currently inside the worktree we're about to remove, hop to the
# main worktree first — git refuses to remove the worktree you're sitting in.
moved_to_main=""
if [[ "$(basename "$current_top")" == "$target_name" ]]; then
  cd "$main_dir" || { echo "Error: could not change to main worktree at $main_dir." >&2; exit 1; }
  moved_to_main="yes"
fi

if ! git worktree remove "$target_path" 2>/dev/null; then
  echo "Error: Failed to remove worktree \"$target_name\"." >&2
  echo "If the worktree has uncommitted changes, use 'git worktree remove --force ../$target_name'." >&2
  exit 1
fi

echo "Worktree \"$target_name\" removed."

# If we silently jumped to main, the user's outer shell is still anchored in
# the now-deleted path. Print the cd command so they don't hit "no such file"
# on their next command.
if [[ -n "$moved_to_main" ]]; then
  echo ""
  echo "Your shell is still in the removed worktree's old path."
  echo "Run: cd $main_dir"
fi
