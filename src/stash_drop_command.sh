if [[ -n "${args[--all]}" ]]; then
  if [[ -n "${args[--yes]}" ]]; then
    git stash clear
    echo "All stash entries cleared."
  else
    echo "Are you sure you want to drop ALL stash entries? (y/N)"
    read REPLY
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
      git stash clear
      echo "All stash entries cleared."
    else
      echo "Aborted."
    fi
  fi
else
  if [[ -n "${args[index]}" ]]; then
    git stash drop "stash@{${args[index]}}"
  else
    git stash drop
  fi
fi
