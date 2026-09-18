# Interaction & concurrency

## Show cross-system interaction as a sequence diagram

Timeline runs top → bottom; top and bottom boxes mirror the same participants. `─────>` is a one-way call/RPC, `<───┼───>` is broadcast / replication to multiple peers; label each message with its mechanism (`// Server RPC`, `// NetMulticast`) beside the arrow.

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ Client::Pawn │    │ Server::Pawn │    │ Client::Pawn │
│   (Owner)    │    │              │    │  (Remote 1)  │
└──────┬───────┘    └──────┬───────┘    └──────┬───────┘
       │                   │                   │
       │  Server_Fire()    │                   │
       │ ─────────────────>│                   │
       │  // Server RPC:   │                   │
       │  // validated on  │                   │
       │  // authority     │                   │
       │                   │ Health -= 10      │
       │                   │ // Replicated UPROPERTY, marked dirty
       │                   │                   │
       │                   │  OnRep_Health     │
       │ <─────────────────┼──────────────────>│
       │                   │  // Property repl to all relevant connections
       │                   │                   │
       │                   │ Multicast_PlayFX  │
       │ <─────────────────┤──────────────────>│
       │                   │  // NetMulticast: cosmetic, runs on every peer
       │                   │                   │
┌──────┴───────┐    ┌──────┴───────┐    ┌──────┴───────┐
│ Client::Pawn │    │ Server::Pawn │    │ Client::Pawn │
└──────────────┘    └──────────────┘    └──────────────┘
```

Round-trip variant — a self-loop (`──┐ … <─┘`) marks work a participant does internally, and multi-step processing is written straight down the lifeline:

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│Server::Actor │    │  NetDriver   │    │Client::Actor │
└──────┬───────┘    └──────┬───────┘    └──────┬───────┘
       │                   │                   │
       │ mutate property   │                   │
       │ (marked dirty by  │                   │
       │  ReplicatedUsing) │                   │
       │ ─────────────────>│                   │
       │                   │                   │
       │                   │ next tick:        │
       │                   │ ServerReplicate   │
       │                   │ Actors()          │
       │                   │ ──┐ priority +    │
       │                   │   │ relevancy     │
       │                   │ <─┘ checks        │
       │                   │                   │
       │                   │ FRepLayout::      │
       │                   │ DiffProperties    │
       │                   │ → pack bunch      │
       │                   │ ─────────────────>│
       │                   │                   │
       │                   │                   │ FRepLayout::
       │                   │                   │ ReceivedBunch
       │                   │                   │ → apply value
       │                   │                   │ → CallRepNotifies()
       │                   │                   │ → OnRep_Foo(Old)
       │                   │                   │
┌──────┴───────┐    ┌──────┴───────┐    ┌──────┴───────┐
│Server::Actor │    │  NetDriver   │    │Client::Actor │
└──────────────┘    └──────────────┘    └──────────────┘
```

Compact variant for narrow viewers — same-width boxes, message name on one row and arrow on the next, long notes pushed into `[N]` footnotes:

```
┌──────────┐ ┌──────────┐ ┌──────────┐
│NetDriver │ │FActorCh. │ │ClientAct │
└────┬─────┘ └────┬─────┘ └────┬─────┘
     │            │            │
     │ Replicate  │            │           [1]
     │───────────>│            │
     │            │            │
     │            │ OnRep_Hp   │           [2]
     │            │───────────>│
┌────┴─────┐ ┌────┴─────┐ ┌────┴─────┐
│NetDriver │ │FActorCh. │ │ClientAct │
└──────────┘ └──────────┘ └──────────┘

[1] ServerReplicateActors picks the actor and opens/reuses an FActorChannel for this connection.
[2] FRepLayout::ReceivedBunch applies the value; CallRepNotifies invokes user OnRep_*.
```

Two-participant elbow variant — for a deferred outbound that is still in flight when an inbound arrives first; the elbow (`│──┐` … `└───>`) wraps around the straight arrow that lands mid-flight:

```
 ┌─────────┐ ┌─────────┐
 │   GT    │ │   RT    │
 └────┬────┘ └────┬────┘
      │           │
      │──┐        │                     [1]
      │ FenceN    │
      │<──────────│                     [2]
      │  │        │
      │ ExecRC    │
      │  └───────>│                     [3]
 ┌────┴────┐ ┌────┴────┐
 │   GT    │ │   RT    │
 └─────────┘ └─────────┘

[1] Earlier tick: GT queued Frame N+1 render commands via ENQUEUE_RENDER_COMMAND — GT does not block.
[2] RT signals the Frame N fence; GT wakes and resumes while the queued command is still pending.
[3] RT finally pops the queued command from [1] — the elbow closing on the right shows the deferred dispatch landing.
```

