if [ ! -z ${args[--local]} ]; then
  git branch -l | grep -v ‘remotes’
elif [ ! -z ${args[--remote]} ]; then
  git branch -r | grep -v ‘remotes’
else
  git branch -a | grep -v ‘remotes’
fi
