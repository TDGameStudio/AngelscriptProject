# Design: Engine-free SDK compile and batch registration

Status: approved (user authorized Change creation 2026-09-11)

Change ID: `angelscript/refactor-sdk-compile-lifecycle`

## Why

`asCMetadataImage` was meant as a short-lived compile helper for C++ / ClassGen. It became a unique owner of live `asCTypeInfo` / `asCScriptFunction` / `asCGlobalProperty`, with a five-state lifecycle (`Building` → `Retired`) stored in `Engine.metadataImages`. Callers then Emit, `RegisterMetadataImage`, and `asLinkByteCodeImage` as three more rituals. `asCExecutableFunction` and `asCByteCodeImage` duplicated bytecode off the function object. The reconstructed SDK compile (`asCBuilder`) already does not need an Engine; the Image bag reintroduced Engine-shaped ownership anyway.

This Change retires that bag, keeps real types on a per-compile-unit set until one batch Engine registration, and hangs both bytecode layers on `asCScriptFunction`.

## Scope

In (SDK):

- Delete public `asCMetadataImage` (and Engine `metadataImages` / `RegisterMetadataImage` as the script-compile path).
- `asCBuilder` produces two products: `asCCompileOutput` and `asCModuleDefinitionSet`.
- Default `RunThrough` includes Emit (stable bytecode on each script function).
- Cross-unit DAG via non-owning `asCModuleDefinitionSet*`.
- `asCEngineCompileRegistration` Install + Link in one success after the whole DAG is compiled.
- Fold runtime bytecode onto `asCScriptFunction`; remove public `asCExecutableFunction` / `asCExecutableSnapshot` / `asCByteCodeImage`.
- Keep public `asCByteCodeEmitter`; `RunThrough` calls it.
- Rewrite Image-based NewVersion tests; comment Binding tests that fail solely because BindInfo still constructs Image.

Out:

- Binding Record / BindInfo Draft-Apply (may keep constructing Image until a later Change).
- Host `FAngelscriptEngine::CompileModules` Stage1–3 and ClassGen UClass materialize.
- Module-wave thread pool; `asSStableKey` rename; in-flight body replace while a Context is running.
- Symbolic bytecode codec / persist of a whole image.

## Approaches

Forced by the grill: Image cannot stay as Engine-lifetime owner, and compile must not require Engine. The only remaining shape is: Builder owns a takeable definition set, ClassGen reads a separate description bag, Engine receives the forest once.

Rejected: keep Image internally; register each unit before the next compiles; kitchen-sink `asCCompileOutput` that holds TypeInfo or bytecode.

## Architecture

```text
asCBuilder (no Engine)
 ├─ asCCompilationSession                 // AST; internal after Emit
 ├─ asCByteCodeEmitter::Emit               // public; also called from RunThrough
 ├─ asCCompileOutput
 │    ├─ diagnostics
 │    └─ asCDefinitionCompileOutput         // FAngelscriptModuleDesc / ClassDesc
 └─ TUniquePtr<asCModuleDefinitionSet>
      ├─ asCTypeInfo* / asCScriptFunction* / asCGlobalProperty*
      ├─ Function.stable bytecode
      └─ immutable after successful RunThrough

caller holds UniquePtr list (the DAG)
 └─ later Builder.Dependencies = { earlier Set* }    // non-owning

asCEngineCompileRegistration(Engine, UniquePtr Sets)
 ├─ Install  // Engine owns the objects; Type->engine; TypeId assigned
 └─ Link     // only writer of Function.runtime bytecode
      └─ Prepare reads Function.runtime; does not generate
```

`asCDefinitionConsumer` stays an internal Builder step that fills the set. `asSBuilderStageResult` remains dump-only.

### `asCModuleDefinitionSet`

One compile unit’s unique owner of real TypeInfo / Function / Global until Registration. Not `asCModule`. Not ClassGen descriptions. No `BoundTypeIds`, Attached, or Retired. Destroying the set without Registration deletes the objects. `TakeModuleDefinitionSet()` moves the UniquePtr off the Builder.

### Two bytecode layers

```text
asCScriptFunction
 ├─ declaration (signature, asSStableKey)
 ├─ stable bytecode     // Emit; Engine-free
 └─ runtime bytecode    // Registration.Link only; VM runs this
```

Native `asFUNC_SYSTEM`: empty stable body; runtime is `sysFuncIntf` (bind later, out of this Change).

### Compile vs Engine

Type creation happens in Builder. `GetEngine()` is null and `GetTypeId()` is -1 until Install. Full compile never puts types into an Engine between units. Independent modules may compile as separate Builders; the SDK does not schedule a module thread pool. Body analysis may still use `WorkerCount` threads inside one session.

Cross-unit cycles are rejected (same rule as Frozen Image dependencies). Mutual types must share one snapshot.

## Data flow

```text
1. asCBuilder(Snapshot, Diagnostics, Options).RunThrough()  // through Emit
2. Get/TakeCompileOutput()     // ClassGen / diagnostics; ScriptType empty
3. TakeModuleDefinitionSet()   // caller keeps UniquePtr
4. Next units: Options.Dependencies = previous sets
5. After the DAG: Registration.Install+Link the UniquePtr list
6. VM Prepare → Function.runtime bytecode
```

## Vocabulary and naming

| Name | Role |
| --- | --- |
| `angelscript/refactor-sdk-compile-lifecycle` | This Change |
| `asCModuleDefinitionSet` | Per-unit TypeInfo/Function owner until batch register |
| `asCCompileOutput` | External bag: diagnostics + `asCDefinitionCompileOutput` |
| `asCDefinitionCompileOutput` | Reuses `FAngelscriptModuleDesc` / `ClassDesc` |
| `asCEngineCompileRegistration` | One Engine Install+Link |
| `TakeModuleDefinitionSet` | Move UniquePtr off Builder |
| `asCByteCodeEmitter` | Public Emit API; also used by RunThrough |
| `asSStableKey` | Unchanged this Change |

Deleted as public types: `asCMetadataImage`, `asCByteCodeImage`, `asCExecutableFunction`, `asCExecutableSnapshot`.

## Error handling and edges

- Failed `RunThrough`: no Take of a usable set; Builder diagnostics in `asCCompileOutput`.
- Depending on a still-mutable set is invalid; only a successfully finished set may appear in `Dependencies`.
- Registration is all-or-nothing for the submitted list: missing declaration, layout mismatch, or Link failure publishes no script functions as callable.
- `Prepare` of a script function without runtime bytecode returns `asNO_FUNCTION`.
- Engine builtins (`$obj` / `$func`) are created on Engine construction without Image.
- BindInfo may still create Image until a later Change; failing bind tests may be commented, not rewritten here.

## Verification

NewVersion tests that treat Image as the product (`MetadataImageTests`, `DefinitionConsumerTests`, `EngineRegistrationTests`, `TypeOwnershipImageTests`, `VMByteCodeImageTests`, `VMLinkingTests`, and Image fixtures) move to Builder + DefinitionSet + Registration. Prove: compile two acyclic units without an Engine; second unit resolves the first’s types; one Registration makes both executable; `Prepare` before Registration fails; destroying a Taken set without register deletes TypeInfo.

Do not require host `CompileModules`, UE Automation, or Binding GREEN in this Change.

## Self-review

- No placeholders. Binding Image rewrite is excluded, not TBD.
- One Change: SDK compile products and registration path. Host ClassGen wiring is a later consumer.
- Current spec `runtime/type-registry` still says Image must not retain TypeInfo; this Change’s spec delta must replace that script-compile contract with DefinitionSet → Engine transfer, and leave BindInfo publication wording for the binding Change.
