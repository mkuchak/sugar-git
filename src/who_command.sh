target="${args[target]}"

# Split file:linespec on the LAST colon (filenames may contain colons).
if [[ "$target" == *:* ]]; then
  file="${target%:*}"
  linespec="${target##*:}"
else
  file="$target"
  linespec=""
fi

if [[ ! -f "$file" ]]; then
  echo "Error: '$file' not found." >&2
  exit 1
fi

# Full-file mode: plain colorized blame.
if [[ -z "$linespec" ]]; then
  git blame --color-by-age -- "$file"
  exit $?
fi

# Validate linespec: either a single number or N-M.
if [[ "$linespec" =~ ^([0-9]+)(-([0-9]+))?$ ]]; then
  start="${BASH_REMATCH[1]}"
  end="${BASH_REMATCH[3]:-$start}"
else
  echo "Error: linespec '$linespec' is not a number or N-M range." >&2
  exit 1
fi

# Blame the requested range. Show the blame lines first.
echo "=== blame ==="
git blame --color-by-age -L "$start,$end" -- "$file"
echo ""

# Collect unique commit hashes from the blame range, preserving order.
hashes=()
seen=""
while IFS= read -r line; do
  hash=$(echo "$line" | awk '{print $1}' | tr -d '^')
  [[ -z "$hash" || "$hash" == "00000000" ]] && continue
  if [[ "$seen" != *"$hash"* ]]; then
    hashes+=("$hash")
    seen="$seen $hash"
  fi
done < <(git blame --porcelain -L "$start,$end" -- "$file" | grep -E '^[0-9a-f]{40} ')

# Show full message (and optionally diff) for each unique commit.
for h in "${hashes[@]}"; do
  echo "=== commit $(git rev-parse --short "$h") ==="
  git show -s --format='Author: %an <%ae>%nDate:   %ad%n%n%w(0,4,4)%B' "$h"
  if [[ -n "${args[--diff]}" ]]; then
    echo ""
    echo "--- diff (for $file) ---"
    git show --color=auto "$h" -- "$file"
  fi
  echo ""
done
