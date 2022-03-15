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
fi

branch=${branch// /-}

if [ ! -z ${args['--only-origin']} ]; then
  git push -u origin $branch
elif [ ! -z ${args['--origin']} ]; then
  git checkout -b $branch
  git push -u origin $branch
else
  git checkout -b $branch
fi