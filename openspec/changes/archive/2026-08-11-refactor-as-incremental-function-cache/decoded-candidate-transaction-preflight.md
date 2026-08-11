# Decoded Candidate Transaction Preflight

Date: 2026-08-08

Scope: read-only implementation preflight for IC-053, IC-054, IC-067, IC-068
and IC-069. This attachment contains no production or test completion claim.

## Selected shape

`FAngelscriptCacheReadBudget` retains the existing public retained consume and
single-allocation move-only scratch reservation. It additionally owns a private
nested move-only decoded-candidate transaction. Only the sole
`FAngelscriptDecodedCacheRecord` factory can begin or mutate it.

```text
Open(aggregate=0)
  -> Open(aggregate>0) through one or more TryExtend calls
  -> Promoted exactly once immediately before publication
  -> or Closed by failure/destruction, releasing Temporary only
```

The transaction never enters a token, graph, async callback or global object.
The Budget outlives it and remains non-copyable/non-movable.

## Minimum private API

```cpp
enum class EDecodedCandidateExtendResult : uint8
{
    Success,
    BudgetExceeded,
    Overflow,
    InvalidState,
};
```

The private nested type supplies `TryExtend`, `PromoteToRetained`, RAII release,
move construction and implementation-only state/aggregate inspection. Move
assignment is deleted. The type is not nameable through the public Budget API. A
private begin operation snapshots `MaxTotalDecodedBytes` and
`MaxResidentDecodedBytes` by value; it never borrows caller-owned `Limits` storage,
so every later extension uses one immutable policy snapshot.

## Begin and zero-byte rules

- begin changes no counter and emits no allocation/reservation event;
- an open zero-aggregate transaction is a scope, not a physical reservation;
- `Open.TryExtend(0)` succeeds without changing state/counters/events;
- zero extend on promoted/closed/moved-from state is invalid and changes nothing;
- zero-aggregate promotion returns false and cannot publish a handle;
- the public active-guard rejection, including zero bytes, remains unchanged.

## Atomic per-site extension

For nonzero `Bytes`, all checks occur before mutation:

1. same owner and `Open` state;
2. transaction aggregate addition does not overflow;
3. `DecodedBytes + Bytes <= MaxTotalDecodedBytes`;
4. `Resident + Temporary + Bytes <= MaxResidentDecodedBytes`;
5. same owner thread and same candidate limits.

Only after every check succeeds does one logical commit perform:

```text
DecodedBytes                    += Bytes
TemporaryResidentDecodedBytes  += Bytes
Transaction.AggregateBytes     += Bytes
PeakLive = max(PeakLive, Resident + Temporary)
```

A rejected extension changes none of these and the target physical allocation
must not be attempted. "Atomic" describes this one-thread logical commit; it is
not a set of unrelated lock-free atomic counters.

## Allocation chronology

Every candidate-owned physical site follows:

```text
checked count/request
-> checked allocator capacity and byte multiplication
-> transaction TryExtend(exact capacity bytes)
-> allocation attempt
-> Reserve/SetNum/MakeShared
-> verify actual allocated bytes equal predicted charge
```

The one canonical reader receives a private per-call charge sink. Canonical
primitive decode and every record decode bind the active aggregate candidate;
each public operation promotes exactly once only after its complete validation
boundary. Global/thread-local routing flags, direct pre-publication retained
charging and duplicated wire readers are forbidden.

## Failure and promotion

Destroying or replacing an open transaction releases only aggregate Temporary:

```text
Total after failure     = entry Total + every accepted site charge
Temporary after failure = entry Temporary
Resident after failure  = entry Resident
Peak after failure      = historical maximum
```

Promotion checks owner/state/nonzero aggregate and internal underflow/overflow,
then performs:

```text
Temporary -= Aggregate
Resident  += Aggregate
Total and combined live unchanged
Peak sampled but numerically unchanged
```

Promotion precedes the no-fail move of the local handle into output. No callback,
weak/shared escape, registry insertion or output assignment may happen earlier.

## Move and lifetime behavior

- copy construction/assignment is deleted;
- move construction transfers owner, limit values, aggregate and state; moved-from
  destruction is a no-op;
- move assignment is deleted: arbitrary owner rebinding could transfer a candidate
  from a shorter-lived Budget into a longer-lived destination and leave a dangling
  owner in non-check builds;
- an open transaction is destroyed before its Budget;
- development Budget destruction requires zero active transactions.

## Controller allocation

The complete seven-kind token layout must exist before freezing:

```cpp
using FController = SharedPointerInternals::TIntrusiveReferenceController<
    FAngelscriptDecodedCacheRecord, ESPMode::ThreadSafe>;
```

The effective replacement-new alignment uses declared controller alignment only
when over-aligned; ordinary size-over-eight allocation uses
`__STDCPP_DEFAULT_NEW_ALIGNMENT__`, and a very small ordinary allocation uses
eight. The candidate extends by the quantized controller size before `MakeShared`.

A test-only measurement allocates the exact final controller directly through
`NewIntrusiveReferenceController`, retains its base pointer, queries
`GetAllocSize`, and destroys it. `Handle.Get()` is an interior token pointer and
is never an allocation-size oracle.

## Thread and observer contract

Budget mutation is thread-affine. Decode, candidates, scratch reservations,
graph validation and queries using one Budget run sequentially on the bound owner
thread. A published `ESPMode::ThreadSafe` handle may cross threads; the Budget may
not.

The test observer is semantic-blind and allocation-free. A caller-provided fixed
event buffer records generic chronology and raw allocator/Budget facts. It may
observe reservation accepted/rejected dimension, allocation attempt/success/
destruction, release, promotion and publication. It does not report fixture
variant, semantic site, coordinates, stage, expected limit or mutation authority.
The capture exposes count plus an overflow flag, never grows or logs on overflow,
and discards excess events after setting that flag. It is an explicit synchronous
per-call view passed through the test-access façade into the same private factory;
it has no scoped active state, TLS/global pointer, nesting rule or destruction-
thread cleanup.

## Platform exactness

Predicted typed capacity and controller charge must equal `GetAllocatedSize` and
controller-base `GetAllocSize` on every supported target. A mismatch cannot be
repaired by charging after allocation; development/test builds fail fast and an
unproven production allocator/platform combination fails closed.

## Implementation gates

- no partial two-kind token before final controller measurement;
- no public candidate extension or construction escape;
- no allocation before successful exact extension;
- no post-allocation Budget correction;
- no direct retained charge for pre-publication token storage;
- no publication before one successful promotion;
- no shared mutable Budget across worker threads;
- SourceIndex and ModuleInterface use the same reader/factory and remove their
  transitional owning boundaries rather than wrapping them.
