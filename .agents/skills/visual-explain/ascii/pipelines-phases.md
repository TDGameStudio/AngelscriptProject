# Pipelines & phases

## Show frame stages as a top-down stage pipeline

Left column = phase name; right column = representative work, with the trailing `//` stating what becomes valid for the next phase; nothing reads back upward:

```
─────────────  UWorld::Tick (per frame)  ─────────────

TG_PrePhysics         AActor::Tick (default tick group)     // Gameplay input before physics write
      │               UActorComponent::TickComponent
      ▼
TG_StartPhysics       Begin physics scene step              // Kick Chaos / PhysScene
      │
      ▼
TG_DuringPhysics      UCharacterMovementComponent::PerformMovement
      │               Chaos solver step                     // Constraints + integration
      ▼
TG_EndPhysics         Read back physics results             // Poses -> scene components
      │
      ▼
TG_PostPhysics        Animation update, post-physics game logic
      │
      ▼
TG_PostUpdateWork     Camera follow, UI, late updates       // Consumers of final transforms

─────────────  End of frame  ─────────────
```

## Show ordered execution phases as a banner-separated phase pipeline

```
==============================================================================
                    Phase 1: Visibility Computation
==============================================================================
FDeferredShadingSceneRenderer::Render()
└─ BeginInitViews()
    └─ LaunchVisibilityTasks()
        ├─ [Phase 1] CreateViewPackets()               // One packet per FViewInfo
        ├─ [Phase 2] SetupTaskDependencies()           // Frustum before occlusion
        └─ [Phase 3] LaunchFrustumCull()
            └─ FrustumCull(...)                        // Outputs visible primitive set
```

## Show a sequence of GPU / RDG passes as boxed steps with per-pass resource access

Each pass box: left = step name, right = `R / W / RW <resource>` per line; footer explains the access-tag legend and any ordering nuance.

```
VSM BuildPageAllocations  —  RDG passes & resource access (condensed)
# Engine/Source/Runtime/Renderer/Private/VirtualShadowMaps/VirtualShadowMapArray.cpp

┌──────────────────────────────┐
│ 1. UpdatePhysicalPages       │  R  PageRequestFlags
│                              │  RW PhysicalPageLists   (LRU → REQUESTED / EMPTY)
│                              │  RW PageTable, RW PageFlags
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│ 2. PackAvailablePages        │  RW PhysicalPageLists   (LRU → AVAILABLE,
│    (single CS group, 1024)   │                          prefix-sum compact)
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│ 3. AllocateNewPageMappings   │  R  PageRequestFlags
│                              │  RW PageTable, RW PageFlags
│                              │  RW PhysicalPageLists   (Pop AVAILABLE.tail)
└──────────────────────────────┘

# Access tags:  R = SRV (readonly),  W = UAV write-only,  RW = UAV read-write.
# Sequence is strict: each pass depends on the previous via RDG handles.
```

## Show policy bands over a continuous value as a threshold bar

For a metric sliced into named behavior ranges (occupancy, distance, budget) — band widths follow the real ranges, and the row below anchors what sets each boundary.

```
Texture Streaming Pool occupancy  ─  r.Streaming.PoolSize behaviour bands

  0%             ~50%           ~70%             ~90%            100%
  ├──────────────┼──────────────┼────────────────┼───────────────┤
  │   IDLE       │  WARMING     │  LAZY STREAM   │  STALL MODE   │
  │  fully       │  prefetch on │  drop low LOD  │  block on     │
  │  resident    │  movement    │  to free pool  │  uploads      │
  └──────────────┴──────────────┴────────────────┴───────────────┘
            ▲                ▲                  ▲                ▲
       PoolMargin       LazyStreamPct       StallPct        HardCap
       (default 50)     (default 70)        (default 90)    (evict last mip)
```

## Show measured time cost as a width-proportional profile bar

Cell width is proportional to measured time — the biggest box is the optimization target by construction. Pick this over the threshold bar when the axis is spent time, not a policy value:

```
GT frame, measured 16.6 ms total  (width ∝ time)

|◀───────────────────────────── 16.6 ms ───────────────────────────▶|
┌──────────────────────────┬──────────┬────────────────┬────┬───────┐
│ TickActors        7.1 ms │ Phys 2.8 │ Anim     4.2   │ GC │ Slack │
│                          │          │                │1.1 │  1.4  │
└──────────────────────────┴──────────┴────────────────┴────┴───────┘
        ▲
        └─ 43% of the frame — first optimization target
```
