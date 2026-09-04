---
replan_id: replan-20260904-170132-fast-focused-unit-tests
status: applied
source: user
source_ref: conversation:2026-09-04-fast-unit-test-startup
scope: replacement Automation verification path and startup timing evidence
base_commit: 47d38dffc062a79e8f9e7c319981406ea79772c3
base_tasks_sha256: 13ed1387f045db6e34f6216a9d12be5910b3eef735c40d20b18889f08f4758b7
result_tasks_sha256: fa059099a850c80da51e320c3360f89d8ee250ae31f0dc7672f51542edb4497f
created_at: 2026-09-04T17:01:32+08:00
resume_task: "2.1"
---

# Adopt fast focused replacement-test verification

## Trigger and Evidence

The user asked whether the new baseline was an empty test and added a requirement to determine the UE test startup floor from `Temp/uetestframework1.md`, query the UE source knowledge base through Knot, and use the fastest valid path for focused unit-test verification.

The existing baseline is not empty: it contains three state assertions covering dormant Runtime/Subsystem behavior, optional provider/extension/editor-command registration, and absence of legacy test namespaces. RED run `dd21e097c1de406c9ee67f7910d8b1f8` discovered all three and completed in `35186 ms` through the ordinary headless profile.

The local research note and UE source results both support `UnrealEditor-Cmd.exe`, exact Automation filtering, unattended NullRHI execution, and removal of optional startup work. The existing Harness `fast-headless` profile already provides that combination while retaining managed reports and process validation.

## Decision

Use `ue.test` with `Fast = $true` and the narrowest exact `Angelscript.UnitTest...` prefix for focused replacement-test work. Add a passing ordinary-versus-fast fresh-process comparison after isolation is green, and retain measured duration as environment-specific evidence.

Do not build a custom commandlet or persistent editor runner in this Change. Both would expand the implementation and validation boundary; a persistent process would also fail to prove the fresh-start dormant-state contract.

## Impact

- Task `2.1`, Task `2.2`, and Task `3.2` now use fast-headless focused verification.
- New Task `3.3` owns the controlled timing comparison and durable evidence.
- Task `4.1` now depends on Task `3.3`; later completion work is unchanged.
- The testing delta spec gains a stable fastest-supported focused-verification behavior without changing Harness APIs.

## Old Task Disposition

The earlier ordinary-headless verification commands remain valid evidence, including the required RED run. They are superseded as the default for subsequent logic-only replacement tests by the existing fast-headless option.

## Diff Snapshot

- Affected paths: proposal, design, testing delta spec, tasks, and attachments for this Change.
- Tasks: `~2.1`, `~2.2`, `~3.2`, `+3.3`, `~4.1` dependency.
- Runtime implementation: unchanged by this replan.

## Preserved Work

All completed macro separation, build evidence, RED assertions, runtime/editor work in progress, generated-artifact boundary, and legacy-source preservation remain valid.

## References and Result

- `Temp/uetestframework1.md`
- Knot UE5-main source results for `FAutomationExecCmd`, `UnrealEditor-Cmd`, NullRHI, and official AutomationTool launch patterns
- `Saved/Harness/Unreal/Runs/dd21e097c1de406c9ee67f7910d8b1f8/RunMetadata.json`
- `.agents/skills/unreal-engine-develop/data/launch-profiles.json`
- `proposal.md`
- `design.md`
- `specs/angelscript/testing/baseline/spec.md`
- `tasks.md`

The updated Task DAG resumes at Task `2.1`.
