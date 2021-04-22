# Sugar Git

<img src="https://user-images.githubusercontent.com/3791148/115315966-cafc8580-a14e-11eb-910d-452851ad87af.png" alt="Sugar Git" height="160" />
Syntactic sugar for git, respecting semantics and modern conventions.

## 1. Installation

### \# Quick install

Paste this line in your terminal and be happy!

`git clone https://github.com/mkuchak/sugar-git ~/.sugar-git && ~/.sugar-git/./install.sh && source ~/.zshrc && source ~/.bashrc`

### \# Detailed installation


1. Clone this repo, preferably in your $HOME directory.

   `git clone https://github.com/mkuchak/sugar-git ~/.sugar-git`

     Tip: If you're using Cygwin, open it and type 'echo $USERPROFILE'. This will show you the location of the $HOME directory.

2. Install it as a set of bash scripts:

   `cd ~/.sugar-git && ./install.sh`

     Tip: Installation script is idempotent and could be harmlessly executed multiple times. It adds bash scripts to the PATH in your `~/.bashrc` or `~/.zshrc` files (without any duplication).

3. Commit away!

### \# Edit your default git editor

```
git config --global core.editor "code --wait"
git config --global core.editor "nano --wait"
git config --global core.editor "vim --wait"
```

## 2. Sugar Management

### \# Git Manager

| Command [optional] \<required>                               | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| git ls [-r \| -l]                                            | List all branches, only remote or only local                 |
| git mkdir [-o \| --origin] \<new_branch>                     | Create new branch                                            |
| git cd \<branch>                                             | Change the current working branch                            |
| git mv [-ns \| --no-sugar] \<old_branch> \<new_branch>       | Rename some branch                                           |
| git rm [-o \| --origin] [-ns \| --no-sugar] \<branch>        | Remove some branch                                           |
| git wipe [-y \| --yes] [\<branch>]                           | Wipe the working branch as per the remote branch             |
| git rollback [\<commit_id>]                                  | Back the commit history, but it preserves the file contents  |
| git edit [\<commit_id>]                                      | Edit the most recent commit message                          |
| git get [-f \| --force] [\<branch>]                          | Fetch and merge changes from remote branch to working branch |
| git put [-f \| --force] [\<branch>]                          | Send committed changes from working branch to the respective remote branch |
| git log [ -a \| --author ] [ -s \| --since ] [ -u \| --until ] [-e \| --exclude] [-ns \| --no-sugar] [ "\<search_terms>" ] | Search in the history of commit by applying some filters     |

To use original command add `-ns` argument (no sugar), as example `git rm -ns Documentation/\*.txt`.

Only `mv`, `rm`, `log` and `merge` could be used with `--no-sugar` argument, no other commands are overlaid.

Examples:

* **git mkdir feature/hello-world**: this command will creates the "feature/hello-world" branch from current branch **(use semantic branches commands instead!!!)**
* **git mv feature/hello-world feature/goodbye-cruel-world**: renames your newly created branch
* **git cd feature/hello-world && git rm**: throws you to "main" branch and deletes "feature/hello-world" branch
* **git rm feature/hello-world**: just deletes "feature/hello-world" branch
* **git rb**: rollback the last commit; so simple, now you can rewrite it without pain! :D
* **git rollback 135889d**: rollback to determined history commited id point
* **git cd feature/hello-world && git put**: sends your last commits to the remote branch (if not exists, creates the remote branch)
* **git get feature/hello-world**: updates the local branch commits as per the remote repository (if not exists, creates the local branch)

## 3. Semantic Branches

All commands create the branches from the current branch you are in.

### \# Fixed Branches

| Command     | Description                                                         |
| ----------- | ------------------------------------------------------------------- |
| git main    | The production branch                                               |
| git staging | Demo branch and decisions about release features                    |
| git testing | Contains all codes ready for QA testing                             |
| git dev     | All new features and bug fixes; codes conflicts should be done here |

### \# Temporary Branches

