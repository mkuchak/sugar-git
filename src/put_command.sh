force=$([[ ! -z "${args[--force]}" ]] && echo "--force" || echo "")
no_verify=$([[ -n "${args[--no-verify]}" ]] && echo "--no-verify" || echo "")
branch=$([[ ! -z "${args[branch]}" ]] && echo ${args[branch]} || echo $(git rev-parse --abbrev-ref HEAD))

git push $force $no_verify "$(get_remote)" $branch
