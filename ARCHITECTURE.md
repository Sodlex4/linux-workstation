# Architecture

## Machines

Machines are identified by their DMI `product_name` (sanitized: spaces → underscores).
Currently tracked:

| Slot | Machine | Role |
|------|---------|------|
| `HP_EliteBook_840_G3` | HP EliteBook 840 G3 | Primary workstation |
| `Apple_MacMini` | Apple Mac Mini (Macmini5,1) | Secondary machine |

New machines are auto-detected on first run — `install.sh` probes hardware and
generates configs on the fly. See `lib/detect-machine.sh`, `lib/probe-hardware.sh`,
`lib/auto-generate.sh`.

## Startup Flow

Hyprland reads `~/.config/hypr/hyprland.lua`, which layers configuration
from three sources:

```
┌──────────────────────────────────────────────────┐
│ 1. Omarchy Defaults ($OMARCHY_PATH/default/hypr) │
│    envs.lua, input.lua, windows.lua              │
│    looknfeel.lua, autostart.lua                  │
│    bindings/ (media, clipboard, tiling, utils)   │
├──────────────────────────────────────────────────┤
│ 2. Theme (~/.local/state/omarchy/current/theme/)│
│    Colors, backgrounds                           │
├──────────────────────────────────────────────────┤
│ 3. User Overrides (~/dev/projects/dotfiles)      │
│    config/hypr/hyprland.lua                      │
│      requires monitors, input, bindings,         │
│              looknfeel, autostart (.lua)         │
└──────────────────────────────────────────────────┘
```

`$OMARCHY_PATH` is set by the session (it resolves to
`~/.local/share/omarchy` on this machine, `/usr/share/omarchy` on a packaged
install). In Lua, each `require`d module is a file named after it:
`require("hypr.monitors")` loads `config/hypr/monitors.lua`. The separate
daemons this repo still owns — hypridle, hyprsunset, xdph — read plain `.conf`
files.

### Service Autostart (in order)

After Hyprland initializes, the following start via `exec-once`:

| Service | Role | Source |
|---------|------|--------|
| `quickshell` | Status bar, launcher, lock screen, screensaver, night light, OSD | Omarchy default |
| `hypridle` | Idle daemon — screensaver and lock timers | `config/hypr/hypridle.conf` |
| `fcitx5` | Input method framework | Omarchy default |
| `polkit-gnome` | Authentication agent | Omarchy default |
| `awww-daemon` | Wallpaper cycling | `config/hypr/autostart.lua` |
| `omarchy-bg-slideshow` | Wallpaper cycling | `config/hypr/autostart.lua` |
| `alacritty + tmux dev` | Dev terminal session | `config/hypr/autostart.lua` |
| `alacritty + nvim` | Editor terminal | `config/hypr/autostart.lua` |
| `cua-driver` | Computer-use daemon for AI agents | `~/.config/systemd/user/cua-driver.service` |

## Lock System

Omarchy Quattro draws the lock screen and screensaver itself, in Quickshell.
`hyprlock`, `swaync`, and `hyprpaper` are no longer part of the stack.

```
Super+Ctrl+L        ──→  omarchy-system-lock  ──→  quickshell lock view
hypridle (150s)     ──→  omarchy-launch-screensaver
hypridle (152s)     ──→  omarchy-system-lock
before_sleep        ──→  OMARCHY_LOCK_ONLY=true omarchy-system-lock
```

`omarchy-system-lock` also locks 1Password and stops the screensaver. Idle
durations live in `~/.config/omarchy/shell.json` (`idle.lock`,
`idle.screensaver`); `config/hypr/hypridle.conf` owns the suspend/wake path.

## Idle Timeouts (hypridle)

| Time | Action |
|------|--------|
| 150s (2.5min) | Start screensaver (`omarchy-launch-screensaver`) |
| 152s (~2.5min) | Lock screen (`omarchy-system-lock`) |

These two are deliberately near-identical: the screensaver resets the idle
timer, so a slightly longer second listener guarantees the lock fires even if
the screensaver came up first.

## File Layout

