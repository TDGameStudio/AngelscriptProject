# StaticJIT Provider benchmark notes — 2026-08-13

These measurements were captured on the same Windows 11 / UE 5.8 development
machine (`Intel Core Ultra 9 285K`, 24 physical cores). They are engineering
evidence for this change, not a cross-machine performance promise.

## Main result

The first routing instrumentation exposed a repeated full-registration-surface
scan for every `EnvironmentSymbol`. With 46 verified routes and 37 distinct
stable references, reference materialization took 12,116.510 ms in the current
source Engine and 12,518.721 ms in the fresh-Cache fixture's source Engine.

`FAngelscriptJITCurrentEngineReferenceResolverBuilder` now constructs the
requested EnvironmentSymbol index in one pass across the current Engine's
registered types, functions, properties, and code roots. The same two cases
take 696.227 ms and 763.188 ms respectively. Provider catalog snapshot and
route match/publication remain below one millisecond in these fixtures.

The optimization does not cache process addresses across compile generations.
Every resolver remains Engine-local and is rebuilt from the current immutable
Cache V2 publication plus the current registration surface. This preserves the
missing, ambiguity, kind, and ABI-mismatch fail-closed behavior.

Evidence:

- before: `Saved/Tests/static-jit-routing-timings/20260813_115911_960_b922646e`;
- after: `Saved/Tests/Tests/static-jit-reference-batch-index-benchmark/20260813_121237_229_646d65ab` (2/2 pass);
- semantic regression: `Saved/Tests/Tests/static-jit-reference-batch-index-regression/20260813_121644_214_1ba79cf7` (10/10 pass);
- build: `Saved/Build/static-jit-reference-batch-index-build-r2/20260813_121216_832_60e3c612`.

## Strict module translation-unit boundary

Generated-file counts are physical module-owned `.jit.cpp` files. Provider
selector/manifest implementation files are not counted as AS-module files.
The largest current project module has 4 generated functions and is 11,948
bytes; the committed `AngelscriptTestJIT` stress fixture has 44 functions and
is 136,259 bytes.

Touching either file and building with `-NoXGE` produced exactly four UBT
actions: compile that one `.jit.cpp`, link its module `.lib`, link its module
`.dll`, and write target metadata. No unrelated AS-module `.jit.cpp` was
compiled. Timestamps were restored after each measurement. Warm samples are
the useful comparison; the first representative sample contains cold
compiler/linker-cache cost and is retained only as raw evidence.

Repeated generation had already preserved path, hash, length, and timestamp
for all 39/39 generated files:
`Saved/AngelscriptJITRuns/staticjit-host-repeat-generate-idempotency/20260813_055605_192_c4dbf3c8`.

## Cache V2 restore plus JIT binding

The isolated fresh-Engine test restores 46 functions from the persisted Cache
V2 candidate, reports three compiled misses, three not-cacheable functions and
six frontend events, then proves an exact Native binding executes. Its complete
fixture duration improved from 102.15 s to 86.54 s after the EnvironmentSymbol
batch-index change. The final two-route publication itself is 0.616 ms; most of
the remaining duration is isolated Engine registration and AS compile/restore
work outside Provider routing.

## Editor VM fallback

The automatic-import hot-reload fixture changes one function body. The changed
function receives `ContentMismatch` and VM, while its unchanged consumer keeps
the exact Native entry. The measured diagnostic refresh is 0.358 ms total for
two verified routes (one Native, one VM).

Evidence:
`Saved/Tests/Tests/static-jit-editor-vm-fallback-benchmark/20260813_120444_034_2dbc8dd0` (1/1 pass).

## Immutable cooked direct-call status

The production generator deliberately sets
`bUseImmutableDirectScriptCalls=false`; all 18 `GameShipping` manifest entries
currently have flags `0`. The package therefore benchmarks the supported
Native Binding route, not a direct script-to-script symbol call. Both Shipping
process starts publish 18/18 Native and 0 VM with 12/12 references. This is not
reported as a direct-call speedup.

The specification says a complete immutable packaged set *may* enable direct
calls. The validation boundary and fail-closed tests are present, but enabling
and measuring production direct-call emission is intentionally deferred to a
separate optimization change so it cannot be conflated with this routing and
one-module-per-file correctness migration.
