# UnrealEvent Reference Audit

## Audited baselines

| Reference | Audited state | Useful evidence | Boundary for UnrealEvent |
|---|---|---|---|
| `D:\Workspace\UnrealEvent` | Local UE prototype; root is not a Git repository | Runtime/Test split; Game/World/Object behavior; Times/Order; weak UObject handling; reentrancy tests; Store/Request experiments; direct GMP comparison benchmarks | Behavior and test reference only. Its Runtime is a process-global `FUnrealEventHub::Get()` with nested `TMap`/`TArray` storage and `TUniqueFunction`; it is not a GMP Hub-core port. Do not copy its global ownership, broad Blueprint/trace/StructUnion surface, Store/Once, or request/response. |
| `W:\TDGame\Plugins\TD\TDEvent` | `W:\TDGame` HEAD `4595fde5470ea97dd058a7a878875908cc358a57`; relevant history includes `1b216a0 [TDEvent] Commit` | Compact AS namespace; FName `Listen*`, `Send*`, and unlisten workflow; direct GMP Hub subclassing | UX reference only. Do not retain its GMP Runtime dependency, `AngelscriptCode` integration, GameplayTag overloads, one-to-five argument ceiling, unfinished paths, or `GEngine->GetCurrentPlayWorld()` lookup. |
| `Reference\GenericMessagePlugin` | Commit `85283fbec0edba1a04c1cff8181455c5d97ba60a`; matching tags include `build-UE5.6`, `build-UE5.7`, and `build-UE5.8` | `GMPFunction`, `FSignalStore`/`FSigElm`, static/direct Key slots, raw fire ABI, optional inline fire, signature diagnostics, named AS method support, typed-tag contexts, preprocessor rewrite, `JitFunction_ParmsEntry`, and `ProcessEvent` fallback | Apache-2.0 source/design baseline for the bounded Hub core. Port into plugin-owned UnrealEvent files, rename public/internal identities, and adapt global static Store ownership to per-GameInstance storage. Never make `Reference/` a deliverable Build.cs/include/link input; a separate transient comparison host may stage the pinned tree for the GMP-only benchmark control. |
| Current AngelscriptProject bindings | Current `Plugins/Angelscript` and optional extensions | File-static `FAngelscriptBind`, explicit bind phases, `IAngelscriptExtension`, `FAngelscriptEngineExtensionRegistry`, current `UASFunction`, preprocessor hooks, CQTest/functional fixtures | Authoritative AS integration model. GMP/TDEvent registrars, ambient-world behavior, and script-backend abstractions are not authoritative. |

## The old UnrealEvent prototype is not the core port

The prototype's `UnrealEventRuntime.Build.cs` depends only on Core/CoreUObject/Engine and contains no GMP source or link dependency. Its test module depends on GMP solely to compare behavior and timings. The Runtime Hub uses:

- one process-static `FUnrealEventHub::Get()`;
- `TMap<TWeakObjectPtr<UGameInstance>, TMap<FName, TArray<Listener>>>` and analogous World/Object maps;
- `TUniqueFunction<void(const FUnrealEventMessage&)>` callback storage;
- `Bucket.Find(EventKey)` for every dispatch;
- direct in-place listener removal while iterating;
- reflected `FUnrealEventMessage`/StructUnion transport instead of GMP's raw typed-address ABI.

It has no `FSignalStore`, `FSigElm`, custom SBO callable store, static Key slot, direct-store route, configured symbol registry, or inline fire loop. The new implementation therefore reuses its expected behavior and fixtures, not its Hub implementation.

## GMP Hub-core mechanisms to port or adapt

The exact source/symbol disposition is maintained in `gmp-core-port-map.md`. The core boundary is:

- **Port/adapt:** small-buffer erased callable storage; weak callable identity; signal element/store layout; raw synchronous fire ABI; mutation-safe iteration; static/direct Key resolution concepts; direct Hub path; optional Monolithic inline fire; compact Shipping diagnostics.
- **Reference only:** AngelScript typed-tag user data, post-process rewrite, UASFunction cache, parameter-entry JIT invocation, and the GMP benchmarks.
- **Replace:** process-global/static per-Key `FSignalStore` ownership becomes immutable process metadata plus `ConfiguredStores[SymbolIndex]` owned by each GameInstance subsystem.
- **Reject:** GMPMeta, MessageTags, GameplayTags, K2/Blueprint nodes, Store/Once/Request/Response, RPC, collections, script-backend matrices, call-site trace graphs, and other product layers.

## Configured-symbol and automatic routing model

`UUnrealEventSettings` is a Runtime `UDeveloperSettings` class with `Config=UnrealEvent, DefaultConfig`. `Config/DefaultUnrealEvent.ini` declares `HighPerformanceEvents`; each valid entry contains one FName Key and zero through eight structured parameter descriptors.

