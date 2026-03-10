Initialize the current directory as a project root for the log plugin.

Run this once in the parent directory that contains your repositories (e.g., `~/Dev/my-project/` which contains `frontend/` and `backend/`).

## Instructions

### 1. Check current directory

```bash
pwd
```

### 2. Check if already initialized

```bash
if [ -f ".logproject" ]; then
  echo "already initialized"
fi
```

If `.logproject` already exists in the current directory, tell the user: "This directory is already a project root." and stop.

### 3. Create marker file

Create a file named `.logproject` in the current directory with this content:

```
# claude-log-plugin project root
# This file marks this directory as a project root.
# Commit this file to git alongside your repositories.
```

### 4. Confirm

Tell the user:
"Project root initialized at <current directory>.

Run /log:bug, /log:task, or /log:idea from any git repository under this directory to start logging.

Tip: commit .logproject to git so this setup travels with your project."
