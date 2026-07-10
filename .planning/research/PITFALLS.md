# Domain Pitfalls

**Domain:** Lightweight Linux-based operating environment for hardware revival (VM demo)
**Researched:** 2026-06-03

## Critical Pitfalls

Mistakes that cause rewrites or major issues.

### Pitfall 1: The Arch/Debian Contradiction
**What goes wrong:** The project has two incompatible build pathways specified in different authoritative documents. SPRINT_OPERATIONS.md says Arch + mkarchiso + pacman. ADR 0001 and OPERATING_CONTRACT.md say Debian + apt. The manifests/ directory has Debian package names. The bootstrap script uses apt.
**Why it happens:** The project evolved through multiple planning sessions without reconciling decisions. Different AI planning sessions produced different recommendations.
**Consequences:** Build scripts will fail. Package lists will have wrong names. The ISO won't build. Wasted hours debugging a problem that's actually a specification error.
**Prevention:** Create a new ADR (ADR 0004) that explicitly resolves this contradiction. Update ALL affected files in a single commit. The recommendation from this research is: commit to Arch + mkarchiso for the ISO demo.
**Detection:** Running `./scripts/build-iso.sh` fails with "package not found" errors because Debian package names are in an Arch package list (or vice versa).

### Pitfall 2: 2 GB RAM Budget Exceeded
**What goes wrong:** The ISO boots but the desktop is sluggish or unresponsive because too many packages/services are included.
**Why it happens:** Adding packages without checking RAM impact. Including heavy applications (Firefox, LibreOffice, GIMP) in the base profile. Enabling unnecessary background services.
**Consequences:** The demo fails the PERF-01 acceptance criterion. The "responsive" narrative is broken. The hardware revival story loses credibility.
**Prevention:** Start with a minimal package list (Xorg + XFCE4 core + LightDM + terminal + Thunar + Mousepad + NetworkManager). Add packages one at a time, measuring RAM impact. Do NOT include Firefox, LibreOffice, or creative apps in the base profile. Use `free -h` inside the VM to validate.
**Detection:** Boot the VM and run `free -h` and `htop`. If available RAM is below ~500 MB with just the desktop idle, the profile is too heavy.

### Pitfall 3: mkarchiso Profile Misconfiguration
**What goes wrong:** The ISO builds successfully but doesn't boot, or boots to a black screen, or boots to console instead of desktop.
**Why it happens:** Missing or incorrect `profiledef.sh`. Missing bootloader configuration. LightDM not enabled as a systemd service. XFCE session not properly configured. Missing xorg-server or graphics drivers.
**Consequences:** The demo cannot proceed. Debugging mkarchiso boot issues is time-consuming and frustrating.
**Prevention:** Start from the Arch Linux releng profile (`/usr/share/archiso/configs/releng/`) as a baseline. Add XFCE4 packages incrementally. Enable LightDM service via airootfs overlay. Test in QEMU after every change. Keep a known-good backup of the profile.
**Detection:** QEMU smoke test (Stage 6) catches this. If the VM doesn't reach a graphical login screen within 2 minutes, something is wrong.

### Pitfall 4: Auto-Login Not Configured for Demo
**What goes wrong:** The ISO boots to a login screen, but the demo requires typing credentials. This breaks the "it just works" narrative.
**Why it happens:** LightDM auto-login not configured in the airootfs overlay. Wrong username. Missing session specification.
**Consequences:** Demo requires manual login, which is fine functionally but breaks the "instant recognition" narrative. Worse: if the password isn't documented, the demo is blocked.
**Prevention:** Configure LightDM auto-login in `airootfs/etc/lightdm/lightdm.conf`. The default archiso live user is typically "arch" or "aether". Set autologin-user and autologin-session=xfce. Test in QEMU.
**Detection:** Boot the VM. If a login screen appears instead of auto-logging in, the config is wrong.

## Moderate Pitfalls

### Pitfall 5: QEMU KVM Not Available
**What goes wrong:** QEMU runs without KVM acceleration, making the VM extremely slow. Boot takes 5+ minutes instead of 30 seconds.
**Prevention:** Check `/dev/kvm` exists on the host. If not, use `-accel tcg` (software fallback) and document that the demo will be slower. The acceptance criteria allow software fallback.

