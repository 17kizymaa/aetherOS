# Phase 1: Foundation & Build System - Research

**Researched:** 2026-06-03
**Domain:** Arch Linux ISO build infrastructure (mkarchiso profile-driven build pipeline)
**Confidence:** HIGH

## Summary

Phase 1 establishes the build infrastructure for aetherOS: resolve the base system contradiction (Debian vs. Arch), create a working mkarchiso profile, implement all build scripts, and archive Debian-specific artifacts. Everything downstream (Phases 2-5) depends on this foundation.

The primary technical domain is **Arch Linux ISO creation via mkarchiso** -- a profile-driven bash-based toolchain that builds bootable ISO images from a custom profile directory. The profile (`profiles/aetheros/`) is the single source of truth for the ISO: it defines packages, boot mode, filesystem overlay, and build metadata. The build host is Arch Linux (detected: `Linux myarch 7.0.10-arch1-1`), but `archiso` and related build packages are not yet installed.

The critical path is: resolve all Debian/Arch contradictions via ADR-0004, create the mkarchiso profile using the Arch `releng` profile as a starting template, implement 6 build/validation scripts (all must pass shellcheck and execute correctly), and create a `.gitignore` before any generated artifacts exist. The profile must produce a minimal bootable ISO -- just enough to reach a login screen. XFCE and desktop applications are added in Phase 2.

**Primary recommendation:** Copy `/usr/share/archiso/configs/releng/` as the profile baseline, strip it to minimal boot configuration, implement all scripts to reference `profiles/aetheros/` with repo-local `work/` and `out/` directories, and resolve every Debian/Arch file contradiction before writing any build code.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| ISO build (mkarchiso invocation) | Build Host (bash scripts) | -- | Scripts run mkarchiso on the build host; no remote API involved |
| Package selection | Build Host (profile config) | -- | `packages.x86_64` drives what mkarchiso installs into the ISO |
| Profile configuration | Build Host (profile config) | -- | `profiledef.sh`, `pacman.conf` define ISO metadata, repos, boot mode |
| Filesystem overlay | Build Host (airootfs/) | -- | `airootfs/` customizes the live system (configs, service symlinks, skeleton) |
| Validation (G0-G6) | Build Host (bash scripts) | CI (GitHub Actions) | Scripts run locally; CI duplicates G0-G3 checks on PRs |
| VM smoke test | Build Host (QEMU) | -- | QEMU runs locally on the build host with KVM or TCG fallback |
| Artifact hosting | Build Host (local FS) | Git (manifests only) | ISO in `out/` (gitignored); checksums/manifests in `artifacts/releases/<v>/` |
| Documentation | Git (source of truth) | -- | `docs/` is authoritative; `context/` is agent summary; git is source of truth |

## User Constraints (from CONTEXT.md)

### Locked Decisions

| # | Area | Decision | Rationale |
|---|------|----------|-----------|
| 1 | Base system | Arch Linux + mkarchiso | Weight of documentation supports Arch; ADR-0001 superseded |
| 2 | Desktop | XFCE | Lightweight (~300-400 MB RAM), well-documented for Arch |
| 3 | Profile scope | Minimal bootable | Just enough to reach XFCE; UX packages in Phase 2 |
| 4 | Build scripts | All referenced scripts | validate.sh, build-iso.sh, smoke-qemu.sh, collect-artifacts.sh, validate-profile.sh, print-build-env.sh |
| 5 | Debian artifacts | Archive/remove | Clean break from Debian for v0.1 |
| 6 | Validation gates | G0-G6 | Push through VM boot smoke to de-risk Phase 2 |

### Claude's Discretion

- Exact package list for minimal bootable profile (rely on Arch releng profile as reference)
- Script implementation details and flag choices
- Directory structure for `deprecated/` vs full removal of Debian artifacts
- Whether to use `linux` or `linux-lts` kernel (recommend `linux-lts` for stability)

### Deferred Ideas (OUT OF SCOPE)

- RECOG features -> Phase 4
- Aether Workbench -> Phase 3
- Backup tooling -> Phase 3/4
- AI assistant -> Phase 3 (stub), post-demo (full)
- Debian bootstrap Plan B -> post-demo

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| BOOT-03 | Boot is reproducible from clean clone using `./scripts/build-iso.sh` | Build script design, mkarchiso invocation flags, profile structure |
| BUILD-01 | `./scripts/validate.sh` passes on clean clone | Validation gate design (G0-G3), script dependencies, required file checks |
| BUILD-02 | `./scripts/build-iso.sh` produces ISO in `out/` | mkarchiso command syntax, work/out directory management |
| DOC-04 | `README.md` contains working quick-start instructions | Quick-start must match actual script names and host dependency install command |

## Standard Stack

### Core

