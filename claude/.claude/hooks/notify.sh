#!/usr/bin/env bash
# Claude Code notification hook
# - Plays Piper voice when user is NOT looking at this tab
# - Sends tab alert to zj-status-bar (tab turns colored)
# Usage: notify.sh "message text"

MSG="${1:-Task completed}"
MODEL="$HOME/.local/share/piper-voices/en_US-lessac-medium.onnx"

play_voice() {
    echo "$MSG" | piper --model "$MODEL" --output-raw 2>/dev/null \
        | pw-play --rate 22050 --channels 1 --format s16 - 2>/dev/null || true
}

# Always show desktop notification
notify-send 'Claude Code' "$MSG" -i dialog-information 2>/dev/null

# Inside Zellij: check if user is on a different tab
if [ -n "$ZELLIJ_SESSION_NAME" ]; then
    USER_ON_TAB=$(zellij action list-clients 2>/dev/null \
        | awk -v pane="terminal_$ZELLIJ_PANE_ID" 'NR>1 && $2==pane {print "yes"; exit}')

    if [ "$USER_ON_TAB" = "yes" ]; then
        # User is on our tab - stay silent, no tab alert needed
        exit 0
    fi

    # User is on a different tab - send tab alert + play voice
    echo "" | zellij pipe --name zj-status-bar:cli:tab_alert --args "pane_id=$ZELLIJ_PANE_ID,exit_code=1" &
    play_voice
    exit 0
fi

# Outside Zellij: check if Zellij window is focused in Sway
FOCUSED=$(swaymsg -t get_tree 2>/dev/null | python3 -c "
import json, sys
tree = json.load(sys.stdin)
def find_focused(node):
    if node.get('focused'):
        return node.get('name', '')
    for child in node.get('nodes', []) + node.get('floating_nodes', []):
        r = find_focused(child)
        if r: return r
    return ''
print(find_focused(tree))
" 2>/dev/null)

if echo "$FOCUSED" | grep -qi "zellij"; then
    exit 0
fi

play_voice
