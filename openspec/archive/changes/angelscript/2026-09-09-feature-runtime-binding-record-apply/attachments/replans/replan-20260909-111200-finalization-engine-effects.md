---
replan_id: replan-20260909-111200-finalization-engine-effects
status: applied
source: implementation
source_ref: task 7.10 source inventory and Harness build ba128a35f2bf4d7ba52255ef2e0e47e5
scope: apply typed non-declaration effects during fresh Engine construction
base_commit: a9afd56e73b9289ed32dee8210d7b96ac0b3b578
base_tasks_sha256: 7768f63d749f985af92f55e437f0a99aea29f1d9032f2b82b96d3eeb31a0a618
result_tasks_sha256: 08a8c5e0e2edf8bf847170d93aaf6e4908454b69c4d1f964e8456d26351ab3be
created_at: 2026-09-09T11:11:28.6136938+08:00
resume_task: 7.10
---

# Trigger and Evidence

Task 7.10 requires ToString, skip, deprecation and finalization contributions to become detached recipes or explicit Engine-owned installation actions, and requires finalization failure to abort fresh Engine publication. Source inventory showed that the accepted file list included the recorder and effect producers but omitted `AngelscriptEngine.*`, which owns the only publication boundary after a sealed Store is installed.

The provisional typed-effect implementation reached Harness build `ba128a35f2bf4d7ba52255ef2e0e47e5`. That build compiled the new `AngelscriptEngine.cpp` application path far enough to expose an ordinary warning-as-error in `AngelscriptBinds.cpp`; it provides concrete evidence that the Engine construction boundary is required rather than speculative scope expansion.

# Decision

Add `Core/AngelscriptEngine.*` to task 7.10. The Store records ordered, typed effects. `CreateForBindings` applies them only after installing the frozen declaration image and before native connection and publication. A failed finalization effect returns no owner with its provider provenance. No legacy provider callback or `Register*` replay is introduced.

# Impact

Proposal, specifications, design, cases, proving selector, task ID and dependency edges remain valid. Task 7.10 remains pending and Ready. Task 8.2 still owns the zero-argument full Runtime factory and full provider-accounting integration; this correction only supplies the per-Store installation primitive required by task 7.10.

# Old Task Disposition

Task 7.10 remains active with its existing bounded outcome. All forty-one completed tasks and their evidence remain valid. No completed node is reopened.

# Diff Snapshot

- Affected path status: the parent records an untracked active Change and modified plugin gitlink; the plugin contains the authorized reconstruction plus task 7.10 edits.
- Focused implementation diff includes the typed effect records, effect-producing providers, FString dynamic contribution recording, and fresh-Engine application path.
- Task changes: `~ 7.10` file boundary; no task additions or removals.
- Edge changes: none.
- Artifact changes: `~ tasks.md`, `+ this applied replan`, `+ inverse sidecar`, `~ attachments/INDEX.md`.

# Preserved Work

All existing ToString function bodies, skip identities, deprecation paths, provider ordering and fresh Engine install stages are preserved. The build failure is an ordinary local compile defect and does not change the plan beyond the demonstrated file owner.

# References and Result

- Finalization inventory: `provider-inventory.md` assigns `PrimitiveTypes.ToStringContribution`, `ConfigEnums`, `Deprecations`, `SkipBinds.Defaults`, and `DirectBindArchitectureProbe` to task 7.10.
- Provisional build: `Saved/Harness/Unreal/Runs/ba128a35f2bf4d7ba52255ef2e0e47e5/UBT.log`.
- Inverse task patch: `attachments/data/replans/replan-20260909-111200-finalization-engine-effects-before.patch`.
- Result: task 7.10 resumes with the Engine publication owner explicitly in scope.
