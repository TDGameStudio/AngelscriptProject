# Scheme and performance verification gates (Q78=A)

2026-09-16. Completion conditions for `host-bind-completion`. Family migration (Q71) is tracked separately.

Test style follows [host-test-style.md](host-test-style.md): one method, one gate; prefer `ASTEST_AS` when an `.as` can prove it.

Identity prefixes: `Angelscript.UnitTest.Bindings.HostScheme.` and `Angelscript.UnitTest.Bindings.HostPerf.` (settled in the selected glossary).

## Scheme gates (hard; failure blocks completed)

| ID | Must observe | Failure |
|---|---|---|
| S1 | After successful `BindScriptTypes`: host graph injected; this pass did not call `ExecuteRegisteredBinds`; `GetBindingInstallation()` is empty | Still replays, still has Installation, or capture failure only logs Verbose |
| S2 | Temp `BasicTypes` compiles an `.as` using `FString` / `FVector` / `TArray<int>` on an engine that just ran `BindScriptTypes`; those names are not registered again | Compile fails, or those host names are registered again during the compile |
| S3 | The same Temp scripts Prepare/Execute `Len` / `opAdd` / `Add` / `Print` with the stated results, and bind logs or `GetLastSnapshot()` record the admitted providers | TypeInfo exists but nothing runs, or there are no `AS_BIND_*` / snapshot records |
| S4 | Two Engines inject the same freeze: `FString`/`FVector` pointers match, process typeId/functionId match, `GetEngine()` stays null | Different pointers, reissued IDs, or host written onto an Engine |
| S5 | After freeze, `ExistingClass("FString").Method(...)` fails and the frozen member count is unchanged | Freeze mutates, or the failure diagnostic is empty |
| S6 | Any production callback failure in the seven phases: no freeze, `BindScriptTypes` fails, a healthy freeze is not replaced by a partial graph | A partial graph is visible, or the old freeze is destroyed |

S2/S3 use independent `TEST_METHOD`s plus small scripts. Do not pack them with S1/S4 in one method.

## Perf gates (hard invariants plus required records; no "must be faster")

| ID | Must observe | Failure | Not a gate |
|---|---|---|---|
| P1 | One seven-phase `ExecuteToHost` records wall-clock, callback count, and source/binary identity | No reproducible record, or a failed callback is stored as a success sample | Must be shorter than current DirectBinds |
| P2 | First `InjectDefinitions` succeeds; second is `AlreadyRegistered` or equivalent; callback count does not increase | Second engine reruns registration | Second wall-clock must be a factor of the first (too noisy) |
| P3 | After destroying one engine: freeze remains; the other still performs an S3-class call | Shared graph is taken away, or the surviving engine cannot call | Exact bytes with 100% coverage |
| P4 | After inject, fixed iterations of `Len`/`opAdd` record median/p95 and a checksum | Semantically failed samples written as success | Median must beat Legacy microbenchmarks |

P1-P4 numbers go in `attachments/data/` and one INDEX row. A perf node cannot complete without that numeric attachment.

## Explicitly not gates

- Old `RuntimeBindings.*` green as-is
- Legacy `Angelscript.TestModule.Performance.*` used as a green gate without adaptation
- `as.Bind.WriteWorkers` N=4 must speed up
- Insights / full allocation traces
- Unconditional Quick / Integration / full UE suite

## Relation to the Change

Per Q72=B these gates live in the same Change, after product inject. Q77 authorized creating `angelscript/refactor-bindings-host-full-inject`.
