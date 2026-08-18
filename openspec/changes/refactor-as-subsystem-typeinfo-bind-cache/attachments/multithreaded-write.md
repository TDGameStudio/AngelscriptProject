# Multithreaded TypeBindInfo writes

Research note (Knot UE5-main + this plugin). Does not implement C++.

## Verdict

**Expand can write in parallel. The sealed subsystem array cannot.**  
Do not make `TypeBindInfos.Add` / `TypeBindInfoIndexByName.FindOrAdd` lock-free concurrent APIs. Use Unreal's existing write patterns.

**Apply (`Register*` into one `asIScriptEngine`) stays sequential.** That is still the follow-on in `as-engine-threaded-registration-follow-on.md`.

After `Sealed`, the array is immutable. Extra engines may **read** it without a lock. They must not append.

## What UE actually uses (Knot)

UE does not have a general concurrent `TMap`/`TArray` for this job. Recurring patterns:

| Pattern | Where | Use here? |
|---|---|---|
| **Pre-size, unique index write** | `ParallelFor(N, [&](int32 i){ Out[i] = ... })`. GC verification writes disjoint `GUObjectArray` slices. | Yes when the type/class list is already captured. |
| **`ParallelForWithTaskContext`** | `Async/ParallelFor.h`: one context object per worker (`AddDefaulted(NumContexts)`), body writes only `Context`. Caller merges after join. Chaos `PhysicsParallelForWithContext`, Zen oplog summaries. | **Preferred for Explicit fill shards.** |
| **`TQueue<T, EQueueMode::Mpsc>`** | Niagara export, FindInBlueprint `AssetsPendingGatherQueue`, ODSC, AssetSearch. Many producers enqueue; **one** thread drains. Comments say gather from a loaded object must be Game Thread. | Optional for "need GT" work items. **Not** the TypeBindInfo catalog (no name lookup). |
| **`FCriticalSection` around `TMap`** | Mutable `FBoneNames` (`TMap` + CS), Android device map. | Merge / name-index insert only. Not on every `.Method()`. |
| **Lock-free allocators** | `TLockFreeFixedSizeAllocator`, `TLockFreePointerListUnordered`. Stats, pools. | Wrong shape for a named type catalog. |
| **Game Thread for UObject iterators** | `TActorIterator` asserts GT. `GetIsEditorLoadingPackage` `ensure`s off GT/ALT. AudioBus `TObjectIterator` gated by `IsInGameThread()`. | Capture `UClass*` lists on GT. Do not `TObjectRange` from workers. |

There is no engine `TConcurrentHashMap` that we should adopt for TypeBindInfo.

Named UE call sites and match/mismatch notes: `ue-analogs.md`.

## What this plugin already does

`Bind_BlueprintType` is the local template:

1. Game Thread: visit/`TObjectRange`, build `ClassesToBind` (stable indices).
2. `ParallelFor(ClassesToBind.Num(), PreparePerClass, Unbalanced)` writes **only** `ClassesToBind[Index].FunctionPreps`. Each class is exclusive. CVar `as.Bind.ParallelPrepare`.
3. Game Thread Phase 2B: `ensure(IsInGameThread())`, then `Register*` / BindDB commit.

`AngelscriptEngine` compile uses the same idea: disjoint module slices, `BuildParallelParseScripts`, then a serial stage.

Do **not** invent a new concurrency model for TypeBindInfo. Lift this prepare/commit split.

## What “parallel Register” actually means

A single `RegisterFVector` is **not** multithreaded. `.Constructor()` then `.Method("Size")` in that function still run on one worker, in order.

Parallelism is **across providers**, not inside one Register function:

```text
Explicit pass (allowlisted only):

  Thread 0: RegisterFVector(Shard0)     // writes only Shard0["FVector"]
  Thread 1: RegisterFRotator(Shard1)    // writes only Shard1["FRotator"]
  Thread 2: RegisterFQuat(Shard2)
  join
  Game Thread merge → Store.TypeBindInfos
```

`RegisterFVector` never calls `Subsystem.TypeBindInfos.Add`. It writes a **private** `TArray`+`TMap` that dies after merge.

