---
replan_id: replan-20260916-165201-bound-engine-call-path
status: applied
source: implementation
source_ref: AngelscriptEngine.cpp:7607 CompileModule_Types_Stage1; NativeEngine.Compile.SDK HasModules/HasCompile; task 1.0 apply
scope: 1.0 verification contract and 2.1 compile interfaces
base_commit: acb127e8539638b0a2ff6392b894d976a81b5bdb
base_tasks_sha256: 1285819445CB9AA805D1AA59686DE6641A67C1119E81597A029A1570896215E9
result_tasks_sha256: 535BFD0B6B1BF84EE1D9333C4A8D7649A550B3C3732AB68AFCD92DE66D626343
created_at: 2026-09-16T16:52:01+08:00
resume_task: "1.0"
---

# Bound-engine proof is Prepare/Execute, not AddScriptSection

## Trigger and Evidence

Apply of 1.0 found the card unprovable. `CompileModule_Types_Stage1` always fails with "Legacy module compilation is unavailable". `asIScriptEngine::GetModule` and `asIScriptModule::AddScriptSection`/`Build` are absent (`NativeEngine.Compile.SDK`). Default `FAngelscriptEngine` always owns a cache service object, so `GetCacheService()` cannot stay null.

## Decision

1.0 keeps the Temp prefix and the same numeric oracles. It Prepare/Executes bound `TArray` / `FString` / `FVector` / `Print` and reads bind logs. Cache exclusion is `IsCacheV2Enabled() == false`. 2.1 compile uses `asCBuilder` plus `asCEngineCompileRegistration` after inject. Do not restore `AddScriptSection`.

## Impact

Task 1.0 title, Outcome, Interfaces, and Cases changed. 2.1 / 4.1 / 4.2 consume `asCBuilder` instead of `AddScriptSection`. Spec compile/call verification note updated. DAG edges unchanged.

## Old Task Disposition

| ID | Disposition |
|---|---|
| 1.0 | Unchecked; same Ready root; cases renamed in contract only (same method names). |
| 1.1-5.1 | Unchecked and preserved. 2.1/4.1/4.2 Interfaces updated. |

## Diff Snapshot

- `git status --short` for this Change: `?? openspec/changes/angelscript/refactor-bindings-host-full-inject/`
- `git diff --stat`: empty because the directory is untracked.
- Task `~` 1.0 (oracle), 2.1 / 4.1 / 4.2 (compile interfaces). Edge `+/-` none.
- Artifact `+` finding/talk/knowledge/replan. Artifact `~` proposal, design, handoff, glossary, spec delta, INDEX, planning-validation, temp oracle finding/knowledge.

## Preserved Work

No completed tasks. Host baseline 30/30 remains characterization. User Temp directory and prefix stay.

## References and Result

Finding `legacy-module-compile-unavailable.md`. Talk `talk-20260916-165201-bound-engine-call-path.md`. Resume at 1.0.
