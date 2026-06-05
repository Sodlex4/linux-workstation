# linux-workstation

This repository contains my personal Linux configuration built on Arch Linux using [Hyprland](https://hyprland.org/) via [Omarchy](https://omarchy.org/).

## Machines

This repo manages configs for two machines. Both share hostname `omarchy` (Omarchy default) and are differentiated by hardware via DMI detection:

| Machine | Vendor | Model | Role |
|---------|--------|-------|------|
| **HP Laptop** | HP | HP EliteBook 840 G3 | Primary workstation |
| **Apple Mac Mini** | Apple Inc. | Macmini5,1 | Secondary machine |

Machine-specific configs live under `config/<app>/machine/<machine>/` and override shared configs at install time. See `lib/detect-machine.sh` for detection logic.

## Components

| Component | Config |
|-----------|--------|
| **Hyprland** | `config/hypr/` — window manager (user overrides) |
| | `config/hypr/omarchy-defaults/` — Omarchy default keybindings & settings |
| **Hyprlock** | `config/hypr/hyprlock.conf` — lock screen |
| **Hypridle** | `config/hypr/hypridle.conf` — idle management daemon |
| **Waybar** | `config/waybar/` — status bar |
| **Alacritty** | `config/alacritty/` — terminal emulator |
| **Kitty** | `config/kitty/` — terminal emulator |
| **Ghostty** | `config/ghostty/` — terminal emulator |
| **Walker** | `config/walker/` — app launcher |
| **SwayOSD** | `config/swayosd/` — on-screen display |
| **Starship** | `config/starship.toml` — shell prompt |
| **Btop** | `config/btop/` — system monitor |
| **Fastfetch** | `config/fastfetch/` — system info |
| **Lazygit** | `config/lazygit/` — git TUI |
| **Git** | `config/git/config` — git configuration |
| **Bash** | `bashrc` — shell aliases and config |

## Theme

Current theme: **Tokyo Night** (managed by Omarchy)

## Installation

```bash
# Clone to ~/Projects/dotfiles (or wherever you keep it)
git clone https://github.com/Sodlex4/linux-workstation.git ~/Projects/dotfiles

# Run the install script to symlink configs
cd ~/Projects/dotfiles
./install.sh
```

The install script will:
1. Back up any existing files in `~/.config/` that aren't already symlinks
2. Create symlinks pointing from `~/.config/<app>/<file>` to the repo files
3. Symlink `~/.bashrc` to the repo's `bashrc`
4. Skip any files already symlinked to the repo

## Note

Some configs import theme-dependent files from `~/.config/omarchy/current/theme/` (e.g. colors, wallpapers). These are managed by `omarchy-theme-set` and are not tracked here.
