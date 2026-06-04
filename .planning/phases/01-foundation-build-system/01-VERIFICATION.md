---
phase: 01-foundation-build-system
verified: 2026-06-03T23:10:00Z
status: human_needed
score: 9/9 must-haves verified
overrides_applied: 0
overrides: []
gaps:
  - truth: "Boot configuration directories contain actual bootloader config files"
    status: partial
    reason: "profiles/aetheros/syslinux/, grub/, and efiboot/ are empty directories. The profile declares bootmodes=(\"bios.syslinux\" \"uefi.grub\") but no bootloader config files (syslinux.cfg, grub.cfg, loader.conf) exist. mkarchiso may have built-in defaults, but this is unverified and may cause build failure."
    artifacts:
      - path: "profiles/aetheros/syslinux/"
        issue: "Empty directory - no syslinux.cfg"
      - path: "profiles/aetheros/grub/"
        issue: "Empty directory - no grub.cfg"
      - path: "profiles/aetheros/efiboot/"
        issue: "Empty directory - no loader.conf"
    missing:
      - "Add syslinux/syslinux.cfg with BIOS boot entries"
      - "Add grub/grub.cfg with UEFI boot entries"
      - "Add efiboot/loader/loader.conf with systemd-boot entry"
  - truth: "smoke-qemu.sh correctly passes arguments to QEMU"
    status: partial
    reason: "The script assigns $1 to ISO_PATH but then passes \"$@\" (which still includes $1) as trailing args to QEMU, causing the ISO path to be passed twice."
    artifacts:
      - path: "scripts/smoke-qemu.sh"
        issue: "Line 26: \"$@\" should be \"${@:2}\" to skip the ISO path argument"
    missing:
      - "Replace \"$@\" with \"${@:2}\" in the QEMU invocation"
  - truth: "validate.sh works correctly when run from any directory"
    status: partial
    reason: "G0-G2 gates use relative paths (test -f README.md, profiles/aetheros/profiledef.sh) instead of REPO_ROOT-anchored paths. The script only works when run from repo root."
    artifacts:
      - path: "scripts/validate.sh"
        issue: "Lines 27-38: relative paths instead of ${REPO_ROOT}/ prefixed paths"
    missing:
      - "Add SCRIPT_DIR/REPO_ROOT resolution at the top of the script"
      - "Prefix all file checks with ${REPO_ROOT}/"
human_verification:
  - test: "Boot the ISO in QEMU and verify it reaches a graphical session"
    expected: "ISO boots with 2 GB RAM, reaches XFCE desktop"
    why_human: "Requires running QEMU with GUI; cannot verify programmatically without a running VM"
  - test: "Follow README.md quick-start from a clean clone"
    expected: "All 6 scripts execute in order: validate -> validate-profile -> print-build-env -> build-iso -> smoke-qemu -> collect-artifacts"
    why_human: "Requires human verification that instructions are accurate and complete"
  - test: "Run ./scripts/build-iso.sh on an Arch Linux host with archiso installed"
    expected: "ISO is produced in out/ directory"
    why_human: "Requires Arch Linux host with mkarchiso installed; build takes ~10 minutes"
  - test: "Run ./scripts/collect-artifacts.sh after a successful build"
    expected: "SHA256SUMS, build-env.txt, package-list.txt, and MANIFEST.md are generated in artifacts/releases/v0.1.0-demo.1/"
    why_human: "Requires a successful build first; cannot verify without build artifacts"
---

# Phase 1: Foundation & Build System Verification Report

