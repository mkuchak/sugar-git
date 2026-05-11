#!/usr/bin/env bats

setup() {
  load 'test_helper'
  setup_git_repo
  # Setup: known file with known commit history
  git config user.email "alice@test.com"
  git config user.name "Alice"
  echo "line 1" > known.txt
  echo "line 2" >> known.txt
  echo "line 3" >> known.txt
  git add known.txt
  git commit -m "feat: add known.txt

This is the longer body of the commit message.
It explains why we added these three lines.
"
}

teardown() {
  teardown_git_repo
}

@test "who file: shows blame for the whole file" {
  run "$SGIT" who known.txt
  assert_success
  assert_output --partial "Alice"
  assert_output --partial "line 1"
  assert_output --partial "line 2"
}

@test "who file:line: shows full commit message for that line" {
  run "$SGIT" who known.txt:1
  assert_success
  assert_output --partial "Alice"
  assert_output --partial "feat: add known.txt"
  # The full body should be present, not just the subject
  assert_output --partial "explains why we added these three lines"
}

@test "who file:start-end: handles a range" {
  run "$SGIT" who known.txt:1-3
  assert_success
  # All three lines should be blamed
  assert_output --partial "line 1"
  assert_output --partial "line 2"
  assert_output --partial "line 3"
}

@test "who file:invalid: rejects non-numeric linespec" {
  run "$SGIT" who known.txt:abc
  assert_failure
  assert_output --partial "not a number"
}

@test "who nonexistent: errors clearly" {
  run "$SGIT" who nope.txt:1
  assert_failure
  assert_output --partial "not found"
}

@test "who file:line --diff: includes the diff" {
  run "$SGIT" who known.txt:1 --diff
  assert_success
  # Diff output should include the added-lines marker
  assert_output --partial "+line 1"
}
