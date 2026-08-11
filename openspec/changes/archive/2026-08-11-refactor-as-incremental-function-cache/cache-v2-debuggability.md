# Cache V2 debuggability contract (C++ / Python)

Cache debuggability is a production acceptance requirement; the implementation
language of each developer-facing tool is not. Capabilities are allocated by the
boundary they must observe instead of being duplicated one-for-one: a small C++
producer captures live Engine/Editor/PIE decisions and exposes immutable DTO/JSON,
while read-only Python tools inspect, diff and explain persisted Cache V2 data and
may correlate that live report even when Unreal cannot start. A future frontend may
be implemented in either language as long as it consumes the same stable schema and
does not create another cache authority. Diagnostics are observers and must not
become cache correctness inputs.

`Python-first` therefore never means `Python-only`. C++ and Python are both valid
implementation languages for Cache V2 debug tools. Choose C++ when the question
requires a live Engine, Editor/PIE state, native lifecycle timing or direct use of
the Runtime DTO authority; choose Python when persisted files, cross-launch
comparison, CI automation or an Unreal-free bug attachment is sufficient. Either
language may provide an additional frontend over the shared schema, but neither
may fork cache selection, invalidation, validation or publication policy.

Acceptance is capability-based rather than language-count-based: a diagnostic
operation implemented correctly in C++ or Python does not need a second mechanical
implementation in the other language. Cross-language coverage is required only at
the shared DTO/JSON and persisted-wire boundaries where agreement itself is the
behavior being verified.

## Questions the combined toolchain must make answerable

For one startup, reload, module, type, function or record, a developer must be able
to determine:

1. Which Current, Previous or PendingColdStart generation was considered/selected.
2. Whether the result was `Restored`, `Miss`, `RejectedCorrupt`, `NotCacheable`,
   compiled, reused, published, deferred or rolled back.
3. The exact typed reason, record kind, validation stage and available byte offset.
4. The full stable module/type/function/global/property/environment key and its
   canonical display coordinate.
5. The expected and current ABI/content/value/source/input digest at a mismatch.
6. The direct dependency edge and deterministic dependent/recompile closure.
7. Whether preprocessing, parsing, module compilation and each invocation compiler
   actually ran.
8. Which records and Pack ranges were read, reused, written or rejected.
9. Whether the active Engine retained last-good state, installed a restored graph
   or published a new generation.
10. Which stable function route selected VM or StaticJIT Native execution.

Persistent diagnostic correlation uses stable identities only. Native pointers,
object addresses, persisted numeric FunctionIds, random IDs and thread-dependent
ordering are forbidden. A current numeric FunctionId may appear only as explicitly
ephemeral verbose context and is never needed to correlate runs.

## Live diagnostics (C++ capture/API)

Runtime owns a public, pointer-free diagnostic DTO/API surface, provisionally under
`Cache/AngelscriptCacheDiagnostics.h/.cpp`:

- `FAngelscriptCacheDiagnosticSnapshot` — one deterministic per-engine summary;
- `FAngelscriptCacheTransactionDiagnostic` — startup/reload/publication result;
- `FAngelscriptCacheDecisionEvent` — one schema-versioned typed decision;
- `FAngelscriptCacheExplainRequest/Result` — query by transaction, module,
  function, record or stable environment symbol;
- `FAngelscriptCacheVerifyApiResult` — shallow/deep persisted-slot validation;
- `FAngelscriptCacheFlushApiResult`, `FAngelscriptCacheCompactApiResult` and
  `FAngelscriptCacheForceCleanApiResult` — explicit transactional controls;
- free typed Runtime API functions over the current Engine/Service authority.

Semantic Current/Previous/Pending generation diff is deliberately not duplicated
as a second C++ implementation. The Unreal-free Python `--diff` command is the
authoritative persisted semantic diff capability and joins records by stable
identity. C++ emits the live session JSON and immutable publication coordinates
that Python can correlate with that persisted result.

The implementation uses immutable, owned DTOs; it never returns AS/UE object
pointers or retains mutable module descriptors. `FAngelscriptStateDump` may observe
these public DTOs, preserving the existing dump architecture as an external
observer instead of adding dump-only hooks to the compiler or Engine.

Every Cache transaction produces a bounded summary. Editor/Development builds also
provide a bounded opt-in in-memory decision journal. Events contain schema version,
transaction ordinal, stage, outcome/reason enum, stable coordinates,
expected/current digests, counters and elapsed time. Capacity is fixed/configured;
old events are overwritten by a documented deterministic policy. Shipping defaults
to disabled or aggregate-only tracing unless a project explicitly enables it.

An explain query reads already captured immutable diagnostics and validated
generation metadata. It reports the direct reason first and the ordered dependency
closure after it. It never reparses source, invokes a compiler or mutates the store
just to explain a result.

Console commands are thin callers of the same C++ API, not a separate authority:

- `as.Cache.Status [Json=<path>]`
- `as.Cache.Explain Module=<name|key> [Function=<declaration|key>] [Record=<id>]`
- `as.Cache.Trace Enable|Disable|Clear|Dump [Json=<path>]`
- `as.Cache.Verify [Generation=Current|Previous|Pending] [Deep=0|1]`
- `as.Cache.ForceClean [Module=<name|key>]`
- the already specified `as.Cache.Flush` and `as.Cache.Compact`

