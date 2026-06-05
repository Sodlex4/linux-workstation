#!/bin/bash
# Symlink dotfiles from this repo to ~/.config/ and ~/
# Auto-detects machine via DMI and applies machine-specific configs.
# Auto-generates configs for unrecognized machines.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.config/dotfiles-backup-$(date +%s)"

MACHINE=$(bash "$REPO_DIR/lib/detect-machine.sh")
echo "==> Detected machine: $MACHINE"

check_stale_symlinks() {
    local found=0
    while IFS= read -r -d '' link; do
        if [ -L "$link" ] && [ ! -e "$link" ]; then
            target=$(readlink "$link")
            echo "  ⚠ Stale symlink: $link → $target"
            found=$((found + 1))
        fi
    done < <(find "$HOME/.config" -type l -print0 2>/dev/null || true)
    if [ $found -gt 0 ]; then
        echo "  → install.sh will re-link these to the correct paths."
    fi
}

check_stale_symlinks

if [ "$MACHINE" = "unknown" ]; then
    echo "==> Machine not recognized. Probing hardware..."
    bash "$REPO_DIR/lib/probe-hardware.sh"
    echo "==> Run ./lib/auto-generate.sh <slot_name> to create configs"
    echo "==> Or edit lib/detect-machine.sh to add your machine"
fi

link_config() {
    local src="$1"
    local rel="${src#$REPO_DIR/config/}"
    local target="$HOME/.config/$rel"
    local target_dir="$(dirname "$target")"

    mkdir -p "$target_dir"

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
        echo "  ✓ Already linked: $rel"
        return
    fi

    if [ -e "$target" ] || [ -L "$target" ]; then
        mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
        cp -a "$target" "$BACKUP_DIR/$rel"
        echo "  → Backed up: $rel"
    fi

    ln -sf "$src" "$target"
    echo "  → Linked: $rel"
}

link_home() {
    local src="$1"
    local basename="$(basename "$src")"
    local target="$HOME/.${basename#.}"

    if [[ "$basename" == dot-* ]]; then
        target="$HOME/.${basename#dot-}"
    elif [[ "$basename" != .* ]]; then
        target="$HOME/.$basename"
    fi

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
        echo "  ✓ Already linked: $(basename "$target")"
        return
    fi

    if [ -e "$target" ] || [ -L "$target" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -a "$target" "$BACKUP_DIR/$(basename "$target")"
        echo "  → Backed up: $(basename "$target")"
    fi

    ln -sf "$src" "$target"
    echo "  → Linked: $(basename "$target")"
}

link_machine_config() {
    local src="$1"
    local machine="$2"
    local file_rel="${src#$REPO_DIR/config/}"
    local app="${file_rel%%/machine/*}"
    local file="${file_rel#*/machine/$machine/}"
    local rel="$app/$file"
    local target="$HOME/.config/$rel"
    local target_dir="$(dirname "$target")"

    mkdir -p "$target_dir"

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
        echo "  ✓ Already linked (machine $machine): $rel"
        return
    fi

    if [ -e "$target" ] || [ -L "$target" ]; then
        mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
        cp -a "$target" "$BACKUP_DIR/$rel"
        echo "  → Backed up (machine $machine): $rel"
    fi

    ln -sf "$src" "$target"
    echo "  → Linked (machine $machine): $rel"
}

echo ""
echo "--- Config files ---"
find "$REPO_DIR/config" -type f ! -path '*/machine/*' ! -path '*/omarchy-defaults/*' | sort | while IFS= read -r file; do
    link_config "$file"
done

echo ""
echo "--- Machine-specific ($MACHINE) ---"
if [ "$MACHINE" != "unknown" ]; then
    machine_dirs=$(find "$REPO_DIR/config" -path "*/machine/$MACHINE" -type d 2>/dev/null || true)
    if [ -n "$machine_dirs" ]; then
        echo "$machine_dirs" | while IFS= read -r machine_dir; do
            find "$machine_dir" -type f ! -name 'errors.json' | sort | while IFS= read -r file; do
                link_machine_config "$file" "$MACHINE"
            done
        done
    else
        echo "  No configs found for $MACHINE — auto-generating..."
        bash "$REPO_DIR/lib/auto-generate.sh" "$MACHINE"
        machine_dirs=$(find "$REPO_DIR/config" -path "*/machine/$MACHINE" -type d 2>/dev/null || true)
        if [ -n "$machine_dirs" ]; then
            echo "$machine_dirs" | while IFS= read -r machine_dir; do
                find "$machine_dir" -type f ! -name 'errors.json' | sort | while IFS= read -r file; do
                    link_machine_config "$file" "$MACHINE"
                done
            done
        fi
    fi
else
    echo "  Unknown machine — using shared configs only"
fi

echo ""
echo "--- Home files ---"
find "$REPO_DIR" -maxdepth 1 -type f ! -name 'install.sh' ! -name '.gitignore' ! -name 'README.md' ! -name 'ARCHITECTURE.md' ! -name 'ROADMAP.md' ! -name 'MACHINES.md' | sort | while IFS= read -r file; do
    link_home "$file"
done

echo ""
if [ -d "$BACKUP_DIR" ]; then
    echo "==> Done! Backups saved to: $BACKUP_DIR"
else
    echo "==> Done! No files needed backing up."
fi

echo "==> To log errors for this machine:"
echo "    ./lib/error-log.sh --machine \"$MACHINE\" --error \"msg\" --fix \"workaround\""
