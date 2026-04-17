# Handle custom date/time if provided
handle_custom_date

force=$([[ -n "${args[--force]}" ]] && echo "--force" || echo "")
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
