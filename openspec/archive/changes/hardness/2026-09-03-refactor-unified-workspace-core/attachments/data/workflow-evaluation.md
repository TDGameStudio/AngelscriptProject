---
record: hardness-workflow-evaluation-v1
result: passed
change: hardness/refactor-unified-workspace-core
captured_at: 2026-09-03T17:35:03+08:00
raw_run_id: workspace-core-final-20260903-PS7
---

# Unified Workspace Core Workflow Evaluation

## Outcome and elapsed time

- Result: passed through Task 3.2; durable spec sync and final direct-closure verification remain downstream gates.
- Lifecycle start: `2026-09-03T16:21:17.5902790+08:00`.
- Capture time: `2026-09-03T17:35:03.8291496+08:00`.
- Elapsed to this evaluation: `01:13:46` (`4426.239` seconds).
- Focused Task 3.2 contract: 7/7 scenarios passed in `9,390` ms on the isolated fixture.
- Final PS7 performance process: passed in `69,500` ms.

## Verification timing

| Gate | Result | Duration |
|---|---:|---:|
| Pre-implementation Quick | 5 pass, 1 expected record-setup failure | 130.9 s |
| Final Task 3.1 Quick | 6/6 pass | 153.046 s cumulative |
| Hardness | pass | 18.879 s |
| Gate contract | pass | 19.715 s |
| Protocol | pass | 3.178 s |
| Workspace lifecycle | pass | 21.927 s |
| Git operations | pass | 79.913 s |
| OpenSpec Skill/package | pass | 9.434 s |

The final Quick was `22.146` seconds slower than the baseline. The observed difference is dominated by the real Git/worktree integration fixture, which took `79.913` seconds in the final run versus roughly `41` seconds in the preceding focused run. This machine-sensitive variation is retained as evidence, not promoted into a hard performance gate.

## Final path measurements

PowerShell `7.6.0` Core x64; one warmup, five measurements, batch size 500. Every sample passed its behavior assertion and generous disaster budget.

| Scenario | Unit | Min | Median | P95 | Max |
|---|---:|---:|---:|---:|---:|
| FreshProcess | ms | 668.8925 | 698.7980 | 722.7366 | 722.7366 |
| PersistentApi | us/op | 27.6928 | 35.5112 | 81.1530 | 81.1530 |
| TaskStatus | ms | 44.3567 | 47.1618 | 49.1815 | 49.1815 |
| FastWorkspaceStatus | ms | 268.9024 | 275.7210 | 299.6404 | 299.6404 |
| HardnessStatus | ms | 265.0599 | 271.2346 | 353.0810 | 353.0810 |
| DetailedWorkspaceStatus | ms | 7576.8823 | 8069.8695 | 15987.2657 | 15987.2657 |
| ObservationWrite | ms | 89.6336 | 94.3339 | 98.6844 | 98.6844 |

The old main-workspace status sample was about `2474` ms. The new default `workspace.status` median is `275.721` ms, an approximately `88.9%` reduction for the normal orientation path. Explicit detailed diagnostics remain intentionally expensive because this workspace currently contains more than 100,000 ignored files across top-level submodules; hooks never use that tier.

## Raw evidence

- Summary: `Saved/Hardness/Performance/workspace-core-final-20260903-PS7/Summary.json`
  - SHA-256: `ce93dc14c6ef1ec3fa26c08dd1096b544d644f22d95f5c95313bdddad383cba6`
  - Size: `3258` bytes.
- Samples: `Saved/Hardness/Performance/workspace-core-final-20260903-PS7/Samples.csv`
  - SHA-256: `5cdf62717763ade503e5e5d9e7e4092263fabfa29d5c1e1af6f49968941e6e02`
  - Size: `2559` bytes; `42` rows.
- Eight bounded observation records existed at capture time. `hardness.evolution.status` reported only their count/latest timestamp and did not load raw bodies.
- Raw paths are ignored and contain local absolute roots; this tracked file retains only relative paths, aggregates, sizes, and hashes.

## Friction and corrections

1. The initial Task Cards did not begin with one global live-surface and publication audit. Five bounded applied Replans were needed to add the live OpenSpec config, lifecycle Skill references, README entrypoints, spec metadata/knowledge, hook ignore boundary, and coupled performance contract files.
2. A route-level contract test found that several workspace commands accepted only `ProjectRoot` while Hardness supplied `WorkspaceRoot`; aliases and regression coverage repaired the local defect without changing the plan.
3. The first observation performance sample found an unborn temporary Git repository. The fixture now commits a minimal baseline because the production observation contract truthfully records HEAD.
4. The broad Quick gate remains dominated by real Git/worktree fixture setup. It is valuable as one final gate, but repeating it during small repairs would waste most of the iteration time.

## Workflow decisions

- Begin future broad Hardness plans with one tracked-file surface map covering live entrypoints, current specs and metadata, ignore/publication rules, coupled contract tests, and deferred ownership boundaries.
- Keep routine iteration on focused tests. Run the broad Quick gate once after focused repair cycles and again only when the final semantic snapshot requires it.
- Keep Task Cards flexible, but name coupled public entrypoints and contract tests whenever a path/schema/default changes.
- Use `hardness.observe` only for material friction or timing; promote one compact evaluation rather than raw event history.
- Keep fast status as the normal and Hook path. Request detailed status only for mutation preconditions or explicit diagnosis.
- Do not schedule Review automatically. Repair local defects directly, replan only when planning truth is invalid, and archive after verification unless the user or an external agent explicitly requested Review.

## Deferred work

- Unreal build/test/commandlet/UBT/status integration is the next sequential Change.
- Root `Tools` PowerShell migration/deletion marking belongs to that Unreal Change; `Tools/openspec` remains the source submodule exception.
- Packaging, Standalone, Cache, Coverage, and JIT workflows remain follow-up capabilities after the first Unreal route set.
- No plugin build or UE Automation gate was appropriate for this parent-only Skill change.
