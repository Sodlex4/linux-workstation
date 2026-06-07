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

Hyprland reads `~/.config/hypr/hyprland.conf`, which layers configuration from three sources:

```
┌──────────────────────────────────────────────────┐
│ 1. Omarchy Defaults (~/.local/share/omarchy/)   │
│    envs.conf, input.conf, windows.conf           │
│    looknfeel.conf, autostart.conf                │
│    bindings/ (media, clipboard, tiling, utils)   │
├──────────────────────────────────────────────────┤
│ 2. Theme (~/.config/omarchy/current/theme/)      │
│    Colors, backgrounds, hyprlock theme           │
├──────────────────────────────────────────────────┤
│ 3. User Overrides (~/.config/hypr/)              │
│    monitors.conf, input.conf, bindings.conf      │
│    looknfeel.conf, autostart.conf                │
└──────────────────────────────────────────────────┘
```

### Service Autostart (in order)

After Hyprland initializes, the following start via `exec-once`:

| Service | Role | Source |
|---------|------|--------|
| `hypridle` | Idle daemon — screensaver, lock, DPMS | Omarchy default |
| `swaync` | Notification daemon | Omarchy default |
| `waybar` | Status bar | Omarchy default |
| `fcitx5` | Input method framework | Omarchy default |
| `swayosd-server` | On-screen display (volume, brightness) | Omarchy default |
| `polkit-gnome` | Authentication agent | Omarchy default |
| `awww-daemon` | Wallpaper daemon | Omarchy default |
| `omarchy-bg-slideshow` | Wallpaper cycling | Omarchy default |

## Lock System

```
Super+Ctrl+L  ──→  omarchy-lock-screen  ──→  hyprlock
                    ├── Resets keyboard layout
                    ├── Locks 1Password
                    └── Stops screensaver

hypridle (151s)  ──→  loginctl lock-session  ──→  hyprlock
hypridle (330s)  ──→  display off (dpms)
```

`hyprlock` reads `~/.config/hypr/hyprlock.conf` which imports theme colors from Omarchy.

## Idle Timeouts (hypridle)

| Time | Action |
|------|--------|
| 150s (2.5min) | Start screensaver |
| 151s (5min) | Lock screen |
| 330s (5.5min) | Keyboard backlight off |
| 330s (5.5min) | Display off (DPMS) |

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
    │   ├── autostart.conf         ── startup apps (shared fallback)
    │   ├── bindings.conf          ── app keybindings (shared)
    │   ├── hypridle.conf          ── idle management
    │   ├── hyprlock.conf          ── lock screen
    │   ├── input.conf             ── input devices (shared fallback)
    │   ├── looknfeel.conf         ── appearance overrides
    │   ├── monitors.conf          ── display setup (shared fallback)
    │   ├── machine/
    │   │   ├── HP_EliteBook_840_G3/
    │   │   │   ├── autostart.conf ── startup apps (HP)
    │   │   │   ├── input.conf     ── input devices (HP)
    │   │   │   └── monitors.conf  ── display setup (HP)
    │   │   └── Apple_MacMini/
    │   │       ├── autostart.conf ── startup apps (Mac Mini)
    │   │       ├── input.conf     ── input devices (Mac Mini)
    │   │       └── monitors.conf  ── display setup (Mac Mini)
    │   └── omarchy-defaults/     ── Omarchy upstream configs
    ├── kitty/               ── terminal emulator
    ├── swayosd/             ── on-screen display
    ├── walker/              ── app launcher
    ├── waybar/              ── status bar
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

1. **Shared pass** — links all files under `config/` except `machine/` and
   `omarchy-defaults/`
2. **Machine override pass** — links files from `config/<app>/machine/<MACHINE>/`,
   overwriting the shared symlinks with machine-specific versions

Example: On `HP_EliteBook_840_G3`, `config/hypr/machine/HP_EliteBook_840_G3/monitors.conf`
is linked to `~/.config/hypr/monitors.conf`, replacing the shared fallback.

For unknown machines, `install.sh` runs `auto-generate.sh` which probes hardware
with `probe-hardware.sh` and writes `monitors.conf`, `input.conf`, `autostart.conf`.

The full config priority order is:
1. **Omarchy defaults** (lowest) — `~/.local/share/omarchy/default/`
2. **Theme** — `~/.config/omarchy/current/theme/` (managed by `omarchy-theme-set`)
3. **Shared user overrides** — `~/.config/<app>/<file>` (this repo)
4. **Machine-specific overrides** (highest) — overwrites shared symlinks during install

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

#### i915 PSR Crash with hyprlock

**Symptom:** GPU hang/crash notification when hyprlock activates (blur rendering).

**Cause:** Intel Skylake HD Graphics 520 — Panel Self Refresh (PSR) fails to exit
cleanly when hyprlock triggers GPU rendering with blur passes (`blur_passes = 1` in
`hyprlock.conf`). PSR allows the display to self-refresh while the GPU idles, but
Skylake's PSR exit sequence is timing-sensitive and can hang the GPU when a sudden
render request arrives (e.g. hyprlock fade-in with blur).

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

**Scope:** All machines — both the HP and Mac Mini autostart configs reference
`omarchy-bg-slideshow` for wallpaper cycling.

**Cause:** The autostart config (`config/hypr/machine/<slot>/autostart.conf`) runs
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
`looknfeel.conf` didn't account for:
1. `-1` removed as a "use default" color sentinel — gradient parser rejects it
2. `dwindle:pseudotile` option removed entirely (was a no-op)

**Fix applied 2026-05-27:**
- Lines 53–54: `col.border_locked_active/inactive = -1` → `$activeBorderColor` / `$inactiveBorderColor`
- Line 111: Removed `pseudotile = true`
- User override in `~/.config/hypr/looknfeel.conf` adds a `group {}` block as a safety net

**Upstream tracking:**
- [omarchy#5870](https://github.com/basecamp/omarchy/issues/5870) — Config incompatibility with Hyprland 0.55
- [omarchy#5752](https://github.com/basecamp/omarchy/issues/5752) — Hyprland 0.55 config errors on startup
- [omarchy#5820](https://github.com/basecamp/omarchy/issues/5820) — Various 0.55.0 defaults breakage

**Warning:** The default file at `~/.local/share/omarchy/default/hypr/looknfeel.conf` is
now a symlink tracked by this repo (`config/hypr/omarchy-defaults/looknfeel.conf`).
`omarchy-update` may warn about the non-regular file but will not overwrite it.
