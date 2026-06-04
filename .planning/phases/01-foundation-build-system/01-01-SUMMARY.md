---
phase: 01-foundation-build-system
plan: 01
subsystem: foundation
tags: [gitignore, adr, arch-linux, debian-archive, operating-contract]
dependency_graph:
  requires: []
  provides: [git-hygiene, base-system-decision, archived-debian-artifacts, updated-operating-contract]
  affects: [01-02, 01-03, 01-04, 01-05]
tech_stack:
  added: []
  patterns: [adr-format, gitignore-pattern, archival-pattern]
key_files:
  - path: ".gitignore"
    action: created
  - path: "docs/decisions/ADR-0004-use-archiso.md"
    action: created
  - path: "deprecated/README.md"
    action: created
  - path: "deprecated/manifests/"
    action: moved from manifests/
  - path: "deprecated/bootstrap-aether.sh"
    action: moved from scripts/bootstrap-aether.sh
  - path: "OPERATING_CONTRACT.md"
    action: modified
decisions:
  - id: D-01
    description: "Arch Linux + mkarchiso formally adopted as base system via ADR-0004, superseding ADR-0001"
  - id: D-07
    description: "Debian artifacts archived to deprecated/ with explanatory README, not deleted"
metrics:
  duration: "~15 minutes"
  completed_date: "2026-06-03"
  tasks_completed: 3
  files_created: 3
  files_modified: 1
  files_moved: 2
---

# Phase 01 Plan 01: Foundation & Git Hygiene Summary

**One-liner:** Resolved the Debian/Arch contradiction via ADR-0004, established .gitignore to prevent artifact commits, and archived Debian artifacts to deprecated/ with updated OPERATING_CONTRACT.md.

## Tasks Completed

| # | Task | Commit | Status |
|---|------|--------|--------|
| 1 | Create .gitignore to prevent artifact commits | `76e752b` | Done |
| 2 | Create ADR-0004 resolving Debian/Arch contradiction | `468d7b7` | Done |
| 3 | Archive Debian artifacts and update OPERATING_CONTRACT.md | `4e1416a` | Done |

## Key Deliverables

### .gitignore
- Created at repo root with patterns for `work/`, `out/`, `logs/`, `*.iso`, `*.img`, `*.qcow2`, `*.log`, `.env`, `.env.*`
- Negation rule `!.env.example` allows example env files
- Prevents accidental commits of build artifacts (ISO files can be 500+ MB)

### ADR-0004 (docs/decisions/ADR-0004-use-archiso.md)
- Formally adopts Arch Linux + mkarchiso as the v0.1 base system
- Supersedes ADR-0001 (Debian Stable + live-build)
- Documents rationale: mkarchiso purpose-built for ISO creation, Arch Wiki documentation quality, alignment with majority of project documentation
- Lists consequences: manifests/ and bootstrap-aether.sh invalidated, OPERATING_CONTRACT.md must be updated

### Debian Artifacts Archived
- `manifests/` moved to `deprecated/manifests/` (contains Debian package names: apt-utils, firefox-esr)
- `scripts/bootstrap-aether.sh` moved to `deprecated/` (uses `apt` commands)
- `deprecated/README.md` created explaining archival rationale

### OPERATING_CONTRACT.md Updated
- Rule 1 changed from "Debian Stable + XFCE" to "Arch Linux + XFCE"
- Only text change needed in the file

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking Issue] Initial commit went to master branch instead of worktree-agent branch**
- **Found during:** Task 1
- **Issue:** First `git commit` from the worktree directory resolved to the master branch instead of `worktree-agent-a65e8ff1`. The `.gitignore` file was physically created in the main repo (`/home/anphuni/aetherOS/.gitignore`) rather than the worktree.
- **Fix:** Removed the accidentally created file from the main repo, reset master's ref back to its original commit using `git update-ref`, then re-created the file directly in the worktree using the explicit worktree path.
- **Files modified:** `.gitignore` (recreated in worktree)
- **Commit:** `76e752b`

**2. [Rule 1 - Bug] Deletions from `mv` not auto-staged in commit**
- **Found during:** Task 3
- **Issue:** After `mv manifests/ deprecated/manifests/` and `mv scripts/bootstrap-aether.sh deprecated/`, `git add` of the new paths did not automatically stage the deletions at the old paths. `git status` showed unstaged deletions.
- **Fix:** Ran `git add -u` to stage the deletions, then `git commit --amend --no-edit` to include them. The commit now correctly shows renames.
- **Files modified:** Task 3 commit amended
- **Commit:** `4e1416a` (amended)

## Verification Results

All automated verification commands passed:
- `.gitignore` exists at repo root with all required patterns
- `docs/decisions/` directory and ADR-0004 file exist with correct content
- `deprecated/` directory contains manifests/ and bootstrap-aether.sh
- `manifests/` no longer exists at repo root
- `OPERATING_CONTRACT.md` contains "Arch Linux" and does not contain "Debian Stable"

## Threat Surface Scan

No new threat surface introduced. The changes are documentation, configuration, and archival operations. The .gitignore reduces information disclosure risk (T-01-01) by preventing secret and artifact commits.

## Self-Check

- [x] `.gitignore` exists at `/home/anphuni/aetherOS/.claude/worktrees/agent-a65e8ff1/.gitignore`
- [x] `docs/decisions/ADR-0004-use-archiso.md` exists
- [x] `deprecated/README.md` exists
- [x] `deprecated/manifests/packages.base.txt` exists
- [x] `deprecated/bootstrap-aether.sh` exists
- [x] `OPERATING_CONTRACT.md` references "Arch Linux"
- [x] Commit `76e752b` exists in worktree-agent-a65e8ff1 git log
- [x] Commit `468d7b7` exists in worktree-agent-a65e8ff1 git log
- [x] Commit `4e1416a` exists in worktree-agent-a65e8ff1 git log

## Self-Check: PASSED
