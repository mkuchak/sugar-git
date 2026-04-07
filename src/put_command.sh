force=$([[ ! -z "${args[--force]}" ]] && echo "--force" || echo "")
no_verify=$(get_no_verify)
branch=$([[ ! -z "${args[branch]}" ]] && echo ${args[branch]} || echo $(git rev-parse --abbrev-ref HEAD))

git push $force $no_verify "$(get_remote)" $branch
