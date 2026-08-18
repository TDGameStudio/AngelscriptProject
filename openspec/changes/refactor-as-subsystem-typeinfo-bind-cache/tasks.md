# Subsystem TypeInfo Bind Cache Implementation Plan

> **For agentic workers:** Use superpowers:subagent-driven-development or executing-plans. REQUIRED: `<!-- TDD -->` tasks write the failing test first (CQTest, `Angelscript` prefix). Verify only with `Tools\RunBuild.ps1` and `Tools\RunTests.ps1` / `Tools\RunTestSuite.ps1`. Dual-repo: C++ in `Plugins/Angelscript` first, then parent gitlink.

**Goal:** Extra engines register recorded types from `UAngelscriptSubsystem`'s `TArray<FAngelscriptTypeBindInfo>` without replaying those providers. Primary bind stays `ExecuteRegisteredBinds` until an allowlist of types is proven.

**Architecture:** `FAngelscriptBind` discovers `void (*)(FAngelscriptBinds&)`. Recording `FAngelscriptBinds` writes TypeBindInfo. Apply is per-type, sequential, and also rebuilds TypeDB / ToString / ClassFunctionBindings — not only `Register*`. Unmigrated lambdas keep replaying. Parallel expand is last. Concurrent `asIScriptEngine::RegisterObjectType` is follow-on.

**Spec:** `openspec/changes/refactor-as-subsystem-typeinfo-bind-cache/specs/` and `design.md` (including Decision 3a v1 bootstrap).

## Global Constraints

- OpenSpec artifacts stay English.
- Do not implement `refactor-as-primary-engine-typed-ast-generate` here.
- Do not store `asITypeInfo*` / `asIScriptFunction*` on `FAngelscriptTypeBindInfo`.
- Do not put the array on `UAngelscriptGameInstanceSubsystem`.
- Do not add a second CRT callback type `void (*)(FAngelscriptTypeBindInfoStore&)`.
- `as.BindFromTypeBindInfo` defaults to **0**. Never Apply a whole engine from a partial store.
- Tests: CQTest like `AngelscriptEngineSubsystemTests.cpp`, prefix `Angelscript.TestModule.Engine.*`, files under `AngelscriptTest/Core/`.

## File map

