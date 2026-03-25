#!/usr/bin/env bash
# Floating pane script: fzf picker for Claude-modified files
# Super+M toggles this float → pick a file → nvim opens → :q returns to fzf
# Ctrl+G: lazygit (q returns to picker) | Ctrl+J: terminal (exit returns to picker)
TRACK_LINK="/tmp/claude-modified-files-latest"

# Get Claude's working directory from its process (source of truth)
get_claude_cwd() {
    local pid cwd
    # Try exact binary name first
    pid=$(pgrep -x claude 2>/dev/null | head -1)
    # Fallback: node-based claude
    [ -z "$pid" ] && pid=$(pgrep -af "node.*bin/claude" 2>/dev/null | head -1 | awk '{print $1}')
    if [ -n "$pid" ]; then
        cwd=$(readlink /proc/"$pid"/cwd 2>/dev/null)
        [ -n "$cwd" ] && echo "$cwd" && return
    fi
    # Last resort: derive from tracked files
    local target first_file
    target=$(readlink -f "$TRACK_LINK" 2>/dev/null)
    if [ -n "$target" ] && [ -s "$target" ]; then
        first_file=$(head -1 "$target")
        [ -n "$first_file" ] && [ -e "$first_file" ] && git -C "$(dirname "$first_file")" rev-parse --show-toplevel 2>/dev/null && return
    fi
}

while true; do
    # Try to cd to the main pane's working directory
    PANE_CWD=$(get_claude_cwd)
    if [ -n "$PANE_CWD" ]; then
        cd "$PANE_CWD" || true
    fi
    clear
    TARGET=$(readlink -f "$TRACK_LINK" 2>/dev/null)
    if [ -n "$TARGET" ] && [ -s "$TARGET" ]; then
        SELECTED=$(cat "$TARGET" | fzf \
            --prompt="Claude modified files > " \
            --header="Ctrl+G: lazygit | Ctrl+J: terminal" \
            --preview="batcat --color=always {} 2>/dev/null || bat --color=always {} 2>/dev/null || cat {}" \
            --preview-window=right:60% \
            --bind="ctrl-g:become(echo __LAZYGIT__)" \
            --bind="ctrl-j:become(echo __TERMINAL__)")
        if [ "$SELECTED" = "__LAZYGIT__" ]; then
            lazygit -p "$PANE_CWD"
        elif [ "$SELECTED" = "__TERMINAL__" ]; then
            cd "$PANE_CWD" && $SHELL
        elif [ -n "$SELECTED" ]; then
            nvim "$SELECTED"
        fi
    else
        echo ""
        echo "  No Claude-modified files tracked yet."
        echo "  Have Claude edit some files first."
        echo "  Ctrl+G: lazygit | Ctrl+J: terminal"
        echo ""
        read -r -s -n 1 KEY
        if [ "$KEY" = $'\x07' ]; then
            lazygit -p "$PANE_CWD"
        elif [ "$KEY" = $'\x0a' ]; then
            cd "$PANE_CWD" && $SHELL
        fi
    fi
done
