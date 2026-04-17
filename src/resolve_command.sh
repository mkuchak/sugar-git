if [[ -n "${args[--ours]}" ]]; then
  git checkout --ours .
fi

if [[ -n "${args[--theirs]}" ]]; then
  git checkout --theirs .
fi
