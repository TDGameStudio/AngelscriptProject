# Fresh `FAngelscriptEngine` Reconstruction Boundary

Date: 2026-08-10

This appendix fixes the meaning of "restore a fresh Engine" after the V3.4/V3.5
narrow executable proof. Cache V2 is a cold-start compilation artifact cache,
not a serialized `FAngelscriptEngine`, `asCScriptEngine`, UObject heap or process
memory snapshot. Every process creates and initializes a fresh Engine. A cache
hit reconstructs only the validated pointer-free script projection inside that
fresh current-process authority.

## 1. Mandatory current-process initialization

The following state is always rebuilt by normal Runtime/Editor initialization
and MUST NOT be copied from a previous process:

- `FAngelscriptEngine` and its owned AngelScript engine/module/context objects;
- C++ binding registration, reflected Unreal type/function/property discovery,
  engine properties, compile settings and current environment catalog;
- UObject/UClass/UStruct/UFunction/FProperty instances and all native pointers;
- current native function addresses, JIT provider instances and route snapshots;
- numeric AngelScript FunctionIds/TypeIds and all tables indexed by those ids;
- execution/thread contexts, object instances, GC state, delegates, locks and
  subsystem/editor lifecycle state;
- compiler/builder/parser scratch, AST nodes and HotReload transient queues; and
- debugger sessions, breakpoint runtime state and live call stacks.

Persisting any pointer, native address, numeric id or live object bit is a format
violation. Equality of stable identities never permits copying those values.

## 2. Cache-owned durable projection

Cache V2 may persist the bounded, canonical, pointer-free material required to
reconstruct script state:

- SourceIndex and direct/preprocess dependency candidates;
- ModuleInterface declarations/imports and public ABI;
- TypeSchema semantic/layout/reflection descriptions;
- ModuleState global storage, hard values and initializer descriptions;
- FunctionBody complete VM artifacts and typed actual dependencies;
- DebugSidecar source/line payloads;
- ModuleSnapshot/Manifest/Pack ownership and reachability; and
- stable module/type/function/global/property/import keys plus Compatibility,
  Context and ArtifactProfile identities.

The persisted records are construction inputs. They are not the live containers
or indexes held by `FAngelscriptEngine`.

## 2.1 `FAngelscriptEngine` state that a fresh process still owns

The distinction is not merely "cached bytes versus a new FunctionId". The live
wrapper owns several families of state which must exist before, during or after
record restoration:

| Live state family | Current examples | Reconstruction authority |
|---|---|---|
| AS engine configuration | `asCScriptEngine`, engine properties, message/context callbacks, game-thread TLD | normal fresh-engine initialization only |
| UE/native binding surface | `TypeDatabase`, `BindState`, `BindDatabase`, `BlueprintEventSignatureRegistry`, to-string registrations, bound enum lookups | rerun current binary/UE bindings; never trust a previous-process pointer |
| live script ownership | `ActiveModules`, `ModulesByScriptModule`, active class/enum/delegate indexes and module descriptors | rebuild while validated modules are staged and atomically activated |
| current route/index tables | stable function key to current `asIScriptFunction*`, numeric FunctionId and StaticJIT/VM route; stable type/property/global/import lookups | derive from newly created current-engine objects |
| UE reflection bridge | current `UClass`/`UStruct`/`UEnum`/`UFunction`/`FProperty`, ClassGenerator results and script-object back-pointers | reconstruct against the current UObject process after AS types exist |
| executable module state | imports, global storage, hard values, initializer order, VFT/base/behavior links and JIT attachment | rebuild from accepted records inside the fresh AS module, then validate |
| source/dependency state | source roots, reverse dependency graph, HotReload content baseline and file-to-module indexes | derive from current source projection plus the accepted generation |
| transient services | contexts/pools, locks, diagnostics, debugger/coverage sessions, delegates, HotReload queues and world context | normal lifecycle only; not cache material |

Consequently, a cache hit does **not** bypass `PreInitialize_GameThread()`, the
current engine-property setup, binding registration or the creation of these
owned databases. It bypasses the admitted script preprocessing/parsing/compiler
work, then supplies validated inputs to reconstruct the script-owned rows in the
fresh live state.

## 3. Derived current-process projection

After records are accepted, the restore path must rebuild current-process maps
and plugin-side databases rather than assume bytecode loading completed them:

