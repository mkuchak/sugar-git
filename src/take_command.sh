# Fetch latest refs (best-effort; offline use should still allow take)
fetch_with_recovery "$(get_remote)" --quiet 2>/dev/null || true

if [[ -n "${args[description]}" ]]; then
  branch="${args[description]}"
elif [[ -n "${args[--main]}" ]]; then
  branch="main"
elif [[ -n "${args[--staging]}" ]]; then
  branch="staged"
elif [[ -n "${args[--test]}" ]]; then
  branch="test"
elif [[ -n "${args[--dev]}" ]]; then
  branch="develop"
elif [[ -n "${args[--feature]}" ]]; then
  branch="feature/${args[--feature]}"
elif [[ -n "${args[--bugfix]}" ]]; then
  branch="bugfix/${args[--bugfix]}"
elif [[ -n "${args[--hotfix]}" ]]; then
  branch="hotfix/${args[--hotfix]}"
elif [[ -n "${args[--experimental]}" ]]; then
  branch="experimental/${args[--experimental]}"
elif [[ -n "${args[--build]}" ]]; then
  branch="build/${args[--build]}"
elif [[ -n "${args[--release]}" ]]; then
  branch="release/${args[--release]}"
elif [[ -n "${args[--merge]}" ]]; then
  branch="merge/${args[--merge]}"
else
  branch=$(uuidgen 2>/dev/null | tr '[:upper:]' '[:lower:]' | cut -c1-8 || cat /proc/sys/kernel/random/uuid 2>/dev/null | cut -c1-8 || date +%s | shasum | head -c 8)
fi

branch="${branch// /-}"
from_branch="${args[--from]:-}"

if [[ -n "${args[--only-remote]}" ]]; then
  # Push a ref (from_branch or current HEAD) under the new branch name on the remote,
  # without creating the branch locally.
  source_ref="${from_branch:-HEAD}"
  git push -u "$(get_remote)" "$source_ref:refs/heads/$branch"
elif [[ -n "${args[--remote]}" ]]; then
  if [[ -n "$from_branch" ]]; then
    git checkout -b "$branch" "$from_branch"
  else
    git checkout -b "$branch"
  fi
  git push -u "$(get_remote)" "$branch"
else
  if [[ -n "$from_branch" ]]; then
    git checkout -b "$branch" "$from_branch"
  else
    git checkout -b "$branch"
  fi
fi
