# linux-workstation

Portable Omarchy config — clone on any machine running Omarchy, symlink everything into place.

[**Machine Inventory →**](MACHINES.md)

## Requirements

Omarchy **quattro** or newer (the Lua-config generation). Verify with:

```bash
omarchy-version
```

Older Omarchy reads `hypr/*.conf` and cannot use this repo — see
[Omarchy Versions](#omarchy-versions) below.

## How It Works

`install.sh` symlinks every file under `config/` into `~/.config/`, plus repo
root files into `~/`. Existing files are backed up first.

The Hyprland config in this repo is **machine-neutral**: `monitors.lua` uses
`output = ""` with `mode = "preferred"`, so it adapts to whatever display is
attached. One set of files serves every machine.

Machines are still identified by DMI `product_name` (e.g. `HP_EliteBook_840_G3`),
and optional overrides can live in `config/<app>/machine/<slot>/`. Those
per-machine slots are currently **empty** — one shared config serves both
machines.

| Slot | Machine | Role |
|------|---------|------|
| `HP_EliteBook_840_G3` | HP EliteBook 840 G3 | Primary workstation |
| `Apple_MacMini` | Apple Mac Mini (Macmini5,1) | Secondary machine |

`install.sh` deliberately does not auto-generate machine overrides, because
generated monitors pin an output name and would override the portable shared
config. To probe hardware for a machine, run `./lib/probe-hardware.sh`; to
generate slot overrides, run `./lib/auto-generate.sh <slot>` yourself and review
them before committing.

### Omarchy Versions

| Omarchy | Hyprland config | Usable here |
|---------|-----------------|-------------|
| quattro+ | Lua (`*.lua`) | yes |
| pre-quattro | `.conf` | no — needs its own config |

Upgrading an older machine:

```bash
omarchy-upgrade-to-quattro   # then reboot
git pull origin master
./install.sh
```

Upgrade **before** pulling. The upgrade script writes its own defaults into
`~/.config/hypr/` and backs up anything it replaces with a
`.omarchy-upgrade-to-quattro.<timestamp>.bak` suffix, so linking the repo
first can result in those defaults overwriting your symlinks.

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
cd ~/dev/projects/dotfiles
git add -A
git commit -m "describe what you changed and why"
git push

# On the other machine:
cd ~/dev/projects/dotfiles
git pull origin master
```

### Editing a machine-specific config (affects one machine)

Files under `config/<app>/machine/<slot>/` apply only to that machine, and take
precedence over the shared file of the same name. Both slots are currently
empty, so everything comes from `config/`.

To add an override:

```bash
./lib/auto-generate.sh HP_EliteBook_840_G3   # writes monitors/input/autostart .lua
./install.sh                                  # links them, they now win
```

Hyprland's compositor overrides (`monitors`, `input`, `bindings`, `looknfeel`,
`autostart`) are shared `config/hypr/*.lua` files — Omarchy Quattro loads
Hyprland config through Lua, so `.conf` files only apply to the separate daemons
this repo still owns: `hypridle`, `hyprsunset`, and `xdph`.

### Adding a new config file

Run `./install.sh` on the other machine after pulling — it detects new files and creates symlinks.

## Adding a New Machine

1. Upgrade it to Omarchy Quattro: `omarchy-upgrade-to-quattro`, then reboot
2. Clone this repo on the new machine
3. Run `./install.sh` — it detects hardware and creates the symlinks
4. Run `./lib/check-deps.sh` to confirm every referenced command is installed

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
| **Hyprland** | `config/hypr/*.lua` — compositor (user overrides; Omarchy Quattro loads Lua) |
| **Hypridle** | `config/hypr/hypridle.conf` — idle management daemon |
| **Hyprsunset** | `config/hypr/hyprsunset.conf` — blue-light filter |
| **xdph** | `config/hypr/xdph.conf` — screen-sharing portal |
| **Alacritty** | `config/alacritty/` — terminal emulator |
| **Kitty** | `config/kitty/` — terminal emulator |
| **Ghostty** | `config/ghostty/` — terminal emulator |
| **Starship** | `config/starship.toml` — shell prompt |
| **Btop** | `config/btop/` — system monitor |
| **Fastfetch** | `config/fastfetch/` — system info |
| **Lazygit** | `config/lazygit/` — git TUI |
| **Git** | `config/git/config` — git configuration |
| **OpenCode** | `config/opencode/` — agent client config |
| **Bash** | `bashrc` — shell aliases and config |

> **Note:** the status bar, app launcher, lock screen, screensaver, night
> light, and OSD are provided by Omarchy's Quickshell shell, not by this repo.
> The Waybar, Walker, Mako, SwayOSD, and Hyprlock/Hyprpaper configs were removed
> when the desktop moved to Omarchy Quattro. Wallpapers are drawn by `awww`,
> which `config/hypr/autostart.lua` launches.

## Installation

Omarchy Quattro only. On a pre-Quattro machine, upgrade first:

```bash
omarchy-upgrade-to-quattro   # then reboot
```

Then:

```bash
git clone https://github.com/Sodlex4/linux-workstation.git ~/dev/projects/dotfiles
cd ~/dev/projects/dotfiles
./install.sh
./lib/check-deps.sh
```

The install script detects your machine via DMI and symlinks every config file into `~/.config/`, along with any machine-specific overrides found for that slot. Existing files are backed up to `~/.config/dotfiles-backup-<timestamp>/` before replacement. It is safe to re-run: files already linked correctly are skipped.

```bash
# Optional: install packages for this machine
./packages/install-packages.sh
```

## Theme

Current theme: **Tokyo Night** (managed by Omarchy).

Some configs import theme files from `~/.local/state/omarchy/current/theme/`
(colors, wallpapers). These are managed by `omarchy-theme-set` and are not
tracked here.

Quattro moved the theme from `~/.config/omarchy/current` to
`~/.local/state/omarchy/current`; this repo targets the new path.
