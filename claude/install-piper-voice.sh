#!/usr/bin/env bash
# Downloads Piper TTS voice model used by Claude Code notification hooks
# Run this after stowing: bash ~/miro-config/claude/install-piper-voice.sh

set -euo pipefail

MODEL_DIR="$HOME/.local/share/piper-voices"
MODEL="en_US-lessac-medium.onnx"
BASE_URL="https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium"

mkdir -p "$MODEL_DIR"

if [ -f "$MODEL_DIR/$MODEL" ]; then
    echo "Piper voice model already installed."
    exit 0
fi

echo "Downloading Piper voice model (~63MB)..."
curl -L -o "$MODEL_DIR/$MODEL" "$BASE_URL/$MODEL"
curl -L -o "$MODEL_DIR/$MODEL.json" "$BASE_URL/$MODEL.json"
echo "Done. Voice model installed to $MODEL_DIR/"

# Ensure piper-tts is installed
if ! command -v piper &>/dev/null; then
    echo "Installing piper-tts via pipx..."
    pipx install piper-tts
    pipx inject piper-tts pathvalidate
fi
