force=$([[ -n "${args[--force]}" ]] && echo "--force" || echo "")
rebase=$([[ -n "${args[--rebase]}" ]] && echo "--rebase" || echo "")
branch="${args[branch]:-$(git rev-parse --abbrev-ref HEAD)}"

git pull $force $rebase "$(get_remote)" "$branch"
