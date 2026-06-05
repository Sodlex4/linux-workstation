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
    local file="$MACHINE_DIR/monitors.conf"
    if [ -f "$file" ]; then
        echo "  ✓ monitors.conf already exists — skipping"
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
# Auto-generated monitor config — no monitors detected during probe.
# Edit or re-run install.sh after connecting displays.
# Syntax: monitor=<name>,<resolution>@<refresh>,<position>,<scale>

env = GDK_SCALE,1
monitor=,preferred,auto,1
MONITOR_EOF
    else
        cat > "$file" << MONITOR_EOF
# Auto-generated from hardware probe
env = GDK_SCALE,1
$(echo "$monitors" | while read -r line; do
    name=$(echo "$line" | awk '{print $1}')
    res=$(echo "$line" | awk '{print $2}')
    echo "monitor=$name,${res},auto,1"
done)
MONITOR_EOF
    fi
    echo "  → Created monitors.conf"
}

generate_input_conf() {
    local file="$MACHINE_DIR/input.conf"
    if [ -f "$file" ]; then
        echo "  ✓ input.conf already exists — skipping"
        return
    fi

    local has_touchpad
    has_touchpad=$(echo "$PROBE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
devices = data.get('input', {})
touchpads = devices.get('touchpads', [])
if touchpads:
    print('yes')
else:
    print('no')
" 2>/dev/null || echo "no")

    if [ "$has_touchpad" = "yes" ]; then
        cat > "$file" << 'INPUT_EOF'
# Auto-generated input config (touchpad detected)
input {
    kb_layout = us
    repeat_rate = 40
    repeat_delay = 600
    numlock_by_default = true
    touchpad {
        natural_scroll = true
        clickfinger_behavior = true
        scroll_factor = 0.4
    }
}
INPUT_EOF
    else
        cat > "$file" << 'INPUT_EOF'
# Auto-generated input config (no touchpad detected)
input {
    kb_layout = us
    repeat_rate = 40
    repeat_delay = 600
    numlock_by_default = true
}
INPUT_EOF
    fi
    echo "  → Created input.conf"
}

generate_autostart_conf() {
    local file="$MACHINE_DIR/autostart.conf"
    if [ -f "$file" ]; then
        echo "  ✓ autostart.conf already exists — skipping"
        return
    fi

    cat > "$file" << 'AUTOSTART_EOF'
# Auto-generated autostart config
exec-once = uwsm-app -- awww-daemon
AUTOSTART_EOF
    echo "  → Created autostart.conf"
}

echo "==> Auto-generating configs for: $MACHINE"
generate_monitors_conf
generate_input_conf
generate_autostart_conf
echo "==> Done — machine configs at: config/hypr/machine/$MACHINE/"
