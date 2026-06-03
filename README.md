# aetherOS

aetherOS turns old and low-end computers into calm local production workstations.

Built for independents, artists, and small businesses, it combines a lightweight Linux base with opinionated project workflows, backup/recovery tools, local documentation, and optional AI assistance.

## Quick Start

```sh
# Prerequisites: Arch Linux (host or VM), archiso, qemu-desktop
sudo pacman -Syu --needed archiso qemu-desktop edk2-ovmf shellcheck git

# Validate repo state
./scripts/validate.sh

# Build ISO
./scripts/build-iso.sh

# Smoke test in QEMU
./scripts/smoke-qemu.sh out/*.iso
```

## Project Structure

```
├── AGENTS.md              # Agent operating rules
├── README.md              # This file
├── docs/                  # Operational docs
│   ├── SPRINT_OPERATIONS.md
│   ├── BUILD_PIPELINE.md
│   └── VM_DEMO_ACCEPTANCE.md
├── profiles/              # mkarchiso profile
├── scripts/               # Build and validation scripts
├── context/               # AI context files
└── adr/                   # Architecture decision records
```

## Demo Goal

A 2 GB RAM VM demo that boots to a lightweight desktop with terminal, file manager, text editor, and documentation access—without cloud dependencies.

See `docs/VM_DEMO_ACCEPTANCE.md` for complete success criteria.