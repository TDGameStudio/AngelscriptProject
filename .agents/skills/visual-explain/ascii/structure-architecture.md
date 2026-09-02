# Structure & architecture

## Show what a type contains as a member / composition tree

```
FSceneRenderer
├─ [Member] TArray<FViewInfo> Views                  // One entry per view / viewport
├─ [Member] TArray<FVisibleLightInfo> VisibleLightInfos
│   └─ [Index 0] FVisibleLightInfo
│       ├─ AllProjectedShadows                       // Every shadow cast by this light
│       └─ ShadowsToProject                          // Subset that actually projects this frame
└─ [Member] FScene* Scene                            // Shared scene graph; lifetime >= renderer
```

## Show a class hierarchy with overrides as an inheritance tree

Indentation = inheritance depth; each row notes what that class overrides or adds, so the reader sees where behavior actually changes:

```
UObject
└─ AActor                          // Defines: Tick(), BeginPlay(), lifecycle + replication
    ├─ APawn                       // Overrides: PossessedBy() / UnPossessed(); adds controller link
    │   └─ ACharacter              // Overrides: Landed(), OnMovementModeChanged()
    │                              // Adds: CharacterMovement, CapsuleComponent
    └─ AController
        ├─ AAIController           // Overrides: possession flow; adds perception, blackboard
        └─ APlayerController       // Adds: input stack, HUD, PlayerCameraManager
```

## Show a cache / storage stack as layered architecture

```
UE5 RVT cache stack (GPU request → Atlas write)
│
├─ [Layer 1: Physical tile cache — FTexturePagePool]
│   ├─ FBinaryHeap FreeHeap                       # LRU min-heap, Key = (Frame<<4)|Level
│   └─ FHashTable PageHash                        # (Producer, vAddr, vLevel) → pAddress
│
├─ [Layer 2: Transcode task cache — FVirtualTextureTranscodeCache]
│   ├─ TArray<FTaskEntry> Tasks                   # in-flight transcode jobs
│   └─ FHashTable TileIDToTaskIndex               # dedup: same tile decoded once
│
└─ [Layer 3: Upload staging cache — FVirtualTextureUploadCache]
    └─ FVTUploadTileAllocator TileAllocator       # budgeted by r.VT.MaxUploadMemory
```

## Show conceptual zones with embedded sketches as double-line banners

When each layer needs its own inline sketch (address spaces, pools, mappings), swap the light spine for `╔═╣ ║ ╚═` bands; otherwise prefer the lighter `[Layer N]` spine above:

```
╔═════════════════════════════════════════════════════════════════╗
║                    Virtual address space                        ║
║  Level 0:  16384 × 16384 px  =  128 × 128 pages  (128 px / pg)  ║
║  Mip 1..N: half each step  (used by point / spot lights)        ║
╠═════════════════════════════════════════════════════════════════╣
║                    Physical Page Pool                           ║
║  ┌───┬───┬───┬───┐    Texture2DArray<UINT> (slice 0 = dynamic,  ║
║  │ P │   │ P │   │                          slice 1 = static)   ║
║  ├───┼───┼───┼───┤    Each cell = 128 × 128 px physical page    ║
║  │   │ P │   │ P │    Sized by r.Shadow.Virtual.MaxPhysicalPages║
║  └───┴───┴───┴───┘                                              ║
╠═════════════════════════════════════════════════════════════════╣
║                    Page Table                                   ║
║  Texture2D<uint32>  (one shared 2D texture for all VSMs)        ║
║  Encoding: [bAnyLODValid|bValidForRender|LODOffset|PhysY|PhysX] ║
╚═════════════════════════════════════════════════════════════════╝
```

## Show module boundaries as a dependency map

Label the arrows with the integration mechanism (depends-on, binds-to, registers-with), not just lines.

```
              ┌──────────────────────────────┐
              │  YourGameModule (.uproject)  │
              └──────────────┬───────────────┘
                             │  PublicDependencyModuleNames (Build.cs)
        ┌────────────────────┼─────────────────────┐
        ▼                    ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌─────────────────┐
│ GameplayTags  │    │ GameplayTasks │    │GameplayAbilities│
└───────┬───────┘    └───────┬───────┘    └────────┬────────┘
        │                    └──── binds tasks ───▶│
        └─────── tags drive cooldowns / queries ──▶│
```

## Show file responsibility or a broad refactor as a shallow file tree

```
Engine/
├── Source/Runtime/Engine/
│   ├── Classes/Engine/NetDriver.h
│   │   └── UNetDriver::ServerReplicateActors        // Per-frame replication entry
│   ├── Classes/GameFramework/Actor.h
│   │   ├── AActor::IsNetRelevantFor                 // Per-viewer relevancy check
│   │   └── AActor::IsWithinNetRelevancyDistance     // NetCullDistance gate
│   └── Private/Actor.cpp
│       └── AActor::SetNetUpdateFrequency            // NetUpdateFrequency setter
├── Plugins/Runtime/ReplicationGraph/Source/Private/
│   └── ReplicationGraph.cpp
│       ├── UReplicationGraph::ServerReplicateActors        // RepGraph entry
│       ├── UReplicationGraph::ReplicateActorsForConnection // Per-connection loop
│       └── UReplicationGraph::ReplicateSingleActor         // Single-actor diff/pack
└── Plugins/Runtime/ReplicationSystemTestPlugin/.../
    └── TestPropertyReplicationState.h
        └── UPROPERTY(ReplicatedUsing=OnRep_X)       // Reflection pattern for OnRep
```
