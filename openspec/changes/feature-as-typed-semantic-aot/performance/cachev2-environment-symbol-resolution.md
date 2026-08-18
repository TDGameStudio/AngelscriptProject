# CacheV2 environment-symbol resolution performance

## Symptom

The isolated Typed AOT capability test compiled its two in-memory AS modules in
about one millisecond and completed ClassGenerator reload/reinstancing in about
0.6--0.7 seconds, but did not reach the CacheV2 compile-capture batch log for a
further 34--35 seconds. The test body and generated Provider routing were not
the owner of this pause.

The production timing seam added around this boundary reports:

- ClassGenerator full lifetime, including destruction;
- cross-module function authority construction;
- complete module-artifact capture time;
- each candidate module's capture duration;
- the shared environment-index build count and indexed-symbol count.

## Localization

The decisive baseline was:

```text
[CacheV2] Compile capture batch:
  authority=0.066ms
  module_artifacts=34632.832ms
  total=34632.898ms
  modules=[ASStaticJITAotFixture=34583.591,
           ASStaticJITAotImportProvider=49.232]
```

Evidence:

```text
Saved/Tests/cachev2-module-capture-profile/
  20260815_043011_680_7946db48/Automation.log
```

`FAngelscriptCacheEngineEnvironmentResolver::Resolve()` was the hot path. For
every requested stable environment key it independently enumerated every live
`UClass`, every registered non-module AS type and property, and every currently
registered AS system function, rebuilding their stable references and ABIs.
The 47-function fixture therefore multiplied one global environment scan by
its dependency-query count.

## Fix

The resolver now builds a stable-key-sorted environment-symbol index on the
first real `Resolve()` request. The build is guarded by a resolver-local mutex;
after construction it is read-only for that resolver session. Modules with no
environment dependency do not build it. A duplicate stable key remains
ambiguous regardless of ABI and still fails closed, matching the former
resolver semantics.

One resolver is shared across the complete Engine compile transaction and is
also passed from function-input resolution into final graph validation. Direct
single-module callers receive one module-lifetime resolver. The index therefore
does not scale with module count or function count while the Engine registration
surface is frozen for the transaction.

The batch diagnostic is intentionally explicit:

```text
environment_index=[builds=1,symbols=135223]
```

`builds` must be `0` when no environment dependency is queried and at most `1`
for a normal compile transaction. This is a permanent regression/debug seam,
not a benchmark-only printf.

StaticJIT generation continues to use
`CaptureAngelscriptCurrentModuleFunctionFacts`: it does not create CacheV2
semantic records, packs, manifests, or lifecycle publications. It still must
resolve stable identities for native/UE binding dependencies, so it shares the
same one-time environment index rather than pretending that those dependencies
do not exist.

## TDD and validation evidence

The first RED required the resolver-session index diagnostics and failed to
compile because the API did not exist:

```text
Saved/Build/cachev2-environment-resolver-index-api-red/
  20260815_043607_263_d000102c/
```

The second RED required lazy construction (`builds=0` immediately after
construction) and failed with `Expected 0 to equal 1`:

```text
Saved/Tests/cachev2-environment-resolver-lazy-red/
  20260815_044216_714_2a8f6729/
```

Final production build and focused resolver test:

```text
Saved/Build/cachev2-environment-resolver-transaction-share-green-02/
  20260815_044740_033_ae6745e8/                 PASS
Saved/Tests/cachev2-environment-resolver-lazy-green/
  20260815_044800_251_a708f4bf/                 1/1 PASS
```

## Before/after result

| Scenario | Before | After | Reduction |
|---|---:|---:|---:|
| Two-module Typed AOT fixture, module artifacts | 34,632.832 ms | 858.399 ms | 97.5% |
| Startup batch, 37 candidates / 9 captured | 13,889.603 ms | 1,320.820 ms | 90.5% |

The final Typed AOT capability run remained green and proved that the entire
two-module batch built exactly one 135,223-symbol index:

```text
Saved/Tests/cachev2-environment-resolver-transaction-performance-green/
  20260815_044839_587_0a0a1322/
Result: 1/1 PASS
CacheV2: module_artifacts=858.399ms,
         environment_index=[builds=1,symbols=135223]
```

The same process startup batch reported one 153,313-symbol build for all 37
candidates and completed module capture in 1,320.820 ms.

Follow-up regression coverage:

```text
Saved/Tests/cachev2-environment-identity-regression-green/
  20260815_045018_309_4145327b/                 8/8 PASS
Saved/Tests/typed-aot-private-provider-after-cache-index-green/
  20260815_045111_128_b7fec5b6/                 1/1 PASS
```
