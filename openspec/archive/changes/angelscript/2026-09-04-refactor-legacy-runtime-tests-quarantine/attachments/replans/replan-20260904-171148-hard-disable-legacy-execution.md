---
replan_id: replan-20260904-171148-hard-disable-legacy-execution
status: applied
source: user
source_ref: conversation:2026-09-04-hard-disable-legacy-execution
scope: legacy runtime activation boundary
base_commit: 47d38dffc062a79e8f9e7c319981406ea79772c3
base_tasks_sha256: 8030264679fb1fa9b4254e0e0e9b2b129c21cbe347ff2de921bce1db5da3cf6d
result_tasks_sha256: 01fe0b150ac0c4af7af36a3a3c59b60a8aef9a49c1954a9e7101c4c2cd23393f
created_at: 2026-09-04T17:11:48+08:00
resume_task: "2.2"
---

# Hard-disable preserved legacy execution

## Trigger and Evidence

After the default-dormant Runtime/Editor baseline passed, the user explicitly removed the requirement to keep the old implementation config-restorable and directed that all old execution remain paralyzed while architecture is rebuilt from the bottom up.

## Decision

Keep legacy source files in place as reference, but remove the newly introduced `bEnableLegacyRuntime` setting and checked-in config key. `FAngelscriptRuntimeModule::IsLegacyRuntimeEnabled()` remains the one cross-module decision and returns false unconditionally for this reconstruction baseline.

Do not promise that retained legacy startup stays executable. Any later reuse or reactivation requires an explicit Change, dependency review, and focused verification.

## Impact

- Proposal, design, and runtime startup delta spec no longer describe config/restart reactivation.
- Ready Task `2.2` also removes the temporary recovery surface and updates the baseline assertion.
- Module shells, settings pages unrelated to activation, legacy source locations, generated artifacts, and the replacement test namespace remain unchanged.

## Old Task Disposition

Task `2.1` remains valid evidence that the subsystem shell is dormant and non-bypassable. Its temporary config-backed implementation is superseded by Task `2.2`'s stronger fixed gate; completed work is not unchecked.

## Diff Snapshot

- Affected planning: proposal, design, runtime delta spec, Task `2.2`, attachment index.
- Affected implementation: Runtime module/settings, default Engine config, baseline assertion, already-planned dependent module gates.
- DAG edges: unchanged.

## Preserved Work

Separate legacy/replacement test macros, real RED/GREEN evidence, fast-headless verification, source preservation, and the no-generated-rewrite boundary remain valid.

## References and Result

- Runtime GREEN run `a278e783518343659e7bbb5373669402`
- `proposal.md`
- `design.md`
- `specs/angelscript/runtime/startup/spec.md`
- `tasks.md`

The updated Task DAG resumes at Task `2.2`.
