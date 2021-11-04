query+=$([[ ! -z "${args[search_terms]}" ]] && echo "--grep ${args[search_terms]} " || echo "")
query+=$([[ ! -z "${args[--author]}" ]] && echo "--author ${args[--author]} " || echo "")
query+=$([[ ! -z "${args[--since]}" ]] && echo "--since ${args[--since]} " || echo "")
query+=$([[ ! -z "${args[--until]}" ]] && echo "--until ${args[--until]} " || echo "")
query+=$([[ ! -z "${args[--exclude]}" ]] && echo "--invert-grep " || echo "")

git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %C(green)(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit $query