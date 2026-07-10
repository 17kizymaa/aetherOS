# aetherOS Requirements

**Version:** v0.1.0-demo.1
**Last Updated:** 2026-06-03

## v1 Requirements (MVP - Must Have for Demo)

These requirements must ship for the demo to pass validation gates G0-G8.

### Boot & Foundation

- [ ] **BOOT-01**: ISO boots in QEMU with 2 GB RAM, 2 vCPU
- [ ] **BOOT-02**: System reaches graphical session (XFCE) without cloud dependencies
- [x] **BOOT-03**: Boot is reproducible from clean clone using `./scripts/build-iso.sh`
- [ ] **BOOT-04**: Shutdown/reboot works from UI or documented command

### Core UX

- [ ] **UX-01**: Terminal opens and is responsive
- [ ] **UX-02**: File manager opens and is responsive
- [ ] **UX-03**: Text editor opens and is responsive
- [ ] **UX-04**: Basic help/about document is accessible from desktop
- [ ] **UX-05**: System feels responsive at 2 GB RAM (no obvious lag)

### Build Provenance

- [x] **BUILD-01**: `./scripts/validate.sh` passes on clean clone
- [x] **BUILD-02**: `./scripts/build-iso.sh` produces ISO in `out/`
- [ ] **BUILD-03**: `./scripts/collect-artifacts.sh` generates SHA256 checksum
- [ ] **BUILD-04**: Build metadata is captured (archiso version, git SHA, timestamp)

### Documentation & Transparency

- [ ] **DOC-01**: `context/CURRENT_STATE.md` reflects actual project state
- [ ] **DOC-02**: `context/KNOWN_ISSUES.md` lists remaining issues
- [ ] **DOC-03**: `CHANGELOG.md` has demo entry
- [x] **DOC-04**: `README.md` contains working quick-start instructions

### Local-First AI Boundaries

- [ ] **AI-01**: `.env.example` exists if API variables are referenced
- [ ] **AI-02**: Missing API credentials do not break boot or UX
- [ ] **AI-03**: No bundled model weights in ISO
- [ ] **AI-04**: All features work offline

## v2 Requirements (Post-Demo Differentiate)

Important but not required for v0.1.0-demo.1 acceptance.

### Workbench & Workflow

- [ ] **WORKBENCH-01**: Aether Workbench launcher provides single entry point
- [ ] **WORKBENCH-02**: Project templates available (web dev, documents, creative)
- [ ] **WORKBENCH-03**: Backup tooling available via documented install

### Content Recognition (Living Archive)

- [ ] **RECOG-01**: Auto-detection of existing folder structure at first boot
- [ ] **RECOG-02**: Smart categorization (Projects, Photos, Documents) without user input
- [ ] **RECOG-03**: Searchable unified view of local content
- [ ] **RECOG-04**: File-based heuristics (not ML) for v2 categorization

### AI Integration

- [ ] **AI-05**: Optional AI assistant launcher stub exists
- [ ] **AI-06**: Local inference support via Ollama or similar (optional install)
- [ ] **AI-07**: RAG source manifest exists under `context/rag/sources.md`

### Stretch Goals

- [ ] **STRETCH-01**: Boot at 1 GB RAM
- [ ] **STRETCH-02**: Both BIOS and UEFI boot verified
- [ ] **STRETCH-03**: Welcome tour or onboarding flow

## Out of Scope

Explicitly excluded from all versions.

| Exclusion | Rationale |
|-----------|-----------|
| Custom kernel | Violates stability constraint; unnecessary complexity |
| Custom package manager | Violates ecosystem constraint; isolation risk |
| Cloud dependencies for boot/UX | Violates local-first principle |
| Electron apps in base profile | RAM hog; cold start too slow on constrained hardware |
| Full office suite (LibreOffice) in base | ~200 MB RAM; not needed for demo narrative |
| Creative suite (GIMP, Inkscape) in base | Too heavy for 2 GB target |
| Background backup services in base | RAM + complexity; defer to post-demo |
| Bundled AI model weights | Too large; violates optional AI principle |
| Custom desktop environment | Violates "no novelty" principle; XFCE is sufficient |
| Installer for v0.1 | Out of scope for VM demo; live ISO is sufficient |
| Autonomous self-modification | Violates operational safety constraint |

## Traceability

| Requirement | Phase | Validation Gate |
|-------------|-------|-----------------|
| BOOT-01 | Phase 2 | G6 (VM boot smoke) |
| BOOT-02 | Phase 2 | G6 |
| BOOT-03 | Phase 1 | G4 (ISO build) |
| BOOT-04 | Phase 2 | G7 (UX smoke) |
| UX-01 | Phase 3 | G7 |
| UX-02 | Phase 3 | G7 |
| UX-03 | Phase 3 | G7 |
| UX-04 | Phase 3 | G7 |
| UX-05 | Phase 2 | G7 |
| BUILD-01 | Phase 1 | G3 (Script validation) |
| BUILD-02 | Phase 1 | G4 |
| BUILD-03 | Phase 5 | G5 (Artifact manifest) |
| BUILD-04 | Phase 5 | G5 |
| DOC-01 | All | G0 (Repo hygiene) |
| DOC-02 | All | G0 |
| DOC-03 | Phase 5 | G8 (Release readiness) |
| DOC-04 | Phase 1 | G0 |
| AI-01 | Phase 3 | G0 |
| AI-02 | Phase 3 | G7 |
| AI-03 | Phase 2 | G2 (Package policy) |
| AI-04 | Phase 2 | G7 |

## Sources

- Project context: `.planning/PROJECT.md`
- Research: `.planning/research/FEATURES.md`, `.planning/research/SUMMARY.md`
- Acceptance criteria: `docs/VM_DEMO_ACCEPTANCE.md`
- Operational standards: `docs/SPRINT_OPERATIONS.md`
