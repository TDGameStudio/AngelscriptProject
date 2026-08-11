# Cache V2 Benchmark Evidence Contract

This directory stores accepted raw and derived evidence produced by
`Tools/RunAngelscriptCacheBenchmark.ps1`. Partial runs and aspirational counters
are not evidence. The runner launches an already built loose package against a
disposable `.as` fixture and isolated Cache V2 roots; it never modifies project
or business scripts.

## Matrix

The default accepted run uses one warmup plus three measured rows per group:

- `cold-no-cache`;
- `unchanged-warm`;
- `one-body-edit`;
- `type-schema-edit`;
- `module-state-edit`;
- `diagnostics-disabled`, `diagnostics-summary`, and `diagnostics-verbose`;
- `pack-4-serial`, `pack-4-parallel`;
- `pack-16-serial`, `pack-16-parallel`;
- `pack-64-serial`, `pack-64-parallel`.

This produces 56 recorded rows. Five additional seed launches create the exact
baseline generation required by warm/edit/diagnostic series, so one complete
run executes 61 independent package processes.

## Files

- `Context.json`: parent/plugin commit and dirty state, UE/platform/
  configuration, archive/executable/script paths, source count, CPU, logical
  processors, memory, storage observations, OS, and exact invocation.
- `Plan.json`: every expected measured/warmup row and its diagnostics,
  preparation, Pack target, and worker policy.
- `Raw.csv`: one successfully correlated package launch per row.
- `Summary.csv`: three-run measured min/median/max by scenario/policy.
- `Result.json`: completed row counts and links to raw, summary, context, and
  the package-resident per-process evidence root.

## Raw fields

`Raw.csv` records only values that the current production surfaces can prove:

```text
timestampUtc, engineVersion, platform, configuration,
scenario, diagnosticsMode, preparationMode, packTargetMiB, maxWorkers,
isWarmup, runIndex, exitCode, totalMs, stagedSourceFiles,
moduleCount, typeRecordCount, functionRecordCount, globalCount,
candidateModuleCount, restoredFunctionCount, compiledMissCount,
notCacheableCount, rejectedCorruptCount,
canonicalRecordBytes, packCount, storedPackBytes, manifestBytes,
reportBytes, traceEventCount, traceEvictedCount, lifecycleFlushUs,
generationId, sourceSnapshot, reportPath, dumpPath, logPath
```

`totalMs` is external process duration. `lifecycleFlushUs` is nullable because
Summary and Disabled diagnostics intentionally do not require the bounded
decision journal. Candidate/reuse counters are nullable when the process report
is disabled. Every enabled report is schema 4, and every dump validates the
selected Current Store plus optional live-session correlation before a row is
accepted.

The design report originally proposed source/preprocess/parse/type/state hit
timings that are not all exposed by the production diagnostic boundary. They
are deliberately absent rather than reconstructed from logs or fabricated.
Stable source/generation coordinates, semantic record counts, function-reuse
aggregates, physical bytes, diagnostic sizes, and exact process duration are
the accepted V7.7 observation surface.

## Assertions and interpretation

- Process success, Store integrity, session correlation, row completeness, and
  serial/parallel semantic parity are hard requirements.
- V1 has no machine-time pass threshold. One warmup and three measured runs are
  retained so min/median/max can be inspected without promoting one noisy
  launch into a correctness failure.
- The package fixture is intentionally small. It may fit into one Pack at all
  three targets, so those rows cannot by themselves choose an optimal target.
  The separate C++ grouping test builds seventeen 1 MiB canonical records and
  proves that 4/16/64 MiB policies produce 5/2/1 Packs.
- Production defaults remain the conservative 64 MiB / four-worker policy until
  a representative larger project corpus justifies retuning.
- Forced serial and bounded parallel must emit byte-identical Pack bytes,
  Manifest indexes, RecordIds, PackIds, and GenerationIds. Runtime unit tests,
  not noisy process timing, are the authoritative equality proof.

## Related package acceptance

The separate Development and Shipping package-smoke matrices retain reports,
logs, dumps, source/generation coordinates, exit status, and exact archive root
for cold, unchanged warm, body edit, invalid source, restored source, and
structural cold/warm launches. Package smoke changes only its disposable archive
fixture and isolated cache root.
