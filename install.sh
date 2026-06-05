#!/bin/bash
# Symlink dotfiles from this repo to ~/.config/ and ~/
# Backs up existing files before replacing.
# Supports machine-specific files with -hp or -macmini suffix.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.config/dotfiles-backup-$(date +%s)"

MACHINE=$(bash "$REPO_DIR/lib/detect-machine.sh" 2>/dev/null || true)

# config/<app>/<file> -> ~/.config/<app>/<file>
# Machine-specific: file-macmini.conf → file.conf (on Mac Mini only)
#                   file-hp.conf     → file.conf (on HP only)
# Shared files without suffix are linked on all machines.
link_config() {
    local src="$1"
    local basename="$(basename "$src")"
    local dir="$(dirname "$src")"
    local rel="${src#$REPO_DIR/config/}"

    local target_machine=""
    case "$basename" in
        *-hp.*)     target_machine="hp" ;;
        *-macmini.*) target_machine="macmini" ;;
    esac

    if [ -n "$target_machine" ]; then
        if [ "$target_machine" != "$MACHINE" ]; then
            echo "  - Skipped (${target_machine}): $rel"
            return
        fi
        local new_basename="${basename/-$target_machine/}"
        rel="${rel/$basename/$new_basename}"
    else
        local name="${basename%.*}"
        local ext="${basename##*.}"
        local variant_file="$dir/${name}-${MACHINE}.${ext}"
        if [ -f "$variant_file" ] && [ -n "$MACHINE" ]; then
            echo "  - Skipped (shared, ${MACHINE} variant exists): $rel"
            return
        fi
    fi

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

    local target_machine=""
    case "$basename" in
        *-hp.*)     target_machine="hp" ;;
        *-macmini.*) target_machine="macmini" ;;
    esac

    if [ -n "$target_machine" ]; then
        if [ "$target_machine" != "$MACHINE" ]; then
            local rel="${src#$REPO_DIR/}"
            echo "  - Skipped (${target_machine}): $rel"
            return
        fi
        local new_basename="${basename/-$target_machine/}"
        local target_name="$HOME/.${new_basename#.}"
        if [[ "$new_basename" != .* ]]; then
            target_name="$HOME/.$new_basename"
        fi
        target="$target_name"
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

# config/<app>/machine/<machine>/<file> -> ~/.config/<app>/<file>
# Strips the machine/ subdirectory to produce the correct target path.
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

echo "==> Installing dotfiles from $REPO_DIR"
echo "==> Detected machine: ${MACHINE:-unknown}"
echo ""

# Link all shared config files (exclude machine-specific overrides)
echo "--- Config files ---"
find "$REPO_DIR/config" -type f ! -path '*/machine/*' ! -path '*/omarchy-defaults/*' | sort | while IFS= read -r file; do
    link_config "$file"
done

echo ""
echo "--- Omarchy defaults ---"
find "$REPO_DIR/config" -path '*/omarchy-defaults/*' -type f | sort | while IFS= read -r file; do
    rel="${file#$REPO_DIR/config/hypr/omarchy-defaults/}"
    target="$HOME/.local/share/omarchy/default/hypr/$rel"
    target_dir="$(dirname "$target")"

    mkdir -p "$target_dir"

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$file" ]; then
        echo "  ✓ Already linked (omarchy): $rel"
        continue
    fi

    if [ -e "$target" ] || [ -L "$target" ]; then
        mkdir -p "$BACKUP_DIR/omarchy-defaults/$(dirname "$rel")"
        cp -a "$target" "$BACKUP_DIR/omarchy-defaults/$rel"
        echo "  → Backed up (omarchy): $rel"
    fi

    ln -sf "$file" "$target"
    echo "  → Linked (omarchy): $rel"
done

# Link machine-specific overrides (overwrite shared symlinks)
echo ""
echo "--- Machine-specific ($MACHINE) ---"
if [ "$MACHINE" != "unknown" ]; then
    machine_dirs=$(find "$REPO_DIR/config" -path "*/machine/$MACHINE" -type d 2>/dev/null || true)
    if [ -n "$machine_dirs" ]; then
        echo "$machine_dirs" | while IFS= read -r machine_dir; do
            find "$machine_dir" -type f | sort | while IFS= read -r file; do
                link_machine_config "$file" "$MACHINE"
            done
        done
    else
        echo "  No machine configs found for: $MACHINE"
    fi
else
    echo "  Unknown machine — using shared configs only"
fi

echo ""
echo "--- Home files ---"
find "$REPO_DIR" -maxdepth 1 -type f ! -name 'install.sh' ! -name '.gitignore' ! -name 'README.md' ! -name 'ARCHITECTURE.md' | sort | while IFS= read -r file; do
    link_home "$file"
done

echo ""
if [ -d "$BACKUP_DIR" ]; then
    echo "==> Done! Backups saved to: $BACKUP_DIR"
else
    echo "==> Done! No files needed backing up."
fi
