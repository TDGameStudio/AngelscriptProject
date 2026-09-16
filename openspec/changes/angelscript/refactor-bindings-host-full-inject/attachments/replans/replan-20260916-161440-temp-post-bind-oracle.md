---
replan_id: replan-20260916-161440-temp-post-bind-oracle
status: applied
source: user
source_ref: user 2026-09-16 Temp + TArray/basic types + bind logs; Host run c359689768d04f8abb85ad11f0918f37
scope: post-bind verification oracle and Task DAG root
base_commit: acb127e8539638b0a2ff6392b894d976a81b5bdb
base_tasks_sha256: 4739836B4331D4DD7945FBC61826C4BBBC6C9F894DC2E6FF382C2C952C630482
result_tasks_sha256: 1285819445CB9AA805D1AA59686DE6641A67C1119E81597A029A1570896215E9
created_at: 2026-09-16T16:14:40+08:00
resume_task: "1.0"
---

# Temp scripts and bind logs become the first proof

## Trigger and Evidence

The user asked how to verify a bound engine, pointed at `Plugins/Angelscript/Source/AngelscriptTest/Temp`, asked to run TArray and other basic types, look at logs, exclude the old cache, and replan.

`Temp` did not exist. Host prefix `ue.test` run `c359689768d04f8abb85ad11f0918f37` was 30/30 Success. Unreal.log showed the default runtime dormant and no `AS_BIND_*` lines. Host* cases call native pointers on a local collection; they do not call `BindScriptTypes` or compile production `TArray`/`FString`/`FVector` scripts.

## Decision

Add task 1.0 as the new root. The post-bind oracle is `Angelscript.UnitTest.Temp`: local `FAngelscriptEngine`, `InitializeWithoutInitialCompile`, then `ASTEST_AS` for `TArray` / `FString` / `FVector` / `Print`, then `GetLastSnapshot()` / `AS_BIND_*`. HostScheme keeps S1 / S4-S6. After inject-only, 2.1 reruns Temp as S2/S3. Old cache suites stay out.

## Impact

The previous "product first, HostScheme compile/call first" verification contract is invalid. 1.1 now depends on 1.0. Spec compile/call scenario names Temp as the oracle.

## Old Task Disposition

| ID | Disposition |
|---|---|
| 1.1-5.1 | Unchecked and preserved. 1.1 edge now `["1.0"]`. 2.1 cases and proving selector now include Temp. |

## Diff Snapshot

- `git status --short` for this Change: `?? openspec/changes/angelscript/refactor-bindings-host-full-inject/` (entire Change still untracked).
- `git diff --stat`: empty because the directory is untracked.
- Task `+` 1.0. Task `~` 1.1 (edge), 2.1 (cases/selector). Edge `+` `1.1 -> 1.0`.
- Artifact `+` finding/talk/knowledge/data/replan. Artifact `~` proposal, design, handoff, glossary, spec delta, INDEX, planning-validation, verification-gates, host-test-style.

## Preserved Work

No completed tasks. Host baseline 30/30 remains characterization, not the new oracle.

## References and Result

Finding `temp-post-bind-oracle.md`. Talk `talk-20260916-161440-temp-post-bind-oracle.md`. Resume at 1.0.
