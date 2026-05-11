#!/usr/bin/env bats

setup() {
  load 'test_helper'
  setup_git_repo
}

teardown() {
  teardown_git_repo
}

@test "history ls: shows entries after operations" {
  create_commits 2
  run "$SGIT" history ls
  assert_success
  assert_output --partial "[0]"
  assert_output --partial "commit number 2"
}

@test "history with no subcommand: shows usage hint" {
  create_commits 1
  run "$SGIT" history
  # Bashly's parent-command routing shows usage; user runs `sgit history ls`.
  assert_output --partial "Browse and restore from the reflog"
}

@test "history ls --limit caps output" {
  create_commits 5
  run "$SGIT" history ls --limit 3
  assert_success
  local entries
  entries=$(echo "$output" | grep -c '^\[' || true)
  [[ "$entries" -le 3 ]]
}

@test "history show: prints the commit at index" {
  create_commits 2
  local current_hash
  current_hash=$(git rev-parse --short HEAD)
  run "$SGIT" history show 0
  assert_success
  assert_output --partial "$current_hash"
}

@test "history restore --yes: resets HEAD to that entry" {
  create_commits 3
  local before_hash
  before_hash=$(git rev-parse HEAD)
  # Make another commit, so HEAD@{0} is now this new one, HEAD@{1} is the prior.
  echo "extra" > extra.txt
  git add extra.txt
  git commit -m "feat: extra"
  # Restore to index 1 (the state before "extra").
  run "$SGIT" history restore 1 --yes
  assert_success
  local after_hash
  after_hash=$(git rev-parse HEAD)
  [[ "$after_hash" == "$before_hash" ]]
  [[ ! -f extra.txt ]]
}

@test "history restore: invalid index fails" {
  create_commits 1
  run "$SGIT" history restore 9999 --yes
  assert_failure
  assert_output --partial "no entry"
}
