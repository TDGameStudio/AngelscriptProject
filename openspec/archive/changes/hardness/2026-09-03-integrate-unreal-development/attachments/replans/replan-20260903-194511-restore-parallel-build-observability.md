---
replan_id: replan-20260903-194511-restore-parallel-build-observability
status: applied
source: user
source_ref: "Restore multi-worktree build concurrency and expose other active builds with progress"
scope: installed-project UBT concurrency, process discovery, and bounded build progress
base_commit: 3c8de4611ba7e3dcfa91b766aeb358db4ed54982
base_tasks_sha256: 84bd7a1683b2d2a2535f3e6e855ac1cd8f7f4b70defe4c449149c0bfeefc7d4f
result_tasks_sha256: ce1ec526bb3a9c5f57afe9ac4166ebcad89e9288559e7d3c39a0af9ab9aa2275
created_at: 2026-09-03T19:45:11+08:00
resume_task: "3.4"
---

# Restore Parallel Build Observability

## Trigger and Evidence

The user corrected the blanket classification of `-NoMutex` as dangerous, required distinct worktrees to retain parallel build capability, and asked to query other active builds and their progress. The current planning truth serialized every same-engine UBT request and therefore removed an intentional capability of the copied runner.

- The retained copied runner and `Documents/Guides/Build.md` use `-NoMutex -NoEngineChanges` as the ordinary installed-project multi-worktree mode and reserve engine serialization as a fallback.
- Local UE 5.8 `GlobalOptions.cs:67-76` defines `-NoMutex` as the supported switch that permits multiple UBT instances; it is a concurrency mechanism, not intrinsically destructive behavior.
- Local UE 5.8 `UnrealBuildTool.cs:398-447` proves that UBT temp and mutex behavior can be controlled, while explicit child temp variables and `-Log` remove the known shared defaults.
- Local UE 5.8 `ProgressWriter.cs:86-96` and `ActionLogger.cs:175-221` provide bounded `@progress` and `[completed/total]` evidence suitable for status parsing.
- `-NoEngineChanges` does not cover every UHT timestamp write, so the existing known contention signature remains a fail-closed boundary rather than being ignored.

## Decision

Hardness owns a typed `Auto | Parallel | Serialize` build mode. `Auto` selects controlled parallelism only for ordinary installed-engine project builds; `Parallel` is the explicit form. Both add `-NoMutex -NoEngineChanges`, isolate logs and temporary files, and occupy a shared Hardness engine lane. Source/unknown builds, QueryTargets, generic UBT, and `Serialize` occupy the exclusive lane and use `-WaitMutex`.

Raw mutex flags remain rejected as policy ownership conflicts so callers cannot form inconsistent combinations. This does not label `-NoMutex` inherently unsafe. A known shared-engine UHT timestamp conflict promotes the result to failure and recommends `Serialize` or a dedicated EngineRoot.

`ue.process.list` identifies active UBT work across workspaces. `ue.run.status` and correlated process records return bounded structured progress from explicit logs; unavailable evidence returns `ProgressKnown=false`.

## Impact

- Amend proposal, design, Unreal delta spec, evidence, and reusable migration knowledge.
- Add Task 3.4 after the already completed initial Build task and require it before Hardness route publication.
- Extend the final performance evidence with process/status progress parsing.
- Preserve Task 3.3 as an independent ready node.

## Old Task Disposition

Tasks 2.1 and 3.1 remain checked because their discovery, build planning, argument safety, and fake-process verification are valid completed work. Their blanket installed-build serialization detail is explicitly superseded in the task cards. Follow-up implementation and verification belong only to new Task 3.4.

## Diff Snapshot

```text
Scoped status: new Unreal Skill module/data/tests and active Change are untracked in the dirty main workspace
Scoped git diff --stat: empty because the scoped work is currently untracked
Task +: 3.4 controlled cross-worktree builds and observable progress
Task ~: 2.1 and 3.1 retain completion but identify their superseded initial concurrency detail
DAG edge +: 3.1 -> 3.4 -> 4.1
DAG edge -: direct 3.1 -> 4.1
Artifact ~: proposal.md, design.md, specs/hardness/unreal/spec.md, evidence, migration knowledge, INDEX.md
Artifact +: this applied Replan
Implementation: existing Tasks 1.2 through 3.2 remain in place
```

## Preserved Work

The PS7 module foundation, engine discovery, contained lifecycle, build/UBT argument construction, Automation/commandlet behavior, report parser, completed verification, and the in-progress suite branch are unchanged. No real UE process, product code, plugin submodule, root Tools script, or OpenSpec executable is changed by this planning update.

## References and Result

- Base Task DAG SHA-256: `84bd7a1683b2d2a2535f3e6e855ac1cd8f7f4b70defe4c449149c0bfeefc7d4f`.
- Result Task DAG SHA-256: `ce1ec526bb3a9c5f57afe9ac4166ebcad89e9288559e7d3c39a0af9ab9aa2275`.
- Resume at Task `3.4`; Task `3.3` remains independently ready and no Review is created.
