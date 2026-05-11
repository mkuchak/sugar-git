since="${args[--since]:-}"
count="${args[count]:-}"
message="${args[message]:-}"

# When --since is used, a single trailing positional is the message, not the
# count. Bashly always fills positionals left-to-right, so "sgit squash --since
# main 'msg'" lands "msg" in args[count]. Shift it over here.
if [[ -n "$since" && -n "$count" && -z "$message" && ! "$count" =~ ^[0-9]+$ ]]; then
  message="$count"
  count=""
fi

if [[ -n "$since" && -n "$count" ]]; then
  echo "Error: pass either a count or --since <ref>, not both." >&2
  exit 1
fi

if [[ -z "$since" && -z "$count" ]]; then
  echo "Error: provide a count or --since <ref>." >&2
  exit 1
fi

if [[ -n "$since" ]]; then
  # Resolve the ref and derive count from the range <ref>..HEAD.
  if ! git rev-parse --verify "$since" >/dev/null 2>&1; then
    echo "Error: '$since' is not a valid ref." >&2
    exit 1
  fi
  count=$(git rev-list --count "$since..HEAD")
  if [[ "$count" -eq 0 ]]; then
    echo "Error: HEAD is already at or behind '$since'; nothing to squash." >&2
    exit 1
  fi
fi

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

if [[ -n "$message" ]]; then
  # Message provided: fully automated
  git reset --soft HEAD~$count
  git commit -m "$message"
else
  # No message: collect original messages, open editor
  original_messages=$(git log --format="%B" -n "$count" | sed '/^$/d')
  git reset --soft HEAD~$count
  git commit -e -m "$original_messages"
fi
