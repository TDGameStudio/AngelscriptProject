# UnrealEvent GMP Core And AngelScript Bind Implementation Plan

> Execute this plan with `openspec-work`, `superpowers:executing-plans`, and `superpowers:test-driven-development`. Use `superpowers:verification-before-completion` before every completion claim. This change is currently a plan-only record: creating or updating this document does not implement the plugin.

**Goal:** Build a self-contained UnrealEvent plugin that ports only the performance-relevant GMP Hub core, automatically accelerates configured ordinary `FName` events, and exposes a deliberately small `Event::*` API to AngelScript.

**Architecture:** A frozen process registry contains configuration-derived metadata and an immutable `FName -> SymbolIndex` router. Every `UUnrealEventSubsystem` owns one Hub, a contiguous configured Store array, and a separate dynamic map. Native and AngelScript callers always use ordinary names; Runtime selects configured or dynamic storage automatically. The AngelScript adapter additionally rewrites configured literal calls to in-memory typed internal bindings, while variable names keep the generic call and still reach the configured Store at Runtime.

**Technology:** Unreal Engine 5.7 C++, UObject reflection, `UDeveloperSettings`, `UGameInstanceSubsystem`, the maintained `AngelscriptRuntime` binding/preprocessor/extension APIs, CQTest and UE Automation, StaticJIT callback entry points, and repository-owned PowerShell runners.

## Execution Rules

- Work in the current main checkout unless the user explicitly asks for a worktree.
- Preserve unrelated dirty-worktree changes. The source plugin will be a new sibling plugin, while OpenSpec remains in the parent repository.
- First write a failing focused test or inspection for every task marked TDD in `tasks.md`; run that leaf; implement only enough to pass; rerun the leaf before moving on.
- Build and test only through `Tools\RunBuild.ps1`, `Tools\RunTests.ps1`, and `Tools\RunTestSuite.ps1`. A performance helper may be added behind a typed suite, but the external entry remains `RunTestSuite.ps1`.
- Update `tasks.md` as implementation knowledge changes. Do not mark a checkbox from expectation or from an old log.
- Keep `gmp-core-port-map.md` and plugin `SourceProvenance.md` synchronized before adding any substantially derived source.
- Never compile or link GMP from a deliverable plugin/normal-host Build.cs and never add a Runtime dependency on GMP or AngelScript. The sole exception is the isolated performance suite, which may copy the verified pinned GMP plugin into a transient comparison host that is built and discarded independently.
- Never add `DefaultGMPMeta.ini`, `UGMPMeta`, MessageTags, `UNREAL_EVENT_KEY`, a `Fast` public API, a per-event generated `.h/.cpp`, or UBT/UHT config code generation.
- Runtime dependencies are Core, CoreUObject, Engine, and DeveloperSettings. The AS module alone depends on AngelscriptRuntime.
- V1 is synchronous, Game Thread only, zero-through-eight payloads, and one complete Hub per GameInstance.
- Write Chinese architecture/configuration/usage/testing material before the corresponding English consumer text.

## Frozen Product Contracts

### Configuration

`Config/DefaultUnrealEvent.ini` backs `UUnrealEventSettings : UDeveloperSettings`, displayed at Project Settings → Plugins → Unreal Event. `HighPerformanceEvents` is an allowlist of Key plus an exact structured parameter signature.

Supported configured kinds are Bool; signed/unsigned 8/16/32/64-bit integers; Float; Double; Name; String; and Enum/Object/Struct with exact `FTopLevelAssetPath`. Primitive/Name/String kinds require an empty path. Reflected kinds require a startup-resolvable native `UEnum`, `UClass`, or `UScriptStruct` path. V1 rejects AS-defined types, unloaded Blueprint-generated types, containers, unsupported pointers/references, invalid kind/path pairs, and more than eight parameters.

Every duplicate participant is invalid. Editor/Development reports detailed errors and omits invalid entries so those keys use the dynamic route. Cook/Commandlet fails configuration validation. Settings are frozen at startup and require process restart; v1 has no live reload.

### Routing And Ownership

```text
ordinary FName
  -> immutable configured router
       hit  -> SymbolIndex -> current GI ConfiguredStores[SymbolIndex]
       miss -> current GI DynamicStores.Find/FindOrAdd(Key)
```

