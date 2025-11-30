## Installing

You will need `git` and GNU `stow`

Clone into your `$HOME` directory or `~`
```bash
git clone https://github.com/blazingly-fast/Miro-OS.git ~/miro-config
cd ~/miro-config
```

Run `stow` to symlink everything or just select what you want

```bash
stow */ # Everything (the '/' ignores the README)
```

```bash
stow zsh # Just my zsh config
```

### First Run

When you first open a terminal after stowing, the configuration will automatically:
- Clone missing zsh plugins (autosuggestions, syntax highlighting, autopair, etc.)
- Attempt to install essential tools (`eza` and `zoxide`) if they're missing

The auto-install feature works on both **macOS** (via Homebrew) and **Linux** (via apt/pacman/dnf).

If you don't have Homebrew on macOS, install it first:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Programs

An updated list of all the programs I use can be found in the `pkgfiles` directory

### Essential Tools Auto-Installed
- **eza** - Modern replacement for `ls` (used by `ll` alias)
- **zoxide** - Smart directory jumper (used by `j` and `f` aliases)
- **yazi** - Terminal file manager (bound to `Ctrl+O`)
- **neovim** - Modern Vim-based text editor
- **zellij** - Terminal multiplexer (like tmux/screen)



