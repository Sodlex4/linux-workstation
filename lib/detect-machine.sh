#!/bin/bash
# Detect which machine this is based on DMI info.
# Outputs: macmini, hp, or unknown

set -euo pipefail

detect_machine() {
    if [ -f /sys/class/dmi/id/sys_vendor ]; then
        local vendor
        vendor=$(cat /sys/class/dmi/id/sys_vendor)
        case "$vendor" in
            *Apple*)   echo "macmini"; return 0 ;;
            *HP*|*Hewlett-Packard*) echo "hp"; return 0 ;;
        esac
    fi

    if command -v hostnamectl &>/dev/null; then
        local hw_model
        hw_model=$(hostnamectl 2>/dev/null | grep -F "Hardware Model")
        case "$hw_model" in
            *Macmini*) echo "macmini"; return 0 ;;
            *HP*)      echo "hp"; return 0 ;;
        esac
    fi

    echo "unknown"
    return 1
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    detect_machine
fi
