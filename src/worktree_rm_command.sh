git worktree remove "../${args[name]}" 2>/dev/null

if [[ $? -ne 0 ]]; then
  echo "Error: Failed to remove worktree \"${args[name]}\"."
  echo "If the worktree has uncommitted changes, use 'git worktree remove --force ../name'."
  exit 1
fi

echo "Worktree \"${args[name]}\" removed."