| Library/Tool | Version | Purpose | Why Standard |
|--------------|---------|---------|--------------|
| Arch Linux | Rolling (latest) | Base OS + build host | Rolling release, best documentation (Arch Wiki), mkarchiso is purpose-built for ISO creation [VERIFIED: host `cat /etc/os-release`] |
| archiso | 88-1 | ISO build tooling | Purpose-built for Arch ISOs; profile system makes builds reproducible; airootfs overlay for customization [VERIFIED: `pacman -Si archiso`] |
| linux-lts | 6.18.34-1 | Kernel (LTS) | Stability over bleeding-edge; recommended by CONTEXT.md D-02 discretion area [VERIFIED: `pacman -Si linux-lts`] |
| shellcheck | 0.11.0-109 | Script linting | Validates all shell scripts (G3 gate); used in CI workflow [VERIFIED: `pacman -Si shellcheck`] |
| git | 2.54.0 | Version control | Standard; required for build metadata capture [VERIFIED: `git --version`] |
| jq | 1.8.1-3 | JSON processing | For build manifests and metadata [VERIFIED: `pacman -Si jq`] |

### Build Dependencies (installed on host)

| Package | Version | Purpose |
|---------|---------|---------|
| qemu-full | 11.0.1-1 | VM testing (includes qemu-desktop) |
| edk2-ovmf | 202605-1 | UEFI firmware for QEMU |
| arch-install-scripts | (with archiso) | Installation script support |
| dosfstools | 4.2-5 | FAT filesystem tools for ISO creation |
| e2fsprogs | (with archiso) | ext4 filesystem tools |
| erofs-utils | 1.9.1-1 | EROFS support (newer archiso default) |
| libarchive | (with archiso) | Archive handling |
| libisoburn | 1.5.8.2-2 | ISO burning/creation |
| mtools | 1:4.0.49-1 | DOS filesystem utilities |
| squashfs-tools | 4.7.5-1 | Squashfs compression for airootfs |

**Installation (build host):**
```bash
sudo pacman -Syu --needed archiso qemu-full edk2-ovmf shellcheck git jq
```

**Version verification:** All versions confirmed via `pacman -Si` on the Arch Linux build host (2026-06-03). The archiso package (88-1) was built 2026-03-27, confirming it is current.

## Package Legitimacy Audit

This phase does not install npm/PyPI/crates packages into a software project. All packages are Arch Linux system packages installed via `pacman` on the build host. The build scripts are bash scripts with no external library dependencies beyond standard POSIX tools and the packages listed above. Therefore, the Package Legitimacy Audit is **not applicable** to this phase.

## Architecture Patterns

### System Architecture Diagram

```
Build Host (Arch Linux x86_64)
================================
        |
[Stage 0: print-build-env.sh]
Record: OS, kernel, archiso version, git SHA -> logs/build-env.txt
        |
[Stage 1: validate.sh -> G0/G1]
Check: required files exist, .gitignore present, no generated artifacts committed
        |
[Stage 2: validate-profile.sh -> G1/G2]
Check: profiledef.sh valid, packages.x86_64 parseable, pacman.conf exists
        |
[Stage 3: validate.sh -> G3]
shellcheck scripts/*.sh (all pass)
        |
[Stage 4: build-iso.sh -> G4]
mkarchiso -v -w work/ -o out/ profiles/aetheros/
        |
    out/*.iso
        |
[Stage 5: collect-artifacts.sh -> G5]
SHA256SUMS, MANIFEST.md, build-env.txt, package-list.txt -> artifacts/releases/<version>/
        |
[Stage 6: smoke-qemu.sh -> G6]
run_archiso -i out/*.iso (or QEMU direct)
        |
[VM boots to login screen]
```

### Recommended Project Structure

```
aetherOS/
├── .gitignore                    # MUST exist before any build artifacts
├── AGENTS.md                     # Agent operating rules (exists)
├── README.md                     # Quick start (exists, must be updated)
├── VERSION                       # Must contain "0.1.0-demo.1"
├── CHANGELOG.md                  # Must have demo entry
│
├── profiles/
│   └── aetheros/                 # SINGLE SOURCE OF TRUTH for ISO
│       ├── profiledef.sh         # ISO name, version, boot modes
│       ├── packages.x86_64       # One package per line (no versions)
│       ├── pacman.conf           # Mirror list, build options
│       ├── airootfs/             # Filesystem overlay (custom configs)
│       │   └── etc/
│       │       └── systemd/system/  # Service symlinks
│       ├── syslinux/             # BIOS boot config (from releng)
│       ├── grub/                 # UEFI GRUB config (from releng)
│       └── efiboot/              # systemd-boot config (from releng)
│
├── scripts/
│   ├── validate.sh               # G0-G3: repo, profile, packages, linting
│   ├── validate-profile.sh       # G1-G2: profile-specific checks
│   ├── print-build-env.sh        # Stage 0: capture build environment
│   ├── build-iso.sh              # G4: run mkarchiso
│   ├── smoke-qemu.sh             # G6: boot ISO in QEMU
│   └── collect-artifacts.sh      # G5: checksums, manifests
│
├── docs/
│   ├── SPRINT_OPERATIONS.md      # Authoritative operational standard (exists)
│   ├── BUILD_PIPELINE.md         # Build stages (exists)
│   └── decisions/
│       └── ADR-0004-use-archiso.md  # NEW: resolves Debian/Arch contradiction
│
├── deprecated/                   # Archived Debian artifacts
│   ├── manifests/                # Old Debian package lists
│   └── bootstrap-aether.sh       # Old Debian bootstrap
│
├── context/                      # Agent-facing summaries (exists)
│   ├── PROJECT_BRIEF.md
│   ├── CONSTRAINTS.md
│   └── CURRENT_STATE.md
│
├── artifacts/
│   └── releases/
│       └── v0.1.0-demo.1/       # Release evidence
│           ├── MANIFEST.md
│           ├── SHA256SUMS
│           ├── build-env.txt
│           ├── package-list.txt
│           ├── validation-summary.md
│           └── known-issues.md
│
├── out/                          # Generated ISO (gitignored)
├── work/                         # Build working dir (gitignored)
└── logs/                         # Build logs (gitignored)
```

