# Phase 2: Core Desktop & Boot - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-04
**Phase:** 02-code-review-command
**Areas discussed:** Auto-login strategy, zram configuration, Bootloader config, XFCE session setup, Demo visuals

---

## Auto-login Strategy

| Option | Description | Selected |
|--------|-------------|----------|
| Full auto-login | LightDM auto-logs in as demo user with no interaction. Seamless demo. | ✓ |
| Click-to-login | LightDM greeter shows user icon, click to login (no password). | |
| Password-protected | Standard login with a password (e.g., 'demo'). More realistic but adds friction. | |

**User's choice:** Full auto-login
**Notes:** Best for the "it just works" narrative.

| Option | Description | Selected |
|--------|-------------|----------|
| demo | Simple, clear, documented. | ✓ |
| aetheros | Matches ISO name/label. | |
| user | Generic and invisible. | |

**User's choice:** demo
**Notes:** Owning the demo nature in the username reinforces the narrative.

| Option | Description | Selected |
|--------|-------------|----------|
| Yes, passwordless sudo | Allows shutdown/reboot from terminal without password. | ✓ |
| Polkit rules only | GUI shutdown works, terminal sudo needs password. | |
| You decide | Claude picks approach. | |

**User's choice:** Yes, passwordless sudo
**Notes:** Keeps the demo frictionless.

---

## zram Configuration

| Option | Description | Selected |
|--------|-------------|----------|
| zram swap, 1 GB, zstd | 1 GB zram swap with zstd compression. Best tradeoff. | ✓ |
| zram swap, 512 MB, zstd | Smaller, more conservative. | |
| zram swap, 2 GB, lzo-rle | Full RAM-sized, faster but less compression. | |

**User's choice:** zram swap, 1 GB, zstd
**Notes:** Gives effective ~3-4 GB swap space.

| Option | Description | Selected |
|--------|-------------|----------|
| systemd service in airootfs | Systemd unit file in airootfs. Clean, standard. | ✓ |
| mkinitcpio hook | Earlier activation but more complex. | |
| You decide | Claude picks approach. | |

**User's choice:** systemd service in airootfs
**Notes:** Package: zram-generator.

---

## Bootloader Config

| Option | Description | Selected |
|--------|-------------|----------|
| Both GRUB + syslinux | Maximum compatibility, matches original bootmodes. | |
| GRUB only (UEFI) | Simpler, fewer config files. Most modern VMs use UEFI. | ✓ |
| syslinux only (BIOS) | Simplest but won't boot on UEFI. | |

**User's choice:** GRUB only (UEFI)
**Notes:** Also fixes the `uefi.grab` typo in profiledef.sh to `uefi.grub`.

| Option | Description | Selected |
|--------|-------------|----------|
| 1 second | Near-instant boot. Can hold Shift for menu. | ✓ |
| 5 seconds | Default GRUB timeout. | |
| 0 seconds (hidden) | No menu, boots immediately. | |

**User's choice:** 1 second

| Option | Description | Selected |
|--------|-------------|----------|
| quiet splash | Suppresses boot messages, shows splash. Cleaner demo. | ✓ |
| quiet only | Suppresses messages, no splash. | |
| You decide | Claude picks parameters. | |

**User's choice:** quiet splash

---

## XFCE Session Setup

| Option | Description | Selected |
|--------|-------------|----------|
| Minimal custom, default XFCE | Default panel, default theme, compositor off. | ✓ |
| Branded desktop | Custom wallpaper, themed appearance. | |
| You decide | Claude picks customization level. | |

**User's choice:** Minimal custom, default XFCE
**Notes:** Keeps profile minimal and maintainable.

| Option | Description | Selected |
|--------|-------------|----------|
| Off | Saves ~50-100 MB RAM. Snappier at 2 GB. | ✓ |
| On (default) | Standard XFCE with compositing. | |
| You decide | Claude decides based on RAM budget. | |

**User's choice:** Off
**Notes:** User can re-enable after boot.

| Option | Description | Selected |
|--------|-------------|----------|
| Add only what's needed for boot | Add terminal, file manager, editor, zram-generator. | ✓ (with additions) |
| Add core apps now | Also include web browser. | |
| You decide | Claude picks minimal set. | |

**User's choice:** Add only what's needed for boot, BUT also include a web browser. Packages: xfce4-terminal, thunar, mousepad, firefox, zram-generator. Keep package list tight.

| Option | Description | Selected |
|--------|-------------|----------|
| firefox | Standard Firefox. Heavier (~300 MB RAM) but familiar. | ✓ |
| falkon | Qt-based lightweight browser. ~100 MB RAM. | |
| No browser in Phase 2 | Defer to Phase 3. | |

**User's choice:** firefox
**Notes:** Most realistic for a demo.

| Option | Description | Selected |
|--------|-------------|----------|
| Yes, add UEFI + auto-shutdown | OVMF UEFI, auto-shutdown timeout, framebuffer checks. | ✓ |
| Keep as-is for now | Current script works for basic boot. | |
| You decide | Claude picks enhancement level. | |

**User's choice:** Yes, add UEFI + auto-shutdown
**Notes:** Auto-shutdown timeout: 2 minutes.

---

## Demo Visuals

| Option | Description | Selected |
|--------|-------------|----------|
| Clean default XFCE | No branding. Lets narrative speak. | |
| Subtle aetherOS branding | Custom wallpaper with name/tagline. | ✓ (expanded) |
| You decide | Claude picks branding level. | |

**User's choice:** Subtle aetherOS messaging — hardware metrics displayed as text on wallpaper.

| Option | Description | Selected |
|--------|-------------|----------|
| Static text image | Generate PNG wallpaper at build time. Simple, no runtime deps. | ✓ |
| Dynamic script on boot | Regenerate wallpaper each boot. More impressive but complex. | |
| You decide | Claude picks approach. | |

**User's choice:** Static text image
**Notes:** Wallpaper shows hardware metrics (CPU name, GPU name, etc.) as body text on background. Faint laptop CPU name / desktop GPU name. Main demographic is hardware enthusiasts. Could grow into aesthetic device identification/hardware-based profiling.

---

## Claude's Discretion

- Exact GRUB config file content and structure (follow Arch wiki UEFI GRUB pattern)
- zram-generator systemd unit file details
- Polkit rules for passwordless shutdown/reboot
- Wallpaper generation script implementation (Python + Pillow or imagemagick)
- Whether to use `firefox` or `firefox-esr` package
- Exact sudoers entry format for passwordless sudo

## Deferred Ideas

- Dynamic wallpaper regeneration at boot — Phase 4+
- BIOS boot support (syslinux) — post-demo for physical hardware
- Full aetherOS branding/theming — post-demo
- Welcome tour/onboarding flow — Phase 3+
- AI assistant integration — Phase 3 (.env.example), full post-demo
