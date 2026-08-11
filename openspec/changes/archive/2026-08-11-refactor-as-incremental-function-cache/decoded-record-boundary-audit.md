# Unified Decoded-Record Boundary Audit

Status: SourceIndex/ModuleInterface migration GREEN; graph integration pending.

This read-only audit was performed during the rejected first TypeSchema RED
remediation. It inspected the synchronized OpenSpec documents plus the current
Task 2B-1 Runtime and SourceInterface tests. It changed no production/test
file, ran no build/test, wrote no `Saved/` artifact, and made no commit.

The audit was deliberately stopped after the actionable boundary was complete;
it is evidence and an implementation checklist, not a claim that Task 2B-2 is
GREEN.

## Accepted findings

| Severity | Finding | Normative resolution | Implementation state |
|---|---|---|---|
| Critical | Runtime has no common `FAngelscriptDecodedCacheRecord`; SourceIndex still publishes `FAngelscriptValidatedSourceIndex` and ModuleInterface still publishes a mutable DTO without declared RecordId, canonical bytes, or retained offsets. | One all-record `TryDecode` factory dispatches all seven kinds and publishes only the sole const shared-ref handle. | Pending Task 2B-2 GREEN. |
| Critical | SourceInterface tests explicitly freeze the old public decoder/token APIs, including a raw DTO test decoder. | Migrate all production consumers to the common factory; record-specific decoders and physical fixture writers are private or unit-test-gated and never trust inputs. | Pending SourceInterface RED/GREEN migration. |
| Critical | SourceIndex/ModuleInterface offsets are top-level stack structs discarded on success; graph cannot report exact nested link/owner/dependency offsets without reconstruction. | The token retains a private immutable, fully nested, record-specific typed-coordinate table; missing validated coordinates are invariant failures, never payload scans or offset-zero fallback. | Pending implementation and migration tests. |
| Critical | Resetting `OutRecord` before reading can destroy the sole owner of a payload view that aliases the old token, causing use-after-free. | Copy the old handle into a reference-count-only local lifetime guard, reset output, consume all input, then release the guard. The copy allocates and charges nothing. | TypeSchema RED added; implementation pending. |
| Critical | Private normal constructors alone do not prevent callers from copying or moving `*Handle` into a second token object. | Public destructor; deleted token copy/move constructors and assignments; only handle copies are legal. Do not expose a constructor to make `MakeShared` convenient. | TypeSchema RED added; implementation pending. |
| Critical | Public `FAngelscriptCacheReadBudget::Reset()` can erase monotonic retained charges while decoded tokens still exist; checking only active temporary reservations does not make that safe. | Remove the session-budget `Reset()` API in this development-phase break. Isolated callers construct a fresh stack Budget; production envelope/pack/graph/session paths pass one Budget without reset. The scratch reservation's own RAII `Reset()` remains a distinct release operation. | Runtime API and old tests pending migration. |
| Important | Envelope decode lacks the same caller-owned Budget overload needed by pack/session/graph paths. | Add mandatory `(Bytes, Limits, Budget, OutEnvelope)`; the standalone convenience overload may use one local Budget only for isolated calls. | Pending implementation/tests. |
| Important | Token/control/canonical payload/DTO/offset allocation was not mapped to one exact accounting owner. | The all-record factory charges each physical capacity exactly once; graphs copy handles without charge. Every retained row now includes its parallel offset capacity. | Matrices corrected; implementation pending. |
| Important | TypeSchema TS-SCR-01..11 and ModuleState MS-SCR-01/02 omitted private captured-offset parallel arrays; SourceIndex/ModuleInterface/FunctionBody/DebugSidecar/ModuleSnapshot had no explicit retained decode oracle. | Offset arrays join the matching DTO family; flat token/header offsets join the first retained family. AR-SCR rows freeze the other five kinds without inventing a TypeSchema TS-SCR-23. | Normative tables corrected; focused matrix rereview pending. |
| Important | Common array/string decoding charged requested `Count*sizeof(T)` before `TArray::Reserve`/`FString::SetNum*`; UE allocator slack may allocate more. The earlier allocator fix covered validation scratch, not retained decoded DTOs. | Separate count/minimum-wire checks from typed allocation. Before each grow, use `CalculateSlackReserve`, checked capacity bytes, both limit dimensions, then prove `GetAllocatedSize` equals the charge. Apply recursively to CanonicalDataType and strings. | Pending codec refactor and SourceInterface regression. |
| Important | `MaxTotalDecodedBytes` currently counts only payload input while DTO allocations count only Resident; old tests freeze `Payload.Num()` as a complete first-decode total. | Canonical token bytes, DTO capacities and captured offsets each consume TotalDecoded and Resident once as two limit dimensions over one physical allocation. Payload input alone is insufficient. | Old tests must be replaced during migration. |
| Important | Query names/placement and pack wording drifted (`QueryModuleCacheEligibility`, archive static method, free `QueryExactFastPathEligibility`, “publish raw record”). | Final API is the free `QueryExactFastPathEligibility(const FAngelscriptDecodedCacheRecord&, ...)`; pack read feeds raw bytes to the sole factory and returns its handle. | Documents corrected; code/tests pending. |
| Important | The shared token/controller allocation had no exact UE allocator oracle, so an implementation could charge only `sizeof(Token)` or allocate object/controller separately. | Use a private construction token with `MakeShared`, charge the quantized single intrusive controller+object allocation exactly once before allocation, and verify its actual allocator size through the unit-test probe. `MakeShareable(new ...)` is forbidden. | TypeSchema factory RED/probe and implementation pending. |
| Important | A declaration-only stub cannot produce a meaningful behavioral TypeSchema RED because valid-fixture helpers require successful hash, writer, physical-trace, sentinel decode and token publication paths. | Keep two explicit gates: first prove the complete TU compiles; then implement the smallest valid-path kernel and capture ordinary assertion failures from the remaining matrix. A `check`/crash or missing-header result is not the final behavioral RED. | Pending after corrected RED approval. |
| Critical | Publishing a two-kind SourceIndex/ModuleInterface token would freeze a controller size that changes when the other five by-value DTO/offset alternatives are added; pimpl/type erasure would add an unbudgeted owner allocation. | Complete all seven DTO/coordinate/offset storage declarations first, then use one final in-place by-value seven-alternative variant and freeze the sole intrusive-controller charge. No partial compatibility token. | Sequencing corrected; implementation pending. |
| Critical | Split `TryConsumeDecoded` then `TryConsumeResidentDecoded` can leave a half-charged target allocation when the second limit fails; temporary reserve currently omits TotalDecoded. | Replace with atomic retained and temporary decoded acquisitions, direct combined-live peak sampling, and no public split escape hatch; promotion reclassifies the same live bytes. | Runtime/tests pending. |
| Important | `alignof(FController)` is not necessarily the alignment passed by UE's replacement `operator new`; ordinary size-over-8 allocations use the standard default-new alignment. | Quantize the exact final intrusive-controller size with the effective replacement-new alignment and verify one observed allocation/actual allocator size. | Authority corrected; RED/GREEN pending. |
| Important | Envelope payload copy has no shared Budget overload or allocator-capacity retained charge. | Mandatory Budget overload; convenience overload delegates with one fresh Budget; copy uses actual owned-byte array capacity and atomic Total+Resident acquisition before allocation. | Runtime/tests pending. |
| Important | SourceIndex/ModuleInterface offset structs retain only shallow top-level offsets and are destroyed at decode return. | Private candidates own exhaustive parallel/nested/recursive pre-order offsets and move DTO+offset storage into the final token without rescanning bytes. | Runtime/tests pending. |
| Important | Canonical codec and eligibility paths still charge requested counts, fixed estimates, or `sizeof(row)+Len` rather than actual allocator capacities; query scratch misses TotalDecoded. | Split count/min-wire checks from typed reserve/setnum; charge exact capacity atomically for every DTO/scratch/output site and prove actual allocated size. | Runtime/tests pending. |

