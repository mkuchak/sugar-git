# Handle custom date/time if provided
handle_custom_date

force=$([[ ! -z "${args[--force]}" ]] && echo "--force" || echo "")
no_verify=$(get_no_verify)

if [ ! -z ${args[--add-all]} ]; then
  git add --all
elif [ ! -z "${args[--add]}" ]; then
  git add ${args[--add]}
fi

if [[ -n "${args[--message]}" ]]; then
  git commit --amend -m "${args[--message]}" $no_verify
else
  git commit --amend --no-edit $no_verify
fi

if [ ! -z ${args[--put]} ]; then
  git push $force $no_verify "$(get_remote)" "$(git rev-parse --abbrev-ref HEAD)"
fi
