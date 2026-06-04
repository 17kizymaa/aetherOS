# Phase 2: Core Desktop & Boot - Context

**Gathered:** 2026-06-04
**Status:** Ready for planning

## Phase Boundary

Boot to a responsive XFCE desktop in QEMU with 2 GB RAM. This phase builds the airootfs overlay with LightDM auto-login, zram, GRUB boot config, and minimal XFCE customization. Everything from Phase 1 (mkarchiso profile, packages, boot scripts) feeds into this. Phase 3 (UX Applications) depends on a working desktop.

## Implementation Decisions

### Auto-login Strategy
- **D-01:** Full auto-login via LightDM — boots straight to XFCE desktop with no interaction. Seamless demo experience.
- **D-02:** Auto-login username is `demo`. Simple, clear, reinforces the demo narrative.
- **D-03:** Passwordless sudo for the `demo` user. Enables shutdown/reboot from terminal without friction. Polkit rules for GUI shutdown as well.

### zram Configuration
- **D-04:** zram swap, 1 GB size, zstd compression algorithm. Gives effective ~3-4 GB swap space. Best compression/speed tradeoff for low-RAM systems.
- **D-05:** Enabled via systemd service unit in `airootfs/etc/systemd/system/`. Clean, standard, survives ISO rebuilds. Package: `zram-generator`.

### Bootloader Config
- **D-06:** GRUB only (UEFI). Drops syslinux/BIOS support for simplicity. Fixes the `uefi.grab` typo in profiledef.sh to `uefi.grub`.
- **D-07:** GRUB timeout: 1 second. Near-instant boot, user can still hold Shift for menu.
- **D-08:** Kernel parameters: `quiet splash`. Suppresses verbose boot messages for cleaner demo boot.

### XFCE Session Setup
- **D-09:** Minimal customization — default XFCE theme (greybird), default panel layout. No heavy branding. Add only what's needed for the demo.
- **D-10:** Compositor **off** (disable xfwm4 compositor). Saves ~50-100 MB RAM. Snappier at 2 GB. User can re-enable after boot.
- **D-11:** Packages to add: `xfce4-terminal`, `thunar`, `mousepad`, `firefox`, `zram-generator`. Core apps included now for Phase 3 testing.
- **D-12:** Subtle aetherOS branding: wallpaper is a static text image showing hardware metrics (CPU name, GPU name, etc.) — a "system at a glance" aesthetic. Generated at build time as a PNG. Could evolve into hardware-based profiling in future phases.

### Demo Visuals
- **D-13:** Wallpaper displays hardware metrics as body text on the background (faint laptop CPU name, desktop GPU name). Main demographic is hardware enthusiasts. Static image generated at build time — simple, no runtime dependencies.
- **D-14:** Desktop includes a brief README/desktop file with aetherOS message. Clean and intentional.

### Smoke Test
- **D-15:** Update `smoke-qemu.sh` for Phase 2: add OVMF UEFI firmware support, auto-shutdown timeout (2 min), and basic framebuffer checks. Makes the smoke test more automated.

### Claude's Discretion
- Exact GRUB config file content and structure (follow Arch wiki UEFI GRUB pattern)
- zram-generator systemd unit file details
- Polkit rules for passwordless shutdown/reboot
- Wallpaper generation script implementation (Python + Pillow or imagemagick)
- Whether to use `firefox` or `firefox-esr` package
- Exact sudoers entry format for passwordless sudo

## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Build Pipeline
- `docs/SPRINT_OPERATIONS.md` — Full operational standard: build stages, validation gates G0-G8, package policy, logging standards
- `docs/BUILD_PIPELINE.md` — Build stages, inputs/outputs, artifact naming conventions
- `docs/VM_DEMO_ACCEPTANCE.md` — VM demo acceptance criteria (2 GB RAM, QEMU/KVM, core UX requirements)

### Architecture
- `.planning/research/ARCHITECTURE.md` — Recommended mkarchiso profile structure, component boundaries, data flow
- `.planning/research/STACK.md` — Technology recommendations: Arch + mkarchiso + XFCE + LightDM, RAM budget analysis

