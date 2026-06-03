# aetherOS Agent Operating Rules

These rules apply to ClaudeCode, local coding agents, assistant-generated patches, and future RAG-assisted workflows.

## Prime Directive

Keep aetherOS simple, bootable, local-first, and reproducible. Do not introduce speculative architecture during the VM-demo sprint.

## Hard Constraints

Agents must not:

1. Add a custom kernel.
2. Add a custom package manager.
3. Add autonomous self-modifying behavior.
4. Add cloud dependencies required for boot or desktop UX.
5. Commit secrets, API keys, model weights, private logs, or `.env` files.
6. Add AUR helpers or source-built packages unless explicitly approved.
7. Replace mkarchiso as the demo ISO build path.
8. Add background services that are not required for the VM demo.
9. Modify generated ISO artifacts directly instead of changing the source profile.
10. Make broad repo rewrites without a task-specific reason.

## Required Agent Workflow

Before editing:

1. Read `README.md`.
2. Read `docs/SPRINT_OPERATIONS.md`.
3. Read `context/PROJECT_BRIEF.md`.
4. Read `context/CONSTRAINTS.md`.
5. Check `context/CURRENT_STATE.md` and `context/KNOWN_ISSUES.md`.

For every change:

1. State the goal.
2. Identify files changed.
3. Keep the diff small.
4. Preserve bootability.
5. Update docs if behavior changes.
6. Run the relevant validation gate.
7. Record unresolved risks in `context/KNOWN_ISSUES.md`.

## AI/NIM/Local Inference Rules

- NVIDIA NIM API access must be optional.
- Use `.env.example` for variable names only.
- Required variable example: `NVIDIA_API_KEY=`.
- Missing API keys must degrade gracefully.
- Local inference support must not require bundled model weights.
- Future RAG support must use local generated indexes ignored by git.

## Done Criteria for Agent Tasks

An agent task is done only when:

- The change is committed or ready as a clean diff.
- Validation steps are documented.
- No new boot blockers are introduced.
- No sprint constraints are violated.
- Any follow-up is recorded in `context/TASKS.md` or `context/KNOWN_ISSUES.md`.