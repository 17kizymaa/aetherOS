Sprint 1 Review Runbook
Repository: https://github.com/17kizymaa/aetherOS
Runbook target: docs/RUNBOOK_SPRINT1.md
Time horizon: final ~24 hours before review
Objective: deliver a convincing, coherent VM/laptop demo of a lightweight local-first operating environment.
Non-objective: feature completeness.

1. Operating Principle
For this sprint, demo readiness beats feature ambition.

Priorities, in order:

Boot reliability
Responsiveness on constrained hardware
Clear reviewer narrative
Accurate documentation
Light polish only after the above are stable
Use the current repository as source material. Do not invent capabilities that are not present in the repo or demonstrable on the review machine.

Primary source files:

README.md
docs/DEMO_FLOW.md
docs/VM_DEMO_ACCEPTANCE.md
docs/SPRINT_OPERATIONS.md
docs/known-issues.md
tasks/reviewer_handoff.md
tasks/today.md
ops/build-log.md
ops/validation-log.md
scripts/validate-vm.sh
scripts/collect-system-report.sh
runtime/welcome/aether-welcome.sh
runtime/assistant/aether-assist.sh
runtime/backup/aether-backup.sh
manifests/*.txt
2. Roles
Role	Resource	Responsibility
Build Lead	ClaudeCode terminal #1	Boot artifact, VM/laptop validation, runtime script fixes, build logs
Product Lead	ClaudeCode terminal #2	Demo story, reviewer flow, success criteria, known limitations
Repository Curator	ClaudeCode terminal #3	Public repo clarity, docs consistency, handoff checklist, changelog/log hygiene
Human Operator	Founder/operator	Final decisions, physical laptop/VM operation, demo rehearsal, ship/no-ship call
Support resources:

Local model assistant: use for drafting, summarizing, and offline demo support.
OpenRouter credits: optional for documentation or AI smoke tests only. Do not make the demo dependent on cloud API access.
3. Mandatory, Optional, Forbidden
Mandatory Tasks
These must be completed before review:

Boot one live target reliably: old laptop preferred, VM acceptable as fallback.
Verify the environment reaches a usable desktop/session without rescue steps.
Confirm welcome flow works or has a manual fallback.
Confirm core scripts are present and executable where needed:
scripts/validate-vm.sh
scripts/collect-system-report.sh
runtime/welcome/aether-welcome.sh
runtime/backup/aether-backup.sh
runtime/assistant/aether-assist.sh
Record validation results in ops/validation-log.md.
Record build or setup results in ops/build-log.md.
Update docs/known-issues.md with honest limitations.
Prepare reviewer handoff using tasks/reviewer_handoff.md.
Ensure no active secrets, tokens, or private credentials are committed.
Rehearse the reviewer demo at least once end-to-end.
Freeze changes after the final rehearsal except for P0 fixes.
Optional Tasks
Do only after mandatory tasks pass:

Branding polish: wallpaper, welcome copy, desktop launcher labels.
Screenshots or short demo recording.
ISO checksum and release artifact naming.
README polish.
AI assistant live demo.
Additional creative apps.
Performance tuning beyond obvious startup/service reductions.
Forbidden Tasks
Do not spend time on:

Major rewrites.
Base distribution migration.
Desktop environment migration.
New installer architecture.
New package manager strategy.
Large dependency additions.
Cloud-first features.
Live API dependency for the core demo.
New secrets or committed credentials.
Unlicensed branding/assets.
Claims that aetherOS is production-ready.
Refactoring working scripts for style only.
Debugging any optional feature for more than 45 minutes.
4. Critical Path Sequence
Step	Owner	Output
1. Freeze scope	Human Operator + Product Lead	Agreement that demo readiness is the only goal
2. Audit repo and scripts	Repository Curator + Build Lead	Known state, no obvious broken paths, no secrets
3. Select primary demo path	Human Operator + Build Lead	Primary: old laptop. Fallback: VM or prebuilt environment
4. Build or prepare runtime	Build Lead	Bootable/usable review environment
5. Validate VM	Build Lead	Pass/fail result in ops/validation-log.md
6. Validate laptop	Build Lead + Human Operator	Actual boot and responsiveness result
7. Finalize demo docs	Product Lead + Repository Curator	Demo flow, handoff, known issues aligned
8. Rehearse	Human Operator + Product Lead	Timed demo with fallback language
9. Freeze	Human Operator	No more optional work
10. Ship/no-ship decision	Human Operator	Green, Yellow, or Red decision
5. Decision Gates
Gate	Latest Time	Decision	Pass Condition	If Fail
Gate 0: Scope Freeze	H1	Stop feature expansion	Mandatory/optional/forbidden accepted	Human Operator cuts scope
Gate 1: Artifact Candidate	H5	Continue build path or fallback	VM or laptop candidate boots/starts	Switch to bootstrap/prepared environment
Gate 2: VM Validation	H7	VM is fallback-ready	VM reaches usable session	Use laptop-first plan
Gate 3: Laptop Validation	H10	Laptop is primary demo or not	Laptop boots and is responsive enough	Use VM as primary, laptop as discussion item
Gate 4: AI Decision	H12	Include or exclude AI demo	AI works without secrets/flakiness	Disable AI demo; explain as optional
Gate 5: Rehearsal Freeze	H16	Stop normal changes	Full demo completed once	Fix only P0 blockers
Gate 6: Ship Decision	H18-H23	Green/Yellow/Red	See ship/no-ship framework	Pivot to fallback or repo walkthrough
6. Hour-by-Hour Execution Plan
Assume H0 = start of this runbook. Shift times to the actual clock.

Time	Build Lead	Product Lead	Repository Curator	Human Operator
H0-H1	Inspect build path, artifacts, scripts	Freeze demo objective	Check git status, doc inventory	Confirm review time, laptop, charger, USB, VM host
H1-H2	Syntax/check permissions on scripts	Draft final demo story	Add/update runbook and handoff skeleton	Select primary target and fallback
H2-H3	Start ISO/build/bootstrap path	Define minimum success criteria	Check README/docs for misleading claims	Prepare boot media or VM snapshot
H3-H4	Continue build/setup, log issues	Draft reviewer-facing flow	Align docs with actual repo tree	Stay available for hardware steps
H4-H5	Attempt first VM/laptop boot	Prepare acceptance checklist	Update ops/build-log.md	Gate 1: choose continue/fallback
H5-H6	Run VM validation if available	Observe timing and UX gaps	Append validation notes	Confirm VM settings and fallback readiness
H6-H7	Fix only VM P0 issues	Write fallback language	Update docs/known-issues.md	Gate 2: VM pass/fail
H7-H8	Boot/install on old laptop	Tailor narrative to old hardware	Record hardware notes	Operate physical laptop
H8-H9	Test welcome, terminal, file manager, scripts	Map each visible feature to user value	Check doc links and paths	Record responsiveness observations
H9-H10	Fix only laptop P0 issues	Prepare slow-hardware talk track	Log boot time and failures	Gate 3: laptop primary or fallback
H10-H11	Test backup/system report scripts	Finalize demo sequence	Collect logs/output paths	Verify offline path works
H11-H12	Smoke-test AI assistant or disable it	Prepare AI explanation	Confirm no API keys/secrets committed	Gate 4: include/exclude AI
H12-H13	Package artifact/checksum if applicable	Finish reviewer handoff	Update changelog/logs	Decide code-freeze candidate
H13-H14	Support rehearsal	Lead timed rehearsal script	Note mismatches/issues	Rehearsal 1 end-to-end
H14-H15	Fix rehearsal P0 issues only	Tighten script	Patch docs only for accuracy	Approve/reject fixes
H15-H16	Re-test changed items	Prepare final talk track	Confirm repo cleanliness	Rehearsal 2 on primary path
H16-H17	Rehearse fallback path	Prepare fallback wording	Ensure handoff includes fallback	Confirm fallback can launch fast
H17-H18	Final commit/log snapshot	Final reviewer checklist	Verify public repo state	Gate 6 preliminary ship call
H18-H19	No optional changes	No optional changes	No optional changes	Final ship/no-ship decision
H19-H20	Standby for P0 only	Rest / no new content	Rest / no new content	Protected rest
H20-H21	Standby for P0 only	Rest / no new content	Rest / no new content	Protected rest
H21-H22	Standby for P0 only	Prepare concise notes only	Prepare concise notes only	Charge laptop, pack hardware
H22-H23	Final smoke test	Verify demo script	Verify handoff checklist	Confirm primary and fallback ready
H23-H24	Support live setup	Keep narrative visible	Keep repo tabs ready	Demo staging and final go
7. Fallback Plans
If ISO Build Fails
Trigger:

ISO build does not complete by Gate 1 or cannot boot by Gate 2.
Action:

Stop ISO debugging after 2 hours total.
Use the most reliable available environment:
Existing installed laptop environment with repo scripts.
VM snapshot.
Base live Linux environment with aetherOS repo checked out and runtime scripts available.
Present it as:
“Sprint 1 review environment for aetherOS, demonstrating the target runtime and operating model.”
Record ISO failure honestly in docs/known-issues.md and ops/build-log.md.
Do not claim a release-quality ISO if one is not available.

If VM Validation Fails
Trigger:

scripts/validate-vm.sh fails, VM does not boot, or VM is too slow/flaky.
Action:

Reduce VM complexity: fewer optional services, safe graphics, conservative RAM/CPU.
Try one clean boot.
If still failing, make old laptop the primary demo.
Keep VM as repo walkthrough only.
Log failure in ops/validation-log.md.
Reviewer language:

“The VM path is not the strongest artifact today; the live laptop is the primary proof of direction.”

If AI Integration Fails
Trigger:

Local model unavailable, API unavailable, latency too high, or secrets would be required.
Action:

Disable live AI demo.
Keep runtime/assistant/aether-assist.sh as an optional helper/demo stub if it works offline.
Do not enter API keys live.
Explain AI boundary using adr/0003-ai-runtime-boundaries.md.
Reviewer language:

“AI is intentionally optional. The core demo is local-first and does not depend on cloud inference.”

If Branding Is Incomplete
Trigger:

Wallpaper, icons, login branding, or desktop polish is unfinished.
Action:

Ensure the welcome script, repo docs, and demo narrative consistently say aetherOS.
Do not spend more than 30 minutes on visual polish.
Present branding as prototype-level.
Reviewer language:

“This sprint prioritizes boot reliability and clarity over visual theming.”

8. Minimum Demo Success Criteria
The review is successful if all are true:

A live environment boots to a usable session on the old laptop or fallback VM.
The environment remains stable for at least 10 minutes.
Terminal or file manager opens without unacceptable delay.
Welcome or equivalent intro flow can be shown.
At least one maintenance script can be demonstrated or shown with recorded output.
Documentation matches what is demonstrated.
Known limitations are disclosed.
No active secrets or private credentials are exposed.
The reviewer can understand what aetherOS is, who it serves, and what the next step is.
9. Ideal Demo Success Criteria
The ideal review includes:

Old laptop boots successfully from cold start.
VM also passes validation.
Welcome launcher opens automatically or manually.
Backup/system-report flow works.
Optional AI assistant works locally or with preconfigured safe credentials.
Repo has clean handoff docs and updated logs.
Build or setup path is documented.
Reviewer receives URL, commit hash, known issues, and validation notes.
Demo feels coherent, modest, and credible.
10. Reviewer-Facing Demo Flow
Target length: 8-12 minutes.

0. Opening
“aetherOS is a lightweight local-first operating environment intended to revive constrained hardware for artists, independents, and small businesses. Today’s goal is not feature completeness; it is to show a coherent, reviewable Sprint 1 environment.”

1. Boot / Live Environment
Boot old laptop if reliable.
If cold boot is too slow, start from login/session and disclose prior boot validation.
Mention actual hardware constraints.
Show:

Desktop/session
Welcome entry point
Basic responsiveness
2. Orientation
Open or show:

README.md
docs/DEMO_FLOW.md
docs/VM_DEMO_ACCEPTANCE.md
Explain:

Local-first
Lightweight
Constrained hardware
Artist/small-business use case
3. Runtime Demo
Show one or more:

Welcome script
File manager
Terminal
Project templates directory
Backup helper
System report helper
Suggested commands:

Copybash runtime/welcome/aether-welcome.sh
bash runtime/backup/aether-backup.sh
bash scripts/collect-system-report.sh
4. Optional AI Segment
Only if stable:

Copybash runtime/assistant/aether-assist.sh
If not stable:

“AI is optional and intentionally outside the boot-critical path.”

5. Repository Credibility
Show:

manifests/packages.base.txt
manifests/services.enabled.txt
docs/known-issues.md
ops/validation-log.md
ops/build-log.md
Explain that the repo is public and reviewable.

6. Close
“The Sprint 1 result is a credible direction: old hardware can boot into a focused, local-first environment with clear docs, maintenance scripts, and a path toward repeatable builds.”

11. Reviewer Handoff Checklist
Before review, confirm:

 Repository URL provided.
 Final commit hash recorded.
 Demo target identified: laptop, VM, or both.
 Hardware specs recorded if possible.
 Boot method documented.
 Demo credentials prepared out-of-band if needed.
 No credentials committed to the public repo.
 ops/build-log.md updated.
 ops/validation-log.md updated.
 docs/known-issues.md updated.
 docs/DEMO_FLOW.md accurate.
 tasks/reviewer_handoff.md accurate.
 ISO/artifact checksum recorded if applicable.
 Fallback plan tested.
 Human Operator has rehearsed the live flow.
 Laptop charger, adapter, USB drive, and VM host are ready.
12. Final Ship / No-Ship Framework
Green: Ship Primary Demo
Ship as planned if:

Old laptop boots and is usable.
VM or other fallback is available.
Docs and demo match.
No secrets exposed.
Human Operator completed rehearsal.
Action:

Proceed with laptop-first demo.

Yellow: Ship Degraded Demo
Ship with disclosure if:

Laptop works but ISO is missing.
VM works but laptop is flaky.
AI fails but core environment works.
Branding is incomplete.
Validation has non-critical warnings.
Action:

Proceed, but open with clear scope framing and known limitations.

Red: No-Ship / Pivot
Do not present as a working demo if any P0 blocker remains:

No live environment can boot.
Demo requires unrehearsed manual rescue steps.
Public repo contains secrets.
Docs materially misrepresent capabilities.
Human Operator has not rehearsed any path.
Action:

Pivot to repository walkthrough, architecture explanation, and recovery plan. Do not claim a working demo.

13. Useful Pre-Flight Commands
Run from repo root where applicable:

git status --short
git log -1 --oneline
Check shell syntax:

find scripts runtime -type f -name "*.sh" -print0 | xargs -0 -n1 bash -n
Ensure scripts are executable if needed:

find scripts runtime -type f -name "*.sh" -exec chmod +x {} \;
Basic secret scan:

git grep -nEi "(api[_-]?key|secret|token|password|openrouter|sk-[a-zA-Z0-9])" -- . || true
Run validation/reporting:

bash scripts/validate-vm.sh
bash scripts/collect-system-report.sh
Append important results to:

ops/build-log.md
ops/validation-log.md
docs/known-issues.md
14. Final Rule
If a task does not improve tomorrow’s boot reliability, responsiveness, documentation clarity, or reviewer confidence, it is out of scope for Sprint 1.
