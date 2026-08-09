# Angelscript Bind/Free Completeness Verification

> Historical measurement report: instrumentation names and source locations below describe the pre-2026-08 direct-callback refactor. Current ownership and replay terminology is documented in `ASBindAllocationInventory.md` and `ASFullEngineRebindOverhead.md`; the memory conclusions remain historical evidence.

> Companion to `ASTestSuiteMemoryPeakRootCause.md` and `ASFullEngineRebindOverhead.md`.
> Question driven by the user: *"Are you sure ALL the memory really gets freed
> when the test harness destroys an Angelscript engine?"*
> Answer (TL;DR): **Almost — there *was* one small but real per-cycle leak
> (`FBlueprintEventSignature`, now fixed — see §4) and one suspicious drift
> (`FUObjectType`); the rest of the ~12 GB peak observed historically is
> dominated by `mimalloc` retention and *living* engines, not by AS code failing
> to call `delete`.**

The verification ran in two phases on 2026-05-13 → 2026-05-14:

1. **Phase 1 (lightweight)** — `FPlatformMemory` probes around `AcquireTransientFullTestEngine`,
   coarse + fine `LLM_SCOPE_BY{TAG,NAME}` instrumentation, `BindFreeEvidence_ThreeCycles`
   minimal test. Raw report: `D:\Tmp\AsMemExp\phase1-report.md`.
2. **Phase 2 (leak localisation)** — `MALLOCLEAK_SCOPED_CONTEXT` + `mallocleak.*`
   console commands, `BindFreeEvidence_LeakReport`. Raw report: `D:\Tmp\AsMemExp\phase2-report.md`.

This document captures the consolidated findings, evidence trail, and the
follow-up items each phase generated.

## 1. Methodology

### 1.1 Code instrumentation (all committed under this OpenSpec change)

| Location | Annotation | Purpose |
|----------|------------|---------|
| `AngelscriptTestUtilities.h::AcquireTransientFullTestEngine` | `SampleBindFreeMem(T0..T4)` + `FMemory::Trim(true)` after Reset+GC. | OS-level snapshot bracketing engine destroy & re-create. |
| `AngelscriptMemoryTags.{h,cpp}` (new) | `LLM_DECLARE_TAG_API` / `LLM_DEFINE_TAG` for `Angelscript_BindSDK / BindAdapter / BindDatabase / BindEphemeral`. | Coarse LLM buckets. |
| `AngelscriptEngine.cpp::BindScriptTypes` | `LLM_SCOPE_BYTAG(Angelscript_BindSDK)` + `MALLOCLEAK_SCOPED_CONTEXT(TEXT("Angelscript/BindScriptTypes"))` | Outermost bind entry. |
| `AngelscriptBinds.cpp::CallBinds` | `LLM_SCOPE_BYTAG(Angelscript_BindAdapter)` + `MALLOCLEAK_SCOPED_CONTEXT` per-bind dynamic context using `Bind.BindName`. | Per-lambda attribution without touching 120+ bind files. |
| `Bind_BlueprintType.cpp` | 9 `LLM_SCOPE_BYNAME` covering `FUObjectType / FSubclassOfType / FObjectPtrType / FWeakObjectPtrType / FClassProperty / FObjectProperty / FWeakObjectProperty` allocation sites. | Adapter-layer attribution. |
| `Bind_BlueprintEvent.cpp` | 3 `LLM_SCOPE_BYNAME` covering each `new FBlueprintEventSignature`. | Event-signature attribution. |
| `StaticJITBinds.cpp` | 17 `LLM_SCOPE_BYNAME` for each `new FScriptNative*` registration. | StaticJIT attribution. |
| `AngelscriptTest/Memory/BindFreeEvidenceTests.cpp` (new) | `BindFreeEvidence_ThreeCycles` + `BindFreeEvidence_LeakReport`. | Phase 1 & 2 driver tests. |

All instrumentation is **no-cost on shipping configurations** (`LLM_SCOPE_*` evaporates
when `ENABLE_LOW_LEVEL_MEM_TRACKER=0`; `MALLOCLEAK_SCOPED_CONTEXT` is empty when
`MALLOC_LEAKDETECTION=0`).

### 1.2 Test rigs

- Driver: `D:\Tmp\AsMemExp\Run-DirectEditor.ps1` (bypasses `RunTests.ps1` so the
  `-ini:Engine:[ConsoleVariables]:mi.MemoryResetDelay=0` switch can be appended
  un-mangled).
- Engine flags: `-Unattended -NullRHI -NOSOUND -BUILDMACHINE` plus optional
  `-LLM -LLMCSV` and the `mi.MemoryResetDelay=0` ini override.
