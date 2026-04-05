count="${args[count]}"

# Validate count is a positive integer
if ! [[ "$count" =~ ^[1-9][0-9]*$ ]]; then
  echo "Error: Count must be a positive integer."
  exit 1
fi

# Validate count doesn't exceed total commits
total_commits=$(git rev-list --count HEAD)
if [[ "$count" -ge "$total_commits" ]]; then
  echo "Error: Cannot squash $count commits. Only $total_commits commits exist in history."
  exit 1
fi

if [[ -n "${args[message]}" ]]; then
  # Message provided: fully automated
  git reset --soft HEAD~$count
  git commit -m "${args[message]}"
else
  # No message: collect original messages, open editor
  original_messages=$(git log --format="%B" -n "$count" | sed '/^$/d')
  git reset --soft HEAD~$count
  git commit -e -m "$original_messages"
fi
