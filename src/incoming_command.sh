# Show the incoming commits from remote branch that is not in the working branch
fetch_with_recovery "$(get_remote)" --quiet 2>/dev/null \
  || echo "Warning: fetch failed; output may be stale." >&2
git log --oneline --no-merges --left-only --cherry-pick --decorate --pretty=format:"%C(yellow)%h %Cgreen%cr %Cblue%an%Creset %s" $(git rev-parse --abbrev-ref HEAD).."$(get_remote)"/$(git rev-parse --abbrev-ref HEAD)
