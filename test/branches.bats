#!/usr/bin/env bats

setup() {
  load 'test_helper'
  setup_git_repo_with_remote
}

teardown() {
  teardown_git_repo
}

@test "sgit ls shows current branch" {
  run "$SGIT" ls
  assert_success
  assert_output --partial "main"
}

@test "sgit ls -l shows local branches" {
  run "$SGIT" ls -l
  assert_success
  assert_output --partial "main"
}

@test "sgit take -f creates feature branch" {
  run "$SGIT" take -f "auth flow"
  assert_success
  run git branch --show-current
  assert_output "feature/auth-flow"
}

@test "sgit take -H creates hotfix branch" {
  run "$SGIT" take -H "critical bug"
  assert_success
  run git branch --show-current
  assert_output "hotfix/critical-bug"
}

@test "sgit take --dev creates develop branch" {
  run "$SGIT" take --dev
  assert_success
  run git branch --show-current
  assert_output "develop"
}

@test "sgit cd switches to branch" {
  git checkout -b feature/test-branch
  git checkout main
  run "$SGIT" cd feature/test-branch
  assert_success
  run git branch --show-current
  assert_output "feature/test-branch"
}

@test "sgit mv renames a branch" {
  git checkout -b feature/auth-flow
  git checkout main
  run "$SGIT" mv feature/auth-flow feature/new-name
  assert_success
  run git branch --list "feature/new-name"
  assert_output --partial "feature/new-name"
}

@test "sgit rm deletes a branch" {
  git checkout -b feature/to-delete
  git checkout main
  run "$SGIT" rm feature/to-delete
  assert_success
  run git branch --list "feature/to-delete"
  assert_output ""
}

@test "sgit clean with no merged branches says no merged branches" {
  run "$SGIT" clean
  assert_success
  assert_output --partial "No merged branches"
}

@test "sgit clean -y deletes merged branch" {
  git checkout -b feature/merged
  echo "merge content" > merge.txt
  git add merge.txt
  git commit -m "feat: merge content"
  git checkout main
  git merge feature/merged
  run "$SGIT" clean -y
  assert_success
  assert_output --partial "Done"
  run git branch --list "feature/merged"
  assert_output ""
}
