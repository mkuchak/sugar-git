# Build file summary from changes
file_summary() {
  local changed_files=$(git diff --cached --name-only 2>/dev/null)
  [[ -z "$changed_files" ]] && changed_files=$(git diff --name-only HEAD 2>/dev/null)

  local file_count=$(echo "$changed_files" | grep -c '.' 2>/dev/null)
  local basenames=$(echo "$changed_files" | head -3 | xargs -I{} basename {} | tr '\n' ', ' | sed 's/,$//' | sed 's/,/, /g')

  local remaining=$((file_count - 3))
  if [[ $remaining -gt 0 ]]; then
    echo "${file_count} files changed (${basenames}, +${remaining} more)"
  elif [[ $file_count -gt 0 ]]; then
    echo "$basenames"
  else
    echo "save progress"
  fi
}

# Check if last commit is a temp (chore: WIP or chore: WIP(N))
last_msg=$(git log -1 --format=%s 2>/dev/null)
is_temp=false
count=1

if [[ "$last_msg" =~ ^chore:\ WIP\(([0-9]+)\) ]]; then
  is_temp=true
  count=$(( ${BASH_REMATCH[1]} + 1 ))
elif [[ "$last_msg" =~ ^chore:\ WIP ]]; then
  is_temp=true
  count=2
fi

# Stage everything
git add --all

# Build message
if [[ -n "${args[description]}" ]]; then
  summary="${args[description]}"
else
  summary="$(file_summary)"
fi

no_verify=$([[ -n "${args[--no-verify]}" ]] && echo "--no-verify" || echo "")

if [[ "$is_temp" == true ]]; then
  # Amend previous temp commit with bumped counter
  git commit --amend -m "chore: WIP($count) $summary" $no_verify

  if [[ -n "${args[--put]}" ]]; then
    git push --force $no_verify "$(get_remote)" "$(git rev-parse --abbrev-ref HEAD)"
  fi
else
  # Fresh temp commit
  git commit -m "chore: WIP $summary" $no_verify

  if [[ -n "${args[--put]}" ]]; then
    git push $no_verify "$(get_remote)" "$(git rev-parse --abbrev-ref HEAD)"
  fi
fi
