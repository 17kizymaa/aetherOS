# Phase 2: Core Desktop & Boot - Pattern Map

**Mapped:** 2026-06-04
**Files analyzed:** 11 (3 modified, 8 new)
**Analogs found:** 6 / 11

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `profiles/aetheros/profiledef.sh` | config | file-I/O | `profiles/aetheros/profiledef.sh` (self) | exact (self-modify) |
| `profiles/aetheros/packages.x86_64` | config | file-I/O | `profiles/aetheros/packages.x86_64` (self) | exact (self-modify) |
| `profiles/aetheros/grub/grub.cfg` | config | file-I/O | `profiles/aetheros/profiledef.sh` (boot config concept) | partial |
| `profiles/aetheros/airootfs/etc/lightdm/lightdm.conf` | config | file-I/O | `deprecated/manifests/services.enabled.txt` (service config concept) | partial |
| `profiles/aetheros/airootfs/etc/systemd/system/zram.service` | config | file-I/O | `deprecated/manifests/services.enabled.txt` (systemd enable concept) | partial |
| `profiles/aetheros/airootfs/etc/sudoers.d/demo` | config | file-I/O | `deprecated/bootstrap-aether.sh` (sudoers concept in comments) | partial |
| `profiles/aetheros/airootfs/etc/polkit-1/rules.d/10-shutdown-reboot.rules` | config | file-I/O | No analog found | no-analog |
| `scripts/generate-wallpaper.sh` | utility | file-I/O | `scripts/collect-artifacts.sh` (file generation script) | role-match |
| `scripts/smoke-qemu.sh` | utility | batch | `scripts/smoke-qemu.sh` (self) | exact (self-modify) |
| `profiles/aetheros/airootfs/etc/skel/Desktop/aetheros-readme.desktop` | config | file-I/O | `deprecated/bootstrap-aether.sh` (desktop entry creation) | role-match |
| `profiles/aetheros/airootfs/home/demo/Desktop/aetheros-readme.txt` | config | file-I/O | `deprecated/bootstrap-aether.sh` (template file creation) | role-match |

## Pattern Assignments

---

### `profiles/aetheros/profiledef.sh` (config, file-I/O) — MODIFIED

**Analog:** `profiles/aetheros/profiledef.sh` (self) — existing file to be modified.

**Current content** (lines 1-13):
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

**Required changes per CONTEXT.md D-06:**
- Fix `uefi.grab` typo to `uefi.grub` (already correct in current file — this was the intended fix)
- Change `bootmodes` from `("bios.syslinux" "uefi.grub")` to `("uefi.grub")` for GRUB-only UEFI boot

**Target pattern:**
```bash
bootmodes=("uefi.grub")
```

**Rules (from ARCHITECTURE.md and SPRINT_OPERATIONS.md):**
- `install_dir` must be max 8 chars, `[a-z0-9]` only
- `bootmodes` must use Arch archiso identifiers
- `iso_label` must be <= 16 chars, uppercase alphanumeric + underscore

---

### `profiles/aetheros/packages.x86_64` (config, file-I/O) — MODIFIED

**Analog:** `profiles/aetheros/packages.x86_64` (self) — existing file to be extended.

**Current content** (lines 1-31):
```
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
xfce4-goodies

# Display manager
lightdm
lightdm-gtk-greeter

# Networking
networkmanager

# Filesystem tools
dosfstools
e2fsprogs
```

**Required additions per CONTEXT.md D-11:**
- `xfce4-terminal` — terminal emulator
- `thunar` — file manager
- `mousepad` — text editor
- `firefox` — web browser
- `zram-generator` — zram swap generator

**Package list format rules (from ARCHITECTURE.md Pattern 2):**
- One package per line, no versions
- Comments use `#`
- No blank lines between packages in the same section (current style uses blank lines between sections)
- No Debian-specific names (no `apt-utils`, no `firefox-esr`)

**Validation gate G2 checks this file for:**
- No duplicate packages (`sort | uniq -d`)
- No version specifiers (`=`)
- At least 5 non-comment lines
- Required packages: `base`, `mkinitcpio`, `mkinitcpio-archiso`, `linux-lts`

---

### `profiles/aetheros/grub/grub.cfg` (config, file-I/O) — NEW

