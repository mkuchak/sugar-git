# Handle custom date/time if provided
handle_custom_date

force=$([[ ! -z "${args[--force]}" ]] && echo "--force" || echo "")

if [ ! -z ${args[--add-all]} ]; then
  git add --all
elif [ ! -z "${args[--add]}" ]; then
  git add ${args[--add]}
fi

git commit --amend --no-edit

if [ ! -z ${args[--put]} ]; then
  git push $force origin $(git rev-parse --abbrev-ref HEAD)
fi
