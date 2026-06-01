#!/usr/bin/env bash
# aether-assist.sh — lightweight RAG-lite assistant: search local docs and show snippets
set -euo pipefail

query="$*"
if [ -z "$query" ]; then
  echo "Usage: aether-assist.sh <search terms>"
  exit 1
fi

echo "Searching docs for: $query"
rg -n --hidden --no-ignore-vcs --glob 'docs/**' "$query" || true
