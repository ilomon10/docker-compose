#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_DATA="/usr/src/node-red/data"
TARGET_DATA="/data"
IGNORE_FILE="$SCRIPT_DIR/.backupignore"

echo "Start backing up from $TARGET_DATA to $USER_DATA"
mkdir -p "$USER_DATA"
cd "$TARGET_DATA"

if [ -f "$IGNORE_FILE" ]; then
  echo "Using ignore file: $IGNORE_FILE"

  # Convert .backupignore patterns into a regex
  GREP_PATTERN=$(grep -vE '^\s*#|^\s*$' "$IGNORE_FILE" | sed 's/\./\\./g; s/\*/.*/g' | paste -sd "|" -)

  echo "Ignore pattern: $GREP_PATTERN"

  find . -type f | grep -Ev "$GREP_PATTERN" | while read -r file; do
    dest="$USER_DATA/${file#./}"
    mkdir -p "$(dirname "$dest")"
    cp -v "$file" "$dest"
  done
else
  echo "No .backupignore found next to script, copying everything"
  cp -a "$TARGET_DATA/." "$USER_DATA/"
fi

echo "Backup Success"
