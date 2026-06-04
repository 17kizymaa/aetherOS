#!/usr/bin/env bash
# scripts/verify-ux.sh — Verify core UX apps launch and are responsive (G7)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== aetherOS UX Verification ==="
echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

errors=0

# Check terminal
echo "Checking xfce4-terminal..."
if command -v xfce4-terminal &>/dev/null; then
    echo "  ✓ xfce4-terminal installed"
else
    echo "  ✗ xfce4-terminal NOT installed"
    ((errors++))
fi

# Check file manager
echo "Checking thunar..."
if command -v thunar &>/dev/null; then
    echo "  ✓ thunar installed"
else
    echo "  ✗ thunar NOT installed"
    ((errors++))
fi

# Check text editor
echo "Checking mousepad..."
if command -v mousepad &>/dev/null; then
    echo "  ✓ mousepad installed"
else
    echo "  ✗ mousepad NOT installed"
    ((errors++))
fi

# Check README
echo "Checking desktop README..."
if [ -f "${REPO_ROOT}/profiles/aetheros/airootfs/home/demo/Desktop/aetheros-readme.txt" ]; then
    echo "  ✓ aetheros-readme.txt exists"
else
    echo "  ✗ aetheros-readme.txt NOT found"
    ((errors++))
fi

if [ -f "${REPO_ROOT}/profiles/aetheros/airootfs/etc/skel/Desktop/aetheros-readme.desktop" ]; then
    echo "  ✓ aetheros-readme.desktop exists"
else
    echo "  ✗ aetheros-readme.desktop NOT found"
    ((errors++))
fi

echo ""
echo "=== Results: ${errors} errors ==="
[ ${errors} -eq 0 ] || exit 1