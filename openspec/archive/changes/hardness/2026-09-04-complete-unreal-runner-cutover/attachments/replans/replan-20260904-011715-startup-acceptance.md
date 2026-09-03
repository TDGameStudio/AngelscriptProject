---
replan_id: replan-20260904-011715-startup-acceptance
status: applied
source: user
source_ref: conversation:2026-09-04-startup-is-sufficient
scope: real acceptance gate after mapped build evidence
base_commit: 4614ff3568427f3374742dc30cea3b5efd1524bf
base_tasks_sha256: c7a1c7734eb7fda174bc9a033e8e2c48d2969d0f1e677a9268ee2429143a57cf
result_tasks_sha256: 4e5be4de11d7cb2514fc5b6d2d06009b5a4fa4104f27ffdee6b1ae765aff0815
created_at: 2026-09-04T01:17:15+08:00
resume_task: "3.3"
---

# Accept real startup and defer the product build error

## Trigger and Evidence

The real default-executor build launched through `Y:\` without Hardness adding `-NoUBA` or `-NoXGE`, then failed in the existing generated JIT provider source because `FAngelscriptJITProviderCanonicalFunctionDiagnostic` is unavailable. The user explicitly directed that this build error be handled later and required only normal startup for the current closure.

The subsequent `AngelscriptSmoke` run `8540d17f10f443c8baeb3ccef21a8d2c` launched UnrealEditor-Cmd with the mapped project, log, and report paths, initialized the plugin and AngelScript environment, executed tests, reached `Succeeded`, and returned the owned mapping to `Absent`.

## Decision

Keep the build attempt as evidence that the mapped path and default executor contract reached UBT. Do not repair or absorb the unrelated product compilation failure. Make successful real UE/Smoke startup and terminal mapping cleanup the real acceptance gate for this Change.

## Impact

- Task `3.2` records the mapped build attempt and the successful Smoke run rather than requiring the unrelated product build to compile.
- Task `3.3` remains the only ready node and owns synchronization, focused verification, and archive.
- No dependency edge changed.

## Old Task Disposition

- The previous successful-build condition in Task `3.2` is superseded by the user's explicit startup acceptance.
- The build failure remains deferred evidence and is not silently described as a passing build.

## Diff Snapshot

- Affected paths: proposal, design, Unreal delta spec, tasks, and attachments for this Change.
- Tasks: `~3.2`, `~3.3`.
- DAG edges: no changes.
- Runtime implementation: unchanged by this replan.

## Preserved Work

All completed implementation and isolated verification remain valid. Default UBA/XGE behavior, the physical/execution split, exact ownership cleanup, stable schema names, and the exclusion of broad root Tools deletion are preserved.

## References and Result

- Build run: `4977707ef2ea4c1f88025665c25df982`
- Smoke run: `8540d17f10f443c8baeb3ccef21a8d2c`
- `proposal.md`
- `design.md`
- `specs/hardness/unreal/spec.md`
- `tasks.md`

The updated Task DAG resumes at Task `3.3`.
