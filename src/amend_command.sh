# Handle custom date/time if provided
handle_custom_date

if [[ -n "${args[--force]}" ]]; then
  if [[ -n "${args[--no-lease]}" ]]; then
    force="--force"
  else
    force="--force-with-lease"
  fi
else
  force=""
fi
no_verify=$(get_no_verify)

if [[ -n "${args[--add-all]}" ]]; then
  git add --all
elif [[ -n "${args[--add]}" ]]; then
  git add "${args[--add]}"
fi

if [[ -n "${args[--message]}" ]]; then
  git commit --amend -m "${args[--message]}" $no_verify
else
  git commit --amend --no-edit $no_verify
fi

if [[ -n "${args[--put]}" ]]; then
  git push $force $no_verify "$(get_remote)" "$(git rev-parse --abbrev-ref HEAD)"
fi
