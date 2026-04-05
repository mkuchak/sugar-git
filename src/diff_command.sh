if [[ -n "${args[--staged]}" ]]; then
  git diff --staged
elif [[ -n "${args[target]}" ]]; then
  git diff "${args[target]}..HEAD"
else
  git diff
fi
