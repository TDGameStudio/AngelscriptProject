# TypeSchema And Unified Decoded Record GREEN File Map

Date: 2026-08-08

Status: implementation preflight only. TypeSchema RED SHA `12E890...` was rejected
with 1 Critical / 2 Important / 1 Minor, and the subsequent declaration inventory
found IC-093 as another Critical scoped-probe contract problem. A third repair is in
progress. This attachment does not claim declarations, production behavior, build or
Automation GREEN.

## Selected ownership

There is one immutable seven-kind decoded-record owner:

```text
RecordId + canonical payload
          |
          v
FAngelscriptDecodedCacheRecord::TryDecode
          |
          +-- validate declared kind and recomputed RecordId before candidate charge
          +-- begin one private decoded-candidate transaction
          +-- charge and allocate one final intrusive controller
          +-- own one canonical-payload byte array
          +-- decode directly into one final TVariant alternative
          +-- own that record kind's captured offsets in the same alternative
          +-- complete physical/local/hash validation
          +-- promote Temporary -> Resident once
          `-- publish ThreadSafe TSharedRef<const token> last
```

The token is not a pimpl and does not allocate a second per-record owner. Its private
storage is a final `TVariant` of complete alternatives for SourceIndex,
ModuleInterface, TypeSchema, ModuleState, FunctionBody, DebugSidecar and
ModuleSnapshot. Each alternative owns its final DTO and captured-offset storage by
value. SourceIndex and ModuleInterface transitional owners are removed, not wrapped.

## Production files

Add:

- `Cache/AngelscriptCacheTypeSchema.h`
  - TypeSchema wire enums, flags, DTOs, V1 build-layout constants, resolver
    interfaces and archive declarations;
  - unit-test-only physical trace declarations behind
    `WITH_ANGELSCRIPT_UNITTESTS`;
  - no all-record token declarations or compatibility include.
- `Cache/AngelscriptCacheTypeSchema.cpp`
  - canonical producer, physical decoder, hash streams, local semantic validation
    and layout replay.
- `Cache/AngelscriptCacheRemainingRecordTypes.h`
  - complete ModuleState, FunctionBody, DebugSidecar and ModuleSnapshot DTOs plus
    their final typed coordinate domains; no empty size placeholders.
- `Cache/AngelscriptCacheDecodedRecord.h`
  - immutable token/handle, seven typed accessors, seven captured-coordinate
    overloads, graph context and graph-validation entry;
  - before the token class, the single final implementation-detail declaration of
    all seven in-place `{DTO, captured offsets}` alternatives and their by-value
    `TVariant`, so the class layout/controller allocation is complete without a
    pimpl or another storage header;
  - under `WITH_ANGELSCRIPT_UNITTESTS`, a narrow explicit test-access façade which
    injects caller-owned observation into the same private factory; no scoped probe.
- `Cache/AngelscriptCacheDecodedRecord.cpp`
  - sole factory, variant dispatch, controller allocation/measurement, candidate
    promotion/publication, accessors and coordinate lookup.
Optional only for translation-unit size:

- `Cache/Private/AngelscriptCacheTypeSchemaCodec.h`
  - private implementation split; accepts the final in-place TypeSchema offset
    storage declared by `AngelscriptCacheDecodedRecord.h` and never defines a
    second storage model or public decoder.

Modify:

- `Core/Artifacts/AngelscriptArtifactIdentity.h`
  - same-key-type equality/inequality only; no cross-domain conversion.
- `Cache/Private/AngelscriptCacheCanonicalCodec.h`
  - constructor-required semantic-blind charge sink at the single retained seam;
  - standalone wrappers bind retained charging;
  - the all-record factory binds its candidate transaction;
  - no mode enum, TLS/global routing or copied codec.
- `Cache/AngelscriptCacheTypes.h`
  - retain the approved private candidate transaction; add only narrow private
    factory plumbing required by the sole token friend.
- `Cache/AngelscriptCacheSemanticRecords.h/.cpp`
  - migrate SourceIndex/ModuleInterface physical decode and captured offsets into
    private candidate alternatives;
  - remove public owning/mutable decode APIs after all consumers migrate.
- `Cache/AngelscriptCacheArchive.h/.cpp`
  - keep envelope behavior unchanged; adjust only decoded-token declarations or
    includes that belong at the envelope-to-token boundary.

## Implementation dependency order

1. Repair/freeze/reapprove the TypeSchema RED at exact SHA with 0C/0I.
2. Freeze IC-095/096 in a separate remaining-record coordinate/API RED: the four
   remaining numeric/P/S/T domains do not yet exist and cannot be inferred from wire
   order; freeze exact nested DTO member names/types/default behavior too.
3. Declare every final public DTO and all seven typed coordinates.
4. Declare every complete private variant alternative before measuring controller
   size; empty/pimpl alternatives would invalidate the allocator oracle later.
5. Add the constructor-owned canonical charge sink.
6. Migrate SourceIndex and ModuleInterface decode into candidate alternatives.
7. Implement the single token/controller/canonical-payload/candidate-publication
   kernel.
8. Implement TypeSchema producer, decoder, offsets, semantics, hashes and replay.
9. Implement ModuleState, FunctionBody, DebugSidecar and ModuleSnapshot decoders.
10. Implement ModuleSnapshot graph validation and external current-symbol/layout/
   opaque-payload authorities.
11. Delete transitional owning/public mutable decode paths.

## Factory chronology

The sole factory performs:

1. preserve the caller's old optional handle in a local lifetime guard;
2. reset caller output;
3. validate input view, declared kind and recomputed RecordId with zero decoded
   charge on mismatch;
4. begin a private candidate transaction;
5. extend by the allocator-quantized final intrusive-controller bytes;
6. create the controller/token once through a private construction token;
7. select the exact final variant alternative;
8. extend/reserve/copy the token-owned canonical payload;
9. decode directly into final DTO and offset storage through the candidate sink;
10. exhaust physical bytes, then finish local semantics and hashes;
11. promote candidate Temporary to Resident once;
12. move-publish the handle with no later failure point.

Failure destroys local storage and releases Temporary while monotonic Total remains.
No token, DTO pointer, callback, registry entry or output handle may escape before
promotion.

## Controller authority

Exact charge uses the complete final:

```cpp
SharedPointerInternals::TIntrusiveReferenceController<
    FAngelscriptDecodedCacheRecord,
    ESPMode::ThreadSafe>
