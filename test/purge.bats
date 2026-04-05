#!/usr/bin/env bats

setup() {
  load 'test_helper'
  setup_git_repo
}

teardown() {
  teardown_git_repo
}

# --- purge dry-run ---

@test "purge dry-run: no artifacts says Nothing to purge" {
  run "$SGIT" purge --dry-run
  assert_success
  assert_output --partial "Nothing to purge"
}

@test "purge dry-run: shows node_modules in output" {
  mkdir -p node_modules/.cache
  echo "x" > node_modules/.cache/file
  run "$SGIT" purge --dry-run
  assert_success
  assert_output --partial "node_modules"
}

@test "purge dry-run: shows .DS_Store in output" {
  echo "x" > .DS_Store
  run "$SGIT" purge --dry-run
  assert_success
  assert_output --partial ".DS_Store"
}

# --- purge --yes ---

@test "purge --yes: actually deletes node_modules" {
  mkdir -p node_modules/.cache
  echo "x" > node_modules/.cache/file
  run "$SGIT" purge --yes
  assert_success
  [[ ! -d "node_modules" ]]
}

# --- purge --locks ---

@test "purge --locks --dry-run: shows yarn.lock" {
  echo "x" > yarn.lock
  run "$SGIT" purge --locks --dry-run
  assert_success
  assert_output --partial "yarn.lock"
}

@test "purge dry-run: does NOT show yarn.lock without --locks" {
  echo "x" > yarn.lock
  run "$SGIT" purge --dry-run
  assert_success
  refute_output --partial "yarn.lock"
}
