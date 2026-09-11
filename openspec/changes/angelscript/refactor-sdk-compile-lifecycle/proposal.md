## Why

`asCMetadataImage` was meant as a short-lived compile helper. It became the unique owner of live TypeInfo/Function/Global, with a five-state Engine lifecycle in `metadataImages`. Callers then Emit, `RegisterMetadataImage`, and `asLinkByteCodeImage` as extra rituals. Script `asCBuilder` already compiles without an Engine. This Change makes that the product contract: a takeable per-unit definition set, a separate ClassGen bag, and one batch Engine Install+Link.

## What Changes

- Script compile (`asCBuilder`) produces `asCModuleDefinitionSet` and `asCCompileOutput`, not Image.
- Default `RunThrough` includes Emit; stable bytecode hangs on `asCScriptFunction`.
- Cross-unit DAG uses non-owning `asCModuleDefinitionSet*`.
- `asCEngineCompileRegistration` Install+Link after the whole DAG; runtime bytecode is written only then, on the same Function.
- Public `asCByteCodeImage`, `asCExecutableFunction`, and `asCExecutableSnapshot` are removed from the script-compile/VM path.
- `asCByteCodeEmitter` stays public; RunThrough also calls it.
- `asCDefinitionCompileOutput` reuses `FAngelscriptModuleDesc` / `ClassDesc`; `ScriptType` stays empty until host ClassGen.
- Image-product NewVersion tests move to the new products. Binding may keep constructing Image; failing bind tests may be commented. The Image type is not deleted while BindInfo still needs it.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `angelscript/language/frontend/builder`: engine-free products are DefinitionSet + CompileOutput; default RunThrough includes Emit.
- `angelscript/language/types/definitions`: script TypeInfo lives on DefinitionSet until batch Engine transfer.
- `angelscript/runtime/type-registry`: script registration is DefinitionSet Install, not Image attach as the compile product.
- `angelscript/runtime/bytecode`: stable bytecode on Function; no public ByteCodeImage; Link is Registration.
- `angelscript/runtime/vm`: Prepare reads Function runtime bytecode.

## Impact

Plugin `Plugins/Angelscript` (Runtime SDK, NewVersion NativeEngine tests). Parent OpenSpec records. `Source/AngelscriptProject` untouched.

BindInfo Draft/Apply still uses Image; a later Binding Change deletes the type.

## Boundaries

- Do not rewrite BindInfo or host `CompileModules` / ClassGen UClass.
- Do not add a module-wave thread pool.
- Do not rename `asSStableKey`.
- Do not generate runtime bytecode on first Prepare.
- Do not put TypeInfo inside `asCCompileOutput`.

## Acceptance

1. `asCBuilder` after successful RunThrough yields a Taken `asCModuleDefinitionSet` whose TypeInfo have null Engine and TypeId -1.
2. A second Builder compiles against that set without Registration.
3. `Get/TakeCompileOutput` carries `FAngelscriptModuleDesc` / `ClassDesc` without filling `ScriptType`.
4. One Registration Install+Link makes script functions Prepare-able; Prepare before that returns `asNO_FUNCTION`.
5. Image-as-product NativeEngine tests use DefinitionSet/Registration; Binding Image tests may be commented.
