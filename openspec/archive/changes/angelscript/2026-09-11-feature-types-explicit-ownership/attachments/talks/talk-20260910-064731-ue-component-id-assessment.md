# UE Component ID assessment and asCTypeIdRegistry decision

Recorded 2026-09-10T06:47:31+00:00. This is source inspection and accepted planning, not measured performance or an executed concurrency test. UE root is selected from AgentConfig.ini Paths.EngineRoot; local version is UE 5.8. Paths/hashes below bind the inspected source without copying engine implementation.

## Evidence and alternatives

| Mechanism | Observed source behavior | Adopt | Do not adopt |
| --- | --- | --- | --- |
| FPrimitiveComponentId | uint32 instance identity, zero invalid; FPrimitiveSceneInfoData owns one static FThreadSafeCounter; constructor increments it through AutoRTFM::Open; Increment uses platform InterlockedIncrement | One exported service, cheap numeric identity, synchronization at issuance | Component-instance semantics, unchecked counter rollover, assuming atomic increment publishes metadata |
| MovieScene FComponentTypeID / FComponentRegistry | TypeInfo is added to TSparseArray; its index becomes a uint16 bit index; masks use MaximumNumComponentsSupported=384; NewComponentTypeInternal mutates arrays/masks without an internal lock | Explicit registry and separate metadata indexes; optionally compact internal Engine indexes | Treating sparse slots as never-reused public identities, global name uniqueness, 384-type limit, a thread-safe registration claim |
| Current maintained AS registration | Engine mutex plus pointer-ordered Image locks; per-Engine nextMetadataTypeId/nextMetadataFunctionId, BoundTypeIds and reverse maps | Whole-batch validation and ordered locking | Independent Engine issuance under a process-unique contract; a shared Image with universal BoundEngine |
| Retained non-metadata AS path | GetTypeIdFromDataType uses plain typeIdSeqNbr++, Type->typeId and map writes; the old lock-related comment has no corresponding lock in this branch | Consumer inventory and explicit dormant/active disposition | Inferring safety from the comment or reactivating disabled producers |

The Primitive ID code inspected here has no finite-range exhaustion contract comparable to packed AS IDs. MovieScene API documentation exposes transient type destruction; local source demonstrates slot-backed allocation, but this assessment does not claim an exercised destroy/reuse sequence. The relevant distinction is that no process-lifetime non-reuse guarantee follows from an array slot. Likewise FPrimitiveComponentId is not a type registry or a lifetime lease.

## Settled decision

Use `asCTypeIdRegistry` as the public SDK service. `asCTypePublication` names only its explicit retained ownership result; `asCEngineTypeView` is an internal admission view. Global host inspection is allowed for all live published definitions, including private AS metadata, while Engine compilation and execution remain owner-scoped. Do not add a global single-result name/key resolver: two private definitions may have the same canonical identity.

A short mutex-protected bundled numeric reservation is selected for type sequences, FunctionIds and generations, because bounds and all-or-nothing reservation are simple to prove. It supports concurrent callers without claiming lock-free operation. Atomic CAS is a future optimization only if measured contention justifies it. Failed candidates can consume unused numbers; public IDs never wrap, reset or recycle. No public reset seam exists. Limits are type sequence 0x03FFFFFF, positive FunctionIds below MAX_int32 and nonzero bounded 64-bit generations.

Registry entries weakly reference live publication controls. Acquiring a result pins immutable graph memory while synchronized with retirement. Graph leases and publication authority are distinct, so leases do not retain a private Engine or keep retired IDs globally visible. No callbacks/destructors run while directory locks are held. One complete publication is visible at a commit boundary; global inspection never uses partially reserved entries.

This supersedes the previous blanket prohibition of a global private-type directory. It preserves immutable external sharing, private ownership, explicit Engine sidecars, stable symbolic caches, no automatic startup, no live-object migration and no SDK module replacement while IDs survive.

## Review disposition

The prior process-ID review is superseded because its no-global-directory boundary is replaced by explicit user direction. Its original findings remain historical observations, not completed implementation claims.

| Finding | Current disposition / proving owner |
| --- | --- |
| I1 | Preserve unified issuance obligation: 2.3 allocator plus 3.1 all maintained producer migration and NoReuse |
| I2 | Preserve definition-owned IDs independent of BoundEngine; revise three-store design to include global retained directory: 2.1, 2.4, 3.1 |
| I3 | Preserve distinct process FunctionId sequence and no array-index interpretation: 2.3, 2.4, 3.1, 4.1 |
| I4 | Preserve no-reuse; 2.3 bounds, 3.1 owner teardown, 4.2 retained retirement |
| I5 | Replace prohibition of host inspection; preserve Engine admission and execution isolation: 2.4, 3.1, 4.1 |
| I6 | Preserve sequence/kind/use separation: 2.3 and 2.2; already-decorated allocation alone is not evidence of faster exhaustion |