```
linux-workstation/
├── ARCHITECTURE.md              ← this file
├── README.md                    ← overview & install guide
├── MACHINES.md                  ← auto-generated machine inventory
├── install.sh                   ← symlink installer (DMI-aware)
├── bashrc                       ← shell aliases & config
├── tmux.conf
├── zshrc
│
├── lib/
│   ├── detect-machine.sh        ← DMI-based machine detection
│   ├── probe-hardware.sh        ← live JSON probe (monitors, input, GPU, distro)
│   ├── auto-generate.sh         ← writes machine configs from probe data
│   ├── error-log.sh             ← structured per-machine error tracking
│   └── generate-machines.sh     ← generates MACHINES.md
│
├── packages/
│   ├── install-packages.sh      ← auto-detect distro + install
│   └── arch/
│       ├── common.txt           ← base packages (all machines)
│       ├── HP_EliteBook_840_G3.txt
│       └── Apple_MacMini.txt
│
└── config/
    ├── alacritty/           ── terminal emulator
    ├── btop/                ── system monitor
    ├── fastfetch/           ── system info
    ├── ghostty/             ── terminal emulator
    ├── git/                 ── git configuration
    ├── hypr/                ── Hyprland window manager
    │   ├── hyprland.lua           ── entry point (requires the modules below)
    │   ├── autostart.lua          ── startup apps
    │   ├── bindings.lua           ── app keybindings
    │   ├── input.lua              ── keyboard & touchpad
    │   ├── looknfeel.lua          ── appearance overrides
    │   ├── monitors.lua           ── display setup
    │   ├── hypridle.conf          ── idle & suspend handling (daemon)
    │   ├── hyprsunset.conf        ── blue-light filter
    │   ├── xdph.conf              ── screen-sharing portal
    │   └── machine/               ── optional per-machine overrides (empty)
    ├── kitty/               ── terminal emulator
    ├── lazygit/             ── git TUI
    ├── opencode/            ── agent client config
    └── starship.toml        ── shell prompt
```

## Machine Detection

`lib/detect-machine.sh` reads DMI `product_name` from `/sys/class/dmi/id/product_name`,
sanitizes it (spaces → underscores), and outputs the machine slot name.
Falls back to `product_uuid`, then `unknown`.

| DMI product_name | Output slot |
|-----------------|-------------|
| `HP EliteBook 840 G3` | `HP_EliteBook_840_G3` |
| `Macmini5,1` | `Apple_MacMini` (mapped) |
| anything else | sanitized (non-alphanumeric → `_`) |

Any machine with a valid DMI `product_name` gets a valid slot — fully portable.

## Machine-Specific Config Overrides

Machine-specific configs live in `config/<app>/machine/<slot>/`. `install.sh`
links them in two passes:

1. **Shared pass** — links all files under `config/` except `machine/`
2. **Machine override pass** — links files from `config/<app>/machine/<MACHINE>/`,
   overwriting the shared symlinks with machine-specific versions

Example: on `HP_EliteBook_840_G3`, `config/hypr/machine/HP_EliteBook_840_G3/monitors.lua`
is linked to `~/.config/hypr/monitors.lua`, replacing the shared version.

Both slots are currently empty, so every machine uses the shared config. To add
overrides, run `./lib/auto-generate.sh <slot>` manually. `install.sh` does not
auto-generate, because a generated `monitors.lua` pins a specific output name
and would override the machine-neutral shared one (`output = ""`,
`mode = "preferred"`) that adapts to any display.

The full config priority order is:
1. **Omarchy defaults** (lowest) — `$OMARCHY_PATH/default/hypr/`
2. **Theme** — `~/.local/state/omarchy/current/theme/` (managed by `omarchy-theme-set`)
3. **Shared user overrides** — `~/.config/<app>/<file>` (this repo)
4. **Machine-specific overrides** (highest) — overwrites shared symlinks during install

Note on paths: Quattro moved the theme from `~/.config/omarchy/current` to
`~/.local/state/omarchy/current`, which this repo targets. Omarchy's own
install location moved too, so read it from `$OMARCHY_PATH` rather than
hardcoding a path — it is `~/.local/share/omarchy` on a git/dev checkout and
`/usr/share/omarchy` on a packaged install.

## Error Tracking

Per-machine errors are tracked in `config/<app>/machine/<slot>/errors.json` via
`lib/error-log.sh`. The `lib/generate-machines.sh` script reads these to produce
[MACHINES.md](MACHINES.md), showing per-slot status with open issue counts.

## Package Management

Package lists live in `packages/<distro>/`:
- `common.txt` — installed on every machine
- `<slot>.txt` — machine-specific extras

`packages/install-packages.sh` auto-detects distro, loads lists, and installs
via the appropriate package manager (`pacman` on Arch, `apt` on Ubuntu/Debian).

## Known Issues

### HP Laptop

#### i915 PSR Crash on Lock / Blur

**Symptom:** GPU hang/crash notification when the lock screen activates (blur rendering).

**Cause:** Intel Skylake HD Graphics 520 — Panel Self Refresh (PSR) fails to exit
cleanly when the compositor triggers GPU rendering with blur passes. PSR allows
the display to self-refresh while the GPU idles, but Skylake's PSR exit sequence
is timing-sensitive and can hang the GPU when a sudden render request arrives.

**Fix:** Disable PSR via kernel parameter `i915.enable_psr=0`. Set in the Limine
UKI cmdline at `/boot/limine.conf` (current boot entry, line 29).

**Verification:** Check `/proc/cmdline` — should contain `i915.enable_psr=0`.
Note: this taints the kernel ("dangerous option"), which is cosmetic and has no
functional impact.

**Note:** Old Limine snapshot entries (kernels 6.18.x) lack this parameter and
would reproduce the crash if booted.

### Apple Mac Mini

#### Omarchy PGP Key Missing on Fresh/Migrated Systems

