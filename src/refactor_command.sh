type=refactor
scope=$([[ ! -z "${args[--scope]}" ]] && echo "(${args[--scope]})" || echo "")
breaking_change=$([[ ! -z "${args[--breaking-change]}" ]] && echo "!" || echo "")
message="$type$scope$breaking_change: ${args[description]}"
edit=$([[ ( ! -z "${args[description]}") && ( -z "${args[--edit]}") ]] && echo "" || echo "--edit")
force=$([[ ! -z "${args[--force]}" ]] && echo "--force" || echo "")

if [ ! -z ${args[--add-all]} ]; then
  git add .
elif [ ! -z "${args[--add]}" ]; then
  git add ${args[--add]}
fi

git commit -m "$message" $edit

if [ ! -z ${args[--put]} ]; then
  git push $force origin $(git rev-parse --abbrev-ref HEAD)
fi
