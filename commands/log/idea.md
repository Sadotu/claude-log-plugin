---
name: "log:idea"
description: "Log an idea to a repository's backlog (supports cross-repo targeting)"
---

Log an idea to a repository's backlog. Supports cross-repo targeting with a `<folder>:` prefix.

## Arguments
The full text after the command: `$ARGUMENTS`

Examples:
- `/log:idea Add dark mode toggle` — logs to current repo
- `/log:idea uboulder-web: Add dark mode toggle` — logs to sibling repo `uboulder-web`

## Instructions

Run the following steps using bash commands:

### 1. Validate environment

```bash
git rev-parse --show-toplevel 2>/dev/null
```

If this fails (exit code non-zero), stop and tell the user: "Not inside a git repository. Navigate to a repo first."

### 2. Detect current repo and project root

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$REPO_ROOT")
```

Run the project root helper and capture its stdout as `PROJECT_ROOT`:
```bash
~/.claude/commands/log/scripts/log-find-root.sh
```

If the script exits non-zero, stop and tell the user the error message it printed to stderr.

### 3. Parse cross-repo prefix

Check if `$ARGUMENTS` starts with a word followed by `: ` (e.g., `uboulder-web: some text`).

```bash
FULL_TEXT="$ARGUMENTS"
TARGET_REPO=""
DESCRIPTION=""

if echo "$FULL_TEXT" | grep -qE '^[a-zA-Z0-9_-]+: '; then
  TARGET_REPO=$(echo "$FULL_TEXT" | sed 's/: .*//')
  DESCRIPTION=$(echo "$FULL_TEXT" | sed 's/^[^:]*: //')
else
  DESCRIPTION="$FULL_TEXT"
fi
```

If `TARGET_REPO` is set:
- Verify `$PROJECT_ROOT/$TARGET_REPO` exists as a directory. If not, stop and tell the user: "Repo '<TARGET_REPO>' not found under project root. Check the folder name and try again." Do NOT increment the ID counter.
- Set `TARGET_DIR="$PROJECT_ROOT/$TARGET_REPO"`
- Set `FROM_TAG=" · from:${REPO_NAME}"`

If `TARGET_REPO` is not set:
- Set `TARGET_DIR="$REPO_ROOT"`
- Set `FROM_TAG=""`

### 4. Get next ID

Run the ID counter helper and capture its stdout as `ID`:
```bash
~/.claude/commands/log/scripts/log-next-id.sh
```

### 5. Build the entry

```bash
DATE=$(date +%Y-%m-%d)
BRANCH=$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
TARGET_NAME=$(basename "$TARGET_DIR")
ENTRY="- [ ] #${ID} [idea] ${DATE} · branch:${BRANCH}${FROM_TAG} — ${DESCRIPTION}"
```

### 6. Write to BACKLOG.md

```bash
BACKLOG="$TARGET_DIR/BACKLOG.md"
```

If `BACKLOG.md` does not exist in `TARGET_DIR`, create it with this exact content:
```
# Backlog — <TARGET_NAME>

## Open

## Done
```

Then append the entry on a new line under `## Open`, before `## Done`.

### 7. Confirm

If cross-repo: "Logged #<ID> [idea] → <TARGET_REPO>: <DESCRIPTION>"
Otherwise: "Logged #<ID> [idea]: <DESCRIPTION>"
