# Fix Docker Desktop for Sway/Wayland

Wraps Docker Desktop binary to run natively on Wayland instead of XWayland.

## Usage

```bash
./fix-docker-desktop.sh
```

Run after installing Docker Desktop or after updates (updates overwrite the wrapper).

## What it does

1. Moves `/opt/docker-desktop/Docker Desktop` to `Docker Desktop.real`
2. Creates wrapper with `--no-sandbox --ozone-platform=wayland` flags
3. Restarts Docker Desktop service
