ref=$(resolve_shelf_id "${args[id]:-}") || exit 1
short="${ref#sgit/shelf/}"
count=$(parse_count_from_shelf_id "$short")

range="$ref~$count..$ref"

if [[ -n "${args[--stat]}" ]]; then
  git log --color=auto --stat "$range"
else
  git log --color=auto -p "$range"
fi
