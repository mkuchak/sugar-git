<p align="center">
   <img src="https://user-images.githubusercontent.com/3791148/115315966-cafc8580-a14e-11eb-910d-452851ad87af.png" alt="Sugar Git" height="160" />
   <h1 align="center">Sugar Git</h1>
</p>

<p align="center">Syntactic sugar for Git, respecting semantics and modern conventions</p>

<div align="center">
   <video src="https://user-images.githubusercontent.com/3791148/141038463-a3af79ac-c87a-493b-b6d7-af1a6e80f6d0.mp4" / >
</div>

## Prerequisites

- Bash 4.0 or higher (`brew install bash` on mac).
- curl
- git

## Installation

### Installing using the setup script

This setup script will download the sgit executable to /usr/local/bin/ and install an autocomplete script in the bash completions directory.

```bash
$ bash <(curl -Ls raw.githubusercontent.com/mkuchak/sugar-git/main/setup)
```

### Installing manually

Download the [sgit](https://github.com/mkuchak/sugar-git/releases/latest/download/sgit) binary from the latest release to `/usr/local/bin/` or anywhere in your `PATH`, and make it executable.

If you wish to have all package name auto-completed for all `sgit` commands, add this line to your startup script (for example: `~/.bashrc` or `~/.zshrc`):

```bash
eval "$(sgit completions)"
```

### Tips: edit your default git editor, automatic push tags... (optional)

```bash
$ git config --global core.editor "code --wait" # nano, vim...
$ git config --global push.followTags true
$ git config --global user.name "Your Name"
$ git config --global user.email "youremail@yourdomain.com"
```

## Quick Start

```bash
# Initialize a new repository with a Node.js .gitignore
$ sgit init --type node

# Create a new feature branch based on main
$ sgit take -f "my awesome feature" --from main -o

# Result:
# git fetch origin
# git checkout -b "feature/my-awesome-feature" main
# git push -u origin "feature/my-awesome-feature"

# Create a new file
$ echo "Hello, world!" > README.md

# Initial commit
$ sgit feat "initial commit" -Ap

# Result:
# git add --all
# git commit -m "feat: initial commit"
# git push origin feature/my-awesome-feature

# Quick free-form commit
$ sgit commit "add project configuration" -Ap

# Result:
# git add --all
# git commit -m "add project configuration"
# git push origin feature/my-awesome-feature

# Sync with main to get latest changes
$ sgit sync main

# Result:
# git fetch origin
# git rebase origin/main

# Stash your work, switch branch, come back
$ sgit stash put -m "half-done auth flow"
$ sgit cd main
$ sgit cd feature/my-awesome-feature
$ sgit stash get

# Squash last 3 messy commits into one clean commit
$ sgit squash 3 "feat: implement auth flow"

# Amend last commit with new changes and updated message
$ sgit amend -Am "feat: complete auth flow"

# Result:
# git add --all
# git commit --amend -m "feat: complete auth flow"

# Add an annotated tag
$ sgit tag v1.0.0

# Push to remote
$ sgit put

# Clean up stale merged branches
$ sgit clean

# Purge build artifacts (preview first)
$ sgit purge --dry-run
$ sgit purge --yes
```

## Usage

### All commands

```
$ sgit -h
sgit - Syntactic sugar for Git, respecting semantics and modern conventions

Usage:
  sgit COMMAND
  sgit [COMMAND] --help | -h
  sgit --version | -v

Branches Commands:
  ls            List all branches, only remote or only local
  take          Create new branch
  cd            Change the current working branch
  mv            Rename some branch
  rm            Delete some branch
  clean         Delete branches that have been merged into main
  worktree      Manage git worktrees with automatic setup (alias: wt)

State Commands:
  auth          Save credentials storage in git repository
  remote        Show the current remote repository
  wipe          Wipe the working branch as per the remote branch
  undo          Back the commit history, but it preserves the file contents (alias: rb)
  edit          Edit some commit message
  squash        Squash the last N commits into one
  get           Fetch and merge changes from remote branch to working branch (pull shortcut)
  put           Send committed changes from working branch to the respective remote branch (push shortcut)
  sync          Fetch and rebase changes from remote branch to working branch
  cherry        Cherry-pick a commit into the current branch
  merge         Merge a branch into the current branch
  init          Initialize a new git repository with recommended settings

Consult Commands:
  log           Search in the history commit by applying some filters
  status        Show the current state of git working directory and staging area
  incoming      Show the incoming commits from remote branch that is not in the working branch
  outgoing      Show the outgoing commits from working branch that is not in the remote branch
  committers    Show the committers of the current branch
  diff          Show changes between commits, working tree, or staging area

Staging Commands:
  add           Add files or directories to staging area
  unstage       Remove files or directories from staging area (alias: sub)
  amend         Add all untracked, modified and deleted files to the last commit
  resolve       Resolve conflicts in the working branch
  tag           Add an annotated tag with the description same as the message
  stash         Manage work-in-progress changes

Commit Commands:
  commit        Commit with a custom message (alias: c)
  build         Changes that affect the build system or external dependencies
  chore         Code change that external user won't see
  ci            Changes to our CI configuration files and scripts
  docs          Documentation only changes
  feat          New feature
  fix           Bug fix
  localize      Translations update
  perf          Code change that improves performance
  refactor      Code change that neither fixes a bug nor adds a feature
  revert        Reverts a previous commit
  style         Changes that do not affect the meaning of the code
  test          Adding missing tests or correcting existing tests

Maintenance Commands:
  purge         Delete build artifacts, caches, and optionally lock files

Completions Commands:
  completions   Generate bash completions

Options:
  --help, -h
    Show this help

  --version, -v
    Show version number
```

### Branching conventions

```
$ sgit take -h
sgit take - Create new branch

Alias: mkdir

Usage:
  sgit take [DESCRIPTION] [OPTIONS]
  sgit take --help | -h

Options:
  --origin, -o         Also create the branch in the origin
  --only-origin, -O    Only create the branch in the origin
  --from BRANCH        Base branch to create the new branch from
  --main               The production branch
  --staging, -s        Demo branch and decisions about release features
  --test, -t           Contains all codes ready for QA testing
  --dev, -d            All new features and bug fixes
  --feature, -f        New module or use case
  --bugfix, -b         Rejected changes after release, sprint or demo
  --hotfix, -H         Immediate fix, merge directly to production
  --experimental, -e   Not part of a release or sprint
  --build, -u          Build artifacts or code coverage runs
  --release, -r        Tagging a specific release version
  --merge, -m          Resolving merge conflicts between branches

Examples:
  $ sgit take -f "my really awesome feature" -o --from develop
  # git fetch origin
  # git checkout -b "feature/my-really-awesome-feature" develop
  # git push -u origin "feature/my-really-awesome-feature"
```

### Syncing with remote

```bash
# Sync current branch with its remote
$ sgit sync

# Sync current branch with main (rebase on top of main)
$ sgit sync main

# If conflicts occur:
$ sgit sync -c    # continue after resolving
$ sgit sync -s    # skip the conflicting commit
$ sgit sync -a    # abort and undo
```

### Stash management

```bash
# Save work in progress
$ sgit stash put -m "WIP: auth flow"

# Save only specific files
$ sgit stash put src/auth.ts src/config.ts

# Include untracked files
$ sgit stash put -u

# List stashes
$ sgit stash ls

# Preview what's in a stash
$ sgit stash peek        # full diff
$ sgit stash peek --stat # summary only
$ sgit stash peek 2      # peek at index 2

# Restore and remove from stash
$ sgit stash get          # pop most recent
$ sgit stash get 2        # pop index 2

# Restore but keep in stash
$ sgit stash keep

# Move changes to another branch (stash + checkout + pop)
$ sgit stash move feature/auth -m "WIP"

# Drop stashes
$ sgit stash drop          # drop most recent
$ sgit stash drop 3        # drop index 3
$ sgit stash drop --all    # clear all (with confirmation)
```

### Worktree management

```bash
# Create a worktree for an existing branch
$ sgit wt add feature/auth

# Create with auto-generated branch name
$ sgit wt add

# Create from a specific base branch
$ sgit wt add feature/new-thing --from develop

# Symlink extra config files
$ sgit wt add feature/auth -s tilt/data -s .workspace

# Skip auto dependency install
$ sgit wt add feature/auth --no-install

# Add symlinks to an existing worktree
$ sgit wt link -s tilt/data -s .env.local

# List all worktrees
$ sgit wt ls

# Remove a worktree
$ sgit wt rm feature-auth

# Clean stale references
$ sgit wt prune
```

Configure which files to auto-symlink by creating a `.sgitlinks` file in the project root:

```
# Files and directories to symlink into new worktrees
.env
.serena
.tickets
.workspace

# Auto-symlink nested .env files in these directories
@envs apps workers packages
```

### Purging build artifacts

```bash
# Preview what would be deleted
$ sgit purge --dry-run

# Delete build artifacts and caches
$ sgit purge

# Also delete lock files (pnpm-lock.yaml, yarn.lock, etc.)
$ sgit purge --locks

# Delete everything without confirmation
$ sgit purge --all --yes
```

Supports: Node.js, Rust, Python, Java, Go, .NET, Ruby, Dart/Flutter, iOS/Android, Terraform, and more.

### Conventional commits

All commit commands follow the [Conventional Commits](https://www.conventionalcommits.org/) specification and share the same flags:

| Flag | Short | Description |
|------|-------|-------------|
| `--scope` | `-s` | Scope for contextual information, e.g. `feat -s auth` |
| `--breaking-change` | `-b` | Mark as breaking change (appends `!`) |
| `--edit` | `-e` | Open editor to complete the message |
| `--add` | `-a` | Stage a specific file before committing |
| `--add-all` | `-A` | Stage all changes before committing |
| `--put` | `-p` | Push to remote after committing |
| `--force` | `-f` | Force push if `--put` is used |
| `--date` | `-d` | Set commit date (YYYY-MM-DD, requires `--time`) |
| `--time` | `-t` | Set commit time (HH:MM:SS, requires `--date`) |

```bash
# Feature with scope and push
$ sgit feat -s "auth" "add OAuth2 login" -Ap

# Bug fix with breaking change, open editor
$ sgit fix "resolve null pointer in parser" -be

# Free-form commit (no type prefix)
$ sgit commit "whatever message you want" -Ap

# Squash last 3 commits
$ sgit squash 3 "feat: unified auth implementation"

# Edit an old commit message (fully automated)
$ sgit edit abc1234 "fix: correct the typo"

# Edit an old commit message (opens editor)
$ sgit edit abc1234
```

## Development

### Building from source

Requires [Bashly](https://bashly.dev) (`gem install bashly`).

```bash
# Compile sgit from src/
$ make build

# Install to /usr/local/bin/
$ make install

# Clean compiled output
$ make clean
```

### Release process

Releases are automated via GitHub Actions. On every push to `main`:

1. Bashly compiles `sgit` from source
2. Version is auto-bumped based on [Conventional Commits](https://www.conventionalcommits.org/) (`feat:` = minor, `fix:` = patch, `!` = major)
3. A GitHub Release is created with the compiled `sgit` binary and a changelog

## Contributing / Support

If you experience any issue, have a question or a suggestion, or if you wish to contribute, feel free to [open an issue](https://github.com/mkuchak/sugar-git/issues).

## References

This project was a compilation of ideas and standards already established. Credit remains for each article or project.

https://www.conventionalcommits.org/en/v1.0.0/

https://dev.to/couchcamote/git-branching-name-convention-cch

https://dev.to/i5han3/git-commit-message-convention-that-you-can-follow-1709

https://github.com/fteem/git-semantic-commits
