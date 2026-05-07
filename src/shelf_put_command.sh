count="${args[count]:-1}"

if ! [[ "$count" =~ ^[0-9]+$ ]] || [[ "$count" -lt 1 ]]; then
  echo "Error: count must be a positive integer." >&2
  exit 1
fi

if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  echo "Error: no commits yet (unborn HEAD)." >&2
  exit 1
fi

require_clean_repo_for_shelf || exit 1

total=$(git rev-list --count HEAD)
if [[ "$count" -gt "$total" ]]; then
  echo "Error: only $total commit(s) available; cannot shelf $count." >&2
  exit 1
fi

# Reject merges in the range — cherry-pick can't replay them cleanly.
if git rev-list --merges -n1 "HEAD~$count..HEAD" 2>/dev/null | grep -q .; then
  echo "Error: range contains a merge commit; merges cannot be cleanly shelved." >&2
  echo "Use 'git rebase -i' or 'git reset --hard <ref>' for merge histories." >&2
  exit 1
fi

# Build a unique ref name; retry on the (very unlikely) collision.
timestamp=$(date +%Y%m%d-%H%M%S)
attempt=0
while [[ $attempt -lt 5 ]]; do
  suffix=$(printf '%04x' $((RANDOM % 65536)))
  id="${timestamp}-${count}c-${suffix}"
  ref="refs/sgit/shelf/$id"
  if ! git show-ref --verify --quiet "$ref"; then
    break
  fi
  attempt=$((attempt + 1))
done

if [[ $attempt -ge 5 ]]; then
  echo "Error: could not generate a unique shelf ID after 5 attempts." >&2
  exit 1
fi

# Save the chain, then pop the commits off HEAD.
git update-ref "$ref" HEAD
git reset --hard "HEAD~$count"

echo "Shelved $count commit(s) as $id"
git log --oneline -n "$count" "$ref" | sed 's/^/  /'
echo ""
echo "Restore with: sgit shelf get"
echo "Drop with:    sgit shelf drop"
