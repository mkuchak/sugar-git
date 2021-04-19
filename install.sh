#!/bin/bash
CWD=$(pwd)

# Register semantic commits scripts execution path
#
# $1 — shell configuraton file path
function git {
  if [[ "$1" == "mv" && "$@" != *"-ns"* && "$@" != *"--no-sugar"* && "$@" != *"--help"* ]]; then
    shift 1
    command git move "$@"
  elif [[ "$1" == "rm" && "$@" != *"-ns"* && "$@" != *"--no-sugar"* && "$@" != *"--help"* ]]; then
    shift 1
    command git remove "$@"
  elif [[ "$1" == "merge" && "$@" != *"-ns"* && "$@" != *"--no-sugar"* && "$@" != *"--help"* ]]; then
    shift 1
    command git merging "$@"
  else
    if [[ "$@" == *"-ns"* ]]; then
      for param; do
        [[ ! $param == '-ns' ]] && newparams+=("$param")
      done
      set -- "${newparams[@]}"
    elif [[ "$@" == *"--no-sugar"* ]]; then
      for param; do
        [[ ! $param == '--no-sugar' ]] && newparams+=("$param")
      done
      set -- "${newparams[@]}"
    fi
    unset newparams
    command git "$@"
  fi
}

# Needs to create an auto register for this function
# Some cheating to override 'mv', 'rm' and 'merge' commands
function git {
  if [[ "$1" == "mv" && "$@" != *"-ns"* && "$@" != *"--no-sugar"* && "$@" != *"--help"* ]]; then
    shift 1
    command git move "$@"
  elif [[ "$1" == "rm" && "$@" != *"-ns"* && "$@" != *"--no-sugar"* && "$@" != *"--help"* ]]; then
    shift 1
    command git remove "$@"
  elif [[ "$1" == "merge" && "$@" != *"-ns"* && "$@" != *"--no-sugar"* && "$@" != *"--help"* ]]; then
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
if ! git config --global --get-all alias.cd &>/dev/null; then
  git config --global alias.cd checkout
fi
echo
echo 'Done! Now you can use sugar git.'
echo 'See: https://github.com/mkuchak/sugar-git for more information.'
