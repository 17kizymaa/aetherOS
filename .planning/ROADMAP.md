# aetherOS Roadmap

**Version:** v0.1.0-demo.1
**Last Updated:** 2026-06-03
**Mode:** Horizontal Layers

## Overview

5 phases building from foundation up: Base → Desktop → UX → Intelligence → Release.

## Phase 1: Foundation & Build System

**Goal:** Resolve base system contradictions and establish working mkarchiso build pipeline.

**Success Criteria:**
1. Base system decision documented (Arch + mkarchiso)
2. `profiles/aetheros/` exists with valid `profiledef.sh`, `packages.x86_64`, `pacman.conf`
3. `./scripts/validate.sh` passes
4. `./scripts/build-iso.sh` produces bootable ISO
5. All contradictory docs updated (ADR, OPERATING_CONTRACT, manifests)

**Requirements:** BOOT-03, BUILD-01, BUILD-02, DOC-04

**Key Deliverables:**
- Resolved ADR on base system
- Working mkarchiso profile
- Build scripts (validate, build, smoke, collect-artifacts)
- Updated documentation

## Phase 2: Core Desktop & Boot

**Goal:** Boot to responsive XFCE desktop in QEMU with 2 GB RAM.

**Success Criteria:**
1. ISO boots in QEMU with 2 GB RAM
2. System reaches XFCE graphical session
3. LightDM auto-login works
4. No cloud dependencies for boot
5. System responsive (no obvious lag)
6. Shutdown/reboot works

**Requirements:** BOOT-01, BOOT-02, BOOT-04, UX-05, AI-03, AI-04

**Key Deliverables:**
- XFCE + LightDM configuration in airootfs
- zram enabled for RAM optimization
- Minimal package set (no bloat)
- Working VM smoke test

## Phase 3: UX Applications & Workbench

**Goal:** Core apps work and help documentation is accessible.

**Success Criteria:**
1. Terminal opens and is responsive
2. File manager opens and is responsive
3. Text editor opens and is responsive
4. Help/about document accessible from desktop
5. .env.example exists for AI integration
6. Missing API keys don't break UX

**Requirements:** UX-01, UX-02, UX-03, UX-04, AI-01, AI-02

**Key Deliverables:**
- Verified core apps (xfce4-terminal, thunar, mousepad)
- Help document on desktop
- .env.example file
- Graceful degradation for missing AI keys

## Phase 4: Content Recognition & Living Archive

**Goal:** Auto-detection and smart categorization of existing content.

**Success Criteria:**
1. System detects existing folder structure at first boot
2. Content categorized (Projects, Photos, Documents) without user input
3. Searchable unified view of local content
4. Uses file heuristics (not ML) for categorization

**Requirements:** RECOG-01, RECOG-02, RECOG-03, RECOG-04

**Key Deliverables:**
- Filesystem scanning script
- Heuristic-based categorization
- Search integration (ripgrep-based)
- Living Archive desktop launcher

## Phase 5: Validation, Packaging & Release

**Goal:** Reproducible build with full provenance and documentation.

**Success Criteria:**
1. `./scripts/collect-artifacts.sh` generates SHA256 checksum
2. Build metadata captured (archiso version, git SHA, timestamp)
3. `context/CURRENT_STATE.md` reflects actual state
4. `context/KNOWN_ISSUES.md` lists remaining issues
5. `CHANGELOG.md` has demo entry
6. Git tag created (v0.1.0-demo.1)
7. All validation gates G0-G8 pass

**Requirements:** BUILD-03, BUILD-04, DOC-01, DOC-02, DOC-03

**Key Deliverables:**
- Artifact collection script
- SHA256 checksums
- Release manifest
- Git tag
- Validation report

## Phase Dependencies

```
Phase 1 (Foundation)
    ↓
Phase 2 (Desktop & Boot)
    ↓
Phase 3 (UX Applications)
    ↓
Phase 4 (Content Recognition) ← Can start in parallel with Phase 3
    ↓
Phase 5 (Validation & Release)
```

## Risk Register

| Risk | Phase | Mitigation |
|------|-------|------------|
| Base system contradiction blocks all work | Phase 1 | Resolve in first 2 hours; document decision |
| XFCE too slow at 2 GB RAM | Phase 2 | Enable zram, disable compositing, minimize packages |
| Build scripts incomplete | Phase 1 | Start with minimal implementations, iterate |
| RECOG features over-engineered | Phase 4 | Use file heuristics only; defer ML |
| Missing build host (Arch Linux) | Phase 1 | Verify host availability before starting |

## Sources

- Requirements: `.planning/REQUIREMENTS.md`
- Research: `.planning/research/SUMMARY.md`
- Acceptance: `docs/VM_DEMO_ACCEPTANCE.md`