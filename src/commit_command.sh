# Handle custom date/time if provided
handle_custom_date

message="${args[description]}"
edit=$([[ -n "${args[description]}" && -z "${args[--edit]}" ]] && echo "" || echo "--edit")
force=$([[ -n "${args[--force]}" ]] && echo "--force" || echo "")
no_verify=$([[ -n "${args[--no-verify]}" ]] && echo "--no-verify" || echo "")

if [[ -n "${args[--add-all]}" ]]; then
  git add --all
elif [[ -n "${args[--add]}" ]]; then
  git add ${args[--add]}
fi

git commit -m "$message" $edit $no_verify

if [[ -n "${args[--put]}" ]]; then
  git push $force $no_verify "$(get_remote)" "$(git rev-parse --abbrev-ref HEAD)"
fi
