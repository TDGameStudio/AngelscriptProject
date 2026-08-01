# Architecture Debt Registry

Source reports: `Documents/Reports/` (13 substantive reports dated 2026-05-11 → 2026-06-03).
All findings re-verified against plugin source on **2026-07-31**.

Paths are relative to `Plugins/Angelscript/Source/` unless noted.

Verdict legend:

| Verdict | Meaning |
| --- | --- |
| STILL TRUE | Present as described, evidence re-confirmed |
| REGRESSED | Present and measurably worse than when reported |
| PARTLY FIXED | Materially improved, residual risk remains |
| FIXED | No longer present — do not re-open |
| NOT FOUND | Identifier//construct no longer exists in the tree |

---

## A. Hot-reload and compilation thread-safety

No active OpenSpec change covers this cluster. Highest-value follow-up candidate.

| ID | Finding | Current evidence | Verdict | Coverage |
| --- | --- | --- | --- | --- |
| A1 | `GAmbientWorldContext` is a raw `UObject*` shared across hot-reload and main thread. Write goes through a `volatile` cast; the read in `GetAmbientWorldContext()` is unguarded. `volatile` is weaker than `TAtomic<>` and provides no atomicity. | `AngelscriptRuntime/Core/AngelscriptEngine.cpp:249` (decl), `:418` (volatile-cast write), `:443` (unguarded read) | STILL TRUE | NOT COVERED |
| A2 | `bWaitingForHotReloadResults` declared `volatile bool` rather than `TAtomic<bool>`; read/written from both hot-reload thread and main thread with no lock. | `AngelscriptRuntime/Core/AngelscriptEngine.h:572`; accesses at `.cpp:2168`, `:2171`, `:3370`, `:3408` | STILL TRUE | NOT COVERED |
| A3 | `FileChangesDetectedForReload` (`TArray`) has `Add()` called from the hot-reload thread and `Empty()` from the main thread with no `FCriticalSection`. Concurrent `Add`/`Empty` on `TArray` can reallocate under a reader. | `AngelscriptRuntime/Core/AngelscriptEngine.h:658`; adds at `.cpp:3509`, `:3532`, `:3545`; empties at `:3378`, `:3488` | STILL TRUE | NOT COVERED |
| A4 | `LastFileChangeDetectedTime` is a plain `double` written by the hot-reload thread and read by the main thread; 8-byte assignment is not guaranteed atomic on all targets. | `AngelscriptRuntime/Core/AngelscriptEngine.h:660`; write ~`.cpp:3553`, read `:3382` | STILL TRUE | NOT COVERED |
| A5 | Check-then-set (TOCTOU) on non-atomic `bHotReloadThreadStarted` — two threads can both observe `false` and both spawn a reload thread. | `AngelscriptRuntime/Core/AngelscriptEngine.h:737`; `AngelscriptEngine.cpp:2146-2148` | STILL TRUE | NOT COVERED |
| A6 | **Confirmed data race.** `bHadCompileErrors` is written from inside the `ParallelFor` worker lambda with no atomic or accumulator. Directly inspected: `ParallelFor` at `:3891`, worker writes `Module->bCompileError = true; bHadCompileErrors = true;` at `:3910-3911`. | `AngelscriptRuntime/Core/AngelscriptEngine.cpp:3891`, `:3910-3911` | STILL TRUE | NOT COVERED |
| A7 | Busy-wait `while (!bInitializationDone)` with `FPlatformProcess::Sleep(0.002f)`, no timeout and no failure diagnostic — a failed async init hangs the game thread indefinitely. | `AngelscriptRuntime/Core/AngelscriptEngine.cpp:962-967` | STILL TRUE | NOT COVERED |
| A8 | `GameThreadTLD` global temporarily reassigned to a worker thread's local data during init. Now scoped inside the `AsyncTask()` lambda so cleanup is implicit-RAII, but there is still no explicit guard and no exception safety. | `AngelscriptRuntime/Core/AngelscriptEngine.cpp:950-957`, lambda at `:947` | PARTLY FIXED | NOT COVERED |
| A9 | `deferValidationOfTemplateTypes` / `deferCalculatingTemplateSize` set at compile entry and restored later. Restoration is now explicit and paired, so the plain leak is gone; an early return or throw between set and restore still leaves the engine inconsistent. | set `:3758-3759`; restored `:4428`, `:4572` | PARTLY FIXED | NOT COVERED |

