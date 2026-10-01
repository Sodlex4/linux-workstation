#!/bin/bash
# Auto-generate machine-specific configs from hardware probe data.
# Usage: ./lib/auto-generate.sh <machine_slot>
# Example: ./lib/auto-generate.sh HP_EliteBook_840_G3

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MACHINE="${1:-unknown}"

if [ "$MACHINE" = "unknown" ]; then
    echo "Error: No machine slot specified"
    exit 1
fi

MACHINE_DIR="$REPO_DIR/config/hypr/machine/$MACHINE"
mkdir -p "$MACHINE_DIR"

PROBE=$(bash "$REPO_DIR/lib/probe-hardware.sh")

generate_monitors_conf() {
    local file="$MACHINE_DIR/monitors.lua"
    if [ -f "$file" ]; then
        echo "  ✓ monitors.lua already exists — skipping"
        return
    fi

    local monitors
    monitors=$(echo "$PROBE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
mons = data.get('monitors', [])
if not mons:
    print('empty')
    sys.exit(0)
for m in mons:
    name = m.get('name', '')
    w = m.get('width', 1920)
    h = m.get('height', 1080)
    rate = m.get('refreshRate', 60)
    scale = m.get('scale', 1.0)
    print(f'{name} {w}x{h}@{rate} scale{scale}')
" 2>/dev/null || echo "empty")

    if [ "$monitors" = "empty" ]; then
        cat > "$file" << 'MONITOR_EOF'
-- Auto-generated monitor config — no monitors detected during probe.
-- Edit or re-run install.sh after connecting displays.

hl.env("GDK_SCALE", "1")
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
MONITOR_EOF
    else
        cat > "$file" << MONITOR_EOF
-- Auto-generated from hardware probe

hl.env("GDK_SCALE", "1")
$(echo "$monitors" | while read -r line; do
    name=$(echo "$line" | awk '{print $1}')
    res=$(echo "$line" | awk '{print $2}')
    echo "hl.monitor({ output = \"$name\", mode = \"${res}\", position = \"auto\", scale = 1 })"
done)
MONITOR_EOF
    fi
    echo "  → Created monitors.lua"
}

generate_input_conf() {
    local file="$MACHINE_DIR/input.lua"
    if [ -f "$file" ]; then
        echo "  ✓ input.lua already exists — skipping"
        return
    fi

    local has_touchpad
    has_touchpad=$(echo "$PROBE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
devices = data.get('input') or {}
mice = devices.get('mice') or [] if isinstance(devices, dict) else []
if any('touchpad' in (m.get('name') or '').lower() for m in mice):
    print('yes')
else:
    print('no')
" 2>/dev/null || echo "no")

    if [ "$has_touchpad" = "yes" ]; then
        cat > "$file" << 'INPUT_EOF'
-- Auto-generated input config (touchpad detected)

hl.config({
  input = {
    kb_layout = "us",
    repeat_rate = 40,
    repeat_delay = 600,
    numlock_by_default = true,
    touchpad = {
      natural_scroll = true,
      clickfinger_behavior = true,
      scroll_factor = 0.4,
    },
  },
})
INPUT_EOF
    else
        cat > "$file" << 'INPUT_EOF'
-- Auto-generated input config (no touchpad detected)

hl.config({
  input = {
    kb_layout = "us",
    repeat_rate = 40,
    repeat_delay = 600,
    numlock_by_default = true,
  },
})
INPUT_EOF
    fi
    echo "  → Created input.lua"
}

generate_autostart_conf() {
    local file="$MACHINE_DIR/autostart.lua"
    if [ -f "$file" ]; then
        echo "  ✓ autostart.lua already exists — skipping"
        return
    fi

    cat > "$file" << 'AUTOSTART_EOF'
-- Auto-generated autostart config

o.launch_on_start("awww-daemon")
AUTOSTART_EOF
    echo "  → Created autostart.lua"
}

echo "==> Auto-generating configs for: $MACHINE"
generate_monitors_conf
generate_input_conf
generate_autostart_conf
echo "==> Done — machine configs at: config/hypr/machine/$MACHINE/"