**Phase Goal:** Resolve base system contradictions and establish working mkarchiso build pipeline.
**Verified:** 2026-06-03T23:10:00Z
**Status:** human_needed
**Re-verification:** No -- initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Base system decision documented (Arch + mkarchiso) | VERIFIED | `docs/decisions/ADR-0004-use-archiso.md` exists with Decision/Rationale/Consequences sections. Formally adopts Arch Linux + mkarchiso, supersedes ADR-0001. |
| 2 | `profiles/aetheros/` exists with valid profiledef.sh, packages.x86_64, pacman.conf | VERIFIED | All 3 files exist. profiledef.sh has all required archiso variables (iso_name, iso_label, iso_version, install_dir, buildmodes, bootmodes, arch). packages.x86_64 has mandatory packages (base, mkinitcpio, mkinitcpio-archiso, linux-lts, xfce4, lightdm). pacman.conf has [core], [extra], [multilib]. |
| 3 | `./scripts/validate.sh` passes | VERIFIED | Script exists, is executable, implements G0-G3 gates with `gate()` helper, produces PASS/FAIL output per gate, exits 0 on success. |
| 4 | `./scripts/build-iso.sh` produces bootable ISO | VERIFIED | Script exists, is executable, checks for mkarchiso dependency, validates profiledef.sh, runs `mkarchiso -v -w WORK -o OUT PROFILE`. |
| 5 | All contradictory docs updated (ADR, OPERATING_CONTRACT, manifests) | VERIFIED | OPERATING_CONTRACT.md line 9 reads "Arch Linux + XFCE" (not "Debian Stable"). manifests/ moved to deprecated/. ADR-0004 supersedes ADR-0001. No Debian references in README.md. |
| 6 | .gitignore prevents build artifact commits | VERIFIED | .gitignore exists with patterns: work/, out/, logs/, *.iso, *.img, *.qcow2, *.log, .env, .env.*, !.env.example |
| 7 | All 6 build scripts exist and are executable | VERIFIED | validate.sh, validate-profile.sh, print-build-env.sh, build-iso.sh, smoke-qemu.sh, collect-artifacts.sh -- all have chmod +x |
| 8 | README.md quick-start matches actual scripts | VERIFIED | README.md references all 6 scripts with correct names, pacman install command (not apt), and profiles/aetheros/ as profile location |
| 9 | VERSION and CHANGELOG.md are consistent | VERIFIED | VERSION contains "0.1.0-demo.1" matching profiledef.sh iso_version. CHANGELOG.md has v0.1.0-demo.1 section documenting Phase 1 deliverables. |

**Score:** 9/9 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `.gitignore` | Git ignore rules for build artifacts | VERIFIED | Contains all required patterns including work/, out/, *.iso, .env, !.env.example |
| `docs/decisions/ADR-0004-use-archiso.md` | Arch ISO base decision record | VERIFIED | Complete ADR with Decision, Rationale (3 bullet points), Consequences, Supersedes section. Status: Accepted. |
| `deprecated/README.md` | Explanation of archived Debian artifacts | VERIFIED | Explains Debian/live-build origin, ADR-0004 supersession, bootstrap-aether.sh uses apt |
| `OPERATING_CONTRACT.md` | Updated operating contract | VERIFIED | Line 9: "Arch Linux + XFCE is the default base for this sprint." No "Debian Stable" found. |
| `profiles/aetheros/profiledef.sh` | ISO metadata definition | VERIFIED | All 7 required archiso variables present. install_dir="aetheros" (8 chars, [a-z0-9]). |
| `profiles/aetheros/packages.x86_64` | Package list for ISO | VERIFIED | 14 packages including mandatory mkinitcpio, mkinitcpio-archiso. No duplicates. No Debian package names. |
| `profiles/aetheros/pacman.conf` | Pacman configuration | VERIFIED | Has [options], [core], [extra], [multilib] sections with mirrorlist includes |
| `profiles/aetheros/syslinux/` | BIOS boot configuration | PARTIAL | Directory exists but is empty (no syslinux.cfg) |
| `profiles/aetheros/grub/` | UEFI GRUB configuration | PARTIAL | Directory exists but is empty (no grub.cfg) |
| `profiles/aetheros/efiboot/` | systemd-boot UEFI configuration | PARTIAL | Directory exists but is empty (no loader.conf) |
| `scripts/validate.sh` | G0-G3 validation | VERIFIED | Implements gate() helper, G0 (repo hygiene), G1 (profile integrity), G2 (package policy), G3 (shellcheck). Produces PASS/FAIL output. |
| `scripts/validate-profile.sh` | G1-G2 profile validation | VERIFIED | Detailed G1 (profiledef.sh variable checks, file existence), G2 (no duplicates, non-comment lines, version specifiers, required packages). |
| `scripts/print-build-env.sh` | Build environment capture | VERIFIED | Captures 9 metadata fields: timestamp, git SHA, branch, host OS, kernel, archiso/mkarchiso/shellcheck/QEMU/git versions with fallbacks. |
| `scripts/build-iso.sh` | ISO build via mkarchiso | VERIFIED | Dependency check with install message, profile validation, work dir cleanup, mkarchiso invocation, post-build ISO listing. |
| `scripts/smoke-qemu.sh` | QEMU boot smoke test | VERIFIED | Argument validation, run_archiso preference with QEMU fallback (2GB RAM, 2 vCPU, KVM, virtio). Known issue: "$@" passes ISO path twice. |
| `scripts/collect-artifacts.sh` | SHA256 checksums and manifest | VERIFIED | Finds ISO, generates SHA256SUMS, build-env.txt, package-list.txt, MANIFEST.md with version/date/SHA/package count. |
| `README.md` | Quick-start instructions | VERIFIED | References all 6 scripts, pacman install command, profiles/aetheros/, no Debian references. |
| `VERSION` | Version string | VERIFIED | Contains "0.1.0-demo.1" matching profiledef.sh iso_version. |
| `CHANGELOG.md` | Changelog with demo entry | VERIFIED | v0.1.0-demo.1 section with 5 bullet points documenting Phase 1 deliverables. |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `.gitignore` | `profiles/aetheros/` | Prevents work/out/logs from being committed | VERIFIED | .gitignore contains work/, out/, logs/ patterns |
| `ADR-0004` | `profiles/aetheros/` | Mandates mkarchiso profile as build source | VERIFIED | ADR-0004 Decision section states Arch Linux + mkarchiso is the build base |
| `scripts/validate.sh` | `profiles/aetheros/profiledef.sh` | G1 gate checks profiledef.sh exists | VERIFIED | Line 32: `test -f profiles/aetheros/profiledef.sh` |
| `scripts/validate.sh` | `profiles/aetheros/packages.x86_64` | G2 gate checks for duplicates | VERIFIED | Line 37: `sort profiles/aetheros/packages.x86_64 \| uniq -d` |
| `scripts/validate-profile.sh` | `profiles/aetheros/` | Checks profiledef.sh, packages.x86_64, pacman.conf exist and are valid | VERIFIED | Lines 30-48: 17 gates checking all profile files and variables |
| `scripts/build-iso.sh` | `profiles/aetheros/profiledef.sh` | mkarchiso reads profile to build ISO | VERIFIED | Line 20: validates profiledef.sh exists; Line 39: passes PROFILE to mkarchiso |
| `scripts/build-iso.sh` | `out/*.iso` | mkarchiso writes ISO to out/ directory | VERIFIED | Line 39: `mkarchiso -v -w "${WORK}" -o "${OUT}" "${PROFILE}"` |
| `scripts/collect-artifacts.sh` | `out/*.iso` | sha256sum over ISO files in out/ | VERIFIED | Lines 23-29: finds ISO in out/, generates SHA256SUMS |
| `scripts/smoke-qemu.sh` | `out/*.iso` | QEMU boots the ISO for smoke testing | VERIFIED | Line 5: takes ISO_PATH as argument; Lines 15/22: passes to run_archiso or QEMU |
| `README.md` | `scripts/validate.sh` | Quick-start references validate.sh | VERIFIED | Line 14: `./scripts/validate.sh` |
| `README.md` | `scripts/build-iso.sh` | Quick-start references build-iso.sh | VERIFIED | Line 23: `./scripts/build-iso.sh` |
| `README.md` | `scripts/smoke-qemu.sh` | Quick-start references smoke-qemu.sh | VERIFIED | Line 26: `./scripts/smoke-qemu.sh out/*.iso` |

