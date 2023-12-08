# Show the incoming commits from remote branch that is not in the working branch
git fetch origin --quiet
git log --oneline --no-merges --left-only --cherry-pick --decorate --pretty=format:"%C(yellow)%h %Cgreen%cr %Cblue%an%Creset %s" $(git rev-parse --abbrev-ref HEAD)..origin/$(git rev-parse --abbrev-ref HEAD)
