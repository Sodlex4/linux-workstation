#!/bin/bash
# Detect which machine this is based on DMI hardware info.
# Returns the sanitized DMI product_name (e.g. "HP_EliteBook_840_G3")
# Falls back to product_uuid if product_name is unavailable.
# Last resort: "unknown"

set -euo pipefail

detect_machine() {
    local product uuid

    # Primary: DMI product_name (most specific, never changes)
    product=$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)
    if [ -n "$product" ]; then
        echo "$product" | sed 's/ /_/g'
        return 0
    fi

    # Fallback: DMI product_uuid (unique per motherboard)
    uuid=$(cat /sys/class/dmi/id/product_uuid 2>/dev/null || true)
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
