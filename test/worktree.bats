#!/usr/bin/env bats

setup() {
  load 'test_helper'
  setup_git_repo
}

teardown() {
  # Remove worktree before teardown to avoid git complaints
  for wt in test-branch test-envs; do
    if [[ -d "../$wt" ]]; then
      git worktree remove --force "../$wt" 2>/dev/null || true
      rm -rf "../$wt"
    fi
  done
  teardown_git_repo
}

# --- worktree add ---

@test "worktree add: creates worktree at ../test-branch" {
  run "$SGIT" worktree add test-branch --no-install
  assert_success
  assert_output --partial "Worktree ready!"
  [[ -d "../test-branch" ]]
}

# --- worktree ls ---

@test "worktree ls: lists worktrees after add" {
  "$SGIT" worktree add test-branch --no-install
  run "$SGIT" worktree ls
  assert_success
  local count
  count=$(echo "$output" | wc -l | tr -d ' ')
  [[ "$count" -ge 2 ]]
}

# --- worktree rm ---

@test "worktree rm: removes the worktree" {
  "$SGIT" worktree add test-branch --no-install
  run "$SGIT" worktree rm test-branch
  assert_success
  assert_output --partial "removed"
  [[ ! -d "../test-branch" ]]
}

# --- worktree prune ---

@test "worktree prune: runs without error" {
  run "$SGIT" worktree prune
  assert_success
  assert_output --partial "Stale worktree references cleaned"
}

# --- .sgitlinks @envs ---

@test "worktree add: @envs links .env files even when subdirs are gitignored-only" {
  # The subdirectories apps/api and workers/w1 exist only because of their
  # gitignored .env files. `git worktree add` won't check them out, so the
  # @envs logic must create the parent dirs before symlinking.
  echo ".env" > .gitignore
  mkdir -p apps/api workers/w1
  echo "API_KEY=main" > apps/api/.env
  echo "Q=main" > workers/w1/.env
  cat > .sgitlinks <<'SGITLINKS'
@envs apps workers
SGITLINKS
  git add .gitignore .sgitlinks
  git commit -m "chore: setup"

  run "$SGIT" worktree add test-envs --no-install
  assert_success
  assert_output --partial "Linked apps/api/.env"
  assert_output --partial "Linked workers/w1/.env"

  # The symlinks must exist and be readable
  [[ -L "../test-envs/apps/api/.env" ]]
  [[ -L "../test-envs/workers/w1/.env" ]]
  run cat "../test-envs/apps/api/.env"
  assert_output "API_KEY=main"
  run cat "../test-envs/workers/w1/.env"
  assert_output "Q=main"
}