### Can this Register function run in parallel?

| Register function | Parallel? | Why |
|---|---|---|
| `RegisterFVector` / `RegisterFRotator` / other POD math | **Yes, if allowlisted** | UObject-free; only touches its own type name; sibling fills do not need to see `Size()` during expand |
| `RegisterTArray` | Usually **yes** (Explicit pass) | Recording no longer needs `TArray.Add` to land before other Register functions; ApplySlot=Infrastructure fixes Apply order |
| `RegisterFColor` that `FindOrAdd("FLinearColor").Method("ToFColor")` | **Yes, if FindOrAdd** | Merge appends `ToFColor` onto the `FLinearColor` row from `RegisterFLinearColor`. **No** if it `MustFind` and expects the other Register function to have already finished |
| `RegisterAActor` that `MustFind("AActor")` | **No** (or after Reflection merge) | Needs the Blueprint generator’s row. Put it in the Reflection pass after merge, or `FindOrAdd` and merge |
| `RegisterBlueprintTypes` / `RegisterUStructs` | **Not as Register shards** | `TObjectRange` / BindDB stay Game Thread. Inner unique-index `ParallelFor` over `ClassesToBind[i]` is a different, already-existing pattern |

Default for unknown Register function: Game Thread sequential. Parallel is opt-in allowlist.

### What a worker is allowed to see

During `RegisterFVector` on a worker:

- Its own shard (types it just `Value()`/`FindOrAdd`ed)
- Rows **already merged** from earlier record passes (`Generated` does not run yet in the Explicit pass)
- **Not** `RegisterFRotator`’s in-progress shard

So do not write an Explicit Register that does `HasMethod("FRotator", "opAdd")` while `RegisterFRotator` might be on another worker. POD math fills do not do that; they only name their own type.

Cross-type **patches** must use `FindOrAdd`, not `MustFind`, if those two Register functions are in the same parallel pass.

### Two parallel shapes (do not mix them)

1. **Provider shards** — many Register functions, each a private store, merge by type name. For Explicit POD.
2. **Unique index** — one generator already built `ClassesToBind[0..N)`, `ParallelFor` writes only slot `i`. For BlueprintType prepare.

Neither is “lock-free `TypeBindInfos.Add`”.


### A. Explicit fills (FColor, FVector) — shard then merge

Within one RegisterKind pass, allowlisted UObject-free fills:

```text
ParallelForWithTaskContext(Shards, ProviderCount,
  [&](FTypeBindInfoShard& Shard, int32 ProviderIndex)
  {
      RegisterBinds[ProviderIndex](Shard.Store);  // private TArray + TMap
  });
// join
MergeShardsInto(Subsystem.TypeBindInfos);  // Game Thread, by AngelscriptTypeName
```

Merge: same name → append members, reject kind conflicts.  
`ExistingClassForTarget` during a worker fill sees **that shard plus already-merged previous RegisterKind passes**, not live sibling shards.

That is why parallelism is **within a RegisterKind pass**, after earlier passes are merged.

### B. Reflection (BlueprintType) — unique index, not a shared map

Keep today's capture → ParallelFor prepare. Each `ClassesToBind[i]` becomes `TypeBindInfos` slot `i` (or a reserved range). Workers fill members on **their** row. No `FindOrAdd` across threads. Actor `Spawn` is written on that same row in `RegisterBlueprintTypes`, not a second PostReflection bind.

### C. Do not

- `FCriticalSection` on every `Store.Method()` (serializes the cheap path).
- Concurrent `Add` on `UAngelscriptSubsystem::TypeBindInfos`.
- `TQueue` as the process catalog.
- Worker `TObjectIterator` / `FindObject` / `GetTargetEngine()->Register*`.
- Mutating TypeBindInfo after `Sealed`.

## Cost reminder

Parallel Explicit fills are cheap. The win that already exists is BlueprintType **prepare**. TypeBindInfo should **preserve** that ParallelFor, then sequential apply still does `Register*`. First-engine bind does not become concurrent registration.
