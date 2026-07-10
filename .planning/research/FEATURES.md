# Feature Landscape

**Domain:** Lightweight Linux-based operating environment for hardware revival (VM demo)
**Researched:** 2026-06-03

## Table Stakes

Features users expect. Missing = product feels incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Boot to graphical session | Core promise of "desktop OS" | Medium | Requires working XFCE4 + LightDM in ISO profile |
| Terminal access | Expected on any Linux system | Low | xfce4-terminal in XFCE; trivial to include |
| File manager | Expected for file navigation | Low | Thunar is XFCE default; trivial to include |
| Text editor | Expected for notes/config | Low | Mousepad is XFCE default; trivial to include |
| Help/about document | Users need orientation | Low | Can be a simple HTML or text file on desktop |
| Shutdown/reboot | Basic system operation | Low | XFCE provides this natively |
| Build reproducibility | Core project requirement | Medium | mkarchiso profile + scripts must be complete |
| Checksum generation | Build provenance | Low | sha256sum in scripts |
| Responsive at 2 GB RAM | Core performance requirement | Medium | Requires careful package selection; no bloat |

## Differentiators

Features that set product apart. Not expected, but valued.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Aether Workbench launcher | Single entry point for workflows; feels intentional | Medium | zenity-based menu (already in bootstrap script); needs desktop file on ISO |
| Auto-detection of existing content | "It already knows what I have" moment | Medium-High | RECOG-01; requires filesystem scanning at first boot; defer to post-demo |
| Smart categorization (Projects, Photos, Documents) | "Of course it organized it that way" moment | High | RECOG-02; requires heuristics or ML; defer to post-demo |
| Living Archive search view | Unified view of all local content | High | RECOG-03; requires indexing; defer to post-demo |
| Project templates | Quick-start for common workflows | Low | Already scaffolded in runtime/project-templates/; needs integration |
| Backup integration | Data protection narrative | Medium | borgbackup/restic in bootstrap script; too heavy for base demo ISO |
| Optional AI assistant | Future differentiator | High | Must be non-blocking; .env.example pattern; defer to post-demo |

## Anti-Features

Features to explicitly NOT build.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Custom kernel | Violates constraint; massive complexity | Use standard Arch linux kernel |
| Custom package manager | Violates constraint; ecosystem isolation | Use pacman (Arch) or apt (Debian fallback) |
| Cloud dependencies for boot | Violates local-first principle | All features must work offline |
| Electron apps in base profile | RAM hog; cold start is slow | Use native GTK/XFCE apps |
| Full office suite (LibreOffice) in base | ~200 MB RAM; not needed for demo | Install on demand or defer to post-demo |
| Creative suite (GIMP, Inkscape, Audacity) in base | Too heavy for 2 GB target | Defer to post-demo or on-demand install |
| Background services (borg, restic, syncthing, timeshift) | RAM + complexity; not needed for demo | Defer to post-demo |
| Bundled AI model weights | Too large; violates "no bundled weights" constraint | Optional download; graceful degradation |
| Custom desktop environment | Violates "no novelty" principle | Use XFCE4 with light theming |
| Installer for v0.1 | Out of scope for VM demo | Live ISO is sufficient |

## Feature Dependencies

```
Boot to graphical session --> Terminal, File manager, Text editor
Boot to graphical session --> Help/about document
Boot to graphical session --> Shutdown/reboot
Aether Workbench launcher --> Project templates
Auto-detection --> Smart categorization --> Living Archive
Optional AI assistant --> .env.example pattern
Build reproducibility --> Checksum generation --> Release manifest
```

## MVP Recommendation

For v0.1.0-demo.1, prioritize:

1. **Boot to graphical session** (BOOT-01/02/03) -- the foundation
2. **Terminal, file manager, text editor** (UX-01) -- table stakes
3. **Help/about document** (UX-02) -- orientation
4. **Shutdown/reboot** (UX-03) -- basic operation
5. **Build reproducibility + checksum** (BUILD-01/02) -- provenance
6. **Known limitations documented** (BUILD-03) -- transparency
7. **Responsive at 2 GB RAM** (PERF-01) -- performance proof

Defer:
- **RECOG-01/02/03** (content recognition): Requires significant additional development; the "smart" narrative is compelling but the demo can succeed with manual organization. Build the hooks (scanning script stubs) but don't implement fully.
- **Aether Workbench launcher**: Nice differentiator but not required for demo acceptance. Can be added in Phase 3 if time permits.
- **Backup tools**: Important for the narrative but too heavy for base ISO. Document as "available via pacman" rather than bundling.
- **AI assistant**: Must remain optional. Create .env.example and a stub script that degrades gracefully.

## Sources

- PROJECT.md: /home/anphuni/aetherOS/.planning/PROJECT.md (requirements)
- VM_DEMO_ACCEPTANCE.md: /home/anphuni/aetherOS/docs/VM_DEMO_ACCEPTANCE.md (acceptance criteria)
- SPRINT_OPERATIONS.md: /home/anphuni/aetherOS/docs/SPRINT_OPERATIONS.md (operational scope)
- ADR 0002: /home/anphuni/aetherOS/adr/0002-demo-scope.md (demo scope)
- context/rag/04_operational-demo-schema.md (strategic architecture guidance)
