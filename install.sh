#!/bin/bash
# Symlink dotfiles from this repo to ~/.config/ and ~/
# Backs up existing files before replacing.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.config/dotfiles-backup-$(date +%s)"

# config/<app>/<file> -> ~/.config/<app>/<file>
link_config() {
    local src="$1"
    local rel="${src#$REPO_DIR/config/}"
    local target="$HOME/.config/$rel"
    local target_dir="$(dirname "$target")"

    # Ensure target directory exists
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

# Top-level files like bashrc -> ~/.bashrc
link_home() {
    local src="$1"
    local filename="$(basename "$src")"
    local target="$HOME/.${filename#.}"

    # strip leading "dot-" prefix if present (e.g. dot-bashrc -> .bashrc)
    if [[ "$filename" == dot-* ]]; then
        target="$HOME/.${filename#dot-}"
    elif [[ "$filename" != .* ]]; then
        target="$HOME/.$filename"
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

echo "==> Installing dotfiles from $REPO_DIR"
echo ""

# Link all config files
echo "--- Config files ---"
find "$REPO_DIR/config" -type f | sort | while IFS= read -r file; do
    link_config "$file"
done

# Link omarchy-defaults files into the omarchy source tree
# This replaces Omarchy's managed defaults with our patched versions.
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

# Link top-level files
echo ""
echo "--- Home files ---"
find "$REPO_DIR" -maxdepth 1 -type f ! -name 'install.sh' ! -name '.gitignore' ! -name 'README.md' | sort | while IFS= read -r file; do
    link_home "$file"
done

echo ""
if [ -d "$BACKUP_DIR" ]; then
    echo "==> Done! Backups saved to: $BACKUP_DIR"
else
    echo "==> Done! No files needed backing up."
fi
