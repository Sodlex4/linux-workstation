#!/bin/bash
# Log or read errors per machine slot.
# Usage:
#   ./lib/error-log.sh --machine <slot> --error "msg" --fix "workaround" [--status open|resolved]
#   ./lib/error-log.sh --machine <slot> --list

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

usage() {
    echo "Usage:"
    echo "  ./lib/error-log.sh --machine <slot> --error \"msg\" --fix \"workaround\" [--status open|resolved]"
    echo "  ./lib/error-log.sh --machine <slot> --list"
    exit 1
}

MACHINE=""
ERROR=""
FIX=""
STATUS="open"
LIST=false

while [ $# -gt 0 ]; do
    case "$1" in
        --machine) MACHINE="$2"; shift 2 ;;
        --error) ERROR="$2"; shift 2 ;;
        --fix) FIX="$2"; shift 2 ;;
        --status) STATUS="$2"; shift 2 ;;
        --list) LIST=true; shift ;;
        *) usage ;;
    esac
done

if [ -z "$MACHINE" ]; then
    usage
fi

ERRORS_DIR="$REPO_DIR/config/hypr/machine/$MACHINE"
mkdir -p "$ERRORS_DIR"
ERRORS_FILE="$ERRORS_DIR/errors.json"

if [ "$LIST" = true ]; then
    if [ -f "$ERRORS_FILE" ]; then
        echo "Errors for $MACHINE:"
        python3 -c "
import json
with open('$ERRORS_FILE') as f:
    errors = json.load(f)
for e in errors:
    print(f\"  [{e['status']}] {e['date']}: {e['error']}\")
    if e.get('fix'):
        print(f\"    Fix: {e['fix']}\")
" 2>/dev/null || cat "$ERRORS_FILE"
    else
        echo "No errors logged for $MACHINE"
    fi
    exit 0
fi

if [ -z "$ERROR" ]; then
    usage
fi

DATE=$(date +%Y-%m-%d)

if [ -f "$ERRORS_FILE" ]; then
    python3 -c "
import json
with open('$ERRORS_FILE') as f:
    errors = json.load(f)
errors.append({
    'date': '$DATE',
    'machine': '$MACHINE',
    'error': '$ERROR',
    'fix': '$FIX',
    'status': '$STATUS'
})
with open('$ERRORS_FILE', 'w') as f:
    json.dump(errors, f, indent=2)
" 2>/dev/null || {
    echo "[]" > "$ERRORS_FILE.tmp"
    python3 -c "
import json
with open('$ERRORS_FILE.tmp') as f:
    errors = json.load(f)
errors.append({
    'date': '$DATE',
    'machine': '$MACHINE',
    'error': '$ERROR',
    'fix': '$FIX',
    'status': '$STATUS'
})
with open('$ERRORS_FILE.tmp', 'w') as f:
    json.dump(errors, f, indent=2)
" && mv "$ERRORS_FILE.tmp" "$ERRORS_FILE"
}
else
    echo '[]' | python3 -c "
import json, sys
data = json.load(sys.stdin)
data.append({
    'date': '$DATE',
    'machine': '$MACHINE',
    'error': '$ERROR',
    'fix': '$FIX',
    'status': '$STATUS'
})
with open('$ERRORS_FILE', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null || {
    cat > "$ERRORS_FILE" << JSON_EOF
[
  {
    "date": "$DATE",
    "machine": "$MACHINE",
    "error": "$ERROR",
    "fix": "$FIX",
    "status": "$STATUS"
  }
]
JSON_EOF
}
fi

echo "→ Logged error for $MACHINE"
