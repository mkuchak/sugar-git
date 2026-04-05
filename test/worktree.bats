#!/usr/bin/env bats

setup() {
  load 'test_helper'
  setup_git_repo
}

teardown() {
  # Remove worktree before teardown to avoid git complaints
  if [[ -d "../test-branch" ]]; then
    git worktree remove --force "../test-branch" 2>/dev/null || true
    rm -rf "../test-branch"
  fi
  teardown_git_repo
}

# --- worktree add ---

@test "worktree add: creates worktree at ../test-branch" {
  run "$SGIT" worktree add test-branch --no-install
  assert_success
  assert_output --partial "Worktree ready!"
  [[ -d "../test-branch" ]]
}

# --- worktree ls ---

@test "worktree ls: lists worktrees after add" {
  "$SGIT" worktree add test-branch --no-install
  run "$SGIT" worktree ls
  assert_success
  local count
  count=$(echo "$output" | wc -l | tr -d ' ')
  [[ "$count" -ge 2 ]]
}

# --- worktree rm ---

@test "worktree rm: removes the worktree" {
  "$SGIT" worktree add test-branch --no-install
  run "$SGIT" worktree rm test-branch
  assert_success
  assert_output --partial "removed"
  [[ ! -d "../test-branch" ]]
}

# --- worktree prune ---

@test "worktree prune: runs without error" {
  run "$SGIT" worktree prune
  assert_success
  assert_output --partial "Stale worktree references cleaned"
}
