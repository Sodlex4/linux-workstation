#!/bin/bash
# Detect which machine this is based on DMI hardware info.
# Returns the sanitized DMI product_name (e.g. "HP_EliteBook_840_G3")
# Falls back to product_uuid if product_name is unavailable.
# Last resort: "unknown"

set -euo pipefail

# Static mapping: DMI product_name → canonical slot name
declare -A MACHINE_MAP
MACHINE_MAP["HP EliteBook 840 G3"]="HP_EliteBook_840_G3"
MACHINE_MAP["Macmini5,1"]="Apple_MacMini"
MACHINE_MAP["Macmini6,1"]="Apple_MacMini"
MACHINE_MAP["Macmini6,2"]="Apple_MacMini"
MACHINE_MAP["Macmini7,1"]="Apple_MacMini"
MACHINE_MAP["Macmini8,1"]="Apple_MacMini"
MACHINE_MAP["Macmini9,1"]="Apple_MacMini"
MACHINE_MAP["Macmini"]="Apple_MacMini"

sanitize() {
    local raw="$1"
    # Check static map first
    if [ -n "${MACHINE_MAP[$raw]:-}" ]; then
        echo "${MACHINE_MAP[$raw]}"
        return 0
    fi
    # Fall back to sanitizing: replace any non-alphanumeric, non-hyphen char with underscore
    echo "$raw" | sed 's/[^a-zA-Z0-9-]/_/g'
}

detect_machine() {
    local product uuid

    product=$(cat /sys/class/dmi/id/product_name 2>/dev/null | tr -d '\0' | xargs || true)
    if [ -n "$product" ]; then
        sanitize "$product"
        return 0
    fi

    uuid=$(cat /sys/class/dmi/id/product_uuid 2>/dev/null | tr -d '\0' | xargs || true)
    if [ -n "$uuid" ]; then
        echo "unknown-${uuid}"
        return 1
    fi

    echo "unknown"
    return 1
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    detect_machine
fi
