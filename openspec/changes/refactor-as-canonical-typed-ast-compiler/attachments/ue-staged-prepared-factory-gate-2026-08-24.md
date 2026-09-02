# UE staged prepared constructor/factory gate — 2026-08-24

## Scope

This gate advances the CANONICAL prepared-module backend across class
constructors, generated default construction, factories, field initialization,
and transactional rollback. Cache V2 is outside this gate and remains
default-disabled. The first host-level fixture exposed the next missing
boundary, the lifecycle of the preprocessor-generated static-class global. That
follow-up is now green and is recorded in
`ue-staged-default-object-global-gate-2026-08-24.md`.

## AST-first generated lifecycle card

- Test source:
  `AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`.
- Focused method:
  `AlwaysImplementDefaultConstructSealsAndBindsGeneratedZeroArgConstructor`.
- Fixture: a reference class with a field and an authored one-argument
  constructor under `asEP_ALWAYS_IMPL_DEFAULT_CONSTRUCT = 1`.
- Required sealed facts: the authored one-argument constructor and the
  policy-generated zero-argument constructor are distinct Decls; the generated
  constructor has origin `canonical-generated-default-constructor`, owns its
  field-initialization plan, and the existing Runtime constructor shell carries
  that exact stable declaration key.
- RED evidence:
  `Saved/Tests/cta-generated-lifecycle-sema-red/20260824_215704_785_a01e0783`.
  The Stage-2 generated Runtime zero-argument constructor existed, but Sema had
  not produced the corresponding canonical declaration.
- GREEN build:
  `Saved/Build/cta-generated-lifecycle-identity-green/20260824_215952_473_72b854df`.
- GREEN focused report:
  `Saved/Tests/cta-generated-lifecycle-identity-green/20260824_220007_874_d429bd7f`
  (`1/1 PASS`).
- Full SemaAuthority regression:
  `Saved/Tests/cta-generated-lifecycle-sema-authority-full/20260824_220612_805_a35a1395`
  (`271/271 PASS`).

Sema now creates the generated zero-argument constructor whenever the Engine
policy requires one, even if other constructor overloads are authored. Builder
sealing then binds generated constructor/destructor/init-default Runtime shells
by complete structural identity (invocation kind, owner, namespace, return and
parameter ABI, direction, and constness). Prepared factory shells carry the
matched constructor stable key before CodeGen consumes them; CodeGen does not
invent or repair semantic identity.

## Prepared CodeGen and transaction card

- Test source:
  `AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`.
- Success method:
  `PreparedReferenceClassKeepsFactoryIdentityAndExecutesCanonicalConstructor`.
- Runtime facts: the authored one-argument factory/constructor returns `42`;
  the generated default factory/constructor returns the sealed field default
  `0`; factory-to-constructor identity is producer-carried.
- GREEN success report:
  `Saved/Tests/cta-prepared-factory-generated-lifecycle-green/20260824_220339_242_fb004216`
  (`1/1 PASS`).
- Rollback method:
  `PreparedFactoryEmissionFailureRestoresEveryRuntimeShellAndBehaviour`.
- Rollback facts: deterministic failure before one factory emission restores
  every exact original function/factory body, preserves stable keys and the
  behavior-table entries, publishes no canonical module, and invokes no legacy
  compiler.
- GREEN rollback report:
  `Saved/Tests/cta-prepared-factory-rollback-gate/20260824_220536_238_c0830fb3`
  (`1/1 PASS`).
- Full ProductionCodeGen regression:
  `Saved/Tests/cta-prepared-factory-production-full/20260824_220700_937_5c6c119a`
  (`79/79 PASS`).

`asCBytecodeCodeGen::GeneratePreparedModule()` now emits generated constructor
and destructor bodies from sealed initialization/cleanup plans even when no
authored body exists. It still installs detached artifacts only after the whole
module succeeds.

## Real Primary host gate: historical RED

- Test source:
  `StaticJIT/AngelscriptPrimaryEngineCanonicalASTGenerateTests.cpp`.
- Method:
  `PrimaryInitialCompileExecutesPreparedConstructorsAndFactories`.
- Fixture: a real temporary UE-hosted source project with a reference class,
  authored one-argument construction, implicit default construction, field
  readback, and both factory call sites.
- GREEN build:
  `Saved/Build/cta-primary-prepared-factory-gate/20260824_220836_912_6a243213`.
- RED runtime report root:
  `Saved/Tests/cta-primary-prepared-factory-gate/20260824_220920_447_a94a9d9e`.
- Failure: access violation in
  `FAngelscriptClassGenerator::SetScriptStaticClass()` while dereferencing the
  value address of the preprocessor-generated `__StaticType_<Class>` global.

At this point in the investigation the isolated constructor/factory backend was
green, but the real Primary class path was not. The evidence identified an
object-global lifecycle gap: Stage 2 registered and allocated the static-class
global, while Stage 3 had not yet published default construction for that
generated value object before ClassGenerator used it. The defect was fixed at
the AST/Sema/CodeGen lifecycle boundary rather than hidden behind a null check;
the follow-up attachment records the RED-to-GREEN closure.

## Completion statement

This slice closes generated default-constructor identity, prepared factory
execution, and factory rollback in isolation. The follow-up object-global gate
also closes this fixture's real Primary blocker. OpenSpec Tasks 9.5, 10.1,
10.4, 13.1, and 13.6 remain open for the other lifetime forms, complete
production-purpose cutover, downstream Hot Reload/StaticJIT gates, and final
HIR removal.