```

and the frozen effective-alignment plus `FMemory::QuantizeSize` rules. The test-only
measurement allocates/destroys the controller through its base pointer and queries
that allocation; `Handle.Get()` is an interior token pointer and is never an
allocation-size oracle.

## Required public token shape

```cpp
using FAngelscriptDecodedCacheRecordHandle =
    TSharedRef<const FAngelscriptDecodedCacheRecord, ESPMode::ThreadSafe>;

class FAngelscriptDecodedCacheRecord
{
public:
    ~FAngelscriptDecodedCacheRecord();

    FAngelscriptDecodedCacheRecord(const FAngelscriptDecodedCacheRecord&) = delete;
    FAngelscriptDecodedCacheRecord& operator=(
        const FAngelscriptDecodedCacheRecord&) = delete;
    FAngelscriptDecodedCacheRecord(FAngelscriptDecodedCacheRecord&&) = delete;
    FAngelscriptDecodedCacheRecord& operator=(
        FAngelscriptDecodedCacheRecord&&) = delete;

    static FAngelscriptCacheValidationResult TryDecode(
        const FAngelscriptCacheRecordId& RecordId,
        TConstArrayView<uint8> CanonicalPayload,
        const FAngelscriptCacheReadLimits& Limits,
        FAngelscriptCacheReadBudget& Budget,
        TOptional<FAngelscriptDecodedCacheRecordHandle>& OutRecord);

    const FAngelscriptCacheRecordId& GetRecordId() const;
    TConstArrayView<uint8> GetCanonicalPayload() const;

    const FAngelscriptCachedSourceIndex* TryGetSourceIndex() const;
    const FAngelscriptCachedModuleInterface* TryGetModuleInterface() const;
    const FAngelscriptCachedTypeSchema* TryGetTypeSchema() const;
    const FAngelscriptCachedModuleState* TryGetModuleState() const;
    const FAngelscriptCachedFunctionBody* TryGetFunctionBody() const;
    const FAngelscriptCachedDebugSidecar* TryGetDebugSidecar() const;
    const FAngelscriptCachedModuleSnapshot* TryGetModuleSnapshot() const;

