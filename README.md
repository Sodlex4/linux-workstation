# linux-workstation

Portable OS config — clone on any Linux machine, auto-detect hardware, set up everything.

[**Machine Inventory →**](MACHINES.md)

## How It Works

Every machine is identified by its DMI `product_name` (e.g. `HP_EliteBook_840_G3`).
Configs live in per-machine slots under `config/<app>/machine/<slot>/`.

| Slot | Machine | Role |
|------|---------|------|
| `HP_EliteBook_840_G3` | HP EliteBook 840 G3 | Primary workstation |
| `Apple_MacMini` | Apple Mac Mini (Macmini5,1) | Secondary machine |

On first run on an unknown machine, `install.sh` auto-generates `monitors.conf`, `input.conf`, and `autostart.conf` from live hardware probes — no manual editing needed.

For the runtime startup flow — how configs layer from Omarchy defaults → theme → user overrides → autostart services — see [Architecture → Startup Flow](ARCHITECTURE.md#startup-flow).

## Key Scripts

| Script | Purpose |
|--------|---------|
| `lib/detect-machine.sh` | Returns sanitized DMI product_name |
| `lib/probe-hardware.sh` | Live JSON probe of monitors, input, GPU, distro |
| `lib/auto-generate.sh <slot>` | Writes machine configs from probe data |
| `lib/error-log.sh` | Structured per-machine error tracking (`errors.json`) |
| `lib/generate-machines.sh` | Generates [MACHINES.md](MACHINES.md) inventory table |
| `packages/install-packages.sh` | Auto-detect distro + install from package lists |
 | `install.sh` | Symlink all configs, detect stale links, auto-generate |

## Syncing Between Machines

### Editing a shared config (affects all machines)

```bash
# On the machine where you made the change:
cd ~/Projects/dotfiles
git add -A
git commit -m "describe what you changed and why"
git push

# On the other machine:
cd ~/Projects/dotfiles
git pull origin master
```

### Editing a machine-specific config (affects one machine)

Files under `config/<app>/machine/<slot>/` apply only to that machine.
Example:

- `config/hypr/machine/HP_EliteBook_840_G3/monitors.conf` → **HP only**
- `config/hypr/machine/Apple_MacMini/input.conf` → **Mac Mini only**

### Adding a new config file

Run `./install.sh` on the other machine after pulling — it detects new files and creates symlinks.

## Adding a New Machine

1. Clone this repo on the new machine
2. Run `./install.sh` — it auto-detects hardware and generates configs
3. Review the generated configs in `config/hypr/machine/<slot>/`
4. Commit and push the new machine slot

## Package Installation

```bash
# See what would be installed
./packages/install-packages.sh --dry-run

# Install packages for this machine
./packages/install-packages.sh
```

Package lists are in `packages/<distro>/`:
- `common.txt` — base packages for all machines
- `<slot>.txt` — per-machine extras

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

## Installation

```bash
git clone https://github.com/Sodlex4/linux-workstation.git ~/Projects/dotfiles
cd ~/Projects/dotfiles
./install.sh
```

The install script auto-detects your machine via DMI, symlinks shared + machine-specific configs, and auto-generates configs for unrecognized machines. Existing files are backed up before replacement.

```bash
# Optional: install packages for this machine
./packages/install-packages.sh
```

## Theme

Current theme: **Tokyo Night** (managed by Omarchy).

Some configs import theme files from `~/.config/omarchy/current/theme/` (colors, wallpapers). These are managed by `omarchy-theme-set` and are not tracked here.