| Command [optional]          | Description                                                                                                                                 |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| git feature ["\<msg>"]      | Any code changes for a new module or use case; created based on the current development branch                                              |
| git bugfix ["\<msg>"]       | If the code changes made from the feature branch were rejected after a release, sprint or demo                                              |
| git hotfix ["\<msg>"]       | If there is a need to fix something that should be handled immediately; could be merged directly to the production branch                   |
| git experimental ["\<msg>"] | Any new feature or idea that is not part of a release or a sprint; a branch for playing around                                              |
| git build ["\<msg>"]        | A branch specifically for creating specific build artifacts or for doing code coverage runs                                                 |
| git release ["\<msg>"]      | A branch for tagging a specific release version                                                                                             |
| git merge ["\<msg>"]        | Resolving merge conflicts, usually between the latest development and a feature or hotfix branch; also to merge two branches of one feature |

All Semantic Branches commands have the `--origin` argument, as does ` git mkdir`. The `-o` command allows to create a branch locally and in the remote repository.

To use original command (like `git merge`) add `-ns` argument (no sugar), as this silly history example:

```bash 
# create some feature
git cd dev
git feature "awesome button" # create new branch from dev branch
# this command will already throw you into this branch (is not really necessary "git cd")

# so you do some code, commit and put
git cd feature/awesome-button
git feat "add awesome button" # feat: add awesome button
git put

# after, you makes pull request, but... the button has some bug
git cd feature/awesome-button
git bugfix "button behavior"

# then, you fix the code, commit and put
git cd bugfix/button-behavior
git fix "update bad button behavior" # fix: update bad button behavior
git put

# now we start to play
git cd feature/awesome-button
git merge "awesome button"

# and legit merge using -ns
git cd merge/awesome-button
git merge -ns merge/awesome-button bugfix/button-behavior
git put
```

Examples:

* **git dev**: dev (fixed branch)
* **git feature "integrate swagger"**: feature/integrate-swagger
* **git feature "JIRA 1234"**: feature/JIRA-1234
* **git feature "JIRA 1234_support dark theme"**: feature/JIRA-1234_support-dark-theme
* **git bugfix "more gray shades"**: bugfix/more-gray-shades
* **git bugfix "JIRA 1444_gray on blur fix"**: bugfix/JIRA-1444_gray-on-blur-fix
* **git hotfix "disable endpoint zero day exploit"**: hotfix/disable-endpoint-zero-day-exploit
* **git hotfix "increase scaling threshold"**: hotfix/increase-scaling-threshold
* **git experimental "dark theme support"**: experimental/dark-theme-support
* **git build "jacoco metric"**: build/jacoco-metric
* **git release "myapp 1.01.123"**: release/myapp-1.01.123
* **git merge "dev_lombok refactoring"**: merge/dev_lombok-refactoring
* **git merge "combined device support"**: merge/combined-device-support

## 4. Git Manage Commits

### \# Semantic Commits

| Command [optional]      | Description                                                                                                     |
| ----------------------- | --------------------------------------------------------------------------------------------------------------- |
| git feat ["\<msg>"]     | A new feature                                                                                                   |
| git fix ["\<msg>"]      | A bug fix                                                                                                       |
| git chore ["\<msg>"]    | A code change that external **user won't see** (eg: change to .gitignore file or .prettierrc file)              |
| git style ["\<msg>"]    | Changes that do **not affect the meaning of the code** (white-space, formatting, missing semi-colons, etc)      |
| git docs ["\<msg>"]     | Documentation only changes                                                                                      |
| git refactor ["\<msg>"] | A code change that neither fixes a bug nor adds a feature; refactoring production code, eg. renaming a variable |
| git perf ["\<msg>"]     | A code change that improves performance                                                                         |
| git revert ["\<msg>"]   | Reverts a previous commit                                                                                       |
| git localize ["\<msg>"] | A translations update                                                                                           |
| git build ["\<msg>"]    | Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)             |
| git test ["\<msg>"]     | Adding missing tests or correcting existing tests                                                               |
| git ci ["\<msg>"]       | Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)     |