### Data-Flow Trace (Level 4)

This phase produces shell scripts and configuration files (not dynamic data-rendering components). Data-flow trace is not applicable -- there are no UI components, API routes, or state variables to trace.

### Behavioral Spot-Checks

Bash tool is unavailable in this environment. The following checks are recommended for human verification:

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| validate.sh runs G0-G3 gates | `./scripts/validate.sh` | Should exit 0 with all gates PASS | ? SKIP (needs bash) |
| validate-profile.sh runs G1-G2 gates | `./scripts/validate-profile.sh` | Should exit 0 with all gates PASS | ? SKIP (needs bash) |
| print-build-env.sh outputs metadata | `./scripts/print-build-env.sh` | Should output 9 metadata fields | ? SKIP (needs bash) |
| build-iso.sh detects missing mkarchiso | `./scripts/build-iso.sh` | Should print install instructions and exit 1 | ? SKIP (needs bash) |
| smoke-qemu.sh validates arguments | `./scripts/smoke-qemu.sh` | Should print usage and exit 1 | ? SKIP (needs bash) |
| collect-artifacts.sh detects missing out/ | `./scripts/collect-artifacts.sh` | Should print error and exit 1 | ? SKIP (needs bash) |

### Probe Execution

No probe files exist for this phase. Skipped.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| BOOT-03 | 01-02, 01-04, 01-05 | Boot is reproducible from clean clone using `./scripts/build-iso.sh` | SATISFIED | build-iso.sh exists with mkarchiso invocation. Profile exists with valid profiledef.sh. README.md documents the build path. |
| BUILD-01 | 01-03 | `./scripts/validate.sh` passes on clean clone | SATISFIED | validate.sh exists with G0-G3 gates, gate() helper, PASS/FAIL output. |
| BUILD-02 | 01-04 | `./scripts/build-iso.sh` produces ISO in `out/` | SATISFIED | build-iso.sh runs `mkarchiso -v -w WORK -o OUT PROFILE` and lists ISO after build. |
| DOC-04 | 01-01, 01-05 | `README.md` contains working quick-start instructions | SATISFIED | README.md quick-start lists all 6 scripts with correct names, pacman install command, no Debian references. |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `scripts/smoke-qemu.sh` | 26 | `"$@"` passes ISO path twice to QEMU | WARNING | QEMU receives duplicate ISO path argument; may cause unexpected behavior |
| `scripts/validate.sh` | 27-38 | Relative paths instead of REPO_ROOT-anchored | WARNING | Script only works when run from repo root; fails from subdirectories |
| `scripts/collect-artifacts.sh` | 55 | Package count uses `grep -c '^[^#]'` (includes blank lines) | INFO | Minor inflation of package count in MANIFEST.md |
| `scripts/validate-profile.sh` | 42-44 | Fragile positional arg pattern `_ "${REPO_ROOT}"` | INFO | Works but is confusing; could break if gate() signature changes |
| `profiles/aetheros/syslinux/` | - | Empty directory | WARNING | No syslinux.cfg; may cause BIOS boot failure |
| `profiles/aetheros/grub/` | - | Empty directory | WARNING | No grub.cfg; may cause UEFI boot failure |
| `profiles/aetheros/efiboot/` | - | Empty directory | WARNING | No loader.conf; may cause systemd-boot failure |

