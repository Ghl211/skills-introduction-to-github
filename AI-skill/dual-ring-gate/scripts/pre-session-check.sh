#!/bin/bash
# Dual-Ring Gate · Outer Ring Shell Gate
# Run before every Hermes session to enforce pre-checks.
# 
# Usage:
#   chmod +x pre-session-check.sh && ./pre-session-check.sh
#
# Or add to your shell profile:
#   alias hermes='~/.hermes/scripts/pre-session-check.sh && hermes'

set -e

echo "=== Dual-Ring Gate · Outer Ring ==="

# ① Time confirmation
echo "[CHECK] Time: $(date '+%Y-%m-%d %H:%M %A')"

# ② Gateway status
GW_STATUS=$(hermes gateway status 2>&1)
if echo "$GW_STATUS" | grep -q "running"; then
    echo "[PASS] Gateway running"
else
    echo "[FAIL] Gateway not running, starting..."
    hermes gateway run --replace 2>/dev/null &
    sleep 3
    if hermes gateway status 2>&1 | grep -q "running"; then
        echo "[PASS] Gateway started"
    else
        echo "[FATAL] Gateway start failed — cron jobs won't run"
        echo "       Try: hermes gateway run (foreground) to debug"
        # Soft fail: warn but don't block the session
        echo "[WARN] Continuing without gateway (cron disabled)"
    fi
fi

# ③ (Optional) Workspace health: check if hot-rules exists
HOT_RULES="$HOME/AppData/Local/hermes/flywheel/hot-rules.json"
if [ -f "$HOT_RULES" ]; then
    if python -c "import json; json.load(open('$HOT_RULES'))" 2>/dev/null; then
        echo "[PASS] hot-rules.json valid"
    else
        echo "[WARN] hot-rules.json has invalid JSON — fix before next session"
    fi
else
    echo "[INFO] hot-rules.json not found (create one for rule lifecycle)"
fi

echo "=== Outer Ring Passed ==="
