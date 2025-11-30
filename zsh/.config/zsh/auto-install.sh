#!/usr/bin/env zsh
# Auto-install missing tools when shell starts

# Initialize Homebrew on macOS if not already in PATH
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ ! -x "$(command -v brew)" ]]; then
        # Try common Homebrew locations
        if [[ -x "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -x "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
fi

# Only run installation check if tools are missing
# Once all tools are installed, this script does nothing (adds ~5ms overhead)
if ! command -v eza &> /dev/null || ! command -v zoxide &> /dev/null || ! command -v yazi &> /dev/null || ! command -v nvim &> /dev/null || ! command -v zellij &> /dev/null; then
    function ensure_tool_installed() {
        local tool=$1

        if ! command -v "$tool" &> /dev/null; then
            echo "Installing $tool..."
            if [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS
                if ! command -v brew &> /dev/null; then
                    echo "Homebrew not found. Please install: https://brew.sh"
                    return 1
                fi
                brew install "$tool"
            elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
                # Linux - try common package managers
                if command -v apt-get &> /dev/null; then
                    sudo apt-get update && sudo apt-get install -y "$tool"
                elif command -v pacman &> /dev/null; then
                    sudo pacman -S --noconfirm "$tool"
                elif command -v dnf &> /dev/null; then
                    sudo dnf install -y "$tool"
                else
                    echo "No supported package manager found. Please install $tool manually."
                    return 1
                fi
            fi
        fi
    }

    # Auto-install essential tools
    ensure_tool_installed "eza"
    ensure_tool_installed "zoxide"
    ensure_tool_installed "yazi"
    ensure_tool_installed "neovim"
    ensure_tool_installed "zellij"
fi