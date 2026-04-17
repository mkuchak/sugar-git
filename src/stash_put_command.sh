untracked=$([[ -n "${args[--untracked]}" ]] && echo "--include-untracked" || echo "")

if [[ -n "${args[--message]}" ]]; then
  if [[ ${#other_args[@]} -gt 0 ]]; then
    git stash push $untracked -m "${args[--message]}" -- "${other_args[@]}"
  else
    git stash push $untracked -m "${args[--message]}"
  fi
else
  if [[ ${#other_args[@]} -gt 0 ]]; then
    git stash push $untracked -- "${other_args[@]}"
  else
    git stash push $untracked
  fi
fi
