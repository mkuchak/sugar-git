# Resolve the main worktree path
main_worktree=$(git worktree list --porcelain | head -1 | sed 's/^worktree //')

if [[ -z "${args[--symlink]}" ]]; then
  echo "Error: At least one --symlink/-s path is required."
  exit 1
fi

# bashly stores repeatable flags as a shell-quoted space-separated string.
# `eval` is the idiomatic way to parse it into an array. Input is the user's
# own shell args, so no untrusted-input concern.
eval "symlinks=(${args[--symlink]})"
for spath in "${symlinks[@]}"; do
  [[ -z "$spath" ]] && continue
  if [[ -e "$main_worktree/$spath" ]]; then
    mkdir -p "$(dirname "$spath")"
    rm -rf "$spath"
    ln -sf "$main_worktree/$spath" "$spath"
    echo "Linked: $spath"
  else
    echo "Warning: $spath not found in main worktree ($main_worktree)"
  fi
done