The process registry owns immutable metadata only. Listeners, Stores, handles, source buckets, Times/Order state, and dynamic signatures live only in the current `UUnrealEventSubsystem`. A configured Key can never create a same-name dynamic Store, including when it arrives through a variable `FName` or the generic AS binding.

### Stable AngelScript Surface

```angelscript
namespace Event
{
    FUnrealEventHandle Listen(FName Key, UObject Listener, FName Method,
                              int Order = 0, int Times = -1);
    FUnrealEventHandle ListenWorld(FName Key, UObject Listener, FName Method,
                                   int Order = 0, int Times = -1);
    FUnrealEventHandle ListenObject(UObject Source, FName Key,
                                    UObject Listener, FName Method,
                                    int Order = 0, int Times = -1);

    bool Send(FName Key, [Arg0 ... Arg7]);
    bool SendWorld(FName Key, [Arg0 ... Arg7]);
    bool SendObject(UObject Source, FName Key, [Arg0 ... Arg7]);

    bool Unlisten(FUnrealEventHandle Handle);
    int UnlistenAll(UObject Listener);
}
```

The bracket notation means nine registered overloads per Send family, not a variadic AS declaration. `__UnrealEventInternal` is implementation-only. Its typed declarations and user data are registered in memory; no generated source artifact is part of the contract.

### Performance Acceptance

Structural counters are required before timing. The primary workload is a pre-resolved subsystem, Game scope, one `int32`, eight native listeners, Monolithic Shipping, 100,000 warmup sends, 1,000,000 measured sends, seven rounds, and median aggregation. The actual ordinary configured public `Send(FName)` median must be at most `1.2x` an equivalent native UE multicast delegate. The report also records pinned GMP direct/static performance, but Runtime never links GMP. Configured AS literal/JIT and ProcessEvent paths are reported separately and do not inherit the native C++ ratio gate.

## Planned File Map

