# Phase 1: Foundation & Build System - Pattern Map

**Mapped:** 2026-06-03
**Files analyzed:** 15 (10 new, 5 modified)
**Analogs found:** 12 / 15

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `.gitignore` | config | file-I/O | `.github/workflows/validate.yml` (artifact patterns) | partial |
| `scripts/validate.sh` | utility | batch | `scripts/validate-vm.sh` | role-match |
| `scripts/validate-profile.sh` | utility | batch | `scripts/collect-system-report.sh` | role-match |
| `scripts/print-build-env.sh` | utility | batch | `scripts/collect-system-report.sh` | role-match |
| `scripts/build-iso.sh` | utility | batch | `scripts/bootstrap-aether.sh` | role-match |
| `scripts/smoke-qemu.sh` | utility | batch | `scripts/validate-vm.sh` | role-match |
| `scripts/collect-artifacts.sh` | utility | batch | `scripts/make-context-bundle.sh` | role-match |
| `profiles/aetheros/profiledef.sh` | config | file-I/O | `manifests/packages.base.txt` (config concept) | partial |
| `profiles/aetheros/packages.x86_64` | config | file-I/O | `manifests/packages.base.txt` | role-match |
| `profiles/aetheros/pacman.conf` | config | file-I/O | `manifests/services.enabled.txt` (config concept) | partial |
| `adr/0004-use-archiso.md` | config | file-I/O | `adr/0001-base-system.md` | exact |
| `README.md` | doc | file-I/O | `README.md` (existing) | exact (self) |
| `VERSION` | config | file-I/O | `CHANGELOG.md` (version reference) | partial |
| `CHANGELOG.md` | doc | file-I/O | `CHANGELOG.md` (existing) | exact (self) |
| `deprecated/` | config | file-I/O | N/A (new pattern) | no-analog |

## Pattern Assignments

---

### `scripts/validate.sh` (utility, batch)

**Analog:** `scripts/validate-vm.sh` — same shebang pattern, `set -euo pipefail`, echo-based reporting.

**Shebang and options pattern** (from `validate-vm.sh` lines 1-4):
```bash
#!/usr/bin/env bash
# validate-vm.sh — simple VM validation checks for the aetherOS demo
set -euo pipefail
```

**Echo-based status reporting pattern** (from `validate-vm.sh` line 5):
```bash
echo "Checking basic VM capabilities..."
```

**Key difference:** `validate.sh` is more complex — it runs multiple gates (G0-G3) with pass/fail counting. The RESEARCH.md code example (lines 483-536) provides the full implementation pattern with the `gate()` helper function. The planner should use the RESEARCH.md example as the primary reference, not the simple stub.

**Gate function pattern** (from RESEARCH.md):
```bash
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
```

---

### `scripts/validate-profile.sh` (utility, batch)

**Analog:** `scripts/collect-system-report.sh` — same structure: shebang, `set -euo pipefail`, sequential echo/check commands.

**Core pattern** (from `collect-system-report.sh` lines 1-9):
```bash
#!/usr/bin/env bash
# collect-system-report.sh — gathers basic system information for validation logs
set -euo pipefail

echo "Collecting system report..."
uname -a
lsb_release -a || true
free -h
df -h
```

**Key difference:** `validate-profile.sh` checks profile-specific files (profiledef.sh, packages.x86_64, pacman.conf) rather than system state. Use `test -f` checks like the G1 gates in the RESEARCH.md validate.sh example (lines 515-517):
```bash
gate "G1" "profiledef.sh exists" test -f profiles/aetheros/profiledef.sh
gate "G1" "packages.x86_64 exists" test -f profiles/aetheros/packages.x86_64
gate "G1" "pacman.conf exists" test -f profiles/aetheros/pacman.conf
```

---

### `scripts/print-build-env.sh` (utility, batch)

**Analog:** `scripts/collect-system-report.sh` — same pattern of echoing system state.

**Environment capture pattern** (from `collect-system-report.sh`):
```bash
#!/usr/bin/env bash
# [script name] — [description]
set -euo pipefail

echo "[Description]..."
uname -a
```

**Full implementation** is provided in RESEARCH.md (lines 678-695). Key pattern: use `$(command)` substitutions with `|| echo 'NOT FALLBACK'` for optional tools:
```bash
echo "archiso:      $(pacman -Q archiso 2>/dev/null | awk '{print $2}' || echo 'NOT INSTALLED')"
echo "mkarchiso:    $(command -v mkarchiso 2>/dev/null || echo 'NOT FOUND')"
```

---

### `scripts/build-iso.sh` (utility, batch)

**Analog:** `scripts/bootstrap-aether.sh` — both are build scripts with dependency checks and sequential execution.

**Dependency check pattern** (from `bootstrap-aether.sh` lines 10-20):
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
    xfce4 xfce4-goodies lightdm \
    network-manager firefox-esr thunar mousepad \
    ...
