if [[ -n "${args[--only-origin]}" ]]; then
  git push origin --delete "${args[branch]}"
else
  target_branch="${args[branch]}"
  current_branch="$(git branch --show-current)"

  if [[ "$target_branch" == "$current_branch" ]]; then
    echo "You are about to delete the current branch \"$current_branch\"."
    echo "You will be switched to another branch. Are you sure? (y/N)"
    read REPLY
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
      exit 0
    fi

    branches=$(git branch -l)
    IFS=$'\n'
    branches=($branches)
    jump_branch=$([[ "*$current_branch" == "${branches[0]// /}" ]] && echo "${branches[1]// /}" || echo "${branches[0]// /}")
    git checkout $jump_branch
  fi

  git branch -D "$target_branch"
  if [[ -n "${args[--origin]}" ]]; then
    git push origin --delete "$target_branch"
  fi
fi