- Engine: installed `C:\UnrealEngine\UE_5.7` (UE 5.7 launcher build).

### 1.3 What we lost vs. the original plan

`MALLOC_LEAKDETECTION=1` cannot be enabled against this installed Engine: setting
`GlobalDefinitions.Add("MALLOC_LEAKDETECTION=1")` either trips UBT's
"GlobalDefinitions differ from UnrealEditor" guard, or — when forced via
`bOverrideBuildEnvironment` — fails at link time because `Core.dll` does not
export `FMallocLeakDetection::DumpOpenCallstacks`. A `Unique` build environment
is rejected outright for installed targets. Phase 2 therefore degrades to "best-
effort LLM analysis" + a placeholder test (`BindFreeEvidence_LeakReport`) that
exercises the `mallocleak.*` console commands so the codepath is ready the day a
source-built Engine becomes available.

## 2. Phase 1 — Quantitative Per-Cycle Memory Behaviour

### 2.1 `BindFreeEvidence_ThreeCycles` (no LLM, `mi.MemoryResetDelay=0`)

Five probe points per cycle (T0 before Reset, T1 after Reset+GC, T2 after Trim,
T3 after new engine bind, T4 after final release).

| Phase | OS_UsedPhys (MB) | Δ from previous |
|------|-----------------:|---------------:|
| T_BeforeFirstCycle | 2550.9 | — (baseline) |
| Cycle 1 T3 | 2641.4 | +90.5 (first bind) |
| Cycle 2 T0 → T1 (Reset+GC) | 2641.4 → 2577.0 | **-64.4** |
| Cycle 2 T1 → T2 (Trim) | 2577.0 → 2577.0 | 0 |
| Cycle 2 T2 → T3 (rebind) | 2577.0 → 2603.2 | +26.2 |
| Cycle 3 T0 → T1 (Reset+GC) | 2603.2 → 2593.6 | -9.6 |
| Cycle 3 T2 → T3 (rebind) | 2593.6 → 2638.9 | +45.3 |
| T4_AfterFinalRelease | 2638.9 → 2626.0 | -12.9 |

**Residual** vs. baseline: `+75.1 MB` after 3 cycles + final release.

Two crisp observations:
- **`FMemory::Trim(true)` is a no-op** when `mi.MemoryResetDelay=0`, confirming
  the previously stated mimalloc hypothesis: with default 10 s delay the same
  release would not have shown up at T1 — it would have lagged until T2.
