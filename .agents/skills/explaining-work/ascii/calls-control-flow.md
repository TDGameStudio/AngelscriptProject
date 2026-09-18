# Calls & control flow

## Preferred annotated caller and callee view

- Use this unboxed shape for explanations; replace placeholders with verified source identifiers and explain each meaningful node.
- The complete original examples below remain available. Their abbreviated labels are shape hints, not the explanation standard for a new reader.

```text
<entry or trigger>                                      // Starts this operation when <condition> holds.
└─[calls] <Caller>::<Method>(<key args>)                 // Establishes <state> and chooses the subject.
   └─[calls] <Subject>::<Method>(<key args>) ◆           // Owns the behavior under discussion.
      ├─[calls] <Helper>(<arg>) → <result>              // Computes <meaning> and preserves <invariant>.
      └─[writes] <Store>.<Operation>(<key>, <value>)     // Publishes data consumed by <next stage>.

<Consumer>::<Method>()                                  // Runs at <later lifecycle point>.
└─[reads] <Store>                                       // Uses <result>; absence causes <actual behavior>.
```

## Show runtime control flow as a call tree

```
NewObject<T>(Outer, Class, Name, Flags, Template)  // User template entry
├─ FStaticConstructObjectParameters Params(Class)  // Pack Outer/Name/Flags/Template
└─ StaticConstructObject_Internal(Params)
    ├─ StaticAllocateObject(Class, Outer, Name, ...)   // Allocate + register in GUObjectArray
    │   ├─ [Path A] New object
    │   │   └─ GUObjectAllocator.AllocateUObject()
    │   │       └─ placement new UObjectBase()
    │   │           └─ FUObjectArray::AllocateUObjectIndex()  // Index + SerialNumber
    │   │               └─ HashObject()                       // Name lookup table
    │   │
    │   └─ [Path B] Replace existing (same Name+Class+Outer)
    │       └─ BeginDestroy → FinishDestroy → FreeUObjectIndex → placement new
    │
    └─ InClass->ClassConstructor(FObjectInitializer(...))     // User ctor + subobjects
```

When prose cross-references steps by number, number the top-level rows:

```
FSceneRenderer::Render()
  ├─1─ VirtualShadowMapArray.Initialize()       // Alloc pool, assign VSM ids
  ├─2─ BeginMarkVirtualShadowMapPages()         // Tag screen-covered pages
  ├─3─ BuildPageAllocations()                   // LRU evict + assign physical pages
  ├─4─ RenderVirtualShadowMaps[Nanite|NonNanite]()
  └─5─ ExtractFrameData()                       // Ping-pong page table for next frame
```

## Show branches, guards, and early exits as a flowchart

```
SpawnActor(Class, Transform, Params)
  │
  ▼
[ IsValid(Class) ? ]                          // Guard: Class must resolve to a spawnable type
  ├── No  ──▶ return nullptr                  // Early exit: no UObject allocated
  └── Yes
        │
        ▼
      [ Params.bDeferConstruction ? ]         // Split: full init now vs. deferred FinishSpawning
        ├── Yes ──▶ return uninitialized actor // Caller owns it until FinishSpawning
        └── No
              │
              ▼
            PostSpawnInitialize()             // CS, component registration, collision setup
              │
              ▼
            DispatchBeginPlay()               // Fan-out BeginPlay to actor + components
              │
              ▼
            return NewActor                   // Fully initialized, ticking-eligible
```

## Show one decision with many outcomes as a nested decision tree

When a single decision fans out into many leaves, a tall `▼` chain gets unreadable — indent the conditions as a tree instead; every terminal action sits on its own row:

```
UpdatePhysicalPages — per physical page
├─ MetaData.Flags == 0
│   └── push to LIST_EMPTY                        // Never owned anything yet
└─ MetaData.Flags != 0
    ├─ bRequestedThisFrame || Age <= MaxPageAge
    │   └── push to LIST_REQUESTED                // (Re)bind virtual→physical
    └─ else (expired)
        └── clear Flags, push to LIST_EMPTY       // Ready for reuse
```

## Show a polling or retry loop as a flowchart with a back-edge

Mark where the flow re-enters (`◄──┐ … ──┘`) and which branch breaks out of the loop:

```
HotReload watcher loop
  │
  ▼
[ Change queue empty ? ] ◄──────────────┐
  ├── Yes ──▶ Sleep(250ms) ─────────────┤   // Poll interval
  └── No                                │
        ▼                               │
      CompileModule(File)               │
        ▼                               │
      [ Compile OK ? ]                  │
        ├── No ──▶ log, keep old ───────┤   // Old bytecode stays live
        └── Yes                         │
              ▼                         │
            ReinstanceClasses() ────────┘   // Back to poll
```

## Show parallel work that must rejoin as a fork-join flowchart

Independent branches fan out at the fork; the join row states what must all finish before the flow continues:

```
LaunchVisibilityTasks()
  │
  ├──────────────┬──────────────┐           // Fork: tasks run in parallel
  ▼              ▼              ▼
FrustumCull  OcclusionCull  RelevanceCompute
  │              │              │
  └──────────────┴──────────────┘
                 │                          // Join: all three must complete
                 ▼
         FinalizeVisibleSet()
```

## Show ordered fallback paths as a cascade flowchart

Alternatives tried in order; each failing guard drops to the next-cheaper (or always-correct) path:

```
Resolve function binding
  │
  ▼
[ Exact JIT provider match ? ]              // Module key + content + ABI all equal
  ├── Yes ──▶ bind native entry             // Fastest path
  └── No
        ▼
      [ Cache V2 restore hit ? ]
        ├── Yes ──▶ bind restored bytecode
        └── No
              ▼
            fall back to VM                 // Always-correct last resort
```

## Show a core loop or heuristic as an algorithm sketch

```
ServerReplicateActors(DeltaTime):
  │
  ├─ Build consider list:
  │    skip dormant / hidden / out-of-range.   // Shrink work before per-connection cost
  │
  ├─ For each NetConnection:
  │    ├─ Prioritize actors:
  │    │    score = NetPriority
  │    │          * (1 / DistSq)               // Nearer actors win bandwidth
  │    │          * (1 + TimeSinceLastUpdate)  // Starved actors catch up
  │    │
  │    └─ For each actor (until bandwidth exhausted):
  │         ├─ IsNetRelevantFor()              // Per-viewer filter
  │         ├─ ReplicateActor:
  │         │    diff properties → dirty set   // Only changed props on wire
  │         └─ Update LastUpdateTime           // Prevents duplicate same-frame send
  │
  └─ Flush send buffers.                       // Push bits to socket layer
```
