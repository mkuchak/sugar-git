#!/usr/bin/env bats

setup() {
  load 'test_helper'
}

@test "completions: no reference to removed commands" {
  run "$SGIT" completions
  assert_success
  refute_output --partial "rollback"
  refute_output --partial "'save'"
  refute_output --partial "--origin"
  refute_output --partial "--only-origin"
}

@test "completions: current commands are present" {
  run "$SGIT" completions
  assert_success
  assert_output --partial "take"
  assert_output --partial "stash"
  assert_output --partial "worktree"
  assert_output --partial "temp"
  assert_output --partial "sync"
  assert_output --partial "purge"
  assert_output --partial "squash"
  assert_output --partial "clean"
  assert_output --partial "commit"
  assert_output --partial "diff"
  assert_output --partial "cherry"
  assert_output --partial "merge"
  assert_output --partial "init"
  assert_output --partial "auth"
  assert_output --partial "remote"
  assert_output --partial "undo"
  assert_output --partial "resolve"
}

@test "completions: commit-type commands expose modern flags" {
  run "$SGIT" completions
  assert_success
  # At least one conventional commit type must offer --bypass, --date, --time
  assert_output --partial "--bypass"
  assert_output --partial "--date"
  assert_output --partial "--time"
}

@test "completions: get exposes --rebase; put exposes --bypass" {
  run "$SGIT" completions
  assert_success
  # get should have --rebase (recent addition)
  [[ "$output" == *"'get'"*"--rebase"* ]]
  # put should offer --bypass
  [[ "$output" == *"'put'"*"--bypass"* ]]
}

@test "completions: remote exposes --remove" {
  run "$SGIT" completions
  assert_success
  [[ "$output" == *"'remote'"*"--remove"* ]]
}
