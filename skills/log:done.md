Mark a backlog item as done by its ID. Searches all repositories in the current project.

## Arguments
The ID number of the item to mark done: `$ARGUMENTS`

Example: `/log:done 7`

## Instructions

### 1. Validate input

`$ARGUMENTS` should be a number. If it is not, tell the user: "Usage: /log:done <id>  Example: /log:done 7"

### 2. Detect project root

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

### 3. Search for the item

Search all `BACKLOG.md` files under `PROJECT_ROOT` for a line matching `- [ ] #<ID> `:

```bash
ID="$ARGUMENTS"
grep -rlF -- "- [ ] #${ID} " "$PROJECT_ROOT" --include="BACKLOG.md"
```

If no match is found, tell the user: "No open item with ID #<ID> found in this project."

### 4. Mark as done

In the file containing the match:

1. Change the matching line from `- [ ] #<ID> ...` to `- [x] #<ID> ...`
2. Move that line from the `## Open` section to the `## Done` section

To do this safely, read the file content, make both changes (checkbox flip + section move), and write the updated content back.

The `## Done` section is at the bottom of the file. Append the completed entry as a new line there.

### 5. Confirm

Tell the user: "#<ID> marked as done."
