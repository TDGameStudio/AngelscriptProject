# GMP Core Port Map

## Baseline and rule

- Upstream: `Reference/GenericMessagePlugin`
- Commit: `85283fbec0edba1a04c1cff8181455c5d97ba60a`
- License: Apache License 2.0
- Build rule: `Reference/` is read-only evidence and never a compiler/include/link input for UnrealEvent or the normal host. The performance suite may copy the verified pinned GMP plugin to a transient comparison host that is built independently and never shipped.
- Product rule: all shipped APIs, settings, logs, namespaces, console commands, files, and configuration use UnrealEvent names. No `GMPMeta`, MessageTags, or GMP public API is retained.

This table is the design-time port inventory. `Plugins/UnrealEvent/SourceProvenance.md` becomes the implementation-time file/patch ledger and must be updated before each substantially derived file is added.

## Core adoption map

| GMP source/symbol | Disposition | Planned UnrealEvent destination | Required adaptation |
|---|---|---|---|
| `Plugins/GMP/Source/GMP/GMP/GMPFunction.h`: `FStorageEraseBase`, `TStorageErase`, `TAttachedCallableStore`, `TGMPFunction`, `TGMPWeakFunction` | Substantially derive the bounded callable-storage mechanics | `UnrealEventRuntime/Private/Core/UnrealEventCallable.h` | Rename all identities; keep SBO + one erased thunk pointer + weak UObject form; remove unrelated type-trait/debug compatibility layers; document inline size/alignment and allocation counters. |
| `Plugins/GMP/Source/GMP/GMP/GMPKey.h`: `FGMPListenOptions`, `Order`, `Times`, `FGMPKey` | Port behavior, not the process-wide key encoding | `UnrealEventTypes.h`, slot id/generation allocation, and Store registration | Keep Order/Times semantics. Replace global `NextGMPKey`/bit-packed order identity with subsystem-owned slot id plus generation and an independent registration sequence, so stale and foreign-GI handles reject safely. |
| `Plugins/GMP/Source/GMP/GMP/GMPSignalsImpl.h`: `FSigElm`, `FSignalStore`, raw matched iteration | Substantially derive the signal element/store and raw-fire mechanics | `UnrealEventRuntime/Private/Core/UnrealEventSignalStore.h` | Replace GMP key/source/connection types with UnrealEvent handle/scope/source metadata; keep preordered slots, weak listener state, inline snapshot storage, generation validation, and raw borrowed-address ABI. |
| `Plugins/GMP/Source/GMP/Private/GMPSignalsImpl.cpp` and `Plugins/GMP/Source/GMP/GMP/GMPSignals.inl` | Port only storage lifecycle, connect/disconnect, compaction, and out-of-line fire pieces required by v1 | `UnrealEventSignalStore.cpp` and optional private `.inl` | Delete Store/Once/Request/collection/RPC behavior; preserve recursive mutation safety; retain Shipping-safe checks; expose counters for tests. |
| `Plugins/GMP/Source/GMP/GMP/GMPMessageKey.h` | Reference the canonical literal/Key identity concept | `UnrealEventConfiguredRegistry.*` | Do not expose `MSGKEY` or `UNREAL_EVENT_KEY`; public callers continue to pass FName. Configuration supplies the predeclared Key set. |
| `Plugins/GMP/Source/GMP/GMP/GMPMessageKeySlot.h`, `Plugins/GMP/Source/GMP/Private/GMPMessageKey.cpp` | Adapt resolve-once/static-slot concepts | `UnrealEventConfiguredRegistry.*` and Hub router | Replace process-unique static `FSignalStore*` with immutable Key metadata and dense `SymbolIndex`; do not keep raw Store pointers across GameInstances. |
| `Plugins/GMP/Source/GMP/GMP/GMPHub.h`, `Plugins/GMP/Source/GMP/Private/GMPHub.cpp` | Port only the direct signal/connect/fire/unbind Hub slice | `UnrealEventHub.*` | One Hub per `UUnrealEventSubsystem`; configured array plus dynamic map; Game/World/Object stages; no process singleton, Meta, holder, request, response, RPC, tracing graph, or Blueprint surface. |
| `Plugins/GMP/Source/GMP/GMP/GMPHubOpt.h` | Adapt the direct/inline fire selection | private Runtime templates/inlines | Direct configured route is always built. Optional inline fire is enabled only for supported Monolithic targets; modular behavior uses the same semantics out of line. |
| `Plugins/GMP/Source/GMP/GMP/GMPMacros.h` | Reference and collapse the capability switches | Runtime private build definitions | Direct signal is architectural, not optional. Order and compact signature safety are always on. Verbose diagnostics are non-Shipping. Inline dispatch defaults off. Do not copy the full macro matrix. |
| `Plugins/GMP/Source/GMP/GMP/GMPUtils.h` and `Plugins/GMP/Source/GMP/Private/GMPUtils.cpp` | Reference only bounded type/address helpers that prove useful | `UnrealEventSignature.*`, `UnrealEventRuntimeBridge.*` | Reimplement against the explicit UnrealEvent type matrix; do not import general GMP utilities or Meta dependencies. |
| `Plugins/GMP/Source/GMP/Private/GMPTests.cpp`: direct/static benchmarks and slot tests | Port test intent, not production dependencies | `UnrealEventTest/Private/Performance`, Core tests, and transient GMP comparison host | The normal test module compares native delegate/configured/dynamic routes without GMP. The project-owned performance suite separately stages the verified pinned plugin into a transient comparison host for the GMP direct control. |

