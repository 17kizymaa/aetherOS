# Architecture Patterns

**Domain:** Lightweight Linux-based operating environment for hardware revival (VM demo)
**Researched:** 2026-06-03

## Recommended Architecture

The architecture is a **profile-driven ISO build** with a layered overlay system and validation-gated pipeline.

```
                    Build Host (Arch Linux)
                    ========================
                            |
                    [Stage 0: Environment Capture]
                    Record host OS, kernel, archiso version, git SHA
                            |
                    [Stage 1: Repo Validation]
                    Check required files, .gitignore, docs presence
                            |
                    [Stage 2: Profile Validation]
                    Validate profiledef.sh, packages.x86_64, pacman.conf
                            |
                    [Stage 3: Package Review]
                    Check for duplicates, heavy packages, policy compliance
                            |
                    [Stage 4: ISO Build]
                    mkarchiso -v -w work/ -o out/ profiles/aetheros/
                            |
                        out/*.iso
                            |
                    [Stage 5: Artifact Capture]
                    SHA256 checksum, manifest, package list, build metadata
                            |
                    [Stage 6: VM Smoke Boot]
                    QEMU/KVM (or software fallback) boot test
                            |
                    [Stage 7: UX Smoke]
                    Terminal, file manager, editor, shutdown tested
                            |
                    [Stage 8: Tag/Release]
                    Git tag v0.1.0-demo.1, release manifest
```

### The mkarchiso Profile (Single Source of Truth)

```
profiles/aetheros/
├── profiledef.sh              # ISO name, version, author, boot mode
├── packages.x86_64            # One package name per line (no versions)
├── pacman.conf                # Mirror list, build options
├── airootfs/                  # Filesystem overlay applied to live system
│   ├── etc/
│   │   ├── lightdm/
│   │   │   └── lightdm.conf   # Auto-login config for demo
│   │   ├── skel/
│   │   │   ├── Desktop/       # Files placed on user's desktop
│   │   │   │   ├── Welcome.txt or Welcome.html
│   │   │   │   └── Aether Workbench.desktop (optional)
│   │   │   └── Templates/     # Right-click "New Document" templates
│   │   └── systemd/system/    # Symlinks to enable services
│   │       ├── lightdm.service
│   │       └── NetworkManager.service
│   └── usr/
│       └── share/
│           ├── backgrounds/   # Custom wallpaper (optional)
│           ├── icons/         # Custom icon theme (optional)
│           └── applications/  # .desktop launchers
└── README.md                  # Profile documentation
```

