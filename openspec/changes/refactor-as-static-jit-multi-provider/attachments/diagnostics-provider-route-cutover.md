# Provider/Route Diagnostics Cutover Notes

This attachment records the progressive implementation evidence for tasks
11.1-11.3. The diagnostics surface is an observer only: it may copy Provider
catalogs, current Engine routes, binding counters, and current reference
resolution results, but it does not register/unregister Providers, publish
routes, mutate Cache V2, or replace the installed JIT compiler.

## 2026-08-13: legacy diagnostics were removed with the global path

The first diagnostics cutover removed all `FJITDatabase`, `ActiveInfo`,
whole-cache `DataGuid`, and `PrecompiledScript.Cache` fields from
`FStaticJITDiagnostics`. `DumpAll()` now writes `JITProviders.csv` and
`JITRoutes.csv`; it no longer fabricates CSV views of the deleted database or
whole-cache activation state. Empty/no-current-Engine snapshots remain valid.

The initial Provider/Route implementation and the migrated generated-output
fixtures passed together:

```text
Saved/Tests/static-jit-diagnostics-generated-r8/
  20260813_112319_274_8fd18d01/Report
Totals: total=13 passed=13 failed=0 skipped=0
```

Three generated-output tests initially failed because their isolated memory
modules had no stable virtual path. Production artifact capture correctly
refused to invent a module identity. The shared test helper now records the
valid `/Angelscript/...` virtual path parsed from each fixture filename. A
separate diagnostics-only capture seam uses the maintained fork writer to
encode real function artifacts and references without synthesizing SourceIndex
records or publishing Cache generations. Production generation still requires
the verified current RouteSnapshot and Cache publication.

## 2026-08-13: schema v2 and function query

The machine-readable schema is revision 2. It includes:

- Provider ABI revision and publication ordinal;
- ProviderId, generation, profile, environment, artifact-set digest,
  diagnostic owner/module names, and compatible/rejected/conflicting counts;
- AS StableModuleKey, strict generated module-source path, function count, and
  deterministic module-artifact digest;
- complete function execution/debug/profile/environment/entry-ABI identity;
- VM/Raw/Parms availability, stable reference descriptors, and resolved state;
- current Engine route generation, Native/VM selection, typed match result,
  transient numeric FunctionId, selected Provider entry, reference counts,
  immutable cooked dispatch flag, and execution counters;
- every evaluated Provider candidate, including all exact candidates for
  `AmbiguousExactProvider`.

Records are sorted by stable Provider/module/function/reference identity before
serialization. Pointers and process addresses are not emitted. The console
surface accepts:

```text
as.StaticJIT.DumpDiagnostics
as.StaticJIT.DumpDiagnostics -Output=<filename.json>
as.StaticJIT.DumpDiagnostics -Function=<canonical-declaration-or-64-hex-key>
as.StaticJIT.DumpDiagnostics -Function=<key> -Output=<filename.json>
```

The query is read-only. It filters matching routes and Provider entries and
sets `queryMatched`; an unresolved query logs a warning and still emits a valid
schema document.

RED evidence after the new test was compiled:

```text
Saved/Tests/static-jit-diagnostics-schema-red-r2/
  20260813_113148_963_3226920e/Report
Totals: total=4 passed=2 failed=2 skipped=0
```

The failures named the missing schema revision, Provider ABI, module ownership,
candidate records, resolved reference state, and command query support. The
implementation build and GREEN evidence are:

```text
Saved/Build/static-jit-diagnostics-schema-green-build-r2/
  20260813_113927_788_ffa0ed4b
Saved/Tests/static-jit-diagnostics-schema-green-r3/
  20260813_113948_806_0b693fe2/Report
Totals: total=4 passed=4 failed=0 skipped=0
```

One complete Capture on the test Engine rebuilds a current reference resolver
so it can explain reference misses rather than trusting generated descriptors.
The full diagnostics test intentionally calls Capture several times and took
223.8 seconds end-to-end; the explicit command is therefore an active
diagnostic operation, not a frame/tick telemetry surface. This cost belongs in
the task-11 benchmark data and must not be hidden by caching pointer-bearing
resolver state globally.

