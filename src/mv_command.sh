if [ ! -z ${args[--only-remote]} ]; then
  git push "$(get_remote)" $(get_remote)/${args[old_branch]}:refs/heads/${args[new_branch]} :${args[old_branch]}
elif [ ! -z ${args[--remote]} ]; then
  git branch -m ${args[old_branch]} ${args[new_branch]}
  git push "$(get_remote)" $(get_remote)/${args[old_branch]}:refs/heads/${args[new_branch]} :${args[old_branch]}
else
  git branch -m ${args[old_branch]} ${args[new_branch]}
fi