## AngelScript reference-only map

| GMP source/symbol | Disposition | Planned UnrealEvent destination | Required adaptation |
|---|---|---|---|
| `Plugins/GMP/Source/GMP/Shared/AngelScriptSupport.h`: `FGMPTypedTagCtx`, bind-time `CachedStore`, generic notify/listen adapters | Reference design and selectively reimplement | `UnrealEventAngelscript/Private/UnrealEventConfiguredBindings.*` | Cache `SymbolIndex`, not a process-global Store pointer; pre-resolve canonical types/property operations; do not repeat `PropertyFromString` per send. |
| `Plugins/GMP/Source/GMP/Shared/AngelScriptSupport.h`: `FAngelscriptPreprocessor::OnPostProcessCode` rewrite | Reference/reimplement | `UnrealEventAngelscript/Private/UnrealEventPreprocessor.*` | Rewrite only valid configured FName literals; preserve public source spelling; use reserved hashed adapter names; leave variable/unconfigured Keys generic. |
| `Plugins/GMP/Source/GMP/Shared/AngelScriptSupport.h`: named method/JIT/ProcessEvent support | Reference/reimplement using maintained fork APIs | `UnrealEventAngelscriptInvoker.*`, `UnrealEventAngelscriptExtension.*` | Weak Listener + Method identity; engine/reload generation cache; exact `JitFunction_ParmsEntry`; reflected fallback; no stale function pointer. |
| `Plugins/GMP/Source/GMPEditor/GMPEditor/Private/GMPAngelScriptCodeGen.*` | Reference typed declaration construction only | no generated source destination | UnrealEvent dynamically registers configured typed bindings in memory. It does not emit `GMPMessages.as`, `.gen.h`, or `.gen.cpp`. |

## Explicitly rejected GMP areas

