# Predecessor terminal-disposition review

Date: 2026-07-27

This handoff is a source- and catalog-based review of all 222 rows in
`audits/predecessor-baseline.csv`. It does not treat a missing predecessor
method name or file as a coverage gap. Each `Superseded` row instead names the
specific current coverage product or products, their exact catalog owner, and
the product-specific expected contract in the CSV rationale.

No build or automation test was run. No source, task list, or primary audit CSV
was changed.

## Result

| Final disposition | Rows |
| --- | ---: |
| `Implemented` | 7 |
| `Superseded` | 205 |
| `ApiDeferred` | 8 |
| `Obsolete` | 2 |
| Total | 222 |

The merge-ready row set is:

- `handoffs/predecessor-terminal-disposition-review.csv`

It preserves the nine-column predecessor schema and the original row keys.

## Exact implemented predecessor methods

Seven predecessor methods remain the exact current product owner rather than a
legacy compatibility method:

- `ConcurrentIncrementAndDecrementRemainBalanced` →
  `ENG-ATOMIC-BATCHED-CONCURRENCY`
- `DefaultConstructionStartsAtZero` →
  `ENG-ATOMIC-DEFAULT-CONSTRUCTION`
- `IncrementAndDecrementReturnExpectedValues` →
  `ENG-ATOMIC-RETURN-TRANSITIONS`
- `PreparedThreadReturnsLocalData` →
  `ENG-TLS-MAIN-THREAD-STABILITY`
- `RepeatedLookupReturnsStableLocalData` →
  `ENG-TLS-MAIN-STABILITY-AFTER-WORKER`
- `WorkerThreadsReceiveDistinctLocalData` →
  `ENG-TLS-WORKER-ISOLATION`
- `SuspendAndResumePreserveContextState` →
  `RT-CTX-SUSPEND-FORK-REJECTION`

The last item deliberately owns the current fork's active-context suspension
rejection; it does not claim that positive suspend/resume semantics work.

## API-deferred predecessor rows

These eight rows remain discoverable Disabled `#as-v238-backport` tests and are
assigned to `V238-DESIRED-BEHAVIOR`. Their prerequisite is an intentional
selective 2.38 parser/compiler/runtime backport for the corresponding syntax:

| Domain | Required method |
| --- | --- |
| Conformance | `AnonymousFunctionCompilesInvokesAndReturnsValue` |
| Conformance | `BoolContextSelectsBranchAndLoopConditions` |
| Conformance | `ConstructorMemberInitializerEvaluatesInDeclarationOrder` |
| Conformance | `DeletedDefaultOrCopyMemberRejectsTheMatchingUse` |
| Conformance | `GeneratedDefaultAndCopyMembersPreserveValues` |
| Conformance | `TemplateFunctionInstantiatesForTwoPrimitiveTypes` |
| Conformance | `UsingDirectiveResolvesTypeAndFunction` |
| Conformance | `VariadicFunctionAcceptsZeroAndMultipleTrailingArguments` |

These are deferred positive semantics, not current-fork gaps and not silently
passing tests.

## Obsolete predecessor rows

Two requirements no longer describe a surviving observable surface:

- `PostBuildEnumDescriptionsReleaseTemporaryState`: the current vendored
  `asCBuilder` has no `enumDescriptions` member or equivalent post-build
  temporary table in `as_builder.h` / `as_builder.cpp`. The predecessor tied
  its assertion to a removed internal representation.
- `UnavailableGlobalMemoryCallbacksRemainUninvoked`: the current fork exposes
  no global memory-callback registration surface. Asserting that a nonexistent
  callback remains uninvoked is vacuous; active engine-memory products instead
  own observable pool allocation, reuse, bulk release, and idempotent cleanup.

## Requirements that do not need a new product

No predecessor row requires a new coverage product after exact semantic
reconciliation. The apparent 198 “missing” rows are overwhelmingly renamed,
split, or deepened owners. Examples:

- broad compiler bytecode requirements split into call/control shapes,
  low-level jump resolution, linked-container mutation, and optimization;
- broad language methods split into product axes such as constructor
  selection, transfer, visibility, order/failure, and partial cleanup;
- unsupported try/catch/rethrow requirements map to the enabled
  `LANG-EX-HANDLER-REJECTION` product rather than to a nonexistent positive
  handler claim;
- config-group ownership maps to
  `TYPE-CONFIG-GROUP-STORAGE-ONLY`, which explicitly records the fork's
  storage-only/no-op behavior;
- exact script-interface semantics map to the registered application-interface
  product and do not claim unsupported script syntax;
- runtime object-construction failure is owned jointly by constructor partial
  cleanup, destructor partial cleanup, and script-object ownership products
  rather than by a duplicated Runtime-only method.

This “no new product” conclusion is about catalog coverage identity. It does
not waive correctness defects in an existing owner.

## Existing owner repairs identified during the review

The separate Compiler pre-build review remains applicable. Several predecessor
rows map correctly to current Compiler product IDs, but the newest owner
implementations still need correction before their evidence can be accepted:

- `COMPILER-BYTECODE-JUMP-RESOLUTION` has a deterministic unequal-offset
  assertion defect for two equal-distance labels.
- `COMPILER-BYTECODE-CALL-CONTROL-SHAPES` contains non-normalized and
  name/arity declaration lookups that violate `UnitTest.md`.
- new Bytecode/Dependency complete-source print sites are not yet represented
  in the generated-source registry.
- CompileFunction and warning-offset owners overstate bytecode, diagnostic,
  cleanup, isolation, or exact-row evidence in several methods.

These required repair/strengthening of already catalogued owners, not a new
predecessor product ID. They were subsequently addressed by the Compiler
repair batch recorded in the main `issues.md` and `verification.md`; the
current Compiler prefix is 119/119 PASS and the current complete SDK prefix is
666/666 PASS. This historical handoff section is retained to show why the
predecessor mapping alone was not accepted as runtime proof.

## Static checks performed

- CSV rows: `222`
- unique `(Domain, Theme, RequiredMethod)` keys: `222`
- key difference from `predecessor-baseline.csv`: `0`
- blank dispositions: `0`
- blank rationales: `0`
- `Implemented` / `Superseded` / `ApiDeferred` rows without IDs: `0`
- distinct mapped product IDs: `215`
- mapped catalog owner files missing: `0`
- mapped catalog owner methods missing: `0`
- mapped product IDs absent from current SDK source markers: `0`
- `ReconcilePredecessorScenarios.ps1 -RequireFinalDisposition`: PASS for all
  222 rows, using a temporary output CSV outside the workspace

The static validator accepts all disposition values and required fields. This
review intentionally makes no build or runtime-pass claim.
