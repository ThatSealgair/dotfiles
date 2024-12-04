#! /bin/bash

# Error Message, Suggested Fix
function script_error {
  echo "[ERROR] $1"
  echo "$2"
}

function script_status {
  echo "[$1/$2] - $3..."
}

function script_complete {
  echo "[SUCCESS] $1"
}

# Remove untracked changes
git-clean() {
  git clean -fd
}

# Show the diff of staged changes
git-diff() {
  git diff --cached
}

git-s() {
  git status
}

git-sv() {
  git status -uall
}

# Show last commit details
git-lc() {
  git log -1 --oneline
}

# Show commit history in readable format
git-history() {
  git log --graph --oneline --decorate --color
}

# Git conflict list
git-cl() {
  git diff --name-only --diff-filter=U
}

# Git conflict diff
git-cd() {
  for file in $(git-cl); do
    echo "[CONFLICT] $file"
    git diff "$file"
  done
}

# Git conflict summary
git-cs() {
  for file in $(git-cl); do
    count=$(grep -o '<<<<<<<' "$file" | wc -l)
    echo "$file: $count conflict(s)"
  done
  script_success "Conflict summary complete."
}

# In merge conflict favour main
git-ct() {
  git checkout --theirs $1
  git add $1
}

# In merge conflict favour local file
git-co() {
  git checkout --ours $1
  git add $1
}

# Rebase with main
git-rwm() {
  local current_branch
  current_branch=$(git branch --show-current)

  if [[ -z "$current_branch" ]] then
    script_error "Error: Could not determine current branch." "Are you in a Git repository?"
    return 1
  fi

  if [[ -n $(git status --porcelain) ]]; then
    script_error "Uncommitted changes." "Please stash or commit them before rebasing."
    return 1
  fi

  script_status "1" "2" "Fetching changes from 'main'"

  git fetch origin

  script_status "2" "2" "Pulling latest changes from 'main' to '$current_branch'"

  git rebase origin/main

  if [[ $? -ne 0 ]] then
    script_error "Rebase failed." "Resolve conflicts and run 'git rebase --continue'."
    return 1
  fi

  script_success "'$current_branch' is now up tp date with 'main'."
}

git-rc() {
  git rebase --continue
}

git-undo() {
  if [[ -z $(git rev-parse--is-inside-work-tree 2>/dev/null) ]] then
    script_error "Not in a Git repository." "Check directory"
    return 1
  fi

  echo "Undoing last commit..."

  git reset --soft HEAD-1

  if [[ $? -ne 0 ]] then
    script_error "Failed to undo the last commit" "Re-try or panic"
    return 1
  fi

  script_success "Last commit undone."
}
