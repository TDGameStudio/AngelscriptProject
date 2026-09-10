---
review_schema: review-v2
review_kind: external
requested_by: user
state: superseded
assigned_at: 2026-09-10T14:14:59.1662819+08:00
reviewed_at: 2026-09-10T14:28:12.0000000+08:00
closed_at: 2026-09-10T06:47:31+00:00
snapshot_ref: openspec/changes/angelscript/feature-types-external-ownership/attachments/reviews/snapshot-20260910-141459-process-typeids.md
snapshot_sha256: 892728ea7fbdce4df4cbb35c5fa4657650079b9304b0e3c850c13d690529ab27
verdict: CHANGES_REQUIRED
---

# Process-wide TypeId allocation

Assigned after an explicit user request to record why AngelScript type and function numeric IDs must be issued by one process-lifetime allocator, how the current Engine dual counters fail, and how Unreal `UClass` identity is not a model for recycling those integers.

This is a planning-plus-current-SDK review. The Change is documentation-only; no product task has run. The snapshot is the Markdown hash table named above, not a Git commit: the Change directory is untracked on parent HEAD `0f0cf23ee78e563bf93dcf20b43a55381948273d`. Paths below are those snapshot entries. No UE build or Automation was executed; traces are deterministic reads of the pinned files.

Scope: current TypeId/FunctionId machinery, design sections 2–5, `type-registry` numeric-identity requirement, task 2.1, and the Unreal class-identity contrast requested by the user. Excluded: provider migration, adapter reconstruction, bytecode opcode changes, and archive of this Change.

## Why the integers exist at all

AngelScript's public C API and VM still traffic in `int` TypeIds with packed use bits (`asTYPEID_OBJHANDLE`, `asTYPEID_HANDLETOCONST`) and kind bits (`asTYPEID_APPOBJECT`, `asTYPEID_SCRIPTOBJECT`, `asTYPEID_TEMPLATE`). Sequence payload is `asTYPEID_MASK_SEQNBR` (`0x03FFFFFF`). Primitive tokens `void` through `float64` are fixed and must never be reused as dynamic sequence numbers.

Those integers are **not** durable identity. Durable identity remains `asSStableKey` / TypeUseKey / schema and layout hashes. Symbolic bytecode must not embed runtime TypeIds. The allocator therefore exists only to give each published definition a process-unique public number that `GetTypeInfoById` / `GetFunctionById` can reverse.

## Current machinery: two Engine counters, one encoding

On each `asCScriptEngine` the snapshot contains **two** dynamic sequence generators, both starting at `asTYPEID_FLOAT64 + 1`:

| Generator | File | When assigned | Where stored | Reverse map |
| --- | --- | --- | --- | --- |
| `typeIdSeqNbr` | `as_scriptengine.cpp` constructor (~816) and `GetTypeIdFromDataType` (~5324) | First legacy `GetTypeIdFromDataType` for a type with `typeId == -1` | `asCTypeInfo::typeId` | `mapTypeIdToTypeInfo` |
| `nextMetadataTypeId` | `as_scriptengine.h` (~704) and `as_scriptengine_metadata.cpp` (~79–104, ~147) | `RegisterMetadataImage` | `asCMetadataImage::BoundTypeIds` only; `Type->typeId` stays `-1` | `metadataTypesById` |

Function IDs split the same way: legacy `scriptFunctions[]` indices versus `nextMetadataFunctionId` / `metadataFunctionsById`.

Metadata reverse lookup is Engine-owned. Forward lookup from a metadata type is Image-owned:

```
Type.GetTypeId()
  metadataOwner ? Image.GetBoundTypeId(this) : Type->typeId

Engine.GetTypeInfoById(id)
  base = id & (asTYPEID_MASK_OBJECT | asTYPEID_MASK_SEQNBR)
  metadataTypesById[base] else primitives else mapTypeIdToTypeInfo
```

`GetTypeInfoById` (`as_scriptengine.cpp` ~6435) **prefers the metadata map**. Kind bits are OR'd onto the stored key (`as_scriptengine_metadata.cpp` ~100–104), so APP versus SCRIPT versus TEMPLATE sequence collisions occupy different map keys. Two APP objects (or two SCRIPT objects) that received the **same sequence from different counters** occupy the same key. The metadata entry wins; the legacy object becomes unreachable by that integer.

