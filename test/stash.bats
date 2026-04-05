#!/usr/bin/env bats

setup() {
  load 'test_helper'
  setup_git_repo
}

teardown() {
  teardown_git_repo
}

# --- stash put ---

@test "stash put: dirty tree becomes clean after stash" {
  make_dirty
  run "$SGIT" stash put
  assert_success
  run git status --porcelain
  assert_output ""
}

@test "stash put: named stash with -m flag" {
  make_dirty
  run "$SGIT" stash put -m "WIP"
  assert_success
  run git stash list
  assert_output --partial "WIP"
}

# --- stash ls ---

@test "stash ls: shows stash entries" {
  make_dirty
  git stash push -m "test entry"
  run "$SGIT" stash ls
  assert_success
  assert_output --partial "test entry"
}

@test "stash ls: empty when nothing is stashed" {
  run "$SGIT" stash ls
  assert_success
  assert_output ""
}

# --- stash get ---

@test "stash get: pops stash and restores changes" {
  make_dirty
  git stash push
  run "$SGIT" stash get
  assert_success
  run git diff --name-only
  assert_output --partial "file.txt"
}

# --- stash peek ---

@test "stash peek: shows diff of stashed changes" {
  make_dirty
  git stash push
  run "$SGIT" stash peek
  assert_success
  assert_output --partial "dirty"
}

@test "stash peek: --stat shows stat summary" {
  make_dirty
  git stash push
  run "$SGIT" stash peek --stat
  assert_success
  assert_output --partial "file.txt"
}

# --- stash keep ---

@test "stash keep: applies stash but keeps it in list" {
  make_dirty
  git stash push -m "keep me"
  run "$SGIT" stash keep
  assert_success
  run git stash list
  assert_output --partial "keep me"
  run git diff --name-only
  assert_output --partial "file.txt"
}

# --- stash drop ---

@test "stash drop: removes top stash entry" {
  make_dirty
  git stash push -m "drop me"
  run "$SGIT" stash drop
  assert_success
  run git stash list
  assert_output ""
}

@test "stash drop: --all -y clears all stashes" {
  make_dirty
  git stash push -m "first"
  make_dirty
  git stash push -m "second"
  run "$SGIT" stash drop --all -y
  assert_success
  assert_output --partial "All stash entries cleared"
  run git stash list
  assert_output ""
}

# --- stash move ---

@test "stash move: moves dirty changes to another branch" {
  git branch target-branch
  make_dirty
  run "$SGIT" stash move target-branch
  assert_success
  local current_branch
  current_branch=$(git branch --show-current)
  [[ "$current_branch" == "target-branch" ]]
  run git diff --name-only
  assert_output --partial "file.txt"
}
