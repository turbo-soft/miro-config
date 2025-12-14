#!/bin/bash
# Fix Docker Desktop for Sway/Wayland
# Run this after installing Docker Desktop or after it updates

set -e

DOCKER_DIR="/opt/docker-desktop"
BINARY="$DOCKER_DIR/Docker Desktop"
REAL_BINARY="$DOCKER_DIR/Docker Desktop.real"

if [[ ! -f "$REAL_BINARY" ]]; then
    if [[ ! -f "$BINARY" ]]; then
        echo "Docker Desktop not found at $DOCKER_DIR"
        exit 1
    fi
    echo "Moving original binary..."
    sudo mv "$BINARY" "$REAL_BINARY"
fi

echo "Creating wrapper script..."
sudo tee "$BINARY" > /dev/null << 'EOF'
#!/bin/bash
exec "/opt/docker-desktop/Docker Desktop.real" --no-sandbox --enable-features=UseOzonePlatform --ozone-platform=wayland "$@"
EOF

sudo chmod +x "$BINARY"

echo "Restarting Docker Desktop..."
systemctl --user restart docker-desktop

echo "Done! Docker Desktop should now work on Sway/Wayland."
