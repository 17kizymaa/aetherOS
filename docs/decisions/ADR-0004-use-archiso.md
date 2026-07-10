# ADR 0004 — Use Arch Linux + mkarchiso as base system

## Status

Accepted (supersedes ADR-0001) — confirmed by 17kizymaa 2026-07-10 (sprint gate G6)

## Decision

Arch Linux + mkarchiso is the build base for aetherOS v0.1.

## Rationale

- **mkarchiso is purpose-built for ISO creation.** It is the official Arch Linux tool for building bootable ISO images, with first-class support for both BIOS (syslinux) and UEFI (grub/systemd-boot) boot modes.
- **Arch Wiki documentation quality.** The Arch Wiki provides comprehensive, up-to-date documentation for mkarchiso, pacman, and XFCE configuration, reducing build troubleshooting time.
- **Weight of project documentation.** SPRINT_OPERATIONS.md, BUILD_PIPELINE.md, and RESEARCH.md all specify Arch Linux + mkarchiso as the build pathway. The project's build scripts, package lists, and profile structure follow Arch conventions.

## Consequences

- ADR-0001 (Debian Stable + live-build) is superseded and no longer valid.
- OPERATING_CONTRACT.md must be updated to reference Arch Linux instead of Debian Stable.
- `manifests/` directory content is invalid (Debian package names for apt).
- `scripts/bootstrap-aether.sh` is invalid (uses `apt` commands).
- All build scripts use `pacman` and Arch package names.

## Supersedes

- ADR-0001 — Use Debian Stable + live-build as base system