**Analog:** `profiles/aetheros/profiledef.sh` — both define boot behavior, but `grub.cfg` is the GRUB bootloader configuration.

**No direct analog exists in the codebase.** This is a new file required for UEFI GRUB boot. The ARCHITECTURE.md specifies the profile structure should include `grub/` directory under the profile.

**Target pattern (from Arch Wiki UEFI GRUB convention, per CONTEXT.md D-06, D-07, D-08):**

Key requirements:
- GRUB timeout: 1 second (D-07)
- Kernel parameters: `quiet splash` (D-08)
- Boot entry points to the Arch ISO squashfs

**Reference structure:**
```bash
# profiles/aetheros/grub/grub.cfg
# GRUB bootloader config for aetherOS UEFI

set timeout=1
set default=0

# Menu entry for aetherOS
menuentry "aetherOS Live" {
    linux /boot/vmlinuz-linux-lts img_loop=... quiet splash
    initrd /boot/initramfs-linux-lts.img
}
```

**Planner note:** The exact `img_loop` and UUID parameters should follow the Archiso GRUB pattern from `/usr/share/archiso/configs/releng/grub/grub.cfg` on the build host. The RESEARCH.md ARCHITECTURE.md section specifies the airootfs overlay pattern for boot configs.

---

### `profiles/aetheros/airootfs/etc/lightdm/lightdm.conf` (config, file-I/O) — NEW

**Analog:** `deprecated/manifests/services.enabled.txt` — both configure which services/users are active, but `lightdm.conf` uses INI format.

**No direct analog exists.** The ARCHITECTURE.md (lines 100-106) provides the canonical example:

```bash
# airootfs/etc/lightdm/lightdm.conf
[Seat:*]
autologin-user=demo
autologin-user-timeout=0
user-session=xfce
```

**Key requirements per CONTEXT.md D-01, D-02:**
- Full auto-login with no interaction
- Auto-login username: `demo`
- Session: `xfce`

**File placement rule (from ARCHITECTURE.md Pattern 1):**
- Files in `airootfs/` mirror the target filesystem structure
- `airootfs/etc/lightdm/lightdm.conf` will appear as `/etc/lightdm/lightdm.conf` in the live system

---

### `profiles/aetheros/airootfs/etc/systemd/system/zram.service` (config, file-I/O) — NEW

**Analog:** `deprecated/manifests/services.enabled.txt` — both relate to systemd service enablement, but this is a full unit file.

**No direct analog exists.** The CONTEXT.md D-04, D-05 specifies:
- zram swap, 1 GB size, zstd compression
- Enabled via systemd service unit in `airootfs/etc/systemd/system/`
- Package: `zram-generator`

**Target pattern (from zram-generator documentation):**

The `zram-generator` package typically provides a systemd unit. The airootfs overlay should either:
1. Drop a `zram-generator.conf` at `airootfs/etc/systemd/zram-generator.conf`, OR
2. Symlink the provided unit: `airootfs/etc/systemd/system/sysinit.target.wants/zram-generator.service -> /usr/lib/systemd/system/zram-generator.service`

**Option 1 (config file approach) is simpler for airootfs overlay:**
```ini
# airootfs/etc/systemd/zram-generator.conf
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
```

**Planner note:** The exact zram-generator configuration format should be verified against the installed version. The CONTEXT.md specifies 1 GB size with zstd compression. If `zram-size = ram / 2` yields 1 GB on a 2 GB system, use that; otherwise use an explicit `zram-size = 1024`.

---

### `profiles/aetheros/airootfs/etc/sudoers.d/demo` (config, file-I/O) — NEW

**Analog:** `deprecated/bootstrap-aether.sh` — the bootstrap script uses `sudo` for package installation, but does not create a sudoers file.

**No direct analog exists.** The CONTEXT.md D-03 specifies passwordless sudo for the `demo` user.

**Target pattern (standard sudoers.d format):**
```
# airootfs/etc/sudoers.d/demo
demo ALL=(ALL) NOPASSWD: ALL
```

**Rules:**
- File must be owned by root and mode `0440` in the live system
- The airootfs overlay will set this if the file is placed with correct permissions
- The `demo` user must be created (typically via `airootfs/etc/skel` or a custom systemd-firstboot script)

