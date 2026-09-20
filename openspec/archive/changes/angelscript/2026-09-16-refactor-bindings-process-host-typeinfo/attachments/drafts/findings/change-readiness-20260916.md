# Creation readiness and current source evidence

English export of the 2026-09-16 readiness finding, updated with actual Q65-Q68 acceptance. This evidence concerns the observed working tree, not a clean immutable commit or a product test run.

## Position and provenance

The primary selected workspace was AngelscriptProject on main. Parent HEAD: acb127e8539638b0a2ff6392b894d976a81b5bdb. Plugin HEAD: b3c80c5fffe292faa15b6f78ef2c1226daaaedd4. Many unrelated modifications already existed. The predecessor had 24 unchecked tasks and the replacement did not exist at the start.

Q40/Q41 had already selected a replacement and superseded archive; Q42 had explicitly withheld overall approval. Q65 now includes live Register reconstruction, Q66 accepts the full naming table, Q67 approves this design and planning-only creation/archive, and Q68 approves two talks and two knowledge candidates. Earlier README guidance to update the old Change is superseded.

## Inspected implementation

Paths below are beneath Plugins/Angelscript/Source/AngelscriptRuntime unless the test root is given.

| Source | Observation | Required consequence |
|---|---|---|
| angelscript/as_context.cpp:665 | Prepare rejects a Function from a different Engine | Add exact HostProcess admission, not a blanket null bypass |
| angelscript/as_scriptengine_metadata.cpp:93,230,234,237,296 | Unique registration checks owner, writes engine, moves Set and clears IDs on retirement | Separate shared injection and shared detachment from private transfer/retirement |
| angelscript/as_typeinfo.cpp:263,282 | IDs and Engine may come from the definition owner | Shared type/function IDs must be fixed before injection; no bound Engine fallback for host |
| angelscript/as_bytecode_linker.cpp:1053 | AcquireSystemInterface ends after local publication/nativeInterfaces | Add admitted process-interface fallback with lifetime retention |
| angelscript/as_scriptfunction.cpp:174,191,197 | Delegate construction dereferences Function.GetEngine | Audit reachable shared-host use and source execution owner explicitly |
| angelscript/as_scriptengine.cpp:1779,2044,2696,2857 | RegisterObjectType/Behaviour/Method/GlobalFunction return asNOT_SUPPORTED | Q65 requires real positive reconstruction, not only rejection tests |
| Core/AngelscriptEngine.cpp:3271 | BindScriptTypes uses DirectBinds and ExecuteRegisteredBinds | Q64 owns the production entry migration |
| Core/AngelscriptTypeBindInfoDraft.cpp:403; Apply.cpp:2006,2038 | Late creation uses Set options after paths that TakeSet | Matches the historical late-set concern; no crash reproduced in this delivery |
| Binds/Bind_BlueprintType.cpp:154,1586,1693,1696 | Prepare can parallelize; commit is serial and FuncMap is prewarmed | New writes need class ownership and explicit barriers |
| AngelscriptTest/Bindings/RuntimeBindingIsolationTests.cpp:90,204 | Two existing test families cover ownership and binding reuse | Adapt both families; retain owner/adapter/auxiliary controls |

## Current contracts and engineering obligations

Definitions, type-registry, binding-engine and VM specs explicitly describe distinct TypeInfo pointers per Engine. The new deltas must change those requirements together. Builder and bytecode also name the old definition APIs; script unique ownership remains intact.

The accepted design includes graph retention after producer release, injection rollback, uninjected-engine rejection, process type/function IDs, Engine-local native overrides, mixed script/host closure, phase barriers, class write ownership and actual production routing. Additional reachability investigation remains implementation work, not another user-owned product decision.

## Predecessor disposition

Replace descriptor preparation and per-Engine host materialization. Carry production registration, actual template calls, external extension behavior and necessary adapter/native/lifetime repairs. Defer full directory reorganization, manifest v2 and the complete performance/memory program. Never equate superseded closure with completion.

## Validation boundary

No Unreal build, Automation or benchmark was run during readiness assessment. Historical Isolation success, four Calls.Native failures and Array AV are provenance only. New planning validates exact record structure, task syntax, link closure and attachment indexing. Product outcomes remain unproved until the tasks execute.

## Carryover

Q68 accepted host ownership and Blueprint write-boundary talks, plus execution-ownership and Blueprint-write knowledge candidates. The complete transcript and discarded descriptor alternatives stay local.
