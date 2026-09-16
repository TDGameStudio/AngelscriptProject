---
replan_id: replan-20260916-165900-replay-delegate-failure
status: applied
source: verification
source_ref: ue.test run 033e558a4c2c4c3cb00adae504e975f9; AngelscriptEngine BindScriptTypes ExecuteRegisteredBinds
scope: 1.0 GREEN set after replay BindScriptTypes failure
base_commit: acb127e8539638b0a2ff6392b894d976a81b5bdb
base_tasks_sha256: 535BFD0B6B1BF84EE1D9333C4A8D7649A550B3C3732AB68AFCD92DE66D626343
result_tasks_sha256: 0B6711EBBA80B51EF395C4CB8E792EAB1727F469C71C26DB5DF0818502D9BA41
created_at: 2026-09-16T16:59:00+08:00
resume_task: "1.0"
---

# Replay BindScriptTypes fails before Temp calls

## Trigger and Evidence

After bind preparation, `FAngelscriptEngine::Create` with `bSkipInitialCompile` returned null. Unreal.log: `RegisterObjectBehaviour` `FInOutWeakPtrDelegate` `void f(const FInOutWeakPtrDelegate& Other)` result `-10` (`asINVALID_DECLARATION`), owner `Delegates.Declarations`, `Bind_Delegates.cpp:701`. All four AfterBind cases failed because no engine was published. Run `033e558a4c2c4c3cb00adae504e975f9`.

## Decision

1.0 GREEN is the characterization case `ReplayBindScriptTypesFailsOnDelegateDeclaration`. AfterBind TArray/FString/Print and bind-log cases stay written as `deferred RED until 2.1`. 1.0 does not edit bind files. 1.1 still captures every record onto host; host registration may not hit the same live `RegisterObjectBehaviour` failure.

## Impact

1.0 Outcome, Cases, and Verification selector changed. DAG edges unchanged. 2.1 must cite the four deferred cases turning green after inject-only.

## Old Task Disposition

| ID | Disposition |
|---|---|
| 1.0 | Unchecked; GREEN narrowed; AfterBind* deferred to 2.1. |
| 1.1-5.1 | Unchecked and preserved. |

## Diff Snapshot

- Change directory still untracked.
- Task `~` 1.0. Edge none.
- Artifact `+` this replan. Artifact `~` INDEX.

## Preserved Work

Temp test file and PrepareForEngineInitialization fixture stay. Host baseline 30/30 unchanged.

## References and Result

Resume at 1.0 characterization case, then 1.1.
