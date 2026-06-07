#!/bin/bash
# Probe hardware config from live system.
# Outputs JSON for use by auto-generate.sh and install.sh
# Usage: ./lib/probe-hardware.sh

set -euo pipefail

probe_monitors() {
    if command -v hyprctl &>/dev/null; then
        hyprctl monitors -j 2>/dev/null || echo "[]"
    else
        echo "[]"
    fi
}

probe_input() {
    if command -v hyprctl &>/dev/null; then
        hyprctl devices -j 2>/dev/null || echo "{}"
    else
        echo "{}"
    fi
}

probe_gpu() {
    if command -v lspci &>/dev/null; then
        lspci 2>/dev/null | grep -i "vga\|3d\|display" | head -5 || echo "unknown"
    else
        echo "unknown"
    fi
}

probe_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "${ID:-linux}"
    else
        echo "linux"
    fi
}

# Build safe JSON with jq
if command -v jq &>/dev/null; then
    DISTRO=$(probe_distro)
    GPU=$(probe_gpu)
    MONITORS=$(probe_monitors)
    INPUT=$(probe_input)
    jq -n \
        --arg distro "$DISTRO" \
        --arg gpu "$GPU" \
        --argjson monitors "$MONITORS" \
        --argjson input "$INPUT" \
        '{distro: $distro, gpu: $gpu, monitors: $monitors, input: $input}'
else
    # Fallback: python with env vars
    export PD_DISTRO=$(probe_distro)
    export PD_GPU=$(probe_gpu)
    export PD_MONITORS=$(probe_monitors)
    export PD_INPUT=$(probe_input)
    python3 -c '
import os, json
print(json.dumps({
    "distro": os.environ["PD_DISTRO"],
    "gpu": os.environ["PD_GPU"],
    "monitors": json.loads(os.environ["PD_MONITORS"]),
    "input": json.loads(os.environ["PD_INPUT"])
}))
'
fi
