#!/usr/bin/env bats

setup() {
  load 'test_helper'
  setup_git_repo
}

teardown() {
  teardown_git_repo
}

@test "feat creates commit with feat prefix" {
  make_dirty
  run "$SGIT" feat "add feature" -A
  assert_success
  [[ "$(git log -1 --format=%s)" == "feat: add feature" ]]
}

@test "fix creates commit with fix prefix" {
  make_dirty
  run "$SGIT" fix "bug" -A
  assert_success
  [[ "$(git log -1 --format=%s)" == "fix: bug" ]]
}

@test "feat with scope creates scoped commit" {
  make_dirty
  run "$SGIT" feat -s "auth" "add login" -A
  assert_success
  [[ "$(git log -1 --format=%s)" == "feat(auth): add login" ]]
}

@test "feat with scope and breaking change" {
  make_dirty
  run "$SGIT" feat -s "api" -b "drop v1" -A
  assert_success
  [[ "$(git log -1 --format=%s)" == "feat(api)!: drop v1" ]]
}

@test "commit without description fails" {
  make_dirty
  run "$SGIT" commit -A
  assert_failure
}

@test "feat with no description and --edit does not crash" {
  make_dirty
  git add --all
  GIT_EDITOR=true run "$SGIT" feat -A -e
  assert_success
}

@test "feat -a stages only the specified file" {
  echo "a" > a.txt
  echo "b" > b.txt
  run "$SGIT" feat "test" -a a.txt
  assert_success
  [[ "$(git log -1 --format=%s)" == "feat: test" ]]
  # b.txt should still be untracked
  run git status --porcelain b.txt
  assert_output --partial "?? b.txt"
}

@test "feat with multi-word description" {
  make_dirty
  run "$SGIT" feat "add a whole new thing with spaces" -A
  assert_success
  [[ "$(git log -1 --format=%s)" == "feat: add a whole new thing with spaces" ]]
}

@test "commit freeform with multi-word description" {
  make_dirty
  run "$SGIT" commit "something with many words here" -A
  assert_success
  [[ "$(git log -1 --format=%s)" == "something with many words here" ]]
}

@test "feat -a with path containing a space" {
  touch "spa ced.txt"
  run "$SGIT" feat "add spaced file" -a "spa ced.txt"
  assert_success
  [[ "$(git log -1 --format=%s)" == "feat: add spaced file" ]]
  run git log -1 --name-only
  assert_output --partial "spa ced.txt"
}
