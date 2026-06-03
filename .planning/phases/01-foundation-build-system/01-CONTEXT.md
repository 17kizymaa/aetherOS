# Phase 1: Foundation & Build System - Context

**Gathered:** 2026-06-03
**Status:** Ready for planning

## Phase Boundary

Establish the build infrastructure: resolve the base system decision, create the mkarchiso profile, implement all build scripts, and archive Debian artifacts. Everything downstream (Phases 2-5) depends on this foundation.

## Implementation Decisions

### Base System
- **D-01:** Standardize on **Arch Linux + mkarchiso** for v0.1. ADR-0001 (Debian) is superseded. Create ADR-0004 to formally document this decision.
- **D-02:** Desktop environment is **XFCE** — lightweight, ~300-400 MB RAM idle, well-documented for Arch.

### Profile Scope
- **D-03:** Create a **minimal bootable profile** in Phase 1. Just enough packages to reach XFCE graphical session. UX-specific packages (terminal, file manager, editor) added in Phase 2.
- **D-04:** Profile structure follows Arch releng convention: `profiledef.sh`, `packages.x86_64`, `pacman.conf`, `airootfs/` overlay.

### Build Scripts
- **D-05:** All referenced scripts must exist and pass shellcheck: `validate.sh`, `build-iso.sh`, `smoke-qemu.sh`, `collect-artifacts.sh`, `validate-profile.sh`, `print-build-env.sh`.
- **D-06:** Scripts follow the 8-stage pipeline from SPRINT_OPERATIONS.md (environment capture → repo validation → profile validation → package review → ISO build → artifact capture → VM smoke boot → tag/release).

### Debian Artifacts
- **D-07:** Archive all Debian-specific artifacts. Move `manifests/` and `bootstrap-aether.sh` to a `deprecated/` directory or remove entirely. Clean break from Debian for v0.1.

### Validation Gates
- **D-08:** Phase 1 must pass **G0 through G6** — repo hygiene, profile integrity, package policy, script validation, ISO build, artifact manifest, and VM boot smoke test. This de-risks Phase 2 by proving the ISO actually boots.

### Claude's Discretion
- Exact package list for minimal bootable profile (rely on Arch releng profile as reference)
- Script implementation details and flag choices
- Directory structure for `deprecated/` vs full removal of Debian artifacts
- Whether to use `linux` or `linux-lts` kernel (recommend `linux-lts` for stability)

## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Build Pipeline
- `docs/SPRINT_OPERATIONS.md` — Full operational standard: build stages, validation gates G0-G8, package policy, logging standards, troubleshooting workflow
- `docs/BUILD_PIPELINE.md` — Build stages, inputs/outputs, artifact naming conventions
- `docs/VM_DEMO_ACCEPTANCE.md` — VM demo acceptance criteria (2 GB RAM, QEMU/KVM, core UX requirements)

### Architecture
- `.planning/research/ARCHITECTURE.md` — Recommended mkarchiso profile structure, component boundaries, data flow, build pipeline design
- `.planning/research/STACK.md` — Technology recommendations: Arch + mkarchiso + XFCE + LightDM, RAM budget analysis, package selection

### Constraints
- `AGENTS.md` — Agent operating rules: hard constraints (no custom kernel, no cloud deps, no secrets), required workflow, done criteria
- `context/CONSTRAINTS.md` — Hard constraints: Arch-based, mkarchiso, no custom kernel/pkg manager, local-first, stability over novelty
- `.planning/research/PITFALLS.md` — 13 pitfalls including base system contradiction, RAM budget, profile misconfiguration

### Requirements
- `.planning/REQUIREMENTS.md` — Phase 1 requirements: BOOT-03, BUILD-01, BUILD-02, DOC-04
- `.planning/ROADMAP.md` — Phase 1 goal, success criteria, key deliverables

### ADRs
- `adr/0001-base-system.md` — Superseded by D-01. Documents original Debian decision.
- `adr/0002-demo-scope.md` — Demo scope boundaries
- `adr/0003-ai-runtime-boundaries.md` — AI integration must be optional and non-blocking

## Existing Code Insights

### Reusable Assets
- `scripts/validate-vm.sh` — Stub exists, can be adapted for VM validation
- `scripts/collect-system-report.sh` — Stub exists, can inform print-build-env.sh
- `scripts/make-context-bundle.sh` — Stub exists, pattern for artifact collection

### Established Patterns
- Validation gates G0-G8 are defined and ordered — must be sequential
- Artifact naming: `aetheros-v0.1.0-demo.1-YYYYMMDDTHHMMSSZ-g<shortsha>.iso`
- Release manifest structure: MANIFEST.md, SHA256SUMS, build-env.txt, package-list.txt, validation-summary.md, known-issues.md
- Commit style: `feat:`, `fix:`, `docs:`, `build:`, `test:`, `chore:`

### Integration Points
- `profiles/aetheros/` is the single source of truth for the ISO — all build scripts reference this
- `out/` and `work/` are generated artifact directories (gitignored)
- `artifacts/releases/<version>/` is the release evidence directory

## Specific Ideas

- Use Arch's `releng` profile as the starting template for `profiles/aetheros/`
- Enable zram in the profile for 2 GB RAM optimization
- LightDM auto-login for demo experience
- `linux-lts` kernel preferred over `linux` for stability

## Deferred Ideas

- **RECOG features (Living Archive)** — Content auto-categorization deferred to Phase 4
- **Aether Workbench launcher** — Deferred to Phase 3
- **Backup tooling (borg/restic)** — Deferred to Phase 3/4
- **AI assistant integration** — .env.example stub in Phase 3, full integration post-demo
- **Debian bootstrap as Plan B** — Could be revived post-demo for physical hardware installs

---

*Phase 01-Foundation & Build System*
*Context gathered: 2026-06-03*