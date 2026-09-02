# State & lifecycle

## Show a lifecycle as a state machine

```
      UWorld::SpawnActor()
              │
              ▼
      ┌───────────────┐
      │    Created    │      // UObject exists; components registered
      └───────┬───────┘
              │ DispatchBeginPlay()
              ▼
      ┌───────────────┐
      │    Active     │      // Ticking, simulating; replication enabled
      └───────┬───────┘
              │ Destroy() / Level unload
              ▼
      ┌───────────────┐
      │    EndPlay    │      // Unregister ticks, flush delegates
      └───────┬───────┘
              │ FinishDestroy() / GC
              ▼
      ┌───────────────┐
      │   Destroyed   │      // Pending kill; no further calls
      └───────────────┘
```

Label transitions on the arrows; note the invariant of each state beside its box; terminal state has no outgoing arrow.

## Show one buffer mutating as a Before / After pair

Same cell width on both rows, so the structural change is visible by column count alone; the middle band names the operation and the invariant it preserves.

```
Before  (PHYSICAL_PAGE_LIST_LRU, holes left by UpdatePhysicalPages)
┌────┬──────┬────┬──────┬────┬────┬──────┬─────┐
│ 3  │ NONE │ 7  │ NONE │ 1  │ 9  │ NONE │ ... │   # NONE = slot reused
└────┴──────┴────┴──────┴────┴────┴──────┴─────┘

          ───── prefix-sum compact (1 CS group) ─────▶
          // Keep slots where Value != NONE; LRU age order preserved

After   (PHYSICAL_PAGE_LIST_AVAILABLE, dense)
┌────┬────┬────┬────┬─────┐
│ 3  │ 7  │ 1  │ 9  │ ... │                       # head = MRU, tail = LRU
└────┴────┴────┴────┴─────┘
```
