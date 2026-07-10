#!/usr/bin/env bash
# scripts/generate-wallpaper.sh — Generate aetherOS wallpaper with hardware metrics
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT="${REPO_ROOT}/profiles/aetheros/airootfs/usr/share/backgrounds/aetheros-wallpaper.png"

# Check for ImageMagick
if ! command -v convert &>/dev/null; then
    echo "ERROR: ImageMagick 'convert' not found. Install with: sudo pacman -S imagemagick" >&2
    exit 1
fi

# Gather hardware metrics from build host
CPU_NAME=$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs || echo "Unknown CPU")
TOTAL_RAM=$(free -h | awk '/^Mem:/{print $2}' || echo "Unknown RAM")

# Generate wallpaper: dark background with hardware text
mkdir -p "$(dirname "${OUTPUT}")"
convert -size 1920x1080 xc:'#1a1a2e' \
    -fill '#e0e0e0' -font DejaVu-Sans -pointsize 24 \
    -gravity center -annotate +0+0 "aetherOS\n${CPU_NAME}\n${TOTAL_RAM} RAM" \
    "${OUTPUT}"

echo "Wallpaper generated: ${OUTPUT}"
