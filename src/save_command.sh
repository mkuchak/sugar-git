if [ ! -z ${args[--global]} ]; then
  git config --global credential.helper store
else
  git config credential.helper store
fi
