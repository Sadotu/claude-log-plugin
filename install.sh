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

# Copy helper scripts and ensure they are executable
SCRIPTS_SRC="$COMMANDS_SRC/scripts"
SCRIPTS_DST="$COMMANDS_DST/scripts"
mkdir -p "$SCRIPTS_DST"
cp "$SCRIPTS_SRC"/*.sh "$SCRIPTS_DST/"
chmod +x "$SCRIPTS_DST"/*.sh
echo "  ✓ Helper scripts installed to $SCRIPTS_DST"

# Patch settings.json: add allow rule for helper scripts (idempotent)
SETTINGS="$HOME/.claude/settings.json"
ALLOW_RULE="Bash(~/.claude/commands/log/scripts/*)"
if ! command -v jq &>/dev/null; then
  echo ""
  echo "  ⚠ jq not found. Add the following rule to ~/.claude/settings.json manually:"
  echo "    under permissions.allow, add: \"$ALLOW_RULE\""
elif [ ! -f "$SETTINGS" ]; then
  echo "  ⚠ $SETTINGS not found. Add the following rule manually:"
  echo "    under permissions.allow, add: \"$ALLOW_RULE\""
else
  if jq -e --arg rule "$ALLOW_RULE" '.permissions.allow // [] | index($rule) != null' "$SETTINGS" &>/dev/null; then
    echo "  ✓ Allow rule already present in settings.json"
  else
    jq --arg rule "$ALLOW_RULE" '.permissions.allow += [$rule]' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
    echo "  ✓ Allow rule added to settings.json: $ALLOW_RULE"
  fi
fi

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
