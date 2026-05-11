limit="${args[--limit]:-20}"

if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  echo "No history yet (unborn HEAD)."
  exit 0
fi

# Parse reflog: %h = abbrev sha, %gd = HEAD@{N}, %gs = action+message, %cr = relative date.
entries=()
while IFS= read -r line; do
  [[ -n "$line" ]] && entries+=("$line")
done < <(git reflog show --format='%h|%gd|%gs|%cr' HEAD -n "$limit" 2>/dev/null)

if [[ ${#entries[@]} -eq 0 ]]; then
  echo "No history yet."
  exit 0
fi

i=0
for entry in "${entries[@]}"; do
  hash="${entry%%|*}"
  rest="${entry#*|}"
  reflog_sel="${rest%%|*}"
  rest="${rest#*|}"
  subject_full="${rest%|*}"
  ago="${rest##*|}"

  # subject_full is like "commit: foo" or "commit (amend): foo" or "rebase (finish):"
  # Action = up to first colon; subject = after first colon (trimmed).
  action="${subject_full%%:*}"
  subject="${subject_full#*:}"
  subject="${subject# }"  # trim leading space

  # Normalize action labels for readability.
  case "$action" in
    "commit") action_label="commit" ;;
    "commit (initial)") action_label="commit" ;;
    "commit (amend)") action_label="amend" ;;
    "rebase") action_label="rebase" ;;
    "rebase (start)") action_label="rebase" ;;
    "rebase (continue)") action_label="rebase" ;;
    "rebase (finish)") action_label="rebase" ;;
    "rebase (pick)") action_label="rebase" ;;
    "rebase -i") action_label="rebase" ;;
    "rebase -i (start)") action_label="rebase" ;;
    "rebase -i (finish)") action_label="rebase" ;;
    "merge"*) action_label="merge" ;;
    "pull"*) action_label="pull" ;;
    "checkout"*) action_label="checkout" ;;
    "reset"*) action_label="reset" ;;
    "clone"*) action_label="clone" ;;
    "cherry-pick"*) action_label="cherry" ;;
    *) action_label="$action" ;;
  esac

  printf "[%d]  %-13s %-10s %s\n" "$i" "$ago" "$action_label" "$subject"
  i=$((i + 1))
done
