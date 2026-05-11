rebase=$([[ -n "${args[--rebase]}" ]] && echo "--rebase" || echo "")
branch="${args[branch]:-$(git rev-parse --abbrev-ref HEAD)}"

# Fetch with --prune --force and lock-error auto-recovery (parity with sync).
# Halt on non-recoverable failure — merging/rebasing against stale data is worse
# than failing loudly.
if ! fetch_with_recovery "$(get_remote)"; then
  echo "" >&2
  echo "Error: fetch failed; refusing to integrate stale data." >&2
  exit 1
fi

if [[ -n "$rebase" ]]; then
  git rebase "$(get_remote)/$branch"
else
  git merge "$(get_remote)/$branch"
fi
