if [[ -n "${args[--stat]}" ]]; then
  if [[ -n "${args[index]}" ]]; then
    git stash show --stat "stash@{${args[index]}}"
  else
    git stash show --stat
  fi
else
  if [[ -n "${args[index]}" ]]; then
    git stash show -p "stash@{${args[index]}}"
  else
    git stash show -p
  fi
fi