### Constraints
- `AGENTS.md` — Agent operating rules: hard constraints, required workflow, done criteria
- `context/CONSTRAINTS.md` — Hard constraints: Arch-based, mkarchiso, no custom kernel/pkg manager, local-first
- `.planning/research/PITFALLS.md` — 13 pitfalls including RAM budget, profile misconfiguration

### Requirements
- `.planning/REQUIREMENTS.md` — Phase 2 requirements: BOOT-01, BOOT-02, BOOT-04, UX-05, AI-03, AI-04
- `.planning/ROADMAP.md` — Phase 2 goal, success criteria, key deliverables

### ADRs
- `adr/0001-base-system.md` — Superseded by ADR-0004. Original Debian decision.
- `adr/0002-demo-scope.md` — Demo scope boundaries
- `adr/0003-ai-runtime-boundaries.md` — AI integration must be optional and non-blocking

### Phase 1 Context
- `.planning/phases/01-foundation-build-system/01-CONTEXT.md` — Prior decisions: Arch+mkarchiso base, XFCE, LightDM, linux-lts, profile structure

## Existing Code Insights

### Reusable Assets
- `profiles/aetheros/profiledef.sh` — ISO metadata, bootmodes, arch. Needs `uefi.grab` → `uefi.grub` fix.
- `profiles/aetheros/packages.x86_64` — Current package list (base, linux-lts, xorg, xfce4, xfce4-goodies, lightdm, lightdm-gtk-greeter, networkmanager, dosfstools, e2fsprogs). Needs: xfce4-terminal, thunar, mousepad, firefox, zram-generator.
- `profiles/aetheros/pacman.conf` — Standard Arch pacman config with core/extra/multilib.
- `scripts/smoke-qemu.sh` — Basic QEMU boot script. Needs UEFI + auto-shutdown enhancements.

### Established Patterns
- Profile structure follows Arch releng convention: `profiledef.sh`, `packages.x86_64`, `pacman.conf`, `airootfs/` overlay
- `airootfs/` is the single source of truth for ISO filesystem customization
- Boot config directories: `efiboot/`, `grub/`, `syslinux/` — currently empty, need GRUB config
- Validation gates G0-G8 are sequential; Phase 2 targets G6 (VM boot smoke) and G7 (UX smoke)
- Artifact naming: `aetheros-v0.1.0-demo.1-YYYYMMDDTHHMMSSZ-g<shortsha>.iso`

### Integration Points
- `profiles/aetheros/` is the single source of truth for the ISO — all build scripts reference this
- `out/` and `work/` are generated artifact directories (gitignored)
- `airootfs/etc/systemd/system/` for zram service unit
- `airootfs/etc/lightdm/lightdm.conf` for auto-login config
- `airootfs/etc/sudoers.d/` for passwordless sudo
- `airootfs/etc/polkit-1/rules.d/` for shutdown/reboot polkit rules
- `grub/grub.cfg` for GRUB bootloader config

## Specific Ideas

- Hardware metrics wallpaper: text-based background showing CPU name, GPU name, RAM, etc. Static PNG generated at build time. Could evolve into dynamic hardware-based profiling in future phases.
- The "system at a glance" aesthetic targets hardware enthusiasts — the main demographic for a "neglected hardware revival" narrative.
- Enable zram for RAM optimization (carried forward from Phase 1 context)
- LightDM auto-login for demo experience (carried forward from Phase 1 context)
- `linux-lts` kernel preferred over `linux` for stability (carried forward from Phase 1 context)

## Deferred Ideas

- **Dynamic wallpaper regeneration at boot** — Regenerate wallpaper with actual hardware info each boot. Deferred to post-demo (Phase 4+) to keep Phase 2 simple.
- **BIOS boot support (syslinux)** — Dropped in favor of UEFI-only for simplicity. Could be revived for physical hardware installs.
- **Full aetherOS branding/theming** — Custom icon theme, full desktop overhaul. Deferred to post-demo.
- **Welcome tour/onboarding flow** — Stretch goal from requirements. Deferred to Phase 3+.
- **AI assistant integration** — .env.example stub in Phase 3, full integration post-demo.

---

*Phase: 02-Core Desktop & Boot*
*Context gathered: 2026-06-04*
