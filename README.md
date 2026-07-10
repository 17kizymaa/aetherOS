# aetherOS

aetherOS turns old and low-end computers into calm local production workstations.

Built for independents, artists, and small businesses, it combines a lightweight Linux base with opinionated project workflows, backup/recovery tools, local documentation, and optional AI assistance.

## Quick Start

```sh
# Prerequisites: Arch Linux host
sudo pacman -Syu --needed archiso qemu-full edk2-ovmf shellcheck git jq

# Validate repo state (G0-G3)
./scripts/validate.sh

# Validate profile integrity (G1-G2)
./scripts/validate-profile.sh

# Capture build environment metadata
./scripts/print-build-env.sh

# Build ISO (produces out/*.iso)
./scripts/build-iso.sh

# Smoke test in QEMU (2 GB RAM)
./scripts/smoke-qemu.sh out/*.iso

# Collect artifacts (SHA256, manifest)
./scripts/collect-artifacts.sh

# Profile: profiles/aetheros/ is the single source of truth for the ISO
```

## Project Structure

```
├── AGENTS.md              # Agent operating rules
├── CHANGELOG.md           # Release changelog
├── README.md              # This file
├── VERSION                # Current version string
├── docs/                  # Operational docs
│   ├── decisions/         # Architecture decision records
│   │   └── ADR-0004-use-archiso.md
│   ├── SPRINT_OPERATIONS.md
│   ├── BUILD_PIPELINE.md
│   └── VM_DEMO_ACCEPTANCE.md
├── profiles/
│   └── aetheros/          # mkarchiso profile (single source of truth)
│       ├── profiledef.sh
│       ├── packages.x86_64
│       ├── pacman.conf
│       ├── syslinux/      # BIOS boot config
│       ├── grub/          # UEFI GRUB config
│       └── efiboot/       # systemd-boot UEFI config
├── scripts/               # Build and validation scripts
│   ├── validate.sh
│   ├── validate-profile.sh
│   ├── print-build-env.sh
│   ├── build-iso.sh
│   ├── smoke-qemu.sh
│   └── collect-artifacts.sh
├── artifacts/
│   └── releases/
│       └── v0.1.0-demo.1/ # Release evidence (SHA256SUMS, MANIFEST.md)
├── context/               # AI context files
├── adr/                   # Legacy ADRs
└── deprecated/            # Archived Debian artifacts
```

## Demo Goal

A 2 GB RAM VM demo that boots to a lightweight desktop with terminal, file manager, text editor, and documentation access -- without cloud dependencies.

See `docs/VM_DEMO_ACCEPTANCE.md` for complete success criteria.
