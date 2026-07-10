#!/usr/bin/env bash
# scripts/living-archive.sh — Content categorization scanner for aetherOS (RECOG-01, RECOG-02, RECOG-04)

set -euo pipefail

OUTPUT_DIR="${HOME}/.local/share/living-archive"
mkdir -p "${OUTPUT_DIR}"

echo "=== Living Archive Scan Started ===" >&2

# Project indicators - files/dirs that suggest a project directory
PROJECT_INDICATORS=(".git" "package.json" "Cargo.toml" ".vscode" "Makefile" "pom.xml" "requirements.txt" "go.mod")

scan_projects() {
    echo -n > "${OUTPUT_DIR}/projects.txt"
    for dir in "${HOME}/Desktop" "${HOME}/Documents" "${HOME}/Projects" "${HOME}/Code"; do
        [ -d "${dir}" ] || continue
        find "${dir}" -maxdepth 2 -type d 2>/dev/null | while read -r d; do
            for indicator in "${PROJECT_INDICATORS[@]}"; do
                if [ -e "${d}/${indicator}" ]; then
                    echo "${d}" >> "${OUTPUT_DIR}/projects.txt"
                    break
                fi
            done
        done
    done
}

scan_photos() {
    echo -n > "${OUTPUT_DIR}/photos.txt"
    for dir in "${HOME}/Pictures" "${HOME}/Photos" "${HOME}/Desktop" "${HOME}/Documents"; do
        [ -d "${dir}" ] || continue
        find "${dir}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.raw" -o -iname "*.cr2" -o -iname "*.nef" \) 2>/dev/null >> "${OUTPUT_DIR}/photos.txt" || true
    done
}

scan_documents() {
    echo -n > "${OUTPUT_DIR}/documents.txt"
    for dir in "${HOME}/Documents" "${HOME}/Desktop" "${HOME}/notes"; do
        [ -d "${dir}" ] || continue
        find "${dir}" -type f \( -iname "*.pdf" -o -iname "*.doc" -o -iname "*.docx" -o -iname "*.txt" -o -iname "*.md" -o -iname "*.org" \) 2>/dev/null >> "${OUTPUT_DIR}/documents.txt" || true
    done
}

scan_projects >&2
scan_photos >&2 || true
scan_documents >&2 || true

echo "=== Living Archive Scan Complete ===" >&2