**Scope:** This issue manifested on the **Apple Mac Mini** on 2026-06-05
during the first `sudo pacman -Syu` after a fresh Omarchy install, but could occur
on either machine if the omarchy signing key isn't present in the local keyring.

**Symptom:** `sudo pacman -Syu` fails with:
```
error: key "F0134EE680CAC571" could not be looked up remotely
error: required key missing from keyring
```

**Cause:** All packages from the `[omarchy]` repo are signed with PGP key
`40DFB630FF42BCFFB047046CF0134EE680CAC571` ("Unknown Packager"). When an upgrade
introduces packages signed with this key and it's not in your local keyring,
`pacman` tries to fetch it from a remote keyserver but the default keyservers
(`hkps://keys.gnupg.net`, `hkps://keyserver.ubuntu.com`, `hkps://keys.openpgp.org`)
may be unreachable from your network (keyserver protocol often blocked).

Note: The `[omarchy]` repo in `/etc/pacman.conf` uses `SigLevel = Optional TrustAll`,
so signatures aren't enforced at transaction time. However, `pacman` still requires
the signing key to be present in the local keyring during the `downloading required
keys...` phase — without it, the transaction is aborted before `SigLevel` is checked.

**Fix (applied 2026-06-05 to Apple Mac Mini):**
```bash
# Download the omarchy repo signing key directly via HTTPS
curl -sS "https://keys.openpgp.org/vks/v1/by-fingerprint/40DFB630FF42BCFFB047046CF0134EE680CAC571" \
  -o /tmp/omarchy-key.asc

# Import and trust the key
sudo pacman-key -a /tmp/omarchy-key.asc
sudo pacman-key --lsign-key 40DFB630FF42BCFFB047046CF0134EE680CAC571

# Upgrade succeeds
sudo pacman -Syu
```

HTTPS (port 443) works where the keyserver protocol fails because it uses
standard web traffic that networks rarely block.

**Prevention:** `omarchy-keyring` package (`omarchy-pkg-add omarchy-keyring`)
is supposed to handle this automatically in future versions.

**Key details:**
- Short ID: `F0134EE680CAC571`
- Full fingerprint: `40DFB630FF42BCFFB047046CF0134EE680CAC571`
- UID: `Omarchy <pkgs@omarchy.org>`

#### Wallpaper slideshow script missing

**Symptom:** `uwsm-app` error on Hyprland startup:
```
path /home/odonde/.local/bin/omarchy-bg-slideshow does not exist
```

**Scope:** All machines — the shared autostart config references
`omarchy-bg-slideshow` for wallpaper cycling.

**Cause:** The autostart config (`config/hypr/autostart.lua`) runs
`omarchy-bg-slideshow` at startup, but the script was never tracked in the repo
or deployed to `~/.local/bin/`.

**Fix:** The script is now at `bin/omarchy-bg-slideshow` in the repo.
Run `./install.sh` to create a symlink at `~/.local/bin/omarchy-bg-slideshow`.
Future `git pull` + `./install.sh` on any machine will deploy it automatically.

### Shared (both machines)

#### Hyprland 0.55 Config Breaking Changes

**Symptom:** Config errors on Hyprland startup:
- `Error parsing gradient -1: failed to parse -1 as a color` (lines 53–54)
- `config option <dwindle:pseudotile> does not exist` (line 111)

**Cause:** Hyprland 0.55 introduced two breaking changes that Omarchy's default
`looknfeel` config didn't account for:
1. `-1` removed as a "use default" color sentinel — gradient parser rejects it
2. `dwindle:pseudotile` option removed entirely (was a no-op)

**Fix applied 2026-05-27:**
- Lines 53–54: `col.border_locked_active/inactive = -1` → `$activeBorderColor` / `$inactiveBorderColor`
- Line 111: Removed `pseudotile = true`
- User override in `config/hypr/looknfeel.lua` adds a `group {}` block as a safety net

**Upstream tracking:**
- [omarchy#5870](https://github.com/basecamp/omarchy/issues/5870) — Config incompatibility with Hyprland 0.55
- [omarchy#5752](https://github.com/basecamp/omarchy/issues/5752) — Hyprland 0.55 config errors on startup
- [omarchy#5820](https://github.com/basecamp/omarchy/issues/5820) — Various 0.55.0 defaults breakage

## Verification

`./lib/check-deps.sh` walks `config/hypr/autostart.lua` plus Omarchy's own
default autostart, extracts every `o.launch(...)` / `o.launch_on_start(...)`
command, and confirms each binary exists. It also reads the `XCURSOR_THEME`
declared in `config/hypr/input.lua` and checks the theme is installed. Both
parsers understand the Quattro Lua form, not the old hyprlang `.conf` syntax.

For Hyprland itself:

```bash
hyprctl reload && hyprctl configerrors   # must be empty
```

**Note:** Omarchy's upstream defaults are no longer snapshotted in this repo.
Read them from `$OMARCHY_PATH/default/hypr/` instead — a copied snapshot that has
diverged from upstream is worse than none, because it silently stops describing
what actually runs.
