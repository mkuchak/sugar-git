rebase=$([[ -n "${args[--rebase]}" ]] && echo "--rebase" || echo "")

# Determine the merge target. Priority:
#   1. Explicit branch arg              -> <remote>/<branch>
#   2. Configured upstream (@{u})       -> that ref (matches `git pull` semantics)
#   3. Fall back to <remote>/<current>  -> same-named remote branch
if [[ -n "${args[branch]}" ]]; then
  target="$(get_remote)/${args[branch]}"
elif upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null); then
  target="$upstream"
else
  target="$(get_remote)/$(git rev-parse --abbrev-ref HEAD)"
fi

# Fetch with --prune --force and lock-error auto-recovery (parity with sync).
# Halt on non-recoverable failure — merging/rebasing against stale data is worse
# than failing loudly.
if ! fetch_with_recovery "$(get_remote)"; then
  echo "" >&2
  echo "Error: fetch failed; refusing to integrate stale data." >&2
  exit 1
fi

if [[ -n "$rebase" ]]; then
  git rebase "$target"
else
  git merge "$target"
fi
