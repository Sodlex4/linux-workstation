# linux-workstation

Personal Linux configuration for two machines running Arch Linux on [Hyprland](https://hyprland.org/) via [Omarchy](https://omarchy.org/): an **HP EliteBook 840 G3** and an **Apple Mac Mini**.

## Machines

This repo manages configs for two machines. Both share hostname `omarchy` (Omarchy default) and are differentiated by hardware via DMI detection:

| Machine | Vendor | Model | Role |
|---------|--------|-------|------|
| **HP Laptop** | HP | HP EliteBook 840 G3 | Primary workstation |
| **Apple Mac Mini** | Apple Inc. | Macmini5,1 | Secondary machine |

Machine-specific configs live under `config/<app>/machine/<machine>/` and override shared configs at install time. See `lib/detect-machine.sh` for detection logic.

## Syncing Between Machines

This repo is shared between the HP laptop and the Apple Mac Mini. Here's how config changes flow between them.

### Editing a shared config (affects both machines)

Shared configs are files **without** a `machine/` subdirectory — things like `config/waybar/style.css`, `config/starship.toml`, `config/hypr/bindings.conf`. When you edit one of these on either machine, the change applies to both.

**Workflow:**

```bash
# On the machine where you made the change:
cd ~/Work/linux-workstation
git add -A
git commit -m "describe what you changed and why"
git push

# On the other machine:
cd ~/Work/linux-workstation
git pull origin master
```

Since the live config is a **symlink** pointing into the repo, editing the file in the repo changes it immediately. After `git pull` on the other machine, the symlink automatically points to the updated file — no `./install.sh` needed unless you added a **brand new file**.

### Editing a machine-specific config (affects one machine)

Machine-specific files live in `config/<app>/machine/<name>/`. The naming tells you which machine they belong to:

- `config/hypr/machine/hp/monitors.conf` → **HP only**
- `config/hypr/machine/macmini/monitors.conf` → **Mac Mini only**
- `config/hypr/machine/hp/input.conf` → **HP only**
- `config/hypr/machine/macmini/input.conf` → **Mac Mini only**

When you edit a file in `machine/hp/`, only the HP gets the change — the Mac Mini pulls the file but `install.sh` skips it (it only links files from `machine/macmini/`).

### Adding a new config file

If you add a new file (not just editing an existing one), run `./install.sh` on the other machine after pulling. This creates the new symlink and backs up any existing file with the same name.

### Summary table

| You edit this... | HP sees the change? | Mac Mini sees the change? |
|---|---|---|
| `config/waybar/style.css` (shared) | Yes | Yes |
| `config/hypr/machine/hp/monitors.conf` | Yes | No — HP‑only |
| `config/hypr/machine/macmini/input.conf` | No — Mac Mini only | Yes |
| A brand new shared file | After `./install.sh` | After `./install.sh` |

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