## Frozen public shape

```cpp
class FAngelscriptDecodedCacheRecord;

using FAngelscriptDecodedCacheRecordHandle =
    TSharedRef<const FAngelscriptDecodedCacheRecord, ESPMode::ThreadSafe>;

FAngelscriptCacheValidationResult
FAngelscriptDecodedCacheRecord::TryDecode(
    const FAngelscriptCacheRecordId& DeclaredRecordId,
    TConstArrayView<uint8> CanonicalPayload,
    const FAngelscriptCacheReadLimits& Limits,
    FAngelscriptCacheReadBudget& Budget,
    TOptional<FAngelscriptDecodedCacheRecordHandle>& OutRecord);
```

The complete class/special-member/accessor sketch is normative in
`record-wire-v1-remaining.md`. `TryGet*` returns a const pointer only for the
active record kind. There is no unchecked typed reference accessor.

## Typed captured-offset contract

Each record kind has its own non-wire coordinate type:

```cpp
struct FAngelscriptTypeSchemaFieldCoordinate
{
    EAngelscriptTypeSchemaCapturedField Field;
    uint32 PrimaryIndex = MAX_uint32;
    uint32 SecondaryIndex = MAX_uint32;
    uint32 TertiaryIndex = MAX_uint32;
};

TOptional<uint64> FindCapturedOffset(
    const FAngelscriptTypeSchemaFieldCoordinate&) const;
```

