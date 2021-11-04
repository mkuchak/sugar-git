force=$([[ ! -z "${args[--force]}" ]] && echo "--force" || echo "")
branch=$([[ ! -z "${args[branch]}" ]] && echo ${args[branch]} || echo $(git rev-parse --abbrev-ref HEAD))

git push $force origin $branch
