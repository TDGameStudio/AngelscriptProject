## Context

`FAngelscriptStateDump::DumpAll()` currently writes a set of CSV tables from `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateDump.cpp`. Those tables cover high-level descriptors (`Modules.csv`, `Classes.csv`, `Functions.csv`, etc.), selected runtime services, public `asIScriptEngine` counts, and editor extension rows. They do not produce a reusable in-memory snapshot and do not compute diffs.

The current dump also cannot be treated as "full engine state":

- `FAngelscriptEngine` has many private state containers that are not exported today: `ActiveModules`, `ModulesByScriptModule`, hot-reload maps/queues, context pools, static-name caches, script enum lookup, bound Blueprint event argument specializations, and service ownership pointers.
- The public `asIScriptEngine` interface exposes aggregate counts, but not the underlying `asCScriptEngine` collections where compile impact is visible: registered object/function/global/type containers, script module maps, script function arrays, type-id maps, shared script types, GC state, and build/defer flags.
- `asIScriptModule` exposes useful public counts, but detailed reload and dependency impact requires `asCModule` internals such as local type maps, dependency maps, external declarations, reload state, old/new reload module pointers, script globals, and compiled function lists.

The target is diagnostic observability, not a new runtime ownership model. The dump layer should remain an external observer as much as possible, but full member-level coverage requires controlled access to private engine state and private AngelScript implementation headers.

## Goals / Non-Goals

**Goals:**

1. Capture a stable, normalized diagnostic snapshot from a live `FAngelscriptEngine`.
2. Cover both FAS engine member categories and underlying AngelScript VM/module internals.
3. Produce a deterministic before/after diff that can reveal the impact of compile, reload, discard, and initialization operations.
4. Keep existing human-friendly dump tables while adding machine-stable snapshot/diff tables.
5. Make compiler-event tests able to log full snapshots and diffs for later inspection.
6. Keep capture read-only and side-effect free.

**Non-Goals:**

- Serializing or restoring the engine or AS VM.
- Making every engine field public API.
- Exposing mutable AS internals outside runtime diagnostics.
- Converting `FAngelscriptEngine` internals into reflected `UPROPERTY` fields.
- Replacing the separate `feature-as-engine-reflectable-state` capability.
- Capturing lock internals, delegate invocation lists, or callback closure bodies beyond safe presence/count summaries.
- Dumping bytecode blobs or full script source by default.

## Decisions

### D1: Add a normalized snapshot model before extending CSV tables

Create new dump-local types:

- `FAngelscriptStateSnapshot`
- `FAngelscriptStateSnapshotRow`
- `FAngelscriptStateDiff`
- `FAngelscriptStateDiffRow`

Each snapshot row should include:

- `Category`
- `Identity`
- `Field`
- `Value`
- `ValueKind`
- `Source`
- optional `SortKey`

This avoids hard-coding diff logic against every human-friendly CSV table. Existing dump tables can stay readable, while the normalized snapshot tables become the stable comparison surface.

Alternative rejected: directly diff the generated CSV files. The current CSV schema is designed for human review and contains table-specific columns, timestamps, row ordering, and partial exports that make generic diff noisy and fragile.

### D2: Keep snapshot/diff implementation inside `Dump/`

Add files under `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/`:

- `AngelscriptStateSnapshot.h/.cpp`
- `AngelscriptStateDiff.h/.cpp`

The snapshot builder may include AngelScript internal headers and use dump-specific access helpers. This keeps private runtime knowledge localized to diagnostics.

Alternative rejected: add broad getters to `FAngelscriptEngine` for every internal collection. That would make diagnostic needs look like supported runtime API and increase mutation risk.

### D3: Use a narrow friend/accessor for private FAS engine members

`FAngelscriptEngine` should grant access to a dump-local helper such as `FAngelscriptStateSnapshotAccess` or `FAngelscriptStateSnapshotBuilder`. The helper reads private members and converts them to stable values. It must not return mutable references to callers outside the dump implementation.

Represent non-value fields conservatively:

| Field kind | Snapshot representation |
| --- | --- |
| scalar flags/config | direct string value |
| pointers / ownership services | present flag, pointer identity string only when useful |
| arrays/maps/sets | count rows plus stable per-entry identity rows |
| locks/thread primitives | presence or related collection count, not lock internals |
| delegates/callbacks | bound/presence summary only if API allows it safely |
| AS VM internals | counts, names, ids, flags, pointer identity, declarations |

### D4: Treat "full engine" as full observable diagnostic coverage, not unsafe memory introspection

The implementation should enumerate every high-value member category in `FAngelscriptEngine`, `asCScriptEngine`, and `asCModule`, but it should not scrape raw memory, lock internals, allocator internals, or callback closure storage. For each member category the snapshot must choose one of:

- full scalar value,
- count,
- entry list,
- presence flag,
- pointer identity,
- explicit unsupported/unavailable marker.

This makes gaps visible rather than silent.

### D5: Add AS internal adapters with deterministic ordering

AngelScript internal containers use `asCArray`, `asCSymbolMap`, `asCMapByName`, and Unreal containers. Snapshot code should normalize entries into sorted rows by module name, declaration, id, or address string. Unstable order from maps should never leak into diff output.

The adapter should cover at minimum:

- `asCScriptEngine`: registered object/types/enums/global props/global funcs/funcdefs/template/list types, all registered/script type/function/global collections, imported functions, modules, module name map, build/defer flags, script section names, type-id map, GC stats, default namespace/access mask, message callback state.
- `asCModule`: name/base name, access mask/default namespace, script functions, global functions, bind info, template instances, script globals, global init state, breakpoints/discarded, local types, imports, dependencies, class/enum/typedef/funcdef lists, external types/functions, reload state, old/new reload module identities.
- AS type/function rows: id, name/declaration, namespace/module ownership, flags, object type/classification, ref/value traits where safely available.

