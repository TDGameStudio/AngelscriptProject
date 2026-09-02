# TestSource Contract V2 plan review guide

Date: 2026-08-24  
Status: review draft; no TestSource source implementation is authorized by this document.

## What the reviewer is accepting

The plan is not a request to approve a mechanical rename. It asks the reviewer to accept five linked choices for every source/callable:

1. stable CaseId/subcase and owner-qualified current identity;
2. semantic replacement name and exact AngelScript declaration;
3. caller-controlled inputs plus raw return/out/inout observation channels;
4. exact immediate English knowledge comment, fixture/invocation phase, and cleanup boundary;
5. concrete vectors/diagnostics and a truthful source/compile/runtime/external-oracle status.

An accepted row is frozen by its normalized-record hash. Changing its declaration, vectors, comment, fixture, cleanup, or body constraints invalidates acceptance and returns it to review.

## Corpus boundary

- 3,041 authored `.as` sources.
- 11,987 current owner-qualified callable identities.
- 249 sources with no callable; these use source-only assertions and never receive a fake no-op function.
- 12,624 normalized plan rows: 12,327 proposed callable declarations, 48 explicit retirements, and 249 source-only assertions.
- 7,494 rows are design-review-ready; 5,130 rows stay blocked on named evidence. Those rows expand to 16,290 field-level `D` tasks rather than silently deferring decisions to an implementation agent.
- `tasks.md` contains 31,975 checkboxes in total, including 3,041 per-file verification tasks and 20 plan/protocol/full-corpus closure gates.
- Writable future implementation scope remains `TestSource/**` plus this OpenSpec. Plugin/runner/C++ sources are read-only evidence unless the user later widens scope.
- Existing Contract V2 tooling under `TestSource/Generation/**` is an unaccepted implementation snapshot. Its 97-test GREEN record is evidence for later re-review, not permission to continue source migration now.

## Naming and signature decisions

- `Observe_*`, `SurfaceNNN`, `_Nominal`, and generic `ExerciseExpectedFailure` are hard-renamed; no forwarding alias remains.
- UE/TestFramework/reflection-required names such as `BeginPlay`, `Tick`, Blueprint overrides, FName-bound timer/delegate handlers, imports, events, and discovery hooks stay exact and carry `requiredNameReason`.
- Expected values live in typed vectors, never in `Expected*`/`bExpect*` AngelScript parameters.
- Raw API returns are returned directly. Multiple raw results use `&out`; mutated receivers/containers use `&inout`.
- A raw Boolean API may return `bool`; a Boolean synthesized from several comparisons is not an acceptable sole oracle.
- Every proposed function is an independent task checkbox. A 1-to-N split is visible as N declarations, not hidden in a file-level instruction.

## High-risk decisions to inspect first

### TArray

The Bindings pilot replaces 45 current callables with 68 exact semantic callables across eight files. Examples:

```angelscript
int32 ReadIndexedValue(const TArray<int32>&in Values, int32 Index)
int32 WriteIndexedValue(TArray<int32>&inout Values, int32 Index, int32 Replacement)
bool AddUniqueValue(TArray<int32>&inout Values, int32 Value)
void ReserveArrayCapacity(TArray<int32>&inout Values, int32 ReservedSize, int32&out Capacity)
```

The separate Containers/TArray audit covers 58 sources, 98 current callables, and 145 proposed declarations. It corrects several false assumptions: `TS-CONT-0051` is a nested-container compile diagnostic, `TS-CONT-0137` is positive permissive float-index behavior, `TS-CONT-0092` is a runtime exception, `Reserve` observes `Max >= requested`, and `SortAndReverse` does not claim an unsupported Reverse binding. Seven compile-negative cases remain explicitly blocked until an authoritative exact diagnostic is captured.

### Actor and DefaultComponent

A spawned non-CDO Actor must materialize each declared `DefaultComponent`. Tests that currently treat a null component as success are rewritten around typed accessors that return the real component handle, followed by independent owner/world/class/registration/attachment vectors. CDO component templates and spawned instance components remain distinct fixture kinds.

### NewObject and UObject lifetime

The core construction surface is planned around raw object identity rather than a combined bool:

```angelscript
UObject CreateObject(UObject Outer, const TSubclassOf<UObject>& Class, FName Name, bool bTransient)
void CreateObjectMatrix(UObject Outer, UObject&out NamedTransient, UObject&out GeneratedName, UObject&out NamedNonTransient, UObject&out NullOuterObject)
void CreateObjectWithInvalidClass()
```

