#!/usr/bin/env bash
# log-next-id.sh — read the current global ID counter, print it, then increment.
# Initialises ~/.claude/log/next-id to 1 if the file does not exist.

NEXT_ID_FILE="$HOME/.claude/log/next-id"
mkdir -p "$HOME/.claude/log"

if [ ! -f "$NEXT_ID_FILE" ]; then
  echo "1" > "$NEXT_ID_FILE"
fi

ID=$(cat "$NEXT_ID_FILE")
echo "$ID"
echo $((ID + 1)) > "$NEXT_ID_FILE"
