#!/usr/bin/env bash
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -z "$SESSION_ID" ] || [ -z "$FILE_PATH" ] && exit 0

TRACK_FILE="/tmp/claude-modified-files-${SESSION_ID}.txt"
grep -qxF "$FILE_PATH" "$TRACK_FILE" 2>/dev/null || echo "$FILE_PATH" >> "$TRACK_FILE"
ln -sfn "$TRACK_FILE" /tmp/claude-modified-files-latest
