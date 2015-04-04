Though it is possible to add aliases directly to git, I prefer to add aliases to
bash to save a few characters on my most frequently used git commands.

## Basics

### gcl: **g**it **cl**one

Though this is one of my newer aliases, I think it's a worthwhile alias to have,
even if you don't use it everyday.

```bash
alias gcl='git clone'
```

### gget and gput: **g**it pull (**get**) and push (**put**)

Since *push* and *pull* have a lot of character overlap, and neither offer clear
4-letter aliases, I've instead used verb descriptors for both. The chosen verbs
are short and correlate to similar HTTP request verbs.

```bash
alias gget='git pull'
alias gput='git push'
```

### gs: **g**it **s**tatus

Since this command is always at the top of my most used commands list, I may be
guilty of over using it. That said, when navigating between repos or staging
changes for a commit, **git status** is enormously useful for getting a handle
on the present state of a git repository.

```bash
alias gs='git status'
```

### gsh: **g**it **sh**ow

Useful for looking at the previous commit in the tree. Particularly handy when
applying amendments or rebasing interactively.

```bash
alias gsh='git show'
```

### gshn: **g**it **sh**ow HEAD@{**n**}

Useful when you want to view the nth previous commit, but prefer not to do a
full **git log -p**.

```bash
function gshn() {
  ([ -z "$1" ] || [ $(($1)) -le 0 ]) && echo 'Invalid integer!' && return
  git show $(echo "HEAD@{$1}")
}
```

## Branch shenanigans

### gbr: **g**it **br**anch

Your most basic **git branch** command. Returns a list of local branches when
no arguments are given. Otherwise, passes arguments along to **git branch**.

```bash
alias gbr='git branch'
```

### gbrc: **g**it **br**anch **c**urrent

Utility function for retrieving the name of the current branch. Useful with
other commands when invoked from a sub-shell.

```bash
alias gbrc='git rev-parse --abbrev-ref HEAD'
```

### gbrp: **g**it **br**anch **p**revious

Utility function for retrieving the name of the previous branch that was checked
out. Useful with other commands when invoked from a sub-shell.

```bash
alias gbrp='git reflog | sed -n "s/.*checkout: moving from .* to \(.*\)/\1/p" | sed "2q;d"'
```

### gbrb: **g**it **br**anch **b**ack

Utility function for returning to the previous branch that was checked out. *Be
right back* also a helpful mnemonic.

```bash
# Return to previous branch
function gbrb() {
  br="$(git reflog | sed -n 's/.*checkout: moving from .* to \(.*\)/\1/p' | sed "2q;d")"
  git checkout $br
}
```

### gbrr: **g**it **br**anch **r**ecent

This function is useful for situations in which you want to return to a branch
you recently checked out, but don't remember the name of the branch. Running
this command will list the last 10 branches that were checked out for the
current repo and prompt you to select which of those branches to checkout.

```bash
GBRR_DEFAULT_COUNT=10
function gbrr() {
  COUNT=${1-$GBRR_DEFAULT_COUNT}

  IFS=$'\r\n' BRANCHES=($(
    git reflog | \
    sed -n 's/.*checkout: moving from .* to \(.*\)/\1/p' | \
    perl -ne 'print unless $a{$_}++' | \
    head -n $COUNT
  ))

  for ((i = 0; i < ${#BRANCHES[@]}; i++)); do
    echo "$i) ${BRANCHES[$i]}"
  done

  read -p "Switch to which branch? "
  if [[ $REPLY != "" ]] && [[ ${BRANCHES[$REPLY]} != "" ]]; then
    echo
    git checkout ${BRANCHES[$REPLY]}
  else
    echo Aborted.
  fi
}
```

## Stash shortcuts

### gss: **g**it **s**tash **s**ave

Stashes changes to the HEAD with the given message. I find adding a message to
stashed items much more useful than the information that is used by default if
you don't provide a message.

**Alias:**

```bash
alias gss='git stash save'
```

**Example:**

```bash
$ gss "Minor refactoring of user model"
Saved working directory and index state On master: Minor refactoring of user model
HEAD is now at 62758b7 Add tests for user model
```

### gsa: **g**it **s**tash **a**pply

Short-hand for the **git stash apply** command. Without additional arguments,
applies the stashed state at the top of the stash to the working tree without
removing the applied state. Can also be used with **stash@{n}** to reference a
particular item in the stash.

**Alias:**

```bash
alias gsa='git stash apply'
```

**Example:**

```bash
$ gsa stash@{1}
On branch master
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

        new file:   stashed_file
```

### gsl: **g**it **s**tash **l**ist

