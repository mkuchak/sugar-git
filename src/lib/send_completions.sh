# [@bashly-upgrade completions send_completions]
send_completions() {
  echo $'#!/usr/bin/env bash'
  echo $''
  echo $'# This bash completions script was generated by'
  echo $'# completely (https://github.com/dannyben/completely)'
  echo $'# Modifying it manually is not recommended'
  echo $'_sgit_completions() {'
  echo $'  local cur=${COMP_WORDS[COMP_CWORD]}'
  echo $'  local comp_line="${COMP_WORDS[*]:1}"'
  echo $''
  echo $'  case "$comp_line" in'
  echo $'    \'completions\'*) COMPREPLY=($(compgen -W "--help -h" -- "$cur")) ;;'
  echo $'    \'rollback\'*) COMPREPLY=($(compgen -W "--help -h" -- "$cur")) ;;'
  echo $'    \'localize\'*) COMPREPLY=($(compgen -A directory -A file -W "--add --add-all --breaking-change --edit --force --help --put --scope -A -a -b -e -f -h -p -s" -- "$cur")) ;;'
  echo $'    \'refactor\'*) COMPREPLY=($(compgen -A directory -A file -W "--add --add-all --breaking-change --edit --force --help --put --scope -A -a -b -e -f -h -p -s" -- "$cur")) ;;'
  echo $'    \'revert\'*) COMPREPLY=($(compgen -A directory -A file -W "--add --add-all --breaking-change --edit --force --help --put --scope -A -a -b -e -f -h -p -s" -- "$cur")) ;;'
  echo $'    \'status\'*) COMPREPLY=($(compgen -W "--help -h" -- "$cur")) ;;'
  echo $'    \'mkdir\'*) COMPREPLY=($(compgen -W "--bugfix --build --dev --experimental --feature --help --hotfix --main --merge --only-origin --origin --release --staging --test -H -O -b -d -e -f -h -m -o -r -s -t" -- "$cur")) ;;'
  echo $'    \'style\'*) COMPREPLY=($(compgen -A directory -A file -W "--add --add-all --breaking-change --edit --force --help --put --scope -A -a -b -e -f -h -p -s" -- "$cur")) ;;'
  echo $'    \'amend\'*) COMPREPLY=($(compgen -W "--help -h" -- "$cur")) ;;'
  echo $'    \'chore\'*) COMPREPLY=($(compgen -A directory -A file -W "--add --add-all --breaking-change --edit --force --help --put --scope -A -a -b -e -f -h -p -s" -- "$cur")) ;;'
  echo $'    \'build\'*) COMPREPLY=($(compgen -A directory -A file -W "--add --add-all --breaking-change --edit --force --help --put --scope -A -a -b -e -f -h -p -s" -- "$cur")) ;;'
  echo $'    \'docs\'*) COMPREPLY=($(compgen -A directory -A file -W "--add --add-all --breaking-change --edit --force --help --put --scope -A -a -b -e -f -h -p -s" -- "$cur")) ;;'
  echo $'    \'perf\'*) COMPREPLY=($(compgen -A directory -A file -W "--add --add-all --breaking-change --edit --force --help --put --scope -A -a -b -e -f -h -p -s" -- "$cur")) ;;'
  echo $'    \'feat\'*) COMPREPLY=($(compgen -A directory -A file -W "--add --add-all --breaking-change --edit --force --help --put --scope -A -a -b -e -f -h -p -s" -- "$cur")) ;;'
  echo $'    \'wipe\'*) COMPREPLY=($(compgen -W "$(git branch 2> /dev/null) --help --yes -h -y" -- "$cur")) ;;'
  echo $'    \'save\'*) COMPREPLY=($(compgen -W "--global --help -g -h" -- "$cur")) ;;'
  echo $'    \'test\'*) COMPREPLY=($(compgen -A directory -A file -W "--add --add-all --breaking-change --edit --force --help --put --scope -A -a -b -e -f -h -p -s" -- "$cur")) ;;'
  echo $'    \'edit\'*) COMPREPLY=($(compgen -W "--help -h" -- "$cur")) ;;'
  echo $'    \'log\'*) COMPREPLY=($(compgen -W "--author --exclude --help --since --until -a -e -h -s -u" -- "$cur")) ;;'
  echo $'    \'add\'*) COMPREPLY=($(compgen -A directory -A file -W "--help -h" -- "$cur")) ;;'
  echo $'    \'tag\'*) COMPREPLY=($(compgen -W "--help -h" -- "$cur")) ;;'
  echo $'    \'put\'*) COMPREPLY=($(compgen -W "$(git branch 2> /dev/null) --force --help -f -h" -- "$cur")) ;;'
  echo $'    \'get\'*) COMPREPLY=($(compgen -W "$(git branch 2> /dev/null) --force --help -f -h" -- "$cur")) ;;'
  echo $'    \'fix\'*) COMPREPLY=($(compgen -A directory -A file -W "--add --add-all --breaking-change --edit --force --help --put --scope -A -a -b -e -f -h -p -s" -- "$cur")) ;;'
  echo $'    \'sub\'*) COMPREPLY=($(compgen -A directory -A file -W "--all --help -a -h" -- "$cur")) ;;'
  echo $'    \'ci\'*) COMPREPLY=($(compgen -A directory -A file -W "--add --add-all --breaking-change --edit --force --help --put --scope -A -a -b -e -f -h -p -s" -- "$cur")) ;;'
  echo $'    \'rm\'*) COMPREPLY=($(compgen -W "$(git branch 2> /dev/null) --help --only-origin --origin -O -h -o" -- "$cur")) ;;'
  echo $'    \'mv\'*) COMPREPLY=($(compgen -W "$(git branch 2> /dev/null) --help --only-origin --origin -O -h -o" -- "$cur")) ;;'
  echo $'    \'ls\'*) COMPREPLY=($(compgen -W "--help --local --remote -h -l -r" -- "$cur")) ;;'
  echo $'    \'cd\'*) COMPREPLY=($(compgen -W "$(git branch 2> /dev/null) --help -h" -- "$cur")) ;;'
  echo $'    \'\'*) COMPREPLY=($(compgen -W "--help --version -h -v add amend build cd chore ci completions docs edit feat fix get localize log ls mkdir mv perf put refactor revert rm rollback save status style sub tag test wipe" -- "$cur")) ;;'
  echo $'  esac'
  echo $'}'
  echo $''
  echo $'complete -F _sgit_completions sgit'
}