### Component Boundaries

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| `scripts/validate.sh` | Repo hygiene (G0), profile integrity (G1), package policy (G2), script linting (G3) | Project files, shellcheck |
| `scripts/build-iso.sh` | Runs mkarchiso with correct flags and paths (G4) | profiles/aetheros/, out/, work/ |
| `scripts/smoke-qemu.sh` | Boots ISO in QEMU, captures output (G6, G7) | out/*.iso, QEMU |
| `scripts/collect-artifacts.sh` | Generates checksums, manifests (G5) | out/*.iso, artifacts/releases/ |
| `profiles/aetheros/` | Defines the complete live system | mkarchiso, airootfs |
| `artifacts/releases/<v>/` | Release evidence (manifest, checksums, env) | scripts/collect-artifacts.sh |
| `context/` | Agent-facing state docs | Agents (RAG future) |
| `docs/` | Authoritative operational docs | Humans, agents |
| `.github/workflows/` | CI validation (G0-G3) | GitHub Actions |

### Data Flow

1. **Build input** -> Developer edits `profiles/aetheros/` (packages, configs, overlay files)
2. **Validation** -> `validate.sh` checks everything is sane before build
3. **Build** -> `build-iso.sh` runs mkarchiso which: installs packages into airootfs, applies overlay, creates squashfs, assembles ISO with bootloader
4. **Output** -> ISO lands in `out/`
5. **Verification** -> `smoke-qemu.sh` boots the ISO; human confirms desktop works
6. **Artifact capture** -> Checksum, manifest, and metadata committed to `artifacts/releases/`

## Patterns to Follow

### Pattern 1: airootfs Overlay for Customization
**What:** Place customization files directly into `airootfs/` mirroring the target filesystem structure.
**When:** Any file that needs to exist in the live system but isn't provided by a package.
**Example:**
```
# For LightDM auto-login
airootfs/etc/lightdm/lightdm.conf:
[Seat:*]
autologin-user=aether
autologin-user-timeout=0
user-session=xfce

# For default home directory content
airootfs/etc/skel/Desktop/Welcome.html -- help/about doc
```

### Pattern 2: Package Lists as Code
**What:** Plain text package lists, one package per line. No versions.
**When:** Defining what goes in the ISO.
**Example:**
```
# packages.x86_64
xfce4
xfce4-terminal
thunar
mousepad
lightdm
lightdm-gtk-greeter
networkmanager
xorg-server
xorg-xinit
```

### Pattern 3: Validation Gates
**What:** Every change must pass through ordered gates before it can be merged/tagged.
**When:** Every commit (G0-G3), every demo candidate (G4-G7), every release (G8).
**Example gate sequence:** G0 (repo hygiene) -> G1 (profile integrity) -> G2 (package policy) -> G3 (script linting) -> G4 (ISO builds) -> G5 (artifacts generated) -> G6 (VM boots) -> G7 (UX works) -> G8 (release ready).

### Pattern 4: Separation of docs/ and context/
**What:** `docs/` is authoritative operational documentation. `context/` is a summary for AI agent consumption.
**When:** Any time documentation is created or updated.
**Rule:** docs/ is always updated first. context/ must not contradict docs/. If docs change, context must be synced in the same commit.

### Pattern 5: Graceful AI Degradation
**What:** AI features are optional accelerators with zero hard dependencies.
**When:** Any feature touching AI/NIM/RAG.
```
# .env.example (committed)
NVIDIA_API_KEY=

# runtime behavior
if NVIDIA_API_KEY is set:
    use AI feature
else:
    skip silently or use heuristic fallback
```

## Anti-Patterns to Avoid

### Anti-Pattern 1: Editing the Running ISO as a Fix
**What:** Making changes to a booted live system and treating that as the fix.
**Why bad:** Changes are lost on reboot. The source profile doesn't reflect reality.
**Instead:** Always fix via `profiles/aetheros/` and rebuild the ISO.

### Anti-Pattern 2: Adding Packages Without Policy Review
**What:** Adding "just one more" package to the ISO without checking impact.
**Why bad:** Each package increases ISO size, RAM usage, build time, and potential for conflicts.
**Instead:** Every package addition goes through the checklist in SPRINT_OPERATIONS.md section 10. Ask: is it required for boot, UX, build, or demo narrative?

### Anti-Pattern 3: Mixing Build System Concepts
**What:** Using Debian package names (apt-utils, firefox-esr) in an Arch pacman profile, or referencing live-build when using mkarchiso.
**Why bad:** Causes build failures, confusion, and rework.
**Instead:** Commit to one base system. Use its native package names and build tooling. If switching, do it explicitly with an ADR and update ALL affected files.

### Anti-Pattern 4: Commit Generated Artifacts
**What:** Committing ISO files, work directories, or log files to git.
**Why bad:** Bloats the repo; makes git operations slow; risks leaking secrets in logs.
**Instead:** Only commit manifests, checksums, and summarized build evidence to `artifacts/releases/<version>/`.

### Anti-Pattern 5: Background Services in Demo ISO
**What:** Enabling services like borgbackup, restic, syncthing, timeshift in the live system.
**Why bad:** Consumes RAM and CPU in the background; increases attack surface; not needed for demo.
**Instead:** Enable only: lightdm, NetworkManager. Everything else is documentation-only or installed on demand.

## Scalability Considerations

| Concern | At Demo (1 user) | At 100 machines | At 10K machines |
|---------|-------------------|-----------------|-----------------|
| Build | Single host, local ISO | Build server + artifact mirror | CI/CD pipeline, artifact CDN |
| Deployment | QEMU/USB | PXE boot + network deploy | Image provisioning system |
| Updates | Rebuild ISO | Package mirrors + update channels | Custom repo + rolling updates |
| AI Features | .env.example only | NIM API integration | Local model fleet + orchestration |
| Content Index | Single-user scripts | Per-user indexes | Central index + local caching |

For v0.1, only the "At Demo" column matters. Everything else is future architecture.

## Sources

- SPRINT_OPERATIONS.md: /home/anphuni/aetherOS/docs/SPRINT_OPERATIONS.md (detailed pipeline and profile specification)
- Arch Wiki - archiso: https://wiki.archlinux.org/title/Archiso (training knowledge)
- context/rag/04_operational-demo-schema.md (strategic architecture guidance)
- ADR 0001-0003: /home/anphuni/aetherOS/adr/ (architecture decisions)
