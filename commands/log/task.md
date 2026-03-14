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
```

Run the project root helper and capture its stdout as `PROJECT_ROOT`:
```bash
~/.claude/commands/log/scripts/log-find-root.sh
```

If the script exits non-zero, stop and tell the user the error message it printed to stderr.

### 3. Get next ID

Run the ID counter helper and capture its stdout as `ID`:
```bash
~/.claude/commands/log/scripts/log-next-id.sh
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