Lists all items in the local stash.

**Alias:**

```bash
alias gsl='git stash list'
```

**Example:**

```bash
$ gsl
stash@{0}: WIP on master: 21e072b Ignore generated src.html in project root
stash@{1}: On master: e80ea55 Run test suite in parallel
```

### gsp: **g**it **s**tash **p**op

Without additional arguments it removes the stashed state from the top of the
stash stack and apples it to the working tree. Can also be used with
**stash@{n}** to reference a particular item in the stash.

```bash
alias gsp='git stash pop'
```



### gssh: **g**it **s**tash **sh**ow
```bash
alias gssh='git stash show -p'
```

### gst: **g**it **st**ash

```bash
alias gst='git stash'
```

### gstd: **g**it **st**ash **d**rop
```bash
alias gstd='git stash drop'
```

## Grep go-tos

### gg: **g**it **g**rep

```bash
alias gg='git grep'
```

### ggi: **g**it **g**rep case-**i**nsensitive

```bash
alias ggi='git grep -i'
```

### ggno: **g**it **g**rep **n**ame **o**nly

```bash
alias ggno='git grep --name-only'
```

### ggo: **g**it **g**rep **o**pen

```bash
function ggo() {
  $EDITOR $(git grep --name-only "$@")
}
```

### ggio: **g**it **g**rep case-**i**nsensitive **o**pen

```bash
function ggio() {
  $EDITOR $(git grep -i --name-only "$@")
}
```

## Rebase basics

### grb: **g**it **r**e**b**ase

```bash
alias grb='git rebase'
```

### grba: **g**it **r**e**b**ase **a**bort

```bash
alias grba='git rebase --abort'
```

### grbc: **g**it **r**e**b**ase **c**ontinue

```bash
alias grbc='git rebase --continue'
```

### grbi: **g**it **r**e**b**ase **i**nteractive

```bash
alias grbi='git rebase --interactive'
```

### grbs: **g**it **r**e**b**ase **s**kip

```bash
alias grbs='git rebase --skip'
```

### grbp: **g**it **r**e**b**ase from **p**revious branch

```bash
# Rebase from previous branch
function grbp() {
  br="$(git reflog | sed -n 's/.*checkout: moving from .* to \(.*\)/\1/p' | sed "2q;d")"
  git rebase $br
}
```

## Commitments are often amended after merging or cherry-picking

### gcm: **g**it **c**ommit with **m**essage

```bash
alias gcm='git commit -m'
```

### gcam: **g**it **c**ommit **a**ll with **m**essage

```bash
alias gcam='git commit -a -m'
```

### gcp: **g**it **c**herry-**p**ick

```bash
alias gcp='git cherry-pick'
```

### gamd: **g**it **a**mend commit without editing message

```bash
alias gamd='git commit --amend --no-edit'
```

### gamend: **g**it **amend** commit and edit message

```bash
alias gamend='git commit --amend'
```

### gmm: **g**it **m**erge

```bash
alias gm='git merge'
```

### gmm: **g**it **m**erge **m**aster

```bash
alias gmm='git merge master'
```

### gmp: **g**it **m**erge **p**revious branch

```bash
function gmp() {
  br="$(git reflog | sed -n 's/.*checkout: moving from .* to \(.*\)/\1/p' | sed "2q;d")"
  git merge $br
}
```

## Branch buddies

### gputu: **g**it push (**put**) and set **u**pstream

Knowing this command is a wrapper around **git push -u** may help clarify where
the alias comes from: it is a **gput** with the **-u** or **--set-upstream**
option.

```bash
# Push to origin remote setting upstream branch appropriately
function gputu() {
  if [ -z $1 ]; then
    br="$(git rev-parse --abbrev-ref HEAD)"
  else
    br="$1"
  fi
  git push -u origin $br
}
```

## Add-itions

### ga: **g**it **a**dd

```bash
alias ga='git add'
```

### gaa: **g**it **a**dd **a**ll

```bash
alias gaa='git add -A'
```

### gap: **g**it **a**dd **p**atch

```bash
alias gap='git add -p'
```

### gau: **g**it **a**dd **u**pdate

```bash
alias gau='git add -u'
```

## Reset reliables

### gback: soft reset last commit

```bash
alias gback='git reset HEAD~ --soft'
```

### gback: hard reset last commit

```bash
alias gbackk='git reset HEAD~ --hard'
```

### grh: **g**it **r**eset **h**ead

```bash
alias grh='git reset HEAD'
```

## Checkout

### gco: **g**it **c**heck **o**ut

```bash
alias gco='git checkout'
```

### gcoa: **g**it **c**heck**o**ut **a**ll