## 2026-08-13: deterministic multi-Provider conflict proof

A synthetic snapshot inserts Provider B before Provider A but requires stable
ProviderId sorting, two exact candidate records, and
`AmbiguousExactProvider + Vm` for the shared function. The first test run
crashed before assertions because the fixture passed an arbitrary seed string
to UE's hex-parsing `FBlake3Hash(FWideStringView)` constructor. The fixture was
corrected to use `FAngelscriptArtifactCanonicalWriter`; no production code was
changed for that test error.

Final evidence:

```text
Saved/Build/static-jit-diagnostics-conflict-build-r3/
  20260813_115133_854_92670885
Saved/Tests/static-jit-diagnostics-conflict-green-r2/
  20260813_115158_282_48d52a67/Report
Totals: total=1 passed=1 failed=0 skipped=0
```

## 2026-08-13: standalone inspector

`Tools/Diagnostics/InspectStaticJITDump.py` uses only the Python standard
library. It validates schema/ABI, required fields, 64-hex stable identities,
deterministic ordering, Provider/module/function membership, module function
counts, reference slots, Route totals, candidate Provider generations, and
Native/VM/match-result consistency. It prints a compact summary and supports
`--fail-on-mismatch` for CI gates.

Checked-in fixtures under `Tools/Diagnostics/Fixtures/StaticJIT/` prove:

- `valid.json`: valid and all Exact, exit 0;
- `mismatch.json`: structurally valid `ContentMismatch`, exit 0 normally and
  exit 2 with `--fail-on-mismatch`;
- `malformed.json`: invalid JSON with exact line/column report, exit 1.

The inspector never imports Unreal modules or parses human log text.

## 2026-08-13: routing benchmark exposed repeated Environment scans

The first phase-level routing measurements showed that Registry access and
Provider matching were already negligible, while stable-reference resolution
dominated every non-trivial refresh. For 46 verified routes and 37 distinct
references, the current-source fixture measured:

```text
catalog=0.001 ms
discovery=0.032 ms
references=12116.510 ms
routes=0.092 ms
total=12116.643 ms
```

The cause was not Cache V2 corruption or Provider lookup. Each requested
`EnvironmentSymbol` independently asked the current Engine resolver to scan
all registered types, functions, and properties. The AOT provider contains 30
EnvironmentSymbol slots, so the same large application registration surface
was re-hashed repeatedly.

`FAngelscriptJITCurrentEngineReferenceResolverBuilder` now materializes only
the requested EnvironmentSymbol keys in one pass across the current Engine
surface. It still builds a new Engine-local immutable resolver from the current
Cache V2 publication. No live pointer is cached globally or reused across a
compile publication. Duplicate values remain visible to the ordinary resolver,
so ambiguous, wrong-kind, missing, and ABI-mismatch results remain fail-closed.

The same 46-route fixture now measures:

```text
catalog=0.001 ms
discovery=0.018 ms
references=696.227 ms
routes=0.093 ms
total=696.346 ms
```

The stable-reference phase decreased by approximately 94.3%. The fresh-Cache
source session similarly decreased from 12,518.721 ms to 763.188 ms. The
complete fresh Cache V2 + Native execution test decreased from 102.15 s to
86.54 s; the remaining time is dominated by isolated Engine registration and
AS compile/restore work.

Evidence:

```text
Saved/Build/static-jit-reference-batch-index-build-r2/
  20260813_121216_832_60e3c612
Saved/Tests/Tests/static-jit-reference-batch-index-benchmark/
  20260813_121237_229_646d65ab   2/2 PASS
Saved/Tests/Tests/static-jit-reference-batch-index-regression/
  20260813_121644_214_1ba79cf7   10/10 PASS
```

Raw phase data, generated-file counts, rebuild samples, Cache V2 timing, and
packaged Native/direct-call status are stored under `benchmarks/`.
