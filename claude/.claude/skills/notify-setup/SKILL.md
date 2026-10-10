---
name: notify-setup
description: Set up or troubleshoot the Claude Code notification system with Piper TTS voice, Zellij tab color alerts, and desktop notifications. Use when the user asks about notifications, sounds, voice alerts, or tab coloring.
disable-model-invocation: true
argument-hint: [setup|status|test|fix]
---

# Claude Code Notification System

This skill manages the notification system that alerts the user when Claude Code needs attention, using voice (Piper TTS), desktop notifications, and Zellij tab color alerts.

## Architecture

The system consists of these components:

### 1. Hook Configuration (`~/.claude/settings.json`)

Four Claude Code hooks call `~/.claude/hooks/notify.sh`:

| Hook | Event | Message |
|---|---|---|
| `Stop` | Claude finishes a response | "Task completed" |
| `Notification` | Claude needs authorization | "Authorization needed" |
| `SubagentStop` | Background agent finishes | "Background task finished" |
| `PermissionRequest` | Tool needs permission | "Permission required" |

**Known limitation**: `AskUserQuestion` events (interactive prompts) do NOT trigger any hook. This is a missing feature in Claude Code ([#13830](https://github.com/anthropics/claude-code/issues/13830)).

### 2. Notification Script (`~/.claude/hooks/notify.sh`)

The script does three things:
1. **Desktop notification** via `notify-send` (always)
2. **Piper TTS voice** via `piper` + `pw-play` (only when user is NOT on this tab)
3. **Zellij tab color alert** via `zellij pipe` to zj-status-bar (only when on a different tab)

**Focus detection logic (Zellij + Sway)**:
- Inside Zellij: compares `ZELLIJ_PANE_ID` with focused tab index from `zellij action dump-layout`
- Outside Zellij: checks focused window title via `swaymsg` for "zellij"
- If user is looking at the tab → silent (desktop notification only)
- If user is on another tab or another app → voice + tab alert

### 3. Piper TTS Voice

- Model: `en_US-lessac-medium.onnx` (female voice, ~63MB)
- Location: `~/.local/share/piper-voices/`
- Installed via: `pipx install piper-tts` + `pipx inject piper-tts pathvalidate`
- Audio playback: `pw-play` (PipeWire)

### 4. Zellij Tab Color Alerts (`zj-status-bar` plugin)

- Plugin: `~/.config/zellij/plugins/zj-status-bar.wasm`
- Layout: `~/.config/zellij/layouts/minimal.kdl` uses the plugin instead of default `tab-bar`
- Alert command: `zellij pipe --name zj-status-bar:cli:tab_alert --args "pane_id=$ZELLIJ_PANE_ID,exit_code=1"`
- `exit_code=0` → green, `exit_code=1` → red
- Alerts auto-clear when user switches to that tab

## Setup on a New Machine

```bash
# 1. Stow config files (from ~/miro-config)
cd ~/miro-config && stow --no-folding claude && stow zellij

# 2. Install Piper TTS and voice model
bash ~/miro-config/claude/install-piper-voice.sh

# 3. Ensure system dependencies exist
# notify-send (libnotify-bin), pw-play (pipewire), python3, zellij

# 4. First Zellij launch: grant zj-status-bar plugin permissions
# Focus the plugin pane (zellij action move-focus "up") and press y
```

## Troubleshooting

If `$ARGUMENTS` is "status":
- Check if `~/.claude/hooks/notify.sh` exists and is executable
- Check if `~/.claude/settings.json` has the hooks configured
- Check if `piper` is installed: `which piper`
- Check if voice model exists: `ls ~/.local/share/piper-voices/`
- Check if `pw-play` works: `pw-play /usr/share/sounds/freedesktop/stereo/complete.oga`
- Check Zellij plugin: `ls ~/.config/zellij/plugins/zj-status-bar.wasm`

If `$ARGUMENTS` is "test":
- Run: `~/.claude/hooks/notify.sh "Test notification"`
- Test tab alert: `echo "" | zellij pipe --name zj-status-bar:cli:tab_alert --args "pane_id=0,exit_code=1" &`
- Test voice directly: `echo "Hello" | piper --model ~/.local/share/piper-voices/en_US-lessac-medium.onnx --output-raw 2>/dev/null | pw-play --rate 22050 --channels 1 --format s16 -`

If `$ARGUMENTS` is "fix":
- Verify symlinks: `ls -la ~/.claude/settings.json ~/.claude/hooks/notify.sh`
- Re-stow if broken: `cd ~/miro-config && stow --no-folding --restow claude`
- Reinstall voice: `bash ~/miro-config/claude/install-piper-voice.sh`
