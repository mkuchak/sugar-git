git init
git branch -M main

# Modern git defaults that every team eventually sets by hand.
# Local-only — never overwrites pre-existing global preferences.
git config push.followTags true
git config pull.rebase true
git config push.autoSetupRemote always
git config push.default current
git config rerere.enabled true
git config diff.algorithm histogram
git config branch.sort -committerdate
git config column.ui auto
git config fetch.prune true
git config fetch.pruneTags true

# zdiff3 conflict markers require git 2.35+; gracefully degrade for older git.
git_version=$(git --version | awk '{print $3}')
if [[ "$(printf '%s\n' "2.35.0" "$git_version" | sort -V | head -n1)" == "2.35.0" ]]; then
  git config merge.conflictStyle zdiff3
else
  git config merge.conflictStyle diff3
fi

project_type="${args[--type]:-}"

if [[ -n "$project_type" ]]; then
  case "$project_type" in
    node)
      cat > .gitignore << 'GITIGNORE'
node_modules/
dist/
build/
.next/
.nuxt/
.output/
.cache/
.turbo/
*.log
.env
.env.local
.env.*.local
.DS_Store
coverage/
.nyc_output/
GITIGNORE
      ;;
    python)
      cat > .gitignore << 'GITIGNORE'
__pycache__/
*.py[cod]
*$py.class
*.egg-info/
dist/
build/
.venv/
venv/
.env
.mypy_cache/
.pytest_cache/
.ruff_cache/
htmlcov/
.DS_Store
GITIGNORE
      ;;
    go)
      cat > .gitignore << 'GITIGNORE'
vendor/
*.exe
*.exe~
*.dll
*.so
*.dylib
*.test
*.out
.env
.DS_Store
GITIGNORE
      ;;
    rust)
      cat > .gitignore << 'GITIGNORE'
/target
**/*.rs.bk
.env
.DS_Store
GITIGNORE
      ;;
    java)
      cat > .gitignore << 'GITIGNORE'
*.class
*.jar
*.war
*.ear
.gradle/
build/
target/
.env
.DS_Store
GITIGNORE
      ;;
    general)
      cat > .gitignore << 'GITIGNORE'
.env
.DS_Store
Thumbs.db
*.log
*.swp
*.swo
*~
.idea/
.vscode/
GITIGNORE
      ;;
  esac
  echo "Created .gitignore for $project_type project."
fi

git commit --allow-empty -m "chore: initial commit"
echo "Repository initialized."
