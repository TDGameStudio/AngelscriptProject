# Lifetime, Host And Dispatch Notes

## Scope

This attachment records implementation evidence and problems discovered while
working through tasks 7.1-7.5. Detailed observations live here so `tasks.md`
remains a concise verified checklist.

## Active Binding Reader Versus Engine Shutdown

The Group 6 review retained one explicit Group 7 risk. Maintained-fork
`SetJITCompiler(nullptr)` clears every current Binding, but a Binding used by an
active execution reader is moved to the function's retired Binding list. That
retired record stores the original `asIJITCompiler*` owner and calls
`ReleaseFunctionBinding()` only after the last reader exits.

The Engine teardown sequence previously detached the compiler and immediately
deleted `FAngelscriptJITCoordinator`. This created two related hazards:

- the final reader could call `ReleaseFunctionBinding()` through a deleted
  coordinator owner;
- the coordinator destructor could destroy Runtime Binding contexts and their
  executable-code leases while native code was still executing.

The selected boundary is an explicit idempotent coordinator shutdown/drain:

1. close admission for new Binding publication;
2. detach the coordinator from the Engine, retiring all current Bindings and
   making later calls use VM;
3. cancel and drain Runtime compilation work;
4. wait without holding the Binding mutex until every provider and Runtime
   Binding context has been released by the maintained-fork reader lifecycle;
5. only then release the coordinator and continue Engine destruction.

Published Runtime code also retains the backend session that created it. Field
destruction order releases the executable code lease before the final session
reference, so a backend session cannot disappear while one of its entries is
still callable.

The first TDD case will block a real Runtime VMEntry, begin coordinator
shutdown on another thread, and require all of the following before unblocking
the old entry: the compiler is detached, a new invocation executes through VM,
shutdown has not returned, and neither the code lease nor backend session has
been released. The old invocation then exits and must release both resources
exactly once before shutdown returns.

## Task 7.1 Evidence

RED was a compile failure because the coordinator exposed no shutdown/drain
protocol:

- `Saved/Build/jit-coordinator-shutdown-drain-red/20260814_043922_413_736c6d5d`

The implementation adds an idempotent serialized `Shutdown()`. Binding
publication rejects admission after shutdown begins; detachment retires current
Bindings; the Runtime state machine cancels and joins admitted work; and a
manual-reset event waits for both provider and Runtime Binding-context maps to
be emptied by maintained-fork reader release callbacks. The Engine destructor
uses this protocol before deleting the coordinator.

Validation:

- full 136-action Editor build PASS:
  `Saved/Build/jit-coordinator-shutdown-drain-green/20260814_044054_649_faec46ce`;
- active Runtime reader versus factory unregister and shutdown `1/1 PASS`:
  `Saved/Tests/jit-coordinator-factory-unregister-shutdown-green/20260814_044725_619_e1abb3ec`;
- active old Runtime call across `Runtime -> exact AOT -> new Runtime`
  replacement `1/1 PASS`:
  `Saved/Tests/jit-coordinator-active-replacement-green/20260814_044620_815_fbc1cc46`;
- matching incremental build PASS:
  `Saved/Build/jit-coordinator-active-replacement-green/20260814_044601_624_36ab668d`.

The shutdown case unregisters the selected fake factory before shutdown begins.
The session and code lease remain alive while the old entry is blocked; the
compiler is already detached and a new call executes through VM. Only after the
old reader exits do the code lease and session each release once and shutdown
return, which is the point at which an owning Runtime module may finish unload.

The replacement case holds the first Runtime entry active, publishes an exact
AOT Binding for new readers, removes that Provider, publishes a distinct second
Runtime Binding, and executes through both replacement tiers. The first code
lease remains retained across both replacements and is released only when the
old invocation returns; the current second lease remains until coordinator
shutdown.

## Runtime Result And Storage Isolation

