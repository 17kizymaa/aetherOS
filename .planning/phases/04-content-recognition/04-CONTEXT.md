# Phase 4: Content Recognition & Living Archive - Context

**Gathered:** 2026-06-04
**Status:** Ready for planning

## Phase Boundary

Auto-detection and smart categorization of existing content. This phase implements filesystem scanning at first boot, heuristic-based categorization (Projects, Photos, Documents), and search integration for a unified view of local content.

## Implementation Decisions

### Auto-detection Strategy (RECOG-01)
- **D-01:** Detect folder structure by scanning `$HOME` directories at first boot
- **D-02:** Use a systemd service triggered on first boot (similar to create-demo-user)
- **D-03:** No ML models - pure file-based heuristics (RECOG-04)

### Categorization Approach (RECOG-02, RECOG-04)
- **D-04:** Use file extensions and common directory names for categorization
- **D-05:** Categories: Projects, Photos, Documents, Other (fallback)
- **D-06:** Create symlinks or a manifest file pointing to categorized content

### Search Integration (RECOG-03)
- **D-07:** Use ripgrep (rg) for content search - lightweight, fast
- **D-08:** Provide a simple search script or GUI wrapper
- **D-09:** Living Archive desktop launcher for unified view

### Implementation Constraints
- **D-10:** Must work offline - no external services
- **D-11:** Minimal RAM impact - scanning should be quick and exit
- **D-12:** No user input required for categorization

## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Requirements
- `.planning/REQUIREMENTS.md` — Phase 4 requirements: RECOG-01, RECOG-02, RECOG-03, RECOG-04
- `.planning/ROADMAP.md` — Phase 4 goal, success criteria, key deliverables

### Prior Phase Context
- `.planning/phases/03-ux-applications/03-CONTEXT.md` — Core apps verified, .env.example created
- `.planning/phases/02-code-review-command/02-CONTEXT.md` — Demo user creation pattern, systemd service pattern

### Architecture
- `.planning/research/ARCHITECTURE.md` — airootfs overlay pattern, systemd service placement
- `.planning/research/STACK.md` — Technology stack (ripgrep available)

## Existing Code Insights

### Reusable Assets
- `profiles/aetheros/airootfs/etc/systemd/system/create-demo-user.service` — Template for first-boot service pattern
- `scripts/verify-ux.sh` — Shell script boilerplate pattern
- `ripgrep` (rg) to be added to packages.x86_64 for search functionality

### Established Patterns
- airootfs systemd service placement: `airootfs/etc/systemd/system/*.service`
- airootfs multi-user.target.wants symlink for service enablement
- Shell script boilerplate: `set -euo pipefail`, SCRIPT_DIR/REPO_ROOT pattern

## Specific Ideas

- Scan standard directories: Desktop, Documents, Downloads, Projects
- Projects: Look for .git, package.json, Cargo.toml, .vscode, etc.
- Photos: Look for .jpg, .png, .gif, .raw files
- Documents: Look for .pdf, .doc, .docx, .txt, .md files
- Create a simple TUI or GUI launcher for the Living Archive
- Consider adding `fd` or keeping with `rg` (ripgrep) for file discovery

## Deferred Ideas

- ML-based categorization — explicitly out of scope for v2 (RECOG-04)
- Content thumbnails/previews — Phase 5+ if time permits
- Automatic content reorganization — deferred, scan-only for now

---

*Phase: 04-Content Recognition & Living Archive*
*Context gathered: 2026-06-04*