### D6: Diff by row key and value

The diff algorithm should build a stable row key from `Category + Identity + Field`. It reports:

- `Added`: key exists only after.
- `Removed`: key exists only before.
- `Changed`: key exists in both but `Value` differs.
- `Unchanged`: optional, normally omitted from `StateDiff.csv` unless requested for tests or debugging.

`StateDiff.csv` columns:

- `ChangeType`
- `Category`
- `Identity`
- `Field`
- `BeforeValue`
- `AfterValue`
- `Source`

`StateDiffSummary.csv` should group by `Category` and `ChangeType`.

### D7: Preserve `DumpAll()` compatibility and add explicit APIs

Extend `FAngelscriptStateDump` with APIs such as:

```cpp
static FAngelscriptStateSnapshot CaptureSnapshot(FAngelscriptEngine& Engine);
static FAngelscriptStateDiff DiffSnapshots(const FAngelscriptStateSnapshot& Before, const FAngelscriptStateSnapshot& After);
static FTableResult DumpSnapshot(const FAngelscriptStateSnapshot& Snapshot, const FString& OutputDir);
static FTableResult DumpDiff(const FAngelscriptStateDiff& Diff, const FString& OutputDir);
```

`DumpAll()` should capture one snapshot and write the new snapshot tables alongside existing tables. Direct before/after diff capture can initially be C++ test/helper API; a console command can be added later if a concrete manual workflow is needed.

### D8: Compiler-event tests should log snapshots/diffs through shared helpers

Do not build local ad hoc snapshot/diff code in `AngelscriptCompilerEventsTests.cpp`. Instead, add reusable test helpers that:

- capture before/after snapshots,
- dump both snapshots and diff to a unique test output directory,
- log the output paths and diff summary counts,
- assert that expected compile impact rows exist.

This keeps compiler-event tests focused on events while using the same diagnostics infrastructure as production dump.

## Coverage Map

| Area | Current dump status | Planned status |
| --- | --- | --- |
| Runtime config | Partial; misses some flags such as `bSkipInitialCompile` and `bSkipStaticJITCodeGen` | Full config row set |
| Engine lifecycle flags | Partial overview | Full scalar snapshot rows |
| Active modules/descriptors | Human-friendly descriptor tables | Descriptor tables plus raw engine map/count rows |
| Module pointer map | Not exported | Count and per-entry pointer/module identity rows |
| Hot reload queues/maps | Partial summary | Counts and stable file/key rows |
| Context pool | Placeholder column is empty | Pool count and context pointer identities where safe |
| Owned services | Partial service tables | Presence/count rows for every service category |
| Static name caches | Not exported | Count and per-name/index rows |
| Script enum lookup | Not exported | Count and per enum/type-info identity rows |
| Bound Blueprint event arg specializations | Not exported | Count and sorted specialization rows |
| Diagnostics | Active diagnostics only | Active and last-emitted diagnostics summary rows |
| AS public engine counts | Present in `ScriptEngineState.csv` | Preserved plus internal container rows |
| AS engine internals | Not exported | Full observable collection counts/entries |
| AS module internals | Only public module counts | Full observable module internals |
| AS type/function internals | Not exported directly | Stable type/function identity rows |
| Diff | Not available | Snapshot diff and summary CSV |

## Risks / Trade-offs

- **Risk: Private AS headers are brittle across upstream AngelScript changes.** Mitigation: localize includes to `Dump/AngelscriptStateSnapshot.cpp` and keep snapshot code compiled with existing vendored source.
- **Risk: "Full" dump becomes too noisy.** Mitigation: split human tables from normalized snapshot tables and add category/source columns for filtering.
- **Risk: Pointer identities create false diffs.** Mitigation: prefer names/ids/declarations where available; use pointer strings only for resources without stable identities.
- **Risk: Capture during active compile/hot reload observes transient state.** Mitigation: document snapshots as point-in-time diagnostics and add tests around controlled compile boundaries.
- **Risk: Friend access grows over time.** Mitigation: one dump access helper owns all private reads; do not add broad public getters.
- **Risk: Existing dump tests become brittle when new files are added.** Mitigation: update expected file list and summary parsing tests together with the feature.

## Migration Plan

1. Add failing tests for snapshot API shape, dump table presence, and compile before/after diff expectations.
2. Add normalized snapshot row/diff row data types and pure diff algorithm.
3. Capture public FAS engine and public AS API rows.
4. Add dump-private access for private `FAngelscriptEngine` member categories.
5. Add AS internal adapters for `asCScriptEngine`, `asCModule`, type, and function rows.
6. Wire snapshot tables into `DumpAll()` and update `DumpSummary.csv`.
7. Add shared test logging helper and use it from compiler-event coverage.
8. Run focused dump/compiler tests, then build if runtime headers or private AS includes require compile validation.

Rollback is additive: remove the new dump-local files, remove added `FAngelscriptStateDump` APIs, remove the friend declaration, and restore the previous expected dump file list.

## Open Questions

- Whether `as.DumpEngineState` should gain command-line flags such as `--snapshot-only`, `--include-unchanged`, or `--diff-before <dir>` in the same change or a follow-up.
- Whether bytecode metadata should be represented only by function bytecode size/checksum rows or omitted from the first implementation.
- Whether snapshot row output should be one wide `EngineStateSnapshot.csv` table only, or both one normalized table and category-specific convenience tables.
