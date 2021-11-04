if [ ! -z ${args[--only-origin]}]; then
  git push origin --delete ${args[branch]}
else
  if [ ${args[branch]} == "$(git branch --show-current)" ]; then
    branches=$(git branch -l)
    IFS=$'\n'
    branches=($branches)
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    jump_branch=$([[ "*$current_branch" == "${branches[0]// /}" ]] && echo "${branches[1]// /}" || echo "${branches[0]// /}")
    git checkout $jump_branch
  fi
  git branch -D ${args[branch]}
  if [ ! -z ${args[--origin]}]; then
    git push origin --delete ${args[branch]}
  fi
fi
