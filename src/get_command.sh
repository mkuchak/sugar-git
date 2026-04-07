force=$([[ ! -z "${args[--force]}" ]] && echo "--force" || echo "")
rebase=$([[ ! -z "${args[--rebase]}" ]] && echo "--rebase" || echo "")
branch=$([[ ! -z "${args[branch]}" ]] && echo ${args[branch]} || echo $(git rev-parse --abbrev-ref HEAD))

git pull $force $rebase "$(get_remote)" $branch
