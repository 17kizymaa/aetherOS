# Phase 3: UX Applications & Workbench - Context

**Gathered:** 2026-06-04
**Status:** Ready for planning

## Phase Boundary

Verify core applications work and help documentation is accessible. This phase tests that XFCE applications (terminal, file manager, text editor) launch correctly and provides `.env.example` for AI integration with graceful degradation.

## Implementation Decisions

### Core Application Verification
- **D-01:** Test xfce4-terminal, thunar, and mousepad launch and responsiveness
- **D-02:** Help/about document accessible from desktop via README text file and .desktop launcher
- **D-03:** No additional styling/customization - use default XFCE behavior

### AI Integration Boundaries
- **D-04:** `.env.example` added to repository root with API variable templates
- **D-05:** Missing API credentials must not break boot or UX (graceful degradation)
- **D-06:** No actual AI services started - `.env.example` is documentation only for this phase

### Workbench Setup (deferred)
- **D-07:** Welcome tour/onboarding flow deferred to Phase 4+ (per Roadmap stretch goals)
- **D-08:** Aether Workbench launcher stub to be created (minimal implementation)

## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Requirements
- `.planning/REQUIREMENTS.md` — Phase 3 requirements: UX-01, UX-02, UX-03, UX-04, AI-01, AI-02
- `.planning/ROADMAP.md` — Phase 3 goal, success criteria, key deliverables

### Prior Phase Context
- `.planning/phases/02-code-review-command/02-CONTEXT.md` — Prior decisions: demo user setup, LightDM auto-login, zram, package list
- `.planning/phases/02-code-review-command/02-REVIEW.md` — Code review findings and fixes

### Build Pipeline
- `docs/VM_DEMO_ACCEPTANCE.md` — VM demo acceptance criteria
- `docs/SPRINT_OPERATIONS.md` — Validation gates G0-G8

### Constraints
- `AGENTS.md` — Agent operating rules
- `context/CONSTRAINTS.md` — Hard constraints

## Existing Code Insights

### Reusable Assets
- `profiles/aetheros/packages.x86_64` — Contains xfce4-terminal, thunar, mousepad, firefox already added in Phase 2
- `profiles/aetheros/airootfs/home/demo/Desktop/aetheros-readme.txt` — Desktop README already created in Phase 2
- `profiles/aetheros/airootfs/etc/skel/Desktop/aetheros-readme.desktop` — Desktop launcher already created in Phase 2

### Established Patterns
- airootfs overlay pattern: `airootfs/` is single source of truth for ISO filesystem customization
- XFCE defaults: Use standard XFCE themes and behaviors without heavy customization
- .env.example pattern: Standard template file for environment variables

### Integration Points
- `.env.example` in repository root
- `profiles/aetheros/airootfs/etc/skel/` for user skeleton files

## Specific Ideas

- Core apps (xfce4-terminal, thunar, mousepad) already in packages.x86_64 - just need verification they launch
- README already on desktop - ensure it's readable and contains useful quick-start info
- .env.example should reference any API keys that would be used in future AI integration
- No need for "AI assistant integration" scope creep - that's Phase 3's AI-01/AI-02 deliverables only

## Deferred Ideas

- Welcome tour/onboarding flow — Stretch goal from requirements, deferred to Phase 4+
- Aether Workbench launcher full implementation — Phase 4 deliverable

---

*Phase: 03-UX Applications & Workbench*
*Context gathered: 2026-06-04*