#!/usr/bin/env bats

setup() {
  load 'test_helper'
  setup_git_repo
}

teardown() {
  teardown_git_repo
}

@test "add stages a file" {
  echo "new" > new.txt
  run "$SGIT" add new.txt
  assert_success
  run git diff --cached --name-only
  assert_output --partial "new.txt"
}

@test "sub removes a file from staging" {
  echo "new" > new.txt
  git add new.txt
  run "$SGIT" sub new.txt
  assert_success
  run git diff --cached --name-only
  refute_output --partial "new.txt"
}

@test "sub -a unstages everything" {
  echo "a" > a.txt
  echo "b" > b.txt
  git add a.txt b.txt
  run "$SGIT" sub -a
  assert_success
  run git diff --cached --name-only
  refute_output --partial "a.txt"
  refute_output --partial "b.txt"
}

@test "amend -A amends last commit without changing message" {
  create_commits 1
  local original_msg
  original_msg=$(git log -1 --format=%s)
  make_dirty
  run "$SGIT" amend -A
  assert_success
  [[ "$(git log -1 --format=%s)" == "$original_msg" ]]
}

@test "amend -A keeps same commit count" {
  create_commits 1
  local count_before
  count_before=$(git rev-list --count HEAD)
  make_dirty
  run "$SGIT" amend -A
  assert_success
  local count_after
  count_after=$(git rev-list --count HEAD)
  [[ "$count_before" == "$count_after" ]]
}

@test "tag creates an annotated tag" {
  create_commits 1
  run "$SGIT" tag v1.0.0
  assert_success
  run git tag -l v1.0.0
  assert_output "v1.0.0"
}

@test "tag message matches tag name" {
  create_commits 1
  run "$SGIT" tag v2.0.0
  assert_success
  run git tag -n1 v2.0.0
  assert_output --partial "v2.0.0"
}

@test "amend --message with multi-word message" {
  create_commits 1
  run "$SGIT" amend --message "this is a multi-word message"
  assert_success
  run git log -1 --format=%s
  assert_output "this is a multi-word message"
}

@test "amend -A --add-specific with spaced file path" {
  touch "my file.txt"
  run "$SGIT" amend -a "my file.txt"
  assert_success
  run git log -1 --name-only
  assert_output --partial "my file.txt"
}
