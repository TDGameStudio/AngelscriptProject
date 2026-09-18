# Code-shaped views

## Show logic or an algorithm as simplified code

```cpp
// Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectGlobals.h
// NewObject<T> — type-safe spawn entry; packs params then constructs
template<class T>
T* NewObject(UObject* Outer, const UClass* Class, FName Name, EObjectFlags Flags, UObject* Template)
{
    if (Name == NAME_None)
    {
        // Unnamed NewObject is forbidden inside a ctor — use CreateDefaultSubobject
        FObjectInitializer::AssertIfInConstructor(Outer, TEXT("..."));
    }

    CheckIsClassChildOf_Internal(T::StaticClass(), Class);  // T must be Class or a parent of Class

    FStaticConstructObjectParameters Params(Class);
    Params.Outer = Outer;
    Params.Name = Name;
    Params.SetFlags = Flags;
    Params.Template = Template;

    return static_cast<T*>(StaticConstructObject_Internal(Params));  // Allocate + construct
}
```

## Show the essentials of a struct or union as a skeleton excerpt

Same real symbols and source order, boilerplate dropped; label it `Skeleton` at the top so the reader knows it is simplified:

```cpp
// Skeleton — Engine/.../TexturePagePool.h — FPageEntry 64-bit packed physical tile slot
union FPageEntry
{
    uint64 PackedValue;
    struct
    {
        uint32 PackedProducerHandle;  // 0 = slot free in FTexturePagePool
        uint32 Local_vAddress : 24;   // Morton index within producer space
        uint32 Local_vLevel   : 4;    // Mip stored in this physical tile
        uint32 GroupIndex     : 4;    // Which physical atlas group
    };
};
```

## Show a long function as phase-grouped annotated code

Banner comments (`// ===== Phase: purpose =====`) split the body so prose can reference phases by name:

```cpp
// ============================================================
// Engine/.../ReplicationGraph.cpp — UReplicationGraph::ServerReplicateActors
// ============================================================

void UReplicationGraph::ServerReplicateActors(float DeltaSeconds)
{
    // ===== Phase 1: global throttle =====
    TimeLeftUntilUpdate -= DeltaSeconds;
    if (TimeLeftUntilUpdate > 0) { return; }  // Skip entire graph tick
    TimeLeftUntilUpdate = 1.f / TargetUpdatesPerSecond;

    ReplicationFrame++;                       // Shared frame id for RepLayout dedup

    // ===== Phase 2: per-connection =====
    for (FNetConnection* Conn : Connections)
    {
        BuildConsiderList(Conn);              // Drop dormant / out-of-range early
        PrioritizeActors(Conn);               // Bandwidth-aware sort
        ReplicateActorsForConnection(Conn);   // Diff + pack until saturated
    }
}
```
