# Compiler Internal Deferred Implementation

## Scope and result

This batch re-evaluates the six Compiler `ApiDeferred` rows from
`internal-method-engine-frontend-compiler-review-v2.csv` against the current
fork source and implements only paths with a direct method-level oracle.

| Internal method | Revised disposition | Focused owner |
|---|---|---|
| `asCCompiler::asCCompiler` | `DirectCovered` | `COMPILER-INTERNAL-COMPILER-LIFECYCLE` |
| `asCCompiler::~asCCompiler` | `DirectCovered` | `COMPILER-INTERNAL-COMPILER-LIFECYCLE` |
| `asCCompiler::Reset` | `DirectCovered` | `COMPILER-INTERNAL-COMPILER-LIFECYCLE` |
| `asCCompiler::AreAllTemplateSubtypesCovariant` | `DirectCovered` | `COMPILER-INTERNAL-TEMPLATE-COVARIANCE` |
| `asCCompiler::AreTemplateTypesWithFailedCovariance` | `DirectCovered` | `COMPILER-INTERNAL-TEMPLATE-COVARIANCE` |
| `asCCompiler::ImplicitConvLambdaToFunc` | `ApiDeferred` | none until the selected 2.38 lambda port |

Five rows now have exact direct owners. One row remains honestly deferred. This
handoff and its companion CSV are batch-local evidence; they do not rewrite
`tasks.md`, `progress.md`, or the authoritative internal-method reconciliation
CSV.

## Lifecycle owner

`Compiler/AngelscriptNativeCompilerInternalLifecycleTests.cpp` adds
`COMPILER-INTERNAL-COMPILER-LIFECYCLE` with three explicit scenarios:

1. `construction_defaults` observes only fields explicitly initialized by the
   constructor. It does not claim unspecified fields that are initialized by
   `Reset`.
2. `reset_transient_state` creates a case-owned raw engine/module/builder from a
   real printed AngelScript section, seeds each documented transient category,
   invokes `Reset` through a narrow test subclass, and asserts the exact new
   owners and cleared state.
3. `destructor_owned_resources` seeds a two-level variable-scope chain and one
   compiler-owned string constant. A tracking `asIStringFactory` observes the
   exact destructor release, and the prior engine factory is restored before
   case-owned engine teardown.

Native-only construction/destruction review inputs and the real reset script
are printed through `PrintGeneratedAsSource`. The test does not introduce a
production header seam or global memory-hook mutation.

## Template covariance owner

`Compiler/AngelscriptNativeCompilerTemplateCovarianceTests.cpp` adds
`COMPILER-INTERNAL-TEMPLATE-COVARIANCE`. The exported fork internals permit a
narrow test subclass to invoke both protected classifiers directly. Eight
source-valid relationship categories are crossed with the two method oracles:

- covariance flag absent;
- same instance;
- different template base;
- exact primitive subtype;
- derived reference subtype;
- unrelated reference subtype;
- primitive subtype mismatch;
- recursively nested covariant template.

The expected results are independent constants in the case table. Every one of
the sixteen relation-by-oracle cells prints a comment-only native review source
before direct invocation. Synthetic object types have no engine owner, so their
destructors cannot mutate the case-owned engine type tables.

## Why lambda conversion remains deferred

The current fork contains parser/compiler fragments for lambda expressions, but
that does not make lambda conversion a supported current-fork language path:

- `Documents/Guides/AngelscriptForkStrategy.md` records
  `Plan_AS238LambdaPort.md` as `未开始`.
- `Conformance/AngelscriptNativeLambda238Tests.cpp` is compiled and
  discoverable only as an `EAutomationTestFlags::Disabled` test tagged
  `#as-v238-backport`.
- `ImplicitConvLambdaToFunc` requires both a funcdef target and an
  `asCExprContext::IsLambda()` expression, then depends on builder datatype
  parsing and `RegisterLambda` for the generated-code path.

Constructing a private AST/expression context by hand would only prove an
isolated retained routine. It would not prove that the current fork can parse,
compile, publish, execute, and clean up the language feature. The row therefore
remains `ApiDeferred`, with this concrete prerequisite:

1. complete the selected 2.38 lambda syntax/semantic port;
2. enable the real tagged fixture;
3. prove parse, compile, funcdef metadata, runtime invocation, and cleanup;
4. add method-level arity, parameter type, in/out modifier, and
   `generateCode=false/true` cases.

No current-fork positive behavior is fabricated and the Disabled 2.38 fixture
is not reclassified as implemented current-fork coverage.

## Catalog and generated-source ownership

The batch updates:

- `catalogs/coverage-products.psd1` with the two focused products;
- `catalogs/generated-source-registry.csv` with both exact source owners;
- the two C++ methods with exact `AS_NATIVE_PRODUCT` markers.

The lifecycle catalog expands to three case IDs. The covariance catalog expands
to sixteen case IDs. The catalog additions therefore declare nineteen new
reviewable IDs without changing any selected-2.38 classification.

## Verification boundary

Per the batch instruction, this change does not build or run automation tests.
Only catalog, source reconciliation, boundary, inline-format, and scoped diff
checks are permitted. Runtime pass/fail status must remain unclaimed until a
later coherent build-and-test phase.

The final static checks at the shared source state report:

- catalog validation: `318` products, `46,426` unique expected IDs,
  `46,280` CurrentFork IDs, and `65` Future238Disabled IDs, `PASS`;
- source reconciliation: `317` Implemented plus one DisabledImplemented,
  zero incomplete products, `687` methods, `313` product-owned plus `374`
  explicit non-product methods, and zero unresolved methods;
- native SDK boundary audit: zero violations;
- inline-AS audit: `296/296` ordinary raw sources conform, two registered
  escaped exact inputs, and zero violations;
- scoped plugin and parent `git diff --check`: `PASS`.

The shared totals include other already-present catalog owners. This batch
itself contributes exactly two products, two CQTest methods, and nineteen
expected IDs. No build or automation result is claimed.
