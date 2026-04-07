# Handle custom date/time if provided
handle_custom_date

force=$([[ ! -z "${args[--force]}" ]] && echo "--force" || echo "")

if [ ! -z ${args[--add-all]} ]; then
  git add --all
elif [ ! -z "${args[--add]}" ]; then
  git add ${args[--add]}
fi

if [[ -n "${args[--message]}" ]]; then
  git commit --amend -m "${args[--message]}"
else
  git commit --amend --no-edit
fi

if [ ! -z ${args[--put]} ]; then
  git push $force "$(get_remote)" "$(git rev-parse --abbrev-ref HEAD)"
fi
