#!/bin/bash
CWD=$(pwd)

# Register sugar git scripts execution path
#
# $1 — shell configuraton file path
function register_path {
  # Paths to call git sugar commands
  PATH_BRANCHES='export PATH=$PATH:'$CWD/branches':$PATH'
  PATH_COMMITS='export PATH=$PATH:'$CWD/commits':$PATH'
  PATH_MANAGEMENT='export PATH=$PATH:'$CWD/management':$PATH'

  # Some cheating to override 'mv', 'rm', 'log' and 'merge' commands
  MAIN_FUNC='function git {
  if [[ "$1" == "mv" && "$@" != *"-ns"* && "$@" != *"--no-sugar"* && "$@" != *"--help"* ]]; then
    shift 1
    command git move "$@"
  elif [[ "$1" == "rm" && "$@" != *"-ns"* && "$@" != *"--no-sugar"* && "$@" != *"--help"* ]]; then
    shift 1
    command git remove "$@"
  elif [[ "$1" == "merge" && "$@" != *"-ns"* && "$@" != *"--no-sugar"* && "$@" != *"--help"* ]]; then
    shift 1
    command git merging "$@"
  elif [[ "$1" == "log" && "$@" != *"-ns"* && "$@" != *"--no-sugar"* && "$@" != *"--help"* ]]; then
    shift 1
    command git lg "$@"
  else
    if [[ "$@" == *"-ns"* ]]; then
      for param; do
        [[ ! $param == "-ns" ]] && newparams+=("$param")
      done
      set -- "${newparams[@]}"
    elif [[ "$@" == *"--no-sugar"* ]]; then
      for param; do
        [[ ! $param == "--no-sugar" ]] && newparams+=("$param")
      done
      set -- "${newparams[@]}"
    fi
    unset newparams
    command git "$@"
  fi
}'

  if [ -f $1 ]; then
    if ! grep -Fxq "$PATH_BRANCHES" $1; then
      echo "Adding branches path to $1"
      cat <<<"" >>$1
      echo $PATH_BRANCHES >>$1
    fi
    if ! grep -Fxq "$PATH_COMMITS" $1; then
      echo "Adding commits path to $1"
      cat <<<"" >>$1
      echo $PATH_COMMITS >>$1
    fi
    if ! grep -Fxq "$PATH_MANAGEMENT" $1; then
      echo "Adding management path to $1"
      cat <<<"" >>$1
      echo $PATH_MANAGEMENT >>$1
    fi
    if ! grep -Fxq "function git {" $1; then
      echo "Adding main function path to $1"
      cat <<<"" >>$1
      echo "$MAIN_FUNC" >>$1
    fi

    # commented because is causing console errors with .zshrc
    # source $1
  fi
}

echo 'Installing scripts…'
echo
register_path ~/.bashrc
echo
register_path ~/.zshrc
if ! git config --global --get-all alias.cd &>/dev/null; then
  git config --global alias.cd checkout
fi
echo
echo 'Done! Close and open again your terminal, and you will can use Sugar Git.'
echo 'See: https://github.com/mkuchak/sugar-git for more information.'
