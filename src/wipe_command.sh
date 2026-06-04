branch="${args[branch]:-$(git rev-parse --abbrev-ref HEAD)}"

# Fetch first so we wipe to the CURRENT origin tip, not a stale cached ref.
# Same hardening philosophy as sync/get: --prune --force + lock-error recovery.
# Halt on non-recoverable failure — wiping to stale data would be worse.
if ! fetch_with_recovery "$(get_remote)"; then
  echo "" >&2
  echo "Error: fetch failed; refusing to wipe against stale data." >&2
  exit 1
fi

remote_ref="$(get_remote)/$branch"

# Validate the remote ref exists after fetch.
if ! git rev-parse --verify "$remote_ref" >/dev/null 2>&1; then
  echo "Error: '$remote_ref' does not exist; nothing to wipe to." >&2
  exit 1
fi

do_wipe() {
  git reset --hard "$remote_ref"
  if [[ -n "${args[--all]}" ]]; then
    git clean -fdx
  fi
}

if [[ -n "${args[--yes]}" ]]; then
  do_wipe
else
  echo "Changes that will be lost:"
  echo ""
  git diff --stat "$remote_ref" 2>/dev/null
  if [[ -n "${args[--all]}" ]]; then
    echo ""
    echo "Untracked and ignored files that will also be removed:"
    git clean -fdx --dry-run | sed 's/^/  /'
  fi
  echo ""
  echo "Are you sure you want to wipe (hard reset) \"$branch\" branch? (y/N)"
  read REPLY
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    do_wipe
  fi
fi