Packaged/commandlet evidence may additionally request
`-as-cache-report=<absolute-json-path>`. Runtime validates the `.json` target and
writes the same pointer-free C++ snapshot after bounded shutdown flush but before
the Cache service is released. This process report is an observer: it never changes
selection, validation, publication or fallback. Python may later correlate that
session JSON with the persisted Store; it does not need an Unreal process to do so.

`Status`, `Explain`, trace dump and `Verify` are read-only. Shallow `Verify` checks
the atomic slot pointer and content-addressed Manifest identity; deep `Verify`
reuses the production Manifest/Pack/record/semantic-graph validator under the
namespace lock. `Compact` reuses the production two-phase rooted compactor and
derives Profile/SourceSnapshot authority from the immutable Current publication.
`ForceClean` queues selected active modules through the authoritative HotReload
compiler transaction and normal last-good rules. No command directly edits a
Manifest/Pack or silently deletes the only last-good generation.

Normal logs emit concise transaction start/end and typed fallback lines without
per-hit spam. Verbose tracing can emit per-module/function details. Machine-readable
JSON is derived from the C++ DTOs; human strings are not the reason-code authority.

This is the minimum Engine-native capture boundary, not a requirement that every
query UI, report formatter or comparison tool be written in C++. Python may consume
the emitted JSON for richer presentation; it must not reach into live AS/UE objects
or reimplement cache-selection policy.

## Offline diagnostics (Python-first)

`Tools/CacheV2Dump` stays Unreal-free and read-only. Alongside the current
root/Manifest/Pack inspection and filters, the completed tool provides:

- physical and semantic verification with structured nonzero failures;
- Current/Previous/Pending diff by stable record identity;
- module/type/function lookup by full key or canonical name/declaration;
- ordered record links and dependency-tree explanation;
- expected and persisted ABI/content/value/source/input coordinates;
- correlation with an explicitly supplied C++ session JSON report;
- deterministic text and JSON suitable for CI assertions and bug attachments.

`--diff` is the formal semantic generation comparison surface. It compares
validated decoded generations, not Pack offsets or compressed bytes, and is the
single presentation implementation used for cross-launch diff/CI evidence.

Opaque execution, initializer and debug payloads remain hash/size/codec metadata
unless the exact codec exports a matching diagnostic decoder. The generic tool
never guesses bytecode or presents a corrupt partial payload as valid.

Python is preferred here because these operations do not need an Engine process and
are easier to automate, attach to bug reports and run in CI. A later C++ frontend is
allowed, but it is not required to duplicate the current Python presentation layer.
Likewise, a new diagnostic whose natural observation boundary is live Runtime state
may be implemented directly in C++ without first creating a Python equivalent.

## Shared schema and error contract

All applicable C++ and Python tools use the same stable enums and coordinates:

- validation error/failure class, record kind, stage and byte offset;
- generation ID, Pack ID, Record ID and bounded physical range for storage faults;
- module/function/type stable key and canonical display coordinate;
- dependency/reference kind and expected/current ABI or content/value;
- source candidate kind and expected/current source/input digest;
- invocation kind and `Restored/Miss/RejectedCorrupt/NotCacheable` result;
- lifecycle transaction and publication/rollback disposition.

Unknown future enum values remain representable numerically rather than crashing
the diagnostic path.

## Tests and acceptance

- C++ unit tests cover the Engine-native DTO producer, deterministic ordering/JSON,
  bounded trace eviction and no pointer or persisted numeric-ID leakage.
- Python tests cover valid/corrupt physical fixtures, stable filters, diff,
  formatting, dependency explanation and C++ report correlation without launching
  Unreal.
- Corruption tests prove C++ and Python agree on physical coordinates and typed
  causes where both inspect the same persisted failure.
- Two-Engine tests prove stable keys correlate functions despite different current
  numeric FunctionIds.
- Editor/PIE tests assert summary/explain chains for warm hit, body edit, structural
  deferral, compile failure and last-good rollback.
- Development/Shipping multi-launch tests retain C++ JSON and Python output as V7
  evidence against the real generated Cache.
- V7 benchmarks measure diagnostics disabled, summary and verbose overhead; the
  diagnostic path is bounded and adds no second source parser.

Current V6.5 C++ coverage additionally executes real Flush, shallow/deep Verify,
two-phase Compact and successful/failing ForceClean transactions. The failing
ForceClean case proves the immutable Current publication and executable last-good
function remain active after a compiler error. It also proves immutable per-Engine
StableFunctionKey-to-current-FunctionId route snapshots, verified content/profile
coordinates, VM/Native route decisions, two-Engine isolation and pointer-free
`StableRoute` trace events. V6.5 further logs injected Provider arrival/departure,
typed per-function mismatch and rejected Live Coding outcomes alongside route
ordinal, VM/Native counts and unchanged Current transaction identity. That live
Engine evidence is naturally C++; a future Editor panel or console frontend may
consume the same DTOs without a Python process. Python coverage executes persisted
dump, corruption, filtering, semantic diff, bounded dependency explanation and C++
session correlation without launching Unreal. A C++ offline frontend is also valid
if later product integration needs one, provided it consumes the same wire/schema
meanings and does not become another cache-selection authority.
