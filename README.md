<p align="center">
   <img src="https://user-images.githubusercontent.com/3791148/115315966-cafc8580-a14e-11eb-910d-452851ad87af.png" alt="Sugar Git" height="160" />
   <h1 align="center">Sugar Git</h1>
</p>

<p align="center">Syntactic sugar for Git, respecting semantics and modern conventions</p>

<div align="center">
   <video src="https://user-images.githubusercontent.com/3791148/141038463-a3af79ac-c87a-493b-b6d7-af1a6e80f6d0.mp4" / >
</div>

## Prerequisites

- Bash 4.0+ (`brew install bash` on mac)
- curl
- git

## Installation

```bash
# One-liner (bash/zsh)
curl -sL https://github.com/mkuchak/sugar-git/releases/latest/download/sgit | sudo tee /usr/local/bin/sgit > /dev/null && sudo chmod +x /usr/local/bin/sgit

# Or using the setup script (also installs completions)
curl -Ls raw.githubusercontent.com/mkuchak/sugar-git/main/setup | bash
```

### Updating

```bash
curl -sL https://github.com/mkuchak/sugar-git/releases/latest/download/sgit | sudo tee /usr/local/bin/sgit > /dev/null && sudo chmod +x /usr/local/bin/sgit
```

### Shell completions (optional)

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
eval "$(sgit completions)"
```

## Quick Start

```bash
# Initialize a new repository
$ sgit init --type node

# Create a feature branch from main
$ sgit take -f "my awesome feature" -F main --remote

# Make changes, commit and push in one step
$ sgit feat "initial commit" -Ap

# Free-form commit (no type prefix)
$ sgit commit "add project configuration" -Ap

# Sync with main (fetch + rebase)
$ sgit sync

# Stash, switch, come back
$ sgit stash put -m "half-done auth flow"
$ sgit cd main
$ sgit cd feature/my-awesome-feature
$ sgit stash get

# Squash messy commits before PR
$ sgit squash 3 "feat: implement auth flow"

# Amend last commit with new message
$ sgit amend -Am "feat: complete auth flow"