| Area | Planned path | Responsibility |
|---|---|---|
| Plugin declaration | `Plugins/UnrealEvent/UnrealEvent.uplugin` | Runtime, AS adapter, and Editor test modules; required Angelscript plugin relationship. |
| Configuration | `Plugins/UnrealEvent/Config/DefaultUnrealEvent.ini` | UnrealEvent-owned example/default high-performance event list. |
| License/provenance | `Plugins/UnrealEvent/LICENSE`, `NOTICE`, `SourceProvenance.md` | Apache-2.0 text, notices, exact GMP commit/path/symbol-to-destination map and modifications. |
| Consumer entry | `Plugins/UnrealEvent/README.md` | English consumer summary after Chinese guidance exists. |
| Runtime rules | `Source/UnrealEventRuntime/UnrealEventRuntime.Build.cs` | Core/CoreUObject/Engine/DeveloperSettings only; no GMP/AS/Reference paths. |
| Settings public API | `Source/UnrealEventRuntime/Public/UnrealEventSettings.h` | `UUnrealEventSettings`, configured event/parameter schema and restart-required metadata. |
| Public types | `Source/UnrealEventRuntime/Public/UnrealEventTypes.h` | Scope/config kind/result types and opaque `FUnrealEventHandle`. |
| Public subsystem | `Source/UnrealEventRuntime/Public/UnrealEventSubsystem.h` | GameInstance lifetime, typed C++ Listen/Send façade, Unlisten operations. |
| Narrow bridge | `Source/UnrealEventRuntime/Public/UnrealEventRuntimeBridge.h` | AS-independent canonical descriptors, borrowed-address operations, no AS/GMP type exposure. |
| Config validation | `Source/UnrealEventRuntime/Private/Config/UnrealEventConfigValidation.*` | Entry validation, duplicates, environment policy, canonical type resolution. |
| Frozen registry | `Source/UnrealEventRuntime/Private/Core/UnrealEventConfiguredRegistry.*` | Lexical indexes, fingerprints, metadata, immutable open-addressed FName router. |
| Callable core | `Source/UnrealEventRuntime/Private/Core/UnrealEventCallable.h` | Renamed bounded derivative of GMP SBO erased/weak callable. |
| Signature core | `Source/UnrealEventRuntime/Private/Core/UnrealEventSignature.*` | Canonical exact signature, reflected identity, compact Shipping checks. |
| Signal core | `Source/UnrealEventRuntime/Private/Core/UnrealEventSignalStore.*` | Slots/generations, ordered stage buckets, snapshots, Times, weak targets, raw fire. |
| Hub | `Source/UnrealEventRuntime/Private/Core/UnrealEventHub.*` | Configured array, dynamic map, automatic route, scopes, subsystem generation. |
| Diagnostics | `Source/UnrealEventRuntime/Private/Diagnostics/UnrealEventDiagnostics.*` | Development detail, compact Shipping rejection, counters/trace-free observability. |
| Runtime lifecycle | `Source/UnrealEventRuntime/Private/UnrealEventSubsystem.cpp`, `UnrealEventRuntimeModule.cpp` | Settings freeze, registry startup, per-GI Hub setup/teardown. |
| AS module rules | `Source/UnrealEventAngelscript/UnrealEventAngelscript.Build.cs` | Runtime + AngelscriptRuntime dependencies only. |
| Public binds | `Source/UnrealEventAngelscript/Private/Binds/Bind_UnrealEvent.cpp` | Exact handle/Event namespace registration and 27 public generic Send overloads. |
| Configured binds | `Source/UnrealEventAngelscript/Private/Configured/UnrealEventConfiguredBindings.*` | File-static pre-compile typed internal declarations, stable names/hashes, user-data lifetime. |
| Literal rewrite | `Source/UnrealEventAngelscript/Private/Preprocessor/UnrealEventPreprocessor.*` | `FAngelscriptPreprocessor::OnPostProcessCode` hook and source-mapped literal rewriting. |
| Generic marshalling | `Source/UnrealEventAngelscript/Private/Invocation/UnrealEventAngelscriptMarshaller.*` | `asIScriptGeneric` type extraction and synchronous borrowed payload plan. |
| Callback invocation | `Source/UnrealEventAngelscript/Private/Invocation/UnrealEventAngelscriptInvoker.*` | named callback resolution, JIT parameter entry, ProcessEvent fallback, exceptions. |
| AS lifecycle | `Source/UnrealEventAngelscript/Private/UnrealEventAngelscriptExtension.*`, `UnrealEventAngelscriptModule.cpp` | `IAngelscriptExtension`, preprocessor hook registration, reload/engine cache generations. |
| Test module | `Source/UnrealEventTest/UnrealEventTest.Build.cs` and `Private/{Architecture,Config,Core,Functional,Bindings,HotReload,Performance}/` | Focused C++/AS/unit/functional/performance verification. |
| Test fixtures | `Source/UnrealEventTest/Private/Fixtures/UnrealEventTestObjects.*` | Native/script listeners, native enums/structs, weak lifetime and allocation/counter helpers. |
| Suite wiring | `Tools/Shared/TestSuiteDefinitions.ps1` plus a suite-owned helper if required | All prefix inclusion and Monolithic Shipping performance entry. |
| Project enablement | `AngelscriptProject.uproject` | Enable the sibling plugin for host validation. |
| Documentation | relevant `Documents/Guides/*UnrealEvent*.md` and plugin README | Chinese-first architecture/config/performance/testing and English consumer material. |

File names may be split when compilation boundaries require it, but responsibilities and module boundaries must remain unchanged. Any added source derived from GMP must be recorded before checkpoint approval.

## Milestone A — Provenance, Scaffold, And Architecture Guards

### A1. Freeze reference evidence

1. Verify `Reference/GenericMessagePlugin` HEAD/commit object equals `85283fbec0edba1a04c1cff8181455c5d97ba60a` and capture the Apache-2.0 license.
2. Reconfirm `D:\Workspace\UnrealEvent` is a behavior/test reference rather than a Hub core port: its process-global singleton and nested FName maps are explicitly not copied.
3. Reconfirm TDEvent's desirable surface is the compact Event API, not its direct GMP inheritance/product coupling.
4. Create plugin provenance files with one row for every planned derivative in `gmp-core-port-map.md`; add rows before code, not after release.

### A2. Write the failing architecture test

Create an Architecture test that initially fails because the plugin is absent, then inspects:

- descriptor/module presence and loading phases;
- Runtime dependencies exactly including DeveloperSettings but excluding GMP/Angelscript;
- no `Reference/` include/source/link input;
- no config-to-C++ generator, generated per-key source, `UNREAL_EVENT_KEY`, GMPMeta, or MessageTags product surface;
- AS dependencies restricted to the adapter/test module.

