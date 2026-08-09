# Cache V2 Benchmark Evidence Contract

This directory stores raw benchmark evidence produced during implementation. It intentionally contains no fabricated baseline numbers in the plan-only phase.

## Scenarios

- `cold-no-cache`
- `exact-warm`
- `one-body-edit`
- `type-schema-edit`
- `module-state-edit`
- `forced-serial-generation`
- `bounded-parallel-generation`

Each scenario uses at least one warmup and three measured runs. Record raw rows first; derive median/min/max in a separate summary file. V1 uses exact work counters and semantic parity as hard assertions and does not add a machine-time pass threshold before evidence exists.

## Required Raw CSV Header

```csv
timestampUtc,commit,engineVersion,platform,configuration,scenario,isWarmup,runIndex,sourceFilesHashed,preprocessedModules,parsedModules,compiledFunctions,moduleHits,moduleMisses,typeHits,typeMisses,stateHits,stateMisses,functionHits,functionMisses,bytesRead,bytesWritten,totalMs,sourceHashMs,readValidateMs,restoreMs,compileMs,classGeneratorMs,prepareWriteMs
```

## Required Context

Every benchmark set records:

- parent and plugin-submodule commits or dirty-state identifiers;
- configured UE version and Runtime Cache schema/profile/context;
- CPU, memory, storage type, OS and worker policy;
- source fixture/module/function/type/global counts;
- cache root and whether compaction occurred;
- exact command, report path and process exit.

## Package Multi-Launch Evidence

Development and Shipping each retain separate reports for:

1. cold first launch;
2. unchanged warm launch;
3. one-body edit;
4. invalid source;
5. restored last-good source;
6. structural cold start.

The summary must link each process log, `-as-cache-report` JSON, generation manifest ID and package archive path. Package smoke modifies only its disposable archive fixture and isolated cache root.