# Push, tag, clean up
$ sgit put
$ sgit tag v1.0.0
$ sgit clean
```

## Commands

Run `sgit -h` for the full list, or `sgit <command> -h` for help on any command.

### Branches

| Command | Description |
|---------|-------------|
| `sgit ls` | List branches (`-l` local, `-r` remote) |
| `sgit take -f "name"` | Create branch with convention prefix (feature/, bugfix/, hotfix/, etc.) |
| `sgit take` | Create branch with auto-generated UUID name |
| `sgit take -F main` | Create branch based off main |
| `sgit cd <branch>` | Switch branch |
| `sgit mv <old> <new>` | Rename branch (`-r` also on remote) |
| `sgit rm <branch>` | Delete branch (`-r` also on remote) |
| `sgit clean` | Delete branches merged into main (`-r` also on remote) |
| `sgit wt add [branch]` | Create worktree with auto-setup |
| `sgit wt ls` | List worktrees |
| `sgit wt rm <name>` | Remove worktree |

### Syncing

| Command | Description |
|---------|-------------|
| `sgit sync` | Fetch and rebase on main (default) |
| `sgit sync develop` | Fetch and rebase on develop |
| `sgit sync -c` | Continue after resolving conflicts |
| `sgit sync -a` | Abort rebase |
| `sgit sync -s` | Skip conflicting commit |
| `sgit get` | Pull from remote (`-r` to rebase instead of merge) |
| `sgit put` | Push to remote (`-f` to force) |

### Commits

| Command | Description |
|---------|-------------|
| `sgit feat "message" -Ap` | Conventional commit + stage all + push |
| `sgit fix "message" -s api` | Bug fix with scope |
| `sgit commit "message"` | Free-form commit (no type prefix) |
| `sgit amend -A` | Amend last commit with all changes |
| `sgit amend -Am "new msg"` | Amend with new message |
| `sgit squash 3 "message"` | Squash last 3 commits into one |
| `sgit edit <hash> "new msg"` | Reword an old commit (automated) |
| `sgit undo` | Uncommit last commit (keeps files) |

All conventional commit types: `feat`, `fix`, `chore`, `docs`, `build`, `ci`, `test`, `perf`, `refactor`, `revert`, `style`, `localize`.

Shared flags: `-s` scope, `-b` breaking change, `-e` open editor, `-a` add file, `-A` add all, `-p` push, `-f` force, `-d`/`-t` custom date/time.

### Stash

| Command | Description |
|---------|-------------|
| `sgit stash put` | Stash changes (`-m "msg"`, `-u` untracked, or specific files) |
| `sgit stash get` | Pop stash (optional index) |
| `sgit stash ls` | List stashes |
| `sgit stash peek` | Preview stash diff (`--stat` for summary) |
| `sgit stash keep` | Apply without removing from stash |
| `sgit stash drop` | Drop stash (`--all -y` to clear all) |
| `sgit stash move <branch>` | Stash + switch branch + pop |

### Worktrees

```bash
$ sgit wt add feature/auth              # create worktree
$ sgit wt add feature/auth -F develop   # from specific branch
$ sgit wt add                           # auto-UUID branch name
$ sgit wt add feature/auth -s tilt/data # symlink extra paths
$ sgit wt add feature/auth --no-install # skip dep install
$ sgit wt link -s .env -s tilt/data     # add symlinks to existing worktree
```

Auto-symlinks are configured via `.sgitlinks` in the project root:

```
.env
.serena
.tickets
@envs apps workers packages
```

### Purge

```bash
$ sgit purge --dry-run    # preview what would be deleted
$ sgit purge              # delete artifacts + caches
$ sgit purge --locks      # also delete lock files
$ sgit purge --all --yes  # everything, no confirmation
```

Covers: Node.js, Rust, Python, Java, Go, .NET, Ruby, Dart/Flutter, iOS/Android, Terraform, and more.

### Other

| Command | Description |
|---------|-------------|
| `sgit status` | Short status (`git status -s`) |
| `sgit diff` | Show changes (`-s` staged, or diff against branch) |
| `sgit log "term"` | Search commits (`-a` author, `-s` since, `-u` until) |
| `sgit incoming` | Commits on remote not yet in local |
| `sgit outgoing` | Commits in local not yet pushed |
| `sgit cherry <hash>` | Cherry-pick a commit |
| `sgit merge <branch>` | Merge (`--ff`, `--no-ff`) |
| `sgit init --type node` | Init repo with .gitignore template |
| `sgit tag v1.0.0` | Create annotated tag |
| `sgit auth` | Save git credentials (`-g` global) |

## Remote Configuration

By default, sgit uses `origin` as the remote. You can change this:

```bash
# Per-repo
$ git config sgit.remote upstream

# Global
$ git config --global sgit.remote upstream

# Per-command override
$ sgit put -R gitlab
$ sgit sync main -R upstream
```

Resolution order: `-R` flag > `sgit.remote` config > branch tracking remote > `origin`.

## Development

Requires [Bashly](https://bashly.dev) (`gem install bashly`) for building from source.

```bash
$ make build    # compile sgit from src/
$ make test     # run 64 bats-core tests
$ make install  # install to /usr/local/bin/
```

### Releases

Automated via GitHub Actions on every push to `main`:

1. Compiles `sgit` with bashly
2. Runs test suite
3. Auto-bumps version from [Conventional Commits](https://www.conventionalcommits.org/) (`feat:` = minor, `fix:` = patch, `!` = major)
4. Creates GitHub Release with binary and changelog

## Contributing

Feel free to [open an issue](https://github.com/mkuchak/sugar-git/issues) for bugs, questions, or suggestions.

## References

- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- [Git Branching Name Convention](https://dev.to/couchcamote/git-branching-name-convention-cch)
- [Git Commit Message Convention](https://dev.to/i5han3/git-commit-message-convention-that-you-can-follow-1709)
- [Git Semantic Commits](https://github.com/fteem/git-semantic-commits)