### A3. Scaffold only what the test requires

Create descriptor, configuration directory, Build.cs files, module entry points, license/provenance files, and host enablement. Build the empty modules before adding Hub logic.

Checkpoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -TimeoutMs 1800000 -Label unreal-event-scaffold -ExtraArgs "-NoHotReloadFromIDE"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.UnrealEvent.Architecture" -Label unreal-event-architecture -TimeoutMs 900000
```

Exit criteria:

- Empty plugin builds enabled.
- Architecture inspection is green.
- Every planned GMP-derived destination is already represented in provenance.
- No implementation code or build input comes from either external prototype path.

## Milestone B — Settings, Validation, And Frozen Symbol Registry

### B1. Settings and type-schema tests

Start with reflection/default-config tests. Cover zero-through-eight parameters and every configured kind. Assert primitive/Name/String entries reject a non-empty type path; Enum/Object/Struct require exact startup-loaded native paths of the right reflected class.

Use plugin test fixtures for one native `UENUM`, base/derived `UCLASS`, and non-trivial `USTRUCT`. Add negative fixtures for an unloaded Blueprint path and an AS-only type without synchronously loading or compiling either during registry construction.

### B2. Validation-policy tests

Use a pure validation input/output seam so tests need not mutate process defaults. Cover empty names, every invalid type/path pair, arity nine, unsupported types, and duplicates. One duplicate-key input with three participants must return three invalid results. Verify:

- Editor/Development: detailed errors, invalid entries omitted, key becomes a router miss and dynamic operation remains available;
- Cook/Commandlet: aggregate diagnostics then non-zero/failure result;
- packaged defensive path: never installs unsafe configured metadata.

No v1 API watches config files or mutates the registry after startup.

### B3. Deterministic metadata and router

Build canonical metadata in temporary mutable storage, reject invalid participants, sort valid keys lexically, then assign dense indexes. Fingerprints cover argument count, kind, and exact reflected identity. Configuration order must not change `(Key, SymbolIndex, Fingerprint)`.

Build an immutable open-addressed table at a documented low maximum load factor. A probe compares the stored full `FName` before returning SymbolIndex. Test empty registry, clustered collision, exact-name mismatch, valid hit, invalid-entry miss, and no `ToString`/allocation. The registry may be process-global only after construction is complete and must expose const metadata/views only.

Checkpoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.UnrealEvent.Config" -Label unreal-event-config -TimeoutMs 900000
```

Exit criteria:

- Settings appear under Plugins → Unreal Event and serialize only to `DefaultUnrealEvent.ini`.
- Validation behavior matches Editor/Development/Cook/Commandlet policy.
- Registry output is deterministic and immutable.
- No generated C++/AS artifact exists and restart-required behavior is documented/tested.

## Milestone C — GMP-Derived Callable And Signal Core

### C1. Port the callable, not the GMP API

Write allocation and lifecycle tests first. Adapt only the required concepts from `GMPFunction.h` into `FUnrealEventCallable`:

- fixed inline storage for the common native thunk/weak target adapter;
- one erased invoke function pointer plus Self address;
- explicit move/destruction operations;
- weak UObject validity without strong ownership;
- registration-time heap fallback only for an oversized callable;
- no public GMP type, macro, header, or namespace.

Instrument allocation at the callable boundary so the common case proves zero registration heap fallback and warm invocation proves no allocation.

### C2. Port mutation-safe signal mechanics

Write slot and recursive mutation tests before adapting `GMPSignalsImpl.*` / `GMPSignals.inl`. A slot contains id, generation, active bit, Times, Order, registration sequence, weak Listener/source as applicable, callback identity/cache hook, and erased thunk. The Store maintains sorted stage buckets on registration/cold mutation; dispatch never sorts.

For each stage, snapshot compact `(SlotId, Generation)` handles. Revalidate immediately before every callback. Positive Times decrements before entry. Nested send creates a new current-state snapshot. Compact only after the outermost dispatch. Callback failure continues later listeners and never restores Times.

### C3. Prove the port boundary

Add source/dependency inspections for the excluded GMP layers. Update provenance with the exact destination, retained algorithm, renamed types, removed global/static ownership, removed macro/product features, and new UE lifetime behavior.

Checkpoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.UnrealEvent.Core.Callable+Angelscript.UnrealEvent.Core.Signal" -Label unreal-event-signal-core -TimeoutMs 900000
```

Exit criteria:

- Callable/store lifetime and all recursive mutation cases pass.
- Common inline callable and warm dispatch allocate nothing.
- No excluded GMP layer or public GMP name entered the plugin.

## Milestone D — Per-GI Hub, Automatic Route, Scopes, And Exact Signatures

### D1. Handles and per-GameInstance ownership

Write handle tests before the Hub. `FUnrealEventHandle` must identify weak subsystem owner, slot id, and generation without exposing a Store pointer. Default/stale/foreign/double removal fails without mutation. `Deinitialize` increments subsystem generation, clears Stores, and retires all cached routes.

Construct `ConfiguredStores` with exactly registry metadata count. Test two simultaneous GameInstances with the same SymbolIndex and same dynamic FName. Listener/signature/source state must never cross between them.

### D2. Automatic ordinary-FName route

Centralize all public store resolution in the Hub:

1. validate Game Thread, subsystem generation, and key;
2. probe configured metadata;
3. on hit, index the current Hub's configured array;
4. on miss, use current Hub's dynamic map;
5. never allow configured-name creation in the dynamic map.

Typed C++, erased Runtime bridge, public generic AS, and internal typed AS adapters all terminate at the same Store. The internal typed adapter may pass SymbolIndex after validating the current subsystem/generation; no Store pointer survives subsystem lifetime.

### D3. Scopes and context

Implement Game, World→Game, and Object→World→Game as explicit stages in one Store. The listener/source World and GameInstance are authoritative. AS may use active execution world context when valid. Never call `GEngine->GetCurrentPlayWorld()`. Null, dead, cross-GI, ambiguous, or off-thread operations fail without establishing a dynamic signature.

### D4. Configured and dynamic signatures

Configured metadata initializes the Store's authoritative signature before any registration. Dynamic stores begin unset; first accepted Send establishes exact types even with no listeners. Pre-send dynamic listeners are provisional. Once a dynamic signature is established, deactivate incompatible provisional slots and retain compatible exact-prefix slots.

Canonical type equality has no numeric coercion. Callbacks return void and accept the first N exact payload types only. Reordering, skipping, output/non-const-ref, return values, containers, non-UObject pointers, and unsupported FFI are rejected.

The erased bridge passes borrowed addresses and canonical descriptors synchronously. Reflected buffers use the relevant `FProperty` initialization/copy/destruction operations; no payload pointer survives return.

Checkpoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.UnrealEvent.Core+Angelscript.UnrealEvent.Functional" -Label unreal-event-runtime -TimeoutMs 900000
```

Exit criteria:

- Same indexes/names are isolated across GameInstances.
- Ordinary `FName` calls select one and only one Store route automatically.
- All scope/order/Times/reentrancy/signature/type/lifetime cases pass.
- Configured warm route counters show no dynamic Store-map lookup, string conversion, Store allocation, hot sort, variant construction, or common heap allocation.
- Shipping retains compact safety checks while guarded verbose strings are absent.

## Milestone E — Minimal AS API, In-Memory Typed Adapters, And Callback Dispatch

### E1. Exact public registration

Start with a declaration-enumeration test. Register `FUnrealEventHandle`; three Listen operations; Unlisten/UnlistenAll; and 27 generic Send overloads using the repository's file-static `FAngelscriptBind` pattern. Assert excluded/Fast/internal per-key helpers are absent from the public Event namespace and consumer docs.

Generic Send receives `FName` and zero-through-eight arguments through `asIScriptGeneric`. It canonicalizes supported values into borrowed addresses/descriptors, calls Runtime synchronously, and retains no AS stack pointer. Add positive/negative inline `ASTEST_AS` fixtures for all arities and type categories before implementation.

### E2. Register configured typed adapters in memory before compilation

Add file-static `FAngelscriptBind` records in the appropriate declaration/explicit-binding phases. When those phases execute, enumerate valid registry metadata and resolve each native reflected path into the exact AS declaration type. Register reserved typed Listen/Send functions with deterministic names formed from sanitized key text plus a stable hash of the full canonical key string. User data contains:

