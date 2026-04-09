#!/usr/bin/env bats

setup() {
  load 'test_helper'
  setup_git_repo
}

teardown() {
  teardown_git_repo
}

@test "temp creates a WIP commit with file names" {
  echo "change" >> file.txt
  run "$SGIT" temp -A -A
  assert_success
  run git log -1 --format=%s
  assert_output --partial "chore: WIP"
  assert_output --partial "file.txt"
}

@test "temp with description uses custom message" {
  echo "change" >> file.txt
  run "$SGIT" temp -A "halfway through auth" -A
  assert_success
  run git log -1 --format=%s
  assert_output "chore: WIP halfway through auth"
}

@test "temp bumps counter on second temp" {
  echo "change1" >> file.txt
  run "$SGIT" temp -A
  assert_success

  echo "change2" >> file2.txt
  run "$SGIT" temp -A
  assert_success
  run git log -1 --format=%s
  assert_output --partial "chore: WIP(2)"
}

@test "temp bumps counter on third temp" {
  echo "change1" >> file.txt
  run "$SGIT" temp -A
  assert_success

  echo "change2" >> file2.txt
  run "$SGIT" temp -A
  assert_success

  echo "change3" >> file3.txt
  run "$SGIT" temp -A
  assert_success
  run git log -1 --format=%s
  assert_output --partial "chore: WIP(3)"
}

@test "temp amend keeps single commit" {
  local before=$(git rev-list --count HEAD)

  echo "change1" >> file.txt
  run "$SGIT" temp -A
  echo "change2" >> file2.txt
  run "$SGIT" temp -A

  local after=$(git rev-list --count HEAD)
  # Should only be 1 more commit than before (not 2)
  [[ $((after - before)) -eq 1 ]]
}

@test "temp after a real commit creates fresh WIP" {
  echo "change" >> file.txt
  git add file.txt
  git commit -m "feat: real commit"

  echo "more changes" >> file.txt
  run "$SGIT" temp -A
  assert_success
  run git log -1 --format=%s
  assert_output --partial "chore: WIP"
  # Should NOT have a counter
  refute_output --partial "WIP("
}
