## 1. Freeze The GMP Core Boundary And Scaffold The Plugin

- [ ] 1.1 <!-- Non-TDD --> Pin `Reference/GenericMessagePlugin` to commit `85283fbec0edba1a04c1cff8181455c5d97ba60a`; verify its Apache-2.0 license and turn `gmp-core-port-map.md` into the implementation provenance checklist.
- [ ] 1.2 <!-- Non-TDD --> Re-audit `D:\Workspace\UnrealEvent` and `W:\TDGame\Plugins\TD\TDEvent`; record only behavior worth preserving and do not treat either implementation as the GMP Hub port baseline.
- [ ] 1.3 <!-- Non-TDD --> Create `Plugins/UnrealEvent/UnrealEvent.uplugin`, `LICENSE`, `NOTICE`, `SourceProvenance.md`, and the `UnrealEventRuntime`, `UnrealEventAngelscript`, and `UnrealEventTest` module skeletons.
- [ ] 1.4 <!-- TDD --> Add architecture inspections that reject GMP or AngelScript dependencies in `UnrealEventRuntime`, GMP/`Reference/` inputs in every deliverable plugin Build.cs, generated per-event C++ files, `UNREAL_EVENT_KEY`, `DefaultGMPMeta.ini`, and any GMP product-facing class/config names.
- [ ] 1.5 <!-- TDD --> Make the architecture inspections pass with Runtime limited to Core, CoreUObject, Engine, and DeveloperSettings, and with Angelscript dependencies isolated to `UnrealEventAngelscript`.
- [ ] 1.6 <!-- Non-TDD --> Enable UnrealEvent in the host project, build the empty plugin through `Tools\RunBuild.ps1`, and prove the plugin-disabled host remains unaffected.

## 2. Implement UnrealEvent Settings And The Configured Registry

- [ ] 2.1 <!-- TDD --> Add settings reflection tests for `UUnrealEventSettings`, Project Settings placement at Plugins → Unreal Event, `Config/DefaultUnrealEvent.ini`, and the absence of GMPMeta/MessageTags naming.
- [ ] 2.2 <!-- TDD --> Add valid-config tests for zero-through-eight parameters, every permitted primitive, `FName`, `FString`, and startup-registered native `UEnum`, `UClass`, and `UScriptStruct` paths.
- [ ] 2.3 <!-- TDD --> Add invalid-config tests for empty keys, invalid kinds, missing or mismatched type paths, unsupported containers/references/pointers, unloaded Blueprint types, AngelScript-defined types, and arity above eight.
- [ ] 2.4 <!-- TDD --> Add duplicate-participant tests proving that all entries sharing a duplicate key are invalid rather than using first-wins or last-wins behavior.
- [ ] 2.5 <!-- TDD --> Add environment-policy tests proving Editor/Development logs a detailed error and sends that key through the dynamic route, while Cook/Commandlet terminates validation with failure.
- [ ] 2.6 <!-- TDD --> Implement `UUnrealEventSettings`, structured parameter descriptors, `DefaultUnrealEvent.ini`, and restart-required startup loading until the settings and validation tests pass.
- [ ] 2.7 <!-- TDD --> Add deterministic registry tests for lexical key ordering, stable `SymbolIndex` assignment, canonical signature fingerprints, config reorder invariance, and duplicate exclusion.
- [ ] 2.8 <!-- TDD --> Add router tests for configured hit, unconfigured miss, invalid-entry miss, hash collision, and exact `FName` equality without string conversion.
- [ ] 2.9 <!-- TDD --> Implement the immutable process-wide configured metadata registry and open-addressed `FName` router; store only metadata/signatures/indexes globally and no listeners, signal stores, Worlds, or GameInstances.
- [ ] 2.10 <!-- TDD --> Add configuration lifecycle tests proving no v1 live reload, no generated `.h/.cpp`, no UHT/UBT per-key generation, and stable startup state until process restart.

## 3. Port The Bounded GMP Callable, Signal, And Hub Core

