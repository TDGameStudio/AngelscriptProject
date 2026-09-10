## Why

Hosts need C++ class information and numeric IDs before an AngelScript Engine exists, then each Engine must create its own TypeInfo later. The previous plan stored actual TypeInfo graphs inside `asCMetadataImage` and shared those objects across Engines with `std::shared_ptr`. That inverts the intended roles: Image is only an intermediate helper, UE BindInfo already holds class records, and Engine TypeInfo is delayed and uniquely owned.

Current source still binds IDs, BoundEngine and graph lifetime to Image, so preparing bindings early cannot describe classes to UE without also creating Engine TypeInfo, and a second Engine cannot materialize an independent TypeInfo from the same publication.

## What Changes

- Treat `FAngelscriptTypeBindInfoStore` / BindInfo records as the durable pre-Engine class publication. `asCMetadataImage` is a unique intermediate that projects those records into the SDK and returns class facts to UE; it does not retain TypeInfo, function graphs or Engine binding.
- Forbid `std::shared_ptr` for Image, Image dependencies, publication lifetime and TypeInfo ownership. Image uses `TUniquePtr`. Engine TypeInfo uses existing Engine-local AddRef/Release. UE BindInfoStore may keep `TSharedRef` as the UE recording owner.
- Keep `asCTypeIdRegistry` as the process ID issuer from task 2.3. IDs attach to publications (BindInfo identities), not to a shared Image graph. Each Engine later materializes its own TypeInfo that reports those IDs.
- Engine A and B never share a TypeInfo pointer. They may share a publication ID. Private AS compilations uniquely own their TypeInfo.
- Move execution, native auxiliary, mutable user data and template operations onto Engine-local TypeInfo/sidecars. Image has no BoundEngine and no execution authority.
- Binding preparation consumes BindInfoStore, uses a unique Image helper, discards the helper after materialization, and installs per-Engine TypeInfo.

## Capabilities

### New Capabilities

- `angelscript/runtime/type-registry`: publication IDs, delayed Engine TypeInfo materialization, host class-info queries without Engine TypeInfo, and Engine-local TypeInfo ownership.

### Modified Capabilities

- `angelscript/language/types/definitions`: Image is intermediate; TypeInfo is Engine-owned and created late; no shared TypeInfo pointers.
- `angelscript/runtime/vm`: execution ownership from the Engine's TypeInfo, never from Image.
- `angelscript/runtime/bytecode`: link against the receiving Engine's materialized TypeInfo.
- `angelscript/runtime/binding-engine`: prepare from BindInfoStore, unique Image helper, independent Engine TypeInfo.

## Impact

Product work remains in `Plugins/Angelscript`. This OpenSpec record, indexed evidence and the binding-pipeline prerequisite notes change. Tasks 1.1 and 2.3 stay completed. Pending tasks 2.1, 2.2, 2.4 and 3.1-6.2 are superseded by 7.x. Abandoned in-progress `Register(std::shared_ptr<asCMetadataImage>)` edits are reverted.

## Boundaries

No automatic subsystem startup, live-object migration, disk cache, cross-process IDs, UHT generator, or wholesale provider migration. No `std::shared_ptr` metadata lifetime. No process-wide shared TypeInfo object.

## Acceptance

A host records native Pair in BindInfo, obtains a publication ID and returns class/member/signature facts to UE without creating an Engine or retaining Image-owned TypeInfo. Destroying the unique Image helper leaves BindInfo and the ID intact. Engines A and B each materialize distinct TypeInfo pointers that report the same Pair ID and execute Sum as 42 with independent native state. Destroying A leaves B usable. Private ScriptThing TypeInfo belongs only to its Engine. Invalid publication never creates Engine TypeInfo.

Steady-state VM performance remains a completion gate: no Registry/Image lookup per instruction.
