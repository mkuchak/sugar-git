#!/usr/bin/env bats

setup() {
  load 'test_helper'
  setup_git_repo
}

teardown() {
  # Remove worktree before teardown to avoid git complaints
  for wt in test-branch test-envs test-default; do
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

@test "worktree add: auto-scans .env files when no .sgitlinks exists" {
  # No .sgitlinks file → fallback: scan the whole repo for .env* files.
  # Must link real envs, skip examples, and skip node_modules.
  echo ".env" > .gitignore
  echo "node_modules" >> .gitignore
  mkdir -p apps/web-app apps/api workers/billing node_modules/bad-pkg
  echo "DB=main"        > apps/web-app/.env
  echo "EXAMPLE=ignored" > apps/web-app/.env.example
  echo "API=main"       > apps/api/.env
  echo "LOCAL=true"     > apps/api/.env.local
  echo "REDIS=main"     > workers/billing/.env
  echo "SHOULD=skip"    > node_modules/bad-pkg/.env
  git add .gitignore
  git commit -m "chore: setup"

  run "$SGIT" worktree add test-default --no-install
  assert_success
  assert_output --partial "Auto-linking .env files"
  assert_output --partial "Linked apps/web-app/.env"
  assert_output --partial "Linked apps/api/.env"
  assert_output --partial "Linked apps/api/.env.local"
  assert_output --partial "Linked workers/billing/.env"

  # node_modules must be pruned from the scan
  refute_output --partial "node_modules"
  # .env.example must not be linked
  refute_output --partial ".env.example"
  [[ ! -e "../test-default/apps/web-app/.env.example" ]] || [[ ! -L "../test-default/apps/web-app/.env.example" ]]

  # Each link must resolve to the main worktree
  [[ -L "../test-default/apps/web-app/.env" ]]
  [[ -L "../test-default/apps/api/.env.local" ]]
  run cat "../test-default/apps/web-app/.env"
  assert_output "DB=main"
}

@test "worktree add: .sgitlinks takes precedence over auto-scan" {
  # When .sgitlinks exists, the auto-scan must NOT run — only the
  # explicit directives take effect.
  echo ".env" > .gitignore
  mkdir -p apps/web-app workers/billing
  echo "LINKED=yes" > apps/web-app/.env
  echo "NOT_LINKED=because-not-in-sgitlinks" > workers/billing/.env
  cat > .sgitlinks <<'SGITLINKS'
@envs apps
SGITLINKS
  git add .gitignore .sgitlinks
  git commit -m "chore: setup"

  run "$SGIT" worktree add test-envs --no-install
  assert_success
  assert_output --partial "Linking configurations from .sgitlinks"
  refute_output --partial "Auto-linking"
  assert_output --partial "Linked apps/web-app/.env"
  # workers/ was NOT in @envs → must not be linked
  refute_output --partial "workers/billing/.env"
  [[ ! -L "../test-envs/workers/billing/.env" ]]
}

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
