if [[ -n "${args[--force]}" ]]; then
  if [[ -n "${args[--no-lease]}" ]]; then
    force="--force"
  else
    force="--force-with-lease"
  fi
else
  force=""
fi

no_verify=$(get_no_verify)
branch="${args[branch]:-$(git rev-parse --abbrev-ref HEAD)}"

git push $force $no_verify "$(get_remote)" "$branch"
