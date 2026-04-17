if [[ -n "${args[--remove]}" ]]; then
  git remote rm "$(get_remote)"
elif [[ -n "${args[--add]}" ]]; then
  git remote rm "$(get_remote)" 2>/dev/null
  git remote add "$(get_remote)" "${args[--add]}"
fi

git remote -v | awk '{print $2}' | sort -u
