# Fetch latest refs
git fetch "$(get_remote)" --quiet 2>/dev/null

if [ ! -z "${args['description']}" ]; then
  branch=${args['description']}
elif [ ! -z "${args['--main']}" ]; then
  branch=main
elif [ ! -z "${args['--staging']}" ]; then
  branch=staged
elif [ ! -z "${args['--test']}" ]; then
  branch=test
elif [ ! -z "${args['--dev']}" ]; then
  branch=develop
elif [ ! -z "${args['--feature']}" ]; then
  branch=feature/${args['--feature']}
elif [ ! -z "${args['--bugfix']}" ]; then
  branch=bugfix/${args['--bugfix']}
elif [ ! -z "${args['--hotfix']}" ]; then
  branch=hotfix/${args['--hotfix']}
elif [ ! -z "${args['--experimental']}" ]; then
  branch=experimental/${args['--experimental']}
elif [ ! -z "${args['--build']}" ]; then
  branch=build/${args['--build']}
elif [ ! -z "${args['--release']}" ]; then
  branch=release/${args['--release']}
elif [ ! -z "${args['--merge']}" ]; then
  branch=merge/${args['--merge']}
else
  branch=$(uuidgen 2>/dev/null | tr '[:upper:]' '[:lower:]' | cut -c1-8 || cat /proc/sys/kernel/random/uuid 2>/dev/null | cut -c1-8 || date +%s | shasum | head -c 8)
fi

branch=${branch// /-}
from_branch="${args[--from]:-}"

if [ ! -z ${args['--only-remote']} ]; then
  git push -u "$(get_remote)" $branch
elif [ ! -z ${args['--remote']} ]; then
  if [[ -n "$from_branch" ]]; then
    git checkout -b $branch $from_branch
  else
    git checkout -b $branch
  fi
  git push -u "$(get_remote)" $branch
else
  if [[ -n "$from_branch" ]]; then
    git checkout -b $branch $from_branch
  else
    git checkout -b $branch
  fi
fi