## B. God objects and oversized units

Partly covered: ClassGenerator and ASClass decomposition landed. The engine/bytecode/preprocessor core did not.

| ID | Finding | Current evidence | Verdict | Coverage |
| --- | --- | --- | --- | --- |
| B1 | `CompileModules()` is a single **1,247-line** function acting as an untyped compile transaction — ~20 stages, no transaction object, stage-ordering dependencies documented only in comments, no rollback if a mid-stage fails after types were removed from engine availability. | `AngelscriptRuntime/Core/AngelscriptEngine.cpp` (`CompileModules`, 1,247 lines) | STILL TRUE | NOT COVERED |
| B2 | `AngelscriptEngine.cpp` remains 6,639 lines / 206 KB, combining lifecycle, compilation, module management, context stack, JIT/debug/coverage coordination. Grew slightly from the reported ~197 KB. | `AngelscriptRuntime/Core/AngelscriptEngine.cpp` | STILL TRUE | NOT COVERED |
| B3 | `AngelscriptBytecodes.cpp` 6,747 lines / 204 KB of bytecode pattern matching, unsupported paths via `check(false)` rather than collectable diagnostics. | `AngelscriptRuntime/StaticJIT/AngelscriptBytecodes.cpp` | STILL TRUE | NOT COVERED |
| B4 | `AngelscriptPreprocessor.cpp` 4,769 lines / 139 KB. | `AngelscriptRuntime/.../AngelscriptPreprocessor.cpp` | STILL TRUE | Partially — `refactor-as-language-core-ue-facade-parity` (record-only, 0 tasks) |
| B5 | `AngelscriptStaticJIT.cpp` 3,970 lines / 121 KB; `GenerateCppCode()` aggregates pre-pass, stack-offset inference, cleanup labels, emission. | `AngelscriptRuntime/StaticJIT/AngelscriptStaticJIT.cpp` | STILL TRUE | NOT COVERED |
| B6 | `AngelscriptDebugServer.cpp` 3,328 lines / 99 KB — DAP envelope parsing, sockets, breakpoints, variable inspection, callstack, dispatch in one unit. | `AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp` | STILL TRUE | NOT COVERED |
| B7 | `AngelscriptEditorCodeGen.cpp` is 2,812 lines with **no header file** — an implementation-only module with no declared interface. `GenerateFunctionEntries()` is 600+ lines. Dead/commented code **rose 588 → 593 lines** (~21%), including `GenerateFunctionEntriesOld()`, `GenerateFunctionEntriesOld2()`, `MultiApproach()`. | `AngelscriptEditor/CodeGen/AngelscriptEditorCodeGen.cpp` (no sibling `.h`; confirmed by directory listing) | REGRESSED | NOT COVERED |
| B8 | `PerformReinstance()` is 367 lines spanning nine responsibilities (symbol replacement, BP analysis, pin mutation, struct dependency replacement, GC, reinstancing, BP recompile, editor UI refresh, actor factory). Iterates only loaded `UBlueprint` via `TObjectIterator`, so unloaded assets are missed; replaces `DataTable->RowStruct` with no layout-compatibility validation; retains a `WILL-EDIT-Temp` block. | `AngelscriptEditor/.../ClassReloadHelper.cpp` (`PerformReinstance`, 367 lines) | STILL TRUE | NOT COVERED |
| B9 | `AngelscriptClassGenerator.cpp` ~208 KB monolith — **decomposed** into coordinator (660 lines) + `_Analyze` (1,990) + `_FullReload` (1,017) + `_SoftReload` (818) + `_Finalize` (940) + `_ReloadPlanning` (394) + `_Reinstancing` (253). | `AngelscriptRuntime/ClassGenerator/` | FIXED | archived `refactor-classgenerator-decomposition` |
| B10 | `ASClass.cpp` ~100 KB monolith — now 18 lines, with `ASClass.h` (198) + `ASClass_Construction.cpp` (740) + `ASClass_Metadata.cpp` (149). | `AngelscriptRuntime/Core/ASClass*.{h,cpp}` | FIXED | archived `refactor-asclass-file-layout` |

## C. Dual execution paths that can silently diverge

Two independent implementations of the same call semantics, selectable at runtime. Behavioural drift is invisible unless both are tested as a matrix.

