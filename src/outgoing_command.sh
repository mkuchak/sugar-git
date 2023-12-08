# Show the outgoing commits from working branch that is not in the remote branch
git fetch origin --quiet
git log --oneline --no-merges --right-only --cherry-pick --decorate --pretty=format:"%C(yellow)%h %Cgreen%cr %Cblue%an%Creset %s" origin/$(git rev-parse --abbrev-ref HEAD)..$(git rev-parse --abbrev-ref HEAD)