### Pitfall 6: Pacman Keyring Issues During Build
**What goes wrong:** mkarchiso fails because pacman can't verify package signatures. Keyring is outdated or not initialized in the build environment.
**Prevention:** Run `pacman-key --init && pacman-key --populate archlinux` on the build host before building. Ensure the host system is up to date (`pacman -Syu`).

### Pitfall 7: ISO Too Large for Target Media
**What goes wrong:** The ISO exceeds the size constraint for the target deployment medium (e.g., a small USB drive).
**Prevention:** Keep the package list minimal. A minimal XFCE4 ISO should be under 1 GB. Monitor ISO size during development. If it exceeds 1.5 GB, audit the package list for bloat.

### Pitfall 8: Missing Build Scripts
**What goes wrong:** SPRINT_OPERATIONS.md references scripts (`validate.sh`, `build-iso.sh`, `smoke-qemu.sh`, `collect-artifacts.sh`) that don't exist or are only stubs.
**Why it happens:** The repo was scaffolded with documentation first, implementation second. The existing scripts in `scripts/` are stubs or serve different purposes (bootstrap-aether.sh, collect-system-report.sh, validate-vm.sh).
**Consequences:** The build pipeline cannot be executed. Every step must be done manually, defeating the reproducibility goal.
**Prevention:** Implement the four core scripts before attempting the first build. Each script should be tested independently.

## Minor Pitfalls

### Pitfall 9: Wrong Package Names Between Distributions
**What goes wrong:** Package names differ between Arch and Debian (e.g., `firefox-esr` vs `firefox`, `xfce4-terminal` vs `xfce4-terminal`). Using the wrong distro's package names.
**Prevention:** Commit to one distribution. Use `pacman -Ss <name>` to verify package names exist in Arch repos before adding to packages.x86_64.

### Pitfall 10: Forgetting to Enable systemd Services
**What goes wrong:** LightDM or NetworkManager is installed but not enabled, so it doesn't start at boot.
**Prevention:** Create symlinks in `airootfs/etc/systemd/system/` for each required service, or use `systemctl enable` in a custom mkarchiso hook.

### Pitfall 11: No .gitignore for Generated Artifacts
**What goes wrong:** ISO files, work directories, and logs get committed to git, bloating the repository.
**Prevention:** Create a `.gitignore` that excludes: `work/`, `out/`, `*.iso`, `*.img`, `*.qcow2`, `*.log`, `.env`, `logs/`. The project currently has no `.gitignore` file at all.

### Pitfall 12: Inconsistent Documentation
**What goes wrong:** docs/ and context/ contradict each other. ADRs reference decisions that were later changed.
**Prevention:** When making a decision change, update ALL affected documents in the same commit. The AGENTS.md workflow requires reading multiple docs before editing -- this helps catch contradictions.

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| Foundation (Phase 1) | Arch/Debian contradiction not resolved | Create ADR 0004 immediately; update all files |
| Foundation (Phase 1) | No .gitignore exists | Create one before any build artifacts are generated |
| Boot & Desktop (Phase 2) | ISO builds but doesn't boot graphically | Start from Arch releng profile; add XFCE incrementally |
| Boot & Desktop (Phase 2) | Auto-login not working | Test LightDM config in QEMU early; don't wait until demo day |
| Core UX (Phase 3) | Apps don't launch or are too slow | Test each app in the VM; measure RAM impact |
| Smart Features (Phase 4) | RECOG features are too complex for timeline | Use simple heuristics (file extensions, directory names) not ML |
| Release (Phase 5) | Missing checksums or manifests | Run collect-artifacts.sh and verify output before tagging |

## Sources

- SPRINT_OPERATIONS.md: /home/anphuni/aetherOS/docs/SPRINT_OPERATIONS.md (troubleshooting section)
- VM_DEMO_ACCEPTANCE.md: /home/anphuni/aetherOS/docs/VM_DEMO_ACCEPTANCE.md (acceptance criteria)
- Arch Wiki - archiso: https://wiki.archlinux.org/title/Archiso (training knowledge of common issues)
- Arch Wiki - XFCE: https://wiki.archlinux.org/title/XFCE (training knowledge)
- Arch Wiki - LightDM: https://wiki.archlinux.org/title/LightDM (training knowledge)
- context/rag/04_operational-demo-schema.md (strategic warnings about scope and sequencing)
