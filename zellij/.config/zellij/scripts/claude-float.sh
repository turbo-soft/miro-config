#!/usr/bin/env bash
# Floating pane script: fzf picker for Claude-modified files
# Super+M toggles this float → pick a file → nvim opens → :q returns to fzf
TRACK_LINK="/tmp/claude-modified-files-latest"
while true; do
    clear
    TARGET=$(readlink -f "$TRACK_LINK" 2>/dev/null)
    if [ -n "$TARGET" ] && [ -s "$TARGET" ]; then
        SELECTED=$(cat "$TARGET" | fzf --prompt="Claude modified files > ")
        if [ -n "$SELECTED" ]; then
            nvim "$SELECTED"
        fi
    else
        echo ""
        echo "  No Claude-modified files tracked yet."
        echo "  Have Claude edit some files first."
        echo ""
        read -r -p "  Press Enter to refresh..."
    fi
done
