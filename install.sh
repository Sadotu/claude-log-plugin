#!/usr/bin/env bash
set -e

COMMANDS_SRC="$(cd "$(dirname "$0")/commands/log" && pwd)"
COMMANDS_DST="$HOME/.claude/commands/log"
LOG_DIR="$HOME/.claude/log"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
SESSION_MARKER="# claude-log-plugin: session-start"
SESSION_INSTRUCTION='## Backlog Session Start (claude-log-plugin)
At the start of each new session, if a file named `BACKLOG.md` exists in the current working directory and contains open items (lines matching `- \[ \]`), display them as a brief numbered list before anything else. Do not show this if there are no open items or no BACKLOG.md.'

echo "Installing claude-log-plugin..."

# Remove old skills-based install if present
if ls "$HOME/.claude/skills/log:"*.md 2>/dev/null | grep -q .; then
  rm "$HOME/.claude/skills/log:"*.md
  echo "  ✓ Removed old skill files from ~/.claude/skills/"
fi

# Copy commands
mkdir -p "$COMMANDS_DST"
cp "$COMMANDS_SRC"/*.md "$COMMANDS_DST/"
echo "  ✓ Commands copied to $COMMANDS_DST"

# Create log directory and next-id if absent
mkdir -p "$LOG_DIR"
if [ ! -f "$LOG_DIR/next-id" ]; then
  echo "1" > "$LOG_DIR/next-id"
  echo "  ✓ Created $LOG_DIR/next-id"
else
  echo "  ✓ $LOG_DIR/next-id already exists"
fi

# Idempotently append session-start instruction to CLAUDE.md
mkdir -p "$(dirname "$CLAUDE_MD")"
touch "$CLAUDE_MD"
if grep -qF "$SESSION_MARKER" "$CLAUDE_MD"; then
  echo "  ✓ Session-start instruction already present in CLAUDE.md"
else
  printf "\n%s\n%s\n" "$SESSION_MARKER" "$SESSION_INSTRUCTION" >> "$CLAUDE_MD"
  echo "  ✓ Session-start instruction added to CLAUDE.md"
fi

echo ""
echo "claude-log-plugin installed successfully."
echo "Run /log:init in each project root to get started."
