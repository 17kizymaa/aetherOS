#!/usr/bin/env bash
# scripts/print-build-env.sh — Capture build environment metadata (Stage 0)
set -euo pipefail

echo "=== aetherOS Build Environment ==="
echo "Timestamp:    $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "Git SHA:      $(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')"
echo "Branch:       $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'N/A')"
echo "Host OS:      $(uname -s -r -m)"
echo "Kernel:       $(uname -v)"
echo "archiso:      $(pacman -Q archiso 2>/dev/null | awk '{print $2}' || echo 'NOT INSTALLED')"
echo "mkarchiso:    $(command -v mkarchiso 2>/dev/null || echo 'NOT FOUND')"
echo "shellcheck:   $(shellcheck --version 2>/dev/null | grep 'version:' | awk '{print $2}' || echo 'NOT INSTALLED')"
echo "QEMU:         $(qemu-system-x86_64 --version 2>/dev/null | head -1 || echo 'NOT INSTALLED')"
echo "Git:          $(git --version 2>/dev/null | awk '{print $3}' || echo 'NOT INSTALLED')"
echo "=================================="
