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

# Output as JSON
echo "{"
echo "  \"distro\": \"$(probe_distro)\","
echo "  \"gpu\": \"$(probe_gpu | sed 's/"/\\"/g')\","
echo "  \"monitors\": $(probe_monitors),"
echo "  \"input\": $(probe_input)"
echo "}"
