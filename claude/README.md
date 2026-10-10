# Claude Code config

Stow it: `cd ~/miro-config && stow claude` → symlinks into `~/.claude/`.

What is here:
- `.claude/settings.json` — hooks, permissions, model prefs
- `.claude/hooks/` — notify.sh, track-modified-files.sh, herdr-agent-state.sh
- `.claude/skills/` — notify-setup, subs
- `.claude/keybindings.json`
- `.claude/projects/<project>/memory/` — auto-memory per project (copy, not symlinked; stow puts it back)

Not in the repo, redo by hand after a reinstall:
1. `claude` → `/login`
2. Plugin: `php-lsp` from the `claude-plugins-official` marketplace (`/plugin`)
3. MCP: `claude mcp add MCP_DOCKER -- docker mcp gateway run`
4. herdr: reinstall its Claude integration (it rewrites `herdr-agent-state.sh`; the hook entry is already in settings.json)
5. `./install-piper-voice.sh` for the notify voice