**Planner note:** Verify that the `demo` user is created. The standard archiso setup creates users via `profiledef.sh` `username` field or via airootfs `/etc/skel`. If no user creation mechanism exists, add `airootfs/etc/passwd` entry or a systemd service to create the user at first boot.

---

### `profiles/aetheros/airootfs/etc/polkit-1/rules.d/10-shutdown-reboot.rules` (config, file-I/O) — NEW

**No analog found in the codebase.** This is a new file type for Phase 2.

**CONTEXT.md D-03 specifies:** Polkit rules for passwordless GUI shutdown/reboot.

**Target pattern (JavaScript polkit rules format):**
```javascript
// airootfs/etc/polkit-1/rules.d/10-shutdown-reboot.rules
polkit.addRule(function(action, subject) {
    if ((action.id == "org.freedesktop.login1.power-off" ||
         action.id == "org.freedesktop.login1.reboot") &&
        subject.user == "demo") {
        return polkit.Result.YES;
    }
});
```

**File naming rules:**
- Must have `.rules` extension
- Numeric prefix `10-` for ordering (lower = earlier)
- Placed in `airootfs/etc/polkit-1/rules.d/`

---

### `scripts/generate-wallpaper.sh` (utility, file-I/O) — NEW

**Analog:** `scripts/collect-artifacts.sh` — both are bash scripts that generate output files using the same boilerplate pattern.

**Shell script boilerplate** (from `collect-artifacts.sh` lines 1-6):
```bash
#!/usr/bin/env bash
# scripts/collect-artifacts.sh — Generate checksums and manifests (G5)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
```

**Error handling pattern** (from `collect-artifacts.sh` lines 16-20):
```bash
if [ ! -d "${OUT}" ]; then
    echo "ERROR: Output directory not found: ${OUT}/" >&2
    echo "Run ./scripts/build-iso.sh first to build the ISO." >&2
    exit 1
fi
```

**File generation pattern** (from `collect-artifacts.sh` lines 32-41):
```bash
{
    echo "VERSION=${VERSION}"
    echo "GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')"
} > "${ARTIFACTS}/build-env.txt"
```

**CONTEXT.md D-12, D-13 requirements:**
- Wallpaper is a static PNG generated at build time
- Shows hardware metrics (CPU name, GPU name, etc.) as body text
- Simple, no runtime dependencies
- Output path: `profiles/aetheros/airootfs/usr/share/backgrounds/aetheros-wallpaper.png`

**Implementation approach options:**
1. **ImageMagick (preferred):** `convert` command to generate PNG with text overlay. Lightweight, single package.
2. **Python + Pillow:** More flexible but requires python3 and python-pillow in the build environment.

**Target pattern (ImageMagick approach):**
```bash
#!/usr/bin/env bash
# scripts/generate-wallpaper.sh — Generate aetherOS wallpaper with hardware metrics
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT="${REPO_ROOT}/profiles/aetheros/airootfs/usr/share/backgrounds/aetheros-wallpaper.png"

# Gather hardware metrics
CPU_NAME=$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs || echo "Unknown CPU")
TOTAL_RAM=$(free -h | awk '/^Mem:/{print $2}' || echo "Unknown")

# Generate wallpaper (requires imagemagick)
if ! command -v convert &>/dev/null; then
    echo "ERROR: ImageMagick 'convert' not found. Install with: sudo pacman -S imagemagick" >&2
    exit 1
fi

mkdir -p "$(dirname "${OUTPUT}")"
convert -size 1920x1080 xc:'#1a1a2e' \
    -fill '#e0e0e0' -font DejaVu-Sans -pointsize 24 \
    -gravity center -annotate +0+0 "aetherOS\n${CPU_NAME}\n${TOTAL_RAM} RAM" \
    "${OUTPUT}"

echo "Wallpaper generated: ${OUTPUT}"
```

**Planner note:** The exact visual design (colors, font sizes, text positioning) is at Claude's discretion per CONTEXT.md "Claude's Discretion" section. The key constraint is: static PNG, no runtime deps in the live system, generated at build time.

---

### `scripts/smoke-qemu.sh` (utility, batch) — MODIFIED

