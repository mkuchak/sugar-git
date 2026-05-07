entries=()
while IFS= read -r line; do
  [[ -n "$line" ]] && entries+=("$line")
done < <(git for-each-ref --sort=-refname refs/sgit/shelf/ --format='%(refname:short)|%(committerdate:format:%Y-%m-%d %H:%M)' 2>/dev/null)

if [[ ${#entries[@]} -eq 0 ]]; then
  echo "No shelved commits."
  exit 0
fi

i=0
for entry in "${entries[@]}"; do
  ref="${entry%%|*}"
  date="${entry##*|}"
  short="${ref#sgit/shelf/}"
  count=$(parse_count_from_shelf_id "$short")
  echo "[$i] $short  ($date, $count commit(s))"
  git log --oneline -n "$count" "$ref" | sed 's/^/    /'
  echo ""
  i=$((i + 1))
done
