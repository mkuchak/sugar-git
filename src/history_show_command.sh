target=$(resolve_history_index "${args[index]:-}") || exit 1
git show --color=auto "$target"
