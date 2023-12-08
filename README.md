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

Download the [sgit](sgit) script to `/usr/local/bin/` or anywhere in your `PATH`, and make it executable.

If you wish to have all package name auto-completed for all `sgit` commands, add this line to your startup script (for example: `~/.bashrc` or `~/.zshrc`):

```bash
complete -W '$(sgit list -s)' sgit
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
# Start a new git repository
$ git init

# Create a new feature branch
$ sgit take -f "my awesome feature"

# Result:
# git checkout -b "feature/my-awesome-feature"

# Create new file
$ echo "Hello, world!" > README.MD

# Initial commit
$ sgit feat "initial commit" -Ap

# Result:
# git add --all
# git commit -m "feat: initial commit"
# git push origin feature/my-awesome-feature

# Start Node.js project
$ npm init -y
$ echo "console.log('Hello, world! 🌎')" > index.js

# Commit feat changes
$ sgit feat -s core "add welcome message" -a index.js

# Result:
# git add index.js
# git commit -m "feat(core): add welcome message"

# Commit build changes
$ sgit build "npm init" -Ap

# Result:
# git add --all
# git commit -m "build: npm init"
# git push origin feature/my-awesome-feature

# Update same feature
$ echo "console.log('Hello, folks! 👯')" >> index.js

# Alter last commit with current changes and push to remote repository
$ sgit amend -Apf

# Result:
# git add --all
# git commit --amend --no-edit
# git push origin feature/my-awesome-feature --force

# Add an annotated tag
$ sgit tag v0.1.0

# Result:
# git tag -a v0.1.0 -m 0.1.0

# Push tag to remote repository (if you have configured `git config --global push.followTags true`)
$ sgit put

# Result:
# git push origin feature/my-awesome-feature
```

## Usage

### Management and convention commit commands

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

State Commands:
  save          Save credentials storage in git repository
  remote        Show the current remote repository
  wipe          Wipe the working branch as per the remote branch
  rollback      Back the commit history, but it preserves the file contents
  edit          Edit some commit message
  get           Fetch and merge changes from remote branch to working branch (pull shortcut)
  put           Send committed changes from working branch to the respective remote branch (push shortcut)

Consult Commands:
  log           Search in the history commit by applying some filters
  status        Show the current state of git working directory and staging area
  incoming      Show the incoming commits from remote branch that is not in the working branch
  outgoing      Show the outgoing commits from working branch that is not in the remote branch
  committers    Show the committers of the current branch

Staging Commands:
  add           Add files or directories to staging area
  sub           Remove files or directories from staging area
  amend         Add all untracked, modified and deleted files to the last commit without edit the message
  resolve       Resolve conflicts in the working branch
  tag           Add an annotated tag with the description same as the message

Commit Commands:
  build         Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
  chore         Code change that external user won't see (eg: change to .gitignore file or .prettierrc file)
  ci            Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)
  docs          Documentation only changes
  feat          New feature
  fix           Bug fix
  localize      Translations update
  perf          Code change that improves performance
  refactor      Code change that neither fixes a bug nor adds a feature; refactoring production code, eg. renaming a variable
  revert        Reverts a previous commit
  style         Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
  test          Adding missing tests or correcting existing tests

Completions Commands:
  completions   Generate bash completions

Options:
  --help, -h
    Show this help

  --version, -v
    Show version number
```

### Convention branch commands

```
$ sgit take -h
sgit take - Create new branch

Alias: mkdir

Usage:
  sgit take [DESCRIPTION] [OPTIONS]
  sgit take --help | -h

Options:
  --origin, -o
    Defines if the branch should also be created in the origin

  --only-origin, -O
    Defines if the branch should be only created in the origin

  --main
    The production branch

  --staging, -s
    Demo branch and decisions about release features

  --test, -t
    Contains all codes ready for QA testing

  --dev, -d
    All new features and bug fixes; codes conflicts should be done here

  --feature, -f DESCRIPTION
    Any code changes for a new module or use case; should be created based on
    the current development branch

  --bugfix, -b DESCRIPTION
    If the code changes made from the feature branch were rejected after a
    release, sprint or demo

  --hotfix, -H DESCRIPTION
    If there is a need to fix something that should be handled immediately;
    could be merged directly to the production branch

  --experimental, -e DESCRIPTION
    Any new feature or idea that is not part of a release or a sprint; a branch
    for playing around

  --build, -u DESCRIPTION
    A branch specifically for creating specific build artifacts or for doing
    code coverage runs

  --release, -r DESCRIPTION
    A branch for tagging a specific release version

  --merge, -m DESCRIPTION
    Resolving merge conflicts, usually between the latest development and a
    feature or hotfix branch; also to merge two branches of one feature

  --help, -h
    Show this help

Arguments:
  DESCRIPTION
    The description is a brief explanation about the branch purpose

Examples:
  [Command]
  - sgit take -f "my really awesome feature" -o
  [Result]
  - git checkout -b "feature/my-really-awesome-feature"
  - git push origin "feature/my-really-awesome-feature"
```

## Contributing / Support

If you experience any issue, have a question or a suggestion, or if you wish to contribute, feel free to [open an issue](issues).

## References

This project was a compilation of ideas and standards already established. Credit remains for each article or project.

https://www.conventionalcommits.org/en/v1.0.0/

https://dev.to/couchcamote/git-branching-name-convention-cch

https://dev.to/i5han3/git-commit-message-convention-that-you-can-follow-1709

https://github.com/fteem/git-semantic-commits
