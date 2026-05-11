# Resolve a numeric reflog index (as shown by `sgit history ls`) to a HEAD@{N}
# reference. Index 0 is the most recent reflog entry (HEAD@{0}).
#
# Echoes the HEAD@{N} string on success; prints to stderr and returns non-zero
# on invalid input or when no reflog exists.
resolve_history_index() {
  local arg="${1:-0}"

  if ! [[ "$arg" =~ ^[0-9]+$ ]]; then
    echo "Error: index must be a non-negative integer." >&2
    return 1
  fi

  local total
  total=$(git reflog show HEAD 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$total" -eq 0 ]]; then
    echo "Error: no reflog entries." >&2
    return 1
  fi
  if [[ "$arg" -ge "$total" ]]; then
    echo "Error: no entry at index $arg (have $total)." >&2
    return 1
  fi

  echo "HEAD@{$arg}"
}