## Show data ownership crossing threads as vertical lanes

```
  Game Thread                 Render Thread                  GPU
  ───────────                 ─────────────                  ───

  UMaterialInstanceDynamic
  ::SetScalarParameterValue       // GT: marks MID dirty; no GPU work yet
        │
        │  ENQUEUE_RENDER_COMMAND // Thread hand-off: lambda captures MID state
        └─────────────────────────▶
                                  │
                                  ▼
                          FMaterialRenderProxy
                          ::GetVectorValue      // RT: resolve scalar for active shader
                                  │
                                  │  RHISetShaderUniformBuffer
                                  └─────────────────────────────▶
                                                                │
                                                                ▼
                                                       Shader cbuffer slot N
```

## Show waits, stalls, and hand-offs as a compact thread timeline

```
══════  executing          ░░░░░  idle / waiting
──────  blocked (OS wait)    ×    stall point
  ▼     enqueue / hand-off

Game Thread:
  ══[Tick · physics · anim]══ BeginFence() ──×──×──×──────────────────── ▶
                                 │    poll: pump GT tasks each round
                                 ▼         // GT is a soft wait, not an OS block
Render Thread:
  ░░░[wait GT cmds]░░ ══[FSceneRenderer::Render()]═══[fence sentinel]~~~~▶
                                                      └─ Trigger() → GT resumes
```

## Show a blocking wait versus a pipe dependency chain on workers

Same timeline symbols as the compact thread timeline; the point is the wasted worker slot in Pattern A versus the free caller in Pattern B:

```
Pattern A - Task.Wait() on a worker (wastes a worker slot)

  Caller (Worker Wc):
  ══ Launch(T1) ══ T1.Wait() ─────────────────────────────── ══[next]══ ▶
                      │  × OS thread blocked; Wc cannot pick other tasks
                      ▼
  Worker Wx:  ░░ ══[T1]══════════════════════════════════════▶ signal

Pattern B - FPipe dependency chain (zero caller blocking)

  Caller (any thread):
  ══ Pipe.Launch(T1) ══ Pipe.Launch(T2) ═══════════════════════════════ ▶
        │ non-blocking      │ T2 waits on T1 via NumLocks / Subsequents
        ▼                   ▼
  Worker A:  ░░ ══[T1]══════▶ Close() → TryUnlock(T2)
  Worker B:  ░░░░░░░░░░░░░░░░░░░░░░░░ ══[T2]══════════════════════════▶

  Rule: NEVER Task.Wait() from inside a TaskGraph worker — use FPipe or explicit prerequisites.
```

## Show parallel pipes merging into one task as a dependency timeline

Three views of the same story stacked in one figure: the caller's launch calls, the task dependency graph, and the worker occupancy:

```
Caller (e.g. Render Thread):
  PipeA.Launch(A1); PipeA.Launch(A2);   // Serial A1 → A2 inside PipeA
  PipeB.Launch(B1); PipeB.Launch(B2);   // Serial B1 → B2 inside PipeB
  PipeC.Launch(C1);
  Launch(Merge, {A2, B2, C1}, ...);     // Non-blocking wait on last task per pipe
  ▼ returns immediately

Task dependency graph:
  PipeA:  A1 ──▶ A2 ──┐
  PipeB:  B1 ──▶ B2 ──┼──▶ [Merge]   (NumLocks = 3 until A2,B2,C1 all complete)
  PipeC:  C1 ─────────┘

Workers:
  W0: ░░ ══[A1]══▶ ══[A2]══▶ done ──▶ Merge.NumLocks 3→2
  W1: ░░ ══[B1]══▶ ══[B2]══▶ done ──▶ Merge.NumLocks 2→1
  W2: ░░ ══[C1]════════════▶ done ──▶ Merge.NumLocks 1→0  schedule Merge
  W3:                              ░░░ ══[Merge]══▶
```

## Show cross-thread teardown ordering as a fence timeline

```
Game Thread:
  ══[...]══ BeginDestroy() ── ENQUEUE_RENDER_COMMAND(ReleaseRenderResources)
            BeginFence() ── Fence.Wait() ──×────────────────── ══ FinishDestroy() ▶
                                              │ (soft stall; may pump GT tasks)
Render Thread:
  ░░ ══[ReleaseRenderResources]══[fence sentinel]~~~~▶ Trigger → GT resumes

  Invariant: GPU/RHI refs released on RT before GC reclaims UObject CPU memory.
```

## Show an atomic hand-off race as a state trace

Borderless step-by-step trace of an atomic exchange, with the race case spelled out explicitly:

