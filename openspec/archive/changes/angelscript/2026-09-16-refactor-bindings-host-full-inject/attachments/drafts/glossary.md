# Vocabulary — host-bind-completion

Keep the predecessor terms: `HostProcess`, `InjectDefinitions`, `asCDefinitions`, `FAngelscriptBindCollection`, `ExecuteToHost`, `as.Bind.WriteWorkers`. This Change adds no new public C++ types.

| Term | Chosen | Rejected | Why |
|---|---|---|---|
| Change ID | `angelscript/refactor-bindings-host-full-inject` | `complete-host-production` / `editor-host-inject` | Q76=A |
| Scheme prefix | `Angelscript.UnitTest.Bindings.HostScheme` | keep `RuntimeBindings.*` as the green gate | Sibling of existing `Bindings.Host*` |
| Perf prefix | `Angelscript.UnitTest.Bindings.HostPerf` | unadapted `Angelscript.TestModule.Performance.*` | Legacy microbenchmarks are not this Change's green gate |
| Production capture | every registered `FAngelscriptBind` record | `IsProcessHostEligibleRecord` eight-name whitelist | Q73/Q74 |
| Editor entry | `BindScriptTypes` only `EnsureProcessHostCollection` + `InjectDefinitions` | replay via `ExecuteRegisteredBinds` after a successful capture | Q73=A |
| No-arg factory | `CreateForBindings()` uses the same freeze | Recorder to Store to Apply | Q71/Q75 |
| Post-bind oracle | `Angelscript.UnitTest.Temp` under `AngelscriptTest/Temp` | HostScheme-only compile/call; Host* pointer calls; `AddScriptSection` | User 2026-09-16: Temp + TArray/basic types + bind logs. 1.0 is Prepare/Execute; 2.1 is `asCBuilder` after inject. |

CQTest classes `HostScheme` and `HostPerf` follow the inspected `TEST_CLASS_WITH_FLAGS(<Class>, "Angelscript.UnitTest.Bindings", ...)` convention, producing `Angelscript.UnitTest.Bindings.HostScheme` and `Angelscript.UnitTest.Bindings.HostPerf`.

CQTest class `BasicTypes` uses `TEST_CLASS_WITH_FLAGS(BasicTypes, "Angelscript.UnitTest.Temp", ...)` in `Plugins/Angelscript/Source/AngelscriptTest/Temp/PostBindBasicTypesTests.cpp`, producing `Angelscript.UnitTest.Temp.BasicTypes`. The directory name is the user's.
