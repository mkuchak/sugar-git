# Handle rebase recovery flags first (these don't need fetch)
if [[ -n "${args[--continue]}" ]]; then
  git rebase --continue
  exit $?
fi

if [[ -n "${args[--abort]}" ]]; then
  git rebase --abort
  exit $?
fi

if [[ -n "${args[--skip]}" ]]; then
  git rebase --skip
  exit $?
fi

# Determine target branch
branch=$([[ -n "${args[branch]}" ]] && echo "${args[branch]}" || echo "main")

# Fetch (with auto-recovery, prune, and force). Halt on non-recoverable
# failure — refusing to rebase on stale data is safer than pretending success.
if ! fetch_with_recovery "$(get_remote)"; then
  echo "" >&2
  echo "Error: fetch failed; refusing to rebase on stale data." >&2
  exit 1
fi

# Rebase, dropping commits whose diff is already present upstream
# (typical after the user's PR landed via squash/merge with extra fixups).
if ! git rebase --empty=drop "$(get_remote)/$branch"; then
  echo ""
  echo "==========================="
  echo ""
  echo "Conflicts found. Resolve them, then run:"
  echo ""
  echo "  sgit sync -c    to continue"
  echo "  sgit sync -s    to skip this commit"
  echo "  sgit sync -a    to abort"
  echo ""
  echo "==========================="
fi