- SymbolIndex and signature fingerprint;
- canonical parameter descriptors;
- resolved AS/native type identity;
- `FProperty`/layout copy and destruction plan when needed;
- callback entry/marshalling plan;
- current AS engine and registry generation.

Hash-collision tests must use deliberately colliding sanitized names and confirm distinct full-key hashes/declarations. Registration writes no file. Add startup-order instrumentation proving the Runtime registry is frozen, the module's bind metadata is present before `FAngelscriptBind::PrepareForEngineInitialization`, and all declarations exist before initial preprocessing/compilation. Adapter contexts need explicit per-engine cleanup ownership that also runs when initial compilation fails and `OnEngineAttached` is never reached. Do not register declarations from that extension callback, which the current engine calls only after successful initial compilation.

### E3. Rewrite only proven configured literals

Install the existing public `FAngelscriptPreprocessor::OnPostProcessCode` hook during AS adapter module startup, before the engine begins initial preprocessing. Parse calls sufficiently to distinguish the exact `Event::Listen*`/`Send*` callee, balanced argument list, and syntactically valid `n"..."` FName literal. A matching configured literal is renamed to its internal typed declaration and its Key argument is removed. Variable expressions, aliases the rewriter cannot prove, unconfigured literals, and invalid-config names remain unchanged on the public generic overload.

Preserve source line/layout mapping as required by current preprocessor diagnostics. Tests cover comments/strings, nested calls, whitespace, namespaces, malformed syntax, sanitized collisions, overload arities, and unchanged unsupported constructs.

### E4. Named callback resolution and fastest valid invocation

Listener + Method remain the authoritative weak identity. Cache `UFunction`/`UASFunction` with AS engine/reload generation and validate exact-prefix signature before activation/entry. If the current compatible `UASFunction::JitFunction_ParmsEntry` is valid, call its exact parameter-entry ABI. Otherwise create the declared-prefix parameter buffer, initialize/copy/destroy properties, and call `ProcessEvent`.

Tests and counters prove:

- warm configured literal call performs no key route, `PropertyFromString`, `FindFunction`, or layout discovery;
- current JIT callback performs no `ProcessEvent`;
- fallback has balanced buffer lifetime and identical visible behavior;
- script exception consumes Times, reports failure, and allows later listeners;
- Runtime stores no AS-owned strong function pointer.

### E5. Reload and teardown

Implement an adapter-owned `IAngelscriptExtension` using `OnEngineAttached`/`OnEngineDetached` only for the published engine and cache-generation lifecycle; register/unregister the preprocessor hook separately in module lifecycle. Static bind records recreate declarations for each new engine before compile. Cache generations must invalidate on compatible replacement, incompatible signature, missing method, module discard, engine detach, and adapter shutdown. The next valid send resolves current metadata. A missing/incompatible method deactivates and diagnoses once; stale JIT/UFunction addresses never execute.

Checkpoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.UnrealEvent.Bindings" -Label unreal-event-bindings -TimeoutMs 900000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.UnrealEvent.HotReload" -Label unreal-event-hot-reload -TimeoutMs 900000
```

Exit criteria:

- Exact public AS surface and all 0–8 arities compile/execute; the ninth does not.
- Configured literals use typed internal adapters without changing source spelling.
- Variables/unconfigured keys use generic calls, with configured variable names still selecting configured Runtime storage.
- JIT/fallback/reload/teardown paths pass counters, lifecycle, and stale-address tests.

## Milestone F — Structural Gates, Shipping Benchmark, Integration, And Documentation

### F1. Structural instrumentation before timing

Keep counters compiled only for tests/diagnostics as appropriate and outside the measured hot operation. Assert zero where required for:

- configured public FName dynamic-map lookup, string conversion, Store creation, hot sort, variant payload, reflected-name resolution, common heap allocation;
- configured AS literal key routing, `PropertyFromString`, `FindFunction`, and layout discovery;
- JIT callback `ProcessEvent` use.

Add deliberate regression fixtures or seams showing each structural test turns red when the forbidden operation is forced.

### F2. Module/configuration matrix

Run behavior suites against Editor/Development modular builds and the Monolithic Shipping benchmark target. Test the private `UNREALEVENT_WITH_INLINE_DISPATCH` setting in supported and unsupported configurations. It defaults to 0, cannot remove safety checks, and may only affect code placement for supported Monolithic targets; behavior and counters remain identical.

### F3. Project-owned performance suite

Add an `UnrealEventPerformance` suite definition under the repository test runner. If packaging/launch needs a helper, keep it under `Tools/` and call it only from the suite definition so users and agents invoke one supported entry. The helper creates two transient hosts under its own output area: one with the deliverable UnrealEvent plugin and one with a copied, commit-verified GMP plugin plus the smallest direct-fire control. Neither transient host changes plugin dependencies or becomes a normal project build input.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite UnrealEventPerformance -LabelPrefix unreal-event-performance -TimeoutMs 3600000
```