**Analog:** `scripts/smoke-qemu.sh` (self) — existing file to be enhanced.

**Current content** (lines 1-27):
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

**Required enhancements per CONTEXT.md D-15:**
1. Add OVMF UEFI firmware support (`-bios /usr/share/edk2-ovmf/x64/OVMF_CODE.fd`)
2. Add auto-shutdown timeout (2 minutes via QEMU `-device isa-debug-exit` or a wrapper timeout)
3. Add basic framebuffer checks (verify display is available)

**Target additions:**
```bash
# UEFI firmware support
if [ -f /usr/share/edk2-ovmf/x64/OVMF_CODE.fd ]; then
    UEFI_BIOS="-bios /usr/share/edk2-ovmf/x64/OVMF_CODE.fd"
else
    echo "WARNING: OVMF firmware not found, falling back to default BIOS" >&2
    UEFI_BIOS=""
fi

# Auto-shutdown after 2 minutes (120 seconds)
# Using QEMU's -device isa-debug-exit for clean exit
# Or: timeout 120 qemu-system-x86_64 ...
```

**Planner note:** The auto-shutdown mechanism should allow the VM to run for 2 minutes then exit cleanly. This can be done either via the host `timeout` command wrapping QEMU, or via a QEMU guest agent mechanism. The simplest approach is `timeout 120 qemu-system-x86_64 ...` but this kills QEMU rather than shutting down cleanly. A better approach is to pass `-device isa-debug-exit,iobase=0xf4,iosize=0x04` which allows the guest to exit QEMU via `outb(0xf4, 0x00)`.

---

### `profiles/aetheros/airootfs/etc/skel/Desktop/aetheros-readme.desktop` (config, file-I/O) — NEW

**Analog:** `deprecated/bootstrap-aether.sh` lines 42-57 — creates a `.desktop` launcher file using heredoc.

**Desktop entry creation pattern** (from `bootstrap-aether.sh` lines 42-57):
```bash
cat > ~/.local/share/applications/aether-workbench.desktop << 'EOF'
[Desktop Entry]
Name=Aether Workbench
Comment=Calm production workspace
Exec=zenity --list --title="Aether Workbench" --column="Action" \
"Start New Project" \
"Open Projects Folder" \
"Backup Now" \
"System Health" \
"Ask Aether Assistant" \
--height=300 --width=400
Type=Application
Terminal=false
Categories=Utility;
Icon=system-run
EOF
```

**CONTEXT.md D-14 requirements:**
- Desktop includes a brief README/desktop file with aetherOS message
- Clean and intentional

**Target pattern:**
```ini
# airootfs/etc/skel/Desktop/aetheros-readme.desktop
[Desktop Entry]
Name=Welcome to aetherOS
Comment=About this system
Exec=mousepad /home/demo/Desktop/aetheros-readme.txt
Type=Application
Terminal=false
Categories=Utility;
Icon=help-about
```

**File placement rules:**
- Goes in `airootfs/etc/skel/Desktop/` so it appears on the demo user's desktop
- The `aetheros-readme.txt` file goes in `airootfs/home/demo/Desktop/` (or `airootfs/etc/skel/Desktop/`)

---

### `profiles/aetheros/airootfs/home/demo/Desktop/aetheros-readme.txt` (config, file-I/O) — NEW

**Analog:** `deprecated/bootstrap-aether.sh` lines 33-39 — creates template files using heredoc.

**Template creation pattern** (from `bootstrap-aether.sh` lines 33-39):
```bash
cat > ~/aetherOS/project-templates/README-TODAY.md << 'EOF'
# README-TODAY.md
Date: $(date +%Y-%m-%d)
Project: 
Current state: 
Next action: 
EOF
```

**CONTEXT.md D-14 requirements:**
- Brief README with aetherOS message
- Clean and intentional

**Target content:**
```
# Welcome to aetherOS

aetherOS turns neglected hardware into calm production workstations.

This demo runs on:
  - Arch Linux with XFCE desktop
  - 2 GB RAM, 2 vCPU
  - No cloud dependencies

Quick commands:
  - Terminal:    xfce4-terminal
  - File manager: thunar
  - Text editor:  mousepad
  - Web browser:  firefox
  - Shutdown:     sudo systemctl poweroff
  - Reboot:       sudo systemctl reboot

Learn more: https://github.com/anphuni/aetherOS
```

