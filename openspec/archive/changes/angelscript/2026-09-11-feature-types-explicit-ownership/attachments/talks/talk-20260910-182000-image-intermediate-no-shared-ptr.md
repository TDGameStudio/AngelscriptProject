# Image is an intermediate helper, not a graph owner

## Context

The previous plan treated `asCMetadataImage` as the durable owner of actual TypeInfo/ObjectType/ScriptFunction graphs, registered by `std::shared_ptr`, and shared by pointer across Engines. The user rejected that model.

## Evidence

- User: Image is only an intermediate structure, holds no durable data, returns class information to UE, and assists delayed Engine TypeInfo creation.
- User: do not use `shared_ptr`.
- Current source still contradicts that intent: Image comments claim it owns actual runtime metadata; Draft/Apply hold `std::shared_ptr<asCMetadataImage>`; Engine `RegisterMetadataImage` attaches those objects; TypeInfo `GetEngine`/`GetTypeId` go through Image BoundEngine.
- UE durable class records already exist as `FAngelscriptTypeBindInfoStore` / `FAngelscriptTypeBindInfo`. Two-stage binding Record is specified to copy semantic values without `asCObjectType`.
- Task 1.1 measured the old contract (detached TypeId -1, ForeignEngine). Task 2.3 delivered a pointer-free numeric allocator. Abandoned 2.1 edits started `Register(std::shared_ptr<asCMetadataImage>)`.

## Options

1. Keep Image as shared graph owner (previous plan). Rejected.
2. Clone TypeInfo into Registry, discard Image, still share TypeInfo pointers. Rejected: second graph plus shared objects.
3. BindInfo/UE class records are durable pre-Engine publication. Image is a unique, short-lived translator that never retains TypeInfo. Each Engine uniquely materializes its TypeInfo later. Accepted.

## Settled Decision

- Durable pre-Engine class information lives in UE BindInfo/recording records, not in Image.
- `asCMetadataImage` is a unique intermediate (`TUniquePtr`, no `std::shared_ptr`) used to project that information into the SDK and back to UE, then discarded.
- Engine TypeInfo is created late and uniquely owned by that Engine. Two Engines never share a TypeInfo pointer. They may share publication IDs assigned before materialization.
- `asCTypeIdRegistry` issues IDs and indexes publications; it does not own TypeInfo or Image.
- No `std::shared_ptr` for Image, Image dependency lists, publication lifetime, or TypeInfo ownership. Existing AngelScript AddRef/Release remains Engine-local TypeInfo lifetime. UE `TSharedRef` on BindInfoStore remains the UE recording owner.

## Consequences and Flip Condition

Acceptance "same original Pair pointer in A and B" is withdrawn. A and B have distinct TypeInfo pointers, the same publication ID, and independent execution state. Flip only if a later explicit decision requires one process-wide TypeInfo object shared by pointer.

## Visual

```text
FAngelscriptTypeBindInfoStore  (UE durable class info)
        |
        |  asCMetadataImage TUniquePtr  (intermediate, no retained TypeInfo)
        |  returns class facts to UE; does not own the graph
        v
asCTypeIdRegistry  (IDs only)
        |
        |  delayed, per Engine
        v
Engine A TypeInfo != Engine B TypeInfo
same publication ID, separate execution/user-data/GC
```

## Sources

User messages on Image-as-intermediate and no `shared_ptr`. Inspected `as_metadata_image.h`, `AngelscriptTypeBindInfoDraft.h`, `AngelscriptTypeBindInfoStore.h`, two-stage binding design, tasks 1.1/2.3 evidence.