- [ ] 3.1 <!-- TDD --> Add allocation/lifetime tests for inline small callable storage, heap fallback only for oversized callables, move/destruction, weak UObject targets, and invalid weak targets.
- [ ] 3.2 <!-- TDD --> Adapt the required `GMPFunction.h` concepts into UnrealEvent-owned callable code, retaining small-buffer and weak-call behavior without public GMP types or macros.
- [ ] 3.3 <!-- TDD --> Add signal slot tests for registration sequence, stable order, finite/unlimited Times, exact removal, stale generation, slot reuse, and deferred compaction.
- [ ] 3.4 <!-- TDD --> Add mutation tests for self-unlisten, removing a later listener, registration during dispatch, nested send visibility, Times-one recursion, and weak target death during a snapshot.
- [ ] 3.5 <!-- TDD --> Adapt only the required signal/slot/raw-fire mechanics from `GMPSignalsImpl.*` and `GMPSignals.inl` into UnrealEvent-owned names until the mutation and lifecycle tests pass.
- [ ] 3.6 <!-- TDD --> Add architecture inspections proving no wholesale import of `GMPMacros.h`, GMPMeta, MessageTags, K2, Store/Once, Request/Response, RPC, collection helpers, trace graph, or multi-script backend layers.
- [ ] 3.7 <!-- Non-TDD --> Record every adapted GMP source concept, local destination, retained optimization, semantic deviation, and license notice in `SourceProvenance.md` before considering the core port complete.

## 4. Build Per-GameInstance Storage And Automatic FName Routing

- [ ] 4.1 <!-- TDD --> Add `FUnrealEventHandle` tests for default handles, exact removal, double removal, stale generation, foreign-subsystem rejection, and slot reuse.
- [ ] 4.2 <!-- TDD --> Add two-GameInstance tests proving the same configured `SymbolIndex` resolves to different listener stores and the same dynamic key remains isolated.
- [ ] 4.3 <!-- TDD --> Add subsystem lifecycle tests for initialization, `ConfiguredStores` sizing from the immutable registry, `Deinitialize`, World teardown, listener death, and source death.
- [ ] 4.4 <!-- TDD --> Implement one private Hub per `UUnrealEventSubsystem`, a contiguous configured-store array indexed by `SymbolIndex`, and a separate per-subsystem dynamic `TMap<FName, Store>`.
- [ ] 4.5 <!-- TDD --> Add route tests proving ordinary public `FName` operations automatically select configured or dynamic storage without an alternate key type, macro, caller token, or generated event function.
- [ ] 4.6 <!-- TDD --> Add convergence tests proving C++ and AngelScript calls for one key reach the same configured or dynamic store and therefore share listeners, signature, order, and Times state.
- [ ] 4.7 <!-- TDD --> Implement `FName -> configured router -> SymbolIndex -> current subsystem ConfiguredStores[index]`, with router miss falling through to the current subsystem dynamic map.
- [ ] 4.8 <!-- TDD --> Add structural instrumentation proving the configured route performs no general store-map lookup, string conversion, signal-store allocation, hot sort, payload-variant construction, or common-path heap allocation.
- [ ] 4.9 <!-- TDD --> Add Game Thread and authoritative context tests, including invalid/cross-GameInstance World/Object calls and a guard against ambient editor-world selection.
- [ ] 4.10 <!-- TDD --> Implement explicit subsystem/World/source context resolution with no queues, async dispatch, process-global current World, or process-global listener storage.

## 5. Implement Scoped Deterministic Dispatch And Signatures