`RegisterObjectType` currently returns `asNOT_SUPPORTED` and `CompileModule_Types_Stage1` is stubbed. That **closes the collision by disabling the legacy producer**, not by unifying allocation. Re-enabling either producer against the current maps is unsafe.

Metadata types also cannot answer `GetTypeId()` until `RegisterMetadataImage` writes `BoundEngine` and `BoundTypeIds`. That is why a frozen Image has real `asCObjectType` objects and still reports TypeId `-1`. The number is a relation `(Engine, Type)`, not a field on the type.

## What this Change already decided

Design section 3 and the `type-registry` requirement *Runtime numeric identity is allocated independently and never reused in-process* already require:

- One process-lifetime SDK allocator for dynamic type **and** function sequence numbers.
- No metadata pointers inside the allocator.
- No reuse after library or Engine destruction.
- Gaps after failed publication are allowed; exhaustion fails the whole batch.
- External definitions receive IDs at `asCTypeLibrary::Publish`, **before any Engine exists**.
- Private script batches receive IDs at Engine publication from the **same** allocator.
- `asSRuntimeTypeId {Generation, Value}` names the **definition owner's publication**, not the querying Engine.
- Primitive IDs stay fixed; `GetTypeInfoById` on a primitive remains null.

Task 2.1 (`Library.DetachedPair`, `Library.Exhaustion`, `Library.NoReuse`) is the proving surface for that allocator.

The plan is directionally correct. The findings below are the ways implementation can still recreate today's split, or mis-copy Unreal object-array recycling.

## Finding I1 — Required: Both Engine counters must stop being sources of dynamic IDs

- Severity: Required
- Status: resolved
- Primary location: `as_scriptengine.h` `typeIdSeqNbr` (~622) and `nextMetadataTypeId` / `nextMetadataFunctionId` (~704–705).
- Related: `as_scriptengine.cpp` ~816, ~5324; `as_scriptengine_metadata.cpp` ~79–147; design.md section 3; tasks.md 2.1.

Observation: If task 2.1 introduces a process allocator only for `asCTypeLibrary::Publish` while private `RegisterMetadataImage` keeps `nextMetadataTypeId`, or while any leftover legacy path still uses `typeIdSeqNbr`, the Change fails its own uniqueness contract. Both existing counters start at the same base and pack the same kind bits. External C++ types and Engine-private script types would again share an encoding with independent sequences.

Impact: Two Engines, or one Engine with both an attached library and a private batch, can publish distinct `asCObjectType` pointers that `GetTypeInfoById` cannot distinguish. Bytecode link and Context Prepare that trust the integer then bind the wrong TypeInfo. The acceptance scenario "Pair has the same original pointer and ID in A and B, while the two ScriptThing objects and IDs differ" requires **different** numbers for the two ScriptThings, issued from one sequence, not two Engine-local sequences that can both yield `FLOAT64+1`.

Resolution condition: After 2.1, every successful dynamic TypeId/FunctionId in the maintained path is issued by the process allocator. Engine fields `nextMetadataTypeId`, `nextMetadataFunctionId`, and `typeIdSeqNbr` are not sources of new maintained IDs. Prove: (1) library Pair ID is valid with zero Engines; (2) Engine-private ScriptThing IDs are distinct from that Pair ID and from each other across two Engines; (3) `Library.NoReuse` still holds after Engine teardown; (4) a test seam that would have used `typeIdSeqNbr++` is either absent or rejected. Dormant `#if 0` Register* bodies must not be reactivated as a second allocator.

Resolution: Task 2.3 delivered `asCTypeIdRegistry`. BindInfo `PublishProcessIds` and unpublished `RegisterMetadataImage` both Reserve process IDs. 7.6 ScriptThingIsolation proved distinct private IDs across Engines.

## Finding I2 — Required: Reverse lookup and ID storage must split library tables from Engine admission

- Severity: Required
- Status: resolved
- Primary location: design.md section 3 (IDs before Engine) versus section 5 ("Move … per-Engine IDs/index relationships into Engine registry").
- Related: `as_metadata_image.h` `BoundEngine` / `BoundTypeIds` (~267–270); `as_typeinfo.cpp` `GetTypeId` (~291–294); `as_scriptengine.cpp` `GetTypeInfoById` (~6435–6443).

