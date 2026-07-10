#!/usr/bin/env bash
# scripts/smoke-qemu.sh — Boot ISO in QEMU for smoke test (G6)
set -euo pipefail

ISO_PATH="${1:?Usage: $0 <path-to-iso>}"

if [ ! -f "${ISO_PATH}" ]; then
    echo "ERROR: ISO not found: ${ISO_PATH}" >&2
    exit 1
fi

# UEFI firmware support
UEFI_BIOS=""
if [ -f /usr/share/edk2-ovmf/x64/OVMF_CODE.fd ]; then
    UEFI_BIOS="-bios /usr/share/edk2-ovmf/x64/OVMF_CODE.fd"
    echo "=== UEFI firmware: OVMF ==="
else
    echo "WARNING: OVMF firmware not found at /usr/share/edk2-ovmf/x64/OVMF_CODE.fd" >&2
    echo "Install with: sudo pacman -S edk2-ovmf" >&2
    echo "Falling back to default BIOS" >&2
fi

# Auto-shutdown timeout: 2 minutes (120 seconds)
TIMEOUT_SEC=120

echo "=== Booting ISO with QEMU (2 GB RAM, 2 vCPU, UEFI) ==="
echo "Auto-shutdown timeout: ${TIMEOUT_SEC}s"
echo "ISO: ${ISO_PATH}"
echo ""

# Prefer run_archiso if available, fall back to direct QEMU
if command -v run_archiso &>/dev/null; then
    echo "=== Booting ISO with run_archiso ==="
    timeout "${TIMEOUT_SEC}" run_archiso -i "${ISO_PATH}" "$@" || true
else
    echo "=== Booting ISO with QEMU ==="
    timeout "${TIMEOUT_SEC}" qemu-system-x86_64 \
        -enable-kvm \
        -m 2048 \
        -smp 2 \
        ${UEFI_BIOS} \
        -cdrom "${ISO_PATH}" \
        -boot d \
        -vga virtio \
        -display sdl \
        "$@" || true
fi

echo ""
echo "=== Smoke test complete (timeout or guest shutdown) ==="