The other six record kinds use distinct coordinate/enums and overloads. Wrong
kind, invalid/unapplicable field or bad index returns unset; captured zero is a
set optional containing zero. Recursive type nodes use a decoder-captured
pre-order ordinal rather than a caller string/path. Lookup is allocation-free
and never scans bytes or accepts caller-authored offsets/tables. The TypeSchema
field enum is frozen append-only through `0..40` in
`record-wire-v1-remaining.md`; the original `0..38` values are unchanged and
`ReflectionKind=39` / `ClassReflectionFlags=40` are the only current additions. SourceIndex
`0..89` and ModuleInterface `0..88` plus the exact eligibility wrong-kind tuple
are frozen in `source-interface-captured-offsets-v1.md`; the other record enums
freeze with their corrected RED before GREEN.

## Budget and allocation lifecycle

`FAngelscriptCacheReadBudget` is a one-owner session accumulator, not a reusable
counter bag. Its stored, decompressed, decoded, conservative retained-resident,
reference/relocation, and peak-live counters are monotonic for the lifetime of
the Budget, including after decode failure and after an output handle is
cleared. There is no public session-budget `Reset()` in Cache V2. A standalone
convenience call creates a new local Budget; a retry/session creates or keeps
the Budget required by its own higher-level protocol rather than mutating an
old one.

Move-only scratch reservations are different: their RAII `Reset()` releases
only active temporary live-resident bytes and never refunds TotalDecoded.
`PromoteToRetained()` atomically transfers the same already-charged live bytes
from temporary to conservative retained resident, performs no allocation,
does not consume TotalDecoded or Resident a second time, and disables the
reservation's destructor release. `PeakLiveResidentDecodedBytes` is sampled
from `ResidentDecodedBytes + TemporaryResidentDecodedBytes` after every
successful retained consume, temporary acquire, release, and promotion;
`final resident + peak temporary` is not an admissible reconstruction.

Every decoded record is built under one private Budget-friended candidate
transaction. Its controller, canonical payload, DTO containers/strings and captured
offset storage extend one aggregate Temporary charge site by site before allocation.
Failure releases that aggregate Temporary charge while TotalDecoded remains
monotonic; success promotes it exactly once immediately before the handle becomes
observable. This private extension is not exposed through the public scratch guard,
whose active-output rejection remains frozen.

The canonical reader routes every owned string/array capacity through a required
private charge sink. Its standalone primitive sink consumes retained decoded bytes;
its sole-record-factory sink extends the active decoded candidate. This is a
constructor-owned per-call decision, not a global flag or a second codec.

The Budget and every active candidate/scratch guard are thread-affine. Their
multi-counter operations are logically all-or-nothing on one owner thread, not
cross-thread atomics. An immutable published handle is thread-safe; the mutable
session Budget is not. Debug ownership checks and a zero-active-transaction Budget
destructor invariant freeze that lifetime.

The token and its thread-safe shared controller use one `MakeShared` intrusive
controller/object allocation. Production computes the allocator-quantized
bytes for that exact controller type before allocation, atomically extends the
decoded candidate's TotalDecoded plus Temporary dimensions, then verifies the
observed allocation size in the unit-test probe. Publication promotes that same
charge to Resident without a second Total/live acquisition. The private construction-token pattern
prevents external construction without exposing another owning handle.

## Compile and behavioral RED gates

The corrected TypeSchema test translation unit first receives enough
declarations/link stubs to prove that every frozen API and DTO compiles. That
gate is compile evidence only. Because valid test fixtures deliberately use
`check` for producer/hash invariants, the subsequent behavioral RED requires a
small real valid-path kernel: all frozen hash helpers, canonical and physical
writers with trace spans, declared-RecordId validation, one complete valid
TypeSchema decode, immutable token/canonical-payload publication,
`TryGetTypeSchema`, and basic captured-offset lookup. Only then is the focused
prefix run accepted as behavioral RED; a missing header, unresolved symbol,
producer `check`, or process crash is not sufficient.

## SourceIndex/ModuleInterface migration acceptance

The original preflight wording requested an empty/one/slack/many Cartesian row for
every semantic DTO allocation family. Implementation evidence showed that this
would repeat the same canonical reader mechanism without increasing the vertical
confidence needed by the module transaction. The accepted V1.3 boundary is now:
one representative non-empty SourceIndex and ModuleInterface that collectively
exercise every retained family, an inventory of every allocation actually
performed, exact Total/Resident/combined-peak limits, one-byte-short rejection and
failure injection after every accepted allocation. The exhaustive TypeSchema
matrix remains the shared canonical codec mechanism authority. Any new allocation
site added later must appear in the per-record inventory automatically.

