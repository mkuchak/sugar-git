#!/usr/bin/env bash

# [@bashly-upgrade lib conventional_commit]
conventional_commit() {
  local type="$1"

  # Handle custom date/time if provided
  handle_custom_date

  local scope=$([[ -n "${args[--scope]}" ]] && echo "(${args[--scope]})" || echo "")
  local breaking_change=$([[ -n "${args[--breaking-change]}" ]] && echo "!" || echo "")
  local message="$type$scope$breaking_change: ${args[description]}"
  local edit=$([[ -n "${args[description]}" && -z "${args[--edit]}" ]] && echo "" || echo "--edit")
  local force=$([[ -n "${args[--force]}" ]] && echo "--force" || echo "")

  if [[ -n "${args[--add-all]}" ]]; then
    git add --all
  elif [[ -n "${args[--add]}" ]]; then
    git add ${args[--add]}
  fi

  git commit -m "$message" $edit

  if [[ -n "${args[--put]}" ]]; then
    git push $force origin "$(git rev-parse --abbrev-ref HEAD)"
  fi
}
