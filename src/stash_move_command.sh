target_branch="${args[branch]}"

# Validate target branch exists
if ! git rev-parse --verify "$target_branch" &>/dev/null && ! git rev-parse --verify "origin/$target_branch" &>/dev/null; then
  echo "Error: Branch \"$target_branch\" does not exist."
  exit 1
fi

# Stash current changes
if [[ -n "${args[--message]}" ]]; then
  git stash push -m "${args[--message]}"
else
  git stash push
fi

if [[ $? -ne 0 ]]; then
  echo "Error: Failed to stash changes. Do you have any changes to stash?"
  exit 1
fi

# Switch to target branch
git checkout "$target_branch"
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to checkout \"$target_branch\". Your changes are still in the stash."
  exit 1
fi

# Attempt to pop stash
if ! git stash pop; then
  echo ""
  echo "Warning: Conflicts detected when applying stash."
  echo "Your changes are kept in the stash. Resolve conflicts, then run 'git stash drop' to clean up."
fi
