#!/bin/bash
# Detect which machine this is based on DMI hardware info.
# Both machines share hostname "omarchy", so we differentiate by hardware.
# Returns: "hp", "macmini", or "unknown"

set -euo pipefail

detect_machine() {
    local product vendor hw_model

    product=$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)
    vendor=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || true)

    # Check product name first (most specific)
    if grep -qi "HP EliteBook" <<< "$product" 2>/dev/null; then
        echo "hp"; return 0
    fi
    if grep -qi "Macmini" <<< "$product" 2>/dev/null; then
        echo "macmini"; return 0
    fi

    # Fall back to vendor
    if grep -qi "Apple" <<< "$vendor" 2>/dev/null; then
        echo "macmini"; return 0
    fi
    if grep -qi "HP\|Hewlett-Packard" <<< "$vendor" 2>/dev/null; then
        echo "hp"; return 0
    fi

    # Final fallback via hostnamectl
    if command -v hostnamectl &>/dev/null; then
        hw_model=$(hostnamectl 2>/dev/null | grep -F "Hardware Model" || true)
        if grep -qi "Macmini" <<< "$hw_model" 2>/dev/null; then
            echo "macmini"; return 0
        fi
        if grep -qi "HP" <<< "$hw_model" 2>/dev/null; then
            echo "hp"; return 0
        fi
    fi

    echo "unknown"
    return 1
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    detect_machine
fi
