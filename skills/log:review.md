Display all open backlog items for the current repository only.

## Instructions

### 1. Detect current repo

```bash
git rev-parse --show-toplevel 2>/dev/null
```

If this fails, tell the user: "Not inside a git repository."

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$REPO_ROOT")
BACKLOG="$REPO_ROOT/BACKLOG.md"
```

### 2. Read and display open items

If `BACKLOG.md` does not exist or contains no lines matching `- [ ] `, tell the user: "No open items in <REPO_NAME>."

Otherwise, extract and display all lines matching `- [ ] ` from `BACKLOG.md`:

```bash
grep -F -- '- [ ] ' "$BACKLOG"
```

Format the output as:

```
Open items in <REPO_NAME>:

- [ ] #3 [bug] 2026-03-10 · branch:main — Token not refreshed on 401
- [ ] #5 [idea] 2026-03-10 · branch:feature/x — Add optimistic UI
```
