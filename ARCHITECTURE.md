# Architecture

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
├── bashrc                   ← shell aliases & config
│
└── config/
    ├── alacritty/           ── terminal emulator
    ├── btop/                ── system monitor
    ├── fastfetch/           ── system info
    ├── ghostty/             ── terminal emulator
    ├── git/                 ── git configuration
    ├── hypr/                ── Hyprland window manager
    │   ├── autostart.conf   ── startup apps (user)
    │   ├── bindings.conf    ── app keybindings (user)
    │   ├── hypridle.conf    ── idle management
    │   ├── hyprlock.conf    ── lock screen
    │   ├── input.conf       ── input devices (user)
    │   ├── looknfeel.conf   ── appearance overrides
    │   ├── monitors.conf    ── display setup
    │   └── omarchy-defaults/  ── Omarchy upstream configs
    ├── kitty/               ── terminal emulator
    ├── swayosd/             ── on-screen display
    ├── walker/              ── app launcher
    ├── waybar/              ── status bar
    └── starship.toml        ── shell prompt
```

## Configuration Layering

Omarchy manages its own defaults in `~/.local/share/omarchy/`. This repo tracks only **user overrides** in `~/.config/`. The priority order is:

1. **Omarchy defaults** (lowest priority) — in `~/.local/share/omarchy/default/`
2. **Theme** — in `~/.config/omarchy/current/theme/` (managed by `omarchy-theme-set`)
3. **User overrides** (highest priority) — in `~/.config/<app>/` (this repo)

## Known Issues

### i915 PSR Crash with hyprlock

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
