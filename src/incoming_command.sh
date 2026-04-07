# Show the incoming commits from remote branch that is not in the working branch
git fetch "$(get_remote)" --quiet
git log --oneline --no-merges --left-only --cherry-pick --decorate --pretty=format:"%C(yellow)%h %Cgreen%cr %Cblue%an%Creset %s" $(git rev-parse --abbrev-ref HEAD).."$(get_remote)"/$(git rev-parse --abbrev-ref HEAD)
