if [ ! -z ${args[--only-origin]} ]; then
  git push origin origin/${args[old_branch]}:refs/heads/${args[new_branch]} :${args[old_branch]}
elif [ ! -z ${args[--origin]} ]; then
  git branch -m ${args[old_branch]} ${args[new_branch]}
  git push origin origin/${args[old_branch]}:refs/heads/${args[new_branch]} :${args[old_branch]}
else
  git branch -m ${args[old_branch]} ${args[new_branch]}
fi
