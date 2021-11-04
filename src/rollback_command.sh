if [ ! -z ${args[commit_id]} ]; then
  git reset --soft ${args[commit_id]}
else
  git reset --soft HEAD~1
fi
git reset