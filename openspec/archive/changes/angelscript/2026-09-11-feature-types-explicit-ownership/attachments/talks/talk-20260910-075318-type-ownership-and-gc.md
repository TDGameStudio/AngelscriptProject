# Creator-owned type metadata and instance GC

Accepted 2026-09-10T07:53:18+00:00 after the user requested a replan following host-owned C++ types, Engine-owned generated types and a non-owning Registry. This is planning only, not an executed ownership or GC test.

## Evidence

Existing MetadataImage already owns actual type/function graphs and frozen dependencies; its destructor deletes graph elements. TypeInfo AddRef retains its Image and final Release drops that retention. Current VM allocation AddRefs TypeInfo, stores Type/Engine in the object header and registers GC-capable instances; free releases TypeInfo. Current allocation/GC registration derives Engine from Type->GetEngine and must migrate to explicit instance ownership for shared types.

## Settled decision

Use existing Image ownership. Host creators or shared preparation objects own host graphs, including graphs created dynamically; receiving Engines own accepted compilation graphs and their new specializations. Builder lifetime is temporary. Registry assigns IDs and weakly indexes active registrations. It does not own or GC types, and it does not distinguish ownership by language spelling.

Expose Register/Unregister and AddRef-owned Acquire outputs. Remove the public publication-container and custom lease-class requirements. Internal generation/registration state remains necessary to withdraw IDs while old references retain graph memory. Host Unregister returns InUse for Engine/dependency use pins, succeeds when only query memory references remain, and cannot retire private Engine graphs. The existing prepared binding object is retained by installations and coordinates final unregister; another public registration token is unnecessary.

The previous UE assessment's bounded process allocation, no reuse, synchronization and index rationale remain valid. Its public publication owner/lease API shape is superseded. Original review and applied records remain unchanged. No new Review is started.

## Test decisions

Add exact creator ownership, repeated registration, InUse withdrawal, AddRef balance, acquire/withdraw races, Builder transfer and A/B instance-cycle GC cases to existing tasks. Keep all 13 SDK task IDs and edges and all 24 binding IDs/edges. Existing group RED/GREEN and final NativeEngine/RuntimeBindings selectors remain required; this document does not claim those tests ran.

## Source hashes

| Path | SHA-256 |
| --- | --- |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_image.h` | `abb48ad9a419f471f9fa0dd168abebe47d1fc346ed4d7136e433cba7e335dfa0` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_image.cpp` | `12ab9c4674ada3fd181fadf0ace2e211903441db481e602f29c6bd30f551cd4a` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_typeinfo.cpp` | `152b6f49540dd62f632eda01375b5af510c30d4578c32d70e9838cbeee3514c6` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_vm_object.cpp` | `487c766edde8d420f4161401c8b15aaca738741c62960c8b26d244c02227540c` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_gc.cpp` | `3be09b4bab842e6cbc6be15ce0e5cecf41b985d8a6c44b5cf6aabe6f8a46819b` |