- The bind product oscillates around a **steady-state** (~2615 MB after the
  editor's working set stabilises); cycles 2 and 3 only differ by ±10 MB. There
  is no linear leak at engine-creation granularity.

### 2.2 `BindFreeEvidence_ThreeCycles` with `-LLM -LLMCSV`

LLM tag snapshot at the last sampled frame (the LLM ticker doesn't align to our
T0..T4 markers, so this is "right around the test's end"):

| Tag | Size (MB) |
|------|----------:|
| `Angelscript` (aggregate) | 203.20 |
| `Angelscript/Angelscript/BindAdapter` | 191.10 |
| `Angelscript/Event/BlueprintEventSignature` | 7.41 |
| `Angelscript/Adapter/UObjectType` | 4.68 |
| `Angelscript/Property/ObjectProperty` | 0.01 |
| every other `Angelscript/*` tag | **0.00** |

Reading: a single living engine costs ~200 MB at steady state. The fine-grained
tags `Engine/DebugServer / SharedState / TypeDatabase / BindState /
Adapter/SubclassOfType / ObjectPtrType / WeakObjectPtrType /
Adapter/InterfaceMethodSignature` all read **0 MB** when no engine is alive at
the sampling instant — strong evidence that those allocation paths *do* go
through their respective `delete` / `Reset()` on engine shutdown.

### 2.3 `Angelscript.TestModule.Engine.Isolation` — 14 tests, mi.MemoryResetDelay=0

Result: **14 / 14 PASS** in 49.77 s. Used only to confirm the instrumentation
does not regress existing engine create/clone paths.

## 3. Phase 2 — Six-Cycle Probe + LLM Delta (the closest thing to a leak report we can get)

Phase 2 runs both `BindFreeEvidence_LeakReport` and `BindFreeEvidence_ThreeCycles`
back-to-back, producing 6 total engine create/destroy cycles in one process.
LLM CSV delta over the test window:

| Tag | F1 (MB) | Flast (MB) | Δ (MB) | Verdict |
|---------|--------:|----------:|------:|---------|
| `Angelscript` (aggregate) | 99.65 | 315.93 | +216 | mostly one extra living engine |
| `Angelscript/Angelscript/BindAdapter` | 93.29 | 296.69 | +203 | as above |
| `Angelscript/Event/BlueprintEventSignature` | 2.31 | **12.72** | **+10.4** | **real leak, see §4** |
| `Angelscript/Adapter/UObjectType` | 4.03 | 6.50 | +2.47 | soft lead, monitor |
| `Angelscript/Property/ObjectProperty` | 0.01 | 0.01 | 0 | clean |
| every other `Angelscript/*` tag | 0.00 | 0.00 | 0 | clean |

## 4. Concrete Leak — `FBlueprintEventSignature` — **FIXED 2026-05-14**

### 4.1 Original symptom

Source: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintEvent.cpp`,
three sites (`BindBlueprintEventOnFunctionStatic`,
`BindBlueprintEventOnFunctionInstance`, `BindBlueprintEventOnMethodMulticast`).
Each did

```cpp
auto* Sig = new FBlueprintEventSignature;
Sig->FunctionName = Function->GetFName();
...
FAngelscriptBinds::BindGlobalFunctionDirect(..., asFUNCTION(CallStaticWithSignature),
    asCALL_GENERIC, ASAutoCaller::FunctionCaller::Make(), Sig); // ← Sig captured as auxiliary user data
```

The `Sig` pointer is attached to the resulting `asIScriptFunction` so it can be
retrieved via `Function->GetUserData()` at call-dispatch time. The AS 2.33 fork
used by this project diverges from upstream Angelscript here in two important
ways (see `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptfunction.{h,cpp}`):

- `asCScriptFunction::SetUserData(data, type)` **ignores the `type` parameter**
  and stores into a single `void* userData` slot (no multi-slot user-data table).
- `~asCScriptFunction()` / `DestroyInternal()` does **not** invoke any cleanup
  callback for that slot (there is no `SetFunctionUserDataCleanupCallback` API
  on this fork).

Consequently, when the AS engine is destroyed every `FBlueprintEventSignature`
allocated during bind survived into the next round.

LLM evidence (pre-fix): tag `Angelscript/Event/BlueprintEventSignature` grew
from 2.31 MB to 12.72 MB across 6 engine cycles ≈ **+1.7 MB / cycle** (~1k
events × `sizeof(FBlueprintEventSignature)` ≈ 1.6 KB on a real bind, given the
`FAngelscriptTypeUsage Arguments[AS_EVENT_MAX_ARGS]` member).

### 4.2 Fix — per-engine `FBlueprintEventSignatureRegistry`

Adding a cleanup callback hook to the fork was rejected (touches ThirdParty).
The recommended-but-deferred upstream-alignment path was also passed over for
the smaller-surface alternative. The accepted fix is **C — per-engine owner
list**:

- New translation unit
  `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/BlueprintEventSignatureRegistry.{h,cpp}`
  introduces `class FBlueprintEventSignatureRegistry` holding
  `TArray<void*>` of signatures it owns, guarded by an `FCriticalSection`.
  The header keeps `FBlueprintEventSignature` opaque; deletion is dispatched
  through `BlueprintEventSignatureRegistryInternal::DropOwnedSignature(...)`
  defined in `Bind_BlueprintEvent.cpp` where the struct is complete.
- `FAngelscriptOwnedSharedState` (in `AngelscriptEngine.cpp`) grows a
  `TUniquePtr<FBlueprintEventSignatureRegistry> BlueprintEventSignatureRegistry`
  member, initialised by `EnsureSharedStateCreated()` and `Reset()` in
  `ReleaseOwnedSharedStateResources()` **immediately after**
  `ScriptEngine->ShutDownAndRelease()` — at that point every `asCScriptFunction`
  has been destroyed and no `userData` pointer can be observed again.
- `FAngelscriptEngine::GetBlueprintEventSignatureRegistry()` mirrors
  `GetTypeDatabase()` / `GetBindState()`.
- `Bind_BlueprintEvent.cpp` exposes a helper
  `NewOwnedBlueprintEventSignature()` and the three `new FBlueprintEventSignature`
  sites route through it; the helper allocates the struct and hands ownership
  to the current engine's registry.

### 4.3 Validation — `BindFreeEvidence_BlueprintEventSignatureBounded`

New regression test in
`Plugins/Angelscript/Source/AngelscriptTest/Memory/BindFreeEvidenceTests.cpp`
drives six full engine create/destroy cycles and asserts the registry's owned
count stays within ±8 of the cycle-1 baseline. Real measurement on 2026-05-14:

| Cycle | `Registry->Num()` | Δ vs. baseline |
|------:|------------------:|---------------:|
| 1     | 1060              | — (baseline) |
| 2     | 1060              | 0 |
| 3     | 1060              | 0 |
| 4     | 1060              | 0 |
| 5     | 1060              | 0 |
| 6     | 1060              | 0 |

Test result: **PASS**. Delta is exactly 0 across all six cycles — every signature
from a destroyed engine is released before the next engine begins binding. The
LLM tag `Angelscript/Event/BlueprintEventSignature` is now expected to oscillate
around `~1060 × sizeof(FBlueprintEventSignature)` ≈ 1.7 MB per live engine and
return to 0 when no engine is alive.

### 4.4 Files touched (commit-ready scope)

- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/BlueprintEventSignatureRegistry.h` (new)
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/BlueprintEventSignatureRegistry.cpp` (new)
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintEvent.cpp` (3 sites + helper + deleter)
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h` (fwd decl + getter)
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` (state field, init, reset, getter impl, include)
- `Plugins/Angelscript/Source/AngelscriptTest/Memory/BindFreeEvidenceTests.cpp` (new test method)

Build: `Rebuild All: 1 succeeded, 0 failed` (Win64 Development, 113 s). No new
linter warnings.

## 5. Where the Other ~65 MB Went

After accounting for the `BlueprintEventSignature` leak we have ~65 MB still
unexplained between baseline and T4 in the Phase 1 run. Plausible buckets,
ranked by likely contribution:

1. **One living engine** left in `GetTransientFullTestEngineStorage()` at T4
   (test stores it again on the way out): ~50 MB tail of `BindAdapter`-tagged
   allocations (the `asCScriptEngine` plus its registered types / functions).
2. **`FNamePool` growth**. AS bindings register thousands of new `FName` values
   on first bind; the pool is append-only globally.
3. **mimalloc residual segments** that survived `Trim(true)`. The
   `mi.MemoryResetDelay=0` switch returns *most* but not 100% of the freed
   region because reserved segments are managed per-thread and only collapsed
   on thread exit.
4. **Editor / shader / asset caches** that drift independently of Angelscript.

None of those qualify as "an AS bind missing its delete" — they are either
not Angelscript-owned, or they are by-design append-only.

## 6. Soft Lead — `Adapter/UObjectType` (+2.47 MB / 6 cycles)

Each cycle's bind calls `MakeShared<FUObjectType>` for every UClass that goes
through `RegisterUObjectType`. Old `FUObjectType` shared pointers should drop
when the previous engine is destroyed (their refs live in the engine-local
`FAngelscriptType::TypeRegistry`).

The +2.47 MB / 6 cycles ≈ 0.4 MB / cycle ≈ a few hundred kilobytes of pointer-
adjacent data per round. **Now that the `BlueprintEventSignature` leak from §4
is closed**, re-run this verification and confirm `UObjectType` returns to 0
delta across cycles. If it does not, the next suspects are the *global*
`TypeFinders` and the `GScriptNativeForms` global TMap, both of which retain
entries keyed by `FBindFunction` pointer across binds.

## 7. Summary of Changes to Cross-Linked Documents

- `ASTestSuiteMemoryPeakRootCause.md` — the executive summary should drop the
  phrasing "the peak is inherent" and instead say "the peak is dominated by
  mimalloc retention plus *one* small but real `FBlueprintEventSignature` leak
  and a steady-state per-living-engine cost of ~200 MB". The empirical Annex B
  data stays valid.
- `ASFullEngineRebindOverhead.md` — section "Why static bind tables are reused
  but bind products are not" is correct; add a small box pointing to §4 here as
  the only known per-cycle leak inside the bind product.
- `ASEngineMemoryAnalysis.md` — root-cause inventory grows one entry:
  `FBlueprintEventSignature` lifecycle.

## 8. Operating Instructions for Future Runs

To repeat the Phase 1 measurement:

```powershell
& "D:\Tmp\AsMemExp\Run-DirectEditor.ps1" `
    -Label "BindFreeEvidence_NoLLM" `
    -TestPrefix "Angelscript.TestModule.Memory.BindFreeEvidence" `
    -ZeroResetDelay
```

To capture the LLM CSV:

```powershell
& "D:\Tmp\AsMemExp\Run-DirectEditor.ps1" `
    -Label "BindFreeEvidence_LLM" `
    -TestPrefix "Angelscript.TestModule.Memory.BindFreeEvidence" `
    -ZeroResetDelay -EnableLLM
# Then inspect: D:\Workspace\AngelscriptProject\Saved\Profiling\LLM\LLM_Pid*.csv
```

When MALLOC_LEAKDETECTION becomes available (source-built Engine), re-enable it
in `Source/AngelscriptProjectEditor.Target.cs` (the location is documented
inline) and rerun `BindFreeEvidence_LeakReport`; the report will land in
`<Project>/Saved/Profiling/MemReports/*Leaks.txt`.
