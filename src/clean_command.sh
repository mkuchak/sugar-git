# Find branches merged into main, excluding protected branches
merged_branches=$(git branch --merged main 2>/dev/null | grep -v -E '^\*|main|develop|staged' | sed 's/^[ ]*//')

if [[ -z "$merged_branches" ]]; then
  echo "No merged branches to clean."
  exit 0
fi

echo "The following branches have been merged into main:"
echo ""
echo "$merged_branches" | while read branch; do
  echo "  - $branch"
done
echo ""

if [[ -z "${args[--yes]}" ]]; then
  echo "Delete these branches? (y/N)"
  read REPLY
  if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
fi

echo "$merged_branches" | while read branch; do
  git branch -d "$branch"
  if [[ -n "${args[--origin]}" ]]; then
    git push origin --delete "$branch" 2>/dev/null
  fi
done

echo ""
echo "Done. Merged branches cleaned up."
