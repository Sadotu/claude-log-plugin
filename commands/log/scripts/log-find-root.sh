#!/usr/bin/env bash
# log-find-root.sh — walk up from cwd to find the nearest .logproject marker
# Prints the absolute path of that directory on stdout and exits 0.
# Exits non-zero with a message on stderr if no .logproject is found.

DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

while [ "$DIR" != "/" ]; do
  if [ -f "$DIR/.logproject" ]; then
    echo "$DIR"
    exit 0
  fi
  DIR=$(dirname "$DIR")
done

echo "No .logproject found in any ancestor directory. Run /log:init in your project root first." >&2
exit 1
