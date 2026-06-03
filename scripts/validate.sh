#!/usr/bin/env bash
# scripts/validate.sh — Run validation gates G0-G3
set -euo pipefail

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

echo "=== aetherOS Validation (G0-G3) ==="
echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "Git SHA: $(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')"
echo ""

# G0: Repo hygiene
gate "G0" "Required files exist" test -f README.md -a -f AGENTS.md -a -f .gitignore
gate "G0" "No ISO files committed" bash -c '! find . -name "*.iso" -not -path "./.git/*" 2>/dev/null | grep -q .'
gate "G0" "No .env files committed" bash -c '! find . -name ".env" -not -name ".env.example" -not -path "./.git/*" 2>/dev/null | grep -q .'

# G1: Profile integrity
gate "G1" "profiledef.sh exists" test -f profiles/aetheros/profiledef.sh
gate "G1" "packages.x86_64 exists" test -f profiles/aetheros/packages.x86_64
gate "G1" "pacman.conf exists" test -f profiles/aetheros/pacman.conf

# G2: Package policy (basic checks)
gate "G2" "No duplicate packages" bash -c 'sort profiles/aetheros/packages.x86_64 | uniq -d | grep -q . && exit 1 || exit 0'
gate "G2" "No empty package file" test -s profiles/aetheros/packages.x86_64

# G3: Script validation
if command -v shellcheck &>/dev/null; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
    for script in "${REPO_ROOT}"/scripts/*.sh; do
        [ -f "$script" ] || continue
        gate "G3" "shellcheck: $(basename "$script")" shellcheck -x "$script"
    done
else
    echo "GATE G3: WARN - shellcheck not installed, skipping"
fi

echo ""
echo "=== Results: ${PASS} passed, ${FAIL} failed ==="
[ "$FAIL" -eq 0 ]