Vectors independently observe identity, requested/effective Outer, class, name, flags, null-Outer behavior, exception state, release, and host-owned GC. Comments state that Outer is containment and is not by itself an automatic GC keepalive guarantee.

### Blueprint, CDO, and inheritance

Script parent CDO, Blueprint child CDO, spawned script instance, spawned Blueprint child, retained pre-reload instance, and fresh post-reload instance are different fixture identities. A representative state reader is:

```angelscript
void ReadBlueprintDefaultFields(ATestBPChildDefaultPreservationParent Object, int&out Counter, bool&out Toggle, FString&out Label)
```

Direct AS dispatch and reflected/native ProcessEvent dispatch are separate cases. The ProcessEvent case keeps the fixed Blueprint event/override and removes direct-call wrappers; the runner owns native dispatch while source exposes only raw state:

```angelscript
void ReadProcessEventDispatchState(ATestInhHealthPickup3 Actor, int&out ParentCallCount, int&out ChildCallCount, int&out ChildCollectorHash)
```

### GC

Prepare/retain/release/host-GC/read occur across separate invocations. Rooted cleanup runs on success, failure, timeout, and early exit. Representative phase declarations include:

```angelscript
void PrepareCandidate()
void ReleaseStrongReference()
bool IsWeakReferenceValid() const
```

The AS-side collection call is retained only when the GC API itself is the tested surface. Ordinary reachability cases cannot collect and inspect in one script callback.

### Timer and delegate

Timer acceptance requires a real TimerManager advance; delegate acceptance requires real Broadcast. FName-bound callbacks keep fixed names but are never called by an observation wrapper. Looping handles and external bindings have explicit clear/unbind cleanup, except destroy-as-cleanup cases whose purpose is to prove callback cessation after owner destruction.

### HotReload, TestFramework, and Debugger

HotReload rows identify ordered generations, retained versus replaced UClass/CDO/instance/descriptors, old-object invocation permission, rollback, and cleanup. TestFramework discovery names remain exact. Four Debugger callables are line-map blocked: inserting function comments must have an exact line-neutral strategy or a paired TestSource-owned expectation update; the plan does not silently alter external C++/DAP line maps.

## How to navigate the exhaustive tasks

The generated task IDs are stable within the plan revision:

```text
WNN.BNN.FNNNN.DNNN   design/evidence blocker
WNN.BNN.FNNNN.CNNN   one proposed callable
WNN.BNN.FNNNN.S000   one source-only assertion
WNN.BNN.FNNNN.V000   one file verification
```

Search `tasks.md` by source path, CaseId, current declaration, proposed semantic name, or exact declaration. Each file section names its audit attachment and source hash. Each callable row repeats the exact declaration rather than asking the executor to consult an implicit list.

For a first review pass, use `attachments/contracts/audit-index.md` for counts and risks, then inspect the `Bindings/TArray` and `Containers/TArray` waves, followed by the Actor/DefaultComponent, NewObject/GC, Blueprint/ProcessEvent, timer/delegate, HotReload, and Debugger rows. The 69 MB projection is intentionally exhaustive; the guide and normalized per-domain JSONL files are the navigation surfaces, while `tasks.md` is the execution ledger.

## Status interpretation

- `contract-review-ready`: the design row is complete and awaits review.
- `contract-reviewed`: the accepted row hash is recorded; later source work may begin.
- `signature/vector/fixture/coverage/line-map-unresolved`: the proposal is visible, but the executor cannot implement it until the named evidence task closes.
- `compile-probe-required`: a syntactically exact candidate signature has a pre-recorded branch that requires an allowed compile/ABI decision.
- `runner-blocked`: source/static work may later proceed, but runtime/external status must stay blocked.

The package must never translate `runner-blocked` into compile/runtime PASS.

## Review outcomes

The reviewer may:

1. accept the whole plan revision and its normalized hashes;
2. accept selected waves/files and leave the rest blocked;
3. request declaration/vector/fixture/comment changes, which creates a new plan revision and new row hashes;
4. reject a proposed case or split, provided the current callable/surface gets an explicit retire/replacement disposition rather than silently disappearing.

No source implementation resumes merely because this guide or the OpenSpec validates syntactically; explicit user acceptance is the final plan gate.
