#!/usr/bin/env bash
# scripts/collect-artifacts.sh — Generate checksums and manifests (G5)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUT="${REPO_ROOT}/out"
VERSION="0.1.0-demo.1"
ARTIFACTS="${REPO_ROOT}/artifacts/releases/${VERSION}"

mkdir -p "${ARTIFACTS}"

echo "=== Collecting Artifacts for ${VERSION} ==="

# Check output directory exists
if [ ! -d "${OUT}" ]; then
    echo "ERROR: Output directory not found: ${OUT}/" >&2
    echo "Run ./scripts/build-iso.sh first to build the ISO." >&2
    exit 1
fi

# Find the ISO
ISO_FILE=$(find "${OUT}" -maxdepth 1 -name "*.iso" -print -quit 2>/dev/null)
if [ -z "${ISO_FILE}" ]; then
    echo "ERROR: No ISO found in ${OUT}/" >&2
    exit 1
fi

echo "ISO: ${ISO_FILE}"

# SHA256 checksum
(cd "${OUT}" && sha256sum *.iso > "${ARTIFACTS}/SHA256SUMS")

# Build environment
{
    echo "VERSION=${VERSION}"
    echo "GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')"
    echo "BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "HOST_OS=$(uname -s -r)"
    echo "ARCHISO_VERSION=$(pacman -Q archiso 2>/dev/null | awk '{print $2}' || echo 'N/A')"
} > "${ARTIFACTS}/build-env.txt"

# Package list
cp "${REPO_ROOT}/profiles/aetheros/packages.x86_64" "${ARTIFACTS}/package-list.txt"

# Manifest
cat > "${ARTIFACTS}/MANIFEST.md" << EOF
# aetherOS ${VERSION} Release Manifest

- **Version:** ${VERSION}
- **Build Date:** $(date -u +%Y-%m-%dT%H:%M:%SZ)
- **Git SHA:** $(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')
- **ISO:** $(basename "${ISO_FILE}")
- **SHA256:** $(sha256sum "${ISO_FILE}" | awk '{print $1}')
- **Package Count:** $(grep -c '^[^#]' "${REPO_ROOT}/profiles/aetheros/packages.x86_64" || echo 0)
EOF

echo ""
echo "=== Artifacts Collected ==="
ls -lh "${ARTIFACTS}/"
