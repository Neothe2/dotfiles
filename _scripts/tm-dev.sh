#!/bin/bash

# Name your session here so you can re-attach to it easily later
SESSION="dev-env"

# Check if the session already exists so we don't accidentally overwrite it
tmux has-session -t "$SESSION" 2>/dev/null

if [ $? != 0 ]; then
  # 1. Create a new session in the background (-d) and name the first window (-n)
  tmux new-session -d -s "$SESSION" -n "BKND"

  # 2. Create the second window
  tmux new-window -t "$SESSION" -n "b-run"

  # 3. Create the third window
  tmux new-window -t "$SESSION" -n "FTND"

  # 4. Create the fourth window
  tmux new-window -t "$SESSION" -n "f-run"

  # (Optional) Switch back to the first window (BKND) before attaching
  tmux select-window -t "$SESSION:0"
fi

# Attach to the session and bring it to the foreground
tmux attach-session -t "$SESSION"