| ID | Finding | Current evidence | Verdict | Coverage |
| --- | --- | --- | --- | --- |
| C1 | `CallBlueprintCallableReflectiveFallback()` has two full implementations of one UFunction call, gated by CVar `as.ReflectiveFallback.UseCache`: cached path (FFrame + `UFunction::Invoke` + `FReflectiveParamCache`, lines 349-547) and legacy path (`TFieldIterator` + `UObject::ProcessEvent`, lines 556-686). | `AngelscriptRuntime/.../BlueprintCallableReflectiveFallback.cpp:112-120` (CVar), `:710-727` (routing) | STILL TRUE | NOT COVERED |
| C2 | Both dispatch helpers return `bool` success and **both returns are discarded**, so a helper failure leaves the script-side return buffer in an undefined state with no diagnostic. | `BlueprintCallableReflectiveFallback.cpp:713`, `:722` | STILL TRUE | NOT COVERED |
| C3 | Out-param writeback bounds check is **asymmetric**: legacy path guards `ParamIndex < BlueprintCallableReflectiveFallbackMaxArgs` at `:632`; the cached path writes `OutScriptAddresses[ParamIndex]` at `:430` with no check. Overflow is prevented only by bind-time validation at `:1008`, so any future bind-path change silently reintroduces stack corruption. | `BlueprintCallableReflectiveFallback.cpp:89` (`= 16`), `:378`, `:430`, `:632`, `:1008` | PARTLY FIXED | NOT COVERED |
| C4 | `AngelscriptCallFromBPVM()` has disjoint JIT path (`:146-334`) and context-fallback path (`:336-443`), each independently marshalling parameters — JIT writes raw memory, context path uses `SetArg*`. A new `VMBehavior` or type change can be applied to one path only. | `AngelscriptRuntime/.../ASFunction_CallHelpers.h:120-444` | STILL TRUE | NOT COVERED |
| C5 | JIT `VMArgs` sized by the unchecked empirical formula `FMemory_Alloca(8 * ArgumentCount + 16)`, mixing byte count with `asDWORD*` semantics and assuming ≤2 dwords per argument. Any 3-dword argument type overflows the alloca silently. | `ASFunction_CallHelpers.h:156` | STILL TRUE | NOT COVERED |
| C6 | `ResolveScriptVirtual()` trusts `vfTableIdx` across hot reload. Bounds are asserted with `checkSlow()` only (`:88-89`), so shipping and test builds carry **no** check; if a virtual function table is rebuilt on reload a stale index dispatches the wrong function silently. | `ASFunction_CallHelpers.h:76-93`, verifier `:55-74` (non-shipping only), reload guard `:123-125` | STILL TRUE | NOT COVERED |

## D. Extension and hook surface

UE-side fragmentation was resolved; the remaining gaps are missing extension points, not tangling.

| ID | Finding | Current evidence | Verdict | Coverage |
| --- | --- | --- | --- | --- |
| D1 | Reported 3-layer / 7-registration-point fragmentation is **substantially resolved**: `IAngelscriptExtension` (`OnEngineAttached`/`OnEngineDetached`) behind a thread-safe `FAngelscriptEngineExtensionRegistry`, plus 14 delegates inlined onto `FAngelscriptEngine` with accessors — the inlining removed 133 indirect call sites. Native AS callbacks remain a separate, isolated layer. | `AngelscriptRuntime/Core/AngelscriptEngineExtensionRegistry.{h,cpp}`; `AngelscriptEngine.h:799-820`, rationale `:57-63` | PARTLY FIXED | archived `refactor-as-engine-extension-hooks`, `refactor-as-engine-owned-hooks`, `refactor-as-engine-inline-hook-accessors`, `refactor-as-compilation-event-hook` |
| D2 | Script exceptions have no UE multicast delegate. Handled internally via native `SetExceptionCallback` → log + DebugServer; external modules must scrape logs to react (telemetry, recovery). | `as_context.cpp:5241`; no `FOnAngelscriptException*` delegate on `FAngelscriptEngine` | STILL TRUE | NOT COVERED |
| D3 | No post-`FAngelscriptBinds::CallBinds()` hook. `OnEngineAttached()` fires too early to append bindings; `PostCompile` is too late to affect bind ordering. | `FAngelscriptEngineExtensionRegistry`; no post-bind hook found | STILL TRUE | NOT COVERED |
| D4 | `SetInstructionCallback` is **still** patched into the vendored `as_context.cpp` hot loop — `asSInstructionCallbackScope` constructed per instruction with pre/post notification — despite the instrumentation review recommending removal. Now consumed by 4 native tests. Cost: per-instruction overhead plus fork-maintenance burden on every AS SDK update. | `as_context.cpp:1682` (hot loop), scope `:1646-1678`; consumers `AngelscriptNativeCallbackLifecycleTests.cpp`, `AngelscriptNativeInstructionPhaseDepthTests.cpp`, `AngelscriptNativeCaseSupportTests.cpp`, `AngelscriptNativeDebugTestSupport.h` | STILL TRUE | NOT COVERED |
| D5 | `SetTranslateAppExceptionCallback` declared and implemented in the vendored engine but never registered; fork builds with `AS_NO_EXCEPTIONS` so it returns `asNOT_SUPPORTED`. Dead API surface. | `as_scriptengine.h`, `as_scriptengine.cpp`; expectation asserted in `AngelscriptNativeEngineGcCleanupServiceTests.cpp` | STILL TRUE | NOT COVERED (low value) |
| D6 | AngelScript GC start/completion not surfaced to the UE layer — no memory-monitoring hook. | no GC delegates on `FAngelscriptEngine` | STILL TRUE | NOT COVERED (low value) |

