---
record: harness-workflow-evaluation-v1
result: passed
change: harness/fix-project-guidance-consistency
captured_at: 2026-09-04T11:48:53.6232224+08:00
---

# Workflow Evaluation

## Lifecycle exercised

The repair used one strict active Change, a static project-guidance RED/GREEN cycle, Chinese-first guidance updates, current-spec synchronization, live Harness route planning, Skill validation, and the public Quick gate in the selected main workspace.

## Findings and corrections

- The first focused run failed on the retained English `Unreal Engine 5.7 plugin` statement, proving the new gate observed the stale baseline before documentation changed.
- Chinese agent guidance still named Hardness, modeled Current/Goal as repository modes, pointed at a removed Skill path, deferred already-live Unreal routes, and required a Review Gate. It now matches the English selected-workspace and explicit-Review contracts.
- The root README still supported Windows PowerShell 5.1 and published root `Tools` wrappers as the only build/test entry. It now uses PowerShell 7 and exact `ue.build`, `ue.test`, and `ue.suite.run` routes.
- Ambiguous `uses pwsh.exe` wording now distinguishes direct current-process dispatch from deliberate isolated test hosts, Git hooks/native fixtures, and managed Unreal workers.

## Evidence

- `HarnessCutover.Tests.ps1`, `OpenSpecSkill.Tests.ps1`, and `Protocol.Tests.ps1` pass after the guidance update.
- System Skill validation passes for both changed live Skills.
- Strict validation passes for all five current specs and the exact active Change.
- Live `ue.status` reports UE 5.8.0 ready, and the documented build, test-prefix, and `All` suite examples each produce a successful `PlanOnly` result without starting UE work.
- The public Harness Quick profile passes all 8 gates; its runner intentionally creates fresh PowerShell 7 test hosts as the declared isolation boundary.

## Outcome

Maintained entry guidance now has one operational meaning. A caller already in PowerShell 7 invokes ordinary Harness routes directly, while process creation remains explicit and bounded to the subsystems that require isolation or owned lifetime.
