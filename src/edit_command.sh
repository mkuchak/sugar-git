if [[ -z "${args[commit_id]}" ]]; then
  # No commit_id: amend the last commit message
  if [[ -n "${args[message]}" ]]; then
    git commit --amend -m "${args[message]}"
  else
    git commit --amend
  fi
else
  # Find the commit position in history
  FULL_HASH=$(git rev-parse "${args[commit_id]}" 2>/dev/null)

  if [[ -z "$FULL_HASH" ]]; then
    echo "Error: Commit ID \"${args[commit_id]}\" not found."
    exit 1
  fi

  SHORT_HASH=$(git rev-parse --short "$FULL_HASH")
  HEAD_COMMIT=$(git rev-list HEAD | nl | grep "$FULL_HASH")
  read HEAD_ID _ <<<"$HEAD_COMMIT"

  if [[ -z "$HEAD_ID" ]]; then
    echo "Error: Commit \"${args[commit_id]}\" not found in current branch history."
    exit 1
  fi

  if [[ -n "${args[message]}" ]]; then
    # Fully automated: reword commit with new message, no editor opens
    EDITOR_SCRIPT=$(mktemp)
    printf '#!/bin/sh\nprintf "%%s\\n" "%s" > "$1"\n' "${args[message]}" > "$EDITOR_SCRIPT"
    chmod +x "$EDITOR_SCRIPT"

    GIT_SEQUENCE_EDITOR="sed -i.bak 's/^pick $SHORT_HASH/reword $SHORT_HASH/' \"\$1\" && rm -f \"\$1.bak\"" \
    GIT_EDITOR="$EDITOR_SCRIPT" \
      git rebase -i HEAD~$HEAD_ID

    RESULT=$?
    rm -f "$EDITOR_SCRIPT"

    if [[ $RESULT -ne 0 ]]; then
      echo ""
      echo "Rebase failed. Run 'git rebase --abort' to undo."
      exit 1
    fi
  else
    # Semi-automated: auto pick->reword, open editor for message
    GIT_SEQUENCE_EDITOR="sed -i.bak 's/^pick $SHORT_HASH/reword $SHORT_HASH/' \"\$1\" && rm -f \"\$1.bak\"" \
      git rebase -i HEAD~$HEAD_ID
  fi

  echo ""
  echo "To publish, run \"sgit put --force\"."
  echo "This is NOT RECOMMENDED if commits have already been pushed and other collaborators are active."
fi
