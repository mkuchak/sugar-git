if [ ! -z "${args[--add]}" ]; then # Add or replace the current origin remote repository"
  git remote rm origin
  git remote add origin ${args[--add]}
fi

if [ ! -z "${args[--add-all]}" ]; then # Add or replace the current origin remote repository"
  git remote rm origin
  git remote add origin ${args[--add-all]}
fi

git remote -v | awk '{print $2}' | sort -u
