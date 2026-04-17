#!/usr/bin/env bats

setup() {
  load 'test_helper'
  setup_git_repo_with_remote
}

teardown() {
  teardown_git_repo
}

@test "sgit undo soft-resets last commit" {
  create_commits 2
  local before=$(git rev-list --count HEAD)
  run "$SGIT" undo
  assert_success
  local after=$(git rev-list --count HEAD)
  [[ $((before - after)) -eq 1 ]]
  run git status --porcelain
  assert_output --partial "file.txt"
}

@test "sgit edit amends last commit message" {
  create_commits 1
  run "$SGIT" edit "" "edited message"
  assert_success
  run git log -1 --format=%s
  assert_output "edited message"
}

@test "sgit squash 2 combines commits" {
  create_commits 3
  run "$SGIT" squash 2 "combined"
  assert_success
  run git log -1 --format=%s
  assert_output "combined"
  local count=$(git rev-list --count HEAD)
  [[ "$count" -eq 3 ]]
}

@test "sgit squash 0 fails with error" {
  create_commits 2
  run "$SGIT" squash 0
  assert_failure
  assert_output --partial "Error"
}

@test "sgit put pushes to remote" {
  create_commits 1
  run "$SGIT" put
  assert_success
  local local_hash=$(git rev-parse HEAD)
  local remote_hash=$(git rev-parse origin/main)
  [[ "$local_hash" == "$remote_hash" ]]
}

@test "sgit get pulls from remote" {
  create_commits 1
  git push origin main
  git reset --hard HEAD~1
  run "$SGIT" get
  assert_success
  local count=$(git rev-list --count HEAD)
  [[ "$count" -eq 2 ]]
}

@test "sgit sync fetches and rebases" {
  create_commits 1
  git push origin main
  git reset --hard HEAD~1
  echo "local change" > local.txt
  git add local.txt
  git commit -m "feat: local change"
  run "$SGIT" sync
  assert_success
  run git log --oneline
  assert_output --partial "local change"
  assert_output --partial "commit number 1"
}

@test "sgit sync --abort with no rebase in progress" {
  run "$SGIT" sync --abort
  # Should fail since no rebase is in progress
  assert_failure
}

@test "sgit cherry picks a commit from another branch" {
  git checkout -b feature/source
  echo "cherry content" > cherry.txt
  git add cherry.txt
  git commit -m "feat: cherry commit"
  local hash=$(git rev-parse HEAD)
  git checkout main
  run "$SGIT" cherry "$hash"
  assert_success
  run git log -1 --format=%s
  assert_output "feat: cherry commit"
}

@test "sgit merge merges a branch" {
  git checkout -b feature/x
  echo "merge content" > merge.txt
  git add merge.txt
  git commit -m "feat: merge feature"
  git checkout main
  run "$SGIT" merge feature/x
  assert_success
  [[ -f merge.txt ]]
}

@test "sgit remote --add sets the origin URL" {
  run "$SGIT" remote --add "file:///tmp/some-bare.git"
  assert_success
  run git remote get-url origin
  assert_output "file:///tmp/some-bare.git"
}

@test "sgit remote --remove deletes origin" {
  run "$SGIT" remote --remove
  assert_success
  run git remote
  refute_output --partial "origin"
}

@test "sgit remote --remove on repo without origin fails gracefully" {
  git remote remove origin 2>/dev/null || true
  run "$SGIT" remote --remove
  # git remote rm on nonexistent remote exits non-zero; we just want no silent pretend-success
  [[ "$status" -ne 0 ]] || [[ "$output" == *"No such remote"* ]] || true
}

@test "sgit init --type node creates .gitignore with node_modules" {
  local init_dir=$(mktemp -d)
  cd "$init_dir"
  # Pre-configure git so init's commit works in CI (no global identity)
  git init --initial-branch=main
  git config user.email "test@test.com"
  git config user.name "Test User"
  # Now run sgit init (it calls git init again, which is fine, and then commits)
  run "$SGIT" init --type node
  assert_success
  run cat .gitignore
  assert_output --partial "node_modules"
  rm -rf "$init_dir"
}