```bash
alias gcoa='git checkout .'
```

### gcob: **g**it **c**heck**o**ut **b**ranch

```bash
alias gcob='git checkout -b'
```

## Log

### gl: **g**it **l**og

```bash
alias gl='git log'
```

### glp: **g**it **l**og with **p**atches

```bash
alias glp='git log -p'
```

### gls: **g**it **ls**: **g**it **l**og **s**imple

```bash
alias gls='git log --oneline'
```

### glv: **g**it **l**og **v**isual

```bash
alias glv='git log --oneline --graph'
```

## Diff

### gd: **g**it **d**iff

```bash
alias gd='git diff'
```

### gds: **g**it **d**iff **s**taged

```bash
alias gds='git diff --staged'
```

## Tag team

### gtaga: **g**it **tag** **a**dd

```bash
function gtaga() {
  [ -z "$1" ] && echo 'Invalid tag name!' && return
  [ -z "$2" ] && msg="$1" || msg="$2"
  git tag -a $1 -m $msg
}
```

### gtagdr: **g**it **tag** **d**elete **r**emote

```bash
function gtagdr() {
  [ -z "$1" ] && echo 'Invalid tag name!' && return
  git push origin :refs/tags/$1
}
```

### gtagd: **g**it **tag** **d**elete

```bash
alias gtagd="git tag -d"
```

### gtagd: **g**it **tag** **l**ist

```bash
alias gtagl="git tag -l"
```

## Miscellanea

### gcopr: **g**it **c**heck**o**ut **p**ull **r**equest

It's usually better to pull down a copy of the branch that the PR is based on,
but sometimes it can be useful to grab a snapshot of a pull request in its
current state.

```bash
# Checkout pull request ref by PR id
function gcopr() {
  ([ -z "$1" ] || [ $(($1)) -le 0 ]) && echo 'Invalid pull request ID' && return
  pr_id=$1
  [ -z "$2" ] && br_name="pull_request_${1}" || br_name="$2"
  git fetch origin pull/${pr_id}/head:${br_name}
  git checkout ${br_name}
}
```

## Bonus #1: up: cd to root of git repo, home dir, then root

This shortcut is the creation of my former co-worker, Nicholas Ellis.

```bash
alias up='[ $(git rev-parse --show-toplevel 2>/dev/null || echo ~) = $(pwd) ] && cd $([ $(echo ~) = $(pwd) ] && echo / || echo) || cd $(git rev-parse --show-toplevel 2>/dev/null)'
```

## Bonus #2: Add bash completion to aliases!

Though the semantics vary depending on the version of git you use, recent
versions of git come with bash completion functions that allow you to configure
arbitrary commands to use git flavored bash completion.

```bash
# Bash completion
__git_complete ga _git_add
__git_complete gap _git_add
__git_complete gau _git_add
__git_complete gback _git_reset
__git_complete gbr _git_branch
__git_complete gco _git_checkout
__git_complete gcp _git_cherry_pick
__git_complete gd _git_diff
__git_complete gg _git_grep
__git_complete ggi _git_grep
__git_complete ggno _git_grep
__git_complete gget _git_pull
__git_complete gl _git_log
__git_complete glv _git_log
__git_complete glp _git_log
__git_complete gput _git_push
__git_complete grb _git_rebase
__git_complete gs _git_status
__git_complete gsh _git_show
__git_complete gst _git_stash
__git_complete gundo _git_reset
```

## Bonus #3: topcmds: **top** **co**m**man**ds**

This command is credit [Ben Orenstein](https://twitter.com/r00k)
The command scans your bash history and generates a list of your most frequently
used 1-2 word commands. The items high on this list are good candidates for
aliasing.

```bash
function topcmds() {
  [ ! -z $1 ] && n="$1" || n="10"
  history | awk '{a[$2 " " $3]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head -n $n
}
```

[Ben Orenstien @ GoGaRuCo 2013](https://youtu.be/8ZMOWypU34k?t=807)

## Going further

If you're git itch still hasn't been satisfied, check out pretty blog post or
talk by [Nicola Paolucci](https://twitter.com/durdn). He's a bona fide git
master with lots of aliases, tools, and tips for achieving a more streamlined
workflow with git.

[One weird trick for powerful Git aliases](http://blogs.atlassian.com/2014/10/advanced-git-aliases/)
[More Blog posts by Nicola Paolucci](http://blogs.atlassian.com/author/npaolucci/)
[Nicola Paolucci - Becoming a Git Master - Atlassian Summit 2014](https://www.youtube.com/watch?v=-kVzV6m5_Qg)

Thanks for reading!
