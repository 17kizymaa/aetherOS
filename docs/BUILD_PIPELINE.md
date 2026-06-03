# Build Pipeline

## Host Requirements

- Arch Linux (preferred) or clean Arch VM
- `archiso`, `qemu-desktop`, `edk2-ovmf`, `shellcheck`, `git`

```sh
sudo pacman -Syu --needed archiso qemu-desktop edk2-ovmf shellcheck git
```

## Pipeline Stages

| Stage | Input | Action | Output |
|-------|-------|--------|--------|
| 0. Environment capture | Host system | Record OS, kernel, archiso version, git SHA | Build environment log |
| 1. Repo validation | Git checkout | Check required files, ignored artifacts, docs presence | Validation result |
| 2. Profile validation | profiles/aetheros/ | Check profiledef.sh, packages.x86_64, pacman.conf, permissions | Profile validation log |
| 3. Package review | packages.x86_64 | Check duplicate/heavy/unapproved packages | Package review result |
| 4. ISO build | mkarchiso profile | Run mkarchiso with repo-local work/out dirs | ISO in out/ |
| 5. Artifact capture | ISO + logs | Generate checksum, manifest, package list, build metadata | Release artifact folder |
| 6. VM smoke boot | ISO | Boot with QEMU/KVM or software fallback | QEMU log and pass/fail note |

## Commands

```sh
# Validate repo state
./scripts/validate.sh

# Build ISO
./scripts/build-iso.sh

# Smoke test
./scripts/smoke-qemu.sh out/*.iso

# Collect artifacts
./scripts/collect-artifacts.sh
```

## Artifact Naming

```
aetherOS-vm-demo-YYYYMMDD-<shortsha>.<ext>
```

Example:
```
aetherOS-vm-demo-20260602-a1b2c3d.qcow2
```

## Build Manifest Location

```
artifacts/releases/<version>/MANIFEST.md
```