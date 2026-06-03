#!/usr/bin/env bash
# scripts/validate-profile.sh — Validate mkarchiso profile (G1-G2)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

PASS=0
FAIL=0

gate() {
    local gate_id="$1"
    local description="$2"
    shift 2
    if "$@"; then
        echo "GATE ${gate_id}: PASS - ${description}"
        PASS=$((PASS + 1))
    else
        echo "GATE ${gate_id}: FAIL - ${description}"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== aetherOS Profile Validation (G1-G2) ==="
echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "Git SHA: $(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')"
echo ""

# G1: Profile integrity (detailed)
gate "G1" "profiledef.sh exists" test -f "${REPO_ROOT}/profiles/aetheros/profiledef.sh"
gate "G1" "profiledef.sh has iso_name" grep -q 'iso_name=' "${REPO_ROOT}/profiles/aetheros/profiledef.sh"
gate "G1" "profiledef.sh has iso_label" grep -q 'iso_label=' "${REPO_ROOT}/profiles/aetheros/profiledef.sh"
gate "G1" "profiledef.sh has iso_version" grep -q 'iso_version=' "${REPO_ROOT}/profiles/aetheros/profiledef.sh"
gate "G1" "profiledef.sh has install_dir" grep -q 'install_dir=' "${REPO_ROOT}/profiles/aetheros/profiledef.sh"
gate "G1" "profiledef.sh has buildmodes" grep -q 'buildmodes=' "${REPO_ROOT}/profiles/aetheros/profiledef.sh"
gate "G1" "profiledef.sh has bootmodes" grep -q 'bootmodes=' "${REPO_ROOT}/profiles/aetheros/profiledef.sh"
gate "G1" "profiledef.sh has arch" grep -q 'arch=' "${REPO_ROOT}/profiles/aetheros/profiledef.sh"
gate "G1" "packages.x86_64 exists" test -f "${REPO_ROOT}/profiles/aetheros/packages.x86_64"
gate "G1" "pacman.conf exists" test -f "${REPO_ROOT}/profiles/aetheros/pacman.conf"

# G2: Package policy (detailed)
gate "G2" "No duplicate packages" bash -c 'sort "$1/profiles/aetheros/packages.x86_64" | uniq -d | grep -q . && exit 1 || exit 0' _ "${REPO_ROOT}"
gate "G2" "At least 5 non-comment lines" bash -c 'grep -cv "^#\|^$" "$1/profiles/aetheros/packages.x86_64" | grep -qE "^[5-9]|^[0-9]{2,}$"' _ "${REPO_ROOT}"
gate "G2" "No version specifiers in packages" bash -c '! grep -v "^#\|^$" "$1/profiles/aetheros/packages.x86_64" | grep -q "="' _ "${REPO_ROOT}"
gate "G2" "Required package: base" grep -q '^base$' "${REPO_ROOT}/profiles/aetheros/packages.x86_64"
gate "G2" "Required package: mkinitcpio" grep -q '^mkinitcpio$' "${REPO_ROOT}/profiles/aetheros/packages.x86_64"
gate "G2" "Required package: mkinitcpio-archiso" grep -q '^mkinitcpio-archiso$' "${REPO_ROOT}/profiles/aetheros/packages.x86_64"
gate "G2" "Required package: linux-lts" grep -q '^linux-lts$' "${REPO_ROOT}/profiles/aetheros/packages.x86_64"

echo ""
echo "=== Results: ${PASS} passed, ${FAIL} failed ==="
[ "$FAIL" -eq 0 ]
