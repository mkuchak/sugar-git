if [ ! -z "${args[--ours]}" ]; then # Resolve conflicts using the working branch version"
  git checkout --ours .
fi

if [ ! -z "${args[--theirs]}" ]; then # Resolve conflicts using the remote branch version"
  git checkout --theirs .
fi