| Path | Responsibility |
|---|---|
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo.h/.cpp` | Row, member, `EApplySlot`, conditions, callable identity, native/adapter recipes |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoStore.h/.cpp` | Array + name index + seal state + `FindOrAdd` / `MergeShard` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoRecorder.cpp` | Recording `FAngelscriptBinds` backend; later shard merge |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.cpp` | Sequential `Register*` + side channels by `EApplySlot` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSubsystem.h/.cpp` | Own the store |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.h/.cpp` | Recording vs live target; `FAngelscriptBoundFunction` member handle |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` | `BindScriptTypes`: replay always while flag is 0; per-type Apply when allowlisted |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector.cpp` | First real migration: TypeFinder/adapter recipes + optional one Register function |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray.cpp` | Second real migration: template row + DefaultArrayType + finder recipe |
| `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptTypeBindInfoTests.cpp` | Store / row unit tests |
| `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptTypeBindInfoRecorderTests.cpp` | Recording probe, no `FAngelscriptEngine::Create` |
| `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptTypeBindInfoApplyTests.cpp` | Isolated apply of hand-built then recorded rows |

Do **not** migrate the rest of `Bind_*.cpp` until slices 5–6 are green.

---

## 1. TypeInfo data model (no engine bind behavior change)

- [ ] 1.1 <!-- TDD --> Add `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptTypeBindInfoTests.cpp` using CQTest `TEST_CLASS_WITH_FLAGS` (same pattern as `AngelscriptEngineSubsystemTests.cpp`) with prefix `Angelscript.TestModule.Engine.TypeBindInfo`. Test `ValueRowHoldsNameAndKind`: construct `FAngelscriptTypeBindInfo` with name `FVector` and kind `Value`. Run: `Tools\RunTests.ps1 -TestPrefix Angelscript.TestModule.Engine.TypeBindInfo -TimeoutMs 600000`. Expected: FAIL (type missing), not a permanently uncompilable tree.

- [ ] 1.2 <!-- TDD --> Create `AngelscriptTypeBindInfo.h/.cpp`. Define `EAngelscriptTypeBindKind`, `EApplySlot { Type, Infrastructure, Members }`, `FAngelscriptBindCondition`, `FAngelscriptTypeBindInfoMember` (declaration, callable identity, native recipe, ApplySlot), `FAngelscriptTypeBindInfo` with `AngelscriptTypeName`, `Kind`, `Condition`, adapter recipe, `TArray` members, `DeclarationOrder`. No AS pointer fields. Wire `.cpp` into `AngelscriptRuntime.Build.cs` if sources are not globbed.

- [ ] 1.3 <!-- TDD --> Assert a row can hold a method declaration string and `EditorScripts=Required`; assert no member type is `asITypeInfo*`. Run TypeInfo prefix. Expected: PASS.

- [ ] 1.4 <!-- TDD --> Create `AngelscriptTypeBindInfoStore.h/.cpp` with `TypeBindInfos`, `TypeBindInfoIndexByName`, `EAngelscriptTypeBindStoreState { Empty, Expanding, Sealed, Failed }`, `FindOrAdd(Name)`, `MergeShard`, `FindByName`. Test: two `FindOrAdd(FVector)` return the same index; merging two shards with kind conflict sets Failed and writes a diagnostic. Run TypeInfo prefix. Expected: PASS.

- [ ] 1.5 <!-- Non-TDD --> `Tools\RunBuild.ps1 -Label typeinfo-model -TimeoutMs 1800000`. Expected: Runtime+Test compile.

## 2. Subsystem ownership

- [ ] 2.1 <!-- TDD --> Extend `AngelscriptEngineSubsystemTests.cpp` (`Angelscript.TestModule.Engine.EngineSubsystem`) with `SubsystemOwnsNativeTypeInfoArray`: after a test initialize path that seals an empty store, `GetTypeBindInfoStore()` is non-null and not a `UPROPERTY`. Run: `Tools\RunTests.ps1 -TestPrefix Angelscript.TestModule.Engine.EngineSubsystem -TimeoutMs 600000`. Expected: FAIL until the member exists.

- [ ] 2.2 <!-- TDD --> Modify `AngelscriptSubsystem.h/.cpp`: native `FAngelscriptTypeBindInfoStore TypeBindInfoStore` (not `UPROPERTY`). Accessor `GetTypeBindInfoStore()`. GameInstance subsystem unchanged. Run EngineSubsystem prefix. Expected: PASS.

- [ ] 2.3 <!-- TDD --> Test `GameInstanceSubsystemDoesNotOwnTypeInfoArray`: compile-time absence of `TypeBindInfoStore` on `UAngelscriptGameInstanceSubsystem`. Keep EngineSubsystem prefix green.

## 3. Recording probe (callback ABI unchanged)

- [ ] 3.1 <!-- TDD --> Add `AngelscriptTypeBindInfoRecorderTests.cpp` prefix `Angelscript.TestModule.Engine.TypeBindInfo.Recorder`. Test `RecordsMethodWithoutRegisterObjectMethod`: local `FAngelscriptBindCollection` with one `void (*)(FAngelscriptBinds&)` that records `ValueClass` + `Method("void Ping()")` on a **recording** `FAngelscriptBinds` (no `FAngelscriptEngine::Create`) produces row `FRecorderProbe` with ApplySlot Type then Members. Run recorder prefix. Expected: FAIL.

- [ ] 3.2 <!-- TDD --> Implement recording mode: `FAngelscriptBinds` writes the store; `GetRecordingStore()` returns it. `GetTypeInfo()` during record does not return `asITypeInfo*`. Add `FAngelscriptBind(Name, RegisterKind, FAngelscriptBindCallback)` — same callback type as today, no `FAngelscriptTypeBindInfoProvider`, no `Store&` CRT callback.

- [ ] 3.3 <!-- TDD --> Recording `FAngelscriptBoundFunction` / `FAngelscriptBoundProperty` hold a **member index**, not `FunctionId`. Test `PassScriptObjectTypeRecordsOnMember`: `.PassScriptObjectTypeAsFirstParam()` on a recorded method sets `FirstParamMeta` on the member while `IsValid()`-style live function lookup is false. Run recorder prefix. Expected: FAIL then PASS.

- [ ] 3.4 <!-- TDD --> Unimplemented bind APIs mark that **provider** `ReplayOnly` or fail the seal with the bind name — never drop. Test a probe that calls an unrecorded API becomes ReplayOnly. Run recorder prefix.

- [ ] 3.5 <!-- TDD --> `HasMethodReadsInProgressTypeInfo`: first callback records a method; second callback sees `HasMethod` true via the store. Run recorder prefix. Expected: PASS.

- [ ] 3.6 <!-- Non-TDD --> `as.BindFromTypeBindInfo=0` default. Primary `BindScriptTypes` still `ExecuteRegisteredBinds` only. Optional diagnostic fill of the store must not change bind behavior. `Tools\RunBuild.ps1 -Label typeinfo-recorder -TimeoutMs 1800000`. Then `Tools\RunTests.ps1 -TestPrefix Angelscript.TestModule.Engine.BindingArchitecture -TimeoutMs 600000` and `Tools\RunTests.ps1 -TestPrefix Angelscript.TestModule.Engine.Binds -TimeoutMs 600000`. Expected: PASS.

## 4. Conditions and surface passes

- [ ] 4.1 <!-- TDD --> Member with `.EditorOnly()` stores `EditorOnlyTrait` / `EditorScripts=Required`. `MemberVisibleOn(EngineSurface)` is false when `ShouldUseEditorScripts()==false`. Run recorder prefix.

- [ ] 4.2 <!-- TDD --> `CompileOutInTest` stores policy, not a pre-baked Shipping mutation. Expand with `bSimulateCooked=false`, then filter as simulate-cooked still requests compile-out. Run recorder prefix.

- [ ] 4.3 <!-- TDD --> `UnexpandedSurfaceRefusesGuess`: store sealed only for `EditorDevelopment`; apply request for `GameShipping` returns failure or ReplayOnly, not Editor rows. Run recorder prefix.

- [ ] 4.4 <!-- Non-TDD --> Keep lazy second-surface expand (design default). Note the choice in `attachments/recording-model.md` when code lands.

## 5. Sequential apply of a hand-built row (flag still 0 for production engines)

- [ ] 5.1 <!-- TDD --> Add `AngelscriptTypeBindInfoApplyTests.cpp` prefix `Angelscript.TestModule.Engine.TypeBindInfo.Apply`. Use `CreateScriptScanFreeEngineForTesting`. Seal a store with one hand-built probe TypeInfo and apply; `asIScriptEngine` has that type and method. Run apply prefix. Expected: FAIL.

- [ ] 5.2 <!-- TDD --> Implement `AngelscriptTypeBindInfoApply.cpp`: sequential `Register*` by `DeclarationOrder` then `ApplySlot` then `MemberOrder`; recreate engine-local adapters from **factories**; attach recorded BoundFunction flags after `RegisterObjectMethod`. Do **not** yet wire production `BindScriptTypes` to skip `ExecuteRegisteredBinds`.

- [ ] 5.3 <!-- TDD --> Apply also registers ToString (`FToStringHelper` / target to-string list) and `RegisterTypeFinder` from recipes on that hand-built row. Run apply prefix.

- [ ] 5.4 <!-- TDD --> `ReplayOnly` providers still run `ExecuteRegisteredBinds` on that engine. Test a marked ReplayOnly probe still increments its counter. Run apply prefix.

## 6. First real type: `FVector` recipes, extra-engine allowlist only

- [ ] 6.1 <!-- TDD --> Rewrite `Bind_FVector` TypeFinder so it does not capture `TSharedRef<FVectorType>` or that engine's TypeDB. Record `Adapter<FVectorType>()` factory + finder recipe. Test: apply `FVector` onto engine B after recording without engine A's TypeDB. Run apply prefix.

- [ ] 6.2 <!-- TDD --> Extra engine with an explicit allowlist `{ FVector }` Applies `FVector` from TypeBindInfo and does **not** invoke `Bind_FVector` callbacks; all other providers still `ExecuteRegisteredBinds`. Test `SecondEngineDoesNotInvokeRecordedFVectorProvider`. Run apply prefix.

- [ ] 6.3 <!-- Non-TDD --> `Tools\RunTests.ps1 -TestPrefix Angelscript.TestModule.Engine.Isolation -TimeoutMs 600000`. Expected: PASS. Then BindingArchitecture prefix. Expected: PASS.

## 7. Second real type: `TArray` template family

- [ ] 7.1 <!-- TDD --> Record `TArray` / iterators: Template callback, DefaultArrayType, `ArrayTemplateTypeInfo` on Apply, TypeFinder recipe (`FArrayProperty` → Inner via **apply-time** TypeDB). Do not store `TArray<FVector>` rows. Run apply prefix.

- [ ] 7.2 <!-- TDD --> `.PassScriptObjectTypeAsFirstParam` and `.NativeTemplateInstantiatedCall` survive Apply onto the new `asIScriptFunction`. Run apply prefix and, when native forms are involved, the NativeForms-focused StaticJIT prefix from bind-reviewability notes — not a full `Angelscript.TestModule.StaticJIT` until flag-on.

- [ ] 7.3 <!-- TDD --> Extra-engine allowlist `{ FVector, TArray, TArrayIterator, TArrayConstIterator }`. Other providers replay. Isolation + BindingArchitecture prefixes. Expected: PASS.

## 8. Grow apply coverage (still not whole-engine)

- [ ] 8.1 <!-- Non-TDD --> Inventory `FAngelscriptBinds` APIs vs recorder coverage in `attachments/recorder-api-coverage.md`. Uncovered production providers stay ReplayOnly.

- [ ] 8.2 <!-- TDD --> Record `RegisterFunctionBindingForTarget` into TypeBindInfo (or a sibling process table keyed by type); Apply fills that engine's `ClassFunctionBindings`.

- [ ] 8.3 <!-- TDD --> `Finalization` probes such as `DirectBindArchitectureProbe` remain ReplayOnly so Isolation counters stay stable.

- [ ] 8.4 <!-- Non-TDD --> Do **not** migrate remaining `Bind_*.cpp` in this slice. Optional: one more POD file only if 6–7 stayed green.

## 9. Parallel expand allowlist (after sequential extra-engine apply works)

- [ ] 9.1 <!-- Non-TDD --> Audit Explicit fills. Write `attachments/parallel-expand-allowlist.md` (`Bind_FVector`, `Bind_FColor`, other UObject-free helpers). Unknown default: Game Thread.

- [ ] 9.2 <!-- TDD --> `ParallelExpandMatchesSequential` for one allowlisted provider. Run recorder prefix. Expected: FAIL until shard merge exists.

- [ ] 9.3 <!-- TDD --> Worker shards + `MergeShard` in the recorder. BlueprintType / UStruct / UEnum / BlueprintCallable never scheduled on workers.

- [ ] 9.4 <!-- Non-TDD --> TypeInfo + Isolation + BindingArchitecture prefixes. Expected: PASS.

## 10. Observation

- [ ] 10.1 <!-- TDD --> Distinct expand vs apply observation (`as-bind-execution-timing`) under `WITH_DEV_AUTOMATION_TESTS`. Expand keyed by provider; apply keyed by type name. ReplayOnly still in provider-replay observation.

## 11. Production flag (only after allowlist covers a full surface)

- [ ] 11.1 <!-- Non-TDD --> Enable `as.BindFromTypeBindInfo=1` for extra engines of a **fully recorded** surface first, then consider primary. Default remains 0 until this task. `Tools\RunTests.ps1 -TestPrefix Angelscript.TestModule.Engine.EngineSubsystem -TimeoutMs 600000`. Expected: PASS.

- [ ] 11.2 <!-- Non-TDD --> `Tools\RunTests.ps1 -TestPrefix Angelscript.TestModule.Bindings -TimeoutMs 900000`. Expected: PASS with zero failures.

## 12. Close-out verification

- [ ] 12.1 <!-- Non-TDD --> `Tools\RunBuild.ps1 -Label typeinfo-bind-cache-final -TimeoutMs 1800000`. Expected: exit 0.

- [ ] 12.2 <!-- Non-TDD --> `Tools\RunTests.ps1 -TestPrefix Angelscript.TestModule.Engine.TypeBindInfo -TimeoutMs 600000`. Expected: PASS.

- [ ] 12.3 <!-- Non-TDD --> Isolation, BindingArchitecture, EngineSubsystem, Bindings prefixes (same timeouts as 6.3 / 11.1 / 11.2). Expected: PASS.

- [ ] 12.4 <!-- Non-TDD --> `openspec validate refactor-as-subsystem-typeinfo-bind-cache --strict`. Expected: PASS.

- [ ] 12.5 <!-- Non-TDD --> Do **not** implement threaded `asCScriptEngine::Register*` here. Follow-on: `attachments/as-engine-threaded-registration-follow-on.md` and `feature-as-multithreaded-type-registration`.
