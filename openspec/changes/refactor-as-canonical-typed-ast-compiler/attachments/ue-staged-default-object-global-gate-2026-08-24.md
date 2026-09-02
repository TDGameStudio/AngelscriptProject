# UE staged default object-global gate — 2026-08-24

## Scope and result

This card closes the concrete object-global lifecycle defect exposed by the
real Primary UE class fixture. A preprocessor-generated
`const TSubclassOf<UObject> __StaticType_<Class>;` is a non-primitive VALUE
global. The canonical pipeline previously allocated its property shell but did
not publish default construction, so ClassGenerator dereferenced a null value
address in `FAngelscriptClassGenerator::SetScriptStaticClass()`.

The fix is AST-first and does not add a ClassGenerator null guard. Sema seals
the lifecycle decision, prepared CodeGen publishes it atomically to the exact
Runtime property shell, module reset constructs/destructs the object, and
member lowering addresses the object rather than the pointer-storage slot.
Cache V2 remains default-disabled and is outside this gate.

## AST-first lifecycle card

- Test source:
  `AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`.
- Focused method: `UninitializedGlobalValueSealsDefaultConstructionPolicy`.
- Fixture: registered native VALUE type `FSemaPod` and source
  `const FSemaPod _DefaultGlobalValue;`.
- Required sealed facts: the global has its exact canonical VALUE type, owns no
  manufactured initializer expression, and carries
  `asAST_TRAIT_DEFAULT_INITIALIZED`. The Runtime bridge independently classifies
  the type as `IsNonPrimitiveValueType()` only as a consistency check.
- RED build/report:
  `Saved/Build/cta-default-object-global-sema-red/20260824_221854_740_f3ab4a8a`
  and
  `Saved/Tests/cta-default-object-global-sema-red/20260824_222201_423_9c37b3e1`.
  The test failed because the sealed declaration lacked the lifecycle trait.
- GREEN build/report:
  `Saved/Build/cta-default-object-global-sema-green/20260824_222313_199_78b9d496`
  and
  `Saved/Tests/cta-default-object-global-sema-green/20260824_222325_988_9b7b779c`
  (`1/1 PASS`).

`asCSema` now records default initialization on an uninitialized global or
namespace declaration only when the sealed canonical type maps to a
non-primitive VALUE runtime family. Backends consume the trait; they do not
reselect the lifecycle policy.

## Prepared CodeGen publication and execution card

- Test source:
  `AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`.
- Focused method:
  `PreparedObjectGlobalConsumesSealedDefaultConstructionPolicy`.
- Fixture: `const FProdDefaultGlobalValue _PreparedObjectGlobal;`, a registered
  constructor/destructor pair, a scalar `Stored` field initialized to `42`, and
  `PreparedObjectGlobalEntry()` reading that field.
- Required publication facts: Stage 2 leaves `isDefaultInit` false; successful
  prepared CodeGen sets it on the exact original property shell; no synthetic
  init function is created; failure before commit cannot expose the candidate;
  no legacy compiler is invoked.
- First RED report:
  `Saved/Tests/cta-default-object-global-codegen-red/20260824_222618_981_1ec1c014`.
  CodeGen had not published the sealed default-initialization policy.
- Intermediate build/report:
  `Saved/Build/cta-default-object-global-codegen-green/20260824_222723_875_ce0209ff`
  and
  `Saved/Tests/cta-default-object-global-codegen-green/20260824_222739_575_61489b5c`.
  Construction advanced from zero to one, proving lifecycle publication, but
  member readback still failed.
- Member-address GREEN build/report:
  `Saved/Build/cta-default-object-global-member-green/20260824_223308_193_fd0fc3aa`
  and
  `Saved/Tests/cta-default-object-global-member-green/20260824_223328_344_60ccb9f3`
  (`1/1 PASS`).

The second failure was a distinct CodeGen lvalue bug. Global non-primitive
VALUE storage contains an object pointer. `PGA` pushes the storage-slot address
and `RDSPtr` obtains the object address. The canonical member path had instead
loaded the pointer into a local and used `PSF`, so field offset zero addressed
the local pointer bytes. Direct global VALUE member read/write now uses
`PGA + RDSPtr`; local VALUE, object handle, funcdef, and reference-object paths
retain their existing lowering.

The focused GREEN proves first reset constructs once, member execution returns
`42`, second reset destructs and reconstructs exactly once, publisher provenance
is canonical, and the legacy invocation count remains zero.

## Real Primary UE gate

- Test source:
  `StaticJIT/AngelscriptPrimaryEngineCanonicalASTGenerateTests.cpp`.
- Method:
  `PrimaryInitialCompileExecutesPreparedConstructorsAndFactories`.
- Historical RED report:
  `Saved/Tests/cta-primary-prepared-factory-gate/20260824_220920_447_a94a9d9e`.
  It crashed while ClassGenerator read the unconstructed generated static-class
  global.
- Focused GREEN report:
  `Saved/Tests/cta-primary-constructors-factories-after-object-global/20260824_223422_921_5916b8b6`
  (`1/1 PASS`).
- Full Primary group:
  `Saved/Tests/cta-primary-canonical-regression-after-object-global/20260824_223641_267_79b565a0`
  (`12/12 PASS`).

The real CANONICAL Primary engine now completes script compilation Stage 1–4,
ClassGenerator analysis/reload/propagation, module swap-in and cleanup, and the
prepared constructor/factory behavior without a sibling or LEGACY fallback.

## Regression matrix

- Runtime build:
  `Saved/Build/cta-default-object-global-member-green/20260824_223308_193_fd0fc3aa`
  (`Succeeded`).
- Full SemaAuthority:
  `Saved/Tests/cta-default-object-global-sema-regression/20260824_223600_912_b1b502e9`
  (`272/272 PASS`).
- Full ProductionCodeGen:
  `Saved/Tests/cta-default-object-global-production-codegen-regression/20260824_223524_534_ab0e81d3`
  (`80/80 PASS`).
- Full Primary canonical generation:
  `Saved/Tests/cta-primary-canonical-regression-after-object-global/20260824_223641_267_79b565a0`
  (`12/12 PASS`).

All listed runs have zero failures and zero skips.

## Remaining boundary

This card removes the concrete `__StaticType_` Primary crash and closes default
object-global construction/member addressing for the exercised shape. It does
not complete the entire OpenSpec. Task 9.5 still includes imports,
lambdas/closures, delegates/funcdefs, generated accessors/list factories, and
the remaining object/temporary lifetime matrix. Tasks 10.1–10.7 and 13.1/13.6
still require every production build purpose to select canonical Parser/Sema/
CodeGen, downstream Hot Reload/StaticJIT validation, removal of production HIR,
and isolation of LEGACY as the reversible comparison path.

Qualitative overall progress after this gate is approximately 78%. The number
reflects semantic and production-risk weight, not the raw checked-box ratio.