| Area | Reason |
|---|---|
| `GMPMeta.h/.cpp`, `DefaultGMPMeta.ini` | Replaced by `UUnrealEventSettings` and `DefaultUnrealEvent.ini`; GMP Meta and response types are outside the product boundary. |
| MessageTags/GameplayTags managers and editor | Keys remain plain FName; no tag tree, redirects, restricted tags, or tag editor. |
| K2/Blueprint libraries and nodes | V1 exposes C++ and AngelScript only. |
| Message holder, Store/Once, collections | V1 dispatch is synchronous and non-owning; no payload survives Send. |
| Request/response and RPC | Outside v1 semantics and would expand state/lifetime/network contracts. |
| slua, UnLua, Puerts, C#, Lua/JS/C# codegen | UnrealEvent supports only the maintained AngelScript plugin. |
| Call-site tracing/debug graph | Not part of the bounded Hub core; only counters/diagnostics needed for tests are retained. |
| Process-global static per-Key `FSignalStore` | Violates per-GameInstance/multi-PIE isolation; replaced by metadata-only registry plus per-GI configured Store arrays. |

## Macro disposition

### How GMP's pre-created symbol optimization is translated

The specific upstream fast path is not merely an FName cache. `GMPMessageKey.h` turns `MSGKEY("...")` into `TMSGKEYTyped<C_STRING_TYPE(...)>`. `GMPMessageKeySlot.h` then maps that compile-time Key type through `GetKeySlot<KeyT>()`: modular/editor builds use an `FStaticSignalSlot` that lazily resolves a pointer, while supported Monolithic builds instantiate `FStaticSlotHolder<KeyT>` with a process-unique `FSignalStore`. `GMPHubOpt.h::SendObjectMessageDirect` reads that Store pointer, builds static type names, and fires the raw address array without a general Key-to-Store lookup.

UnrealEvent keeps the useful two-stage idea but changes both identity and ownership:

1. `DefaultUnrealEvent.ini` is the declaration site instead of `MSGKEY("...")`.
2. Startup creates one canonical FName, signature/fingerprint, and dense SymbolIndex for every valid configured entry.
3. Each GameInstance pre-creates `ConfiguredStores[SymbolIndex]`; no process-unique Store pointer exists.
4. Ordinary C++/generic-AS FName calls probe the immutable open-addressed router, then index the current subsystem array. This is the cost of retaining the required simple API and multi-PIE safety.
5. A configured AS literal is rewritten to an in-memory typed adapter whose user data already contains SymbolIndex, so its warm path skips the FName probe just as GMP's typed Key slot skips general lookup.
6. The acceptance benchmark measures the ordinary public configured FName route, not a private SymbolIndex shortcut, so the automatic selection overhead cannot be hidden.

There is intentionally no public macro-equivalent. The optimization is driven by project configuration and selected behind the ordinary event name.

