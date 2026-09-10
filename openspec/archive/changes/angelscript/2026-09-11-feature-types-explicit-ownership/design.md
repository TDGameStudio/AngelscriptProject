## 1. Decision

`asCMetadataImage` is an intermediate translator. It does not hold durable class data and does not own TypeInfo. UE BindInfo records hold pre-Engine class information. Each Engine uniquely creates TypeInfo when it needs executable metadata. `asCTypeIdRegistry` only issues process IDs.

The previous Image-as-graph-owner, `std::shared_ptr` registration, and shared TypeInfo-pointer model is withdrawn.

```text
FAngelscriptTypeBindInfoStore  --durable UE class records-->
        |
        |  TUniquePtr<asCMetadataImage>  (project / return class facts / discard)
        v
asCTypeIdRegistry.Reserve  --publication IDs, no objects-->
        |
        |  delayed per Engine
        v
Engine TypeInfo  (unique, AddRef/Release, not shared_ptr)
```

## 2. Ownership

| Object | Owner | Lifetime |
| --- | --- | --- |
| BindInfoStore / BindInfo records | UE recording / host | Process publication until the host drops the store |
| `asCMetadataImage` | The call that created the helper (`TUniquePtr`) | Ends after projection, UE query, or Engine materialize |
| Publication ID / generation | Registry numeric service | Process, never reused |
| TypeInfo / ScriptFunction graphs | The Engine that materialized them | Engine lifetime plus Engine-local AddRef |
| Native auxiliary, user data, template operations | That Engine | Destroyed with the Engine |

Rules:

- No `std::shared_ptr` for Image, Image dependency lists, publication handles or TypeInfo ownership.
- Image must not store BoundEngine, BoundTypeIds as durable graph state, or a shared TypeInfo array that outlives the helper.
- Materialize copies or constructs Engine TypeInfo from BindInfo/canonical facts. After success the unique Image may be reset.
- Two Engines materializing one Pair publication produce two TypeInfo pointers and one ID.
- Private AS batches never publish TypeInfo through Image sharing.

Public shape (to implement; not present as-is):

```cpp
static asCTypeIdRegistry& asCTypeIdRegistry::Get();
asETypeIdReservationResult asCTypeIdRegistry::Reserve(...); // exists from 2.3

// Publication records BindInfo identities, not Image graphs.
asEMetadataRegistrationResult asCTypeIdRegistry::Publish(const FAngelscriptTypeBindInfoStore& Store, ...);
asETypeQueryResult asCTypeIdRegistry::GetPublishedClassInfo(int TypeId, /* UE-facing class facts */ ...) const;

// Delayed unique materialization. Image is a unique in-parameter, not a retained owner.
asEMetadataRegistrationResult asCScriptEngine::MaterializePublishedTypes(
    const FAngelscriptTypeBindInfoStore& Store,
    TUniquePtr<asCMetadataImage> Image);
```

Exact member names may be refined in task 7.1 as long as unique Image, BindInfo durability, delayed Engine TypeInfo and no `std::shared_ptr` remain.

## 3. IDs and queries

Keep primitive encodings and 2.3 reservation. Assign TypeId/FunctionId to publications when BindInfo is published, before Engine TypeInfo exists. Engine TypeInfo later reports those IDs; it does not allocate a second process ID.

Pre-Engine queries return UE class facts (name, members, signatures, IDs) from BindInfo/Registry. They do not return Engine TypeInfo pointers. `GetTypeInfoById` without an Engine is null. After materialize, Engine `GetTypeInfoById` returns that Engine's pointer only.

Retained Engine TypeInfo uses existing AddRef/Release. No AddRef-owned Image.

## 4. Builder and source

Builder remains engine-independent as a producer. Successful AS definitions are adopted by the receiving Engine as unique TypeInfo. Builder must not leave a shared Image as the TypeInfo owner. Newly created specializations belong to that Engine.

## 5. VM, bytecode, bindings

Admission, CALLSYS, ALLOC/FREE and GC use the executing Engine's TypeInfo. Linked operands stay direct pointers into that Engine. No Image BoundEngine and no per-instruction Registry lock.

`CreateForBindings` consumes BindInfoStore (and optional sealed snapshot). Each Engine materializes its TypeInfo. Destroying A releases A's TypeInfo and sidecars; BindInfo and B remain.

## 6. Migration

Task 1.1 documents the old Image-owned baseline. Task 2.3 keeps the allocator. Pending 2.1-2.4 and 3.1-6.2 assumed Image graph ownership and are superseded by 7.x. Revert abandoned 2.1 `Register(shared_ptr)` before 7.1 implementation.

Current-spec formatting repairs remain 7.10's named baseline only.

## 7. Performance

Same gate: measure execution separately from preparation. Sharing BindInfo must not add Registry/Image traffic to the interpreter loop.

## 8. Binding-pipeline prerequisite

The binding Change consumes BindInfoStore as the reusable preparation, not a shared Image graph. Its Install stage uniquely materializes TypeInfo per Engine. Update that Change's "shared MetadataImage definitions" conclusion to match this decision.
