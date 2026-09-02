# Canonical function declaration identity gate — 2026-08-23

## Scope

This is the AST-first gate card that closes OpenSpec task `13.3` and supplies
bounded evidence toward `4.5`, `7.2`, `7.4`, and `13.9`. It does not close
those downstream tasks: the default compiler is still LEGACY and the complete
Sema/CodeGen/JIT/Cache surface remains open.

The fixed defect boundary is production-relevant: a function emitted by
canonical CodeGen already had an exact sealed `asCDecl`, but the immutable
StaticJIT generation snapshot threw that association away and reconstructed an
AST key from `asCScriptFunction` metadata. Lambda binding was weaker still: it
ranked Runtime `$...$N` functions against AST source offsets. That was a second
identity derivation at a backend boundary.

## Gate card: producer-carried stable declaration identity

- **OpenSpec task(s):** `13.3` primarily; downstream `7.2`, `7.4`, `13.9`.
- **Source fixture:** a retained CANONICAL source module containing the
  overloads `F(int)` and source-spelled `F(float)`, plus the existing fixture
  containing two same-signature lambdas at distinct source offsets.
- **Canonical fact:** every source function installed by
  `asCBytecodeCodeGen` carries the exact stable key of the sealed declaration
  from which it was emitted.  A Runtime-to-AST binder accepts that key only
  when it names exactly one function-like declaration and the current Runtime
  owner, namespace, return type, parameter types/directions, constness, and
  lambda shape agree.  A key copied from another overload is a signature
  mismatch, not a successful bind.  Multiple exact AST keys are ambiguous.
- **AST test:**
  `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptStaticJITCanonicalASTIdentityTests.cpp`.
  `CanonicalProducerCarriesStableDeclIdentity`,
  `ProducerCarriedIdentityRejectsCrossOverloadSignatureMismatch`, and
  `ProducerCarriedIdentityRejectsAmbiguousStableKey` compile real source
  through Parser → Sema → Seal → canonical CodeGen and call the maintained-fork
  binder also used by StaticJIT. The existing global/method/lifecycle/operator/
  mixin/namespace cases remain in the same 11-test group.
  `MultipleLambdasBindDistinctStableKeysNotZeroOrFirstName` additionally
  requires each Runtime lambda to carry its exact `<lambda>(...)@offset` key.
- **AST-red:** expected wished-for-API failure recorded by
  `Saved/Build/cta-canonical-function-identity-red/20260823_223740_131_e20c18dd/RunMetadata.json`.
  The test module fails specifically because `asCScriptFunction` has no
  `canonicalASTStableDeclKey`, `asCRuntimeTypeBridge` has no
  `BindFunctionDeclaration`, and the exact mismatch status does not exist.
  The fixture and existing harness compile far enough to reach those missing
  contracts; this is not a selector, syntax, or setup failure.
- **AST-green:** the focused identity group is **11/11** in
  `Saved/Tests/cta-canonical-function-identity-regression/20260823_231731_045_c5b385ee/RunMetadata.json`.
  Runtime keys equal the sealed declaration keys; cross-overload copies return
  `asRUNTIME_DECL_BIND_SIGNATURE_MISMATCH`; duplicate exact keys return
  `asRUNTIME_DECL_BIND_AMBIGUOUS`.
- **CodeGen/provenance:** the focused identity group must prove the function
  publisher is canonical and the snapshot records a non-zero exact Decl ID
  without Runtime-name reconstruction for producer-keyed functions.
- **Lifecycle:** Cache V2 ExactStartup validates the whole restored declaration
  graph into temporary function/key pairs and commits keys only after every
  exact bind succeeds. It therefore cannot partially mutate the staging module
  before activation. `Answer()` restores with the stable key owned by its
  independently materialized sealed AST. Standalone compiles the field and
  binder with no Unreal dependency.
- **Focused regression:** StaticJIT CanonicalASTIdentity, Cache
  ExactWarmStartup, Compiler CanonicalAST, Runtime build, and Standalone.
- **Remaining boundary:** this card does not remove the LEGACY compatibility
  reconstruction path, make CANONICAL the default, finish full declaration
  dependency identity, remove HIR, or close the complete TypedASTJIT/Cache
  migration.

## Root causes found by the AST-first gate

The implementation exposed three distinct gaps that name-only tests had not
made visible:

1. **UE staged compilation bypasses `asCModule::Build()`.**
   `FAngelscriptEngine::CompileModules` calls staged Builder operations. The
   current UE production route therefore still invokes the legacy compiler
   even when a canonical AST has been built. Setting the field only in direct
   canonical CodeGen left real Runtime functions unkeyed.
2. **The legacy compiler reparses lambda bodies.**
   A parse-node pointer is a valid ephemeral fast path for ordinary
   declarations but does not survive that reparse. Sema now retains an
   ephemeral `(logical section, token offset) → DeclId` fallback. It accepts
   exactly one match and fails closed on ambiguity. Neither pointer nor DeclId
   is stored on the Runtime function.
3. **Runtime and source spelling are not identical type identities.**
   Primitive pass-by-value parameters can acquire an irrelevant top-level
   `const` in the Runtime declaration, and source `float` can semantically be
   `double` under `asEP_FLOAT_IS_FLOAT64`. The binder accepts only the former
   narrowly scoped primitive value normalization and otherwise compares the
   canonical resolved type. Owner, namespace, reference/handle mode,
   direction, const method, return type, capture shape, and every other
   structural fact remain exact.

The lifecycle tests also found that constructor and destructor declarations
were sealed with an invalid return type while CodeGen silently treated them as
`void`. Sema now records canonical `void`, so the AST itself is complete before
any backend consumes it.

