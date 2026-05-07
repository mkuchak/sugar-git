ref=$(resolve_shelf_id "${args[id]:-}") || exit 1
short="${ref#sgit/shelf/}"
count=$(parse_count_from_shelf_id "$short")

require_clean_repo_for_shelf || exit 1

# Replay the shelved chain on top of HEAD.
start="$(git rev-parse "$ref~$count")"
if ! git cherry-pick "$start..$ref"; then
  echo "" >&2
  echo "Cherry-pick conflict." >&2
  echo "  sgit resolve --ours          # or --theirs" >&2
  echo "  git cherry-pick --continue" >&2
  echo "  sgit shelf drop $short       # the now-applied shelf" >&2
  echo "Or: git cherry-pick --abort    (shelf preserved)" >&2
  exit 1
fi

git update-ref -d "refs/$ref"
rm -f "$(shelf_meta_dir)/$short.txt"
echo "Restored $count commit(s) and dropped $short"
