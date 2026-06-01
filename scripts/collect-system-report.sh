#!/usr/bin/env bash
# collect-system-report.sh — gathers basic system information for validation logs
set -euo pipefail

echo "Collecting system report..."
uname -a
lsb_release -a || true
free -h
df -h
