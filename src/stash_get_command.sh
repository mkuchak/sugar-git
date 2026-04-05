if [[ -n "${args[index]}" ]]; then
  git stash pop "stash@{${args[index]}}"
else
  git stash pop
fi
