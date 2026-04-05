if [[ -n "${args[index]}" ]]; then
  git stash apply "stash@{${args[index]}}"
else
  git stash apply
fi
