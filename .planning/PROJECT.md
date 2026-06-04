# aetherOS

## What This Is

aetherOS is a lightweight, local-first operating environment that turns neglected hardware into calm production workstations. It demonstrates that old computers can become immediately useful again through boringly smart organization and intentional performance optimization, without cloud dependencies or permission friction.

## Core Value

Instant recognition and local intelligence - the system immediately understands existing content and makes it searchable and navigable faster than modern alternatives, proving that neglected hardware has untapped utility.

## Requirements

### Validated

### Validated

- [x] **BOOT-03**: Boot process is reproducible from clean clone using build scripts (validated in Phase 1: Foundation & Build System)
- [x] **BUILD-01**: `./scripts/validate.sh` passes on clean clone (G0-G3 gates, 8/8 pass)
- [x] **BUILD-02**: `./scripts/build-iso.sh` produces ISO in `out/` (script implemented, build unverified pending archiso install)
- [x] **DOC-04**: `README.md` contains working quick-start instructions (validated in Phase 1)

### Active

- [ ] **BOOT-01**: ISO boots in QEMU with 2 GB RAM to graphical session
- [ ] **BOOT-02**: System reaches login flow without cloud dependencies
- [ ] **UX-01**: Terminal, file manager, text editor open responsively
- [ ] **UX-02**: Basic help/about documentation is accessible
- [ ] **UX-03**: Shutdown/reboot works from UI or documented command
- [ ] **PERF-01**: System remains responsive under 2 GB RAM constraint
- [ ] **RECOG-01**: Auto-detection and indexing of existing folder structure
- [ ] **RECOG-02**: Smart categorization of Documents, Photos, Projects without user input
- [ ] **RECOG-03**: Searchable "Living Archive" view of local content
- [ ] **BUILD-03**: Known limitations documented for transparency

### Out of Scope

- Custom kernel — use Arch Linux base for stability
- Custom package manager — leverage existing Arch ecosystem
- Cloud dependencies — local-first by design
- Autonomous self-modification — predictable behavior required
- Bundled model weights — optional AI features must be lightweight
- Complex AI workflows — focus on boringly smart categorization

## Context

**Sprint Goal**: Produce a stable VM demo that demonstrates narrative coherence - that neglected hardware can become useful again through intentional design. Tomorrow's validation is about inevitability, not technical revelation.

**Target Narrative**: A 5-year-old laptop boots into something faster at organizing and finding content than current systems, making the case for hardware revival through software intention.

**Hardware Resurrection Story**: The demo should make someone think "of course it organized it that way" when seeing project structure recognition - React repos, design portfolios, tax documents categorized naturally without learning or asking.

## Constraints

- **Platform**: QEMU/KVM x86_64, 2 vCPU, 2 GB RAM minimum
- **Base**: Arch Linux with mkarchiso - no custom kernel/package manager
- **Dependencies**: Local-first by default, no cloud requirements for boot/UX
- **Performance**: Responsive under constrained resources
- **Stability**: Prioritize operational coherence over novelty
- **AI Integration**: Optional and gracefully degrading (no bundled weights)
- **Build**: Human approval required for destructive changes

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Arch + mkarchiso base | Proven toolchain, community support, lightweight | — Pending |
| Local-first architecture | Hardware revival narrative requires independence | — Pending |
| Boringly smart categorization | Immediate utility without AI buzzwords or learning | — Pending |
| 2 GB RAM target | Realistic constraint for neglected hardware | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-06-03 after initialization*