- [x] no public `FAngelscriptValidatedSourceIndex` owning role;
- [x] no public mutable ModuleInterface decode output;
- [x] SourceIndex `0..89` and ModuleInterface `0..88` captured-coordinate enums and every P/S/T index rule have compile/runtime coverage, including invalid, missing, unused and out-of-range coordinates;
- [x] common factory recomputes declared RecordId for both kinds;
- [x] exact-fast-path query is the free function over a common const token and its wrong-kind result is exactly error 48, actual supplied kind, ModuleGraph stage 5, offset zero, empty output and unchanged Budget;
- [x] all existing SourceInterface semantic/golden behavior survives migration;
- [x] nested link/owner/dependency offsets survive successful token publication;
- [x] token/control/canonical bytes/DTO/offset capacities charge once;
- [x] arrays, recursive types and strings use actual allocator capacity;
- [x] TotalDecoded, retained Resident and combined-live peak each use their distinct authority;
- [x] exact, one-byte-short, allocation-probe and per-actual-event rollback rows cover both representative non-empty records;
- [x] the public session Budget has no reset escape hatch that can erase a live token's conservative charge;
- [x] aliasing output-owned payload input is lifetime-safe;
- [x] handle copies allocate and charge nothing;
- [x] focused and complete SourceInterface regression is `43/43` GREEN;
- [ ] independent implementation review is deferred to the complete graph/publication boundary and no longer blocks this record-level vertical slice.

## Current migration file map (2026-08-08 preflight)

A fresh read-only `rg` audit of the isolated plugin worktree found the
transitional owning/public decode surface in only four files:

| File | Required migration |
|---|---|
| `AngelscriptCacheTypes.h` | remove public session `FAngelscriptCacheReadBudget::Reset`; add exact combined-live peak and scratch promotion primitives without changing reservation RAII release |
| `AngelscriptCacheSemanticRecords.h` | delete `FAngelscriptValidatedSourceIndex` and public record-specific decoders; declare the sole common const handle, seven typed coordinate overloads, const `TryGet*`, and free eligibility query |
| `AngelscriptCacheSemanticRecords.cpp` | keep wire/local/hash readers private; move-publish SourceIndex/ModuleInterface DTO, canonical bytes and nested offsets through `TryDecode`; enforce alias guard, declared RecordId, allocator-capacity charge and common error stages |
| `AngelscriptCacheSourceInterfaceTests.cpp` | replace transitional-token/raw-DTO assertions and every reusable-Budget retry with common-handle/fresh-Budget coverage; preserve all prior wire/semantic/query goldens and add `0..89`/`0..88` coordinate plus wrong-kind/budget/allocation matrices |

The current tests contain exactly 34 session-Budget reset call sites: 10 in
`AngelscriptCacheArchivePrimitiveTests.cpp` and 24 in
`AngelscriptCacheSourceInterfaceTests.cpp`. Each must become a fresh Budget
scope or a monotonic same-session assertion; scratch reservation `Reset()` is
not included in that count and remains legal RAII release. No current
consumer of `FAngelscriptValidatedSourceIndex`, the raw ModuleInterface decoder,
or the exact-eligibility query was found elsewhere in `AngelscriptRuntime`,
`AngelscriptEditor`, or `AngelscriptTest`. This means the development-phase API
break is locally bounded; it does **not** prove the later compiler/editor/PIE/
Shipping integration, which remains a separate task.

The 34 calls are localized to five CQTest methods, which are the mechanical
migration boundary rather than permission to weaken their assertions:

- Primitives: `ReaderRejectsMalformedStringsUnknownTagsTrailingDataAndBudgets`
  (10);
- SourceInterface:
  `DecodedSemanticFailuresRetainRecordKindAndEnclosingFieldOffset` (5),
  `RecordReadersApplyFieldRecordArrayAndCumulativeBudgetsAndResetOutputs` (4),
  `RecordsRoundTripReserializeAndCanonicalizeInsertionOrder` (1), and
  `ValidationScratchAndValidatedEligibilityAreBudgetedBeforeAllocation` (14).

Malformed/failure variants receive independent fresh Budget objects. Cases
that intentionally prove cumulative same-session behavior keep one Budget and
must assert monotonic counters without any reset/retry escape hatch.

The current implementation still has stack-only `FSourceIndexReadOffsets` and
`FModuleInterfaceReadOffsets`, resets them with the decoded DTO on return, and
publishes no declared RecordId or canonical payload ownership. This confirms
the Critical migration rows above remain open; the file map is preparation,
not GREEN evidence.
