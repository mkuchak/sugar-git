ref=$(resolve_shelf_id "${args[id]:-}") || exit 1
short="${ref#sgit/shelf/}"
git update-ref -d "refs/$ref"
echo "Dropped $short"
