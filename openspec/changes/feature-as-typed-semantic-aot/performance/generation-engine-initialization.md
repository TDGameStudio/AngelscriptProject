# StaticJIT generation Engine initialization performance

This attachment tracks measured generation/test Engine startup cost, the
specific Cache V2 boundary involved, hypotheses, corrective work, and before /
after evidence. It is deliberately separate from `tasks.md`.

## 2026-08-14 baseline

Authoritative run:

```text
Tools/RunTests.ps1
  -TestPrefix Angelscript.TestModule.StaticJIT
  -Label semantic-aot-scalar-staticjit-final

Result: 162/162 completed, 0 failed
Report: Saved/Tests/semantic-aot-scalar-staticjit-final/
        20260814_095248_336_864bc7eb/Report/index.json
Runner duration: 564.5 s
```

Longest cases:

| Test | Duration |
| --- | ---: |
| FreshCacheV2EnginePublishesAndExecutesCommittedProviderRoute | 91.75 s |
| SequentialLoadsKeepGeneratedRegistryVisible | 79.86 s |
| GeneratedOutputVerify | 76.94 s |
| TypedASTScalarProbeMatchesInterpreterAndBytecodeJIT | 37.37 s |
| Next non-AOT test | 8.73 s |

Repeated log intervals show the same fixture source compile taking about one
millisecond, followed by 34-38 seconds before the Cache V2 capture-batch log.
Full Bind replay is normally 1.5-2.1 seconds and therefore is not the dominant
cost.

## Confirmed current boundary

The AOT helper sets `bDisableCacheV2Persistence=true` for ordinary generation
and interpreter sessions, but that switch only prevents persistence. During a
successful compile, `FAngelscriptEngine::CompileModules` still calls
`CaptureAngelscriptCleanCompiledModule` for every generation module and then
builds `FAngelscriptStaticJITGenerationSnapshot` from the resulting full clean
artifacts.

The snapshot consumes only canonical module names, verified function content
identities, and verified stable reference sets from those artifacts. It does
not consume serialized Cache V2 records. The present path nevertheless writes
function artifacts, serializes Cache records, and graph-validates the complete
record set before the snapshot is frozen.

The first diagnostic step adds generation-only phase timings for cross-module
authority and each full module capture. No behavior or timeout threshold is
changed. A focused AOT generation run will identify the exact expensive phase
before a light-weight generation-fact path is selected.

## Confirmed root cause

The focused baseline reproduced the delay without the full StaticJIT suite:

```text
Test: Angelscript.TestModule.StaticJIT.AOT.
      FAngelscriptStaticJITAotTests.GeneratedOutputVerify
Label: staticjit-generation-capture-timing-baseline-2
Evidence: Saved/Tests/staticjit-generation-capture-timing-baseline-2/
          20260814_100922_610_c071ea68
Result: 1/1 passed
Runner duration: 182 s
```

The script compilation itself took about 1-2 ms and cross-module authority
about 0.08 ms. The two generation Engines then spent 45,757-45,883 ms each in
full module capture. `GeneratedOutputVerify` deliberately constructs two
generation Engines to prove deterministic output, so the same unnecessary
work was paid twice.

The first facts-only early return removed record serialization and graph-pack
construction, reducing each large generation capture to 26.8-27.4 s. Narrower
timing around the retained front half then isolated essentially all remaining
cost:

```text
[StaticJITGeneration] Class graph fact timings_ms=
  [authority=0.588,
   artifact_debug=1.026,
   dependency_input_encode=23026.898,
   total=23028.512]
```

The expensive operation was
`FAngelscriptCacheCompilerBridge::ResolveCurrentFunctionInput` for every
function. That routine constructs a Cache invalidation digest from the complete
current module authority. The generation snapshot never stores or consumes
`FunctionInputDigest`; it consumes the already verified stable function
identity and the ordered stable dependency/reference set. Recomputing the
Cache-only digest for each function therefore produced near-quadratic work
without affecting generated JIT output.

## Implemented generation-only boundary

`CaptureAngelscriptCurrentModuleFunctionFacts` now reuses the exact existing
clean-capture semantic front half so reflected `StaticsClass`, type/property
references, imports, and execution-envelope validation retain one authority.
When `bFunctionFactsOnly` is set it:

- emits no SourceIndex, semantic, function-body, debug-sidecar, snapshot, pack,
  manifest, or other Cache V2 records;
- retains the maintained-fork function artifact writer, canonical debug hash,
  stable actual-dependency capture, cross-module authority, and execution codec
  hash validation;
- skips only `ResolveCurrentFunctionInput` and `FunctionInputDigest`, which are
  Cache invalidation data not represented in the generation snapshot;
- promotes only sorted function identities and stable reference sets into the
  transient generation input.

Normal runtime/reload Cache V2 capture still calls the full path. Generation
capture failures are logged under `[StaticJITGeneration]` and do not publish a
Cache decision event. The snapshot exposes `InputCacheRecordCount` as an audit
field; focused tests require it to remain zero.

An earlier experiment tried to generalize the diagnostics-only function helper
into a new type/global resolver. It could not represent the reflection-only
`StaticsClass` operand graph and made the generated fixture fall back. No golden
files were updated. The experiment was removed; the final implementation is a
narrow early-return mode on the existing authoritative capture vertical, while
the diagnostics helper retains its previous behavior.

## Final measurements and verification

The final large-fixture measurement after cleanup is:

```text
Label: staticjit-generation-cache-facts-cleanup-green
Evidence: Saved/Tests/staticjit-generation-cache-facts-cleanup-green/
          20260814_105209_361_52423f23
Result: 1/1 passed

[StaticJITGeneration] Class graph fact timings_ms=
  [authority=0.367,
   artifact_debug=0.644,
   dependency_encode=11.227,
   total=12.238]
[StaticJITGeneration] Snapshot input timings_ms=
  [authority=0.042,function_facts=12.823,total=12.866]
```

| Boundary | Before | Final | Change |
| --- | ---: | ---: | ---: |
| Large module capture / facts | 45,757-45,883 ms | 12.238 ms | about 3,740x faster |
| Remaining facts front half after record early return | 23,028.512 ms | 12.238 ms | about 1,882x faster |
| Input Cache V2 records in generation snapshot | 9 in RED contract run | 0 | eliminated |

Correctness evidence:

- `staticjit-generation-cache-facts-cleanup-build`: Editor Development build
  passed after the final cleanup.
- `staticjit-generation-cache-facts-cleanup-green`: large 48-function module,
  1/1 passed; the representative generated scalar function has verified
  identity and references, and the snapshot carries zero Cache records.
- `staticjit-generation-engine-facts-final-green`: generation Engine suite,
  3/3 passed.
- `staticjit-generation-generated-output-final-green`: the exported Automation
  report records `GeneratedOutputVerify` as 1/1 success with zero warnings and
  errors. Both generation runs produced byte-identical module JIT source,
  Provider source/header, owned-files manifest, and Provider manifest; no golden
  output was changed for the optimization.

The roughly 40-second one-time full Cache capture still visible when running an
individual AOT Provider test belongs to its shared ordinary-runtime fixture.
Those tests intentionally need a current Cache publication to validate Provider
reference resolution and execution. It is separate from the generation Engine
path fixed here, is amortized across the AOT test class, and is not broadened
into this performance correction.
