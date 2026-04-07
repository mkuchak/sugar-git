if [ ! -z "${args[--add]}" ]; then
  git remote rm "$(get_remote)"
  git remote add "$(get_remote)" ${args[--add]}
fi

git remote -v | awk '{print $2}' | sort -u