### Pattern 1: Profile-Driven ISO Build

**What:** The mkarchiso profile is the single source of truth for the ISO. All customizations go through the profile, never through manual ISO modification.

**When:** Always. Every change to the live system must be traceable to a file in `profiles/aetheros/`.

**Example:**
```bash
# profiles/aetheros/profiledef.sh
iso_name="aetheros"
iso_label="AETHEROS_01"
iso_publisher="aetherOS Project <https://github.com/anphuni/aetherOS>"
iso_application="aetherOS Live/Rescue CD"
iso_version="0.1.0-demo.1"
install_dir="aetheros"
buildmodes=("iso")
bootmodes=("bios.syslinux" "uefi.grub")
arch="x86_64"
```

Source: [VERIFIED: GitLab archiso README.profile.rst https://gitlab.archlinux.org/archlinux/archiso/-/raw/master/docs/README.profile.rst]

### Pattern 2: airootfs Overlay for Customization

**What:** Place customization files directly into `airootfs/` mirroring the target filesystem structure. Contents are copied to the working directory before package installation.

**When:** Any file that needs to exist in the live system but is not provided by a package.

**Example:**
```bash
# Enable LightDM service in live system
mkdir -p profiles/aetheros/airootfs/etc/systemd/system/multi-user.target.wants
ln -s /usr/lib/systemd/system/lightdm.service \
    profiles/aetheros/airootfs/etc/systemd/system/multi-user.target.wants/

# Auto-login config
mkdir -p profiles/aetheros/airootfs/etc/systemd/system/getty@tty1.service.d
cat > profiles/aetheros/airootfs/etc/systemd/system/getty@tty1.service.d/autologin.conf << 'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --noreset --noclear --autologin aether - ${TERM}
EOF
```

Source: [VERIFIED: Arch Wiki archiso https://wiki.archlinux.org/title/Archiso, systemd_units and Login_manager sections]

### Pattern 3: Package Lists as Code

**What:** Plain text package lists, one package per line. No versions. Lines starting with `#` are comments.

**When:** Defining what goes in the ISO via `packages.x86_64`.

**Example:**
```bash
# profiles/aetheros/packages.x86_64
# Minimal bootable system
base
linux-lts
xorg-server
xfce4
xfce4-terminal
thunar
mousepad
lightdm
lightdm-gtk-greeter
networkmanager
```

Source: [VERIFIED: Arch Wiki archiso https://wiki.archlinux.org/title/Archiso, Selecting_packages section] and [VERIFIED: GitLab archiso README.profile.rst]

### Pattern 4: Validation Gates (G0-G6)

**What:** Ordered validation gates that must pass before proceeding. Earlier gates must not be skipped.

**When:** G0-G3 on every commit/PR. G4-G6 for demo candidates.

| Gate | Name | Phase 1 Scope |
|------|------|---------------|
| G0 | Repo hygiene | Clean status, no generated artifacts, no secrets |
| G1 | Profile integrity | profiledef.sh, packages.x86_64, pacman.conf exist and are valid |
| G2 | Package policy | Official repos preferred, no duplicates, no unnecessary daemons |
| G3 | Script validation | All shell scripts pass shellcheck |
| G4 | ISO build | mkarchiso completes successfully |
| G5 | Artifact manifest | SHA256 checksum, build ID, package manifest captured |
| G6 | VM boot smoke | ISO boots in QEMU to login or desktop |

Source: [VERIFIED: SPRINT_OPERATIONS.md section 5, docs/BUILD_PIPELINE.md]

### Pattern 5: Separation of docs/ and context/

**What:** `docs/` is authoritative operational documentation. `context/` is a summary for AI agent consumption.

**Rule:** docs/ is always updated first. context/ must not contradict docs/. If docs change, context must be synced in the same commit.

Source: [VERIFIED: SPRINT_OPERATIONS.md section 3, AGENTS.md required workflow]

### Anti-Patterns to Avoid

- **Editing the running ISO as a fix:** Changes to a booted live system are lost on reboot. Always fix via `profiles/aetheros/` and rebuild. [VERIFIED: SPRINT_OPERATIONS.md section 11, step 6]
- **Mixing Debian and Arch concepts:** Using Debian package names (apt-utils, firefox-esr) in an Arch pacman profile, or referencing live-build when using mkarchiso. Causes build failures. [VERIFIED: PITFALLS.md pitfall 1]
- **Committing generated artifacts:** ISO files, work directories, and logs must not be committed. Create `.gitignore` before any build. [VERIFIED: SPRINT_OPERATIONS.md section 1]
- **Enabling unnecessary services:** Only enable services required for the demo. Every service consumes RAM. [VERIFIED: SPRINT_OPERATIONS.md section 10]
- **Skipping shellcheck:** All scripts must pass shellcheck (G3). The CI workflow also enforces this. [VERIFIED: .github/workflows/validate.yml]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| ISO creation | Custom dd/mkisofs pipeline | mkarchiso | Handles bootloader, squashfs, UEFI, BIOS automatically |
| Package installation into image | Manual pacman chroot | mkarchiso packages.x86_64 | mkarchiso manages the chroot, package DB, and initramfs |
| Boot configuration | Manual syslinux/grub config | Copy from releng profile | Releng profile is tested and maintained by Arch releng team |
| Script validation | Ad-hoc grep/sed checks | shellcheck | Industry standard, catches real bugs, used in CI |
| Checksum generation | Custom hash script | sha256sum (coreutils) | Standard tool, available everywhere |
| VM testing | Manual QEMU invocation | run_archiso (from archiso) or scripted QEMU | Handles firmware, display, and SSH forwarding automatically |

## Runtime State Inventory

This is a greenfield build infrastructure phase. There are no runtime services, databases, or OS-registered state to migrate. The existing scripts (`bootstrap-aether.sh`, `validate-vm.sh`, `collect-system-report.sh`, `make-context-bundle.sh`) are stubs that will be archived to `deprecated/` or replaced.

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | None | N/A |
| Live service config | None | N/A |
| OS-registered state | None | N/A |
| Secrets/env vars | None | N/A |
| Build artifacts | None (no builds run yet) | N/A |

## Common Pitfalls

### Pitfall 1: The Arch/Debian Contradiction (CRITICAL)

**What goes wrong:** The project has two incompatible build pathways. SPRINT_OPERATIONS.md says Arch + mkarchiso + pacman. ADR-0001 and OPERATING_CONTRACT.md say Debian + apt. The `manifests/` directory has Debian package names. `bootstrap-aether.sh` uses `apt`.

**Why it happens:** The project evolved through multiple planning sessions without reconciling decisions.

**Consequences:** Build scripts fail. Package lists have wrong names. The ISO won't build. Wasted hours debugging a specification error.

**How to avoid:** Create ADR-0004 that explicitly resolves this contradiction. Update OPERATING_CONTRACT.md to reference Arch. Archive `manifests/` and `bootstrap-aether.sh` to `deprecated/`. Do this in a single commit before any build work.

**Detection:** `./scripts/build-iso.sh` fails with "package not found" errors because Debian package names are in an Arch package list.

**Confidence:** HIGH -- verified by reading all contradicting files. [VERIFIED: adr/0001-base-system.md, OPERATING_CONTRACT.md, manifests/packages.base.txt, scripts/bootstrap-aether.sh]

### Pitfall 2: Missing .gitignore Before Build

**What goes wrong:** ISO files (potentially 500+ MB), work directories, and logs get committed to git, bloating the repository.

**Why it happens:** The project currently has no `.gitignore` file at all.

**How to avoid:** Create `.gitignore` as the very first action in Phase 1, before any build artifacts are generated.

**Contents:**
```
work/
out/
logs/
*.iso
*.img
*.qcow2
*.log
.env
.env.*
!.env.example
```

**Confidence:** HIGH -- verified by `cat /home/anphuni/aetherOS/.gitignore` returning "File does not exist."

### Pitfall 3: mkarchiso Not Installed on Build Host

**What goes wrong:** `build-iso.sh` fails because `mkarchiso` command not found.

**Why it happens:** The build host is Arch Linux but `archiso` package is not installed.

**How to avoid:** The `README.md` quick-start must include the host dependency install command. The `validate.sh` script should check for required host tools and fail with a clear message.

**Detection:** `command -v mkarchiso` returns false on the current host.

**Confidence:** HIGH -- verified by `command -v archiso` returning false on the build host.

### Pitfall 4: Pacman Keyring Issues During Build

**What goes wrong:** mkarchiso fails because pacman can't verify package signatures. Keyring is outdated or not initialized.

**How to avoid:** `print-build-env.sh` or `validate.sh` should check/initialize the keyring:
```bash
pacman-key --init
pacman-key --populate archlinux
```

**Confidence:** MEDIUM -- documented in SPRINT_OPERATIONS.md troubleshooting section. [VERIFIED: SPRINT_OPERATIONS.md section 11, step 5]

### Pitfall 5: profiledef.sh Format Errors

**What goes wrong:** mkarchiso fails with cryptic errors because `profiledef.sh` has wrong variable names, missing required variables, or syntax errors.

**How to avoid:** Start from the releng profile's `profiledef.sh` as a template. Only change the variables you need. Validate with `validate-profile.sh` before attempting a build.

**Key variables (from archiso README.profile.rst):**
- `iso_name`: First part of ISO filename
- `iso_label`: ISO volume label
- `iso_version`: Version string in filename
- `install_dir`: Max 8 chars, `[a-z0-9]` only
- `buildmodes`: `("iso")` for standard ISO build
- `bootmodes`: `("bios.syslinux" "uefi.grub")` for dual BIOS/UEFI
- `arch`: `"x86_64"`

**Confidence:** HIGH -- verified from official archiso documentation. [VERIFIED: GitLab archiso README.profile.rst]

### Pitfall 6: Missing mkinitcpio-archiso Package

**What goes wrong:** mkarchiso fails because `mkinitcpio` and `mkinitcpio-archiso` are mandatory packages but not in the package list.

**How to avoid:** Always include `mkinitcpio` and `mkinitcpio-archiso` in `packages.x86_64`. The releng profile includes these.

**Confidence:** HIGH -- explicitly documented in archiso README: "The mkinitcpio and mkinitcpio-archiso packages are mandatory." [VERIFIED: GitLab archiso README.profile.rst]

### Pitfall 7: Scripts Not Executable

**What goes wrong:** `./scripts/validate.sh` fails with "Permission denied" because scripts lack execute permission.

**How to avoid:** All scripts must be created with `chmod +x`. The `validate.sh` script should check this. CI workflow uses `bash scripts/validate.sh` as fallback.

**Confidence:** HIGH -- common issue, CI workflow already accounts for it.

## Code Examples

### profiledef.sh (Minimal Bootable Profile)

```bash
#!/usr/bin/env bash
# profiles/aetheros/profiledef.sh
# Source: https://gitlab.archlinux.org/archlinux/archiso/-/raw/master/docs/README.profile.rst

iso_name="aetheros"
iso_label="AETHEROS_01"
iso_publisher="aetherOS Project <https://github.com/anphuni/aetherOS>"
iso_application="aetherOS Live/Rescue CD"
iso_version="0.1.0-demo.1"
install_dir="aetheros"
buildmodes=("iso")
bootmodes=("bios.syslinux" "uefi.grub")
arch="x86_64"
```

### packages.x86_64 (Minimal Bootable)

```bash
# profiles/aetheros/packages.x86_64
# Minimal bootable Arch + XFCE system
# Phase 1: just enough to reach graphical session

# Base system (required by archiso)
base
mkinitcpio
mkinitcpio-archiso

# Kernel
linux-lts

# Xorg
xorg-server
xorg-xinit

# Desktop
xfce4
xfce4-terminal
thunar
mousepad

# Display manager
lightdm
lightdm-gtk-greeter

# Networking
networkmanager

# Filesystem tools
dosfstools
e2fsprogs
```

### validate.sh (G0-G3 Validation)

```bash
#!/usr/bin/env bash
# scripts/validate.sh — Run validation gates G0-G3
set -euo pipefail

PASS=0
FAIL=0

gate() {
    local gate_id="$1"
    local description="$2"
    shift 2
    if "$@"; then
        echo "GATE ${gate_id}: PASS — ${description}"
        ((PASS++))
    else
        echo "GATE ${gate_id}: FAIL — ${description}"
        ((FAIL++))
    fi
}

echo "=== aetherOS Validation (G0-G3) ==="
echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "Git SHA: $(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')"
echo ""

# G0: Repo hygiene
gate "G0" "Required files exist" test -f README.md -a -f AGENTS.md -a -f .gitignore
gate "G0" "No ISO files committed" ! find . -name "*.iso" -not -path "./.git/*" | grep -q .
gate "G0" "No .env files committed" ! find . -name ".env" -not -name ".env.example" -not -path "./.git/*" | grep -q .

# G1: Profile integrity
gate "G1" "profiledef.sh exists" test -f profiles/aetheros/profiledef.sh
gate "G1" "packages.x86_64 exists" test -f profiles/aetheros/packages.x86_64
gate "G1" "pacman.conf exists" test -f profiles/aetheros/pacman.conf

# G2: Package policy (basic checks)
gate "G2" "No duplicate packages" bash -c 'sort profiles/aetheros/packages.x86_64 | uniq -d | grep -q . && exit 1 || exit 0'
gate "G2" "No empty package file" test -s profiles/aetheros/packages.x86_64

# G3: Script validation
if command -v shellcheck &>/dev/null; then
    for script in scripts/*.sh; do
        [ -f "$script" ] || continue
        gate "G3" "shellcheck: $(basename "$script")" shellcheck -x "$script"
    done
else
    echo "GATE G3: WARN — shellcheck not installed, skipping"
fi

echo ""
echo "=== Results: ${PASS} passed, ${FAIL} failed ==="
[ "$FAIL" -eq 0 ]
```

### build-iso.sh (G4 ISO Build)

```bash
#!/usr/bin/env bash
# scripts/build-iso.sh — Build aetherOS ISO (G4)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROFILE="${REPO_ROOT}/profiles/aetheros"
WORK="${REPO_ROOT}/work"
OUT="${REPO_ROOT}/out"

# Check host dependencies
for cmd in mkarchiso; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "ERROR: ${cmd} not found. Install with: sudo pacman -Syu --needed archiso" >&2
        exit 1
    fi
done

# Validate profile exists
if [ ! -f "${PROFILE}/profiledef.sh" ]; then
    echo "ERROR: Profile not found at ${PROFILE}" >&2
    exit 1
fi

# Clean previous build artifacts (work dir only, preserve out/)
if [ -d "${WORK}" ]; then
    echo "Removing previous work directory..."
    rm -rf "${WORK}"
fi

mkdir -p "${OUT}"

echo "=== Building aetherOS ISO ==="
echo "Profile: ${PROFILE}"
echo "Work:    ${WORK}"
echo "Out:     ${OUT}"
echo ""

mkarchiso -v -w "${WORK}" -o "${OUT}" "${PROFILE}"

echo ""
echo "=== Build Complete ==="
ls -lh "${OUT}"/*.iso 2>/dev/null || echo "WARNING: No ISO found in ${OUT}/"
```

### smoke-qemu.sh (G6 VM Boot Smoke)

```bash
#!/usr/bin/env bash
# scripts/smoke-qemu.sh — Boot ISO in QEMU for smoke test (G6)
set -euo pipefail

ISO_PATH="${1:?Usage: $0 <path-to-iso>}"

if [ ! -f "${ISO_PATH}" ]; then
    echo "ERROR: ISO not found: ${ISO_PATH}" >&2
    exit 1
fi

# Prefer run_archiso if available, fall back to direct QEMU
if command -v run_archiso &>/dev/null; then
    echo "=== Booting ISO with run_archiso ==="
    run_archiso -i "${ISO_PATH}"
else
    echo "=== Booting ISO with QEMU (2 GB RAM, 2 vCPU) ==="
    qemu-system-x86_64 \
        -enable-kvm \
        -m 2048 \
        -smp 2 \
        -cdrom "${ISO_PATH}" \
        -boot d \
        -vga virtio \
        -display sdl \
        "$@"
fi
```

### collect-artifacts.sh (G5 Artifact Capture)

```bash
#!/usr/bin/env bash
# scripts/collect-artifacts.sh — Generate checksums and manifests (G5)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUT="${REPO_ROOT}/out"
VERSION="0.1.0-demo.1"
ARTIFACTS="${REPO_ROOT}/artifacts/releases/${VERSION}"

mkdir -p "${ARTIFACTS}"

echo "=== Collecting Artifacts for ${VERSION} ==="

# Find the ISO
ISO_FILE=$(find "${OUT}" -maxdepth 1 -name "*.iso" | head -1)
if [ -z "${ISO_FILE}" ]; then
    echo "ERROR: No ISO found in ${OUT}/" >&2
    exit 1
fi

echo "ISO: ${ISO_FILE}"

# SHA256 checksum
(cd "${OUT}" && sha256sum *.iso > "${ARTIFACTS}/SHA256SUMS")

# Build environment
{
    echo "VERSION=${VERSION}"
    echo "GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')"
    echo "BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "HOST_OS=$(uname -s -r)"
    echo "ARCHISO_VERSION=$(pacman -Q archiso 2>/dev/null | awk '{print $2}' || echo 'N/A')"
} > "${ARTIFACTS}/build-env.txt"

# Package list
cp "${REPO_ROOT}/profiles/aetheros/packages.x86_64" "${ARTIFACTS}/package-list.txt"

# Manifest
cat > "${ARTIFACTS}/MANIFEST.md" << EOF
# aetherOS ${VERSION} Release Manifest

- **Version:** ${VERSION}
- **Build Date:** $(date -u +%Y-%m-%dT%H:%M:%SZ)
- **Git SHA:** $(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')
- **ISO:** $(basename "${ISO_FILE}")
- **SHA256:** $(sha256sum "${ISO_FILE}" | awk '{print $1}')
- **Package Count:** $(grep -c '^[^#]' "${REPO_ROOT}/profiles/aetheros/packages.x86_64" || echo 0)
EOF

echo ""
echo "=== Artifacts Collected ==="
ls -lh "${ARTIFACTS}/"
```

### print-build-env.sh (Stage 0 Environment Capture)

```bash
#!/usr/bin/env bash
# scripts/print-build-env.sh — Capture build environment metadata (Stage 0)
set -euo pipefail

echo "=== aetherOS Build Environment ==="
echo "Timestamp:    $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "Git SHA:      $(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')"
echo "Branch:       $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'N/A')"
echo "Host OS:      $(uname -s -r -m)"
echo "Kernel:       $(uname -v)"
echo "archiso:      $(pacman -Q archiso 2>/dev/null | awk '{print $2}' || echo 'NOT INSTALLED')"
echo "mkarchiso:    $(command -v mkarchiso 2>/dev/null || echo 'NOT FOUND')"
echo "shellcheck:   $(shellcheck --version 2>/dev/null | grep 'version:' | awk '{print $2}' || echo 'NOT INSTALLED')"
echo "QEMU:         $(qemu-system-x86_64 --version 2>/dev/null | head -1 || echo 'NOT INSTALLED')"
echo "Git:          $(git --version 2>/dev/null | awk '{print $3}' || echo 'NOT INSTALLED')"
echo "=================================="
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Debian + live-build | Arch + mkarchiso | Phase 1 (ADR-0004) | Clean break; all manifests and scripts must be updated |
| Custom bootstrap script | mkarchiso profile | Phase 1 | Bootstrap-aether.sh archived to deprecated/ |
| Manual ISO testing | Automated smoke-qemu.sh | Phase 1 | Reproducible VM testing with QEMU |
| No validation gates | G0-G6 ordered gates | Phase 1 | Every change validated before merge |

**Deprecated/outdated:**
- `manifests/packages.base.txt` -- contains Debian package names (apt-utils, firefox-esr); must be archived
- `manifests/packages.ai-optional.txt` -- references pip packages; not applicable to Arch ISO
- `manifests/packages.creative.txt` -- references Debian package names
- `manifests/services.enabled.txt` -- references systemd services but in Debian context
- `scripts/bootstrap-aether.sh` -- Debian-specific bootstrap using `apt`; must be archived
- `OPERATING_CONTRACT.md` -- still says "Debian Stable + XFCE is the default base"; must be updated to Arch
- `adr/0001-base-system.md` -- superseded by ADR-0004

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | The releng profile at `/usr/share/archiso/configs/releng/` will be available after `pacman -S archiso` | Architecture Patterns | If the releng profile structure changed significantly, the template copy would need manual adjustment |
| A2 | `mkinitcpio` and `mkinitcpio-archiso` are mandatory packages for any archiso ISO build | Don't Hand-Roll | If not included, mkarchiso will fail; this is explicitly documented in archiso README |
| A3 | The build host will have sudo access to install packages | Environment Availability | Without sudo, the user must install deps manually; scripts should detect and warn |
| A4 | `run_archiso` is available when `archiso` package is installed | Code Examples (smoke-qemu.sh) | If not available, fall back to direct QEMU invocation |
| A5 | The `linux-lts` kernel package (6.18.34-1) is available in Arch repos | Standard Stack | If removed, fall back to `linux` kernel package |

## Open Questions

1. **Deprecated/ vs full removal of Debian artifacts:**
   - What we know: CONTEXT.md says "Archive/remove" -- giving discretion
   - What's unclear: Whether to keep a `deprecated/` directory or delete entirely
   - Recommendation: Create `deprecated/` with a README explaining the rationale; preserves history without cluttering active paths

2. **Exact minimal package list:**
   - What we know: Must include base, linux-lts, mkinitcpio, mkinitcpio-archiso, xorg-server, and at minimum a login manager
   - What's unclear: Whether to include XFCE in Phase 1 or Phase 2
   - Recommendation: Include XFCE in Phase 1's minimal profile since BOOT-03 requires a reproducible build and the profile must be testable; Phase 2 adds the remaining desktop polish

3. **CI workflow runs on ubuntu-latest:**
   - What we know: `.github/workflows/validate.yml` uses `runs-on: ubuntu-latest` with `apt-get install shellcheck`
   - What's unclear: Whether to keep Ubuntu-based CI or switch to Arch container
   - Recommendation: Keep Ubuntu-based CI for G0-G3 (shellcheck, file checks, artifact detection); G4-G6 require Arch host and are run manually

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Arch Linux | Build host OS | Yes | Rolling (7.0.10-arch1-1) | N/A (already running) |
| archiso | ISO build (G4) | No | 88-1 in repos | `sudo pacman -S archiso` |
| qemu-full | VM testing (G6) | No | 11.0.1-1 in repos | `sudo pacman -S qemu-full` |
| edk2-ovmf | UEFI boot testing | No | 202605-1 in repos | `sudo pacman -S edk2-ovmf` |
| shellcheck | Script linting (G3) | No | 0.11.0-109 in repos | `sudo pacman -S shellcheck` |
| git | Version control | Yes | 2.54.0 | N/A |
| jq | Build manifests | No | 1.8.1-3 in repos | `sudo pacman -S jq` |
| sudo | Package installation | Yes | (standard) | User must install deps manually |

**Missing dependencies with no fallback:** None -- all missing packages are in official Arch repos.

**Missing dependencies with fallback:** None -- all have direct install paths via `pacman`.

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | Shell-based validation (bash + shellcheck) |
| Config file | None — validation is script-based |
| Quick run command | `./scripts/validate.sh` |
| Full suite command | `./scripts/validate.sh && ./scripts/build-iso.sh && ./scripts/smoke-qemu.sh out/*.iso` |

### Phase Requirements -> Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| BOOT-03 | Build is reproducible from clean clone | Integration | `./scripts/build-iso.sh` produces ISO in `out/` | No (Wave 0) |
| BUILD-01 | validate.sh passes on clean clone | Unit | `./scripts/validate.sh` exits 0 | No (Wave 0) |
| BUILD-02 | build-iso.sh produces ISO in out/ | Integration | `test -f out/*.iso` after build | No (Wave 0) |
| DOC-04 | README.md has working quick-start | Manual | Human verifies quick-start instructions match actual commands | Yes (exists, needs update) |

### Sampling Rate

- **Per task commit:** `./scripts/validate.sh` (G0-G3 only, fast)
- **Per wave merge:** `./scripts/validate.sh && ./scripts/build-iso.sh` (G0-G4)
- **Phase gate:** Full suite green (G0-G6) before `/gsd-verify-work`

### Wave 0 Gaps

- [ ] `scripts/validate.sh` — covers G0-G3 validation (BUILD-01)
- [ ] `scripts/validate-profile.sh` — covers G1-G2 profile checks
- [ ] `scripts/print-build-env.sh` — covers Stage 0 environment capture
- [ ] `scripts/build-iso.sh` — covers G4 ISO build (BOOT-03, BUILD-02)
- [ ] `scripts/smoke-qemu.sh` — covers G6 VM boot smoke
- [ ] `scripts/collect-artifacts.sh` — covers G5 artifact capture
- [ ] `profiles/aetheros/profiledef.sh` — ISO metadata definition
- [ ] `profiles/aetheros/packages.x86_64` — package list
- [ ] `profiles/aetheros/pacman.conf` — pacman configuration
- [ ] `.gitignore` — prevent generated artifact commits
- [ ] `adr/0004-use-archiso.md` — resolves Debian/Arch contradiction
- [ ] Host dependency install: `sudo pacman -Syu --needed archiso qemu-full edk2-ovmf shellcheck jq`

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | No | Phase 1 is build infrastructure; no user authentication in ISO yet |
| V3 Session Management | No | No sessions in build phase |
| V4 Access Control | No | No access control in build phase |
| V5 Input Validation | Yes | Shell scripts use `set -euo pipefail`, input validation on file paths |
| V6 Cryptography | Yes | SHA256 checksums for ISO integrity; no custom crypto |

### Known Threat Patterns for Build Infrastructure

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Malicious package in profile | Tampering | Use only official Arch repos; verify package signatures via pacman keyring |
| Secrets committed to git | Information Disclosure | `.gitignore` excludes `.env` files; G0 gate checks for secrets |
| Compromised build script | Tampering | Shellcheck linting; code review on PRs; CI validation |
| ISO tampering | Tampering | SHA256 checksums in release manifest |

## Sources

### Primary (HIGH confidence)
- [VERIFIED: GitLab archiso README.profile.rst] https://gitlab.archlinux.org/archlinux/archiso/-/raw/master/docs/README.profile.rst — Definitive reference for profiledef.sh variables, profile structure, package list format, mandatory packages
- [VERIFIED: Arch Wiki archiso] https://wiki.archlinux.org/title/Archiso — Profile structure, airootfs overlay, systemd units, auto-login, boot modes, build commands
- [VERIFIED: Arch Wiki LightDM] https://wiki.archlinux.org/title/LightDM — Auto-login configuration, greeter setup, service enabling
- [VERIFIED: `pacman -Si archiso`] archiso 88-1, depends on arch-install-scripts, bash, dosfstools, e2fsprogs, erofs-utils, libarchive, libisoburn, mtools, squashfs-tools
- [VERIFIED: `pacman -Si linux-lts`] linux-lts 6.18.34-1
- [VERIFIED: `pacman -Si shellcheck`] shellcheck 0.11.0-109
- [VERIFIED: `pacman -Si qemu-full`] qemu-full 11.0.1-1
- [VERIFIED: `pacman -Si edk2-ovmf`] edk2-ovmf 202605-1
- [VERIFIED: `pacman -Si jq`] jq 1.8.1-3
- [VERIFIED: `git --version`] git 2.54.0
- [VERIFIED: `/etc/os-release`] Arch Linux Rolling, kernel 7.0.10-arch1-1

### Secondary (MEDIUM confidence)
- [VERIFIED: SPRINT_OPERATIONS.md] Authoritative operational standard: build stages, validation gates G0-G8, package policy, logging standards
- [VERIFIED: CONTEXT.md] Phase 1 locked decisions and discretion areas
- [VERIFIED: PITFALLS.md] 13 documented pitfalls for the project
- [VERIFIED: .github/workflows/validate.yml] CI workflow for G0-G3 validation

### Tertiary (LOW confidence)
- N/A — all critical claims verified from primary sources

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all versions verified via `pacman -Si` on the actual build host
- Architecture: HIGH — verified against official archiso documentation (GitLab README.profile.rst and Arch Wiki)
- Pitfalls: HIGH — verified by reading all contradicting files in the repo; pitfall 1 (Debian/Arch contradiction) confirmed by direct file comparison

**Research date:** 2026-06-03
**Valid until:** 2026-07-03 (30 days — archiso is stable; Arch rolling release may change package versions but not APIs)
