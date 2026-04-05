#!/usr/bin/env bats

setup() {
  load 'test_helper'
  setup_git_repo
}

teardown() {
  teardown_git_repo
}

# --- handle_custom_date ---

@test "handle_custom_date: date without time should fail" {
  make_dirty
  run "$SGIT" feat "test" -A -d 2025-01-15
  assert_failure
  assert_output --partial "Both --date and --time flags must be used together"
}

@test "handle_custom_date: time without date should fail" {
  make_dirty
  run "$SGIT" feat "test" -A -t 10:30:00
  assert_failure
  assert_output --partial "Both --date and --time flags must be used together"
}

@test "handle_custom_date: invalid month should fail" {
  make_dirty
  run "$SGIT" feat "test" -A -d 2025-13-15 -t 10:30:00
  assert_failure
  assert_output --partial "Invalid month"
}

@test "handle_custom_date: invalid hour should fail" {
  make_dirty
  run "$SGIT" feat "test" -A -d 2025-01-15 -t 25:30:00
  assert_failure
  assert_output --partial "Invalid hour"
}

@test "handle_custom_date: valid date and time sets commit date" {
  make_dirty
  run "$SGIT" feat "test" -A -d 2025-01-15 -t 10:30:00
  assert_success
  local commit_date
  commit_date=$(git log -1 --format=%ai)
  [[ "$commit_date" == *"2025-01-15"* ]]
}

# --- conventional_commit ---

@test "conventional_commit: type and description format" {
  make_dirty
  run "$SGIT" feat "add feature" -A
  assert_success
  local msg
  msg=$(git log -1 --format=%s)
  [[ "$msg" == "feat: add feature" ]]
}

@test "conventional_commit: type with scope" {
  make_dirty
  run "$SGIT" feat -s api "add endpoint" -A
  assert_success
  local msg
  msg=$(git log -1 --format=%s)
  [[ "$msg" == "feat(api): add endpoint" ]]
}

@test "conventional_commit: type with scope and breaking change" {
  make_dirty
  run "$SGIT" feat -s api -b "drop v1" -A
  assert_success
  local msg
  msg=$(git log -1 --format=%s)
  [[ "$msg" == "feat(api)!: drop v1" ]]
}
