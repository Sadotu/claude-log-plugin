# claude-log-plugin

A Claude Code plugin for logging bugs, tasks, and ideas across repositories — without breaking your flow.

When you're working in the backend and notice something about the frontend, log it immediately. Everything stays in markdown, travels with git, and surfaces at the start of each session.

## Requirements

- [Claude Code](https://claude.ai/code)
- git
- bash

No package manager required.

## Install

```bash
git clone <repo-url> claude-log-plugin
cd claude-log-plugin
./install.sh
```

## Setup (once per project)

Navigate to the directory that contains your repositories and run:

```bash
cd ~/Dev/my-project   # the folder containing frontend/, backend/, etc.
/log:init
```

Commit the `.logproject` marker file to git so the setup travels with your project.

## Usage

### Log something

```bash
/log:bug   Token not refreshed on 401
/log:task  Add rate limiting to the API
/log:idea  Add dark mode toggle to settings
```

### Log to a different repo (cross-repo)

```bash
# While in backend, log an idea for the frontend:
/log:idea frontend: Add dark mode toggle to settings
```

### Review items

```bash
/log:review           # current repo only
/log:review_all       # all repos in current project
/log:review_global    # all projects
```

### Mark done

```bash
/log:done 7   # marks item #7 as done
```

## How it works

- Each repository gets a `BACKLOG.md` as its sole source of truth
- A global ID counter at `~/.claude/log/next-id` gives every entry a unique ID
- Project boundaries are declared by a `.logproject` marker file
- Review commands aggregate lazily — no sync, no duplicate writes
- At the start of each Claude session, open items in the current repo are surfaced automatically

## File structure

```
your-project/
  .logproject          ← marks this as a project root (commit to git)
  frontend/
    BACKLOG.md         ← logged items for frontend
  backend/
    BACKLOG.md         ← logged items for backend
```

## Uninstall

```bash
rm -rf ~/.claude/commands/log/
rm -rf ~/.claude/log/
# Remove the session-start block from ~/.claude/CLAUDE.md
# Delete .logproject files from your project roots
```
