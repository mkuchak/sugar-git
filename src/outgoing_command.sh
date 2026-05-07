# Show the outgoing commits from working branch that is not in the remote branch
fetch_with_recovery "$(get_remote)" --quiet 2>/dev/null \
  || echo "Warning: fetch failed; output may be stale." >&2
git log --oneline --no-merges --right-only --cherry-pick --decorate --pretty=format:"%C(yellow)%h %Cgreen%cr %Cblue%an%Creset %s" "$(get_remote)"/$(git rev-parse --abbrev-ref HEAD)..$(git rev-parse --abbrev-ref HEAD)
