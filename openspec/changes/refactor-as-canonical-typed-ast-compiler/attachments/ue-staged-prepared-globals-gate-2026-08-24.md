# UE staged prepared globals gate — 2026-08-24

## Scope

This gate advances the real `FAngelscriptEngine` staged CANONICAL publisher
from prepared ordinary function shells to an already-registered scalar global.
It does not claim dynamic initializer, object lifetime, enum, import, factory,
or lambda coverage.

The production invariant is whole-module and fail-closed: Stage 2 may allocate
and register the authoritative `asCGlobalProperty`, but it must not invoke
`asCCompiler`. Stage 3 must bind that exact property to its sealed declaration,
publish a property-owned Canonical initializer, and preserve the property
pointer used by UE descriptors and Hot Reload maps.

## AST-first card

- Owning task: `10.1`, `10.4`, `13.1` staged primary source cutover.
- Test source: `AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`.
- Focused method: `PreparedScalarGlobalKeepsPropertyIdentityAndCanonicalInitializer`.
- Fixture: `int _PreparedGlobal = 41; int PreparedGlobalEntry() { return _PreparedGlobal + 1; }`.
- Sealed facts: one namespace/translation-unit `Var` named
  `_PreparedGlobal`, non-empty stable key, Sema-owned constant value `41`, and
  the entry body's resolved declaration edge to that global.
- Existing semantic evidence nominated: SemaAuthority
  `CompileSealGlobalConstAndMutableInitializersOwnConstantFacts` (mutable
  writable global retains the constant initializer) and
  `CompileSealFloatGlobalConstantsFreezeResolvedStorageWidths` (resolved
  storage width and constant bits). The new prepared gate retains a direct
  assertion because runtime-property identity is the crossed boundary.
- AST-red: the sealed facts already exist; the focused test is expected to
  fail at the missing `BuildLayoutFunctionsWithoutGlobalInitializers()` staged boundary before any
  production change.
- CodeGen/provenance-green: `PreparedScalarGlobalKeepsPropertyIdentityAndCanonicalInitializer`
  is GREEN in report `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.FCanonicalASTProductionCodeGenTests.PreparedScalarGlobalKeepsPropertyIdentityAndCanonicalInitializer/20260824_212140_937_c8b9d25a`.
  It proves exact `asCGlobalProperty*`,
  property-owned initializer, `CANONICAL_CODEGEN`, and zero legacy compiler
  invocations.
- Lifecycle-green: the same report executes `ResetGlobalVars()` and observes
  `PreparedGlobalEntry() == 42`.
- Transaction rollback: `PreparedBuilderFailureRestoresEveryOriginalShell`
  now includes `_RollbackGlobal`, injects failure after one body, and requires
  the exact property, empty initializer, `isCompiled == false`, Engine
  function-slot length, and free-id stack to remain unchanged.
- Address-publication negative gate:
  `PreparedGlobalMissingAddressPublicationFailsClosedAndRollsBack` deliberately
  removes the exact `varAddressMap` entry after Stage 2. Stage 3 returns
  `asINVALID_CONFIGURATION` with the stable
  `prepared global address is not published` diagnostic, restores the exact
  empty function shell, and publishes neither initializer nor module
  publisher. Focused **1/1 PASS** at
  `Saved/Tests/cta-prepared-global-address-preflight-negative/20260824_213644_673_3f1eac19`.
- Focused regression: ProductionCodeGen **77/77 PASS** at
  `Saved/Tests/cta-production-codegen-prepared-global-full-green/20260824_213855_119_7588ad32`.

The real Primary fixture now also declares `_PrimaryCanonicalASTGlobal = 40`
and requires `PrimaryCanonicalASTEntry() == 42` after the normal Stage 4
lifecycle. This prevents the prepared helper from being the only global proof.

The first real-Engine run crashed in `asCScriptFunction::AddReferences()` when
an `LDG` operand missed `varAddressMap` and fell through to the host FString
factory. The diagnostic preflight converted that crash into the exact RED:
`property=... address=... mapped=null` at
`Saved/Tests/cta-primary-prepared-global-address-preflight/20260824_213310_926_24cf82fa`.
The root cause was orchestration, not AST or opcode width:
`FAngelscriptEngine` allocated script-global storage only when
`ModulesToUpdateReferences` was non-empty. Allocation/address publication now
runs for every freshly compiled module after class layout; only old-to-new
reference replacement remains conditional on Hot Reload. The real Primary
group is **11/11 PASS** at
`Saved/Tests/cta-primary-prepared-global-full-green/20260824_213722_133_ee9d6c52`.

## Non-claims

This first card accepts only Sema-proven scalar constants with a supported
1/2/4/8-byte storage width. Unsupported initializers remain a module-level
CANONICAL error; there is no declaration-level fallback to `asCCompiler`.
