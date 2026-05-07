# Wrapper around `git fetch --prune --force` that auto-recovers from the
# "cannot lock ref" error class.
#
# The --prune --force pair handles the common cases:
#   --prune  drop local remote-tracking refs for branches gone upstream
#   --force  allow non-fast-forward updates (e.g., upstream force-push)
#
# When ref bookkeeping has drifted (loose vs packed-refs out of sync,
# typically after a previous force-push couldn't be cleanly reconciled),
# `git fetch` aborts with "error: cannot lock ref 'refs/remotes/origin/X'".
# This helper detects that pattern, deletes the offending ref(s) with
# `git update-ref -d`, and retries fetch once.
#
# Returns 0 on success (including after recovery); non-zero only if the
# retry also fails or the error wasn't a recoverable lock failure.
#
# Usage: fetch_with_recovery <remote> [extra-args...]
fetch_with_recovery() {
  local fetch_output
  fetch_output=$(git fetch --prune --force "$@" 2>&1)
  local status=$?

  if [[ $status -eq 0 ]]; then
    [[ -n "$fetch_output" ]] && echo "$fetch_output"
    return 0
  fi

  local bad_refs
  bad_refs=$(echo "$fetch_output" | grep -oE "cannot lock ref '[^']+'" | sed -E "s/cannot lock ref '([^']+)'/\\1/")

  if [[ -z "$bad_refs" ]]; then
    # Not a recoverable lock error; surface what git said and bail.
    echo "$fetch_output" >&2
    return $status
  fi

  while IFS= read -r bad_ref; do
    [[ -n "$bad_ref" ]] || continue
    echo "Reconciling stale ref: $bad_ref" >&2
    git update-ref -d "$bad_ref" 2>/dev/null || true
  done <<< "$bad_refs"

  git fetch --prune --force "$@"
}