Runtime publication remains Engine-local. It installs only a VMEntry Binding on
the exact live function owned by that Engine; it does not register an AOT
Provider, invoke Static generation, or write Runtime code into Cache V2,
precompiled-data, or typed-HIR storage. Cache V2 may still capture the ordinary
AngelScript bytecode transaction during a test Engine compile; that existing
bytecode cache activity is independent from Runtime native-code publication.

The isolation coverage combines behavioral and source-boundary checks:

- `RuntimePublicationDoesNotMutateTheAotProviderRegistry` compares the AOT
  registry publication ordinal and Provider count before Runtime publication,
  after publication, and after Engine teardown;
- `TwoEnginesOwnIsolatedRuntimeSessionsBindingsAndTeardown` proves two Engines
  selecting the same factory own distinct sessions, bindings, requests, and
  teardown;
- `RuntimePublicationFilesHaveNoAotOrPersistentCacheSink` rejects AOT registry,
  Static generation, Cache V2, precompiled-data, and typed-storage sink symbols
  from the Runtime publication surface.

## Whole-Function Eligibility And Fallback

Eligibility is decided for the entire function. A scalar function may publish
one Runtime VMEntry. A function with an unsupported stable helper token reaches
the selected backend exactly once and memoizes the typed unsupported result. A
suspend/latent profile, managed-value profile, cleanup/exception profile,
receiver profile, malformed snapshot, or Entry ABI mismatch fails closed before
concrete backend work where the contract can determine that outcome.

No RawEntry or ParmsEntry is synthesized for an unsupported function. The
function retains an entirely empty Runtime Binding and executes wholly through
the VM. During fixture development, constructing an `FString` inside the
managed-value function also introduced a reference-bearing operand and correctly
failed closed earlier. The final managed-value fixture therefore uses a
`const FString&` parameter, isolating and proving the intended profile gate.

Validation evidence:

- complete Snapshot prefix `10/10 PASS`:
  `Saved/Tests/jit-group7-snapshot-final/20260814_053024_496_8ba12ffc`;
- complete Routing prefix `12/12 PASS`:
  `Saved/Tests/jit-group7-routing-final-rerun/20260814_053300_255_91741950`.

## Debugger, Coverage And Reflected Dispatch

Runtime native publication is suppressed while the DebugServer requires
bytecode visibility (active debugging, data breakpoints, or break-next-line) or
while CodeCoverage is attached to the Engine. This is a Runtime-only gate:
exact Static AOT selection remains valid in `Auto`, and lifting the debugger
gate allows a fresh exact Runtime request to publish at the next safe point.

`UASFunction` optimized-call coverage publishes a VMEntry-only Binding while a
stale raw-entry cache value is deliberately present. The reflected call returns
through the current VM/context path, invokes the current Runtime VMEntry exactly
once, and never fabricates RawEntry or ParmsEntry.

Focused evidence:

- DebugServer gate `1/1 PASS`:
  `Saved/Tests/jit-group7-debug-gate-green/20260814_051941_180_9258ff12`;
- CodeCoverage/AOT preservation `1/1 PASS`:
  `Saved/Tests/jit-group7-coverage-gate-green/20260814_052044_377_0f81e3d6`;
- reflected VMEntry-only dispatch `1/1 PASS`:
  `Saved/Tests/jit-group7-uasfunction-vmentry-only/20260814_052316_555_415a6f8f`.

## Worker And Lowering Boundary

The Runtime backend ABI, registry, session owner, request state machine, and
worker-visible publication structures are explicitly scanned for forbidden
Engine/host dependencies and storage surfaces. The boundary rejects direct
UObject, UFunction, Blueprint, ClassGenerator, World, GC, Editor, typed-HIR,
typed-AST, and StaticJIT APIs, together with persistent/AOT storage sinks.

Validation: boundary prefix `2/2 PASS` at
`Saved/Tests/jit-group7-runtime-boundary/20260814_052421_077_e43c4859`.