- [ ] 5.1 <!-- TDD --> Add Game-only, World→Game, and Object→World→Game propagation tests with exact source identity, stage order, equal-order stability, and cross-World/GameInstance isolation.
- [ ] 5.2 <!-- TDD --> Implement preordered stage buckets so registration/update work maintains dispatch order and a warm send never sorts listeners.
- [ ] 5.3 <!-- TDD --> Add callback failure tests proving finite Times is consumed before entry, later listeners continue after a recoverable failure, and a recursive Times-one listener runs only once.
- [ ] 5.4 <!-- TDD --> Implement ordered handle snapshots, immediate active/generation checks, nested current-state snapshots, outer-dispatch depth, and post-dispatch compaction.
- [ ] 5.5 <!-- TDD --> Add configured-signature tests proving the config is authoritative before any send/listen and exact count/type matching applies across every scope.
- [ ] 5.6 <!-- TDD --> Add dynamic-signature tests for first-send establishment with zero listeners, listener-prefix provisional state, compatible establishment, incompatible provisional listener invalidation, and later exact sends.
- [ ] 5.7 <!-- TDD --> Implement one canonical signature per store, exact comparison with no numeric coercion, and callback prefix compatibility without Store/Once aliases.
- [ ] 5.8 <!-- TDD --> Add zero-through-eight payload tests covering supported primitives, `FName`, `FString`, native enums, UObject handles, reflected USTRUCT copy/destruction, and callback prefixes.
- [ ] 5.9 <!-- TDD --> Add rejection tests for containers, non-UObject pointers, unsupported FFI types, output/non-const-reference callbacks, invalid keys/context, and expired resolved state.
- [ ] 5.10 <!-- TDD --> Implement the synchronous borrowed-address Runtime bridge and reflected buffer lifecycle, proving no argument address survives the send and every constructed reflected value is destroyed exactly once.
- [ ] 5.11 <!-- TDD --> Add Development/Shipping inspections proving verbose type/call-site text compiles out where planned while all signature, lifetime, generation, context, and bounds checks remain fail-closed.

## 6. Bind The Minimal AngelScript API And Configured Adapters

- [ ] 6.1 <!-- TDD --> Add surface enumeration tests for `FUnrealEventHandle` and exactly `Event::Listen`, `ListenWorld`, `ListenObject`, `Send`, `SendWorld`, `SendObject`, `Unlisten`, and `UnlistenAll`; reject public internal/config/generated helpers.
- [ ] 6.2 <!-- TDD --> Register the handle, Listen families, unlisten operations, and zero-through-eight generic Send overloads through the current file-static `FAngelscriptBind` pattern.
- [ ] 6.3 <!-- TDD --> Add inline `ASTEST_AS` compile/execution fixtures for all three Send families, every arity, configured keys, unconfigured keys, and variable `FName` keys.
- [ ] 6.4 <!-- TDD --> Add AS type-matrix fixtures for all supported categories plus exact numeric mismatches, containers, disallowed references, script-defined configured types, and ninth-argument compile failure.
- [ ] 6.5 <!-- TDD --> Implement generic AS type extraction/canonicalization and borrowed payload marshalling so accepted calls return true even with zero matching listeners.
- [ ] 6.6 <!-- TDD --> Add configured adapter registration tests for deterministic internal names, signature fingerprinting, symbol-index capture, deliberate hash collisions, no public declaration leakage, and registration before initial compilation.
- [ ] 6.7 <!-- TDD --> Register the reserved `__UnrealEventInternal` typed adapter declarations in memory from the validated registry through file-static `FAngelscriptBind` phases, without writing C++/AS source files, relying on post-compile `OnEngineAttached`, or exposing them as stable API.
- [ ] 6.8 <!-- TDD --> Add preprocessor rewrite tests proving configured literal calls select the exact typed adapter, while variable keys, unconfigured literals, and invalid-config keys keep the generic public call.
- [ ] 6.9 <!-- TDD --> Install the rewrite hook during adapter module startup and implement literal-call rewriting without changing source-visible `Event::Send*` syntax; prove the hook exists before initial preprocessing and preserve diagnostics/source mapping for compile errors.
- [ ] 6.10 <!-- TDD --> Add warm-path counters proving a rewritten configured call bypasses key routing, `PropertyFromString`, `FindFunction`, runtime layout discovery, and `ProcessEvent` on the JIT path.
- [ ] 6.11 <!-- TDD --> Implement configured adapter caches for `SymbolIndex`, canonical signature, type/property descriptors, marshalling plan, and callback entry strategy.
- [ ] 6.12 <!-- TDD --> Add callback declaration tests for valid `UFUNCTION`, non-UFUNCTION method, return value, out/ref parameters, unsupported types, exact/prefix signatures, and provisional incompatibility.
- [ ] 6.13 <!-- TDD --> Implement weak Listener+Method authoritative identity, generation-tagged `UFunction`/`UASFunction` caching, exact JIT parameter-entry invocation, and reflected fallback buffers.
- [ ] 6.14 <!-- TDD --> Add exception/failure tests proving diagnostics are emitted, Times remains consumed, later listeners continue, and no stale callback address or strong script-function ownership remains.

