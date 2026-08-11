# Cache V2 V7.7 Development Benchmark Analysis

## Accepted run

- runner: `Tools/RunAngelscriptCacheBenchmark.ps1`
- result: `Passed`, exit `0`
- package: freshly built Development archive from
  `cache-v77-parallel-development1`
- machine: UE `5.8.0-55116800`, Windows 11, Intel Core Ultra 9 285K,
  24 logical processors, 128 GiB RAM, SSD workspace
- source surface: 38 staged loose `.as` files
- process launches: 61
- recorded rows: 56 = 14 warmup + 42 measured
- per group: 1 warmup + 3 measured
- diagnostics schema: 4

The package-resident reports, dumps, logs and isolated Stores are beneath the
`packageEvidenceRoot` in `cache-v77-real4-Result.json`. Every recorded process
exited successfully; every selected Current generation passed Python physical
integrity validation and, when diagnostics were enabled, schema-4 session
correlation.

## Correctness and determinism

An independent post-run assertion joined 4/16/64 MiB serial and parallel rows
by target and compared `generationId`, `sourceSnapshot`, module/type/function/
global counts, canonical bytes, Pack count, stored bytes and Manifest bytes.
All comparisons passed.

For every Pack target, both execution modes produced:

```text
GenerationId   10bcfebe90d90dc879bfbbd191e032ef640f0ab6756c28cf3da4923617414f2d
SourceSnapshot b802f7845e690690cf51e1309783b3a0a322577462dc265fbe0c670a2197a59f
PackCount      1
StoredPack     32691 bytes
```

The fixture is too small to cross even the 4 MiB Pack target, so physical
grouping is expected to be one Pack for all policies. This does not select an
optimal target. The separate C++ production Pack builder test uses seventeen
1 MiB canonical records and proves 5/2/1 grouping at 4/16/64 MiB plus exact
serial/parallel Pack-byte, index and ID parity.

Mutation rows alternated the changed source with baseline in one isolated
Store. They produced distinct, repeatable semantic generations:

| Source state | SourceSnapshot prefix | GenerationId prefix |
| --- | --- | --- |
| baseline | `b802f784...7a59f` | `10bcfebe...14f2d` |
| one body edit | `b8e7c980...207ae` | `9c3ba002...12831` |
| type schema edit | `9b23a199...` | `568e3fc1...3de9` |
| module state edit | `d12c6c36...` | `abdb589a...5369` |

Returning to baseline returned to the exact original content-addressed
Generation, rather than creating an order-dependent identity.

## Timing observations

Times are complete external package-process durations, not isolated cache-stage
microbenchmarks. There is intentionally no machine-time pass threshold.

| Scenario | Measured median | Range |
| --- | ---: | ---: |
| cold, no cache | 11093 ms | 11079–11100 ms |
| unchanged warm | 14055 ms | 14031–15416 ms |
| one body edit | 14097 ms | 14079–15431 ms |
| type schema edit | 14129 ms | 14079–15442 ms |
| module state edit | 14084 ms | 14021–14098 ms |

The tiny mixed package surface does **not** demonstrate a startup speedup:
unchanged warm is 26.7% slower than cold in this run. Its schema-4 report shows
eight candidate modules, 18 restored functions, four compiled misses, four
typed `NotCacheable` functions and zero corrupt rejections. The current hybrid
path therefore still pays source/declaration validation and compiles unsupported
families while adding Store read/validation/restore overhead. This result must
not be advertised as a performance win. A representative larger project corpus
and finer stage timing are required before claiming or tuning startup savings.

The result is still useful correctness evidence: unchanged launches select the
same source/generation, restore supported functions, reject no corrupt records,
and remain behaviorally equivalent. V7.7 deliberately treats timings as
observations rather than a pass/fail gate.

## Diagnostics overhead

| Mode | Median process time | Median report bytes | Trace events |
| --- | ---: | ---: | ---: |
| Disabled | 14094 ms | 0 | 0 |
| Summary | 14104 ms | 182237 | 0 |
| Verbose | 14125 ms | 248358 | 93 |

Summary was +0.07% and Verbose +0.22% against Disabled at the three-run median;
that difference is below what this process-level sample can treat as a stable
performance conclusion. Verbose lifecycle flush was 14.412 ms median
(11.335–14.849 ms). The bounded trace increased report size by about 66 KiB.

## Serial versus bounded parallel

| Pack target | Serial median | Parallel median | Parallel delta |
| --- | ---: | ---: | ---: |
| 4 MiB | 11177 ms | 11222 ms | +45 ms (+0.40%) |
| 16 MiB | 11107 ms | 11268 ms | +161 ms (+1.45%) |
| 64 MiB | 11113 ms | 11180 ms | +67 ms (+0.60%) |

All six groups contained only one 32.7 KiB Pack. Worker scheduling overhead is
therefore unsurprisingly not amortized, and end-to-end process noise is much
larger than the immutable preparation stage. This sample proves parity, not a
parallel speedup. The production default remains a conservative 64 MiB target
and four bounded workers for larger Stores; future representative-corpus data
may justify a small-work serial threshold or different target.

## Evidence files

- `cache-v77-real4-Context.json`
- `cache-v77-real4-Plan.json`
- `cache-v77-real4-Raw.csv`
- `cache-v77-real4-Summary.csv`
- `cache-v77-real4-Result.json`
