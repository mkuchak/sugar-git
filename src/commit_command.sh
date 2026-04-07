# Handle custom date/time if provided
handle_custom_date

message="${args[description]}"
edit=$([[ -n "${args[description]}" && -z "${args[--edit]}" ]] && echo "" || echo "--edit")
force=$([[ -n "${args[--force]}" ]] && echo "--force" || echo "")

if [[ -n "${args[--add-all]}" ]]; then
  git add --all
elif [[ -n "${args[--add]}" ]]; then
  git add ${args[--add]}
fi

git commit -m "$message" $edit

if [[ -n "${args[--put]}" ]]; then
  git push $force "$(get_remote)" "$(git rev-parse --abbrev-ref HEAD)"
fi
