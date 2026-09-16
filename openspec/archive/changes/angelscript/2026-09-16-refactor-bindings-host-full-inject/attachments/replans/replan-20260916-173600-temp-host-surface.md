---
replan_id: replan-20260916-173600-temp-host-surface
status: applied
source: verification
source_ref: ue.test run f48e15f7933440b3ba49eca09414fb9d; Temp AfterBindTArrayAddThenNum / AfterBindPrintWritesLog / BindLogsRecordBasicTypeProviders
scope: 2.1 Files and host-surface writers for Temp S3
base_commit: acb127e8539638b0a2ff6392b894d976a81b5bdb
base_tasks_sha256: 5972BEB655DFA9372A16BBF2EDB4AC9AFDAE0CD5250566373FDE29104E6D939D
result_tasks_sha256: 62867E761FF865B5F4D4FCBB3FA2AB17E3CBDAF39C3DD9329E56BD8A4B39DF57
created_at: 2026-09-16T17:36:00+08:00
resume_task: "2.1"
---

# Temp S3 needs host TArray and Log writers

## Trigger and Evidence

After 1.2 inject-only, Unreal `f48e15f7933440b3ba49eca09414fb9d` Temp 1/4. `AfterBindFStringLenAndFVectorAdd` passed. `AfterBindTArrayAddThenNum` failed: `TArray<int>` exists but has no default construct. `AfterBindPrintWritesLog` failed: Print/Log missing. `BindLogsRecordBasicTypeProviders` failed: `GetLastSnapshot()` has no `TArray.Declaration` because `BindScriptTypes` no longer calls `ExecuteRegisteredBinds`. Cause: 1.1 host sidecars return before `TArray.MethodSurface` and `Logging.Functions` write.

## Decision

Keep inject-only. Expand 2.1 Files to `Bind_TArray.cpp` and `Bind_Logging.cpp`. Host `MethodSurface` writes construct, destruct, `opIndex`, `Add`, and `Num` then returns. Host `Logging.Functions` writes `Log(const FString&)` then returns. BindLogs asserts those names on `GetProcessHostCollection()` records. Do not restore DirectBinds.

## Impact

2.1 Files and Notes change. Outcome and proving prefixes unchanged. DAG edges unchanged.

## Old Task Disposition

| ID | Disposition |
|---|---|
| 1.0-1.2 | Checked; preserved. |
| 2.1 | Unchecked; Files expanded; resume here. |
| 2.2-5.1 | Unchecked and preserved. |

## Diff Snapshot

- Change directory still untracked. Submodule bind files already dirty from 1.1 sidecars.
- Task `~` 2.1. Edge none.
- Artifact `+` this replan. Artifact `~` INDEX.

## Preserved Work

1.2 HostScheme 7/7 on `648ec44cb7f74692b3a1536077998b60`. Temp FString/FVector call already green on this inject path.

## References and Result

Resume at 2.1 host-surface writes, then Temp + HostScheme prefixes.
