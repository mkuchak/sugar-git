ff_flag=""
if [[ -n "${args[--ff]}" ]]; then
  ff_flag="--ff-only"
elif [[ -n "${args[--no-ff]}" ]]; then
  ff_flag="--no-ff"
fi

git merge $ff_flag "${args[branch]}"
