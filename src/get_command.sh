rebase=$([[ -n "${args[--rebase]}" ]] && echo "--rebase" || echo "")

# Fetch with --prune --force and lock-error auto-recovery (parity with sync).
# Halt on non-recoverable failure — merging/rebasing against stale data is
# worse than failing loudly.
if ! fetch_with_recovery "$(get_remote)"; then
  echo "" >&2
  echo "Error: fetch failed; refusing to integrate stale data." >&2
  exit 1
fi

# Resolve what to merge from. Try candidates in priority order, use the first
# that actually exists after the fetch. This makes `sgit get` robust to common
# config drift: stale upstream pointing at a deleted PR branch, branches with
# no upstream set, or branches whose upstream is differently named.
#
#   1. Explicit branch arg               -> <remote>/<branch>
#   2. Configured upstream (@{u} name)   -> that ref (if it still exists)
#   3. Fall back to <remote>/<current>   -> same-named remote branch
candidates=()
current="$(git rev-parse --abbrev-ref HEAD)"

if [[ -n "${args[branch]}" ]]; then
  candidates=("$(get_remote)/${args[branch]}")
else
  # Read the configured upstream NAME without requiring the ref to exist —
  # `git rev-parse @{u}` would error when the cached ref was pruned, hiding
  # the very config drift we want to detect.
  upstream=$(git for-each-ref --format='%(upstream:short)' "refs/heads/$current" 2>/dev/null)
  if [[ -n "$upstream" ]]; then
    candidates+=("$upstream")
  fi
  same_named="$(get_remote)/$current"
  if [[ "$same_named" != "$upstream" ]]; then
    candidates+=("$same_named")
  fi
fi

target=""
for c in "${candidates[@]}"; do
  if git rev-parse --verify "$c" >/dev/null 2>&1; then
    target="$c"
    break
  fi
done

if [[ -z "$target" ]]; then
  echo "Error: no remote ref to pull from. Tried: ${candidates[*]}" >&2
  echo "Specify a branch: sgit get <branch>" >&2
  exit 1
fi

# Visible recovery: if we fell past the configured upstream, say so and show
# how to clear the notice next time.
if [[ ${#candidates[@]} -gt 1 && "$target" != "${candidates[0]}" ]]; then
  echo "Note: upstream '${candidates[0]}' no longer exists; using '$target'." >&2
  echo "  To clear: git branch --set-upstream-to=$target $current" >&2
fi

if [[ -n "$rebase" ]]; then
  git rebase "$target"
else
  git merge "$target"
fi
