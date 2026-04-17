force=$([[ -n "${args[--force]}" ]] && echo "--force" || echo "")
no_verify=$(get_no_verify)
branch="${args[branch]:-$(git rev-parse --abbrev-ref HEAD)}"

git push $force $no_verify "$(get_remote)" "$branch"
