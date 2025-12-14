# Scripts

System fix scripts that can't be managed directly by stow (require sudo or modify system files).

## Installation

```bash
cd ~/miro-config && stow scripts
```

This symlinks scripts to `~/.local/bin/`.

---

## fix-docker-desktop

Fixes Docker Desktop GUI crash on Sway/Wayland.

### Problem

Docker Desktop uses Electron for its UI. On Sway (Wayland compositor), it crashes with a segmentation fault on startup because:

1. **Sandbox issue** - Electron's Chrome sandbox doesn't work correctly, causing immediate crashes
2. **Display protocol** - By default Electron uses XWayland, which causes tray icon to be non-interactive on Sway

### Symptoms

- Docker Desktop fails to open
- Popup error: "Docker Desktop failed"
- No icon appears in system tray
- Journal logs show: `electron crashed`, `segmentation fault (core dumped)`

### Solution

The script creates a wrapper at `/opt/docker-desktop/Docker Desktop` that runs the real binary with these flags:

- `--no-sandbox` - Disables Chrome sandbox that causes crashes
- `--enable-features=UseOzonePlatform --ozone-platform=wayland` - Uses native Wayland instead of XWayland

### Usage

```bash
fix-docker-desktop
```

Run this script:
- After fresh Docker Desktop installation
- After Docker Desktop updates (updates overwrite the wrapper)

### Manual Fix

If the script isn't available:

```bash
sudo mv "/opt/docker-desktop/Docker Desktop" "/opt/docker-desktop/Docker Desktop.real"
echo '#!/bin/bash
exec "/opt/docker-desktop/Docker Desktop.real" --no-sandbox --enable-features=UseOzonePlatform --ozone-platform=wayland "$@"' | sudo tee "/opt/docker-desktop/Docker Desktop"
sudo chmod +x "/opt/docker-desktop/Docker Desktop"
systemctl --user restart docker-desktop
```
