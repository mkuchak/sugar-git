#!/usr/bin/env bash

# [@bashly-upgrade lib get_remote]
get_remote() {
  # Resolution: -R flag > sgit.remote config > branch tracking remote > "origin"
  [[ -n "${args[--git-remote]}" ]] && echo "${args[--git-remote]}" && return
  local config_remote=$(git config --get sgit.remote 2>/dev/null)
  [[ -n "$config_remote" ]] && echo "$config_remote" && return
  local tracking=$(git config --get "branch.$(git rev-parse --abbrev-ref HEAD 2>/dev/null).remote" 2>/dev/null)
  [[ -n "$tracking" ]] && echo "$tracking" && return
  echo "origin"
}
