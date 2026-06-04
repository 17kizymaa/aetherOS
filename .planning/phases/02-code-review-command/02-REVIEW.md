---
phase: 02-code-review-command
reviewed: 2026-06-04T00:00:00Z
depth: standard
files_reviewed: 10
files_reviewed_list:
  - profiles/aetheros/profiledef.sh
  - profiles/aetheros/packages.x86_64
  - profiles/aetheros/grub/grub.cfg
  - profiles/aetheros/airootfs/etc/lightdm/lightdm.conf
  - profiles/aetheros/airootfs/etc/systemd/system/create-demo-user.service
  - profiles/aetheros/airootfs/etc/systemd/zram-generator.conf
  - profiles/aetheros/airootfs/etc/sudoers.d/demo
  - profiles/aetheros/airootfs/etc/polkit-1/rules.d/10-shutdown-reboot.rules
  - scripts/generate-wallpaper.sh
  - scripts/smoke-qemu.sh
findings:
  critical: 1
  warning: 3
  info: 3
  total: 7
status: issues_found
---

# Phase 02: Code Review Report

**Reviewed:** 2026-06-04T00:00:00Z
**Depth:** standard
**Files Reviewed:** 10
**Status:** issues_found

## Summary

Reviewed all Phase 2 source files implementing UEFI-only GRUB boot mode and core desktop applications. Found one critical bug in user creation that will cause runtime failure, multiple security/permission issues, and several code quality concerns.

## Critical Issues

### CR-01: passwd --stdin not available on Arch Linux - demo user password will not be set

**File:** `profiles/aetheros/airootfs/etc/systemd/system/create-demo-user.service:15`
**Issue:** The `passwd --stdin` option is not standard on Arch Linux. The `passwd` utility on Arch does not accept stdin passwords by default. This command will fail silently due to `|| true`, leaving the demo user with an unset password or requiring passwordless login which may not work as expected.
**Fix:**
```bash
ExecStart=/usr/bin/bash -c '\
  if ! id demo &>/dev/null; then \
    useradd -m -G wheel -s /bin/bash demo; \
  fi'
```
Alternatively, use `chpasswd` which is available on Arch:
```bash
ExecStart=/usr/bin/bash -c '\
  if ! id demo &>/dev/null; then \
    useradd -m -G wheel -s /bin/bash demo; \
    echo "demo:demo" | chpasswd 2>/dev/null || true; \
  fi'
```

## Warnings

### WR-01: Sudoers file has incorrect permissions (644 instead of required 0440)

**File:** `profiles/aetheros/airootfs/etc/sudoers.d/demo`
**Issue:** The sudoers.d file currently has permissions `-r--r-----` (644) but should be `0440` (sudoers files must be owned by root and not be world-writable or group-writable for security). When installed, this file will be rejected by `visudo -c` validation.
**Fix:** Ensure the file is packaged with mode 0440 in the profile configuration. The archiso build system should handle this, but verify with `permissions=(root, 0440)` in the profiledef.sh file or adjust build process.

### WR-02: Silent error suppression masks user creation failure

**File:** `profiles/aetheros/airootfs/etc/systemd/system/create-demo-user.service:15`
**Issue:** The `|| true` after `passwd --stdin` silently suppresses any error, making debugging difficult. Combined with the fact that `passwd --stdin` doesn't exist on Arch, the entire user setup could fail without visibility.
**Fix:** Remove `|| true` and handle errors explicitly, or use a proper user provisioning method like `chpasswd` or a pre-built user with known password.

### WR-03: smoke-qemu.sh BIOS fallback may conflict with UEFI-only profile

**File:** `profiles/aetheros/scripts/smoke-qemu.sh:14-46`
**Issue:** The script falls back to default BIOS mode when OVMF firmware is missing, but the `profiledef.sh` explicitly sets `bootmodes=("uefi.grub")` indicating UEFI-only support. This mismatch could cause false positives in smoke testing where the ISO passes in BIOS mode but fails in UEFI mode.
**Fix:** Consider adding an explicit error exit when UEFI firmware is required but missing, or document that this test is for development convenience only and may not accurately validate the UEFI-only ISO.

## Info

### IN-01: zram-generator.conf should specify units for zram-size

**File:** `profiles/aetheros/airootfs/etc/systemd/zram-generator.conf:6`
**Issue:** The value `zram-size = 1024` does not specify units. Per zram-generator documentation, values without units are interpreted as bytes, which would create a ~1KB swap device instead of 1GB.
**Fix:**
```ini
[zram0]
zram-size = 1024M
compression-algorithm = zstd
```

### IN-02: generate-wallpaper.sh uses hardcoded font without fallback

**File:** `profiles/aetheros/scripts/generate-wallpaper.sh:22`
**Issue:** The script uses `-font DejaVu-Sans` without checking if the font is installed or providing a fallback. If the font is unavailable, ImageMagick may fail or use a default font inconsistently.
**Fix:** Consider using `-font DejaVu-Sans -font-size 24 || echo "Warning: Font not found, using default"` or checking font availability with `convert -list font | grep -q DejaVu`.

### IN-03: lightdm.conf autologin-user-timeout=0 may be too aggressive

**File:** `profiles/aetheros/airootfs/etc/lightdm/lightdm.conf:7`
**Issue:** `autologin-user-timeout=0` means no delay before auto-login. For a demo/rescue system this is intentional, but it may be worth noting that users have no opportunity to select a different session or user.
**Fix:** This is intentional for the demo use case; no fix needed but consider adding a comment explaining the rationale.

---

_Reviewed: 2026-06-04T00:00:00Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_