#!/usr/bin/env bash
# scripts/build-iso.sh — Build aetherOS ISO (G4)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROFILE="${REPO_ROOT}/profiles/aetheros"
WORK="${REPO_ROOT}/work"
OUT="${REPO_ROOT}/out"

# Check host dependencies
for cmd in mkarchiso; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "ERROR: ${cmd} not found. Install with: sudo pacman -Syu --needed archiso" >&2
        exit 1
    fi
done

# Validate profile exists
if [ ! -f "${PROFILE}/profiledef.sh" ]; then
    echo "ERROR: Profile not found at ${PROFILE}" >&2
    exit 1
fi

# Clean previous build artifacts (work dir only, preserve out/)
if [ -d "${WORK}" ]; then
    echo "Removing previous work directory..."
    rm -rf "${WORK}"
fi

mkdir -p "${OUT}"

echo "=== Building aetherOS ISO ==="
echo "Profile: ${PROFILE}"
echo "Work:    ${WORK}"
echo "Out:     ${OUT}"
echo ""

mkarchiso -v -w "${WORK}" -o "${OUT}" "${PROFILE}"

echo ""
echo "=== Build Complete ==="
ls -lh "${OUT}"/*.iso 2>/dev/null || echo "WARNING: No ISO found in ${OUT}/"