```text
validated stable record
        |
        +--> fresh asIScriptModule / type / function objects
        +--> StableFunctionKey -> current numeric FunctionId
        +--> StableFunctionKey -> current StaticJIT/VM route
        +--> stable type/property keys -> current AS and Unreal objects
        +--> current module/source/debug indexes
        +--> current reverse dependency graph and HotReload baseline
        +--> ClassGenerator inputs and current reflection projection
```

The exact retained Runtime containers remain an implementation concern, but
their semantic state must be rebuilt from validated records or normal current
initialization. Cache format fields must not mirror container layouts merely to
make restoration appear direct.

The activation order is therefore:

```text
create fresh FAngelscriptEngine/asCScriptEngine
        |
        v
configure engine + register current UE/C++ bindings
        |
        v
open/validate cache generation against current authorities
        |
        v
stage fresh AS modules/types/functions/globals from accepted records
        |
        v
resolve imports/base links/VFT/initializers and PrepareEngine
        |
        v
run ClassGenerator against current UObject reflection
        |
        v
publish ActiveModules + reverse indexes + stable live routes atomically
        |
        v
create/enable normal contexts, debugger, HotReload and editor lifecycle
```

No stage may copy a previous `FAngelscriptEngine` field wholesale. A useful
cache must instead contain enough semantic material for the fresh Engine to
rebuild the script-derived stages without running their original compiler work.

## 4. Stable FunctionId/StaticJIT rebinding

Numeric FunctionIds are intentionally session-local:

```text
previous process: StableFunctionKey K -> FunctionId 172
current process:  StableFunctionKey K -> FunctionId 241
```

The current Engine creates `241`, then rebuilds the stable route:

```text
StableFunctionKey K
        +--> current FunctionId 241
        +--> current compatible StaticJIT native entry, when present
        `--> current VM entry otherwise
```

Cache V2 never restores `172`. StaticJIT provider absence, Live Coding address
changes or a native artifact mismatch may change the per-function route without
invalidating a valid VM cache artifact; V6 owns the immutable current route
snapshot and the sibling StaticJIT change owns external native transport.

## 5. Required restoration evidence

V3.4/V3.5 proved only a narrow enum plus self-contained global-function path:
fresh engines received new numeric ids, executed restored bytecode and an exact
unchanged second launch made zero preprocess/parse/function-compiler calls. This
does not prove full `FAngelscriptEngine` reconstruction.

The present Runtime proof creates a staging module, restores one enum and one
self-contained function, publishes its current numeric-id route, calls
`PrepareEngine()`, initializes module globals, runs `FAngelscriptClassGenerator`
and swaps the module into `ActiveModules`. Its own success result reports "one
enum and one current-engine function route". This is deliberate evidence for
the mechanism, not evidence that every intermediate `FAngelscriptEngine` state
family in the table above is already reconstructed.

Completion requires explicit coverage for at least:

| State family | Durable record authority | Current-process reconstruction evidence |
|---|---|---|
| module/public declarations/imports | ModuleInterface | fresh module objects and resolved imports |
| class/struct/interface/enum/delegate/typedef | TypeSchema | current AS types plus ClassGenerator/reflection projection |
| properties/inheritance/VFT/behaviors | TypeSchema | current layout/slot/base links and Unreal reflection |
| globals/constants/initializers | ModuleState | fresh storage, deterministic init order, rollback/cleanup |
| ordinary/generated/factory/lambda functions | FunctionBody | complete VM state and new FunctionIds in a second Engine |
| source/debug navigation | SourceIndex + DebugSidecar | current debugger/source databases without old pointers |
| StaticJIT routing | stable artifact tuple | current native address or VM fallback per function |
| Editor HotReload baseline | complete generation | body/structural reload and reinstancing from restored state |

V5 owns complete per-function VM restoration across every admitted invocation
family. V6 owns service/lifecycle integration, current stable-id maps,
ClassGenerator/Editor/PIE behavior and StaticJIT route publication. V7 owns real
PIE and Development/Shipping multi-launch acceptance. None may cite the V3.4
narrow function result as proof of the broader rows.

## 6. Fail-closed rule

If a required plugin-side or VM-side state item cannot be reconstructed exactly,
the affected record/module is a cache miss and the existing authoritative clean
compile path runs. A partially loaded module must never become active. The last
good generation remains readable until a complete candidate has been validated,
attached and atomically activated.
