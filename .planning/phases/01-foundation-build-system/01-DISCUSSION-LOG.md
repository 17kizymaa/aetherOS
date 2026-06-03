# Phase 1: Foundation & Build System - Discussion Log

**Date:** 2026-06-03
**Areas discussed:** 5

## Decisions

| # | Area | Decision | Rationale |
|---|------|----------|-----------|
| 1 | Base system | Arch Linux + mkarchiso | Weight of documentation supports Arch; ADR-0001 superseded |
| 2 | Desktop | XFCE | Lightweight (~300-400 MB RAM), well-documented for Arch |
| 3 | Profile scope | Minimal bootable | Just enough to reach XFCE; UX packages in Phase 2 |
| 4 | Build scripts | All referenced scripts | validate.sh, build-iso.sh, smoke-qemu.sh, collect-artifacts.sh, validate-profile.sh, print-build-env.sh |
| 5 | Debian artifacts | Archive/remove | Clean break from Debian for v0.1 |
| 6 | Validation gates | G0-G6 | Push through VM boot smoke to de-risk Phase 2 |

## Deferred

- RECOG features → Phase 4
- Aether Workbench → Phase 3
- Backup tooling → Phase 3/4
- AI assistant → Phase 3 (stub), post-demo (full)
- Debian bootstrap Plan B → post-demo

## Open Questions

- Exact package list for minimal profile (rely on Arch releng)
- linux vs linux-lts kernel (recommend lts for stability)
- deprecated/ directory structure for archived Debian artifacts