## Intended data flow

```text
Parser/Sema sealed asCDecl stableKey
          |
          | direct canonical CodeGen
          |
          | staged UE bridge: parse pointer OR exact section+offset
          |                   -> DeclId -> stableKey
          v
asCScriptFunction.canonicalASTStableDeclKey
          |
          | exact-key + structural validation
          +--------------------------+
          |                          |
          v                          v
StaticJIT immutable          Cache V2 validate-all
CanonicalFunctionDecl        then commit-all restore
          |
          +--> TypedASTJIT / diagnostics / dependency consumers

No name-first lookup, no overload guessing, no lambda rank matching on the
canonical producer path.
```

The Runtime key is address-free. The source node pointer and snapshot-local
DeclId are explicitly ephemeral and are never serialized. Cache V2 derives the
Runtime key again from its independently restored and verified sealed AST.

## TDD and regression evidence

| Stage | Result | Evidence / diagnosis |
| --- | --- | --- |
| Wished-for API RED | build failure | `Saved/Build/cta-canonical-function-identity-red/20260823_223740_131_e20c18dd/RunMetadata.json`: missing Runtime key, binder API, and exact statuses |
| First Runtime RED | 8/11 | `Saved/Tests/cta-canonical-function-identity-green/20260823_224737_135_b7ba9be5/RunMetadata.json`: staged UE functions carried no key |
| Structural RED | 2/11 | `Saved/Tests/cta-canonical-function-identity-builder-map-green/20260823_225703_507_869a2d9c/RunMetadata.json`: exact binding exposed primitive value top-level const mismatch |
| Lifecycle RED | 9/11 then 10/11 | `cta-canonical-function-identity-ctor-diagnostic-red` exposed invalid lifecycle return type; the remaining failure exposed lambda reparse identity |
| Lambda source-coordinate GREEN | 1/1 | `Saved/Tests/cta-canonical-function-identity-source-coordinate-green/20260823_231253_991_88b50876/RunMetadata.json` |
| Cache V2 explicit RED | stable key empty | `Saved/Tests/cta-cache-v2-canonical-function-identity-red/20260823_231437_264_03273c53/RunMetadata.json` |
| Identity GREEN | **11/11** | `Saved/Tests/cta-canonical-function-identity-regression/20260823_231731_045_c5b385ee/RunMetadata.json` |
| Cache ExactWarm GREEN | **15/15** | `Saved/Tests/cta-cache-exact-warm-identity-regression/20260823_231858_108_f63b9ed6/RunMetadata.json` |
| CanonicalAST GREEN | **354/354** | `Saved/Tests/cta-canonical-ast-identity-regression/20260823_232335_291_dcdf4938/RunMetadata.json` |
| Compiler GREEN | **544/544** | `Saved/Tests/cta-compiler-stable-identity-regression/20260823_232449_543_c800eff5/RunMetadata.json` |
| Standalone GREEN | **21/21** | `Tools/RunTestSuite.ps1 -Suite Standalone`, 2026-08-23 |

The first short Standalone invocation was terminated by the outer command
window before CTest completed and is not counted as product evidence. The full
rerun above completed all 21 tests.

## Close decision

Task `13.3` is complete: complete owner-qualified stable signatures now cross
the canonical producer boundary; Runtime Function↔AST binding rejects missing,
ambiguous, and structurally mismatched candidates; and the requested global,
method, constructor/destructor, operator, mixin, namespace-overload, and
multiple-lambda cases are covered. LEGACY may retain its historical
name/signature/rank reconstruction for comparison and rollback, but the
canonical producer path does not use it.

## Follow-up gate card: retained LEGACY source must complete one declaration

- **OpenSpec task(s):** `7.2`, `7.4`, `13.9`; regression protection for
  `13.3` without reopening its canonical-producer contract.
- **Source fixture:** a real preprocessed `UFUNCTION()` global compiled by the
  LEGACY bytecode publisher while `asAST_RETAIN_SNAPSHOT` builds the canonical
  semantic sidecar used by TypedASTJIT.
- **Canonical fact:** the Parser action immediately after a function name may
  create one provisional declaration, but the completed parameter list and
  body must finish that same `DeclId`. The sealed AST must not contain a second
  function-like declaration with the same parent, source coordinate, and
  stable key. The surviving declaration owns the body and exact Runtime key.
- **AST test:**
  `FAngelscriptStaticJITCanonicalASTIdentityTests::LegacyRetainedUFunctionCompletesOneCanonicalDecl`.
  It compiles source through the actual Engine preprocessor and staged LEGACY
  builder, then requires one exact `TypedASTCapabilityShowcase(int,int,bool,bool)`
  declaration, a valid body, and a non-zero frozen snapshot DeclId.
- **AST-red:** the real TestJIT Generate probe currently reports two exact
  declarations at file 1 / begin offset 851: `DeclId 32` has no body and
  `DeclId 47` owns body 58. The exact-key binder rejects the ambiguity and the
  TypedAST backend fails closed at DeclId 0. Evidence:
  `Saved/StaticJIT/TestJIT/Commandlet/cta_hir_removal_provider_regen_v5_coordinate_diag_02_generate/20260824_023558_972_4efe0d92/Commandlet.log`.
- **Forbidden fix:** do not make StaticJIT choose the declaration with a body,
  choose the first match, or otherwise weaken exact/unique identity. Repair
  Parser/Sema provisional-declaration completion so the sealed AST is unique.
- **Required green:** focused AST test, complete CanonicalASTIdentity group,
  Compiler CanonicalAST group, and a fresh TestJIT Generate run that advances
  past the capability identity gate.