Current Engine-local duplicate integers are not independently a bug while APIs are strictly Engine-scoped. They violate the newly required process identity contract. Neither this replan nor the old review establishes an executed runtime collision or passing stress test.

## Source pins

| Root | Relative path | SHA-256 |
| --- | --- | --- |
| ue | `Engine/Source/Runtime/Engine/Public/PrimitiveComponentId.h` | `af8cfec33dcf67bde784e7775aa5b42fba4a7841c2ec357f2d913920485818d5` |
| ue | `Engine/Source/Runtime/Engine/Public/PrimitiveSceneInfoData.h` | `34bd964c19d57ff653d23a7ec52c4fc7f7550fc7c9dfcf9612669a9cf7f8b96e` |
| ue | `Engine/Source/Runtime/Engine/Private/PrimitiveSceneInfoData.cpp` | `17a3b2337e2c62c8dfed9035a8e5b7b2c8866efc56a7452305d6f6187ad64525` |
| ue | `Engine/Source/Runtime/Core/Public/HAL/ThreadSafeCounter.h` | `f071912a572aeeb6df513da41d910b8b8f2fddbdc565f7468ee6df718a30c691` |
| ue | `Engine/Source/Runtime/MovieScene/Public/EntitySystem/MovieSceneEntityIDs.h` | `9abf73498a5a52884675cddd4029ca77a2707ad7d29bed6831a7a445cf3f03a6` |
| ue | `Engine/Source/Runtime/MovieScene/Public/EntitySystem/MovieSceneComponentRegistry.h` | `284df34b193e31aae99f383f0eef71037c6f9c363620f17406017a0aadd31d3f` |
| ue | `Engine/Source/Runtime/MovieScene/Private/EntitySystem/MovieSceneComponentRegistry.cpp` | `77638b5416079fc32f8a98b0abe9addb483945e4e054cd801763672347afae58` |
| sdk | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.h` | `d7df598d4f1a0d488dd901f9127d86781b1191c78bb23f50aa68c7a84df49a14` |
| sdk | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.cpp` | `ece591599a60b9cc835eaac10a51d2b2b57d0bb3f9d850ee57e1ee381b88640b` |
| sdk | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine_metadata.cpp` | `95819711a61a8ab84e1696681d006c7baeb7ca449177bbc0479df70530ca9e92` |
| sdk | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_image.cpp` | `12ab9c4674ada3fd181fadf0ace2e211903441db481e602f29c6bd30f551cd4a` |
| sdk | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_runtime_type_binding.h` | `e49c1abf4b52c4e67dd1e1187f94d32b1d98559e2e8ce9dd34e322e70531fdd5` |

Official references: [FPrimitiveComponentId](https://dev.epicgames.com/documentation/unreal-engine/API/Runtime/Engine/FPrimitiveComponentId), [MovieScene FComponentRegistry](https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Runtime/MovieScene/FComponentRegistry). Exact implementation conclusions above use the local source pins, not a different online engine version.

## Earlier review snapshot check

- `openspec/changes/angelscript/feature-types-external-ownership/proposal.md`: matches assigned hash.
- `openspec/changes/angelscript/feature-types-external-ownership/design.md`: matches assigned hash.
- `openspec/changes/angelscript/feature-types-external-ownership/tasks.md`: matches assigned hash.
- `openspec/changes/angelscript/feature-types-external-ownership/change.yaml`: matches assigned hash.
- `openspec/changes/angelscript/feature-types-external-ownership/attachments/INDEX.md`: differs from assigned hash.
- `openspec/changes/angelscript/feature-types-external-ownership/attachments/data/query-contract.md`: matches assigned hash.
- `openspec/changes/angelscript/feature-types-external-ownership/specs/angelscript/runtime/type-registry/spec.md`: matches assigned hash.
- `openspec/changes/angelscript/feature-types-external-ownership/specs/angelscript/language/types/definitions/spec.md`: matches assigned hash.
- `openspec/changes/angelscript/feature-types-external-ownership/specs/angelscript/runtime/vm/spec.md`: matches assigned hash.
- `openspec/changes/angelscript/feature-types-external-ownership/specs/angelscript/runtime/bytecode/spec.md`: matches assigned hash.
- `openspec/changes/angelscript/feature-types-external-ownership/specs/angelscript/runtime/binding-engine/spec.md`: matches assigned hash.
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.h`: matches assigned hash.
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.cpp`: matches assigned hash.
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine_metadata.cpp`: matches assigned hash.
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_typeinfo.cpp`: matches assigned hash.
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_image.h`: matches assigned hash.
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_image.cpp`: matches assigned hash.
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_runtime_type_binding.h`: matches assigned hash.

INDEX can differ because recording a review adds its navigation entry; the immutable manifest itself and original finding text are preserved. Any other mismatch is reported rather than represented as the same snapshot.
