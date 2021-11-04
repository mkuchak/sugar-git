branch=$([[ ! -z "${args[branch]}" ]] && echo ${args[branch]} || echo $(git rev-parse --abbrev-ref HEAD))

if [ ! -z ${args[--yes]} ]; then
  git reset --hard origin/$branch
else
  echo "Are you sure you want to wipe (hard reset) \"$branch\" branch? (y/N)"
  read REPLY
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    git reset --hard origin/$branch
  fi
fi
