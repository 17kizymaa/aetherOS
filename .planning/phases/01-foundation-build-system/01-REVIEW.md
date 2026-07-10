---
phase: 01-foundation-build-system
reviewed: 2026-06-03T23:00:00Z
depth: standard
files_reviewed: 11
files_reviewed_list:
  - scripts/validate.sh
  - scripts/validate-profile.sh
  - scripts/build-iso.sh
  - scripts/collect-artifacts.sh
  - scripts/smoke-qemu.sh
  - scripts/print-build-env.sh
  - profiles/aetheros/profiledef.sh
  - profiles/aetheros/pacman.conf
  - profiles/aetheros/packages.x86_64
  - CHANGELOG.md
  - VERSION
findings:
  critical: 1
  warning: 4
  info: 3
  total: 8
status: issues_found
---

# Phase 1: Code Review Report

**Reviewed:** 2026-06-03T23:00:00Z
**Depth:** standard
**Files Reviewed:** 11
**Status:** issues_found

## Summary

Reviewed all Phase 1 (Foundation & Build System) deliverables: 7 shell scripts, 3 profile configuration files, and 2 metadata files. The implementation establishes an Arch Linux + mkarchiso build pipeline for aetherOS with validation gates G0-G6. Several bugs found ranging from a build-blocking empty boot configuration to argument-passing errors in the smoke test script.

## Critical Issues

### CR-01: Empty boot configuration directories will cause ISO build failure

**File:** `profiles/aetheros/profiledef.sh:10-11`
**Issue:** The profile declares `bootmodes=("bios.syslinux" "uefi.grub")` which tells mkarchiso to configure BIOS (syslinux) and UEFI (GRUB) boot. However, the corresponding directories `profiles/aetheros/syslinux/`, `profiles/aetheros/grub/`, and `profiles/aetheros/efiboot/` are empty (no config files). When mkarchiso runs, it expects bootloader configuration files (e.g., `syslinux/syslinux.cfg`, `grub/grub.cfg`, `efiboot/loader/`) in these directories. Their absence will cause the ISO build to fail or produce an unbootable image.

**Fix:** Add the required bootloader configuration files. At minimum:
- `profiles/aetheros/syslinux/syslinux.cfg` with BIOS boot entries
- `profiles/aetheros/grub/grub.cfg` with UEFI boot entries
- `profiles/aetheros/efiboot/loader/loader.conf` and a boot entry for systemd-boot

Alternatively, if only BIOS boot is needed for the demo, remove `"uefi.grub"` from `bootmodes` and remove the empty `grub/` and `efiboot/` directories.

## Warnings

### WR-01: smoke-qemu.sh passes ISO path twice to QEMU

**File:** `scripts/smoke-qemu.sh:26`
**Issue:** The script consumes `$1` as `ISO_PATH` but then passes `"$@"` (all original arguments, including `$1`) as additional arguments to QEMU on line 26. This means the ISO path is passed both via `-cdrom "${ISO_PATH}"` (line 22) and again as a positional parameter from `"$@"`. QEMU will receive the ISO path twice, which may cause unexpected behavior or an error.

**Fix:** Replace `"$@"` with `"${@:2}"` to skip the first argument (the ISO path):
```bash
qemu-system-x86_64 \
    -enable-kvm \
    -m 2048 \
    -smp 2 \
    -cdrom "${ISO_PATH}" \
    -boot d \
    -vga virtio \
    -display sdl \
    "${@:2}"
```

### WR-02: validate.sh runs from CWD instead of repo root

**File:** `scripts/validate.sh:27-29`
**Issue:** The G0 gate checks for `README.md`, `AGENTS.md`, and `.gitignore` using relative paths (`test -f README.md ...`). If the user runs the script from any directory other than the repo root (e.g., from `scripts/` or a subdirectory), these checks will fail even though the files exist. Other scripts in the project correctly use `SCRIPT_DIR` and `REPO_ROOT` to anchor their paths, but `validate.sh` does not.

**Fix:** Add repo root detection at the top of the script (consistent with other scripts):
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
```
Then prefix all file checks with `${REPO_ROOT}/`.

### WR-03: collect-artifacts.sh package count includes blank lines

**File:** `scripts/collect-artifacts.sh:55`
**Issue:** The package count in MANIFEST.md uses `grep -c '^[^#]'` which counts all lines that don't start with `#`. This includes blank/empty lines, inflating the package count. A file with 20 packages and 5 blank lines would report 25.

**Fix:** Exclude both comment and blank lines:
```bash
- **Package Count:** $(grep -cv '^#\|^$' "${REPO_ROOT}/profiles/aetheros/packages.x86_64" || echo 0)
```

### WR-04: validate-profile.sh G2 duplicate check is fragile

**File:** `scripts/validate-profile.sh:42`
**Issue:** The duplicate detection uses `sort "$1/profiles/..."` with `_` as `$1` and `${REPO_ROOT}` as the positional argument via the `_ "${REPO_ROOT}"` pattern. While this works, it is confusing and fragile -- the `_` placeholder is non-obvious. If someone modifies the `gate()` function signature or calling convention, this will silently break. The same pattern appears on lines 43 and 44.

**Fix:** Use direct variable expansion instead of the positional argument hack:
```bash
gate "G2" "No duplicate packages" bash -c "sort '${REPO_ROOT}/profiles/aetheros/packages.x86_64' | uniq -d | grep -q . && exit 1 || exit 0"
```
Or better yet, refactor the `gate()` function to accept a working directory parameter.

## Info

### IN-01: validate.sh G0 gate checks AGENTS.md which is not an archiso concept

**File:** `scripts/validate.sh:27`
**Issue:** The G0 gate checks for `AGENTS.md` as a "required file." While this file exists and is part of the project, it is an AI-agent operating guide, not a build-related artifact. If the goal is repo hygiene, this is fine, but it mixes concerns. Consider renaming this gate or splitting repo-level checks from build-level checks.

**Fix:** Either rename the gate to clarify it checks project docs, or move `AGENTS.md` check to a separate project-structure validation step.

### IN-02: collect-artifacts.sh uses hardcoded version string

**File:** `scripts/collect-artifacts.sh:8`
**Issue:** The version `VERSION="0.1.0-demo.1"` is hardcoded in the script rather than read from the `VERSION` file at the repo root. This creates a maintenance risk -- releasing a new version requires updating both `VERSION` and this script.

**Fix:** Read the version from the VERSION file:
```bash
VERSION="$(cat "${REPO_ROOT}/VERSION" 2>/dev/null || echo 'unknown')"
```

### IN-03: validate-profile.sh minimum package count check is imprecise

**File:** `scripts/validate-profile.sh:43`
**Issue:** The regex `^[5-9]|^[0-9]{2,}$` is applied to a count number. While functionally correct (matches 5-9 and 10+), the first alternation `^[5-9]` would also match the first digit of numbers like 50, 51, etc. It works because the second alternation catches 2+ digit numbers, but the regex is redundant and confusing. A simpler approach would be to use arithmetic comparison.

**Fix:** Replace with a numeric comparison:
```bash
gate "G2" "At least 5 non-comment lines" bash -c 'count=$(grep -cv "^#\|^$" "$1/profiles/aetheros/packages.x86_64"); [ "$count" -ge 5 ]' _ "${REPO_ROOT}"
```

---

_Reviewed: 2026-06-03T23:00:00Z_
_Reviewer: OWL (gsd-code-reviewer)_
_Depth: standard_
