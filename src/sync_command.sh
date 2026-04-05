# Handle rebase recovery flags first (these don't need fetch)
if [[ -n "${args[--continue]}" ]]; then
  git rebase --continue
  exit $?
fi

if [[ -n "${args[--abort]}" ]]; then
  git rebase --abort
  exit $?
fi

if [[ -n "${args[--skip]}" ]]; then
  git rebase --skip
  exit $?
fi

# Determine target branch
branch=$([[ -n "${args[branch]}" ]] && echo "${args[branch]}" || echo "$(git rev-parse --abbrev-ref HEAD)")

# Fetch and rebase
git fetch origin

if ! git rebase "origin/$branch"; then
  echo ""
  echo "==========================="
  echo ""
  echo "Conflicts found. Resolve them, then run:"
  echo ""
  echo "  sgit sync -c    to continue"
  echo "  sgit sync -s    to skip this commit"
  echo "  sgit sync -a    to abort"
  echo ""
  echo "==========================="
fi
