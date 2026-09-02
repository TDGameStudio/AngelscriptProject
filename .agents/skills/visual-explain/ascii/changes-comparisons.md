# Changes & comparisons

## Show a file-layout change as a diff-marked file tree

```diff
 Engine/Source/Runtime/Renderer/Private/VT/
   VirtualTextureSystem.cpp
-  VirtualTextureFeedback.cpp
+  VirtualTextureFeedback.h                 # CPU Map() / in-flight ring
+  VirtualTextureFeedbackResource.cpp       # GPU Begin/End, UAV overlap
 Engine/Shaders/Private/
   VirtualTextureCommon.ush
```

## Show a call-tree or call-stack change as a diff-marked call tree

```diff
 NewObject<T>(Outer, Class, Name, Flags, Template)
   FStaticConstructObjectParameters Params(Class)
   StaticConstructObject_Internal(Params)
     StaticAllocateObject(Class, Outer, Name, ...)
       [Path A] New object
         GUObjectAllocator.AllocateUObject()
-          placement new UObjectBase()
+          FMemory::Memzero + placement new UObjectBase()
             FUObjectArray::AllocateUObjectIndex()
+              HashObject()                       # name lookup table
     InClass->ClassConstructor(FObjectInitializer(...))
```

## Show a state or control-flow change as diff-marked pseudocode

```diff
 StaticAllocateObject(Class, Outer, Name, ...)
-  GUObjectAllocator.AllocateUObject(...)
+  if bCreatingCDO
+    InName = Class->GetDefaultObjectName()     // "Default__ClassName"
+  if InName == NAME_None
+    InName = MakeUniqueObjectName(Outer, Class)
+  else
+    Obj = StaticFindObjectFastInternal(Outer, InName)
+    if Obj && !Obj->GetClass()->IsChildOf(Class)
+      Fatal  // Cannot replace a different class
+  if Obj == nullptr
+    GUObjectAllocator.AllocateUObject(...)     // New object only
```

## Show the same function reached from N entry paths as side-by-side call stacks

Same row index = same stack depth in every column; bottom row tags the dominant path. 2–4 columns max.

```
┌────┬──────────────────────────┬───────────────────────────┬───────────────────────────┐
│    │  UActorComponent::RegisterComponent()  -  call-path comparison                   │
├────┼──────────────────────────┼───────────────────────────┼───────────────────────────┤
│    │  Path A: Editor spawn    │  Path B: Runtime spawn    │  Path C: Hot Reload       │
├────┼──────────────────────────┼───────────────────────────┼───────────────────────────┤
│ #0 │  RegisterComponent()     │  RegisterComponent()      │  RegisterComponent()      │
│ #1 │  AActor::PostEditChange  │  AActor::PostActorCreated │  ReloadObjectsInPackage() │
│ #2 │  FPropertyChangedEvent   │  UWorld::SpawnActor()     │  HotReloadReinstancer     │
│ #3 │  Details panel UI click  │  UChildActorComponent::   │  FModuleManager::Unload   │
│    │                          │    CreateChildActor()     │                           │
├────┼──────────────────────────┼───────────────────────────┼───────────────────────────┤
│    │  [EDITOR ONLY]           │  [RUNTIME - COMMON]       │  [EDITOR / DEV ONLY]      │
└────┴──────────────────────────┴───────────────────────────┴───────────────────────────┘
```

## Show a crash postmortem as a boxed stack with collapse and FIX footer

`#0` is the crash site; collapse boring middle frames; attach `◄──` notes to 2–3 frames only (crash site, contract violation, root cause); end with a `FIX` footer.

```
┌─────┬─────────────────────────────────────────────────────────────────────────────┐
│     │  Crash: null deref in UPrimitiveComponent::UpdateBounds()                   │
├─────┼─────────────────────────────────────────────────────────────────────────────┤
│ #0  │  [CRASH] UPrimitiveComponent::UpdateBounds()       ◄── BodySetup == nullptr │
│ #1  │  UPrimitiveComponent::SendPhysicsTransform()                                │
│ #4  │  USceneComponent::SetWorldTransform()              ◄── called w/ bTeleport  │
│  .  │  ... (12 frames: movement system internals, collapsed) ...                  │
│ #17 │  UCharacterMovementComponent::PerformMovement()    ◄── ROOT CAUSE ENTRY     │
│ #20 │  FEngineLoop::Tick()                                                        │
├─────┼─────────────────────────────────────────────────────────────────────────────┤
│ FIX │  Guard `BodySetup != nullptr` inside SetWorldTransform before               │
│     │  UpdateBounds() runs; see UPrimitiveComponent::RecreatePhysicsState()       │
│     │  for the canonical init order.                                              │
└─────┴─────────────────────────────────────────────────────────────────────────────┘
```

## Show design options side by side as a comparison pair

For resolving a discussion point: one box per option, `+` / `-` rows aligned so trade-offs face each other, and a one-line recommendation below — never leave the comparison unresolved:

```
Where should script GC references be reported?

┌─ Option A: per-object hook ──────────────┐   ┌─ Option B: batch scan in subsystem ──────┐
│ AddReferencedObjects on every AS object  │   │ Single sweep from the engine subsystem   │
│                                          │   │                                          │
│ + Precise, engine-driven timing          │   │ + One call site, easy to profile         │
│ + Works with incremental GC              │   │ + No per-object virtual call cost        │
│ - Hook cost on every object, every GC    │   │ - Sweep can lag one frame                │
│ - Hard to batch                          │   │ - Needs its own dirty tracking           │
└──────────────────────────────────────────┘   └──────────────────────────────────────────┘

Recommendation: Option A — correctness first; revisit batching only if GC profiling demands it.
```
