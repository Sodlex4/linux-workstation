#!/bin/bash
# Generate MACHINES.md from machine/ directory and errors.json
# Usage: ./lib/generate-machines.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MACHINE_DIR="$REPO_DIR/config/hypr/machine"
OUTPUT="$REPO_DIR/MACHINES.md"

cat > "$OUTPUT" << 'HEADER'
# Machine Inventory

Auto-generated from `config/hypr/machine/` directory.

| Slot | Status | Monitors | Input | Known Issues |
|------|--------|----------|-------|-------------|
HEADER

if [ ! -d "$MACHINE_DIR" ]; then
    echo "No machines configured yet." >> "$OUTPUT"
    exit 0
fi

for slot_dir in "$MACHINE_DIR"/*/; do
    slot=$(basename "$slot_dir")

    status="✅ Ready"
    known_issues="None"

    if [ -f "$slot_dir/errors.json" ]; then
        open_count=$(python3 -c "
import json
with open('$slot_dir/errors.json') as f:
    errors = json.load(f)
open_errors = [e for e in errors if e.get('status') == 'open']
print(len(open_errors))
" 2>/dev/null || echo "0")

        if [ "$open_count" -gt 0 ]; then
            status="⚠️  $open_count open issue(s)"
            known_issues=$(python3 -c "
import json
with open('$slot_dir/errors.json') as f:
    errors = json.load(f)
open_errors = [e for e in errors if e.get('status') == 'open']
for e in open_errors:
    print(e['error'])
" 2>/dev/null | head -3 | paste -sd ', ' - || echo "See errors.json")
        fi
    fi

    has_monitors="❌"
    has_input="❌"
    [ -f "$slot_dir/monitors.conf" ] && has_monitors="✅"
    [ -f "$slot_dir/input.conf" ] && has_input="✅"

    echo "| \`$slot\` | $status | $has_monitors | $has_input | $known_issues |" >> "$OUTPUT"
done

FOOTER_DATE=$(date +%Y-%m-%d)
cat >> "$OUTPUT" << FOOTER
---
*Last updated: $FOOTER_DATE*
FOOTER

echo "Generated: $OUTPUT"
