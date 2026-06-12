#!/bin/bash
# Check that commands referenced by this machine's configs are available.
# Usage: ./lib/check-deps.sh [--quiet]

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MACHINE=$(bash "$REPO_DIR/lib/detect-machine.sh")
QUIET=false

if [ "${1:-}" = "--quiet" ]; then
  QUIET=true
fi

KNOWN_PACKAGES=(
  "awww-daemon:awww"
  "hypridle:hypridle"
  "hyprlock:hyprlock"
  "waybar:waybar"
  "mako:mako"
  "swaync:swaync"
  "fcitx5:fcitx5"
  "swaybg:swaybg"
  "swayosd-server:swayosd"
  "polkit-gnome-authentication-agent-1:polkit-gnome"
  "walker:walker"
  "kitty:kitty"
  "alacritty:alacritty"
  "ghostty:ghostty"
  "starship:starship"
  "btop:btop"
  "fastfetch:fastfetch"
  "lazygit:lazygit"
  "tmux:tmux"
  "nvim:neovim"
  "pipewire:pipewire"
  "wireplumber:wireplumber"
  "pavucontrol:pavucontrol"
  "brightnessctl:brightnessctl"
  "playerctl:playerctl"
  "grim:grim"
  "slurp:slurp"
  "cliphist:cliphist"
  "wl-clipboard:wl-clipboard"
  "jq:jq"
)

command_to_package() {
  local cmd="$1"
  for entry in "${KNOWN_PACKAGES[@]}"; do
    if [[ $entry == "$cmd:"* ]]; then
      echo "${entry#*:}"
      return 0
    fi
  done
  return 1
}

MISSING=false

check_cursor_theme() {
  local theme_file="$1"
  local label="$2"
  local theme

  if [ ! -f "$theme_file" ]; then
    return
  fi

  while IFS= read -r line; do
    trimmed="${line## }"
    [[ $trimmed == '#'* ]] && continue
    if [[ $trimmed == env\ =\ XCURSOR_THEME,* ]]; then
      theme="${trimmed#env = XCURSOR_THEME,}"
      theme="${theme%%#*}"
      theme="${theme## }"
      theme="${theme%% }"
      [ -z "$theme" ] && continue
      if [ ! -d "/usr/share/icons/$theme" ] && [ ! -d "$HOME/.local/share/icons/$theme" ] && [ ! -d "$HOME/.icons/$theme" ]; then
        $QUIET || echo "  ⚠ Cursor theme not installed: $theme"
        $QUIET || echo "    Install: sudo pacman -S ${theme,,}  (or AUR: yay -S ${theme,,})"
        $QUIET || echo "    Referenced in: $label"
        MISSING=true
      fi
    fi
  done < "$theme_file"
}

check_autostart() {
  local autostart_file="$1"
  local label="$2"

  if [ ! -f "$autostart_file" ]; then
    return
  fi

  while IFS= read -r line; do
    trimmed="${line## }"
    [[ $trimmed == '#'* ]] && continue
    raw=$(echo "$line" | sed -n 's/.*uwsm-app -- //p')
    [ -z "$raw" ] && continue
    raw="${raw%%#*}"
    raw="${raw## }"
    raw="${raw%% }"
    [ -z "$raw" ] && continue

    cmd="${raw%% *}"
    if [[ $raw == \$HOME* ]]; then
      eval "resolved=$raw"
      if [ ! -f "$resolved" ] && [ ! -x "$resolved" ]; then
        $QUIET || echo "  ⚠ Script not found: $resolved"
        $QUIET || echo "    Referenced in: $label"
        MISSING=true
      fi
      continue
    fi

    if ! command -v "$cmd" &>/dev/null; then
      pkg=$(command_to_package "$cmd")
      if [ -n "$pkg" ]; then
        $QUIET || echo "  ⚠ Command not found: $cmd (package: $pkg)"
        $QUIET || echo "    Install: sudo pacman -S $pkg"
      else
        $QUIET || echo "  ⚠ Command not found: $cmd"
        $QUIET || echo "    Install the package providing '$cmd'"
      fi
      $QUIET || echo "    Referenced in: $label"
      MISSING=true
    fi
  done < "$autostart_file"
}

$QUIET || echo "--- Checking dependencies for $MACHINE ---"

autostart_file="$REPO_DIR/config/hypr/machine/$MACHINE/autostart.conf"
if [ -f "$autostart_file" ]; then
  check_autostart "$autostart_file" "config/hypr/machine/$MACHINE/autostart.conf"
fi

autostart_file="$REPO_DIR/config/hypr/autostart.conf"
if [ -f "$autostart_file" ]; then
  check_autostart "$autostart_file" "config/hypr/autostart.conf"
fi

omarchy_default="$HOME/.local/share/omarchy/default/hypr/autostart.conf"
if [ -f "$omarchy_default" ]; then
  check_autostart "$omarchy_default" "omarchy default autostart"
fi

$QUIET || echo ""
$QUIET || echo "--- Checking cursor themes ---"
for f in "$REPO_DIR/config/hypr/machine/$MACHINE/input.conf" \
         "$REPO_DIR/config/hypr/input.conf" \
         "$REPO_DIR/config/hypr/omarchy-defaults/envs.conf" \
         "$HOME/.local/share/omarchy/default/hypr/envs.conf"; do
  check_cursor_theme "$f" "${f#$REPO_DIR/}"
done

if $MISSING; then
  $QUIET || echo ""
  $QUIET || echo "  → Run ./packages/install-packages.sh to install missing packages"
  $QUIET || echo "  → Or install individually with sudo pacman -S <package>"
  exit 1
fi

$QUIET || echo "  ✓ All commands found"
