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
        jq -r '.[] | "  [" + .status + "] " + .date + ": " + .error + (if .fix then "\n    Fix: " + .fix else "" end)' "$ERRORS_FILE" 2>/dev/null || cat "$ERRORS_FILE"
    else
        echo "No errors logged for $MACHINE"
    fi
    exit 0
fi

if [ -z "$ERROR" ]; then
    usage
fi

DATE=$(date +%Y-%m-%d)

# Use jq for safe JSON construction (no shell injection)
if command -v jq &>/dev/null; then
    if [ -f "$ERRORS_FILE" ]; then
        jq --arg date "$DATE" \
           --arg machine "$MACHINE" \
           --arg error "$ERROR" \
           --arg fix "$FIX" \
           --arg status "$STATUS" \
           '. + [{$date, machine: $machine, error: $error, fix: $fix, status: $status}]' \
           "$ERRORS_FILE" > "${ERRORS_FILE}.tmp" && mv "${ERRORS_FILE}.tmp" "$ERRORS_FILE"
    else
        jq -n --arg date "$DATE" \
           --arg machine "$MACHINE" \
           --arg error "$ERROR" \
           --arg fix "$FIX" \
           --arg status "$STATUS" \
           '[{$date, machine: $machine, error: $error, fix: $fix, status: $status}]' \
           > "$ERRORS_FILE"
    fi
else
    # Fallback: python3 with env vars (no shell interpolation)
    export ERR_DATE="$DATE"
    export ERR_MACHINE="$MACHINE"
    export ERR_ERROR="$ERROR"
    export ERR_FIX="$FIX"
    export ERR_STATUS="$STATUS"
    export ERR_FILE="$ERRORS_FILE"
    python3 -c '
import os, json
file = os.environ["ERR_FILE"]
date = os.environ["ERR_DATE"]
machine = os.environ["ERR_MACHINE"]
error = os.environ["ERR_ERROR"]
fix = os.environ["ERR_FIX"]
status = os.environ["ERR_STATUS"]
entry = {"date": date, "machine": machine, "error": error, "fix": fix, "status": status}
if os.path.exists(file):
    with open(file) as f:
        errors = json.load(f)
else:
    errors = []
errors.append(entry)
with open(file, "w") as f:
    json.dump(errors, f, indent=2)
' 2>/dev/null || {
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