## E. Module boundaries and encapsulation

| ID | Finding | Current evidence | Verdict | Coverage |
| --- | --- | --- | --- | --- |
| E1 | Direct `#include "source/as_*.h"` outside any central entry header **rose 152 → 203**: `Binds/` 72, `ClassGenerator/` 67, `StaticJIT/` 49, `Testing/` 6, `Debugging/` 5, `CodeCoverage/` 3, `FunctionLibraries/` 1. ClassGenerator and StaticJIT were not even flagged in the original report. Every vendored-header change now ripples across 7 directories. | 7 directories under `AngelscriptRuntime/` | REGRESSED | NOT COVERED |
| E2 | `Binds/` holds full `UCLASS` definitions rather than bindings only — `UObjectInWorld.h` (`UCLASS(Blueprintable)` :5, `GENERATED_BODY()` :8, `UPROPERTY` :12, `UFUNCTION` :18/:22/:26) and `UObjectTickable.h` (`UCLASS` :6, `GENERATED_BODY` :9, `UPROPERTY` :13/:16, `UFUNCTION` :22/:26/:36). Directory responsibility is not pure. | `AngelscriptRuntime/Binds/UObjectInWorld.h`, `UObjectTickable.h` | STILL TRUE | NOT COVERED |
| E3 | 147 distinct `AS_*` macros, **33 defined in more than one place**. `AS_FORCE_LINK` is defined twice — `AngelscriptBinds.h:32,34` and `StaticJITHeader.h:43,45` — so include order decides which wins. Relevant because `AS_FORCE_LINK` is the dead-strip guard for bindings in Shipping/Clang. | `AngelscriptRuntime/Core/AngelscriptBinds.h`, `AngelscriptRuntime/StaticJIT/StaticJITHeader.h` | STILL TRUE | NOT COVERED |
| E4 | 8 internal helper structs exported via `ANGELSCRIPTRUNTIME_API`, bloating the export table and blurring the public API: `FArrayOperations`, `FMapOperations`, `FSetOperations`, `FOptionalOperations`, `FAngelscriptBindHelpers`, `FAngelscriptStructTypeHelpers`, `FAngelscriptInstancedStructHelpers`, `FAngelscriptSubclassOfHelpers`. | `Binds/Bind_TArray_Functions.h`, `Bind_TMap.h`, `Bind_TSet.h`, `Bind_TOptional.h`, `Bind_Helpers.h` (×2), `Bind_TSubclassOf.h` | STILL TRUE | NOT COVERED |
| E5 | 11 virtual functions declared without `override`, so a base-signature change fails silently instead of at compile time: `UASClass` 6 (`ASClass.h:78,79,82,84,86,90`), `UScriptEditorMenuExtension` 3 (`:110,111,113`), `UScriptActorMenuExtension` 2 (`:25,26`), `UScriptAssetMenuExtension` 2 (`:24,25`). | as listed | STILL TRUE | NOT COVERED |

## F. Ownership and global state

