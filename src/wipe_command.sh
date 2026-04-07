branch=$([[ ! -z "${args[branch]}" ]] && echo ${args[branch]} || echo $(git rev-parse --abbrev-ref HEAD))

if [ ! -z ${args[--yes]} ]; then
  git reset --hard $(get_remote)/$branch
else
  echo "Changes that will be lost:"
  echo ""
  git diff --stat $(get_remote)/$branch 2>/dev/null
  echo ""
  echo "Are you sure you want to wipe (hard reset) \"$branch\" branch? (y/N)"
  read REPLY
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    git reset --hard $(get_remote)/$branch
  fi
fi
