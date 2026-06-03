# Technology Stack

**Project:** aetherOS
**Researched:** 2026-06-03

## Recommended Stack

### Core Framework

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Arch Linux | Rolling (latest) | Base operating system | Rolling release = newer packages at lower resource cost; best documentation (Arch Wiki); mkarchiso is purpose-built for ISO creation |
| mkarchiso | From Arch repos | ISO build tooling | Purpose-built for creating bootable Arch ISOs; profiles system makes build reproducible; airootfs overlay for customization |
| Linux kernel | linux or linux-lts | Kernel | Use standard Arch linux kernel; linux-lts only if hardware compatibility issues arise. Do NOT customize. |

### Desktop Environment

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| XFCE4 | Latest from Arch repos | Lightweight desktop environment | Idles at ~300-500 MB RAM; highly configurable; mature; proven on low-end hardware; theming support for branding |
| LightDM | Latest from Arch repos | Display manager/login screen | Lightweight (~50 MB); themeable; auto-login support for demo; minimal dependencies |
| GTK3/4 theme | Adwaita or custom | Visual identity | Start with Adwaita-dark for professional feel; customize later for branding |

### Core Applications

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| xfce4-terminal | Arch repos | Terminal emulator | Native to XFCE; minimal footprint; works well in constrained RAM |
| Thunar | Arch repos | File manager | Native to XFCE; fast with large directories; bulk rename for organization workflow |
| Mousepad | Arch repos | Text editor | Native to XFCE; suitable for config files and notes |
| Chromium (or firefox) | Arch repos | Web browser | **Consider dropping from base profile** to save RAM; if needed, use firefox (lighter cold-start than chromium) |

### Infrastructure

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| QEMU/KVM | Arch repos | VM testing | Standard virtualization for validation; KVM for speed, software fallback for compatibility |
| edk2-ovmf | Arch repos | UEFI firmware for QEMU | Enables UEFI boot testing alongside BIOS (stretch goal) |
| shellcheck | Arch repos | Script linting | Validates shell scripts in CI and local dev |
| jq | Arch repos | JSON processing | For build manifests and metadata |
| git | Arch repos | Version control | Standard |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| python3 | Arch repos | Scripting runtime | Only if needed for RECOG features; keep out of base profile for demo |
| python3-venv | Arch repos | Virtual environments | For optional AI/RECOG scripts; not in base ISO |
| zenity | Arch repos | Simple GTK dialogs | For Aether Workbench launcher (from bootstrap script) |
| ripgrep | Arch repos | Fast search | For future content indexing; not in base ISO |
| fzf | Arch repos | Fuzzy finder | For future CLI tooling; not in base ISO |

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Base OS | Arch Linux | Debian Stable | Arch has better docs, newer packages at lower resource cost, mkarchiso is purpose-built. Debian's advantage (stability) is less relevant for a demo ISO that gets rebuilt fresh. However, if Arch build issues arise, Debian + live-build is the documented fallback. |
| ISO Builder | mkarchiso | live-build (Debian) | mkarchiso is purpose-built for Arch ISOs. Use live-build only if going Debian route. Do NOT mix. |
| Desktop Env | XFCE4 | LXQt, i3, sway | LXQt is slightly lighter but less polished for demo. i3/sway are too unfamiliar for general audience. XFCE hits the sweet spot of lightweight + recognizable desktop paradigm. |
| Display Manager | LightDM | SDDM, no DM (startx) | SDDM pulls in Qt. No DM makes demo harder to present. LightDM is the best balance of lightweight + user-friendly for demo. |
| Terminal | xfce4-terminal | xterm, alacritty, kitty | xterm is too bare for demo. alacritty/kitty add GPU deps. xfce4-terminal is native and fast. |
| Text Editor | Mousepad | nano, vim, geany | Mousepad is visual, intuitive for demo audience. nano/vim are CLI-only. geany is heavier. |

## Critical Implementation Notes

### The Arch/Debian Contradiction

The existing repo has BOTH:
- **Arch pathway**: SPRINT_OPERATIONS.md specifies `pacman.conf`, `packages.x86_64`, `profiledef.sh` -- all Arch/mkarchiso conventions
- **Debian pathway**: ADR 0001, OPERATING_CONTRACT.md, `scripts/bootstrap-aether.sh`, and `manifests/*.txt` (apt-utils, firefox-esr) all reference Debian

**Recommendation**: Commit to Arch for the ISO demo. Keep bootstrap-aether.sh as a post-install convenience script for physical hardware installs (if that ever becomes a goal). Convert all manifests to Arch package names.

### mkarchiso Profile Structure

The mkarchiso profile (`profiles/aetheros/`) is the SINGLE SOURCE OF_truth for the ISO. It must contain:

```
profiles/aetheros/
├── profiledef.sh          # ISO metadata (name, version, etc.)
├── packages.x86_64        # Package list (one per line)
├── pacman.conf            # Pacman configuration for build
├── airootfs/              # Filesystem overlay (customizes the live system)
│   ├── etc/
│   │   ├── lightdm/       # LightDM config for auto-login
│   │   ├── skel/          # Default home directory contents
│   │   └── systemd/system/# Enabled services
│   └── usr/
│       └── share/         # Themes, wallpapers, desktop files
└── README.md
```

### RAM Budget (2 GB Target)

| Component | Approximate RAM |
|-----------|-----------------|
| Linux kernel + base system | ~200-300 MB |
| XFCE4 session | ~150-250 MB |
| LightDM | ~30-50 MB |
| xfce4-terminal | ~30-50 MB |
| Thunar | ~30-50 MB |
| Mousepad | ~20-30 MB |
| NetworkManager | ~20-30 MB |
| **Headroom for user work** | **~1.2-1.4 GB** |

This budget works but has no room for a modern web browser in the base profile. **Recommendation**: Firefox/Chromium should NOT be in the base package list. If web browsing is needed for the demo, install it separately or use a lighter browser like `surf` or `dillo`.

## Installation (Build Host)

```bash
# On Arch Linux host/VM
sudo pacman -Syu --needed archiso qemu-desktop edk2-ovmf shellcheck git jq

# Validate repo state
./scripts/validate.sh

# Build ISO
./scripts/build-iso.sh

# Smoke test
./scripts/smoke-qemu.sh out/*.iso

# Collect artifacts
./scripts/collect-artifacts.sh
```

## Sources

- Arch Wiki - archiso: https://wiki.archlinux.org/title/Archiso (training knowledge; could not verify current state due to WebFetch unavailability)
- Arch Wiki - XFCE: https://wiki.archlinux.org/title/XFCE (training knowledge)
- Arch Wiki - LightDM: https://wiki.archlinux.org/title/LightDM (training knowledge)
- SPRINT_OPERATIONS.md: /home/anphuni/aetherOS/docs/SPRINT_OPERATIONS.md (authoritative project specification)
- ADR 0001: /home/anphuni/aetherOS/adr/0001-base-system.md (contradicts SPRINT_OPERATIONS.md)
- OPERATING_CONTRACT.md: /home/anphuni/aetherOS/OPERATING_CONTRACT.md (contradicts SPRINT_OPERATIONS.md)