```

**Key difference:** `build-iso.sh` checks for host commands before running (not installing them), then invokes `mkarchiso`. The RESEARCH.md example (lines 540-583) provides the full pattern:

**Host dependency check pattern** (from RESEARCH.md):
```bash
for cmd in mkarchiso; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "ERROR: ${cmd} not found. Install with: sudo pacman -Syu --needed archiso" >&2
        exit 1
    fi
done
```

**REPO_ROOT resolution pattern** (from RESEARCH.md):
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
```

---

### `scripts/smoke-qemu.sh` (utility, batch)

**Analog:** `scripts/validate-vm.sh` — both validate VM/boot state.

**Key difference:** `smoke-qemu.sh` takes an ISO path as argument and boots it. The RESEARCH.md example (lines 588-616) provides the full pattern with argument validation and `run_archiso` fallback:

**Argument validation pattern** (from RESEARCH.md):
```bash
ISO_PATH="${1:?Usage: $0 <path-to-iso>}"

if [ ! -f "${ISO_PATH}" ]; then
    echo "ERROR: ISO not found: ${ISO_PATH}" >&2
    exit 1
fi
```

**Tool preference with fallback** (from RESEARCH.md):
```bash
if command -v run_archiso &>/dev/null; then
    run_archiso -i "${ISO_PATH}"
else
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

---

### `scripts/collect-artifacts.sh` (utility, batch)

**Analog:** `scripts/make-context-bundle.sh` — both collect files and produce output archives/reports.

**Bundle pattern** (from `make-context-bundle.sh` lines 1-6):
```bash
#!/usr/bin/env bash
# make-context-bundle.sh — bundle docs, manifests, and logs for support or assistant context
set -euo pipefail

echo "Bundling context files..."
```

**Full implementation** is in RESEARCH.md (lines 620-674). Key patterns:

**ISO discovery** (from RESEARCH.md):
```bash
ISO_FILE=$(find "${OUT}" -maxdepth 1 -name "*.iso" | head -1)
if [ -z "${ISO_FILE}" ]; then
    echo "ERROR: No ISO found in ${OUT}/" >&2
    exit 1
fi
```

**SHA256 generation** (from RESEARCH.md):
```bash
(cd "${OUT}" && sha256sum *.iso > "${ARTIFACTS}/SHA256SUMS")
```

**Build metadata capture** (from RESEARCH.md):
```bash
{
    echo "VERSION=${VERSION}"
    echo "GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')"
    echo "BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "HOST_OS=$(uname -s -r)"
    echo "ARCHISO_VERSION=$(pacman -Q archiso 2>/dev/null | awk '{print $2}' || echo 'N/A')"
} > "${ARTIFACTS}/build-env.txt"
```

---

### `profiles/aetheros/profiledef.sh` (config, file-I/O)

**Analog:** `manifests/packages.base.txt` — both define what goes into the system, but `profiledef.sh` is the Arch iso metadata definition.

**No direct analog exists.** The RESEARCH.md provides the canonical example (lines 428-441) based on official archiso documentation:

```bash
#!/usr/bin/env bash
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

**Key constraint:** `install_dir` must be max 8 chars, `[a-z0-9]` only. `bootmodes` must use Arch archiso identifiers.

---

### `profiles/aetheros/packages.x86_64` (config, file-I/O)

**Analog:** `manifests/packages.base.txt` — same concept (package list), different format (Arch vs Debian).

**Existing pattern** (from `manifests/packages.base.txt`):
```bash
# packages.base.txt

# Base and utilities
apt-utils
curl
wget
git
jq
ripgrep
fzf
python3
python3-venv

# XFCE and basic desktop
xfce4
lightdm
thunar
mousepad
firefox-esr
```

**Key differences for Arch version:**
- No Debian-specific package names (apt-utils, firefox-esr)
- Arch equivalents (no apt-utils needed, firefox not firefox-esr)
- Must include `mkinitcpio` and `mkinitcpio-archiso` (mandatory per archiso docs)
- Comments use `#`, one package per line, no versions

**RESEARCH.md provides the target example** (lines 446-479).

---

### `profiles/aetheros/pacman.conf` (config, file-I/O)

**Analog:** `manifests/services.enabled.txt` — both are configuration files that control system behavior.

**No direct analog exists.** This is a standard Arch pacman.conf. The planner should reference the Arch releng profile's pacman.conf at `/usr/share/archiso/configs/releng/pacman.conf` as the starting template.

---

### `adr/0004-use-archiso.md` (config, file-I/O)

**Analog:** `adr/0001-base-system.md` — exact same ADR format.

**ADR format pattern** (from `adr/0001-base-system.md` lines 1-14):
```markdown
# ADR 0001 — Base system

Decision: Use Debian Stable + XFCE as the base for aetherOS v0.1.

Rationale:

- Stability and broad hardware support
- Familiar packaging and provenance
- Predictable for small-business use

Consequences:

- No custom kernel or package manager for v0.1
```

**ADR 0003 format** (from `adr/0003-ai-runtime-boundaries.md` lines 1-5) is more concise:
```markdown
# ADR 0003 — AI runtime boundaries

Decision: AI features are optional accelerators. Local models may be used for summarization and context compression, but must not be treated as authoritative for licensing, packaging, or security.

Rationale and constraints included in OPERATING_CONTRACT.md.
```