| GMP capability | UnrealEvent decision |
|---|---|
| `GMP_IF_CONSTEXPR`, attribute, stringification, warning-suppression helpers | Do not port as a macro layer. Use current C++/UE language and platform facilities locally where needed. |
| `GMP_FUNCTION_PREDEFINED_INLINE_SIZE` / `GMP_FUNCTION_PREDEFINED_ALIGN_SIZE` | Replace with private `constexpr` callable layout values selected and static-asserted by UnrealEvent. Start from upstream 32-byte/16-byte evidence, then validate common adapters and target ABIs in tests. No public build switch. |
| `GMP_FUNCTION_USING_TAGGED_INLNE_SIZE` | Retain the proven inline-versus-heap state concept only if the port audit confirms it is safe on supported UE targets; otherwise use an explicit private discriminator. Either representation must pass move/destruction/alignment/allocation tests. |
| `GMP_FUNCTION_DEBUGVIEW`, `GMP_DEBUG_SIGNAL`, `GMP_ENABLE_DEBUGVIEW`, logging/trace macros | Do not port. Use UnrealEvent log category and test-only counters; no hot-path debug-view fields or call-site trace graph. |
| `SLOT_STORAGE_INLINE_SIZE`, `GMP_ALWAYS_USE_INLINE_SIGNAL`, `GMP_SIG_BASE_ALIGN` | Collapse into private slot/callable layout constants with `alignof`/`sizeof` static assertions and allocation tests. Do not expose tuning macros. |
| `GMP_WITH_DIRECT_SIGNAL` | Always represented by the configured route; no public build switch. |
| `GMP_WITH_STATIC_STORE` | Do not copy global Store ownership. Pre-create one Store per configured Key per GameInstance. |
| `GMP_STATIC_STORE_MONOLITHIC` | Replace with unconditional per-GI configured Store creation. Monolithic affects only optional code inlining, never whether the configured route exists. |
| `GMP_WITH_INLINE_FIRE` | Private optional `UNREALEVENT_WITH_INLINE_DISPATCH`, default `0`, effective only in Monolithic builds. |
| `GMP_WITH_INLINE_FIRE_ENABLED` | Derived privately from the UnrealEvent inline option and supported Monolithic target; it never changes semantics or safety. |
| `GMP_SIGNAL_BACKEND_FLEX` / `Z_GMP_PROXY_APPLY` | Do not port the backend-switch matrix. Use one explicit raw borrowed-address ABI and direct native/AS adapter thunks. |
| `GMP_SIGNAL_COMPATIBLE_WITH_BASEDELEGATE` | Rejected. UnrealEvent owns a purpose-built Store layout instead of inheriting UE delegate implementation details. |
| `GMP_WITH_SIGNAL_ORDER` | Always on because Order is public behavior. |
| `GMP_WITH_DYNAMIC_CALL_CHECK` / `GMP_WITH_DYNAMIC_TYPE_CHECK` | Split diagnostics from safety: compact signature validation always on; verbose names only Development/Editor. |
| `GMP_WITH_TYPENAME` / `GMP_WITH_TYPE_INFO_EXTENSION` | No optional general type-info extension. Canonical compact descriptors always exist; readable reflected names are Development/Editor diagnostics only. |
| `GMP_FORCE_DOUBLE_PROPERTY` | Rejected. Float and Double are distinct configured kinds and generic AS marshalling follows the actual maintained binding type without coercion. |
| `GMP_WITH_NULL_PROPERTY` | Rejected as permissive behavior. A missing/unsupported reflected property or layout plan fails closed. |
| `GMP_WITH_EXACT_OBJECT_TYPE` | Replace with exact declared canonical type identity. Runtime UObject values may be instances of the declared class contract, but no implicit change of the event's declared type is allowed. |
| `GMP_WITH_STATIC_MSGKEY` | No public literal macro. Configured names are frozen to runtime metadata/indexes; Shipping may omit verbose call-site text. |
| `GMP_WITH_NO_CLASS_CHECK` | Rejected; exact configured/reflected type checks remain fail-closed in Shipping. |
| `GMP_ENABLE_STATIC_DISCONNECT` | Rejected; UnrealEvent handle id/generation provides exact removal without a process-global connection pool. |
| `GMP_MULTIWORLD_SUPPORT` | Replaced by mandatory per-GI ownership and explicit World/Object scope stages. |
| `GMP_WITH_MSG_HOLDER` | Rejected with Store/Once/collection features. |
| `GMP_MSG_HOLDER_DEFAULT_INLINE_SIZE` / `GMP_WITH_SINGLE_STRUCT_STORE` | Rejected with retained-message storage; synchronous Event sends retain no payload. |
| `GMP_SCRIPTSTRUCT`, `GMP_USE_NEW_PROP_FROM_STRING`, `GMP_DELEGATE_INVOKABLE` | Do not port as feature switches. The explicit type matrix governs USTRUCT support, configured warm paths never call `PropertyFromString`, and named `UFUNCTION` callbacks use the explicit JIT/ProcessEvent contract rather than arbitrary delegate invocation. |
| `Z_GMP_OBJECT_NAME` / `NAME_GMP_TObjectPtr` | Do not port. Use current UE UObject/TObjectPtr reflection conventions directly and keep the Runtime bridge independent of this alias. |
