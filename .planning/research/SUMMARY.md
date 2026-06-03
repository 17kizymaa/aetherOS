# Research Summary: aetherOS

**Domain:** Lightweight Linux-based operating environment for hardware revival (VM demo)
**Researched:** 2026-06-03
**Overall confidence:** MEDIUM

## Executive Summary

aetherOS aims to demonstrate that old/low-end hardware can become useful production workstations through intentional software design. The immediate deliverable is a bootable VM demo: an ISO that boots in QEMU with 2 GB RAM, reaches a lightweight graphical desktop, and provides terminal, file manager, text editor, and help documentation -- all without cloud dependencies.

The project has a **critical unresolved contradiction** at its foundation: the official docs (PROJECT.md, SPRINT_OPERATIONS.md) specify Arch Linux + mkarchiso as the base system with pacman packages, but the Architecture Decision Record (ADR 0001), the Operating Contract, and the bootstrap script all specify Debian Stable + XFCE with apt packages. The manifests/ directory contains Debian package names (apt-utils, firefox-esr) while the SPRINT_OPERATIONS.md profile structure uses Arch conventions (pacman.conf, packages.x86_64). This must be resolved before any build work begins, as it affects every downstream decision.

**The recommendation is to commit to Arch Linux + mkarchiso** as the ISO build path, for the following reasons: (1) the SPRINT_OPERATIONS.md already provides an extraordinarily detailed Arch/mkarchiso pipeline specification, (2) Arch's rolling-release model means newer packages for the same lightweight footprint, (3) the Arch Wiki is the single best documentation resource for any Linux customization work, (4) mkarchiso is purpose-built for creating bootable Arch ISOs from a profile directory, and (5) agent workflows are more effective with Arch's explicit, transparent configuration model. The Debian bootstrap script should be kept as a fallback/convenience installer but not as the demo artifact path.

The feature scope for v0.1.0-demo.1 is well-defined and achievable: a VM demo proving boot + lightweight desktop + core apps + build provenance. The hardest technical risk is fitting a functional desktop experience into 2 GB RAM, which requires careful package selection to avoid background services and heavy dependencies. The "Living Archive" content recognition feature (RECOG-01/02/03) should be deferred past the initial demo as it requires significant additional development.

The build pipeline architecture from SPRINT_OPERATIONS.md is comprehensive and production-quality. The 8-stage pipeline (environment capture through tag/release) with 8 validation gates (G0-G8) is well-designed for reproducibility. The main gap is that the actual build/validation scripts referenced in the pipeline do not yet exist in implementation-ready form.

## Key Findings

**Stack:** Arch Linux + mkarchiso + XFCE + LightDM (resolve the Arch vs Debian contradiction first)
**Architecture:** Profile-driven ISO build with airootfs overlay, QEMU validation, 8-stage pipeline with validation gates
**Critical pitfall:** The Arch/Debian contradiction will block all work if not resolved immediately -- manifests have Debian packages, docs specify Arch tooling

## Implications for Roadmap

Based on research, suggested phase structure:

1. **Phase 1: Foundation & Decision Resolution** - Resolve Arch vs Debian, create actual mkarchiso profile, implement build scripts
   - Addresses: BUILD-01, BUILD-02, BUILD-03
   - Avoids: Building on contradictory foundations that will cause rework

2. **Phase 2: Boot & Desktop** - Get ISO booting in QEMU with graphical session
   - Addresses: BOOT-01, BOOT-02, BOOT-03, PERF-01
   - Avoids: Package bloat that prevents 2 GB RAM target

3. **Phase 3: Core UX & Apps** - Terminal, file manager, text editor, help docs working
   - Addresses: UX-01, UX-02, UX-03
   - Avoids: Adding apps that consume too much RAM in the base profile

4. **Phase 4: Smart Features (optional/recognition)** - Content indexing, project categorization
   - Addresses: RECOG-01, RECOG-02, RECOG-03
   - Avoids: AI buzzweight -- use simple heuristics first

5. **Phase 5: Hardening & Release** - Validation, documentation, checksums, known issues
   - Addresses: All remaining acceptance criteria
   - Avoids: Missing build provenance

**Phase ordering rationale:**
Phase 1 must come first because every other phase depends on the build system being coherent. Phases 2 and 3 are the core demo and may overlap. Phase 4 is the differentiator but should not block the demo. Phase 5 wraps up and produces the release artifact.

**Research flags for phases:**
- Phase 1: CRITICAL -- needs immediate resolution of the Arch/Debian contradiction; this is a blocker
- Phase 2: Likely needs deeper research into XFCE/LightDM configuration for mkarchiso airootfs overlay
- Phase 4: Will need research into lightweight file classification approaches (pure heuristic vs optional ML)

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | MEDIUM | Strong knowledge of Arch/mkarchiso and XFCE, but cannot verify current package availability or specific version compatibility without live system access |
| Features | HIGH | Feature set is clearly defined in PROJECT.md and VM_DEMO_ACCEPTANCE.md |
| Architecture | HIGH | SPRINT_OPERATIONS.md provides detailed architecture; main gap is implementation |
| Pitfalls | MEDIUM | Known pitfalls well-documented in project files; runtime pitfalls (2 GB RAM constraint, boot issues) need empirical validation |

## Gaps to Address

1. **Arch vs Debian decision** -- Must be resolved before any build work; this is the single biggest risk
2. **Actual mkarchiso profile contents** -- profiles/aetheros/ directory does not exist yet; must be created
3. **2 GB RAM desktop validation** -- XFCE4 can run in ~512MB idle, but the full stack (LightDM + XFCE4 + terminal + Thunar + Mousepad + Firefox) needs to fit in 2GB; may need to drop Firefox from base profile or swap it for a lighter browser
4. **Content recognition implementation** -- RECOG features are defined in requirements but no implementation approach is specified; defer to post-demo
5. **Live-build fallback path** -- The image/live-build/README.md references a Plan A but the directory is empty; the relationship between this and mkarchiso needs clarification
6. **WebSearch/WebFetch unavailable** -- Could not verify current package versions, archiso documentation updates, or recent changes to Arch ISO building; all technical recommendations based on training knowledge