| ID | Finding | Current evidence | Verdict | Coverage |
| --- | --- | --- | --- | --- |
| F1 | `GScriptNativeForms` is a `TMap<asIScriptFunction*, FScriptFunctionNativeForm*>` of raw `new` allocations; `Empty()` is called with no preceding `delete` loop — leaks every entry. | `AngelscriptRuntime/StaticJIT/StaticJITBinds.cpp:27` (decl), `:130` (`new`), `:68` (`Empty()`) | STILL TRUE | NOT COVERED |
| F2 | `ReplaceHelper->AddToRoot()` with no matching `RemoveFromRoot()`; static member rooted for the whole session, relying on engine shutdown. | `AngelscriptEditor/.../ClassReloadHelper.cpp:347`; decl `ClassReloadHelper.h:91` | STILL TRUE | NOT COVERED |
| F3 | `FJITDatabase` is a process-wide static singleton, not per-engine, so multiple engines share JIT lookup state. `Clear()` is now called between sessions, removing the worst pollution, but ownership is still global. | `StaticJIT/AngelscriptStaticJIT.h:18`, `.cpp:43-47`; cleared at `AngelscriptEngine.cpp:2094` | PARTLY FIXED | Partially — `docs-as-mutable-global-feasibility` (research only) |
| F4 | `DebugAdapterVersion` is a static global set during a debug session and never reset, so a reconnect or second client inherits the previous session's value. | `Debugging/AngelscriptDebugServer.cpp:51`, `.h:22`; set ~`:1313` | STILL TRUE | NOT COVERED |
| F5 | `ActiveTickOwners` static-count / not-per-world finding — identifier does not exist anywhere in the tree. Either removed or misnamed in the original report. | no match in `Plugins/Angelscript/Source/` | NOT FOUND | n/a — close |

## G. API surface consistency

Low severity individually; jointly they are the discoverability tax on a 1.0.0 product.

| ID | Finding | Current evidence | Verdict | Coverage |
| --- | --- | --- | --- | --- |
| G1 | `AS_*`-prefixed static constants in `Bind_Primitives.cpp` **rose 31 → 42** (`AS_MIN_uint8` … `AS_THRESH_NORMALS_ARE_ORTHOGONAL_flt`), bypassing the UE `G` convention. Intentional for AS exposure, but undocumented as a deliberate exception. | `AngelscriptRuntime/Binds/Bind_Primitives.cpp` | REGRESSED | NOT COVERED |
| G2 | 168 of 212 `BlueprintCallable` `UFUNCTION`s lack `Category` (79%) — ratio unchanged from the reported 177/224, so no progress. Blueprint palette is effectively unorganised. | `AngelscriptRuntime/`, `AngelscriptEditor/` | STILL TRUE | NOT COVERED |
| G3 | `FunctionLibraries` naming still mixes patterns across 22 files: `Angelscript<Name>Library.h`, unprefixed `<Name>MixinLibrary.h`, unprefixed `<Name>Statics.h`, and `UAssetManagerMixinLibrary.h` carrying a `U` type-prefix on a filename. `GameplayLibrary.h` sits unprefixed among 7 prefixed siblings. | `AngelscriptRuntime/FunctionLibraries/`, `AngelscriptEditor/FunctionLibraries/` | PARTLY FIXED | NOT COVERED |
| G4 | `Testing/` headers split exactly 6 prefixed / 6 unprefixed, with `Test` vs `Tests` vs `TestTypes` suffixes mixed. | `AngelscriptRuntime/Testing/` | STILL TRUE | Partially — `refactor-as-reflected-script-test-suites` |
| G5 | Console prefix fragmentation **overstated in the report**: only two families exist, `angelscript.` (2: `UseUnrealReload`, `UseRecompileAvoidance`) and `as.` (~9, incl. `as.ReflectiveFallback.UseCache`, `as.DumpEngineState`). Sub-namespace casing is inconsistent (`as.Test.` vs `as.test.`). The claimed `as.P3_2.` prefix **does not exist** — report was wrong. | plugin-wide CVar scan | PARTLY FIXED | NOT COVERED |
| G6 | `GAngelscriptDumpEngineStateCommand` registered only in the Test module; if engine-state dump is a delivery-facing entry point it cannot ship without the test module. | Test module registration | STILL TRUE | NOT COVERED |

