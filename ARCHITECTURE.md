# Architecture

## Machines

This repo covers two machines. Both run Arch Linux + Omarchy. The HP laptop uses
hostname `omarchy` (Omarchy default), while the Mac Mini uses `apple-mac-mini`. They are differentiated by hardware:

| Machine | Vendor | Model | Role |
|---------|--------|-------|------|
| HP Laptop | Hewlett-Packard | HP EliteBook 840 G3 | Primary workstation |
| Apple Mac Mini | Apple Inc. | Macmini5,1 | Secondary machine |

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

| Service | Role |
|---------|------|
| `hypridle` | Idle daemon — manages screensaver, lock, display power |
| `mako` | Notification daemon |
| `waybar` | Status bar |
| `fcitx5` | Input method framework |
| `swayosd-server` | On-screen display (volume, brightness) |
| `polkit-gnome` | Authentication agent |
| `awww-daemon` | Wallpaper daemon |
| `omarchy-bg-slideshow` | Wallpaper cycling |

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
├── ARCHITECTURE.md          ← this file
├── README.md                ← overview & install guide
├── install.sh               ← symlink installer
├── lib/
│   └── detect-machine.sh    ← DMI-based machine detection
├── bashrc                   ← shell aliases & config
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
    │   │   ├── hp/
    │   │   │   ├── autostart.conf ── startup apps (HP)
    │   │   │   ├── input.conf     ── input devices (HP)
    │   │   │   └── monitors.conf  ── display setup (HP)
    │   │   └── macmini/
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

Machine detection is handled by `lib/detect-machine.sh`, which reads DMI info
from `/sys/class/dmi/id/product_name` and `sys_vendor`, falling back to
`hostnamectl`. Checks product name first, then vendor:

| Detection Source | Match | Output |
|-----------------|-------|--------|
| `product_name` | `HP EliteBook` | `hp` |
| `product_name` | `Macmini` | `macmini` |
| `sys_vendor` | `Apple Inc.` | `macmini` |
| `sys_vendor` | `HP` / `Hewlett-Packard` | `hp` |
| anything else | — | `unknown` |

## Machine-Specific Config Overrides

Machine-specific configs live in `config/<app>/machine/<name>/`. `install.sh`
links them in two passes:

1. **Shared pass** — links all files under `config/` except `machine/` and
   `omarchy-defaults/`
2. **Machine override pass** — links files from `config/<app>/machine/<MACHINE>/`,
   overwriting the shared symlinks with machine-specific versions

Example: On Mac Mini, `config/hypr/machine/macmini/monitors.conf` is linked to
`~/.config/hypr/monitors.conf`, replacing the shared `monitors.conf` symlink.

The full config priority order is:
1. **Omarchy defaults** (lowest) — `~/.local/share/omarchy/default/`
2. **Theme** — `~/.config/omarchy/current/theme/` (managed by `omarchy-theme-set`)
3. **Shared user overrides** — `~/.config/<app>/<file>` (this repo)
4. **Machine-specific overrides** (highest) — overwrites shared symlinks during install

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