**Planner should use ADR 0001 as the template** (more detailed structure with Decision/Rationale/Consequences sections).

---

### `.gitignore` (config, file-I/O)

**Analog:** `.github/workflows/validate.yml` — the CI workflow already lists the artifact patterns that must be gitignored.

**Artifact patterns from CI** (from `.github/workflows/validate.yml` line 31):
```bash
grep -E '(^out/|^work/|^logs/|\.iso$|\.img$|\.qcow2$|\.log$)'
```

**RESEARCH.md provides the full .gitignore content** (from RESEARCH.md pitfall 2):
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

---

### `README.md` (doc, file-I/O) — MODIFIED

**Analog:** `README.md` (existing) — self-analog, must be updated not replaced.

**Current structure** (from `README.md` lines 1-41):
```markdown
# aetherOS

aetherOS turns old and low-end computers into calm local production workstations.
...

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
```

**Key pattern:** Quick start already references the correct scripts. Must be updated to also reference `validate-profile.sh`, `print-build-env.sh`, and `collect-artifacts.sh` as they are added.

---

### `VERSION` (config, file-I/O) — NEW

**Analog:** `CHANGELOG.md` — the changelog already references version strings.

**No direct file analog.** The file should contain a single version string matching `profiledef.sh`:
```
0.1.0-demo.1
```

---

### `CHANGELOG.md` (doc, file-I/O) — MODIFIED

**Analog:** `CHANGELOG.md` (existing) — self-analog.

**Current structure** (from `CHANGELOG.md`):
```markdown
# Changelog

All notable changes to this repository will be documented in this file.

## Unreleased

- Initialize repository skeleton
```

**Pattern to follow:** Add entries under `## Unreleased` following conventional commit types (`feat:`, `fix:`, `docs:`, `build:`, `test:`, `chore:`).

---

## Shared Patterns

### Shell Script Boilerplate
**Source:** All existing scripts (`scripts/bootstrap-aether.sh`, `scripts/validate-vm.sh`, `scripts/collect-system-report.sh`, `scripts/make-context-bundle.sh`)
**Apply to:** All new scripts (`validate.sh`, `validate-profile.sh`, `print-build-env.sh`, `build-iso.sh`, `smoke-qemu.sh`, `collect-artifacts.sh`)

```bash
#!/usr/bin/env bash
# [script-name] — [one-line description]
set -euo pipefail
```

**Rules:**
- Always use `#!/usr/bin/env bash` (not `#!/bin/bash`)
- Always include `set -euo pipefail`
- Description comment on line 2
- All scripts must be executable (`chmod +x`)

### Error Handling
**Source:** `scripts/bootstrap-aether.sh` (implicit via `set -euo pipefail`), RESEARCH.md examples (explicit error messages)
**Apply to:** All scripts

```bash
# Error with stderr redirect and exit
echo "ERROR: [message]" >&2
exit 1

# Optional tool check with fallback
$(command 2>/dev/null || echo 'NOT FOUND')
```

### REPO_ROOT Resolution
**Source:** RESEARCH.md `build-iso.sh` example
**Apply to:** All scripts that reference repo-relative paths (`build-iso.sh`, `validate.sh`, `validate-profile.sh`, `collect-artifacts.sh`)

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
```

### ADR Format
**Source:** `adr/0001-base-system.md`
**Apply to:** `adr/0004-use-archiso.md`

```markdown
# ADR NNNN — [short title]

Decision: [one sentence decision]

Rationale:

- [point 1]
- [point 2]
- [point 3]

Consequences:

- [consequence 1]
- [consequence 2]
```

### Commit Message Convention
**Source:** CONTEXT.md "Established Patterns"
**Apply to:** All commits in Phase 1

```
feat:     New feature or capability
fix:      Bug fix
docs:     Documentation update
build:    Build system or script change
test:     Test-related changes
chore:    Maintenance, cleanup, archival
```

### Validation Gate Naming
**Source:** `docs/SPRINT_OPERATIONS.md`, `docs/BUILD_PIPELINE.md`
**Apply to:** `scripts/validate.sh`, `scripts/validate-profile.sh`

```
G0 — Repo hygiene
G1 — Profile integrity
G2 — Package policy
G3 — Script validation (shellcheck)
G4 — ISO build
G5 — Artifact manifest
G6 — VM boot smoke
```

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `profiles/aetheros/profiledef.sh` | config | file-I/O | New Arch-specific format; no existing profiledef.sh in repo. Use RESEARCH.md example based on official archiso docs. |
| `profiles/aetheros/pacman.conf` | config | file-I/O | New Arch-specific config; no existing pacman.conf in repo. Copy from `/usr/share/archiso/configs/releng/pacman.conf`. |
| `VERSION` | config | file-I/O | New file; no existing VERSION file. Single-line version string. |

## Metadata

**Analog search scope:** `scripts/`, `adr/`, `manifests/`, `.github/workflows/`, `docs/`, root files
**Files scanned:** 20+ (all non-git files in repo)
**Pattern extraction date:** 2026-06-03
