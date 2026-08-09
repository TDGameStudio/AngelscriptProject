# Direct Manual Binding Callback Impact Matrix

## Summary

The implementation is broad by call-site count but deliberately small in runtime shape. One process-wide callback collection remains. `UAngelscriptSubsystem` loads generated modules and finalizes that collection once; each `FAngelscriptEngine` then replays it directly through an explicit `FAngelscriptBinds` context.

There is no subsystem binding cache, expanded registration data, public Registry, central manifest, dependency graph, or runtime disable surface. NativeModuleFunctionAddress retains its current POD/`IModularFeatures` dynamic lifecycle as the only documented exception.

## Subsystem Matrix

| Area | Required change | Main risk | Verification |
|---|---|---|---|
| Static discovery | Replace `FAngelscriptBinds::FBind`/`TFunction<void()>` records with `FAngelscriptBind` plus non-capturing `void(*)(FAngelscriptBinds&)` | Static construction accidentally touches runtime state | Local collection tests and construction interception |
| Global collection | Validate/sort the existing array in place and permanently seal it | Static/module order changes execution | Permutation tests with identical stable order |
| Subsystem startup | Load `BindModules.Cache` modules before finalization; store no binding data | Generated providers missing at seal | Module-load-before-seal lifecycle tests |
| No-`GEngine` bootstrap | Reuse the same idempotent finalizer | Two process collections or inconsistent order | Compatibility initialization test |
| Phases | Require one of seven `EAngelscriptBindPhase` values per callback | Hidden `EOrder` dependency | Complete order-to-phase migration table |
| Engine execution | Iterate the sealed collection without copy/sort | Unsealed or late provider visibility | Execution guard and multi-engine tests |
| Explicit target | Route all mutable binding work through one `FAngelscriptBinds(Engine)` | Ambient/fallback state writes | Two-engine pointer/id/store isolation |
| Fluent traits | Return direct `FAngelscriptBoundFunction` / `FAngelscriptBoundProperty` | Trait mutates wrong result | Interleaved registration/trait tests |
| Hand-written callables | Move project-owned direct AS entries into bind-owned `_Functions.h/.cpp` and stable `FAngelscript<Name>Binds` functions | Source churn, invalid pointer signatures, or lost native forms | Source-layout guard, callable matrix, focused binding tests, and generated StaticJIT compile |
| Auxiliary work | Directly target engine-owned type/ToString/BindDB/interface stores | Cross-engine reuse of AS pointers | Recreation and teardown tests |
| Generated bindings | Emit direct callbacks in `GeneratedBindings` | UHT/Runtime/CodeGen divergence | Golden emitters plus runtime generated tests |
| Reflection/RPC | Execute reflection in `ReflectionBindings` and reflection-derived callable synthesis in `PostReflectionBindings`; preserve fallback routing | RPC bypassed through raw thunk or post-reflection work finalized too early | Phase-order, reflective fallback, and networking regression |
| Failure handling | Stop after first required registration failure and withhold publication | Partially initialized engine becomes visible | Per-phase injected failure tests |
| Diagnostics | Observe finalization plus per-engine provider/phase execution | Dump or stats invoke callbacks | Observation/CSV repeated-read tests |
| Memory/performance | Retain only compact callback records; remove per-engine array copy/sort | Unexpected callback replay cost | Startup timing and allocation comparison |

## Implemented Source Ownership

The implementation is concentrated in the plugin submodules, with OpenSpec and developer documentation retained in the parent repository.

### Runtime binding core

Implemented in the existing Runtime Core binding files, with focused helpers split only where that improves ownership:

- `FAngelscriptBind` file-static registration declaration;
- `EAngelscriptBindPhase`;
- internal compact record and single process collection;
- validate/sort/seal and direct execution;
- `FAngelscriptBoundFunction` / `FAngelscriptBoundProperty`;
- explicit-target `FAngelscriptBinds` integration;
- provider/phase failure and timing observations.