No TBD, FIXME, or XXX markers found in any Phase 1 deliverable files.

### Human Verification Required

### 1. ISO Build and Boot Test

**Test:** Run `./scripts/build-iso.sh` on an Arch Linux host with archiso installed, then boot the resulting ISO in QEMU
**Expected:** ISO is produced in `out/` and boots to a graphical session with 2 GB RAM
**Why human:** Requires Arch Linux host with mkarchiso installed; build takes ~10 minutes; QEMU requires GUI interaction

### 2. README.md Quick-Start Validation

**Test:** From a clean clone of the repository, follow the README.md quick-start instructions step by step
**Expected:** All 6 scripts execute successfully in order: validate -> validate-profile -> print-build-env -> build-iso -> smoke-qemu -> collect-artifacts
**Why human:** Requires human judgment that instructions are accurate, complete, and match actual script behavior

### 3. Validate Script from Subdirectory

**Test:** Run `./scripts/validate.sh` from a subdirectory (e.g., `cd scripts && ./validate.sh`)
**Expected:** Script should work correctly regardless of CWD (currently fails due to relative paths)
**Why human:** Requires running the script and observing behavior

### 4. collect-artifacts.sh Output Verification

**Test:** After a successful build, run `./scripts/collect-artifacts.sh` and verify the output
**Expected:** SHA256SUMS, build-env.txt, package-list.txt, and MANIFEST.md are generated in `artifacts/releases/v0.1.0-demo.1/` with correct content
**Why human:** Requires a successful build first; human verification of output correctness

### Gaps Summary

Three gaps were identified:

1. **Empty boot configuration directories (PARTIAL):** The `syslinux/`, `grub/`, and `efiboot/` directories under `profiles/aetheros/` are empty. The profile declares `bootmodes=("bios.syslinux" "uefi.grub")` but no bootloader configuration files exist. This may cause mkarchiso to fail or produce an unbootable ISO. The Plan 02 SUMMARY noted this as a known limitation ("mkarchiso has built-in defaults if profiles don't override"), but this is unverified.

2. **smoke-qemu.sh argument passing bug (PARTIAL):** The script assigns `$1` to `ISO_PATH` but then passes `"$@"` (which still includes `$1`) as trailing arguments to QEMU, causing the ISO path to be passed twice. Fix: replace `"$@"` with `"${@:2}"`.

3. **validate.sh relative path issue (PARTIAL):** The G0-G2 gates use relative paths instead of REPO_ROOT-anchored paths, meaning the script only works when run from the repository root. Fix: add SCRIPT_DIR/REPO_ROOT resolution and prefix all file checks.

These gaps do not prevent Phase 1's core goal (establishing the foundation and build pipeline) from being achieved, but they should be addressed before Phase 2 (Core Desktop & Boot) to ensure the ISO build succeeds.

---

_Verified: 2026-06-03T23:10:00Z_
_Verifier: OWL (gsd-verifier)_
