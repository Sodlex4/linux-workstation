#!/bin/bash
# Install packages for the current machine/distro.
# Reads package lists from packages/<distro>/ directory.
# Usage: ./packages/install-packages.sh [--dry-run]

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DRY_RUN=false

if [ "${1:-}" = "--dry-run" ]; then
    DRY_RUN=true
fi

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "${ID}"
    else
        echo "unknown"
    fi
}

MACHINE=$(bash "$REPO_DIR/lib/detect-machine.sh")
DISTRO=$(detect_distro)

echo "==> Machine: $MACHINE"
echo "==> Distro:  $DISTRO"

PKG_DIR="$REPO_DIR/packages/$DISTRO"

if [ ! -d "$PKG_DIR" ]; then
    echo "!! No package lists for distro '$DISTRO'"
    echo "!! Create package files in: packages/$DISTRO/"
    echo "   - common.txt (always installed)"
    echo "   - <machine_slot>.txt (machine-specific)"
    exit 1
fi

PACKAGES=()

load_list() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "  → Reading: $(basename "$file")"
        while IFS= read -r line; do
            line="${line%%#*}"
            line="${line## }"
            line="${line%% }"
            [ -z "$line" ] && continue
            PACKAGES+=("$line")
        done < "$file"
    fi
}

echo ""
echo "--- Loading package lists ---"
load_list "$PKG_DIR/common.txt"

machine_list="$PKG_DIR/${MACHINE}.txt"
if [ "$MACHINE" != "unknown" ] && [ -f "$machine_list" ]; then
    load_list "$machine_list"
else
    echo "  ~ No machine-specific list for $MACHINE"
fi

echo ""
echo "--- Package summary ---"
printf '%s\n' "${PACKAGES[@]}" | sort -u
echo "--- Total: ${#PACKAGES[@]} packages ---"

if [ "${#PACKAGES[@]}" -eq 0 ]; then
    echo "==> No packages to install."
    exit 0
fi

if [ "$DRY_RUN" = true ]; then
    echo ""
    echo "==> Dry run — no changes made."
    exit 0
fi

echo ""
echo "==> Proceed with installation? (y/N)"
read -r confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "==> Aborted."
    exit 0
fi

check_command() {
    if ! command -v "$1" &>/dev/null; then
        echo "!! Required command not found: $1"
        exit 1
    fi
}

install_arch() {
    check_command pacman
    echo "==> Installing with pacman..."
    sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
}

install_ubuntu() {
    check_command apt
    echo "==> Installing with apt..."
    sudo apt update
    sudo apt install -y "${PACKAGES[@]}"
}

case "$DISTRO" in
    arch) install_arch ;;
    ubuntu|debian|pop|linuxmint|elementary) install_ubuntu ;;
    *)
        echo "!! Unsupported distro: $DISTRO"
        echo "!! Install manually from these lists:"
        printf '   %s\n' "${PACKAGES[@]}"
        exit 1
        ;;
esac

echo "==> Done."
