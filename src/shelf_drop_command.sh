ref=$(resolve_shelf_id "${args[id]:-}") || exit 1
short="${ref#sgit/shelf/}"
git update-ref -d "refs/$ref"
rm -f "$(shelf_meta_dir)/$short.txt"
echo "Dropped $short"