If you would like to add an **optional scope**, as described [here](https://conventionalcommits.org/), use the `-s` flag and quote the scope message:

* `git docs -s "scope here" "commit message here"` -> `git commit -m 'docs(scope here): commit message here'`

To add all files without type `git add .` can be used the flag `-a`, and the flag `-p` to automatic commit to origin repo (use `-ap` or `-pa` to to combine flags):

* `git feat "commit msg" -ap` -> `git add . && git commit -am 'feat: commit msg' && git push origin <current_branch>`
* `git fix -a -s "middleware" "add new auth flow"` -> `git add . && git commit -am 'fix(middleware): add new auth flow'`

In case you would still like to use your **text editor** for your commit messages you can omit the message, and do your commit message in your editor.

* `git feat` -> `git commit -m 'feat: ' -e`

Examples:

* **git feat "add beta sequence"**: feat: add beta sequence
* **git fix -s "release" "need to depend on latest rxjs and zone.js"**: fix(release): need to depend on latest rxjs and zone.js
* **git fix "remove broken confirmation message"**: fix: remove broken confirmation message
* **git chore "add Oyster build script"**: chore: add Oyster build script
* **git style "convert tabs to spaces"**: style: convert tabs to spaces
* **git style "add missing semicolons"**: style: add missing semicolons
* **git docs "explain hat wobble"**: docs: explain hat wobble
* **git docs -s "changelog" "update changelog to beta.5"**: docs(changelog): update changelog to beta.5
* **git rf "share logic between 4d3d3d3 and flarhgunnstow"**: refactor: share logic between 4d3d3d3 and flarhgunnstow
* **git test "ensure Tayne retains clothing"**: test: ensure Tayne retains clothing

##  5. The reasons for these conventions

* Automatic generating of the changelog
* Simple navigation through git history (e.g. ignoring style changes)

## 6. Format of the commit message

```bash
<type>(<scope>): <subject>

<body>

<footer>
```

## 7. Explanation

**"type" is required and must be one of the semantic command**

**"scope" is optional**

* Scope must be noun and it represents the section of the section of the codebase
* [Refer this link for example related to scope](http://karma-runner.github.io/1.0/dev/git-commit-msg.html)
* E.g.: init, runner, watcher, config, web-server, proxy

**"subject" is required**

* Use imperative, present tense (eg: use "add" instead of "added" or "adds")
* Don't use dot (.) at end
* Don't capitalize first letter

**"body" is optional**

* Uses the imperative, present tense: “change” not “changed” nor “changes”
* Includes motivation for the change and contrasts with previous behavior

For more info about message body, see:
* http://365git.tumblr.com/post/3308646748/writing-git-commit-messages
* http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html

**"footer" is optional**

* Referencing issues:
Closed issues should be listed on a separate line in the footer prefixed with "Closes" keyword like this:

```bash
Closes #234
```
or in the case of multiple issues:

```bash
Closes #123, #245, #992
```

* Breaking changes:
All breaking changes have to be mentioned in footer with the description of the change, justification and migration notes.

```bash
BREAKING CHANGE:

`port-runner` command line option has changed to `runner-port`, so that it is
consistent with the configuration file syntax.

To migrate your project, change all the commands, where you use `--port-runner`
to `--runner-port`.
```

## 8. Example commit message

```bash
fix(middleware): ensure Range headers adhere more closely to RFC 2616

Add one new dependency, use `range-parser` (Express dependency) to compute
range. It is more well-tested in the wild.

Fixes #2310
```

## 9. How to contribute

This project was created to help follow the best standards and conventions for using git in a simple and effective way.

I don't master shell script and I had to write these help commands quickly, so much of the shell code SHOULD really be refactored. Feel free to help with this.

Open a pull request/issue or fork this repo and submit your changes via a pull request.

## 10. References

This project was a compilation of ideas and standards already established. Credit remains for each article or project.

https://dev.to/couchcamote/git-branching-name-convention-cch

https://dev.to/i5han3/git-commit-message-convention-that-you-can-follow-1709

https://github.com/fteem/git-semantic-commits