The suite must build/launch the exact Monolithic Shipping profile, reject instrumentation-disabled or wrong-build results, and emit machine-readable raw measurements plus a concise summary.

### F4. Benchmark cases and gate

Use the same payload/listener bodies for:

1. native UE multicast delegate baseline;
2. ordinary configured UnrealEvent `Send(FName)` — this exact case owns the `<= 1.2x` gate;
3. configured direct SymbolIndex internally, diagnostic only;
4. dynamic UnrealEvent FName route;
5. pinned GMP direct/static route, comparison only in test/performance target;
6. configured AS literal with valid JIT parameter entry;
7. AS variable FName/generic route;
8. AS ProcessEvent fallback.

For the gated case: pre-resolve subsystem outside the loop, Game scope, one int32 payload, eight native listeners, 100,000 warmups, 1,000,000 measured sends, seven rounds, median. Prevent dead-code elimination with an externally observed checksum. Randomize/interleave case order or otherwise document thermal/order control. Record engine commit/version, UnrealEvent/GMP commit, target/configuration, compiler/link/LTO/inline settings, CPU/OS/power mode, clock units, all seven raw values, medians, ratio, counters, and checksum in `benchmarks/`.

### F5. Test-suite and documentation closure

Wire `Angelscript.UnrealEvent.*` into the configured All suite without changing independent baseline counts. Write Chinese documentation for architecture, settings examples, ordinary-name automatic routing, invalid-config policy, restart requirement, C++/AS API, scopes, types, thread/lifetime rules, performance methodology, testing commands, and GMP provenance. Then write/update the English plugin README.

Checkpoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.UnrealEvent.Performance.Structural" -Label unreal-event-structural -TimeoutMs 900000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite UnrealEventPerformance -LabelPrefix unreal-event-performance -TimeoutMs 3600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite All -LabelPrefix unreal-event-all -TimeoutMs 1800000
```

Exit criteria:

- Structural gates are green in the correct build profiles.
- Ordinary configured `Send(FName)` meets the seven-round median `<= 1.2x` gate.
- GMP/native/configured/dynamic/AS results and full environment metadata are recorded.
- All suite includes the UnrealEvent prefix and has no new failure.
- Chinese-first and English documentation match the implemented contract.

## Final Verification And Handoff

Run fresh after the last implementation change:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -TimeoutMs 1800000 -Label unreal-event-final -ExtraArgs "-NoHotReloadFromIDE"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.UnrealEvent." -Label unreal-event-final -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite UnrealEventPerformance -LabelPrefix unreal-event-performance-final -TimeoutMs 3600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite All -LabelPrefix unreal-event-all-final -TimeoutMs 1800000
```

Before declaring the feature complete:

1. Map every scenario in `specs/unreal-event-core/spec.md` and `specs/unreal-event-angelscript-bind/spec.md` to a named test/inspection and confirm a fresh pass.
2. Re-scan Runtime Build.cs/includes for GMP/AngelScript/Reference leakage and scan the full plugin for excluded public surfaces/config names/codegen artifacts.
3. Compare every substantially derived file to `gmp-core-port-map.md` and `SourceProvenance.md`; confirm license/notice placement.
4. Inspect two-GameInstance ownership, configured/dynamic convergence, and teardown using both tests and code review.
5. Inspect raw benchmark files, confirm the measured case is ordinary configured `Send(FName)`, recompute medians/ratio, and confirm the declared build profile.
6. Run `git diff --check`, inspect the complete source/OpenSpec diff, and preserve unrelated user changes.
7. Record exact fresh command results and limitations under this change. Only then mark the corresponding `tasks.md` boxes complete.
