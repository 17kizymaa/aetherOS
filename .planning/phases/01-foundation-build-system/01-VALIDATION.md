---
phase: 01
slug: foundation-build-system
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-06-03
---

# Phase 01 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Shell-based validation (bash + shellcheck) |
| **Config file** | None — validation is script-based |
| **Quick run command** | `./scripts/validate.sh` |
| **Full suite command** | `./scripts/validate.sh && ./scripts/build-iso.sh && ./scripts/collect-artifacts.sh` |
| **Estimated runtime** | ~30s (G0-G3) / ~10min (G0-G6 with build) |

---

## Sampling Rate

- **After every task commit:** Run `./scripts/validate.sh` (G0-G3 only, fast)
- **After every plan wave:** Run `./scripts/validate.sh && ./scripts/build-iso.sh` (G0-G4)
- **Before `/gsd-verify-work`:** Full suite green (G0-G6) including VM smoke
- **Max feedback latency:** 30 seconds (G0-G3) / 10 minutes (G0-G4)

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 01-01-01 | 01 | 1 | DOC-04 | — | `.gitignore` prevents artifact commits | unit | `test -f .gitignore` | ❌ W0 | ⬜ pending |
| 01-01-02 | 01 | 1 | BOOT-03 | — | profiledef.sh has valid format | unit | `test -f profiles/aetheros/profiledef.sh` | ❌ W0 | ⬜ pending |
| 01-02-01 | 02 | 1 | BOOT-03, BUILD-01 | — | packages.x86_64 parseable, no dupes | unit | `sort packages.x86_64 \| uniq -d` | ❌ W0 | ⬜ pending |
| 01-03-01 | 03 | 1 | BUILD-01, BUILD-02 | T-01-01 | validate.sh passes shellcheck | unit | `shellcheck scripts/validate.sh` | ❌ W0 | ⬜ pending |
| 01-03-02 | 03 | 1 | BUILD-01 | — | validate.sh exits 0 | integration | `./scripts/validate.sh` | ❌ W0 | ⬜ pending |
| 01-04-01 | 04 | 2 | BOOT-03, BUILD-02 | — | build-iso.sh produces ISO | integration | `test -f out/*.iso` | ❌ W0 | ⬜ pending |
| 01-05-01 | 05 | 2 | BOOT-03 | — | collect-artifacts.sh generates SHA256 | integration | `test -f artifacts/releases/*/SHA256SUMS` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `profiles/aetheros/profiledef.sh` — ISO metadata definition
- [ ] `profiles/aetheros/packages.x86_64` — package list
- [ ] `profiles/aetheros/pacman.conf` — pacman configuration
- [ ] `scripts/validate.sh` — G0-G3 validation (BUILD-01)
- [ ] `scripts/validate-profile.sh` — G1-G2 profile checks
- [ ] `scripts/print-build-env.sh` — Stage 0 environment capture
- [ ] `scripts/build-iso.sh` — G4 ISO build (BOOT-03, BUILD-02)
- [ ] `scripts/smoke-qemu.sh` — G6 VM boot smoke
- [ ] `scripts/collect-artifacts.sh` — G5 artifact capture
- [ ] `.gitignore` — prevent generated artifact commits
- [ ] `docs/decisions/ADR-0004-use-archiso.md` — resolves Debian/Arch contradiction

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| ISO boots in QEMU with 2 GB RAM | BOOT-03 | QEMU smoke test requires GUI/interactive session | Run `./scripts/smoke-qemu.sh out/*.iso` and verify boot |
| README.md quick-start works from clean clone | DOC-04 | Requires human verification of instructions | Fresh clone, follow README.md, verify each step |
| OPERATING_CONTRACT.md updated | DOC-04 | Semantic accuracy requires human review | Read OPERATING_CONTRACT.md, verify Arch references |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s for G0-G3
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
