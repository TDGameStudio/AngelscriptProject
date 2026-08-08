## Why

The completed `refactor-as-manual-binding-architecture` established the runtime binding architecture, but follow-up review exposed a separate repository-wide maintainability problem: actual `FAngelscriptBind` registrar files do not consistently summarize the AngelScript surface they expose, Type adapters have inconsistent source ownership, and a small number of obsolete Actor binding shims remain. These issues should be closed in one focused change without reopening the completed architecture migration.

## What Changes

- Make the `.cpp` file containing the actual `FAngelscriptBind` definition the single owner of binding-facing documentation. Every such `Bind_*.cpp` receives one UE/Doxygen-style file-head two-column table containing the complete stable AngelScript surface and non-obvious `@param` notes.
- Preserve `Bind_AActor.cpp` as the formatting and registrar-reviewability reference: `AActor.Manual` and `AActor.PostReflection` keep non-capturing provider lambdas expanded directly at their `FAngelscriptBind` definitions, while named `FAngelscriptActorBinds` functions remain the native callable owners.
- Remove the obsolete internal `Actor::__Actor_GetAllByClass` path and its native helper, disabled generator stub, table row, and internal-only test branch while retaining all supported public Actor query coverage.
- Remove the compatibility-only `Bind_Actor.h` include shim. The already-implemented cleanup temporarily points its two checked-in consumers at `Bind_AActor_Functions.h`; the repository-wide family-header migration then moves those declarations into the canonical `Bind_AActor.h` and deletes `Bind_AActor_Functions.h` with the other legacy callable headers.
- Replace all 96 `Bind_<Family>_Functions.h` files with one canonical `Bind_<Family>.h` per affected family. The family header owns native callable declarations, family-owned Type declarations, and template definitions that must remain visible; `Bind_<Family>.cpp` owns registrars and script-facing documentation, `Bind_<Family>_Functions.cpp` owns out-of-line native callable implementations, and `Bind_<Family>_Type.cpp` owns out-of-line Type implementations.
- Inventory every direct or indirect `FAngelscriptType` adapter and move every non-Blueprint concrete adapter family, including small scalar families, into that unified family topology. Shared template infrastructure remains header-only, and the four object adapters in `Bind_BlueprintType.cpp` remain a documented high-risk exception for this change.
- Create no empty symmetry files. A `_Functions.cpp` or `_Type.cpp` exists only when that family owns the corresponding out-of-line implementation responsibility; necessary support headers remain only after their distinct ownership and consumers are recorded.
- Preserve the already-verified Actor provider-lambda regression, but do not add long-lived unit tests for canonical filenames, include shape, or comment markers. Audit the 120 surface blocks, 96 header consolidations, and Type ownership statically during implementation, then use build/diff review plus the narrowest missing Bindings, Coverage, Functional, TypeUsage, or StaticJIT regression for actual Bind interfaces and behavior.
- Keep `issues.md`, `bind-documentation-audit.md`, and `type-ownership-audit.md` synchronized with implementation and verification evidence until all non-deferred rows are verified.

## Capabilities

### New Capabilities

- `as-bind-reviewability-and-contract-tests`: Defines registrar-local binding documentation, Actor registrar reviewability, binding-test ownership, evidence-gated internal cleanup, and explicit Type-adapter family ownership.

### Modified Capabilities

None. Supported public AngelScript declarations and behavior remain compatible. The only script-visible removal is the internal double-underscore entry point `Actor::__Actor_GetAllByClass` after its repository-wide no-consumer audit.

## Impact

- OpenSpec record: `openspec/changes/improve-as-bind-reviewability-and-tests/`.
- Runtime documentation: every `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*.cpp` that defines a real `FAngelscriptBind`; current snapshot is 120 registrar files, of which `Bind_AActor.cpp` is already the documented reference.
- Header ownership: all 96 legacy `Bind_*_Functions.h` files under `AngelscriptRuntime/Binds`, plus the audited family/support headers with which their declarations merge.
- Type ownership: all non-Blueprint concrete adapter families under `AngelscriptRuntime/Binds`; existing registrar phases, declarations, traits, native forms, TypeDB ownership, export visibility, and generated/native-module layouts remain unchanged.
- Tests: the existing Actor provider-lambda regression, focused Actor tests, affected family Bindings/Coverage/Functional tests, TypeUsage/TypeRegistry/TypeDatabase, and StaticJIT NativeForms. Canonical header and comment completeness are delivery audits rather than permanent automation contracts.
- Repository workflow: plugin source and tests are committed in the `Plugins/Angelscript` submodule first; the parent then records this OpenSpec and the resulting gitlink without staging unrelated workspace changes.
