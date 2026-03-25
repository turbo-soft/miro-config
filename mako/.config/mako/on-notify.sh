#!/bin/bash
# Bridge: mako notification → sway workspace urgency
# Maps notification app-names to sway app_ids and sets urgency

# Wait briefly for notification to be registered
sleep 0.1

# Get the latest notification's app-name
APP_NAME=$(makoctl list | jq -r '.data[0][0]["app-name"].data // empty')

# Map notification app-name → sway app_id
declare -A APP_MAP=(
    ["Mattermost"]="Mattermost"
    ["Viber"]="Viber"
    # Add more apps as needed
)

SWAY_APP_ID="${APP_MAP[$APP_NAME]}"

if [[ -n "$SWAY_APP_ID" ]]; then
    swaymsg "[app_id=$SWAY_APP_ID] urgent enable" 2>/dev/null
fi
