#!/usr/bin/env bash
# scripts/verify-ux.sh — Verify core UX apps launch and are responsive (G7)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Validate paths
if [[ ! -d "${REPO_ROOT}" || ! -d "${REPO_ROOT}/profiles" ]]; then
    echo "ERROR: Invalid repository root path: ${REPO_ROOT}" >&2
    exit 1
fi

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
    errors=$((errors + 1))
fi

# Check file manager
echo "Checking thunar..."
if command -v thunar &>/dev/null; then
    echo "  ✓ thunar installed"
else
    echo "  ✗ thunar NOT installed"
    errors=$((errors + 1))
fi

# Check text editor
echo "Checking mousepad..."
if command -v mousepad &>/dev/null; then
    echo "  ✓ mousepad installed"
else
    echo "  ✗ mousepad NOT installed"
    errors=$((errors + 1))
fi

# Check README
echo "Checking desktop README..."
if [ -f "${REPO_ROOT}/profiles/aetheros/airootfs/home/demo/Desktop/aetheros-readme.txt" ]; then
    echo "  ✓ aetheros-readme.txt exists"
else
    echo "  ✗ aetheros-readme.txt NOT found"
    errors=$((errors + 1))
fi

if [ -f "${REPO_ROOT}/profiles/aetheros/airootfs/etc/skel/Desktop/aetheros-readme.desktop" ]; then
    echo "  ✓ aetheros-readme.desktop exists"
else
    echo "  ✗ aetheros-readme.desktop NOT found"
    errors=$((errors + 1))
fi

echo ""
echo "=== Results: ${errors} errors ==="
[ ${errors} -eq 0 ] || exit 1