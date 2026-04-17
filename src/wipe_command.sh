branch="${args[branch]:-$(git rev-parse --abbrev-ref HEAD)}"
remote_ref="$(get_remote)/$branch"

if [[ -n "${args[--yes]}" ]]; then
  git reset --hard "$remote_ref"
else
  echo "Changes that will be lost:"
  echo ""
  git diff --stat "$remote_ref" 2>/dev/null
  echo ""
  echo "Are you sure you want to wipe (hard reset) \"$branch\" branch? (y/N)"
  read REPLY
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    git reset --hard "$remote_ref"
  fi
fi
