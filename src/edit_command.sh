if [ -z ${args[commit_id]} ]; then
  git commit --amend
else
  HEAD_COMMIT=$(git rev-list HEAD | nl | grep ${args[commit_id]})
  read HEAD_ID _ <<<"$HEAD_COMMIT"

  echo "==========================="
  echo
  echo "ATTENTION! Alter \"pick\" to \"reword\" in the commit you want to edit."
  echo "After that, save and close the file, so you will be able to edit the commit message."
  echo ""
  echo "To publish you must run \"git put --force\"."
  echo "This is NOT RECOMMENDED if commits have already been made to a remote repository and other collaborators are active."
  echo
  echo "==========================="

  git rebase -i HEAD~$HEAD_ID

fi