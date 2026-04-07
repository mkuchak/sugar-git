# Show the outgoing commits from working branch that is not in the remote branch
git fetch "$(get_remote)" --quiet
git log --oneline --no-merges --right-only --cherry-pick --decorate --pretty=format:"%C(yellow)%h %Cgreen%cr %Cblue%an%Creset %s" "$(get_remote)"/$(git rev-parse --abbrev-ref HEAD)..$(git rev-parse --abbrev-ref HEAD)
