#!/usr/bin/env bash

# Load bats assertion libraries
load 'libs/bats-support/load'
load 'libs/bats-assert/load'

# Path to the compiled sgit binary
SGIT="${BATS_TEST_DIRNAME}/../sgit"

# Create a temporary git repo for each test
setup_git_repo() {
  TEST_REPO=$(mktemp -d)
  cd "$TEST_REPO"
  git init --initial-branch=main
  git config user.email "test@test.com"
  git config user.name "Test User"
  echo "init" > file.txt
  git add file.txt
  git commit -m "chore: initial commit"
}

# Create a temporary git repo with a local bare remote
setup_git_repo_with_remote() {
  REMOTE_REPO=$(mktemp -d)
  git init --bare "$REMOTE_REPO"

  TEST_REPO=$(mktemp -d)
  cd "$TEST_REPO"
  git init --initial-branch=main
  git config user.email "test@test.com"
  git config user.name "Test User"
  git remote add origin "$REMOTE_REPO"
  echo "init" > file.txt
  git add file.txt
  git commit -m "chore: initial commit"
  git push -u origin main
}

# Clean up temporary directories
teardown_git_repo() {
  cd /
  [[ -n "$TEST_REPO" ]] && rm -rf "$TEST_REPO" || true
  [[ -n "$REMOTE_REPO" ]] && rm -rf "$REMOTE_REPO" || true
}

# Helper: create N commits for testing history operations
create_commits() {
  local n=$1
  for i in $(seq 1 "$n"); do
    echo "change $i" >> file.txt
    git add file.txt
    git commit -m "feat: commit number $i"
  done
}

# Helper: create a dirty working tree
make_dirty() {
  echo "dirty" >> file.txt
}

# Helper: create a dirty working tree with staging
make_dirty_staged() {
  echo "dirty" >> file.txt
  git add file.txt
}