    // One strongly typed FindCapturedOffset overload for each record kind.
};
```

Unit-test builds additionally declare a non-owning façade, not a second decoder:

```cpp
#if WITH_ANGELSCRIPT_UNITTESTS
class FAngelscriptDecodedCacheRecordTestAccess
{
public:
    static FAngelscriptCacheValidationResult TryDecodeWithProbe(
        const FAngelscriptCacheRecordId& RecordId,
        TConstArrayView<uint8> CanonicalPayload,
        const FAngelscriptCacheReadLimits& Limits,
        FAngelscriptCacheReadBudget& Budget,
        FAngelscriptCacheTypeSchemaAllocationProbeForTests& Probe,
        TOptional<FAngelscriptDecodedCacheRecordHandle>& OutRecord);
};
#endif
```

Both public `TryDecode` and this façade call the same private internal factory. The
façade owns no record, Budget, payload, decoder, validation or publication step.

The type is non-default-constructible, non-aggregate and has no public DTO
constructor. Accessors return exact `const DTO*` types.

## Behavioral kernel versus declaration milestone

A declaration slice may establish all enums/DTOs/interfaces, complete alternatives,
token signatures, traces and probes so the TU reaches linker/behavioral failures. It
is not GREEN. The following are forbidden shortcuts:

- success-returning empty decoder or blanket unsupported result claimed as GREEN;
- public mutable DTO output or compatibility owner;
- pimpl/type-erased/per-kind shared heap allocation;
- temporary empty alternatives used for controller measurement;
- fixture/site-aware production offsets or hashes;
- global/TLS/mode charge routing;
- retained charging inside candidate decode;
- publication before complete validation/promotion;
- fixed guessed controller bytes;
- ignoring inactive union arms or replacing semantic matrices with raw-mask tests.

The first behavioral kernel includes canonical bytes/goldens, hash streams, physical
decode, captured offsets, first-error precedence, TypeKind/presence, complete local
flags/reflection/relation/property/layout rules, layout replay, exact Budget/probe
chronology, RecordId/lifetime guard and final candidate publication.

## RED repairs required before GREEN

- direct `FAngelscriptCachedTypeLayoutInput::Target` must not be used as Optional
  (IC-088);
- no unfrozen `InjectedTestFailure` public error (IC-082);
- TypeSchema probes use caller-owned fixed views and explicit overflow (IC-081);
- delete `FAngelscriptCacheScopedTypeSchemaAllocationProbeForTests` and route the
  caller-owned probe explicitly through the test-access façade into the same factory
  (IC-093); no TLS/global/allocator-singleton active observer is permitted;
- equivalent allocation occurrences are sampled deterministically rather than
  re-decoding the full fixture O(E^2) (IC-089);
- the test explicitly includes `AngelscriptCacheDecodedRecord.h` (IC-090);
- Typedef hostile subtype and exact TypeSchema dependency authorities follow
  IC-086/IC-087;
- the AA4808 independent 3C/6I findings IC-055/056/058/059/060/062/080/083/084
  are closed in the next SHA.

## GREEN slices and commands

1. **RED repair/reapproval** — exact SHA, independent 0C/0I.
2. **Remaining coordinate/API RED** — four exhaustive enum/P/S/T tables plus exact
   nested DTO member shape, separate from the TypeSchema mega-TU.
3. **Final declarations** — complete DTO/coordinate/storage layout and token API;
   compilation evidence only.
4. **Producer/goldens/hashes/wire trace**.
5. **Unified owner/controller/captured offsets/publication**.
6. **Physical decode and first-error precedence**.
7. **Local semantics** — flags/reflection; relations/layout inputs;
   properties/datatype/metadata; methods/VFT; behavior; kind payload; dependencies;
   replay/hash.
8. **TS-SCR budget/probe** — one allocator family at a time, then full prefix.
9. **SourceIndex/ModuleInterface migration regression**.
10. **Remaining four records and graph closure**.

Build only through:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 `
  -Label typeschema-green-<slice> -TimeoutMs 1800000 -NoXGE
```

Focused/full tests only through:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.Cache.Archive.TypeSchema.<Method>" `
  -Label typeschema-<method> -TimeoutMs 600000

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.Cache.Archive.TypeSchema" `
  -Label typeschema-full -TimeoutMs 3600000
```

Run the complete Cache prefix after SourceIndex/ModuleInterface migration. Missing
headers, unresolved symbols, crashes or check failures are declaration/build failures,
not behavioral RED or GREEN.
