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

OMARCHY_PATH="${OMARCHY_PATH:-$HOME/.local/share/omarchy}"

KNOWN_PACKAGES=(
  "awww-daemon:awww"
  "hypridle:hypridle"
  "swaync:swaync"
  "fcitx5:fcitx5"
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
  # Always succeed: callers use this in a command substitution, where a
  # non-zero status would trip `set -e` and abort the whole check silently.
  return 0
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
    # Quattro Lua form: hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
    if [[ $trimmed =~ hl\.env\(\"XCURSOR_THEME\",\ *\"([^\"]+)\" ]]; then
      theme="${BASH_REMATCH[1]}"
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

# Quattro autostart is Lua: commands appear inside o.launch_on_start("...")
# or o.launch("...") / hl.exec_cmd(o.launch(...)) calls.
check_autostart() {
  local autostart_file="$1"
  local label="$2"

  if [ ! -f "$autostart_file" ]; then
    return
  fi

  while IFS= read -r line; do
    trimmed="${line## }"
    [[ $trimmed == '#'* ]] && continue
    raw=$(printf '%s\n' "$line" \
      | { grep -oE 'o\.launch(_on_start)?\("[^"]*"' || true; } \
      | { grep -oE '"[^"]*"' || true; } \
      | tr -d '"')
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

check_autostart "$REPO_DIR/config/hypr/autostart.lua" "config/hypr/autostart.lua"
check_autostart "$OMARCHY_PATH/default/hypr/autostart.lua" "omarchy default autostart"

$QUIET || echo ""
$QUIET || echo "--- Checking cursor themes ---"
for f in "$REPO_DIR/config/hypr/input.lua" \
         "$OMARCHY_PATH/default/hypr/envs.lua"; do
  check_cursor_theme "$f" "${f#$REPO_DIR/}"
done

if $MISSING; then
  $QUIET || echo ""
  $QUIET || echo "  → Run ./packages/install-packages.sh to install missing packages"
  $QUIET || echo "  → Or install individually with sudo pacman -S <package>"
  exit 1
fi

$QUIET || echo "  ✓ All commands found"
