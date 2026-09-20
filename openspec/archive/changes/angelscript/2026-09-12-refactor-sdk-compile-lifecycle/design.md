# Design: Engine-free SDK compile and batch registration

Status: approved (user authorized Change creation 2026-09-11)

Change ID: `angelscript/refactor-sdk-compile-lifecycle`

## Why

`asCMetadataImage` was meant as a short-lived compile helper. It became the unique owner of live `asCTypeInfo` / `asCScriptFunction` / `asCGlobalProperty`, with a five-state Engine lifecycle (`Building` → `Retired`) in `Engine.metadataImages`. Callers then Emit, `RegisterMetadataImage`, and `asLinkByteCodeImage` as extra rituals. `asCExecutableFunction` and `asCByteCodeImage` duplicated bytecode off the function. Snapshot `asCBuilder` already compiles without an Engine; the Image bag reintroduced Engine-shaped ownership.

This Change makes the script-compile products a takeable per-unit definition set and a separate ClassGen bag, hangs both bytecode layers on `asCScriptFunction`, and performs one Engine Install+Link after the compile DAG.

## Scope

In (SDK script compile):

- `asCBuilder` produces `asCCompileOutput` and `asCModuleDefinitionSet`. No public Image on that path.
- Default `RunThrough` includes Emit (stable bytecode on each script function).
- Cross-unit DAG via non-owning `asCModuleDefinitionSet*`.
- `asCEngineCompileRegistration` Install+Link in one success after the DAG.
- Fold runtime bytecode onto `asCScriptFunction`; remove public `asCByteCodeImage`, `asCExecutableFunction`, and `asCExecutableSnapshot` from the script-compile and VM path.
- Keep public `asCByteCodeEmitter`; `RunThrough` also calls it.
- Rewrite Image-as-product NewVersion tests. Engine builtins `$obj` / `$func` are created on Engine construction without Image.
- Delete `asCMetadataImage`, `RegisterMetadataImage`, and Engine `metadataImages`. BindInfo owner-swaps onto DefinitionSet. Binding tests that fail because Image is gone are commented.

Out:

- Binding two-stage pipeline rewrite, and treating `Angelscript.UnitTest.RuntimeBindings` GREEN as a gate.
- Host `FAngelscriptEngine::CompileModules` Stage1–3 and ClassGen UClass materialize.
- Module-wave thread pool; `asSStableKey` rename; in-flight body replace; a replacement bytecode persist/codec.

## Binding after Image deletion

This Change deletes `asCMetadataImage`, Engine `metadataImages`, and `RegisterMetadataImage`. Script compile and BindInfo Draft/Apply uniquely own TypeInfo on `asCModuleDefinitionSet` until `asCEngineCompileRegistration`. That BindInfo edit is an owner swap only: Draft holds a UniquePtr set instead of Image, and Apply Installs through Registration. It is not a Binding pipeline rewrite.

`asSBuilderOptions::HostImages` is removed. Frozen-host native graphs are Frozen DefinitionSets in `Options.Dependencies`.

Comment Binding `TEST_CLASS` files under `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/` (and TypeOwnership Materialize/Admission/SharedPublication methods) that fail to compile or fail solely because Image is gone. Wrap the class in `#if 0` with the one-line reason `MetadataImage retired; Binding GREEN is a later Binding Change.` Do not delete those files. Do not treat Binding GREEN as a gate.

`TakeDefinitions()` is already gone (task 5.1). Tasks 6.1–6.2 finish the type deletion the draft required.

## Architecture

```text
asCBuilder (no Engine)
 ├─ asCCompilationSession
 ├─ asCByteCodeEmitter::Emit
 ├─ asCCompileOutput
 │    ├─ diagnostics
 │    └─ asCDefinitionCompileOutput   // FAngelscriptModuleDesc / ClassDesc
 └─ TUniquePtr<asCModuleDefinitionSet>
      ├─ TypeInfo / Function / Global
      ├─ Function.stable bytecode
      └─ immutable after successful RunThrough

asCEngineCompileRegistration(Engine)
 └─ Register(TArray<TUniquePtr<asCModuleDefinitionSet>>)
      ├─ Install    // Engine owns objects; Type->engine; TypeId assigned
      └─ Link       // only writer of Function.runtime bytecode
           └─ Prepare reads Function.runtime; does not generate
```

`asCDefinitionConsumer` stays an internal Builder step that fills the set. `asSBuilderStageResult` remains dump-only. Default `RunThrough` stop is `asEBuilderStage::ByteCodeEmitted` (new enum value after `DefinitionsFrozen`). Stopping at `DefinitionsFrozen` remains legal and does not require stable bytecode.

### `asCModuleDefinitionSet`

One compile unit’s unique owner of TypeInfo / Function / Global until Registration. Not `asCModule`. Not ClassGen descriptions. No Image states Attached/Retired. Destroying the set without Registration deletes the objects. `TakeModuleDefinitionSet()` is `MoveTemp` of the Builder UniquePtr.

### Two bytecode layers

```text
asCScriptFunction
 ├─ declaration (asSStableKey, signature)
 ├─ stable bytecode     // Emit; Engine-free
 └─ runtime bytecode   // Registration.Link only; VM runs this
```

Native `asFUNC_SYSTEM`: empty stable body; runtime is `sysFuncIntf` (native bind later, out of this Change). `GetByteCode` remains the runtime stream. `GetStableByteCode` is the Emit product.

### Compile vs Engine

Type creation happens in Builder. `GetEngine()` is null and `GetTypeId()` is -1 until Install. Full compile never puts types into an Engine between units. Independent modules may compile as separate Builders; the SDK does not schedule a module thread pool. Body analysis may still use `WorkerCount` threads inside one session (`AnalyzeBodies` stride). `asCTypeContext` Intern is not multi-Builder-safe.

Cross-unit cycles are rejected. Mutual types must share one snapshot.

## Data flow

```text
1. asCBuilder(Snapshot, Diagnostics, Options).RunThrough()  // default through Emit
2. Get/TakeCompileOutput()      // ClassGen / diagnostics; ScriptType empty
3. TakeModuleDefinitionSet()    // caller keeps UniquePtr
4. Next units: Options.Dependencies = previous sets
5. Registration.Register the UniquePtr list
6. VM Prepare → Function.runtime bytecode
```

## Error handling

- Failed `RunThrough`: no Take of a usable set; diagnostics in `asCCompileOutput`.
- Depending on a still-mutable set is invalid.
- Registration of the submitted list is all-or-nothing: any Install or Link failure publishes no script functions from that list as callable and does not leave a partial Engine mutation for those sets.
- `Prepare` of a script function without runtime bytecode returns `asNO_FUNCTION`.
- Install+Link are not separately observable public steps.

## Verification

Smallest proof is SDK NewVersion tests on Builder + DefinitionSet + Registration, not host `CompileModules`. Prove: two acyclic units without an Engine; second unit resolves the first’s types; one Registration makes both executable; `Prepare` before Registration fails; destroying a Taken set without register deletes TypeInfo; CompileOutput `ScriptType` stays null.

Do not require Binding GREEN. Comment Binding tests that fail to compile or fail solely because Image is gone.

## Self-review

- Binding two-stage rewrite is excluded. BindInfo owner-swap onto DefinitionSet is in scope so Image can be deleted.
- Persist/codec of `asCByteCodeImage` is removed from the script product contract; a later Change may persist Function-hung bytecode.
- `asCCompileOutput` is not `asCCompileOut` (`asECompileOutType` collision).