At Runtime startup, UnrealEvent validates all entries, sorts valid Keys lexically, assigns deterministic dense `SymbolIndex` values, builds canonical signatures/fingerprints, and freezes an immutable low-load FName router. It does not generate source files. The registry owns metadata only.

Each `UUnrealEventSubsystem` constructs one contiguous configured-store array at initialization. A normal C++ or generic AS `FName` operation checks the immutable router:

```text
FName -> configured router -> SymbolIndex -> current GI ConfiguredStores[SymbolIndex]
                         miss -> current GI DynamicStores.Find/FindOrAdd(FName)
```

This keeps the user API uniform. The configured route avoids the general `TMap<FName, Store>`, string conversion, store allocation, and first-send signature establishment. The selection probe is still part of ordinary FName calls; configured AS literal adapters bypass it because their function user data already contains `SymbolIndex`.

All operations for the same Key converge on the same store: a configured Key passed through a variable FName must not create a second dynamic store. Unconfigured Keys retain the dynamic behavior and first-accepted-send signature rule.

## Configured signature and type boundary

Configured signatures support bool, fixed-width integer categories, float, double, FName, FString, and startup-registered native UEnum/UClass/UScriptStruct types. Enum/Object/Struct descriptors use an exact `/Script/Module.Type` top-level asset path. Numeric coercion, containers, non-UObject pointers, AS-defined types, and unloaded Blueprint-generated types are not supported by the configured v1 path.

This restriction removes an AS compilation cycle: a typed native adapter must be registered before scripts compile, while AS-defined types do not exist until after compilation. Those values may still use the unconfigured generic path if they satisfy its runtime reflected-type contract; v1 does not add a two-stage AS compiler.

Configured signatures are authoritative before any listener/send. Dynamic signatures continue to be established by the first accepted send. Detailed type names may compile out in Shipping, but compact signature comparison and rejection remain enabled.

## AngelScript adaptation

The public script stays FName-based. During the file-static `FAngelscriptBind` phases, before initial compilation, UnrealEvent registers one reserved typed adapter per valid configured Key under `__UnrealEventInternal`, using the configured native types and a deterministic canonical-Key-string hash to avoid sanitized-name collisions. Module startup installs `FAngelscriptPreprocessor::OnPostProcessCode` before initial preprocessing; configured literal `Event::Listen*`/`Send*` calls are renamed to the matching adapter and the Key argument is removed. `IAngelscriptExtension::OnEngineAttached` is post-compile in the maintained engine, so it is used for cache lifetime, not declaration registration. No `.as`, `.h`, or `.cpp` file is generated.

Adapter user data caches `SymbolIndex`, signature fingerprint, canonical descriptors, property/layout operations, and engine generation. The warm literal route must not redo configured-Key routing, `PropertyFromString`, `FindFunction`, or parameter-layout discovery. Unconfigured literals and variable Keys stay on the public generic overloads; a configured variable Key still reaches the configured store through the automatic router but retains generic marshalling overhead.

Named callbacks keep weak Listener + Method as authoritative identity. Cached `UFunction`/`UASFunction` state is generation-tagged; current `JitFunction_ParmsEntry` is preferred, with correct reflected `ProcessEvent` parameter storage as fallback.

## Configuration error policy

- Valid entries are independent: one bad entry does not disable other valid configured Keys.
- Empty Key, duplicate Key, invalid kind/path pairing, unresolved or wrong reflected type, unsupported type, and more than eight parameters invalidate the entry.
- Every entry participating in a duplicate Key is invalid; there is no first/last precedence.
- Editor/Development logs complete diagnostics and routes an invalid Key dynamically.
- Cook/Commandlet treats any invalid entry as an error and fails validation so Shipping cannot silently lose the promised path.
- Settings changes use `ConfigRestartRequired`; v1 has no live rebuild or console reload of the frozen registry/AS bindings.

## License and provenance rule

`Reference\GenericMessagePlugin\LICENSE` is Apache License 2.0. Before derived GMP source enters the plugin, implementation must create plugin-owned `LICENSE`, `NOTICE`, and `SourceProvenance.md` containing:

- upstream repository identity and commit `85283fbec0edba1a04c1cff8181455c5d97ba60a`;
- every copied or substantially derived upstream path/symbol;
- the corresponding UnrealEvent destination;
- a concise local modification summary, especially global-Store to per-GI adaptation;
- retained copyright/license notices;
- confirmation that Build.cs never compiles from `Reference/GenericMessagePlugin`.

Design inspiration that does not copy protectable source still records the upstream baseline for auditability.
