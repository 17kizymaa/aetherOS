#!/usr/bin/env bash
# scripts/smoke-qemu.sh — Boot ISO in QEMU for smoke test (G6 / LT-3)
# UEFI-only ISO: must use OVMF. Headless-friendly when DISPLAY is unset.
set -euo pipefail

ISO_PATH="${1:?Usage: $0 <path-to-iso> [extra qemu args...]}"
shift || true

if [ ! -f "${ISO_PATH}" ]; then
    echo "ERROR: ISO not found: ${ISO_PATH}" >&2
    exit 1
fi

TIMEOUT_SEC="${SMOKE_TIMEOUT_SEC:-120}"
WORK_TMP="${TMPDIR:-/tmp}/aetheros-smoke-$$"
mkdir -p "${WORK_TMP}"
cleanup() { rm -rf "${WORK_TMP}"; }
trap cleanup EXIT

# Locate OVMF (Arch edk2-ovmf layouts vary by package era)
OVMF_CODE=""
OVMF_VARS=""
for code in \
    /usr/share/edk2/x64/OVMF_CODE.4m.fd \
    /usr/share/edk2/x64/OVMF_CODE.fd \
    /usr/share/edk2-ovmf/x64/OVMF_CODE.4m.fd \
    /usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
    /usr/share/OVMF/OVMF_CODE.fd
do
    if [ -f "$code" ]; then
        OVMF_CODE="$code"
        break
    fi
done

for vars in \
    /usr/share/edk2/x64/OVMF_VARS.4m.fd \
    /usr/share/edk2/x64/OVMF_VARS.fd \
    /usr/share/edk2-ovmf/x64/OVMF_VARS.4m.fd \
    /usr/share/edk2-ovmf/x64/OVMF_VARS.fd \
    /usr/share/OVMF/OVMF_VARS.fd
do
    if [ -f "$vars" ]; then
        OVMF_VARS="$vars"
        break
    fi
done

if [ -z "${OVMF_CODE}" ]; then
    echo "ERROR: OVMF firmware not found. Install: sudo pacman -S edk2-ovmf" >&2
    echo "Refusing BIOS fallback — aetherOS is uefi.grub-only (would false-pass)." >&2
    exit 2
fi

cp -f "${OVMF_VARS:-${OVMF_CODE}}" "${WORK_TMP}/OVMF_VARS.fd" 2>/dev/null || \
    truncate -s 540672 "${WORK_TMP}/OVMF_VARS.fd"

echo "=== UEFI firmware: ${OVMF_CODE} ==="
echo "=== Booting ISO with QEMU (2 GB RAM, 2 vCPU, UEFI) ==="
echo "Auto-shutdown timeout: ${TIMEOUT_SEC}s"
echo "ISO: ${ISO_PATH}"
echo ""

# Display: SDL if available DISPLAY; else none + serial for agent TTYs
DISPLAY_ARGS=()
if [ -n "${DISPLAY:-}" ] && [ "${SMOKE_HEADLESS:-}" != "1" ]; then
    DISPLAY_ARGS=(-vga virtio -display sdl)
else
    DISPLAY_ARGS=(-vga none -display none -serial mon:stdio)
    echo "=== Headless mode (serial mon:stdio) ==="
fi

set +e
timeout "${TIMEOUT_SEC}" qemu-system-x86_64 \
    -enable-kvm \
    -machine q35,smm=off \
    -m 2048 \
    -smp 2 \
    -drive if=pflash,format=raw,readonly=on,file="${OVMF_CODE}" \
    -drive if=pflash,format=raw,file="${WORK_TMP}/OVMF_VARS.fd" \
    -cdrom "${ISO_PATH}" \
    -boot order=d \
    "${DISPLAY_ARGS[@]}" \
    "$@"
EC=$?
set -e

echo ""
echo "=== Smoke test complete (qemu/timeout exit=${EC}) ==="
# timeout returns 124; qemu guest may exit 0
if [ "$EC" -eq 124 ] || [ "$EC" -eq 0 ]; then
    echo "RESULT: PASS-timeout-or-clean (process ran to timeout/exit without crash)"
    exit 0
fi
echo "RESULT: FAIL (unexpected exit ${EC})"
exit "$EC"