No public Registry, provider registration handle, collection lease, expanded operation record, or subsystem-owned bind container was introduced.

### Subsystem and engine integration

- `UAngelscriptSubsystem`: move generated module loading/finalization before primary engine creation; do not add a binding member.
- `FAngelscriptRuntimeModule`: use the same idempotent finalization for the supported no-`GEngine` compatibility path.
- `FAngelscriptEngine`: construct explicit `FAngelscriptBinds`, execute the sealed callbacks, and gate publication on success.
- `FAngelscriptTypeDatabase`, `FAngelscriptBindDatabase`, ToString, interface signatures, StaticJIT/native metadata, and related helpers: add/use explicit instance targets and remove binding-path fallback writes.
- `Dump/`: observe collection metadata and per-engine results without executing providers.

### Generated integrations

- `Source/AngelscriptUHTTool/AngelscriptFunctionBindingEmitters.cs`: emit `FAngelscriptBind` with `GeneratedBindings` for RuntimeLinked shards; keep NativeModuleFunctionAddress target shards Runtime-independent.
- `Source/AngelscriptRuntime/FunctionBinding/`: consume RuntimeLinked tables during direct callback execution; adapt the NativeModuleFunctionAddress consumer to explicit engine access while preserving its POD/`IModularFeatures` arrival/unload bridge.
- Editor CodeGen templates: emit file-static callbacks and leave generated `StartupModule()` free of binding submission.
- Reflective fallback/RPC: retain safe routing in `ReflectionBindings`.

### Provider consumers

- Runtime `Bind_*.cpp`: migrate each logical provider, split mixed phase responsibilities, and keep only registration/registration-time logic in the provider source.
- Runtime binds with project-owned callable implementations: add `Bind_<Name>_Functions.h/.cpp`, declare one primary `FAngelscript<Name>Binds` owner, put non-template bodies in `.cpp`, and leave required template definitions in the header. Pointer-only binds do not gain empty pairs.
- Existing callable owner names such as `FAngelscriptActorBinds`, `FAngelscriptMapBinds`, `FAngelscriptSetBinds`, and `FAngelscriptOptionalBinds`: preserve established names unless ownership must split across registration files; do not mass-rename for stem normalization.
- `AngelscriptGameplayTags`: migrate runtime providers and project-owned direct callables without module-startup submission.
- `AngelscriptGAS`: migrate all binding providers and project-owned direct callables to the same direct callback/named-owner form.
- Editor/runtime helper providers outside `Binds/`: migrate by symbol inventory rather than filename assumptions.
- UHT-generated binding shards: keep their existing named thunks; they adopt file-static providers but do not receive hand-written `_Functions` companions.

### Tests

Implemented coverage includes:

- local process-collection append/sort/seal/late-rejection tests that never reset the production collection;
- subsystem module-load/finalize ordering and absence of subsystem binding storage;
- explicit-engine context and two-engine isolation;
- direct bound-function/property trait targeting;
- seven-phase ordering and every migrated non-default order;
- callable shape matrix proving lambda overload compatibility independently from production named-callable style;
- source-layout audit rejecting only inline lambdas directly supplied to production AS callable registration APIs, without rejecting type finders, local algorithms, or UE delegate/async callbacks;
- `FColor`/`FVector` reference families plus StaticJIT/native/trivial name, include, visibility, and generated-code compilation checks;
- auxiliary stores, ToString, BindDB, reflection, RPC, generated shards, GameplayTags, and GAS;
- fail-closed execution/publication;
- timing, state dump, startup allocation, and script-visible parity.

## Public API Impact

New or replacement author-facing types:

- `FAngelscriptBind` — file-static direct callback declaration.
- `EAngelscriptBindPhase` — required phase per callback.
- `FAngelscriptBinds` — explicit-engine direct binding facade, retaining the established name.
- `FAngelscriptBoundFunction` — short-lived fluent view of the exact registered function.
- `FAngelscriptBoundProperty` — short-lived fluent view of the exact registered property.

