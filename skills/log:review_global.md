Display all open backlog items across all projects, grouped by project then by repo.

## Instructions

### 1. Detect current project root

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
GLOBAL_ROOT=$(dirname "$PROJECT_ROOT")
```

### 2. Find all projects

Scan all immediate subdirectories of `GLOBAL_ROOT` for `.logproject` files:

```bash
for PROJECT_DIR in "$GLOBAL_ROOT"/*/; do
  if [ -f "$PROJECT_DIR/.logproject" ]; then
    # this is a project — scan its repos
  fi
done
```

### 3. Aggregate across all projects

For each project found:
- For each immediate subdirectory of the project dir:
  - If `BACKLOG.md` exists and has `- [ ] ` lines (checked with `grep -cF -- '- [ ] '`), collect them with `grep -F -- '- [ ] '`

### 4. Display results

Format output as:

```
All Projects

## <project-name> (N open)

### <repo-name> (N open)
- [ ] #2 [idea] 2026-03-10 · branch:main — description

### <other-repo-name> (0 open)

## <other-project-name> (0 open)
```

If no open items exist anywhere, tell the user: "No open items found across all projects."
