---
name: "log:task"
description: "Log a task to the current repository's backlog"
---

Log a task to the current repository's backlog.

## Arguments
The full text after the command is the task description: `$ARGUMENTS`

## Instructions

Run the following steps using bash commands:

### 1. Validate environment

```bash
git rev-parse --show-toplevel 2>/dev/null
```

If this fails (exit code non-zero), stop and tell the user: "Not inside a git repository. Navigate to a repo first."

### 2. Detect paths

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$REPO_ROOT")

# Walk up to find .logproject
DIR="$REPO_ROOT"
PROJECT_ROOT=""
while [ "$DIR" != "/" ]; do
  if [ -f "$DIR/.logproject" ]; then
    PROJECT_ROOT="$DIR"
    break
  fi
  DIR=$(dirname "$DIR")
done
```

If `PROJECT_ROOT` is empty, stop and tell the user: "No .logproject found. Run /log:init in your project root first."

### 3. Get next ID

```bash
NEXT_ID_FILE="$HOME/.claude/log/next-id"
mkdir -p "$HOME/.claude/log"
if [ ! -f "$NEXT_ID_FILE" ]; then echo "1" > "$NEXT_ID_FILE"; fi
ID=$(cat "$NEXT_ID_FILE")
echo $((ID + 1)) > "$NEXT_ID_FILE"
```

### 4. Build the entry

```bash
DATE=$(date +%Y-%m-%d)
BRANCH=$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
DESCRIPTION="$ARGUMENTS"
ENTRY="- [ ] #${ID} [task] ${DATE} · branch:${BRANCH} — ${DESCRIPTION}"
```

### 5. Write to BACKLOG.md

```bash
BACKLOG="$REPO_ROOT/BACKLOG.md"
```

If `BACKLOG.md` does not exist, create it with this exact content:
```
# Backlog — <REPO_NAME>

## Open

## Done
```

Then append the entry on a new line under `## Open`, before `## Done`.

### 6. Confirm

Tell the user: "Logged #<ID> [task]: <DESCRIPTION>"
