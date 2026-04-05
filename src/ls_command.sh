if [[ -n "${args[--local]}" ]]; then
  git for-each-ref --sort=-committerdate refs/heads/ \
    --format='%(if)%(HEAD)%(then)* %(color:green)%(else)  %(color:yellow)%(end)%(refname:short)%(color:reset) %(color:green)(%(committerdate:relative))%(color:reset) %(subject)'
elif [[ -n "${args[--remote]}" ]]; then
  git for-each-ref --sort=-committerdate refs/remotes/ \
    --format='  %(color:yellow)%(refname:short)%(color:reset) %(color:green)(%(committerdate:relative))%(color:reset) %(subject)'
else
  git for-each-ref --sort=-committerdate refs/heads/ refs/remotes/ \
    --format='%(if)%(HEAD)%(then)* %(color:green)%(else)  %(color:yellow)%(end)%(refname:short)%(color:reset) %(color:green)(%(committerdate:relative))%(color:reset) %(subject)'
fi
