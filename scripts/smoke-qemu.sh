#!/usr/bin/env bash
# scripts/smoke-qemu.sh — Boot ISO in QEMU for smoke test (G6)
set -euo pipefail

ISO_PATH="${1:?Usage: $0 <path-to-iso>}"

if [ ! -f "${ISO_PATH}" ]; then
    echo "ERROR: ISO not found: ${ISO_PATH}" >&2
    exit 1
fi

# Prefer run_archiso if available, fall back to direct QEMU
if command -v run_archiso &>/dev/null; then
    echo "=== Booting ISO with run_archiso ==="
    run_archiso -i "${ISO_PATH}"
else
    echo "=== Booting ISO with QEMU (2 GB RAM, 2 vCPU) ==="
    qemu-system-x86_64 \
        -enable-kvm \
        -m 2048 \
        -smp 2 \
        -cdrom "${ISO_PATH}" \
        -boot d \
        -vga virtio \
        -display sdl \
        "$@"
fi
