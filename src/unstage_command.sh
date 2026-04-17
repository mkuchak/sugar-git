if [[ -n "${args[--all]}" ]]; then
  git reset
else
  git restore --staged "${other_args[@]}"
fi
