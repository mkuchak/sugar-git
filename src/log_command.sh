query_args=()

if [[ -n "${args[search_terms]}" ]]; then
  query_args+=(--grep "${args[search_terms]}")
fi
if [[ -n "${args[--author]}" ]]; then
  query_args+=(--author "${args[--author]}")
fi
if [[ -n "${args[--since]}" ]]; then
  query_args+=(--since "${args[--since]}")
fi
if [[ -n "${args[--until]}" ]]; then
  query_args+=(--until "${args[--until]}")
fi
if [[ -n "${args[--exclude]}" ]]; then
  query_args+=(--invert-grep)
fi

git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %C(green)(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit "${query_args[@]}"