```
FPipe::LastTask state machine

  (empty)  LastTask ──▶ nullptr
  Launch(T1): exchange(&T1) → old=nullptr  → T1 NumLocks→0  ready
  Launch(T2): exchange(&T2) → old=T1
              T1.AddSubsequent(T2) OK  → T2 waits on T1
              chain: T1 → T2 → T3

  Race: Launch(T2) while T1 completes concurrently
    exchange(&T2) → old=T1
    T1.AddSubsequent(T2) FAIL (T1 already Close())
    → T2 does NOT wait; TryLaunch schedules T2 immediately
```

## Show frames in flight across threads as a boxed multi-thread swimlane

The heavyweight option — use only when frame overlap itself is the topic. All lanes share one column grid; each lane is offset by whole frame slots to encode its lag, and each box writes its own frame number so the offset against the header row self-documents the latency. A Snapshot row reads any vertical column; `[N]` call-outs expand in the Sync Key block:

```
┌─────────────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│             │  Frame N+0                   Frame N+1                   Frame N+2                   Frame N+3                       │
│             │  (GT-frame timeline; each column = one 16ms GT tick slot. RT/RHI lag = horizontal offset of their boxes.)            │
├─────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│             │                                                                                                                      │
│             │  ┌────────────────────────┐  ┌────────────────────────┐  ┌────────────────────────┐  ┌────────────────────────┐      │
│ Game Thread │  │ Frame N+0              │  │ Frame N+1              │  │ Frame N+2              │  │ Frame N+3              │      │
│   (GT)      │  │ UWorld::Tick()         │  │ UWorld::Tick()         │  │ UWorld::Tick()         │  │ UWorld::Tick()         │      │
│             │  │ FPhysScene::Tick()     │  │ FPhysScene::Tick()     │  │ FPhysScene::Tick()     │  │ FPhysScene::Tick()     │      │
│             │  │ Anim · GC · ENQ_RC     │  │ Anim · GC · ENQ_RC     │  │ Anim · GC · ENQ_RC     │  │ Anim · GC · ENQ_RC     │      │
│             │  └────────────┴───────────┘  └────────────┴───────────┘  └────────────┴───────────┘  └────────────┴───────────┘      │
│             │               │ [1] FFrameEndSync::Sync() │ [1]                       │ [1]                       │ [1]              │
│             │               ▼                           ▼                           ▼                           ▼                  │
│             │                                                                                                                      │
│             │                              ┌────────────────────────┐  ┌────────────────────────┐  ┌────────────────────────┐      │
│ RenderThread│    (cold: wait GT fence)     │ Frame N+0              │  │ Frame N+1              │  │ Frame N+2              │      │
│   (RT)      │                              │ FSceneRenderer::       │  │ FSceneRenderer::       │  │ FSceneRenderer::       │      │
│             │                              │   Render() [2]         │  │   Render() [2]         │  │   Render() [2]         │      │
│             │                              └────────────┴───────────┘  └────────────┴───────────┘  └────────────┴───────────┘      │
│             │                                           │ [3] ImmediateFlush        │ [3]                       │ [3]              │
│             │                                           ▼                           ▼                           ▼                  │
│             │                                                                                                                      │
│             │                                                          ┌────────────────────────┐  ┌────────────────────────┐      │
│  RHI Thread │    (cold x 2: wait for RT FinishRecording)               │ Frame N+0              │  │ Frame N+1              │      │
│   (RHI)     │                                                          │ Translate FRHICmd      │  │ Translate FRHICmd      │      │
│             │                                                          │ Present() · Fence[4]   │  │ Present() · Fence[4]   │      │
│             │                                                          └────────────────────────┘  └────────────────────────┘      │
│             │                                                                                                                      │
├─────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  Snapshot   │  At t = 48ms (Frame N+3 GT tick begins):                                                                             │
│  @ t=48ms   │    GT  --> processing Frame N+3   -- input sampling · physics · animation                                            │
│             │    RT  --> processing Frame N+2   -- culling · shading · post-process                                                │
│             │    RHI --> processing Frame N+1   -- translate · SetPSO · DrawCall · Present                                         │
│             │    GPU --> rasterizing Frame N    -- vertex · pixel shader · ROP    <-- actual pixels on screen                      │
├─────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  Sync Key   │  [1] FFrameEndSync::Sync(EFlushMode)  -- GT max 1 frame ahead of RT (ESyncDepth::RenderThread)                       │
│             │  [2] FVisibilityTaskData::LaunchVisibilityTasks() -- parallel FrustumCull / OcclusionCull / Relevance                │
│             │  [3] FRHICommandListImmediate::ImmediateFlush(EImmediateFlushType::DispatchToRHIThread)                              │
│             │  [4] ESyncDepth::RHIThread fence signalled  ▶ unblocks GT PipelineFences.Wait()                                      │
└─────────────┴──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```
