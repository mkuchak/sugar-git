#!/bin/bash
CWD=$(pwd)

# Register semantic commits scripts execution path
#
# $1 — shell configuraton file path
function register_path {
  PATH_BRANCHES='export PATH=$PATH:'$CWD/branches':$PATH'
  PATH_COMMITS='export PATH=$PATH:'$CWD/commits':$PATH'
  PATH_MANAGEMENT='export PATH=$PATH:'$CWD/management':$PATH'

  if [ -f $1 ]; then
    if ! grep -Fxq "$PATH_BRANCHES" $1; then
      echo "Adding branches path to $1"
      echo $PATH_BRANCHES >>$1
      source $1
    fi
    if ! grep -Fxq "$PATH_COMMITS" $1; then
      echo "Adding commits path to $1"
      echo $PATH_COMMITS >>$1
      source $1
    fi
    if ! grep -Fxq "$PATH_MANAGEMENT" $1; then
      echo "Adding management path to $1"
      echo $PATH_MANAGEMENT >>$1
      source $1
    fi
  fi
}

# Needs to create an auto register for this function
# Some cheating to override 'mv', 'rm' and 'merge' commands
function git {
  if [[ "$1" == "mv" && "$@" != *"--help"* ]]; then
    shift 1
    command git move "$@"
  elif [[ "$1" == "rm" && "$@" != *"--help"* ]]; then
    shift 1
    command git remove "$@"
  elif [[ "$1" == "merge" && "$@" != *"--help"* ]]; then
    shift 1
    command git merging "$@"
  else
    command git "$@"
  fi
}

echo 'Installing scripts…'
echo
register_path ~/.bashrc
register_path ~/.zshrc
echo
echo 'Done! Now you can use sugar git.'
echo 'See: https://github.com/mkuchak/sugar-git for more information.'
