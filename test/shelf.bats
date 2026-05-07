#!/usr/bin/env bats

setup() {
  load 'test_helper'
  setup_git_repo
}

teardown() {
  # Drop any leftover shelf refs created during the test.
  for ref in $(git for-each-ref refs/sgit/shelf/ --format='%(refname)' 2>/dev/null); do
    git update-ref -d "$ref" 2>/dev/null || true
  done
  teardown_git_repo
}

# --- shelf put ---

@test "shelf put: removes N commits from HEAD and creates a ref" {
  create_commits 3
  local before
  before=$(git rev-list --count HEAD)
  run "$SGIT" shelf put 2
  assert_success
  assert_output --partial "Shelved 2 commit(s)"
  local after
  after=$(git rev-list --count HEAD)
  [[ $((before - after)) -eq 2 ]]
  local n
  n=$(git for-each-ref refs/sgit/shelf/ | wc -l | tr -d ' ')
  [[ "$n" -eq 1 ]]
}

@test "shelf put: defaults to 1 commit" {
  create_commits 2
  local before
  before=$(git rev-list --count HEAD)
  run "$SGIT" shelf put
  assert_success
  local after
  after=$(git rev-list --count HEAD)
  [[ $((before - after)) -eq 1 ]]
}

@test "shelf put: refuses with dirty working tree" {
  create_commits 1
  echo "dirty" >> file.txt
  run "$SGIT" shelf put
  assert_failure
  assert_output --partial "uncommitted"
}

@test "shelf put: refuses if N > available commits" {
  create_commits 1
  # Total commits = 2 (initial + 1 created)
  run "$SGIT" shelf put 5
  assert_failure
  assert_output --partial "only 2"
}

@test "shelf put: refuses non-positive count" {
  create_commits 1
  run "$SGIT" shelf put 0
  assert_failure
  assert_output --partial "positive integer"
}

@test "shelf put: refuses merge commits in range" {
  create_commits 1
  git checkout -b feature/x
  echo "fx" > fx.txt
  git add fx.txt
  git commit -m "feat: fx"
  git checkout main
  git merge --no-ff feature/x -m "merge: fx"
  run "$SGIT" shelf put 1
  assert_failure
  assert_output --partial "merge"
}

# --- shelf ls ---

@test "shelf ls: empty list when no shelves" {
  run "$SGIT" shelf ls
  assert_success
  assert_output --partial "No shelved"
}

@test "shelf ls: shows entries with index" {
  create_commits 3
  "$SGIT" shelf put 1
  run "$SGIT" shelf ls
  assert_success
  assert_output --partial "[0]"
  assert_output --partial "1 commit"
  assert_output --partial "commit number 3"
}

@test "shelf ls: orders most recent first" {
  create_commits 2
  "$SGIT" shelf put 1                          # shelves "commit number 2"
  echo "later" > later.txt
  git add later.txt
  git commit -m "feat: later commit"
  sleep 1                                       # ensure committerdate differs
  "$SGIT" shelf put 1                          # shelves "feat: later commit"
  run "$SGIT" shelf ls
  assert_success
  # [0] is the most recent → "later commit"
  [[ "$(echo "$output" | grep -A 1 '\[0\]' | tail -n 1)" == *"later commit"* ]]
  [[ "$(echo "$output" | grep -A 1 '\[1\]' | tail -n 1)" == *"commit number 2"* ]]
}

# --- shelf get ---

@test "shelf get: restores shelved commits and drops the ref" {
  create_commits 2
  local before_count
  before_count=$(git rev-list --count HEAD)
  local before_subject
  before_subject=$(git log -1 --format=%s)
  "$SGIT" shelf put 1
  run "$SGIT" shelf get
  assert_success
  assert_output --partial "Restored 1 commit(s)"
  local after_count
  after_count=$(git rev-list --count HEAD)
  [[ "$before_count" -eq "$after_count" ]]
  local after_subject
  after_subject=$(git log -1 --format=%s)
  [[ "$before_subject" == "$after_subject" ]]
  local n
  n=$(git for-each-ref refs/sgit/shelf/ | wc -l | tr -d ' ')
  [[ "$n" -eq 0 ]]
}

@test "shelf get: by index resolves the right entry" {
  create_commits 2
  "$SGIT" shelf put 1                          # [later 0] "commit number 2"
  echo "z" > z.txt
  git add z.txt
  git commit -m "feat: z commit"
  sleep 1
  "$SGIT" shelf put 1                          # [now 0] "feat: z commit"; [1] "commit number 2"
  run "$SGIT" shelf get 1                      # restore the older one
  assert_success
  run git log -1 --format=%s
  assert_output --partial "commit number 2"
}

@test "shelf get: refuses with dirty working tree" {
  create_commits 2
  "$SGIT" shelf put 1
  echo "dirty" >> file.txt
  run "$SGIT" shelf get
  assert_failure
  assert_output --partial "uncommitted"
}

# --- shelf drop ---

@test "shelf drop: removes ref without changing HEAD" {
  create_commits 2
  "$SGIT" shelf put 1
  local head_before
  head_before=$(git rev-parse HEAD)
  run "$SGIT" shelf drop
  assert_success
  local head_after
  head_after=$(git rev-parse HEAD)
  [[ "$head_before" == "$head_after" ]]
  local n
  n=$(git for-each-ref refs/sgit/shelf/ | wc -l | tr -d ' ')
  [[ "$n" -eq 0 ]]
}

@test "shelf drop: errors when no shelves exist" {
  run "$SGIT" shelf drop
  assert_failure
  assert_output --partial "no shelved"
}

# --- round-trip ---

@test "shelf put + get: round-trips count and content" {
  create_commits 1
  echo "a" > a.txt
  git add a.txt
  git commit -m "feat: file a"
  echo "b" > b.txt
  git add b.txt
  git commit -m "feat: file b"
  local before_count
  before_count=$(git rev-list --count HEAD)
  "$SGIT" shelf put 2
  local after_put_count
  after_put_count=$(git rev-list --count HEAD)
  [[ $((before_count - after_put_count)) -eq 2 ]]
  [[ ! -f a.txt ]]
  [[ ! -f b.txt ]]
  "$SGIT" shelf get
  local after_get_count
  after_get_count=$(git rev-list --count HEAD)
  [[ "$after_get_count" -eq "$before_count" ]]
  [[ -f a.txt ]]
  [[ -f b.txt ]]
}
