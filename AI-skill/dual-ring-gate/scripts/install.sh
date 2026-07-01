#!/bin/bash
# Dual-Ring Gate · One-Command Install Script
# Usage: curl -fsSL https://raw.githubusercontent.com/<repo>/main/scripts/install.sh | bash

set -e

HERMES_HOME="${HOME}/AppData/Local/hermes"
echo "=== Dual-Ring Gate Installer ==="

# 1. Create directories
mkdir -p "$HERMES_HOME/scripts" "$HERMES_HOME/flywheel"

# 2. Download outer ring script
echo "[1/4] Downloading pre-session-check.sh..."
curl -fsSL -o "$HERMES_HOME/scripts/pre-session-check.sh" \
    https://raw.githubusercontent.com/Ghl211/skills-introduction-to-github/main/AI-skill/dual-ring-gate/scripts/pre-session-check.sh
chmod +x "$HERMES_HOME/scripts/pre-session-check.sh"

# 3. Create hot-rules.json if not exists
if [ ! -f "$HERMES_HOME/flywheel/hot-rules.json" ]; then
    echo "[2/4] Creating hot-rules.json template..."
    curl -fsSL -o "$HERMES_HOME/flywheel/hot-rules.json" \
        https://raw.githubusercontent.com/Ghl211/skills-introduction-to-github/main/AI-skill/dual-ring-gate/templates/hot-rules.json
fi

# 4. Add inner ring to SOUL.md if not present
SOUL_FILE="$HERMES_HOME/SOUL.md"
INNER_RING_MARKER="Dual-Ring Gate · Inner Ring"
if [ ! -f "$SOUL_FILE" ]; then
    echo "[3/4] SOUL.md not found — creating..."
    echo "# SOUL.md — Agent Identity" > "$SOUL_FILE"
fi

if ! grep -q "$INNER_RING_MARKER" "$SOUL_FILE" 2>/dev/null; then
    echo "[3/4] Injecting inner ring into SOUL.md..."
    cat >> "$SOUL_FILE" << 'EOF'

## 🔴 Dual-Ring Gate · Inner Ring (auto-injected · cannot skip)
- **Time check**: terminal('date') before every response
- **Gateway check**: verify gateway status on first response of each session
- **Rule update**: every fix must also update the error rule database
EOF
else
    echo "[3/4] Inner ring already in SOUL.md — skipping"
fi

# 5. Install the Hermes skill
echo "[4/4] Installing Hermes skill..."
hermes skills install https://raw.githubusercontent.com/Ghl211/skills-introduction-to-github/main/AI-skill/dual-ring-gate/SKILL.md 2>/dev/null || {
    echo "[WARN] Could not install via hermes CLI."
    echo "       Manually copy SKILL.md to:"
    echo "       $HERMES_HOME/skills/knowledge/dual-ring-gate/"
}

echo ""
echo "=== Dual-Ring Gate Installed ==="
echo ""
echo "Next steps:"
echo "  1. Edit ~/AppData/Local/hermes/flywheel/hot-rules.json with your top 3 mistakes"
echo "  2. Start a new Hermes session — inner ring is already active"
echo "  3. Make a mistake and correct yourself — the hot layer learns"
echo ""
echo "Full docs: https://github.com/Ghl211/skills-introduction-to-github/blob/main/AI-skill/dual-ring-gate/SKILL.md"
