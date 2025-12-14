# APT Hook - Auto-update Package List

This hook automatically updates `pkglist/pkglist.txt` whenever packages are installed or removed via apt.

## How it works

The `99update-pkglist` file is an apt hook that runs after every dpkg operation. It executes:
```
apt-mark showmanual | sort > /home/miro/miro-config/pkglist/pkglist.txt
```

## Installation

Run the install script (requires sudo):
```bash
./install.sh
```

This copies `99update-pkglist` to `/etc/apt/apt.conf.d/`.

## Note

This cannot be installed via `stow` because it needs to go to `/etc/`, not `$HOME`.