## H. Findings carried by upstream/ecosystem reports

From `Report_HazelightDiscordGeneral_*` and `Review_LLMInstrumentationAndLeakFix_*`. These are **third-party-sourced signals, not verified against this tree** — they are recorded as leads requiring their own reproduction before any work is scoped. Distinguish them from A–G, which were re-verified.

| ID | Finding | Verdict | Coverage |
| --- | --- | --- | --- |
| H1 | StaticJIT null-chain access (e.g. `Controller.PlayerState.GetUniqueId()` with null `Controller`) crashes natively instead of raising a script exception. | UNVERIFIED lead | NOT COVERED |
| H2 | Temporary value lifetime in StaticJIT — temporary `FText`/`FString` passed as an argument can corrupt subsequent arguments. | UNVERIFIED lead | NOT COVERED |
| H3 | Precompiled path asserts on non-copyable value-type delegate parameters (`ObjectType->beh.copy != 0`). | UNVERIFIED lead | NOT COVERED |
| H4 | Plugin `Script/` directories not reliably staged as NonUFS without explicit config; no pre-ship validation. | UNVERIFIED lead | NOT COVERED |
| H5 | Cook/editor divergence — USTRUCT/UENUM visibility, precompiled type registration, DeveloperSettings paths differ in packaged builds. | UNVERIFIED lead | NOT COVERED |
| H6 | Hot-reload `_OLD` module suffix leaks into debugger breakpoint paths, source navigation, and callstacks. | UNVERIFIED lead | NOT COVERED |
| H7 | `BindWidget` resolution unreliable across hot reload; weak diagnostics for missing widgets. | UNVERIFIED lead | NOT COVERED |
| H8 | Reference-vs-value semantics boundary unclear (container element access returns a copy; `const T&` vs `const T&in` in delegates). Documentation/diagnostics gap. | UNVERIFIED lead | Partially — wiki content changes |
| H9 | Parser error locations misattributed for template default initialisers; `asINVALID_NAME` for illegal generated identifiers (e.g. collision channel `3DWidget`) gives no mapping back to the UE name. | UNVERIFIED lead | NOT COVERED |
| H10 | LLM instrumentation over-marking: 127 scope markers (70 BYNAME / 39 `AS_LLM_SCOPE` / 18 BYTAG), 6 declared tags unused, no consuming profiler or CI analysis. Related to D4. | UNVERIFIED lead | NOT COVERED |
| H11 | Compilation-event payloads (`FAngelscriptCompilationEvent`, `FAngelscriptPreprocessorSummary`, 20+ fields each, ~350 lines) consumed only by tests — no editor UI, IDE, or profiler consumer. | UNVERIFIED lead | NOT COVERED |

---

## Follow-up change candidates

Ordered by verified severity. Each is a separate change with its own verification; none is authorised by this record.

1. **`fix-as-hot-reload-thread-safety`** — A1–A6. Contains one confirmed data race (A6) and four unsynchronised cross-thread members. Highest correctness risk in the registry; also the cheapest to fix (`TAtomic<>` + one critical section).
2. **`refactor-as-compile-transaction`** — B1, A7, A9. Give `CompileModules()` an explicit transaction object with enforced stage ordering, rollback, and a bounded init wait.
3. **`refactor-as-dispatch-path-unification`** — C1–C6. Collapse or contract-bind the dual dispatch paths; stop discarding helper return values; make the cached-path bounds check symmetric; validate `vfTableIdx` after reload in shipping builds.
4. **`refactor-as-thirdparty-include-boundary`** — E1, E3. Route vendored AS headers through one entry header and de-duplicate `AS_FORCE_LINK`. Actively regressing (152 → 203), so cost grows with delay.
5. **`refactor-as-editor-codegen-decomposition`** — B7. Add a header, delete 593 dead lines, split `GenerateFunctionEntries()`.
6. **`refactor-as-binds-module-boundary`** — E2, E4, E5. Move `UCLASS` definitions out of `Binds/`, trim the export surface, add `override`.
7. **`fix-as-native-form-ownership`** — F1, F2, F4. Confirmed leak in `GScriptNativeForms`.
8. **`chore-as-api-surface-consistency`** — G1–G6. Batch the low-severity naming/`Category` work.
9. **Reproduce-then-scope** — H1–H11. Each needs a repro in this tree before it earns a change.