Observation: Section 3 requires external IDs to exist with no Engine. Section 5 requires Engine registries to own per-Engine ID indexes. Today's Image still stores `BoundEngine` plus `BoundTypeIds` and is the only forward map for metadata `GetTypeId()`. If implementation keeps BoundTypeIds on a **shared** Image after multi-Engine attach, `GetBoundTypeId` remains a single-Engine table (`BoundEngine && Owns`). If implementation stores IDs **only** on the Engine, library queries before `asCreateScriptEngine` have nowhere to read them.

The required split is:

```
process allocator              issues the integer, holds no pointers
TypeLibrary published index    ID ↔ original Type* / Function* for external graphs
Engine registry                admitted library IDs (same integers) + private-batch IDs
asCTypeInfo::typeId            remains unused for maintained objects (-1)
asCMetadataImage BoundEngine   must not stay the uniqueness or ID authority
```

`GetTypeInfoById` on an Engine is then a **visibility** filter over process-unique numbers, not a second generator. A library can answer the same ID without an Engine. An Engine that never attached that library must not resolve it.

Impact: Leaving BoundTypeIds as the sole table blocks either "ID before Engine" or "many Engines share one Image". Merging library and private IDs into one Engine map without a process allocator recreates Finding I1.

Resolution condition: Document and implement three stores as above. Cases: DetachedPair ID round-trip with no Engine; A and B `GetTypeInfoById(pairId)` return the same pointer; B `GetTypeInfoById(aScriptThingId)` is NotVisible/null, not A's object; after A retires, Pair ID still resolves on B and on the library. Shared Images stay Frozen and do not report a single BoundEngine as owner of the ID.

Resolution: BindInfo holds publication IDs without TypeInfo. Each Engine materializes unique TypeInfo and indexes its own maps. 7.5 Shared publication and 7.6 private isolation proved the split. BoundEngine is not ID or admission authority.

## Finding I3 — Required: FunctionIds follow the same process allocator and must not reuse `scriptFunctions` indices

- Severity: Required
- Status: resolved
- Primary location: `as_scriptengine.h` `nextMetadataFunctionId` (~705); legacy `scriptFunctions` array (`as_scriptengine.cpp` ~813 reserves slot 0).
- Related: design.md section 3 "a separate monotonic counter issues FunctionIds"; query-contract.md FunctionId row; `as_scriptfunction.cpp` metadata `id = -1`.

Observation: Maintained metadata functions keep `id = -1` and receive BoundFunctionIds at registration, parallel to types. Legacy functions use `scriptFunctions` indices as IDs. Task 2.1 names type/function allocation together but the current Engine still has an independent function counter and a third legacy array.

Impact: CALLSYS / `GetFunctionById` mixed across metadata and leftover module functions can alias. Private script functions published through the metadata path must not take IDs from `scriptFunctions.GetLength()`.

Resolution condition: One process FunctionId counter; metadata `GetId()` reads publication tables, not `asCScriptFunction::id` unless that field is explicitly synchronized. Prove library method IDs before Engine creation, and that two Engines' private functions receive distinct process IDs. No test may assume FunctionId == array index.

Resolution: FunctionIds come from the same Registry Reserve as TypeIds. Shared publication tests execute Sum by published FunctionId on distinct Engine Function objects.

## Finding I4 — Advisory: Do not recycle TypeIds the way `GUObjectArray` recycles `InternalIndex`

- Severity: Advisory
- Status: open
- Primary location: design.md section 3 "Engine/library destruction never resets counters"; type-registry scenario "Retire a private definition and publish another".

Observation: Unreal type identity is `UClass*` plus `/Script/Module.Name`. `StaticClass()` is a process singleton pointer. Blueprint-generated classes are additional `UClass` objects in the same `GUObjectArray`. `EClassCastFlags` are inherited kind bits for fast Cast, not per-class numbers. `UObject::GetUniqueID()` is the object array slot and **can be reused** after GC; weak references add a serial number so a recycled slot does not revive a stale weak ptr.

AngelScript TypeIds are packed into VM/API integers **without** that serial on the public `int`. Recycled sequence numbers would make `GetTypeInfoById` and any in-memory bytecode that still carried the old int bind a new definition. That is the failure mode `Library.NoReuse` exists to prevent.

Copy from Unreal: pointer identity for the actual object, FName-like stable keys for durability, generation on retained handles (`asSRuntimeTypeId`). Do not copy slot recycling for the public TypeId int.