The completed authoring form requires no module manifest or `StartupModule()` submission. A file may contain multiple `FAngelscriptBind` values for separate phases.

Hand-written callable-owner types are implementation-facing rather than a new general Registry API. New former-lambda owners are module-internal by default. A callable retains or gains export visibility only when existing StaticJIT-generated code or another real cross-module consumer must include and link it. Supported DSL lambda overloads remain source-compatible even though production in-tree binds use named entry points.

Removed production APIs/concepts include:

- nested legacy `FAngelscriptBinds::FBind` constructors;
- `RegisterBinds`, callback-array copy/sort helpers, and legacy `CallBinds` overloads;
- `FAngelscriptBinds::EOrder`, integer order, and `Early` / `Normal` / `Late` offsets;
- `PreviouslyBoundFunction`, `PreviouslyBoundGlobalProperty`, getters/setters, and dependent helpers/macros;
- `UAngelscriptSettings::DisabledBindNames` and per-engine disabled collections;
- binding provider filters, aliases, dependency cascades, skip reasons, and related configuration/dumps;
- binding-specific modular-feature arrival/unload queues and late replay, except for the recorded NativeModuleFunctionAddress transport;
- module-owned binding submission and central manifests;
- any intermediate legacy/modern compile switch in the final state.

## Data and Configuration Impact

- The process collection schema is internal and not serialized.
- `Binds.Cache` semantics and format remain unchanged.
- No binding phase/order information enters `Binds.Cache`.
- Disabled-bind configuration and serialization are removed.
- A native provider change requires rebuild and restart after collection seal.
- Per-engine AS ids/pointers remain intentionally non-deterministic and are not parity artifacts.
- The global collection keeps only callback metadata; it does not retain declaration/callable/trait/reflection expansion data.
- Named callable extraction adds no per-function process metadata, per-call trace object, debug trampoline, or serialized schema.

## Compatibility / Explicit Non-Impact

The implementation must preserve:

- complete AngelScript declaration strings and script-visible names;
- member/free pointers, explicit overloads, macro wrappers, supported DSL lambdas, direct/generic calls, userdata, and call conventions;
- StaticJIT/native/trivial metadata and documentation/compiler traits;
- reflection and RPC/Net fallback routing;
- `Binds.Cache` behavior;
- multi-engine state isolation and teardown;
- optional-plugin functionality;
- generated binding statistics and signature policy;
- `FAngelscriptNativeModuleFunctionBinding` and view layout unless an explicit implementation diff requires the layout-version bump.

Production source style changes without changing the callable API: project-owned direct AS entries become stable named functions. Type-finder captures, local algorithm lambdas, UE delegate/async callbacks, and generated UHT thunks are explicitly outside that source-layout rule.

The change does not alter the AngelScript parser, grammar, compiler, VM, Standalone host, host game module, or unrelated extension registry.

## Removal Readiness

Before deleting legacy concepts, implementation must prove zero production references to:

```text
FAngelscriptBinds::FBind
RegisterBinds
legacy CallBinds overloads
FAngelscriptBinds::EOrder
BindOrder
PreviouslyBoundFunction
PreviouslyBoundGlobalProperty
GetPreviousBind*
SetPreviousBind*
DeprecatePreviousBind
CompileOutPreviousBind*
DisabledBindNames
binding StartupModule submission
binding-specific late-arrival/unload replay outside the NativeModuleFunctionAddress exception
inline lambda passed directly to a production hand-written AS callable registration API
```

Generated source fixtures, optional plugins, docs, and test helpers are part of the removed-concept search. The callable-lambda guard is narrower: it covers production hand-written bind call sites but deliberately permits focused DSL compatibility fixtures and non-AS-entry auxiliary lambdas. Compatibility helpers may exist transiently during implementation commits but not in the completed target.
