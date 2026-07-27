# Internal Method Semantic Review V2: Engine, Frontend, Compiler

## Result

This second pass re-evaluates all 570 rows without replacing the conservative
v1 handoff. It recognizes direct member pointers, test-subclass exposure,
product-local helper chains, constructor/destructor lifecycle observations, and
method-specific public behavior correlations.

| Domain | Rows | DirectInternal | PublicBehavior | NotApplicable | Deferred / real gap |
|---|---:|---:|---:|---:|---:|
| Engine | 126 | 15 | 94 | 0 | 17 |
| Frontend | 99 | 41 | 58 | 0 | 0 |
| Compiler | 345 | 24 | 315 | 0 | 6 |
| Total | 570 | 80 | 467 | 0 | 23 |

The CSV uses the reconciliation vocabulary:

- `DirectCovered` corresponds to DirectInternal.
- `PublicContractCovered` corresponds to PublicBehavior.
- `NotApplicable` remains zero because no reviewed implementation was proven
  unreachable, excluded by the active build, or a pure forwarding body with no
  separately observable responsibility.
- `ApiDeferred` is reserved for the 23 rows where an exact semantic chain still
  could not be established.

## V2 evidence rules

Direct evidence accepts:

- receiver-qualified calls inside the exact product-owning `TEST_METHOD`;
- `&Class::Method` passed to a product-local stage helper;
- protected methods exposed and invoked through a test-only subclass;
- a narrow helper called by the product owner when that helper's only relevant
  responsibility is the reviewed internal method.

Public behavior evidence requires all of:

1. a concrete source responsibility for the internal method;
2. an exposing builder, parser, compiler, engine, or public-interface call
   chain;
3. a named catalog product whose oracle observes that responsibility, such as
   AST family, stage publication barrier, signed jump target, runtime dispatch,
   diagnostic, ownership, cleanup, or isolation.

Generic statements such as “Module Build compiles code” are not dispositions.
For example:

- `asCBuilder::BuildGenerateFunctions` and layout stages correlate to their
  exact staged publication/layout products and metadata or runtime oracles;
- `asCCompiler::CompileSwitchStatement` correlates through
  `CompileFunction` to the switch/control-flow product, not to a generic
  compiler smoke;
- string, parser, tokenizer, and node methods correlate to raw Frontend owners
  that assert exact text, token span, AST link, source range, or ownership;
- engine cleanup callbacks are correlated only when a callback-specific product
  asserts replacement/invocation/teardown.

Constructor and destructor rows are covered only where a focused product
creates the concrete internal fixture and observes initial state, post-reset
state, resource balance, independent ownership, or teardown. The
`asCCompiler` constructor/destructor remain deferred because compilation success
alone does not expose compiler-object lifetime.

## Remaining real gaps

### Compiler: 6

- `asCCompiler::asCCompiler`
- `asCCompiler::~asCCompiler`
- `asCCompiler::Reset`

These require a focused compiler lifecycle owner that exposes compiler
construction/reset/teardown and asserts transient scope, bytecode, diagnostic,
and owned-state cleanup rather than inferring lifecycle from a successful
function compile.

- `asCCompiler::AreAllTemplateSubtypesCovariant`
- `asCCompiler::AreTemplateTypesWithFailedCovariance`
- `asCCompiler::ImplicitConvLambdaToFunc`

These require a supported template-covariance/lambda conversion entry path and
method-specific positive/rejection oracle. The existing selected-2.38 lambda
expectations do not by themselves prove these current-fork internal routines.

### Engine: 17

Function-table and declaration internals:

- `AddScriptFunction`
- `RemoveScriptFunction`
- `GetFunctionDeclaration`
- `GetMethodIdByDecl`
- `GetFactoryIdByDecl`
- `GetNextScriptFunctionId`
- `GetScriptSectionNameIndex`
- `DeprecateGlobalFunctionsByName`

These need a focused internal function-table owner covering identity allocation,
declaration formatting, lookup, removal/deprecation, section-name indexing, and
sibling-table preservation.

Engine preparation/build/JIT and replacement restrictions:

- `PrepareEngine`
- `RequestBuild`
- `SetJITCompiler`
- `RequireTypeReplacement`
- `SetTemplateRestrictions`
- `VerifyVarTypeNotInFunction`

These need exact owners for prepare idempotence, build-request state,
JIT install/replace/clear behavior, replacement eligibility, template
restriction enforcement, and invalid variable-type rejection. A general module
build or JIT invocation is not sufficient.

Missing cleanup-callback ownership:

- `SetFunctionUserDataCleanupCallback`
- `SetModuleUserDataCleanupCallback`
- `SetScriptObjectUserDataCleanupCallback`

These require callback-specific registration, replacement, invocation count,
payload/type identity, and engine/module/object teardown assertions. Engine and
type-info cleanup products do not substitute for these three receivers.

## Integrity

- CSV rows: 570
- unique `ImplementationUnit|Class|Method|Line` keys: 570
- missing `FinalCoverageIds`: 0
- missing rationales: 0
- non-final states: 0
- invalid catalog product IDs among public behavior rows: 0
- duplicate keys: 0

No authoritative audit CSV, task file, catalog, or source file was changed.
No build or runtime test was run for this semantic reconciliation pass.
