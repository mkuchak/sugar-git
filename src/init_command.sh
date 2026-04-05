git init
git branch -M main
git config push.followTags true

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
