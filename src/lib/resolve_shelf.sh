# Resolve a shelf identifier (full ID or numeric index) to a short refname
# like "sgit/shelf/<id>". Index 0 is the most recently shelved entry.
# On failure, prints an error to stderr and returns non-zero.
resolve_shelf_id() {
  local arg="${1:-0}"
  local refs=()
  local r

  while IFS= read -r r; do
    [[ -n "$r" ]] && refs+=("$r")
  done < <(git for-each-ref --sort=-refname refs/sgit/shelf/ --format='%(refname:short)' 2>/dev/null)

  if [[ ${#refs[@]} -eq 0 ]]; then
    echo "Error: no shelved commits." >&2
    return 1
  fi

  if [[ "$arg" =~ ^[0-9]+$ ]]; then
    if [[ "$arg" -ge "${#refs[@]}" ]]; then
      echo "Error: no shelf at index $arg (have ${#refs[@]} entries)." >&2
      return 1
    fi
    echo "${refs[$arg]}"
  else
    if git show-ref --verify --quiet "refs/sgit/shelf/$arg"; then
      echo "sgit/shelf/$arg"
    else
      echo "Error: shelf '$arg' not found." >&2
      return 1
    fi
  fi
}

# Extract the commit count from a shelf refname.
# Refname format: <YYYYMMDD-HHMMSS>-<count>c-<suffix>
# Example: 20260507-150030-3c-a1b2 → 3
parse_count_from_shelf_id() {
  local short="$1"   # e.g., "sgit/shelf/20260507-150030-3c-a1b2" or just the id part
  local id="${short##*/}"
  local without_suffix="${id%-*}"
  local last_seg="${without_suffix##*-}"
  echo "${last_seg%c}"
}

# Path to the sidecar metadata directory used for shelf labels.
# Stored under the git common dir so it's shared across worktrees and never
# pushed to a remote (shelf is a local concept).
shelf_meta_dir() {
  local common_dir
  common_dir=$(git rev-parse --git-common-dir 2>/dev/null) || return 1
  echo "$common_dir/sgit-shelf-meta"
}

# Verify the working tree is clean and no other git operation is in progress.
# Prints an error and returns non-zero if the repo is not in a stable state.
require_clean_repo_for_shelf() {
  local gitdir
  gitdir=$(git rev-parse --git-dir 2>/dev/null) || {
    echo "Error: not in a git repository." >&2
    return 1
  }
  if [[ -d "$gitdir/rebase-merge" ]] || [[ -d "$gitdir/rebase-apply" ]] \
     || [[ -f "$gitdir/CHERRY_PICK_HEAD" ]] || [[ -f "$gitdir/MERGE_HEAD" ]] \
     || [[ -f "$gitdir/REVERT_HEAD" ]]; then
    echo "Error: another git operation is in progress; finish or abort it first." >&2
    return 1
  fi
  if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "Error: working tree has uncommitted changes." >&2
    echo "Stash them first (sgit stash put) or commit them." >&2
    return 1
  fi
  return 0
}
