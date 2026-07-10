---
phase: 01-foundation-build-system
plan: 04
subsystem: build-scripts
tags: [build-iso, mkarchiso, qemu, smoke-test, artifacts, shellcheck]
dependency_graph:
  requires:
    - phase: 01-foundation-build-system
      plan: 02
      provides: [mkarchiso-profile]
  provides: [print-build-env-sh, build-iso-sh, smoke-qemu-sh, collect-artifacts-sh]
  affects: [01-05]
tech_stack:
  added: []
  patterns: [repo-root-resolution, dependency-check-with-install-message, tool-fallback-pattern]
key_files:
  - path: "scripts/print-build-env.sh"
    action: created
  - path: "scripts/build-iso.sh"
    action: created
  - path: "scripts/smoke-qemu.sh"
    action: created
  - path: "scripts/collect-artifacts.sh"
    action: created
key_decisions:
  - "build-iso.sh fails with clear install command if mkarchiso not found (Pitfall 3)"
  - "smoke-qemu.sh prefers run_archiso, falls back to direct QEMU with 2GB RAM / 2 vCPU"
  - "collect-artifacts.sh validates out/ directory exists before searching for ISO"
  - "collect-artifacts.sh VERSION hardcoded to 0.1.0-demo.1 matching profiledef.sh iso_version"
requirements_completed:
  - BOOT-03
  - BUILD-02
metrics:
  duration: "~15 minutes"
  completed_date: "2026-06-03"
  tasks_completed: 2
  files_created: 4
  files_modified: 0
---

# Phase 01 Plan 04: Build Scripts Summary

**One-liner:** Created the 4 remaining build pipeline scripts: `print-build-env.sh` (Stage 0 environment capture), `build-iso.sh` (G4 ISO build), `smoke-qemu.sh` (G6 VM boot), and `collect-artifacts.sh` (G5 artifact capture).

## Performance

- **Duration:** ~15 minutes
- **Started:** 2026-06-03T21:29:00Z
- **Completed:** 2026-06-03T21:32:00Z
- **Tasks:** 2
- **Files modified:** 4 (all created)

## Accomplishments
- Created `scripts/print-build-env.sh` capturing 9 build environment metadata fields with fallbacks
- Created `scripts/build-iso.sh` with dependency check, profile validation, and mkarchiso invocation
- Created `scripts/smoke-qemu.sh` with run_archiso preference and QEMU fallback
- Created `scripts/collect-artifacts.sh` generating SHA256SUMS, build-env.txt, package-list.txt, and MANIFEST.md
- All scripts follow the shared boilerplate pattern: `#!/usr/bin/env bash`, description comment, `set -euo pipefail`, REPO_ROOT resolution

## Task Commits

Each task was committed atomically:

1. **Task 1: Create print-build-env.sh and build-iso.sh** - `8f3162c` (feat)
2. **Task 2: Create smoke-qemu.sh and collect-artifacts.sh** - `b1dc9be` (feat)

## Files Created/Modified
- `scripts/print-build-env.sh` -- Captures timestamp, git SHA, branch, host OS, kernel, archiso/mkarchiso/shellcheck/QEMU/git versions with fallbacks
- `scripts/build-iso.sh` -- Checks for mkarchiso, validates profiledef.sh exists, cleans work dir, runs `mkarchiso -v -w WORK -o OUT PROFILE`
- `scripts/smoke-qemu.sh` -- Takes ISO path as argument, prefers run_archiso, falls back to QEMU with 2GB RAM, 2 vCPU, KVM, virtio
- `scripts/collect-artifacts.sh` -- Finds ISO in out/, generates SHA256SUMS, build-env.txt, copies package-list.txt, writes MANIFEST.md

## Decisions Made
- build-iso.sh fails with `sudo pacman -Syu --needed archiso` message if mkarchiso not found (per Pitfall 3)
- smoke-qemu.sh uses `run_archiso -i` if available, otherwise direct QEMU command (per RESEARCH.md)
- collect-artifacts.sh validates out/ directory exists before find, giving actionable error message
- All scripts use `2>/dev/null || echo 'NOT FOUND'` pattern for optional tool version capture

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] collect-artifacts.sh find error when out/ directory missing**
- **Found during:** Task 2 (collect-artifacts.sh creation)
- **Issue:** When `out/` directory doesn't exist (no build run yet), `find "${OUT}" -maxdepth 1 -name "*.iso"` produces a find error message before the empty-check catches it. The error output is confusing.
- **Fix:** Added explicit directory existence check before the find command: `if [ ! -d "${OUT}" ]; then echo "ERROR: Output directory not found..."; exit 1; fi`
- **Files modified:** `scripts/collect-artifacts.sh`
- **Verification:** `./scripts/collect-artifacts.sh` now prints clean error message when out/ is missing
- **Committed in:** `b1dc9be` (Task 2 commit, fix applied before commit)

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** Minor fix for better error messaging. No scope creep.

## Issues Encountered
- mkarchiso not installed on build host -- build-iso.sh correctly detects and reports with install instructions (expected behavior)
- QEMU not installed -- smoke-qemu.sh would fail at QEMU invocation (expected, requires build host setup)

## Next Phase Readiness
- All 6 build scripts now exist (validate.sh, validate-profile.sh from Plan 03 + 4 from this plan)
- All scripts pass bash -n syntax check
- Ready for Plan 05 (documentation update)

---
*Phase: 01-foundation-build-system*
*Completed: 2026-06-03*
