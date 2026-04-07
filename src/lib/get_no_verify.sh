#!/usr/bin/env bash

# [@bashly-upgrade lib get_no_verify]
get_no_verify() {
  # Check both --no-verify and --bypass (aliases of each other)
  if [[ -n "${args[--no-verify]}" || -n "${args[--bypass]}" ]]; then
    echo "--no-verify"
  fi
}
