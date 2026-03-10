---
name: "log:review_all"
description: "Display open backlog items across all repos in the current project"
---

Display all open backlog items across all repositories in the current project, grouped by repo.

## Instructions

### 1. Detect project root

```bash
git rev-parse --show-toplevel 2>/dev/null
```

If this fails, tell the user: "Not inside a git repository."

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)

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

If `PROJECT_ROOT` is empty, tell the user: "No .logproject found. Run /log:init in your project root first."

```bash
PROJECT_NAME=$(basename "$PROJECT_ROOT")
```

### 2. Walk all subdirectories and aggregate

For each immediate subdirectory of `PROJECT_ROOT`:

```bash
for SUBDIR in "$PROJECT_ROOT"/*/; do
  REPO_NAME=$(basename "$SUBDIR")
  BACKLOG="$SUBDIR/BACKLOG.md"
  # collect open items
done
```

For each subdirectory:
- Check for open items with: `grep -cF -- '- [ ] ' "$BACKLOG" 2>/dev/null || echo 0`
- If `BACKLOG.md` exists and has `- [ ] ` lines, collect them with: `grep -F -- '- [ ] ' "$BACKLOG"`
- Track both repos with items and repos with none

### 3. Display results

Format output as:

```
Project: <PROJECT_NAME>

## <repo-name> (N open)
- [ ] #3 [bug] 2026-03-10 · branch:main — description
- [ ] #5 [idea] 2026-03-10 · branch:feature/x — description

## <other-repo-name> (0 open)
```

Show all repos found under the project root, even those with 0 open items. If no repos have any open items, tell the user: "No open items in project <PROJECT_NAME>."