**File placement:** `airootfs/home/demo/Desktop/aetheros-readme.txt` — directly on the demo user's desktop. Alternatively, could be placed in `airootfs/etc/skel/Desktop/` to apply to any new user.

---

## Shared Patterns

### Shell Script Boilerplate
**Source:** All existing scripts (`scripts/build-iso.sh`, `scripts/validate.sh`, `scripts/collect-artifacts.sh`, `scripts/smoke-qemu.sh`)
**Apply to:** `scripts/generate-wallpaper.sh` (new script)

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

### REPO_ROOT Resolution
**Source:** `scripts/build-iso.sh`, `scripts/validate.sh`, `scripts/collect-artifacts.sh`
**Apply to:** `scripts/generate-wallpaper.sh` (new script that references profile paths)

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
```

### Error Handling
**Source:** All existing scripts
**Apply to:** All new and modified scripts

```bash
# Error with stderr redirect and exit
echo "ERROR: [message]" >&2
exit 1

# Warning (non-fatal)
echo "WARNING: [message]" >&2

# Optional tool check with fallback
$(command 2>/dev/null || echo 'NOT FOUND')
```

### airootfs Overlay Pattern
**Source:** ARCHITECTURE.md Pattern 1
**Apply to:** All new files under `profiles/aetheros/airootfs/`

**Rule:** Files placed in `airootfs/` mirror the target filesystem structure exactly. A file at `airootfs/etc/lightdm/lightdm.conf` appears as `/etc/lightdm/lightdm.conf` in the live system.

**Directory structure for Phase 2:**
```
profiles/aetheros/airootfs/
├── etc/
│   ├── lightdm/
│   │   └── lightdm.conf          # Auto-login config
│   ├── polkit-1/
│   │   └── rules.d/
│   │       └── 10-shutdown-reboot.rules  # Passwordless shutdown/reboot
│   ├── skel/
│   │   └── Desktop/
│   │       └── aetheros-readme.desktop   # Desktop launcher for README
│   ├── sudoers.d/
│   │   └── demo                  # Passwordless sudo
│   └── systemd/
│       └── system/
│           └── (zram service symlink or config)
├── home/
│   └── demo/
│       └── Desktop/
│           └── aetheros-readme.txt       # Desktop README file
└── usr/
    └── share/
        └── backgrounds/
            └── aetheros-wallpaper.png   # Generated wallpaper
```

### Package List Management
**Source:** `profiles/aetheros/packages.x86_64` (existing), ARCHITECTURE.md Pattern 2
**Apply to:** `profiles/aetheros/packages.x86_64` (modified)

**Rules:**
- One package per line, no versions
- Comments use `#`
- Blank lines between sections for readability
- No Debian-specific names
- Every addition must be justified (required for boot, UX, build, or demo narrative)
- Run validation gate G2 after changes: `./scripts/validate.sh`

### Validation Gate Integration
**Source:** `scripts/validate.sh`, `scripts/validate-profile.sh`
**Apply to:** All changes in Phase 2

**Phase 2 targets gates G6 (VM boot smoke) and G7 (UX smoke).**
- G0-G3 must continue to pass after all changes
- Profile changes (packages, configs) are validated by G1-G2
- Script changes are validated by G3 (if shellcheck available)

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `profiles/aetheros/airootfs/etc/polkit-1/rules.d/10-shutdown-reboot.rules` | config | file-I/O | No polkit rules exist in the codebase. New file type for Phase 2. Use standard polkit JavaScript rules format. |
| `profiles/aetheros/grub/grub.cfg` | config | file-I/O | No GRUB config exists in the codebase. New file required for UEFI boot. Follow Arch Wiki UEFI GRUB pattern. |
| `profiles/aetheros/airootfs/etc/systemd/system/zram.service` | config | file-I/O | No systemd unit files exist in the codebase. Use zram-generator package with config file approach. |

## Metadata

**Analog search scope:** `scripts/`, `profiles/aetheros/`, `deprecated/`, `docs/`, `.planning/research/`
**Files scanned:** 30+ (all non-git files in repo relevant to Phase 2)
**Pattern extraction date:** 2026-06-04