## 7. Close Hot Reload, Performance, And Configuration Behavior

- [ ] 7.1 <!-- TDD --> Add Hot Reload/lifecycle tests for compatible method replacement, method deletion, incompatible signature change, module discard, engine teardown, initial-compile failure before extension attachment, and adapter-module shutdown.
- [ ] 7.2 <!-- TDD --> Register an `IAngelscriptExtension` that invalidates only post-publication AS-owned caches for the correct engine/reload generation, never owns declaration registration, and never adds an AngelScript dependency to Runtime.
- [ ] 7.3 <!-- TDD --> Add module-configuration tests covering Editor modular, Development modular, and Monolithic Shipping builds with inlining/LTO both available and unavailable; behavior must remain identical.
- [ ] 7.4 <!-- TDD --> Add structural performance gates for allocation, lookup, sort, payload construction, callback resolution, layout discovery, and invocation path counters before timing comparisons.
- [ ] 7.5 <!-- Non-TDD --> Add a project-owned `UnrealEventPerformance` suite reachable through `Tools\RunTestSuite.ps1`; it must build/run the required Monolithic Shipping benchmark plus an independently staged pinned-GMP comparison host, without adding GMP to a deliverable module or requiring a hand-written direct UBT command.
- [ ] 7.6 <!-- TDD --> Implement the primary benchmark: pre-resolved subsystem, Game scope, one `int32`, eight native listeners, 100,000 warmup sends, 1,000,000 measured sends, seven rounds, median aggregation.
- [ ] 7.7 <!-- TDD --> Gate the ordinary configured public `Send(FName)` median at no more than `1.2x` the equivalent native UE multicast delegate under the primary benchmark profile.
- [ ] 7.8 <!-- Non-TDD --> Record pinned GMP direct-send, configured UnrealEvent, dynamic UnrealEvent, native multicast, configured AS literal, and AS variable-key results with engine/build/CPU/compiler/listener/round metadata under this change's `benchmarks/` directory.
- [ ] 7.9 <!-- TDD --> Add negative performance regression fixtures proving the benchmark fails when the configured route is deliberately forced through dynamic lookup, per-send sorting, or common-path allocation.

## 8. Integrate Tests, Documentation, And Final Verification

- [ ] 8.1 <!-- Non-TDD --> Organize the test module under Architecture, Config, Core, Functional, Bindings, HotReload, and Performance with the `Angelscript.UnrealEvent.*` prefix and repository-owned fixtures.
- [ ] 8.2 <!-- Non-TDD --> Add the UnrealEvent prefix to the configured All suite and enable `UnrealEventTest` only for appropriate Editor/test targets.
- [ ] 8.3 <!-- Non-TDD --> Write Chinese architecture, configuration, usage, performance, testing, type/thread limitations, and Apache-2.0 provenance documentation first; then update the English plugin README/consumer guidance.
- [ ] 8.4 <!-- Non-TDD --> Document that callers always use ordinary `FName`, configuration only selects the fast path, invalid Development entries fall back dynamically, Cook/Commandlet rejects bad config, and configuration changes require restart.
- [ ] 8.5 <!-- Non-TDD --> Run the narrow architecture/config/core/binding/hot-reload prefixes after their milestones and record exact results without conflating repository test baselines.
- [ ] 8.6 <!-- Non-TDD --> Run the final project build, `Angelscript.UnrealEvent.*`, `UnrealEventPerformance`, and configured All suite through project runners; store fresh logs/results with known limitations.
- [ ] 8.7 <!-- Non-TDD --> Map every requirement/scenario in both capability specs to a named test or architecture inspection, verify every GMP-derived destination against provenance, and run final forbidden-surface/dependency scans plus `git diff --check` before claiming completion.