Resolution condition: Keep never-reuse for dynamic sequence numbers. Retained retired metadata may still **report** its historical ID; live lookup must not resolve it to a newer object. If a compact live index is wanted, it is an Engine sidecar, not the public TypeId.

## Finding I5 — Advisory: Uniqueness is process-wide; visibility is not

- Severity: Advisory
- Status: open
- Primary location: query-contract.md rows "Pair published numeric ID" versus "A's ScriptThing ID"; type-registry scenarios Shared versus Private.

Observation: After unification, A's ScriptThing might be `101` and B's `102`. The integers are globally unique, but B must not treat `101` as a valid member of B. Operators that only test "is this int in range" will leak cross-Engine private types. Conversely, Pair's ID must resolve on every admitting Engine **and** on the library with zero Engines.

Impact: Implementers may build one process hash map from ID to TypeInfo and call it the registry. That becomes a global private-type directory, which the Change forbids.

Resolution condition: Engine `GetTypeInfoById` / `GetTypeIdFromDataType` consult only admitted libraries plus live private batches of **that** Engine. Library queries see only that library's closure. Prove ForeignDataType and Private ScriptThing isolation even when the caller holds the raw integer obtained from the other owner.

## Finding I6 — Advisory: Handle and kind bits stay on the integer; the allocator issues only the sequence

- Severity: Advisory
- Status: open
- Primary location: `angelscript.h` `asETypeIdFlags`; `GetBoundDataTypeId` in `as_metadata_image.cpp` (~231–263); design.md "Primitive IDs stay fixed" / "Legal handle IDs return the underlying TypeInfo".

Observation: The process allocator should mint the sequence (`1 … MASK_SEQNBR` after primitives), not a fully decorated TypeId. Kind bits are a function of the published type's flags. Handle bits are a function of the **type use**, added when converting `asCDataType` to int and stripped on reverse lookup. Enums currently omit APP/SCRIPT bits in `RegisterMetadataImage`. Aliases have their own object ID; `GetTypedefTypeId` projects the target.

Impact: If the allocator returns already-OR'd APP/SCRIPT bits, two publications can exhaust the sequence space faster or disagree with `GetTypeInfoById`'s mask. If handle bits are stored in BoundTypeIds, `FVector` and `FVector@` become two directory keys for one object.

Resolution condition: Allocator API returns the raw sequence (and FunctionId). Publication records the fully decorated object TypeId used as the directory key. Type-use queries add/remove handle bits without allocating. Tests cover primitive null TypeInfo, alias identity versus target, and `Obj@` resolving to the same TypeInfo as `Obj`.

## Verdict

`CHANGES_REQUIRED` because I1–I3 are open Required implementation contracts. They do not invalidate the accepted process-allocator requirement; they pin how that requirement must consume and then replace the current dual Engine counters, FunctionId arrays, and Image `BoundTypeIds`.

I4–I6 are Advisory rationale: Unreal `UClass` is pointer-plus-name identity with a recyclable object-array slot; AngelScript's public TypeId cannot recycle; uniqueness and visibility are different tables.

No Replan is requested from this file. Design section 3 already states the allocator. Coordinator triage may add a talk or a design footnote for the three-store split in I2 without changing the Task DAG if task 2.1's files (`as_type_library.*`, `as_type_registry.*`) are accepted as those stores.

Verification story: read-only inspection of the snapshot manifest files. No Automation. Close only after I1–I3 have named proving cases on the process allocator and Engine/library lookup isolation, or are rejected with evidence that an equivalent existing case already covers them.

## Coordinator supersession — 2026-09-10T06:47:31+00:00

Superseded by explicit user direction to evaluate UE Component IDs and replan with asCTypeIdRegistry. The previous restriction against any global private-type directory no longer applies to retained host inspection. Original findings, verdict and snapshot remain unchanged historical evidence; this is not APPROVE and no implementation proof is claimed. See ../talks/talk-20260910-064731-ue-component-id-assessment.md for source checks and I1–I6 dispositions, and ../replans/replan-20260910-064731-process-type-id-registry.md for permanent task mapping. Implementation obligations are carried by 2.3, 2.1, 2.2, 2.4, 3.1, 4.1 and 4.2; no automatic replacement Review is started.
