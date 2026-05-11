target=$(resolve_history_index "${args[index]:-}") || exit 1

# Show the user what they're about to restore to.
hash=$(git rev-parse --short "$target")
subject=$(git log -1 --format=%s "$target" 2>/dev/null)
echo "Will reset HEAD to: $hash $subject"
echo ""

if [[ -z "${args[--yes]}" ]]; then
  echo "This rewrites current branch state. Continue? (y/N)"
  read REPLY
  if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
fi

git reset --hard "$target"
echo "HEAD is now at $hash $subject"
