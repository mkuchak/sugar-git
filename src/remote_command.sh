if [ ! -z "${args[--add]}" ]; then
  git remote rm origin
  git remote add origin ${args[--add]}
fi

git remote -v | awk '{print $2}' | sort -u
