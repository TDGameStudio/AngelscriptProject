# Canonical Typed AST compiler implementation progress (2026-08-27)

## Scope

- Change: `refactor-as-canonical-typed-ast-compiler`
- Worktree: `D:\as-cta`
- Plugin submodule branch observed at start: `feature-as-typed-semantic-aot`
- This file records implementation evidence, baseline failures, root-cause notes, and follow-up gates. It does not replace `tasks.md`.

## Current reconciled status

The sections below are a chronological RED/GREEN implementation log. Their
intermediate “still red/next step” statements describe the named checkpoint,
not the current end-of-day state.

The latest authoritative current-state report is
`implementation-progress-snapshot-2026-08-28.md`, including CTA-S45. The
checkpoint below intentionally preserves the reconciled CTA-S34 state from
the start of this chronological log; later sections supersede its percentages
and focused test totals.

Checkpoint state after physical HIR retirement and CTA-S34:

- `tasks.md`: **87/125 complete, 38 open**;
- type identity Units A–D and Tasks `14.1`–`14.6`: closed;
- current boundary counts include Frontend Type/TypeSema, Parser declarations
  and ProductionCodeGen in the earlier combined **152/152** matrix; the latest
  focused boundaries are SemaAuthority **367/367**, ProductionCodeGen
  **114/114**, native ScriptNode shape **32/32** and Canonical Semantics
  **12/12**;
  retained broader counts include
  Language Conversions **17/17**, Expression Chain **1/1**,
  transaction **20/20**, Module
  Snapshot **10/10**, ASTBodySidecar **21/21**, Canonical SourceManager
  **12/12**, HotReload **12/12**,
  TypedASTJIT **71/71**, Cache default-disabled **7/7** and Standalone
  **21/21**;
- durable identity is
  `snapshot-local asASTTypeRef -> StableTypeKey -> TypeABIKey -> immutable
  generation binding -> current numeric TypeId projection`;
- compiler default remains LEGACY and Cache V2 remains default-disabled;
- local `TArray<int>` default construction is repaired through an
  instance-local template behaviour shell and has a permanent sealed-AST,
  Canonical CodeGen, StaticJIT-retention and VM-execution regression;
- custom access specifiers are now typed, ordered immutable declarations with
  exact record-local member edges, public snapshot and Sidecar V6 support;
- primitive functional-cast and object-construction target types now cross
  Parser→Sema as exact local QualTypes; Parser and expression Sema no longer
  re-decode those target `snDataType` nodes;
- Parser and public Sema no longer expose any generic whole-tree declaration
  callback, action counter, script fallback or recursive declaration replay
  walker; explicitly named property/default/body adapters remain;
- `as_compiler.h/.cpp` now contain zero HIR hooks and
  `asCTypedSemanticIRBuilder` is physically absent; the retained native
  compiler still provides explicit LEGACY Bytecode;
- TypedSemantic HIR model, compiler capture, ScriptFunction ownership,
  Engine configuration and HIR dump commandlets are physically absent. HIR-
  only Editor/SDK/Standalone tests are removed or reduced to still-valid
  native-language coverage; the remaining TypedASTJIT work is direct
  Canonical-AST eligibility/dependency/call/lifetime coverage, not HIR
  retention;
- literal, declaration-reference, conditional, assignment, flat binary/
  logical, pure prefix/postfix unary, explicit cast, construct, ordinary-call
  ordered member/index/postfix-call and initializer-list expressions now cross
  pointer-free typed actions. Complete migrated native-node cases are
  identity-only; production Parser/Sema has **zero** generic
  `ActOnParsedExpr` declarations, implementations or calls;
- the remaining work is full residual Sema action authority, complete detached
  Bytecode/lifetime/debug lowering, TypedASTJIT Canonical-AST closure, aggregate
  production-entry cutover, migration notes and section 12 final gates.

### Progress interpretation (2026-08-28 after CTA-S-34)

The best single engineering estimate is **68% complete**. This is a
conservative weighted estimate of the required architecture, not a ratio of
changed lines or passing test cases. The independent progress numbers are:

| Measure | Current | Meaning |
| --- | ---: | --- |
| OpenSpec checkbox completion | **87/125 = 69.6%** | Mechanical task-record progress; 38 tasks remain open. |
| Weighted engineering completion | **about 68%** | Foundation, Sema authority, CodeGen/AOT, lifecycle and final cutover weighted by remaining risk. |
| Default-CANONICAL cutover readiness | **about 40%** | Readiness to change the product default safely; deliberately much lower than feature implementation. |

Weighted subsystem estimate used for the 68% figure:

| Subsystem/gate | Estimate | Current interpretation |
| --- | ---: | --- |
| Canonical AST foundation, public snapshot, stable type identity | **95%** | Core graph, snapshot/sidecar and dynamic-TypeId relocation model are substantially present; final race/publication gates remain. |
| Action-only declaration/expression/statement/lifetime Sema | **75%** | Generic expression replay is gone; declaration adapters plus statement/body/default/local-initializer/lifetime routes remain. |
| Canonical Bytecode CodeGen and Runtime-shell integration | **70%** | Real CANONICAL module/primary paths publish and execute, with 114/114 production regressions; complete detached/debug/lifetime language closure is open. |
| TypedASTJIT / AST AOT consumption | **55%** | HIR is gone and Canonical-AST analysis/emission foundations exist; final generation, eligibility/fallback and external AOT verification remain. |
| Production default/cutover/final verification | **40%** | Explicit CANONICAL opt-in works, but the default remains intentionally LEGACY until residual authority and full gates close. |
| Documentation, migration record and evidence | **78%** | Large evidence set is recorded and strict OpenSpec validation passes; final migration/release/archive material remains. |

Do not report 69.6% as “ready to ship”: the open umbrella items in sections 4,
5, 7, 9, 10 and 13 contain the highest semantic and lifecycle risk. Conversely,
the 28.6%/20% checkbox ratios for sections 4/5 understate their internal
implementation because long umbrella tasks remain unchecked while individual
typed-action slices advance beneath them.

The exact final type matrix, repairs, scans and non-claims are recorded in
`attachments/type-identity-boundary-gate-2026-08-27.md`. The executable order
for the remaining 38 tasks is
`attachments/final-completion-execution-plan-2026-08-27.md`.

## Dirty-worktree boundary

The parent worktree and `Plugins/Angelscript` submodule already contained a large uncommitted implementation set before this continuation. No cleanup, reset, checkout, broad staging, or unrelated rewrite was performed. New edits are limited to the current OpenSpec and explicit Canonical AST implementation/test files.

## Baseline verification before Unit A

Command:

```powershell
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" `
  -Label canonical-type-identity-baseline `
  -TimeoutMs 600000
```

Result: **132 total, 121 passed, 11 failed, 0 skipped**. Report:

`Saved/Tests/canonical-type-identity-baseline/20260827_003855_227_bfb4ab2f/Report/index.json`

The failing tests existed before the new TypeIdentity test and remained after UBT reported the target up to date:

1. `CodeGenEmitsCallInReverseFormalOrder`
2. `CodeGenEmitsIfAndComparison`
3. `CodeGenEmitsIntegerLiteralReturn`
4. `CodeGenEmitsLocalAssignmentAndUnaryMinus`
5. `CodeGenEmitsParameterReadsAndScalarOps`
6. `CodeGenEmitsWhileLoop`
7. `CodeGenLoadByteCodeRejectsUnsupportedVersion`
8. `CodeGenSaveLoadByteCodeRoundTripHasNoAstBytes`
9. `CodeGenRetryAfterPublicationRejectionSeesNoLeftoverIds`
10. `CodeGenSuccessDoesNotExtraRefPublishedFunction`
11. `RejectsSealedPublicationCallWithoutResolvedDecl`

Representative diagnostics are `source should lower`, `while loop should lower`, and `sealed CALL with a resolving target must publish`. These are real pre-existing cutover blockers, not evidence for or against Unit A. They remain assigned to the Canonical CodeGen/verifier closure and the broad 14.6/12.2 gates.

Build synchronization command:

```powershell
Tools\RunBuild.ps1 `
  -Label canonical-ast-baseline-sync `
  -TimeoutMs 1800000 `
  -NoXGE
```

Result: exit 0, target up to date. This rejected the stale-binary hypothesis; the 11 failures are reproducible in the current source/binary baseline.

## Unit A — AST stable type identity

### RED

Added `AngelscriptNativeCanonicalASTTypeIdentityTests.cpp` with `ContextRejectsForeignOwnerWithSameTypeIndex` before editing production code.

Command:

```powershell
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.TypeIdentity" `
  -Label canonical-type-identity-red `
  -TimeoutMs 600000
```

Result: **1 total, 0 passed, 1 failed**. The assertion failed because `asCASTContext::GetType` accepted a nonzero foreign `snapshotOwner` with a coincident local numeric index. Report:

`Saved/Tests/canonical-type-identity-red/20260827_004221_241_385c9493/Report/index.json`

### GREEN and matrix

Production change: internal `asCASTContext::GetType` accepts only owner-zero internal refs. Public snapshots continue to validate their issued owner and deliberately strip it before internal lookup.

Added acceptance coverage for:

- public snapshot A/B equal numeric type indices with distinct owners;
- foreign snapshot rejection;
- same complete type+qualifiers interning once;
- enum/value/reference/funcdef kind separation despite identical spelling;
- complete owner/template-argument key separation;
- deliberate lookup-hash collision still requiring complete-key equality;
- two Engines producing different lazy numeric IDs for the same stable enum identity;
- durable stable keys remaining independent of those IDs.

Commands and results:

```powershell
Tools\RunBuild.ps1 `
  -Label canonical-type-identity-matrix-build `
  -TimeoutMs 1800000 `
  -NoXGE

Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Type" `
  -Label canonical-type-identity-matrix `
  -TimeoutMs 600000
```

- Build: exit 0.
- Type/TypeIdentity/TypeSema: **19 total, 19 passed, 0 failed, 0 skipped**.
- Report: `Saved/Tests/canonical-type-identity-matrix/20260827_004555_981_95d615aa/Report/index.json`.

## Unit B — Runtime compatibility and immutable binding table

### RED 1: stable spelling incorrectly accepted the wrong Runtime kind

Added `AngelscriptNativeCanonicalRuntimeTypeBindingTests.cpp` before editing the
Runtime bridge. `RejectsSameKeyWithWrongRuntimeKind` registered an enum named
`ETarget`, interned canonical `ETarget` as `VALUE_OBJECT`, and required the
bridge to reject it.

```powershell
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.RuntimeTypeBinding" `
  -Label canonical-runtime-type-binding-red `
  -TimeoutMs 600000
```

Result: **1 total, 0 passed, 1 failed**. The old bridge selected the first
same-key `asCTypeInfo` without checking canonical kind. Report:

`Saved/Tests/canonical-runtime-type-binding-red/20260827_005111_440_9aca1eda/Report/index.json`

### Implementation and acceptance matrix

Added maintained-fork `as_runtime_type_binding.h/.cpp`, listed the source in
`Standalone/CMakeLists.txt`, and routed `asCRuntimeTypeBridge::Resolve` plus
`ValidateContextTypes` through the same exact candidate resolver. The new
boundary provides:

- distinct stable result categories for invalid, missing, ambiguous,
  wrong-kind, wrong-profile, wrong-native-environment, ABI mismatch,
  missing-member and already-frozen cases;
- candidate transient-type shadowing with pointer de-duplication and ambiguity
  rejection inside the authoritative candidate set;
- complete `asSTypeABIKey` values containing stable type identity, target
  profile, native environment, kind/qualifiers, object flags, size/alignment,
  full layout/member signature and full behaviour/call signature;
- `layoutHash` as a non-authoritative accelerator/checksum only;
- pointer-free `asSTypeRelocation` records with use kind, function artifact
  index and bytecode operand offset;
- generation-local resolved `asCDataType`, `asCTypeInfo*`, property/function
  targets, property offset and current public type-ID projection;
- validate-all/commit-none `Build`: all slots are built in a private pending
  array, swapped into the table only after every relocation succeeds, and the
  table freezes on success;
- the retained `asCDataType` value anchors the resolved TypeInfo through the
  maintained fork's internal reference protocol. At this Unit B checkpoint,
  aggregate generation ownership and Hot Reload publication still remained
  Task 14.4; Unit D below records their later closure.

Focused acceptance covers exact success/freeze, late-failure atomicity,
missing, ambiguous, wrong-kind, wrong-profile, wrong-native-environment,
complete layout/ABI mismatch despite an unchanged hash, equality of complete
ABI values despite different cached hashes, and property/function targets.

Final focused command:

```powershell
Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.RuntimeTypeBinding" `
  -Label canonical-runtime-type-binding-final-focused `
  -TimeoutMs 600000
```

Result: **10 total, 10 passed, 0 failed, 0 skipped**. Report:

`Saved/Tests/canonical-runtime-type-binding-final-focused/20260827_010535_347_bb86d11f/Report/index.json`

A second TDD cycle explicitly proved that hash values are not equality
authority. RED was **9/10 passed** with only
`NonAuthoritativeHashCannotSplitEqualCompleteABIKeys` failing; after removing
hash equality from `asSTypeABIKey::Equals`, the final focused run above was
green. RED report:

`Saved/Tests/canonical-runtime-type-binding-hash-red/20260827_010444_299_eccb828b/Report/index.json`

### Historical Standalone RED checkpoint — repaired later

Command:

```powershell
Tools\RunTestSuite.ps1 `
  -Suite Standalone `
  -LabelPrefix canonical-runtime-type-binding `
  -TimeoutMs 600000
```

The new maintained-fork source compiled and linked successfully outside the UE
unity/PCH build. CTest result was **21 total, 8 passed, 13 failed**. This is a
real gate failure, so Task 14.2 remains unchecked.

The failures are broad and predate/cross the binding-table surface:

- `asCScriptEngine` currently initializes `canonicalCompilerPipeline = true`,
  while `AngelscriptStandalone.CanonicalAST` still asserts a LEGACY default;
- multiple Standalone products then enter incomplete canonical Sema/CodeGen and
  fail on array `length`/`insertLast`, dictionary/member lookup, HIR publication,
  construct-decl verification and allocator cleanup consequences;
- historical evidence in this same change records Standalone **21/21** before
  the current default-cutover edits, including the 2026-08-23 gates;
- the failed run does not show a compile/link error in
  `as_runtime_type_binding.cpp`, and the focused Runtime binding matrix remains
  10/10.

At this checkpoint the failure was assigned to section 10 and the broad
14.6/12.2/12.3 gates rather than waived. The later supported-runner
reproduction isolated the premature product default, restored the truthful
LEGACY migration baseline, returned Standalone to **21/21**, and closed 14.2;
see `attachments/final-completion-issue-log-2026-08-27.md`.

## Unit C — Detached type/property/function relocation and late TypeId projection

The detached artifact now carries `asSTypeRelocation` values and a frozen
`asCRuntimeTypeBindingTable`. Durable relocation identity contains complete
stable type/member/function ABI identity, relocation use, owning function and
operand location; it does not contain an Engine pointer, numeric type ID or
snapshot-local TypeRef. The implementation resolves the complete table before
`Commit()`, prepares candidate-local numeric public-ID projections without
mutating `typeIdSeqNbr`/`mapTypeIdToTypeInfo`, patches only detached bytecode,
and publishes the pending projections only inside the commit transaction.

The implementation work in this continuation also closed the following real
relocation defects found by the broad ProductionCodeGen group:

- source-sealed POD by-value formals no longer inherit a Runtime-normalized
  `const T&inout` signature;
- enum Runtime candidate discovery includes `enumTypes` and `typeDefs`, and an
  existing enum shell is assigned canonical `asAST_TYPE_ENUM` when required;
- function relocation uses a candidate-local exact ordinal to disambiguate
  same-arity/same-signature batch functions instead of re-searching only by
  name;
- late public TypeId projection is transactional and can include prepared
  non-owning types without eager Engine mutation;
- anonymous list-pattern helpers use explicit
  `asTYPE_RELOC_LIST_PATTERN_TARGET`, whose durable identity is the owning
  object ABI plus exact list-factory function. No synthetic public TypeId or
  helper pointer/name is used as canonical identity;
- `Abandon()` removes only list-pattern helpers created by the failed
  candidate and restores the helper cache.

Focused and broad evidence:

| Gate | Result | Report |
| --- | ---: | --- |
| authored-source TypeId transaction | 17/17 PASS | `Saved/Tests/canonical-typeid-authored-source-fixture/20260827_013839_880_adb60885/Report/index.json` |
| base TypeId projection | PASS | `Saved/Tests/canonical-typeid-base-projection/20260827_014229_411_f0be1ffd/Report/index.json` |
| type/function relocation focused | 3/3 PASS | `Saved/Tests/canonical-function-relocation-transient-green/20260827_014800_823_931d0c33/Report/index.json` |
| array relocation | PASS | `Saved/Tests/canonical-function-relocation-array-green-2/20260827_015407_231_f0c3d2f9/Report/index.json` |
| automatic import function/global publication | 1/1 PASS | `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.FCanonicalASTProductionCodeGenTests.CanonicalAutomaticImportsPublishGlobalsAndResolveFunctions/20260827_015545_021_adbeb87b/Report/index.json` |
| null-handle lifecycle | 1/1 PASS | `Saved/Tests/canonical-null-handle-lifecycle-green/20260827_021231_297_eab82bdf/Report/index.json` |
| same-arity and type-only targets | 3/3 PASS | `Saved/Tests/canonical-declared-type-template-target-green/20260827_022545_906_cb003251/Report/index.json` |
| POD sealed formal | PASS | `Saved/Tests/canonical-pod-sealed-formal-green/20260827_023647_974_3bd37bb9/Report/index.json` |
| complete ProductionCodeGen | 111/111 PASS | `Saved/Tests/canonical-production-relocation-closure/20260827_024626_196_6dadaceb/Report/index.json` |
| anonymous list helper rollback | 1/1 PASS | `Saved/Tests/canonical-listpattern-rollback-green/20260827_025055_067_d32f3648/Report/index.json` |
| complete CodeGen transaction group | 19/19 PASS | `Saved/Tests/canonical-type-relocation-transaction-final/20260827_025133_270_4e1c7484/Report/index.json` |

The list-pattern source/header build first reached the command timeout after
64/166 actions without a compiler error; the continuation build completed the
remaining 102/102 actions successfully:

- timed run metadata:
  `Saved/Build/canonical-listpattern-explicit-relocation/20260827_024037_287_4b4a8891/RunMetadata.json`;
- successful rerun:
  `Saved/Build/canonical-listpattern-explicit-relocation-rerun/20260827_024349_915_1b002d8d/RunMetadata.json`;
- rollback-test build:
  `Saved/Build/canonical-listpattern-rollback-test/20260827_025036_568_d577bd04/RunMetadata.json`.

Task 14.3 is now closed by the explicit six-class failure matrix. The test-only
injection happens after the complete Runtime binding table has resolved and
frozen, but before any detached operand patch or `Commit()`. Each requested
class must actually be present in the candidate artifact, otherwise the test
cannot report an injected failure. The matrix compares Engine slots/free
lists, TypeId sequence/map, module inventories, anonymous list helpers,
publisher/digest, AST snapshot/current/generation key and the immutable Runtime
binding count/fingerprint.

The matrix also found a real success-path defect: canonical wildcard calls
passed the live value address but did not emit the hidden VM ABI `TYPEID`.
Canonical call lowering now emits a zero placeholder plus
`asTYPE_RELOC_PUBLIC_TYPE_ID`; installation late-projects the current
Engine/generation ID. The Production wildcard test asserts both the opcode and
that generic `GetArgTypeId(0)` equals `GetTypeIdByDecl("FPayload")`.

Final Task 14.3 evidence:

| Gate | Result | Report |
| --- | ---: | --- |
| six-class relocation transaction | 20/20 PASS | `Saved/Tests/canonical-relocation-matrix-full-transaction/20260827_043434_164_c9fad9ce/Report/index.json` |
| complete ProductionCodeGen | 111/111 PASS | `Saved/Tests/canonical-relocation-matrix-production-regression/20260827_043507_255_e1b56025/Report/index.json` |
| Module CanonicalAST Snapshot | 9/9 PASS | `Saved/Tests/canonical-relocation-matrix-module-snapshot-regression/20260827_043544_787_a2f5b695/Report/index.json` |
| HotReload CanonicalAST | 12/12 PASS | `Saved/Tests/canonical-relocation-matrix-hotreload-regression/20260827_043616_544_f5382824/Report/index.json` |

The RED injection build, the missing-public-TypeId RED, focused wildcard
execution evidence, full fixture/class mapping and the separately open
Parser/Sema speculative-node issues are recorded in
`reviews/canonical-type-relocation-failure-matrix-2026-08-27.md`.

## Unit D — Aggregate Runtime generation publication and retirement

Task 14.4 is implemented. The local CodeGen artifact now transfers its frozen
`runtimeTypeBindings` into an `asCRuntimeTypeGeneration` owned by the candidate
module. That generation also preallocates a retired-module carrier. On
replacement, the old executable/type/global/import inventories move wholesale
to the carrier instead of being destroyed while old readers may still exist.

The final lease model is:

```text
current asCModule -> generation owner reference
asCASTSnapshot    -> generation snapshot lease
external function reference / Context::Prepare
                  -> generation execution lease (external ref 0->1 / 1->0)
```

Functions do not internally own their generation, so the module's internal
function ownership cannot form `generation -> function -> generation`. Only an
external function reference acquires the execution lease.

Canonical candidate allocation, complete relocation resolution, binding-table
freeze and snapshot preparation occur before publication. Under the same
`astSnapshotLock` used by `AcquireASTSnapshot()`, successful Build retires A,
promotes B, exchanges `astSnapshot`, increments generation and changes the
current markers. This closes the concurrency window where an A snapshot could
still be advertised as current after A's Runtime generation had retired.

Two additional RED tests found real lifecycle defects:

- `PreparedExecutionKeepsRetiredGenerationAliveAfterSnapshotRelease` failed
  because a context-held old function did not retain the generation after the
  last old snapshot was released. External function references now acquire and
  release a generation execution lease.
- `ConcurrentAcquireNeverSeesRetiredGenerationAdvertisedAsCurrent` failed
  because executable promotion and public snapshot exchange were separate.
  They now form one lock-protected current-generation publication.

Legacy Build, canonical empty rebuild and LoadByteCode replacement now share
`ResetExecutableGenerationForReplacement()` so they cannot silently bypass
retirement.

Final evidence after the atomic-publication change:

| Gate | Result | Report |
| --- | ---: | --- |
| Runtime generation lifecycle | 6/6 PASS | `Saved/Tests/canonical-runtime-type-generation-final/20260827_035434_179_56b4c087/Report/index.json` |
| HotReload CanonicalAST | 12/12 PASS | `Saved/Tests/canonical-hotreload-generation-final/20260827_035508_306_a5cdee87/Report/index.json` |
| Module CanonicalAST Snapshot | 9/9 PASS | `Saved/Tests/canonical-module-snapshot-generation-final/20260827_035546_484_f87c6f65/Report/index.json` |
| ProductionCodeGen | 111/111 PASS | `Saved/Tests/canonical-production-generation-final/20260827_035737_704_25f5d064/Report/index.json` |
| CodeGen.Transaction | 19/19 PASS | `Saved/Tests/canonical-type-relocation-transaction-generation-final/20260827_035811_787_99281096/Report/index.json` |

RED/GREEN paths, ownership diagram, TypeId projection rules, discard/JIT/global
boundaries and the issue matrix are recorded in
`reviews/canonical-runtime-type-generation-lifecycle-2026-08-27.md`.

## Current next step

Tasks 14.1–14.6 are closed. The next implementation package is not another
TypeId redesign: it is the still-open Canonical compiler authority work in
Batches 2–4 of `attachments/final-completion-execution-plan-2026-08-27.md`.
The AST-first `TArray<int>` construction gap is now closed as one bounded
container/lifetime slice. Continue with the declaration/type/scope/call/control
matrix, starting from the unresolved Sema authority ledger rather than another
TypeId or array-alias change. Do not switch the product default until the
complete purpose matrix and Gate 0 umbrella are green. Section 12 focused,
Standalone Release and All gates remain separate final evidence.

### 2026-08-27 Canonical exact-scope progress

The bounded explicit-scope call and `DeclRef` family is now closed. Missing
qualifiers no longer fall back to global names, valid scopes with missing
members no longer climb to their parents, unresolved calls advertise no
dispatch, later-declared qualified names retain their exact qualifier, and
qualifier segments cannot bind unrelated same-name callables/constructors.
Invalid production replacements fail closed and preserve the prior published
generation.

The repair was verified by the complete SemaAuthority **306/306 PASS** and
ProductionCodeGen **113/113 PASS** groups. Detailed RED/GREEN evidence is in
`attachments/canonical-explicit-scope-resolution-gate-2026-08-27.md` and
`attachments/canonical-explicit-scope-declref-gate-2026-08-27.md`.

This advances, but does not complete, Tasks `4.3`, `5.3`, or `13.2`. The next
authority risk is deferred-name reconciliation: repairing a child call or
`DeclRef` after a later declaration must also recompute the already-built
parent expression's type and semantic/lifetime plan. It is tracked as
CTA-S-06 in the final completion issue ledger.

### 2026-08-27 deferred parent-expression progress

CTA-S-06 found a real semantic closure defect: later-qualified call/global
children became `double`, while their already-built `+` parent and return
conversion retained recovery-time `int` facts. Canonical Sema now performs an
AST-only fixed-point recomputation for built-in primitive binary parents,
including explicit operand promotion and disconnection of newly redundant
conversion ownership edges. The deferred API was renamed from
`ResolveDeferredCalls` to `ResolveDeferredNames` because it now owns both call
and `DeclRef` reconciliation.

The strengthened source fixtures execute `double deferred-name + int literal`
through Canonical CodeGen as `42.0`. Complete SemaAuthority is **308/308 PASS**
and ProductionCodeGen is **114/114 PASS**. RED/GREEN and the retained
compile-order build failure are recorded in
`attachments/canonical-deferred-expression-reconciliation-gate-2026-08-27.md`.

This is one primitive-expression family, not the action-only Sema or complete
expression/lifetime umbrella. Object operators, assignment, conditional,
cast, member access and lifetime-plan reconciliation remain explicit open
work.

### 2026-08-27 namespace typed-action progress

CTA-S-07 migrated namespace-path creation off generic `asCScriptNode` replay.
`ParseNamespace()` now passes short-lived typed segments with exact byte ranges
to `ActOnNamespacePath`; Sema remaps them through SourceManager and `WalkOne`
contains no `snNamespace` case. The first repair uncovered a hidden dependency:
namespace child functions/classes had relied on recursive namespace replay to
attach completed bodies and traits. The required ProductionCodeGen gate caught
this as **109/114**, and an AST-first strengthened fixture reproduced the exact
missing `Game::F(int)` body as **0/1**.

The scoped correction retains namespace action-only construction and restores
only the per-child completion transition. Final SemaAuthority is **309/309**
and ProductionCodeGen is **114/114**. Full RED/root-cause/GREEN evidence,
including one invalid zero-match runner attempt, is recorded in
`attachments/canonical-namespace-typed-action-gate-2026-08-27.md` and the final
issue log.

This is not Task 4.2 or 13.2 completion. Non-namespace declaration families
still pass completed Parser nodes until their own typed finish actions land;
expression/statement walkers also remain. Compiler and Cache V2 defaults stay
unchanged.

### 2026-08-27 enum/enumerator typed-action progress

CTA-S-08 migrates enum and enumerator declaration identity away from generic
Parser-node replay. `ParseEnumeration()` now publishes validated typed
name/range payloads, pushes the exact enum context before recognizing members,
and `WalkOne` contains no `snEnum` case. The generic completed-declaration
callback also excludes enum, preventing duplicate semantic replay.

The permanent architecture test produced a valid **0/1 RED** before the
production edit. Final Runtime/Editor build, focused architecture **1/1**,
SemaAuthority **310/310**, ProductionCodeGen **114/114**, strict OpenSpec
validation and both diff checks pass. Exact paths and the source contract are
recorded in
`attachments/canonical-enum-typed-action-gate-2026-08-27.md` and the final
issue log.

This advances Tasks `4.2` and `13.2` but does not close them. Enumerator
initializer parsing remains an explicitly named expression-node adapter, and
class/interface/mixin/function/variable/import/type/expression/statement
families still have Parser-node semantic boundaries. Compiler default remains
LEGACY and Cache V2 remains default-disabled.

### 2026-08-27 primitive typedef typed-action progress

CTA-S-09 migrates the maintained fork's bounded primitive typedef grammar away
from `snTypedef` semantic replay. `ParseTypedef()` now publishes the recognized
alias name, its exact SourceManager range, and the Parser-resolved non-void
primitive token through `ActOnTypedefAction`. This preserves configured float
width semantics without asking Sema to decode a Parser type node. `WalkOne`
contains no `snTypedef` case and the generic completed-declaration callback
excludes typedef.

The focused architecture test produced a valid **0/1 RED** before production
changes. The behavior gate proves an alias is published before a missing
semicolon and a complete parse has exactly one `Typedef Count` with
`type=int`. One intermediate **0/2** run was an invalid test assertion: it
assumed dump fields were adjacent even though the product dump already
contained the correct facts. The line-scoped assertion was fixed without a
production change.

Final Runtime/Editor build, focused architecture **1/1**, behavior **2/2**,
SemaAuthority **311/311**, ProductionCodeGen **114/114**, strict OpenSpec
validation and both diff checks pass. Exact RED/GREEN/invalid-run paths are in
`attachments/canonical-typedef-typed-action-gate-2026-08-27.md` and the final
issue log.

This advances Tasks `4.2`, `4.3`, and `13.2` but does not close them. The
action covers only the existing primitive typedef grammar; general type
payloads and class/interface/mixin/function/variable/import/expression/
statement families remain transitional. Compiler default remains LEGACY and
Cache V2 remains default-disabled.

### 2026-08-27 import typed signature/origin progress

CTA-S-10 removes whole `snImport` semantic replay. Parser now publishes a
typed import signature before parsing parameters, keeps the exact import
DeclContext active while parameters attach incrementally, and publishes a
typed module origin after the quoted string but before the semicolon.
`ParseImport()` no longer calls `NotifySema(node)`, `WalkOne` has no
`snImport` case, and the generic completed callback excludes import.

The permanent architecture assertion produced a valid **0/1 RED** before the
production edit. A strengthened behavior run then produced an invalid **2/3**
result because the test expected source spelling `float`; the configured
canonical type was correctly `double`, so only the assertion changed.

The mandatory ProductionCodeGen gate exposed a separate real defect at
**113/114**: prepared Runtime import shells lost the stable declaration key
previously carried as a side effect of whole-node notification. The final
repair explicitly binds the already-created DeclId to the legacy Parser shell
through `BindParsedDeclarationIdentity`. This bridge is identity-only,
per-generation transitional state; it does not decode semantic syntax and
must be removed with the remaining Builder/Parser map.

Final behavior is **3/3 PASS**, SemaAuthority is **313/313 PASS**, focused
prepared-import execution is **1/1 PASS**, and ProductionCodeGen is
**114/114 PASS**. Complete RED/GREEN paths, builds, root cause and non-claims
are recorded in
`attachments/canonical-import-typed-action-gate-2026-08-27.md` and the final
issue log.

This advances Tasks `4.2`, `4.3`, `4.4`, and `13.2` without closing them.
Import return type and parameter payloads still use explicitly inventoried
general node adapters; class/interface/mixin/function/variable/expression/
statement families remain. Compiler default stays LEGACY and Cache V2 stays
default-disabled.

### 2026-08-27 ordinary function-family typed-action progress

CTA-S-11 removes ordinary function-family whole-node semantic replay for
global functions, class methods, constructors/destructors, mixins, local
functions and interface methods. Parser now publishes a typed signature as
soon as the function name is known, parses parameters under the exact function
DeclContext, publishes a typed access/mixin/const/final/override/external trait
mask before `;` or body parsing, and attaches only a successfully completed
body through an explicitly named statement adapter.

The permanent early-recovery and architecture tests produced a valid
**313/315, 2 FAIL** full-discovery RED before production changes. Three earlier
focused attempts were invalid zero-match prefixes because they omitted the
CQTest class segment; they are recorded as runner mistakes rather than product
failures.

The first implementation was behaviorally green but retained the now-dead
static `ActOnFunctionLike` whole-node decoder. A strengthened architecture
test produced a second valid **0/1 RED**, after which the decoder was physically
deleted. Final architecture is **1/1 PASS**, SemaAuthority **315/315 PASS**,
ProductionCodeGen **114/114 PASS**, and Parser declarations **18/18 PASS**.
Exact builds, REDs, invalid commands, implementation contract and report paths
are recorded in
`attachments/canonical-function-typed-action-gate-2026-08-27.md` and the final
issue log.

This advances Tasks `4.2`, `4.3`, `4.4` and `13.2` without closing them.
Return types still use `ActOnQualTypeFromNode`, parameters/defaults still use
`ActOnParsedParam`, bodies still use a statement-node adapter, and lambda plus
class/interface body semantics remain separate. Compiler default stays LEGACY
and Cache V2 stays default-disabled.

## 2026-08-27 overall progress snapshot after CTA-S-11

**Primary engineering completion estimate: 66%.** This is the number to use
for overall status. It is intentionally lower than a naive reading of green
focused tests and close to, but not identical to, the mechanical task count.
The estimate has roughly ±3 percentage-points of judgment because many of the
39 unchecked tasks are overlapping acceptance umbrellas rather than
independent implementation units.

The mechanical OpenSpec count is **86/125 checked, 39 open, 68.8%**. CTA-S-11
does not change that count: it truthfully advances four open umbrellas
(`4.2`/`4.3`/`4.4`/`13.2`) but cannot close any one of them until their other
declaration/type/parameter/expression/statement surfaces are finished.

The 66% estimate uses this architecture-weighted model:

| Workstream | Weight | Current estimate | Weighted contribution |
|---|---:|---:|---:|
| Baselines, SourceManager, AST/context/seal/public view, Cache containment and canonical TypeId boundary | 25% | 96% | 24.0% |
| Canonical declaration/type/expression/statement/lifetime Sema authority | 25% | 58% | 14.5% |
| Detached Canonical Bytecode CodeGen, relocation and Runtime installation | 18% | 72% | 13.0% |
| TypedASTJIT canonical visitor migration and production HIR retirement | 10% | 50% | 5.0% |
| Generation/publication and real production entry-point matrix | 8% | 65% | 5.2% |
| Canonical default cutover and explicit LEGACY isolation | 9% | 12% | 1.1% |
| Documentation, final focused/Standalone/All verification and reconciliation | 5% | 60% | 3.0% |
| **Total** | **100%** |  | **65.8% → 66%** |

### Current implementation footprint

The plugin worktree currently touches **261 unique plugin files** when tracked
changes and untracked new files are combined:

- **118 Runtime files** (66 tracked modifications, 52 new files);
- **8 Editor files** (6 tracked, 2 new);
- **107 test files** (58 tracked, 49 new);
- **7 Standalone files** (4 tracked, 3 new);
- **1 root README** and **20 generated/other artifact files**.

Tracked plugin diff alone is **155 files, +15,959/-5,651 lines**. There are
another **106 untracked plugin files**, so the tracked diff statistic
understates the actual working implementation. These numbers describe
worktree footprint, not completion: generated StaticJIT artifacts and large
test fixtures make raw LOC unsuitable as a progress percentage. The parent
worktree separately carries the OpenSpec/review/research record and project
configuration/documentation changes.

### What is substantially implemented

1. SourceManager, canonical AST arena/context, node/type system, sealing,
   verifier, deterministic dump/public AST V1 and snapshot/lease primitives.
2. Stable canonical type identity plus complete ABI key, immutable
   generation-local Runtime binding table, relocation validation and late
   numeric TypeId projection. Dynamic Engine/generation-local TypeId is no
   longer treated as durable compiler/StaticJIT identity.
3. Detached Canonical CodeGen transaction scaffolding, validate-all/commit-none
   type/property/function relocations, rollback, current/retired generation
   ownership, Hot Reload publication and execution/snapshot leases.
4. A meaningful Canonical Sema subset: exact namespace/enum/typedef/import/
   ordinary-function actions; stable declaration identity; qualified lookup;
   overload/conversion/call facts for covered routes; primitive parent
   reconciliation; field layout/accessor facts; foreach/control/cleanup and
   covered object/container construction/lifetime routes.
5. Cache V2 pointer-free sidecar/restore prototypes are contained behind a
   default-disabled boundary; they are not being claimed as the final cache
   design.
6. TypedASTJIT/StaticJIT already consume substantial canonical identity,
   dependency, generation and execution facts, but production HIR compatibility
   has not yet been removed.

CTA-S-11's final state is Runtime/Editor build PASS, architecture **1/1**,
SemaAuthority **315/315**, ProductionCodeGen **114/114**, and Parser
declarations **18/18**. Source scans show zero obsolete ordinary-function
whole-node decoder; the remaining direct `asCScriptNode` inventory is
declaration **100**, expression **42**, statement **27**, core Sema **3**.

### Remaining critical path

1. Finish action-only Sema for class/interface/variable/property and general
   type/parameter/default/lambda forms, then remove expression/statement/
   lifetime semantic replay.
2. Complete detached CodeGen coverage for the remaining object/container/
   generated/exception/suspend/debug/coverage surfaces and close the aggregate
   publication audit.
3. Replace TypedASTJIT production HIR inputs with canonical visitors and delete
   production HIR builders/storage/accessors.
4. Prove every real entry point (primary Build, Hot Reload, CompileFunction,
   StaticJIT generation, commandlet and Standalone) is canonical, fail-closed
   and rollback-safe.
5. Only then switch the product default from LEGACY to CANONICAL, retire the
   old semantic authority, update final documentation, and run focused,
   Standalone Debug/Release and complete All gates.

Architecture assessment: the corrected direction is sound—stable identity,
immutable generations, detached artifacts and explicit Parser-to-Sema actions
are the right boundaries. The largest remaining risk is no longer dynamic
TypeId; it is the still-mixed semantic authority across typed actions,
`asCScriptNode` adapters and LEGACY `asCCompiler`. Therefore the remaining
34% is the hardest part of the change and should not be extrapolated linearly
from elapsed time or LOC.

## 2026-08-27 CTA-S-12 record typed-action progress

Class, struct and interface identity no longer depends on whole-record Sema
replay. Parser publishes a typed record header immediately after the name, an
ordered set of complete qualified-base spellings before entering the body and
a finish action only after a real closing brace. Sema now owns VALUE vs
REFERENCE_OBJECT kind, exact base resolution/dependencies, the no-authored-base
`PreClassData` rule and generated class lifecycle/accessors.

The permanent pre-edit gate was a valid **315/317 PASS, 2 FAIL**. One fixture
proved that `Right::Base` was not available as an exact edge before method-body
recovery failed; the other proved the old `snClass`/`snInterface` replay and
base decoder were still present. Final verification is focused behavior
**1/1**, focused architecture **1/1**, SemaAuthority **317/317**,
ProductionCodeGen **114/114**, and Parser declarations **18/18**. There were
no invalid runner attempts in this slice.
Strict OpenSpec validation and both parent/plugin `git diff --check HEAD`
also pass; only existing LF/CRLF conversion notices are emitted.

Source scans find no `ActOnParsedBaseSpecifiers`, `RecordClassBases`,
`case snClass:` or `case snInterface:`. Direct line-bearing
`asCScriptNode` sites are now declaration **94**, expression **42**, statement
**27**, and core Sema **3**. The remaining declaration sites are concentrated
in general type/parameter/default/field/funcdef/lambda/body adapters, not
record header/base/completion authority. Exact RED/GREEN/build paths and
non-claims are recorded in
`attachments/canonical-record-typed-action-gate-2026-08-27.md` and the final
issue log.

A static audit also corrected a stale header comment that called CANONICAL the
current default while executable initialization remains
`ep.canonicalCompilerPipeline = false`. This is a documentation correction;
the compiler default is still LEGACY and Cache V2 remains default-disabled.

## 2026-08-27 overall progress snapshot after CTA-S-12

**Primary engineering completion estimate: 67%.** This supersedes the 66%
CTA-S-11 snapshot. The mechanical task count remains **86/125 checked, 39
open, 68.8%**, because CTA-S-12 advances overlapping acceptance umbrellas but
does not truthfully complete any umbrella row.

The architecture-weighted update raises only the Sema-authority stream—from
58% to 62%—for the verified class/struct/interface header/base/finish closure:

| Workstream | Weight | Current estimate | Weighted contribution |
|---|---:|---:|---:|
| Baselines, SourceManager, AST/context/seal/public view, Cache containment and canonical TypeId boundary | 25% | 96% | 24.0% |
| Canonical declaration/type/expression/statement/lifetime Sema authority | 25% | 62% | 15.5% |
| Detached Canonical Bytecode CodeGen, relocation and Runtime installation | 18% | 72% | 13.0% |
| TypedASTJIT canonical visitor migration and production HIR retirement | 10% | 50% | 5.0% |
| Generation/publication and real production entry-point matrix | 8% | 65% | 5.2% |
| Canonical default cutover and explicit LEGACY isolation | 9% | 12% | 1.1% |
| Documentation, final focused/Standalone/All verification and reconciliation | 5% | 60% | 3.0% |
| **Total** | **100%** |  | **66.8% → 67%** |

The current plugin worktree footprint is **262 unique changed/new files**:
**156 tracked paths** and **106 untracked paths**. Relative to plugin `HEAD`,
the tracked portion is **+16,114/-5,653 lines**. By the prior component
classification this is 118 Runtime, 8 Editor, 107 test, 7 Standalone, 1 root
README and 21 generated/other paths. The extra path since CTA-S-11 is
repository metadata; the record slice itself modified existing Runtime/test
files. Footprint remains an implementation-volume measure, not a completion
score.

The critical path is unchanged in shape:

1. finish typed field/property/default/funcdef/general type/parameter/lambda
   actions, then remove expression/statement/lifetime Parser-node replay;
2. close detached CodeGen language/metadata/runtime installation coverage;
3. migrate TypedASTJIT fully to sealed Canonical AST visitors and remove
   production HIR storage/accessors;
4. close the real entry-point/generation matrix;
5. only then flip the default, isolate the retained explicit LEGACY authority,
   physically retire TypedSemantic HIR, and run final focused, Standalone
   Debug/Release and All verification.

The remaining **33%** is still the risk-heavy portion: semantic authority
retirement, backend completeness, production entry-point proof and delivery
gates. The 67% figure should therefore be used as the current overall status,
while 68.8% is reported only as the literal OpenSpec checkbox ratio.

## 2026-08-27 CTA-S-13 global/field variable typed-action progress

Top-level/namespace globals and class/struct fields no longer depend on one
completed `snDeclaration` replay. Parser resolves the authored type once,
publishes one typed header immediately for each comma-separated identifier,
and binds only that declarator's optional initializer to the returned DeclId.
Recognized private/protected access crosses the header payload. The generic
top-level callback excludes declarations, the class field branch has no
whole-node callback, and the residual declaration walker fails closed for
translation-unit, namespace, or class owners while remaining available for
local statement migration.

The permanent test-only build passed, then the valid pre-edit SemaAuthority
gate produced the intended **317/319 PASS, 2 FAIL**. During GREEN, two distinct
issues were recorded:

1. The first focused test incorrectly expected globals and fields to share one
   initializer representation. The dump proved globals were correctly folded
   into `hasConstantValue/constantValue` and fields correctly retained explicit
   InitPlans. The oracle was corrected without weakening production checks.
2. The first full ProductionCodeGen gate was a valid **113/114** regression:
   `40 + 1` had `constant=41` but stale `default=40`. The generic first-literal
   extractor was overwriting the normalized global default. Global/namespace
   normalized text is now owned only by `ActOnGlobalVarInit`; field source
   initializer handling remains explicit.

Final verification is focused semantic/architecture **2/2**, repaired
constant execution **1/1**, SemaAuthority **319/319**, ProductionCodeGen
**114/114**, and Parser declarations **18/18**. Strict OpenSpec validation and
both parent/plugin `git diff --check HEAD` pass; only existing LF/CRLF notices
are emitted. Corrected static scans show direct line-bearing `asCScriptNode`
sites of declaration **96**, expression **42**, statement **27**, and core
Sema **3**. The two-line declaration increase from CTA-S-12 is the explicitly
named initializer adapter surface, not restored whole-declaration replay.

Exact RED/GREEN/build paths, the invalid test-oracle classification, the
production normalized-default root cause/fix, the corrected static-scan path,
and non-claims are recorded in
`attachments/canonical-global-field-variable-typed-action-gate-2026-08-27.md`
and the final issue log.

## 2026-08-27 overall progress snapshot after CTA-S-13

**Primary engineering completion estimate: 68%.** This supersedes the 67%
CTA-S-12 snapshot. The literal OpenSpec checkbox ratio remains **86/125
checked, 39 open, 68.8%** because this slice advances five overlapping
umbrellas (`4.2`, `4.3`, `4.4`, `4.5`, `13.2`) without satisfying the complete
wording of any one umbrella.

The architecture-weighted estimate raises the Sema-authority stream from 62%
to 65%. No backend, TypedASTJIT, entry-point, or default-cutover stream is
credited merely because its regression suite remained green:

| Workstream | Weight | Current estimate | Weighted contribution |
|---|---:|---:|---:|
| Baselines, SourceManager, AST/context/seal/public view, Cache containment and canonical TypeId boundary | 25% | 96% | 24.0% |
| Canonical declaration/type/expression/statement/lifetime Sema authority | 25% | 65% | 16.3% |
| Detached Canonical Bytecode CodeGen, relocation and Runtime installation | 18% | 72% | 13.0% |
| TypedASTJIT canonical visitor migration and production HIR retirement | 10% | 50% | 5.0% |
| Generation/publication and real production entry-point matrix | 8% | 65% | 5.2% |
| Canonical default cutover and explicit LEGACY isolation | 9% | 12% | 1.1% |
| Documentation, final focused/Standalone/All verification and reconciliation | 5% | 60% | 3.0% |
| **Total** | **100%** |  | **67.5% -> 68%** |

### Current implementation volume

The plugin worktree contains **262 unique changed/new paths** relative to its
submodule `HEAD`: **156 tracked modified paths** plus **106 untracked new
paths**. The tracked diff is **+16,162/-5,655 lines**. The 106 complete new
C++/header files contain **84,431 lines**; combining tracked additions with
whole new-file content gives a raw added implementation/test surface of about
**100,593 lines**. This combined value is not a net diff and must not be used
as a completion score.

Component path totals are:

| Component | Changed/new paths |
|---|---:|
| Runtime/compiler/Cache/StaticJIT | 118 |
| Editor integration | 8 |
| Tests and test support | 107 |
| Standalone | 7 |
| Plugin README | 1 |
| Generated/build metadata and other | 21 |
| **Total** | **262** |

The OpenSpec change itself currently contains **278 files**, including **246
attachments** and **19 review records**. These counts describe the dirty
worktree footprint and accumulated evidence; nothing in this snapshot is a
commit, merge, archive, or final delivery claim.

### What the 68% already includes

- Clang-style SourceManager, Decl/Stmt/Expr/Type graph, ASTContext, verifier,
  Seal, immutable snapshots and public views;
- canonical stable function/type identity, generation-local Runtime type
  binding, six-class relocation validation and atomic publication slices;
- substantial canonical expression/control/lifetime facts and a real detached
  Bytecode CodeGen path with 114 production regressions green;
- typed namespace, enum, typedef, import, ordinary function, record, global
  and field declaration phases through CTA-S-07 through CTA-S-13;
- StaticJIT/TypedASTJIT canonical identity/dependency/generation foundations,
  Cache V2 default-off containment and Standalone foundations;
- extensive TDD gates, issue ledger, design reconciliation and review records.

### Remaining critical path (32%)

1. Finish action-only Sema for local declarations, property/access-group,
   class-default, funcdef, general type/parameter/default/lambda/body forms,
   then remove residual expression/statement/lifetime Parser-node replay.
2. Close detached CodeGen language, metadata, debug/coverage/exception,
   cleanup and Runtime installation coverage without semantic fallback.
3. Replace TypedASTJIT production HIR inputs with sealed Canonical AST visitors
   and delete production HIR builders/storage/accessors.
4. Prove every production entry point and aggregate generation/publication
   transaction, including CompileFunction, commandlet and Standalone.
5. Only after those gates, switch the default to CANONICAL, isolate the
   retained explicit LEGACY authority, physically retire TypedSemantic HIR,
   reconcile documentation, and run final focused,
   Standalone Debug/Release and complete All verification.

The 68% is therefore the current architecture-weighted engineering estimate;
68.8% is only the mechanical checkbox ratio. The remaining work is
concentrated in the highest-risk authority-retirement and delivery gates, so
neither number should be extrapolated linearly from LOC or elapsed time.

## 2026-08-27 CTA-S-14 local/loop variable typed-action progress

Ordinary locals, `for` initializer declarations and `foreach` variable
identity no longer depend on `snDeclaration` semantic replay. Parser publishes
one typed header immediately for each declarator, binds its bounded optional
initializer to the exact returned DeclId, and finishes one exact-range
statement sequence after `;`. Normal declarations flatten into the surrounding
block without changing lexical visibility; `for` retains the sequence as its
initializer carrier so condition/increment/body share the exact loop scope.
`foreach` publishes a DeclStmt without default construction because the
protocol supplies the element.

The permanent test-only build passed, then the valid pre-production run was
the intended **319/321 PASS, 2 FAIL**. The first implementation exposed a real
**248/321** regression with verifier detail `stmt-multi-owner`: normal block
flattening copied statement edges but left the same edges on the synthetic
sequence. Clearing the carrier after normal flattening repaired that without
changing the `for` carrier. The next full run was **320/321** and exposed a
second real recovery regression: malformed `{1,2` returned before the exact
initializer action retained the partial list-pattern expression. Publishing
that bounded action before returning the parse error restored the previous
recovery contract without restoring declaration replay.

The final semantic fixture also compiles and executes the valid
comma-declarator/loop shape through Canonical CodeGen and requires `Entry() ==
34`. Final evidence is focused semantic/architecture **2/2**, SemaAuthority
**321/321**, ProductionCodeGen **114/114**, and Parser declarations **18/18**.
Strict OpenSpec validation and separate parent/plugin `git diff --check` pass;
existing LF/CRLF conversion notices are the only output from the diff checks.
Exact RED/GREEN/build paths, both product root causes, invalid tool invocations
and non-claims are recorded in
`attachments/canonical-local-loop-variable-typed-action-gate-2026-08-27.md`
and the final issue log.

The maintained-fork scan now finds **zero** semantic
`case snDeclaration:` decoders. Direct line-bearing `asCScriptNode` sites are
declaration **85**, expression **42**, statement **20**, and core Sema **3**,
down from CTA-S-13's **96/42/27/3**. The remaining sites are named adapters and
other declaration/expression/statement families; the count is a migration
signal, not proof that action-only Sema is complete.

## 2026-08-27 overall progress snapshot after CTA-S-14

**Primary engineering completion estimate: 69%.** This supersedes the 68%
CTA-S-13 snapshot. The literal OpenSpec checkbox ratio remains **86/125
checked, 39 open, 68.8%**: CTA-S-14 advances `4.2`, `4.3`, `4.4`, `4.5`, and
`13.2`, but the complete wording of each umbrella still includes other open
language/authority families.

Only the Sema-authority stream is credited for this slice, moving from 65% to
70%. Backend, TypedASTJIT, entry-point, default-cutover and delivery streams do
not receive progress merely because their regression gates remained green:

| Workstream | Weight | Current estimate | Weighted contribution |
|---|---:|---:|---:|
| Baselines, SourceManager, AST/context/seal/public view, Cache containment and canonical TypeId boundary | 25% | 96% | 24.0% |
| Canonical declaration/type/expression/statement/lifetime Sema authority | 25% | 70% | 17.5% |
| Detached Canonical Bytecode CodeGen, relocation and Runtime installation | 18% | 72% | 13.0% |
| TypedASTJIT canonical visitor migration and production HIR retirement | 10% | 50% | 5.0% |
| Generation/publication and real production entry-point matrix | 8% | 65% | 5.2% |
| Canonical default cutover and explicit LEGACY isolation | 9% | 12% | 1.1% |
| Documentation, final focused/Standalone/All verification and reconciliation | 5% | 60% | 3.0% |
| **Total** | **100%** |  | **68.8% -> 69%** |

### Current total implementation volume

The plugin worktree currently contains **261 unique changed/new paths** against
its submodule `HEAD`: **155 tracked modified paths** and **106 untracked new
paths**. The tracked diff is **+16,231/-5,665 lines**. The 106 untracked C++/
header files contain **90,711 lines**; adding their full content to tracked
additions gives a raw changed/new implementation-and-test surface of about
**106,942 added lines**. This is deliberately not called a net diff or a
completion score: it measures the accumulated dirty-worktree implementation,
tests and support surface for the whole change.

The OpenSpec change contains **280 files**, including **247 attachment files**
and **19 review records**. These totals include design research, RED/GREEN
evidence and issue ledgers. No commit, merge, archive or final delivery is
claimed.

### What the 69% now includes

- Clang-style SourceManager, Decl/Stmt/Expr/Type graph, ASTContext, verifier,
  Seal, immutable snapshots and public views;
- stable type/function identity, immutable generation-local Runtime type
  binding, relocation validation and atomic publication foundations;
- substantial Sema facts and a real detached Canonical bytecode path with
  **114/114** ProductionCodeGen regressions green;
- typed namespace, enum, typedef, import, ordinary function, record, global,
  field, ordinary local, `for` initializer and `foreach` declaration phases
  through CTA-S-07–CTA-S-14, with no declaration-shell semantic decoder left;
- StaticJIT/TypedASTJIT identity/dependency/generation foundations, Cache V2
  default-off containment and Standalone foundations;
- synchronized TDD gates, issue ledger, execution plan, task progress notes
  and architecture review records.

### Remaining critical path (31%)

1. Finish typed property/access-group/class-default/funcdef, general type/
   parameter/default/lambda/body actions, then retire residual expression/
   statement/lifetime Parser-node semantic adapters.
2. Close detached CodeGen language, metadata, debug/coverage/exception,
   cleanup and Runtime-installation completeness without semantic fallback.
3. Replace TypedASTJIT production HIR inputs with sealed Canonical AST visitors
   and remove production HIR builders/storage/accessors.
4. Prove the aggregate generation/publication transaction and every production
   entry point, including CompileFunction, commandlet and Standalone.
5. Only after those gates, switch the default to CANONICAL, isolate the
   retained explicit LEGACY authority, physically retire TypedSemantic HIR,
   reconcile migration documentation, and run final
   focused, Standalone Debug/Release and complete All verification.

The **69%** value is the current architecture-weighted engineering estimate;
**68.8%** remains the literal checkbox ratio. The remaining 31% contains the
highest-risk backend/authority-retirement/cutover work, so neither percentage
should be extrapolated linearly from path count, LOC or elapsed time.

## 2026-08-27 CTA-S-15 class-default typed-action progress

Class `default <statement>` no longer depends on a completed
`snClassDefaultStatement` being replayed under its record. Parser now calls a
typed start action immediately after `default`, receives one exact generated
`void __InitDefaults()` declaration, enters that method DeclContext before
parsing the authored statement, and calls a finish action with only the
complete source range. Sema requires exactly one statement matching both that
method owner and range, fails closed with
`class-default-statement-action-missing` when it is absent, and appends later
defaults exactly once in source order.

The permanent test-only build passed and the valid pre-production gate was
**0/2 RED**: the early-recovery graph already had the generated method/body/
assignment, but its body and statement were owned by the class; the static
test found the missing actions and old replay decoder. After repair, the
focused pair is **2/2 PASS**, the pre-existing class-default execution fixture
is **1/1 PASS**, ProductionCodeGen is **114/114 PASS**, and the
TypedSemanticIR synthesized-default disposition/execution boundary is **1/1
PASS**. A further permanent regression proves two defaults reuse exactly one
method and attach two method-owned children in strict source order. Final
SemaAuthority is **324/324 PASS**.

Two final verification invocations were invalid but not product failures: one
Automation prefix omitted the CQTest class segment and matched zero tests; one
`RunBuild.ps1` call used unsupported `-LabelPrefix`, which was rebound as a
nonexistent UBT target before compilation. Earlier read-only source scans also
used stale guessed paths/Windows wildcard forms. All metadata, root causes and
corrected GREEN paths are recorded in
`attachments/canonical-class-default-typed-action-gate-2026-08-27.md` and
`attachments/final-completion-issue-log-2026-08-27.md`.

The maintained-fork scan now finds zero semantic
`case snClassDefaultStatement:` and zero `case snDeclaration:` decoders.
Direct line-bearing `asCScriptNode` references are declaration **84**,
expression **42**, statement **20**, and core Sema **3**. These residual named
adapters, not the raw count alone, are why action-only Sema remains incomplete.
Strict OpenSpec validation and separate parent/plugin `git diff --check` both
pass after the CTA-S-15 ledger updates; existing LF/CRLF conversion notices
are the only diff-check output.

## 2026-08-27 overall progress snapshot after CTA-S-15

**Primary engineering completion estimate: 69%.** The literal OpenSpec ratio
remains **86/125 checked, 39 open, 68.8%**. CTA-S-15 advances class-default
ownership inside `4.2`, `4.4`, `4.5`, and `13.2`, but each task is a broader
umbrella and remains unchecked.

Only the Sema-authority stream is credited, moving from 70% to 72%. The
backend, TypedASTJIT, production-entry, cutover and delivery streams receive no
credit merely because their relevant regression boundaries stayed green:

| Workstream | Weight | Current estimate | Weighted contribution |
|---|---:|---:|---:|
| Baselines, SourceManager, AST/context/seal/public view, Cache containment and canonical TypeId boundary | 25% | 96% | 24.0% |
| Canonical declaration/type/expression/statement/lifetime Sema authority | 25% | 72% | 18.0% |
| Detached Canonical Bytecode CodeGen, relocation and Runtime installation | 18% | 72% | 13.0% |
| TypedASTJIT canonical visitor migration and production HIR retirement | 10% | 50% | 5.0% |
| Generation/publication and real production entry-point matrix | 8% | 65% | 5.2% |
| Canonical default cutover and explicit LEGACY isolation | 9% | 12% | 1.1% |
| Documentation, final focused/Standalone/All verification and reconciliation | 5% | 60% | 3.0% |
| **Total** | **100%** |  | **69.3% -> 69%** |

### Current total implementation volume

The plugin worktree currently contains **262 unique changed/new paths** against
its submodule `HEAD`: **156 tracked modified paths** and **106 untracked new
paths**. The tracked diff is **+16,253/-5,669 lines**. The 106 untracked C++/
header files contain **91,023 lines**; adding their full content to tracked
additions gives a raw changed/new implementation-and-test surface of about
**107,276 added lines**. This is a dirty-worktree engineering footprint, not a
net diff and not a completion score.

The OpenSpec change currently contains **281 files**, including **248 files
recursively under `attachments/`** and **19 review records**. It now includes
the CTA-S-15 gate, RED/GREEN evidence references, final issue entry, execution
ledger row, task progress notes and this reconciled status. No commit, merge,
archive or final delivery is claimed.

### What the 69% currently includes

- the Clang-shaped SourceManager, typed Decl/Stmt/Expr/Type graph, ASTContext,
  verifier, Seal, immutable snapshot and public-view foundations;
- stable type/function identity, immutable generation-local Runtime bindings,
  complete relocation validation and atomic-publication foundations;
- a real detached Canonical bytecode path with **114/114** production
  regressions green;
- typed namespace, enum, typedef, import, ordinary function, record, global,
  field, ordinary local, `for`, `foreach`, and generated class-default phases
  through CTA-S-07–CTA-S-15;
- no declaration, record or class-default semantic switch decoder for the
  migrated families, while the Parser syntax tree remains for LEGACY/recovery;
- StaticJIT/TypedASTJIT identity/dependency/generation foundations, Cache V2
  default-off containment, Standalone foundations, and the stable TypeId
  boundary (`StableTypeKey -> ABI key -> generation binding -> dynamic ID`).

### Remaining critical path (31%)

1. Finish typed property/access-group/funcdef, general type/parameter/default/
   lambda/body actions and retire the remaining expression/statement/lifetime
   Parser-node semantic adapters.
2. Close detached CodeGen language, metadata, debug/coverage/exception,
   cleanup and Runtime-installation completeness without semantic fallback.
3. Replace TypedASTJIT production HIR inputs with sealed Canonical AST visitors
   and delete production HIR builders/storage/accessors.
4. Prove the aggregate generation/publication transaction and every production
   entry point, including CompileFunction, commandlet and Standalone.
5. Only after those gates, switch the product default to CANONICAL, isolate
   the retained explicit LEGACY authority, physically retire TypedSemantic
   HIR, reconcile migration documentation, and run final
   focused, Standalone Debug/Release and complete All verification.

The engineering score deliberately stays at **69%**, not 70%: CTA-S-15 closes
one important declaration family, but the highest-risk backend, HIR-retirement,
entry-point and cutover gates did not advance. Compiler default remains LEGACY
and Cache V2 remains default-disabled.

## 2026-08-27 CTA-S-16 funcdef typed-action progress

The fork's retained internal `ParseFuncDef()` path no longer reconstructs a
callable declaration from a completed `snFuncDef`. Parser now publishes a
pointer-free name/canonical-return-type/range action before parameters and
enters the exact returned FuncDef DeclContext. The top-level and class-member
completion paths do not notify the completed shell, and declaration Sema has no
`case snFuncDef:` decoder.

The test-only build produced the intended compile RED for the missing action
payload/API. After the production repair, the first Runtime/Editor build passed,
complete SemaAuthority is **326/326 PASS**, both focused semantic/architecture
fixtures are **1/1 PASS**, and ProductionCodeGen remains **114/114 PASS**. The
two authored-script rejection boundaries are **1/1 + 1/1 PASS**, while the host
registration/call/rebuild fixture is **1/1 PASS**. Exact evidence and the valid
RED are recorded in
`attachments/canonical-funcdef-typed-action-gate-2026-08-27.md`.

Two initial focused runner invocations omitted CQTest's test-class segment and
matched zero tests. They are recorded as invalid runner prefixes rather than
product failures. Corrected exact prefixes and the full owning suite passed.
The final source scan finds zero `case snFuncDef:` and zero class-member
`NotifySema(node->lastChild)`. Direct line-bearing `asCScriptNode` references
are declaration **83**, expression **42**, statement **20**, and core Sema
**3**, down from CTA-S-15's **84/42/20/3**.

This slice preserves the dialect and ABI boundary: authored script `funcdef`
remains tokenizer-rejected; host `RegisterFuncdef`, dynamic Runtime TypeId
projection, VM object-register/indirect-call behavior and CodeGen relocations
are unchanged. General type/parameter/default/property/access-group/lambda/
body/expression/statement/lifetime authority remains open.

## 2026-08-27 overall progress snapshot after CTA-S-16

**Primary engineering completion estimate: 70%.** The literal OpenSpec ratio
remains **86/125 checked, 39 open, 68.8%**. CTA-S-16 advances `4.2`, `4.4` and
`13.2`, but their complete wording covers broader language and authority
families, so none is checked prematurely.

Only the Sema-authority stream is credited, moving from 72% to 73%. Backend,
TypedASTJIT, production-entry, default-cutover and final-delivery streams get no
credit merely because their regression gates stayed green:

| Workstream | Weight | Current estimate | Weighted contribution |
|---|---:|---:|---:|
| Baselines, SourceManager, AST/context/seal/public view, Cache containment and canonical TypeId boundary | 25% | 96% | 24.0% |
| Canonical declaration/type/expression/statement/lifetime Sema authority | 25% | 73% | 18.3% |
| Detached Canonical Bytecode CodeGen, relocation and Runtime installation | 18% | 72% | 13.0% |
| TypedASTJIT canonical visitor migration and production HIR retirement | 10% | 50% | 5.0% |
| Generation/publication and real production entry-point matrix | 8% | 65% | 5.2% |
| Canonical default cutover and explicit LEGACY isolation | 9% | 12% | 1.1% |
| Documentation, final focused/Standalone/All verification and reconciliation | 5% | 60% | 3.0% |
| **Total** | **100%** |  | **69.6% -> 70%** |

### Current total implementation volume

The plugin worktree contains **262 unique changed/new paths** against its
submodule `HEAD`: **156 tracked modified paths** and **106 untracked new
paths**. The tracked diff is **+16,280/-5,666 lines**. The 106 untracked C++/
header files contain **91,234 lines**; adding their full content to tracked
additions gives a raw changed/new implementation-and-test surface of about
**107,514 added lines**. This is a dirty-worktree footprint, not a net diff and
not a completion score.

The OpenSpec change contains **282 files**, including **249 files recursively
under `attachments/`** and **19 review records**. CTA-S-16 adds the gate/result,
RED/GREEN evidence, issue entry, execution-ledger row, task progress notes,
authority inventory update and this reconciled snapshot. No commit, merge,
archive or final delivery is claimed.

### What the 70% currently includes

- Clang-shaped SourceManager, typed Decl/Stmt/Expr/Type graph, ASTContext,
  verifier, Seal, immutable snapshot and public-view foundations;
- stable type/function identity, immutable generation-local Runtime bindings,
  relocation validation and atomic-publication foundations;
- a real but language-incomplete detached Canonical bytecode path with
  **114/114** ProductionCodeGen regressions green;
- typed namespace, enum, typedef, import, ordinary function, record, global,
  field, local/loop, generated class-default and retained Parser funcdef phases
  through CTA-S-07–CTA-S-16;
- removal of whole-node declaration decoders for those migrated families while
  retaining the Parser syntax tree only for LEGACY/recovery boundaries;
- StaticJIT/TypedASTJIT foundations, Cache V2 default-off containment,
  Standalone foundations and stable TypeId projection
  (`StableTypeKey -> ABI key -> generation binding -> dynamic numeric ID`).

### Remaining critical path (30%)

1. Finish property/access-group and general type/parameter/default/lambda/body
   actions, then retire remaining expression/statement/lifetime Parser-node
   semantic adapters and Builder/LEGACY declaration authority.
2. Close detached CodeGen language, metadata, debug/coverage/exception,
   cleanup and Runtime-installation completeness without semantic fallback.
3. Replace TypedASTJIT production HIR inputs with sealed Canonical AST visitors
   and delete production HIR builders/storage/accessors.
4. Prove aggregate generation/publication transactions and every production
   entry point, including CompileFunction, commandlet and Standalone.
5. Only after those gates, switch the default to CANONICAL, isolate the
   retained explicit LEGACY authority, physically retire TypedSemantic HIR,
   reconcile migration documentation, and run final
   focused, Standalone Debug/Release and complete All verification.

The rounded **70%** is an architecture-weighted engineering estimate with
roughly ±3 percentage points of judgment; **68.8%** is the literal checkbox
ratio. The remaining work contains the highest-risk backend, HIR-retirement,
entry-point and cutover gates. Compiler default remains LEGACY and Cache V2
remains default-disabled.

## 2026-08-27 CTA-S-17 custom access-specifier typed-action progress

The fork's custom `access NAME = ...;` family is now represented in the sealed
Canonical graph instead of existing only as Parser syntax plus a
Builder/Runtime registration side effect. Parser publishes one complete
pointer-free access action after the terminating `;`; Sema creates a named
`AccessSpecifierDecl`, ordered `AccessPermissionDecl` children, typed base/
permission traits and an exact record-local DeclId edge on every authored
field or method using `access:NAME`.

The public/internal AST contract was extended append-only. Verifier and
traversal reject dangling, foreign-owner and wrong-kind member edges; dump and
shadow comparison make the relationship deterministic; the capacity-aware
public view preserves older caller size behavior; Sidecar schema **V5**
encodes, decodes, validates and hashes the new edge; detached CodeGen accepts
the declarations as non-executable metadata. The exact `ParseAccessDecl`
slice contains one typed action publication and zero `NotifySema` calls, and
declaration Sema contains no `case snAccessDeclaration:`.

The test-only build produced the intended compile RED for the absent enum,
trait, action, edge, public-view and sidecar contract. One direct-test API call
was corrected during that RED to supply the already-required canonical method
return type. After production repair, three GREEN-stage failures were traced
to permanent test fixtures rather than production:

- a hand-built access specifier omitted mandatory PRIVATE/PROTECTED;
- the snapshot test incorrectly demanded LEGACY Runtime registration from the
  current detached CANONICAL Build, contrary to the gate's non-claim;
- the snapshot fixture searched a class method as `FUNCTION` rather than
  `METHOD`.

The fixtures were corrected without loosening verifier rules or claiming the
future Runtime-install boundary. Final results are SemaAuthority **329/329**,
traversal/verifier **6/6**, ASTBodySidecar **18/18**, Module Snapshot
**10/10**, ProductionCodeGen **114/114**, and Parser declarations **18/18**.
The valid RED, every intermediate run, root cause and final evidence are in
`attachments/canonical-access-specifier-typed-action-gate-2026-08-27.md` and
`attachments/final-completion-issue-log-2026-08-27.md`.

Direct line-bearing `asCScriptNode` references remain declaration **83**,
expression **42**, statement **20**, and core Sema **3**. The declaration
count does not fall because the slice adds typed payload/edge support while
removing replay; raw occurrence count is an inventory signal, not the
authority gate. General type/parameter/default/property/lambda/body and
expression/statement/lifetime adapters remain open.

## 2026-08-27 overall progress snapshot after CTA-S-17

**Primary engineering completion estimate: 70%.** The architecture-weighted
unrounded estimate is approximately **70.2%**. The literal OpenSpec ratio is
still **86/125 checked, 39 open, 68.8%**: CTA-S-17 materially advances
`4.2`, `4.4`, `4.5` and `13.2`, but each is a broader acceptance umbrella and
none is checked prematurely.

The Sema-authority stream is credited from 73% to 76% because this slice spans
typed construction, exact dependency edges, verifier/traversal, immutable
public publication and Sidecar persistence. The headline remains 70% after
rounding because backend completeness, HIR retirement, production entry-point
proof and default cutover did not advance:

| Workstream | Weight | Current estimate | Weighted contribution |
|---|---:|---:|---:|
| Baselines, SourceManager, AST/context/seal/public view, Cache containment and canonical TypeId boundary | 25% | 96% | 24.0% |
| Canonical declaration/type/expression/statement/lifetime Sema authority | 25% | 76% | 19.0% |
| Detached Canonical Bytecode CodeGen, relocation and Runtime installation | 18% | 72% | 13.0% |
| TypedASTJIT canonical visitor migration and production HIR retirement | 10% | 50% | 5.0% |
| Generation/publication and real production entry-point matrix | 8% | 65% | 5.2% |
| Canonical default cutover and explicit LEGACY isolation | 9% | 12% | 1.1% |
| Documentation, final focused/Standalone/All verification and reconciliation | 5% | 60% | 3.0% |
| **Total** | **100%** |  | **70.2% -> 70%** |

### Current total implementation volume

The refreshed plugin worktree footprint is **262 unique changed/new paths**
against its submodule `HEAD`: **156 tracked modified paths** and **106
untracked new paths**. The tracked diff is **+16,377/-5,673 lines**. The 106
readable untracked files contain **85,981 text lines**; counting their full
content together with tracked additions gives a raw changed/new surface of
approximately **102,358 added lines**. This deliberately reports the dirty
worktree footprint, not authorship, net product size or completion percentage.

The OpenSpec change contains **283 files**, including **250 files recursively
under `attachments/`** and **19 review records**. CTA-S-17 is represented by
its gate/result, issue-log entry, execution-ledger row, task progress notes,
authority inventory update and this status snapshot. No commit, merge,
archive, default switch or final delivery is claimed.

### What the 70% currently includes

- Clang-shaped SourceManager, typed Decl/Stmt/Expr/Type graph, ASTContext,
  verifier, Seal, immutable snapshot and capacity-aware public-view foundations;
- stable type/function identity, immutable generation-local Runtime bindings,
  relocation validation and atomic-publication foundations, with numeric
  TypeId retained only as a generation-local projection;
- a real but language-incomplete detached Canonical bytecode path with
  **114/114** ProductionCodeGen regressions green;
- typed namespace, enum, typedef, import, ordinary function, record, global,
  field, local/loop, generated class-default, retained Parser funcdef and
  custom access-specifier phases through CTA-S-07–CTA-S-17;
- exact access-definition/permission/member-edge facts through verifier,
  traversal, Sidecar V5 and public snapshot, while Runtime registration stays
  explicitly on the LEGACY comparison path;
- StaticJIT/TypedASTJIT foundations, Cache V2 default-off containment,
  Standalone foundations and the stable dynamic-TypeId boundary
  (`StableTypeKey -> ABI key -> generation binding -> numeric projection`).

### Remaining critical path (approximately 30%)

1. Finish property and general type/parameter/default/lambda/body actions,
   then retire expression/statement/lifetime Parser-node semantic adapters and
   the remaining Builder/LEGACY declaration authority.
2. Close detached CodeGen language, metadata, debug/coverage/exception,
   cleanup and Runtime-installation completeness—including Canonical access
   metadata installation—without semantic fallback.
3. Replace TypedASTJIT production HIR inputs with sealed Canonical AST visitors
   and delete production HIR builders/storage/accessors.
4. Prove aggregate generation/publication transactions and every production
   entry point, including CompileFunction, commandlet and Standalone.
5. Only after those gates, switch the default to CANONICAL, isolate the
   retained explicit LEGACY authority, physically retire TypedSemantic HIR,
   reconcile migration documentation, and run final
   focused, Standalone Debug/Release and complete All verification.

The reported **70%** is an architecture-weighted estimate with approximately
±3 percentage points of judgment. The independently reproducible mechanical
ratio is **68.8%**. The remaining work is disproportionately risky: it contains
backend/runtime installation, production HIR removal and the irreversible
default/legacy-authority cutover. Compiler default remains LEGACY and Cache V2
remains default-disabled.

## 2026-08-27 CTA-S-18 callable-parameter typed-action progress

Ordinary, import, interface-method and retained Parser-funcdef parameter
headers now cross a pointer-free typed action before optional default parsing.
The action contains the exact callable DeclId, canonical qualified type,
authored name and half-open range. Sema validates the callable/type/range,
creates the ParamDecl and records its named-type dependency. A successfully
parsed default is attached later through a separately named transitional
adapter; a malformed default cannot erase the header or synthesize a fake init.
`ActOnParsedParam` and its `lastActedDecl` owner fallback are deleted.

The permanent behavior/architecture tests produced the intended pre-edit
**329/331 PASS, 2 FAIL**. After repair, the first complete Sema run was
**330/331** because an existing source-oracle still searched for the old
`ParseParameterList()` spelling in the funcdef slice. The actual ordering was
correct and stronger, so the test was updated to require the exact
`ParseParameterList(canonicalFuncDef)` route. Final results are SemaAuthority
**331/331**, ProductionCodeGen **114/114**, and Parser declarations **18/18**.

Two invalid build invocations are not counted: one outer escaping error never
started `RunBuild.ps1`; one used unsupported `-ReportOutputPath`, which UBT
misread as a target and rejected before compilation. Their disposition, the
valid RED, every build/run path and the stale-oracle correction are recorded in
`attachments/canonical-parameter-typed-action-gate-2026-08-27.md` and
`attachments/final-completion-issue-log-2026-08-27.md`.

The maintained-fork scan now finds zero `ActOnParsedParam`; all Canonical
`ParseParameterList` routes carry an exact owner. Direct line-bearing
`asCScriptNode` references remain **83/42/20/3** across declaration,
expression, statement and core Sema because the named default adapter remains.
The historical Task 4.4 virtual-property wording was reconciled against the
maintained dialect: Parser still emits `TXT_VIRTUAL_PROPERTY_REMOVED`, Sema has
no virtual-property case and `ActOnPropertyDecl` has no production caller. No
deleted syntax was restored.

## 2026-08-27 overall progress snapshot after CTA-S-18

**Primary engineering completion estimate: 71%.** The architecture-weighted
unrounded estimate is approximately **70.7%**. The literal OpenSpec ratio
remains **86/125 checked, 39 open, 68.8%**: CTA-S-18 materially advances
`4.2`, `4.3`, `4.4`, `4.5` and `13.2`, but their complete acceptance wording
still spans broader semantic families, so none is checked prematurely.

Only the Sema-authority stream is credited, from 76% to 78%. Backend,
TypedASTJIT, production-entry, default-cutover and final-delivery streams did
not advance merely because their regressions stayed green:

| Workstream | Weight | Current estimate | Weighted contribution |
|---|---:|---:|---:|
| Baselines, SourceManager, AST/context/seal/public view, Cache containment and canonical TypeId boundary | 25% | 96% | 24.0% |
| Canonical declaration/type/expression/statement/lifetime Sema authority | 25% | 78% | 19.5% |
| Detached Canonical Bytecode CodeGen, relocation and Runtime installation | 18% | 72% | 13.0% |
| TypedASTJIT canonical visitor migration and production HIR retirement | 10% | 50% | 5.0% |
| Generation/publication and real production entry-point matrix | 8% | 65% | 5.2% |
| Canonical default cutover and explicit LEGACY isolation | 9% | 12% | 1.1% |
| Documentation, final focused/Standalone/All verification and reconciliation | 5% | 60% | 3.0% |
| **Total** | **100%** |  | **approximately 70.7% -> 71%** |

### Refreshed implementation inventory

The plugin worktree contains **262 unique changed/new paths** against its
submodule `HEAD`: **156 tracked modified paths** and **106 untracked new C++/
header paths**. The tracked diff is **+16,415/-5,676 lines**. The 106 untracked
source/header files contain **92,250 lines**; counting their full content with
tracked additions gives a raw changed/new implementation-and-test surface of
approximately **108,665 added lines**. This is a dirty-worktree footprint, not
authorship, a net product size, or a completion score.

The OpenSpec change now contains **284 files**, including **251 files beneath
`attachments/`** and **19 review records**. CTA-S-18 is represented by its
gate/result, issue-log entry, execution-ledger row, task progress notes,
authority inventory update and this reconciled snapshot. No commit, merge,
archive, default switch or final delivery is claimed.

### What the 71% now includes

- the Clang-shaped SourceManager, typed ASTContext/Decl/Stmt/Expr/Type graph,
  verifier, Seal and immutable public snapshot foundations;
- stable type/function/ABI identity, generation-local Runtime bindings and the
  stable dynamic-TypeId projection boundary;
- typed declaration phases through namespace, enum, typedef, import, ordinary
  functions, records, global/field/local/loop declarations, generated class
  defaults, retained Parser funcdefs, custom access groups and callable
  parameter headers;
- a real but language-incomplete detached Canonical Bytecode backend with the
  current ProductionCodeGen **114/114** gate green;
- existing StaticJIT/TypedASTJIT, Cache V2 default-off, publication and
  Standalone foundations without claiming their final cutover closure.

### Remaining critical path (approximately 29%)

1. Finish general qualified/template type production, default expressions and
   named-argument diagnostics, property/accessor, lambda/list-pattern/body and
   expression/statement/lifetime action authority; then remove remaining
   semantic Parser-node adapters and Builder/LEGACY declaration authority.
2. Complete detached Bytecode lowering, metadata, debug/coverage/exception,
   cleanup and transactional Runtime installation without semantic fallback.
3. Replace TypedASTJIT production HIR inputs with sealed Canonical AST visitors
   and delete production HIR builders/storage/accessors.
4. Prove the aggregate generation/publication and every production entry-point
   matrix, including CompileFunction, commandlet and Standalone.
5. Only then switch the default to CANONICAL, isolate the retained explicit
   LEGACY authority, physically retire TypedSemantic HIR, reconcile migration
   documentation and run final focused, Standalone Debug/
   Release and complete All verification.

The **71%** headline is a rounded engineering estimate with approximately ±3
percentage points of judgment. The mechanical checkbox ratio is **68.8%**.
The remaining 29% contains the highest-risk backend/install, HIR-retirement,
entry-point and irreversible default/LEGACY-authority gates. Compiler default
remains LEGACY and Cache V2 remains default-disabled.

## 2026-08-27 CTA-S-19 declaration-QualType typed-action progress

Every declaration-site return, parameter and variable type now crosses the
Parser-to-Sema boundary as a short-lived pointer-free action. Parser copies the
complete spelling, root primitive token, qualifier mask and half-open source
offsets while it still owns syntax. Sema validates that payload and alone
resolves the local canonical QualType. Import, parameter, funcdef, ordinary
function, interface-method, global/field/local/`for`, and `foreach` routes are
all migrated; this is seven action call sites and zero Parser calls to
`ActOnQualTypeFromNode`.

The permanent semantic test proves `array<int>` with `const &in` resolves to a
valid template kind, exact stable key and exact qualifiers without a script
node. The architecture test locks the all-route migration and rejects Parser
nodes, Runtime pointers, numeric TypeIds and foreign AST refs in the action.
The pre-edit test-only build failed exactly for the missing action/API. The
production build then passed, followed by focused **2/2**, SemaAuthority
**333/333**, ProductionCodeGen **114/114**, Parser declarations **18/18**, and
Frontend Type **20/20**.

The direct line-bearing `asCScriptNode` inventory remains **83/42/20/3** for
declaration/expression/statement/core Sema. That unchanged count is truthful:
the declaration routes no longer call the adapter, but Sema still declares,
defines and uses it for residual lambda/property/expression/cast/construct
recovery. The interned type object also has no source-range field; this slice
validates the action range at the boundary without claiming persisted type
provenance. One stale guessed read-only scan path produced no files and was
discarded; the corrected maintained-fork scan is the evidence source. There
were no build/test runner failures.

Exact RED/GREEN paths, source scans, non-claims and the scan-path correction
are recorded in
`attachments/canonical-declaration-qualtype-typed-action-gate-2026-08-27.md`
and `attachments/final-completion-issue-log-2026-08-27.md`. Strict OpenSpec
validation and both diff checks pass with only existing line-ending notices.

## 2026-08-27 overall progress snapshot after CTA-S-19

**Primary engineering completion estimate: 71%.** The architecture-weighted
unrounded estimate is approximately **71.2%**. The literal OpenSpec ratio
remains **86/125 checked, 39 open, 68.8%**: CTA-S-19 materially advances
`4.2`, `4.3`, `4.4`, and `13.2`, but residual type recovery and the other
semantic families prevent truthful umbrella closure.

Only the Sema-authority stream is credited, from 78% to 80%. Backend,
TypedASTJIT, production-entry, cutover and delivery streams remain unchanged:

| Workstream | Weight | Current estimate | Weighted contribution |
|---|---:|---:|---:|
| Baselines, SourceManager, AST/context/seal/public view, Cache containment and canonical TypeId boundary | 25% | 96% | 24.0% |
| Canonical declaration/type/expression/statement/lifetime Sema authority | 25% | 80% | 20.0% |
| Detached Canonical Bytecode CodeGen, relocation and Runtime installation | 18% | 72% | 13.0% |
| TypedASTJIT canonical visitor migration and production HIR retirement | 10% | 50% | 5.0% |
| Generation/publication and real production entry-point matrix | 8% | 65% | 5.2% |
| Canonical default cutover and explicit LEGACY isolation | 9% | 12% | 1.1% |
| Documentation, final focused/Standalone/All verification and reconciliation | 5% | 60% | 3.0% |
| **Total** | **100%** |  | **approximately 71.2% -> 71%** |

### Refreshed total implementation inventory

The plugin worktree contains **262 unique changed/new paths** against its
submodule `HEAD`: **156 tracked modified paths** and **106 untracked new
paths**. The tracked diff is **+16,597/-5,676 lines**. Counting all content
records in the 106 readable untracked files gives **92,364 lines**; combining
them with tracked additions gives a raw changed/new implementation-and-test
surface of approximately **108,961 added lines**. These are dirty-worktree
footprint figures, not authorship, net product size or a completion score.

The OpenSpec change now contains **285 files**, including **252 files beneath
`attachments/`** and **19 review records**. CTA-S-19 is represented by its gate,
issue-log entry, execution-ledger row, task progress notes, authority inventory
update and this status snapshot. No commit, merge, archive, default switch or
final delivery is claimed.

### What the 71% now includes

- Clang-shaped SourceManager, ASTContext, typed Decl/Stmt/Expr/Type graph,
  verifier, Seal, immutable snapshots and capacity-aware public views;
- stable type/function/ABI identities and generation-local Runtime projection,
  with dynamic numeric TypeId excluded from durable AST/provider/relocation
  identity;
- typed declaration phases for namespace, enum, typedef, import, ordinary
  functions, records, variables/loops, class defaults, retained funcdefs,
  access groups and callable parameters;
- pointer-free declaration-site primitive/qualified/template/qualified-type
  actions across all seven live Parser route families;
- a real but language-incomplete detached Canonical Bytecode backend with
  ProductionCodeGen **114/114**, plus existing StaticJIT/TypedASTJIT, Cache V2
  default-off, publication and Standalone foundations.

### Remaining critical path (approximately 29%)

1. Remove residual lambda/property/expression/cast/construct type recovery;
   finish default/named-argument, property/accessor, lambda/list-pattern/body,
   expression/statement/lifetime action authority and retire remaining
   Builder/LEGACY declaration semantics.
2. Complete detached CodeGen language coverage, metadata, debug/coverage/
   exception/cleanup and transactional Runtime installation without fallback.
3. Replace TypedASTJIT production HIR inputs with sealed Canonical AST visitors
   and delete production HIR builders/storage/accessors.
4. Prove aggregate generation/publication and all production entry points,
   including CompileFunction, commandlet and Standalone.
5. Only then switch the default to CANONICAL, isolate the retained explicit
   LEGACY authority, physically retire TypedSemantic HIR, reconcile delivery
   docs and run final focused, Standalone Debug/Release and
   complete All verification.

The rounded headline stays **71%** even though the unrounded estimate rose from
70.7% to 71.2%; reporting 72% would overstate the bounded type-action slice.
The reproducible mechanical ratio remains **68.8%**. Compiler default remains
LEGACY and Cache V2 remains default-disabled.

## 2026-08-27 CTA-S-20 expression-target-type action progress

Primitive functional casts and object constructions no longer ask expression
Sema to decode their retained `snDataType`. Parser resolves the target through
the pointer-free type-syntax action while it still owns syntax and publishes
the local canonical QualType through an exact migration-only binding. The
binding is keyed by transient node identity with an exact section/offset
fallback, rejects ambiguous coordinates, and is not exposed through AST,
snapshot, Provider, relocation or Cache surfaces. Missing binding fails closed
with `expression-target-type-unbound`.

Two permanent tests were added first. The initial complete SemaAuthority run
was **333/335 PASS, 2 FAIL**. One was the intended architecture RED. The other
showed the fixture used `cast<double>(40)`, while this fork reserves `cast<T>`
for reference casts. Correcting the fixture to the supported `double(40)`
functional cast changed no production code and left the architecture RED
valid. Parser now has exactly two target-type publications, and Parser,
`as_sema_expr.cpp` and the incremental cast action have zero
`ActOnQualTypeFromNode` calls.

The corrected-fixture build and first production build compiled and linked the
Runtime but hit an independent test-module source issue:
`AngelscriptNativeContextReturnValueTests.cpp` uses `ASTEST_AS_ANSI` without
including `AngelscriptTestMacros.h`. A validation-only include was added,
the supported full build passed, and the include was immediately removed; a
logical diff against `HEAD` for that file is empty. This does not claim the
independent aggregate clean-build blocker is fixed.

Final gates are SemaAuthority **335/335**, ProductionCodeGen **114/114**,
Parser declarations **18/18**, Frontend Type **20/20**, Language Conversions
**17/17** and Expression Chain **1/1**. Exact RED/build/GREEN paths and the
reverted workaround are recorded in
`attachments/canonical-expression-target-type-action-gate-2026-08-27.md` and
`attachments/final-completion-issue-log-2026-08-27.md`.

The direct line-bearing Parser-node inventory is now **80/41/20/5** for
declaration/expression/statement/core Sema. The remaining type decoder has only
three lambda/declaration-related production call sites in `as_sema_decl.cpp`.
This is bounded progress: general expressions, defaults, properties, lambdas,
bodies, statements, lifetimes and Builder/LEGACY authority remain open.

## 2026-08-27 overall progress snapshot after CTA-S-20

**Primary engineering completion estimate: 71%.** The architecture-weighted
unrounded estimate is approximately **71.5%**, conservatively reported as 71%
because CTA-S-20 removes one narrow expression target-type boundary rather than
closing a whole OpenSpec task. The literal OpenSpec ratio remains **86/125
checked, 39 open, 68.8%**.

Only the Sema-authority stream is credited, from 80% to 81%. All downstream
streams retain their previous estimates even though their regressions remain
green:

| Workstream | Weight | Current estimate | Weighted contribution |
|---|---:|---:|---:|
| Baselines, SourceManager, AST/context/seal/public view, Cache containment and canonical TypeId boundary | 25% | 96% | 24.0% |
| Canonical declaration/type/expression/statement/lifetime Sema authority | 25% | 81% | 20.3% |
| Detached Canonical Bytecode CodeGen, relocation and Runtime installation | 18% | 72% | 13.0% |
| TypedASTJIT canonical visitor migration and production HIR retirement | 10% | 50% | 5.0% |
| Generation/publication and real production entry-point matrix | 8% | 65% | 5.2% |
| Canonical default cutover and explicit LEGACY isolation | 9% | 12% | 1.1% |
| Documentation, final focused/Standalone/All verification and reconciliation | 5% | 60% | 3.0% |
| **Total** | **100%** |  | **approximately 71.5% -> conservative 71%** |

### Refreshed total implementation inventory

The plugin worktree contains **262 unique changed/new paths** against its
submodule `HEAD`: **156 tracked modified paths** and **106 untracked new
paths**. The tracked diff is **+16,618/-5,682 lines**. The 106 readable
untracked files contain **92,567 content lines**; combining them with tracked
additions gives a raw changed/new implementation-and-test surface of
approximately **109,185 added lines**. These are dirty-worktree footprint
figures, not authorship, net shipped size or a completion metric.

The OpenSpec change contains **286 files**, including **253 files beneath
`attachments/`** and **19 review records**. CTA-S-20 has a gate, issue-log
entry, execution-ledger row, task progress notes, authority-inventory update
and this reconciled status. No commit, merge, archive, default switch or final
delivery is claimed.

### What the 71% now includes

- Clang-shaped SourceManager, ASTContext, typed Decl/Stmt/Expr/Type graph,
  verifier, Seal, immutable snapshots and capacity-aware public views;
- stable type/function/ABI identities and generation-local Runtime binding,
  with dynamic numeric TypeId retained only as the active-generation
  projection rather than durable identity;
- typed declaration phases from namespaces and records through callable
  signatures, parameters and variables, plus pointer-free declaration type
  syntax across all live Parser routes;
- exact typed target publication for primitive functional casts and object
  constructions, with fail-closed expression lookup;
- a real but language-incomplete detached Canonical Bytecode backend with
  ProductionCodeGen **114/114**, plus the existing publication, StaticJIT/
  TypedASTJIT, Cache V2 default-off and Standalone foundations.

### Remaining critical path (approximately 29%)

1. Finish lambda/property/default/named-argument/body/general expression,
   statement, control and lifetime action authority; remove the remaining
   semantic Parser-node adapters and Builder/LEGACY declaration authority.
2. Complete detached CodeGen language/metadata/debug/coverage/exception/
   cleanup lowering and transactional Runtime installation without fallback.
3. Replace TypedASTJIT production HIR inputs with sealed Canonical AST visitors
   and delete production HIR builders, storage and accessors.
4. Prove aggregate generation/publication plus every real production entry
   point, including CompileFunction, Hot Reload, commandlet and Standalone.
5. Only then switch the product default to CANONICAL, isolate the retained
   explicit LEGACY authority, physically retire TypedSemantic HIR, reconcile
   delivery docs and run final focused, Standalone Debug/
   Release and complete All verification.

The remaining 29% is the risk-heavy part of the change. Compiler default is
still LEGACY, Cache V2 is still default-disabled, and no umbrella semantic or
cutover checkbox was closed by CTA-S-20.

## 2026-08-27 CTA-S-21 lambda-header typed-action progress

Lambda header identity and explicitly typed parameters no longer cross the
Parser-to-Sema boundary as semantic Parser nodes. `ParseLambda` now resolves
each explicit type through the pointer-free type-syntax action, publishes one
`asSLambdaHeaderAction`, attaches parameters under the exact returned lambda
DeclId and pushes that exact DeclContext before parsing the body. It neither
notifies the completed lambda header nor selects the body owner through mutable
`lastActedDecl`.

The retained `ActOnLambdaFromNode` route is body-only. It must retrieve the
exact previously bound declaration, validate its lambda trait and fail closed
with `lambda-header-action-missing`; it cannot recover the signature or type.
`ActOnQualTypeFromNode`, `WalkParameterSequence`, `WalkParameterList`,
`FindExistingFunctionLike` and the supporting signature/type decoder helpers
are physically deleted. The previously node-based TypeSema test was migrated
to `BuildQualTypeSyntaxAction -> ActOnQualTypeAction`, so the obsolete API was
not restored for test compatibility.

The pre-edit test-only build is a valid compile-time RED for the missing action
and API. The first production build then exposed the stale TypeSema helper plus
the already-recorded, out-of-slice test-macro include blocker. The test helper
was corrected in-slice; the unrelated include was used only as a validation
workaround, immediately removed and confirmed absent from the logical diff.
Final gates are SemaAuthority **337/337**, Canonical TypeSema **1/1**, Parser
declarations **18/18**, ProductionCodeGen **114/114**, and Frontend Type
**20/20**.

The maintained-fork direct line-bearing `asCScriptNode` inventory is now
**49/41/20/5** for declaration/expression/statement/core Sema, down from
**80/41/20/5** after CTA-S-20. The reduction is unusually large because the
entire private lambda signature/type reconstruction chain was deleted; it is
still not proof that the remaining property/default/body/expression/statement/
lifetime adapters are complete.

Exact RED/build/GREEN paths, the stale scan-path correction, the reverted
workaround and explicit non-claims are recorded in
`attachments/canonical-lambda-header-typed-action-gate-2026-08-27.md` and
`attachments/final-completion-issue-log-2026-08-27.md`.

## 2026-08-27 overall progress snapshot after CTA-S-21

**Primary engineering completion estimate: 72%.** The architecture-weighted
unrounded estimate is approximately **71.7%** (exact weighted sum 71.74%). The literal OpenSpec ratio
remains **86/125 checked, 39 open, 68.8%** because CTA-S-21 advances four
umbrella tasks but does not satisfy their complete wording.

Only the Sema-authority stream is credited, from 81% to 82%. All downstream
streams keep their previous estimates; passing their focused regressions proves
preservation, not new coverage:

| Workstream | Weight | Current estimate | Weighted contribution |
|---|---:|---:|---:|
| Baselines, SourceManager, AST/context/seal/public view, Cache containment and canonical TypeId boundary | 25% | 96% | 24.0% |
| Canonical declaration/type/expression/statement/lifetime Sema authority | 25% | 82% | 20.5% |
| Detached Canonical Bytecode CodeGen, relocation and Runtime installation | 18% | 72% | 13.0% |
| TypedASTJIT canonical visitor migration and production HIR retirement | 10% | 50% | 5.0% |
| Generation/publication and real production entry-point matrix | 8% | 65% | 5.2% |
| Canonical default cutover and explicit LEGACY isolation | 9% | 12% | 1.1% |
| Documentation, final focused/Standalone/All verification and reconciliation | 5% | 60% | 3.0% |
| **Total** | **100%** |  | **71.74% -> 72%** |

### Refreshed total implementation inventory

The plugin worktree currently contains **261 unique changed/new paths** against
its submodule `HEAD`: **155 tracked modified paths** and **106 untracked new
paths**. The tracked diff is **+16,697/-5,679 lines**. All 106 untracked files
were readable and contain **92,342 content lines**; combining that content with
tracked additions gives a raw changed/new implementation-and-test surface of
approximately **109,039 added lines**. These figures describe the entire dirty
worktree, including prior slices and generated/test material. They are not
authorship, net shipped size, reviewed-line coverage or a completion score.

The OpenSpec change contains **286 files**, including **254 files beneath
`attachments/`** and **19 review records**. CTA-S-21 has a gate, issue-log
entry, execution-ledger row, task progress notes, authority inventory update
and this reconciled snapshot. No commit, merge, archive or default switch is
claimed.

### What the 72% implementation now contains

1. A Clang-shaped frontend foundation: SourceManager, ASTContext, typed
   Decl/Stmt/Expr/Type graph, Sema-owned symbols/conversions/plans, verifier,
   Seal, immutable snapshots, traversal/dump/diagnostics and public views.
2. Stable declaration/function/type/ABI identities. AngelScript numeric TypeId
   is deliberately retained only as a late Engine/generation-local Runtime
   projection; durable AST, Cache/provider/relocation and cross-generation
   identity use complete stable keys plus ABI keys.
3. Twenty-one recorded Sema migration slices through namespace, declarations,
   signatures, type syntax, cast/construct targets and now lambda headers/
   explicit parameters. The generic node-to-type semantic decoder is gone.
4. A real but language-incomplete detached Canonical Bytecode backend with six
   relocation families and transactional generation/publication foundations;
   ProductionCodeGen remains **114/114** on the current supported surface.
5. TypedASTJIT canonical capture/visitor foundations, StaticJIT provider
   routing, Cache V2 default-off containment, Hot Reload/snapshot leases,
   production-entry provenance slices and Standalone foundations.

### Remaining critical path (approximately 28%)

1. Finish contextual lambda/funcdef signature and return inference, untyped
   lambda parameters, defaults/named arguments, property/accessor/list-pattern
   declarations, body actions and general expression/statement/control/
   lifetime authority; remove the remaining semantic Parser-node adapters and
   Builder/LEGACY declaration authority.
2. Complete detached CodeGen language coverage, object/container/generated/
   exception/suspend/debug/coverage/cleanup semantics and transactional Runtime
   installation with no semantic fallback.
3. Replace all production TypedASTJIT HIR-shaped inputs/oracles with sealed
   Canonical AST visitors, then physically delete HIR builders, storage and
   accessors.
4. Prove atomic aggregate publication and every production entry point,
   including CompileFunction, Hot Reload, commandlet and Standalone.
5. Only after those gates, switch the product default from LEGACY to CANONICAL,
   isolate the retained explicit LEGACY authority, physically retire
   TypedSemantic HIR, reconcile delivery documentation and run final focused,
   Standalone Debug/Release and complete All verification.

The percentage is an engineering estimate over architecture workstreams, not a
release-readiness promise. The remaining 28% contains the highest-risk backend,
lifecycle, HIR-retirement and default-cutover work. Compiler default remains
LEGACY and Cache V2 remains default-disabled.

## 2026-08-27 CTA-S-22 whole-tree declaration replay retirement

CTA-S-22 removes the inactive second declaration-semantic entry rather than
placing another guard around it. Parser no longer contains `NotifySema`,
`semaDeclActions`, the action-counter increments, the top-level declaration
exclusion list or the zero-action `ActOnParsedScript` call. Public Sema no
longer exposes `ActOnParsedDeclaration` or `ActOnParsedScript`; declaration
Sema no longer contains `WalkOne`, `WalkDecls` or their replay-only recursive
identifier/token/type/return/trait helpers.

Two permanent API-surface tests were added first. After repairing the recurring
test-infrastructure include defect described below, the valid RED was
**337/339 PASS**, with only the two obsolete methods observed as present:
`Saved/Tests/cta-declaration-replay-red/20260827_161809_396_b4bdbf7d/RunMetadata.json`.

The first post-deletion SemaAuthority run was **335/339**. All four failures
were older source-architecture assertions that positively required the now-
deleted exclusion-list or residual walker text as proof of non-replay. No
source-built AST, type, lookup, call-plan, CodeGen or execution assertion
failed. The tests now require global absence of the callback and walker, which
is stronger and aligned with the new architecture.

Final evidence is:

- full Runtime/Editor build: exit 0, all 41 scheduled actions complete,
  `Saved/Build/cta-declaration-replay-green-build/20260827_162535_044_2ed1c425/RunMetadata.json`;
- test-repair build: exit 0,
  `Saved/Build/cta-declaration-replay-green-test-repair-build/20260827_162848_770_7cf1decf/RunMetadata.json`;
- SemaAuthority **339/339 PASS**,
  `Saved/Tests/cta-declaration-replay-green-sema-fix1/20260827_162908_093_8a7561d0/RunMetadata.json`;
- combined Canonical TypeSema, Parser declarations, ProductionCodeGen and
  Frontend Type **152/152 PASS**,
  `Saved/Tests/cta-declaration-replay-green-regression-matrix/20260827_163022_003_215ff320/RunMetadata.json`.

The first test-only build also closed a recurring non-semantic infrastructure
problem. Three native SDK context test `.cpp` files used `ASTEST_AS[_ANSI]`
without directly including `AngelscriptTestMacros.h`; adaptive non-unity had
exposed the ReturnValue file in three consecutive slices. A scan of all 450
macro-user `.cpp` files identified ReturnValue, PublicApiDepth and Invocation
as real missing includes; a StaticJIT file using the `Shared/` header was a
scan false positive. All three now include the macro header directly. The
failed/repaired builds are recorded as CTA-I-01 in the issue log. This repair
has no compiler-semantic completion credit.

The forbidden-symbol scan is zero. Direct line-bearing `asCScriptNode`
inventory is now declaration **25**, expression **41**, statement **20** and
core **5**, down from **49/41/20/5** after CTA-S-21. The remaining declaration
sites are explicitly named property/default/initializer/function/lambda-body
adapters; the count does not imply those adapters are complete.

## 2026-08-27 overall progress snapshot after CTA-S-22

**Primary engineering completion estimate: 72%.** The architecture-weighted
unrounded estimate is approximately **72.24%**. The literal OpenSpec ratio
remains **86/125 checked, 39 open, 68.8%** because CTA-S-22 completes a Batch
2 implementation bullet but not the full wording of Tasks 4.2–4.6, 5.2–5.9
or 13.2.

The Sema-authority stream is credited from 82% to 84% because a complete
generic semantic entry and recursive replay family were physically deleted.
No downstream stream receives credit merely for preserving its green tests:

| Workstream | Weight | Current estimate | Weighted contribution |
|---|---:|---:|---:|
| Baselines, SourceManager, AST/context/seal/public view, Cache containment and canonical TypeId boundary | 25% | 96% | 24.00% |
| Canonical declaration/type/expression/statement/lifetime Sema authority | 25% | 84% | 21.00% |
| Detached Canonical Bytecode CodeGen, relocation and Runtime installation | 18% | 72% | 12.96% |
| TypedASTJIT canonical visitor migration and production HIR retirement | 10% | 50% | 5.00% |
| Generation/publication and real production entry-point matrix | 8% | 65% | 5.20% |
| Canonical default cutover and explicit LEGACY isolation | 9% | 12% | 1.08% |
| Documentation, final focused/Standalone/All verification and reconciliation | 5% | 60% | 3.00% |
| **Total** | **100%** |  | **72.24% -> 72%** |

### Refreshed total implementation inventory

The plugin worktree currently contains **264 unique changed/new paths** against
its submodule `HEAD`: **158 tracked modified paths** and **106 untracked new
paths**. The tracked diff is **+16,633/-5,684 lines**. All 106 untracked files
were readable and currently contain **85,883 content lines**; combining that
content with tracked additions gives a raw changed/new implementation-and-test
surface of approximately **102,516 added lines**. Builds may refresh generated
untracked material, so these are dirty-worktree footprint figures, not
authorship, net shipped size, reviewed-line coverage or a completion metric.

The OpenSpec change contains **288 files**, including **255 files beneath
`attachments/`** and **19 review records**. CTA-S-22 now has a Gate card,
issue-log entries for both the semantic slice and CTA-I-01, an execution-ledger
row, task progress notes, this authority-inventory update and this reconciled
snapshot. No commit, merge, archive or default switch is claimed.

### Updated remaining critical path (approximately 28%)

1. Replace the remaining named property/default/initializer/function-body and
   lambda-body adapters, then general expression/statement/control/lifetime
   node decoders, with typed Parser→Sema actions; finish contextual lambda/
   funcdef inference and make CANONICAL declaration authority independent from
   the retained Builder/LEGACY path.
2. Finish detached Bytecode coverage for objects, containers, generated code,
   exceptions/suspend, cleanup, debug/coverage metadata and transactional
   installation without semantic fallback.
3. Migrate all production TypedASTJIT consumers and oracles to sealed Canonical
   AST visitors and physically delete HIR builders/storage/accessors.
4. Prove aggregate atomic publication across Build, CompileFunction, Hot
   Reload, StaticJIT generation, commandlet and Standalone.
5. Only then switch the production default to CANONICAL, retain LEGACY as an
   explicit isolated compatibility/reference/rollback selection, finish
   migration documents and run focused,
   Standalone Debug/Release and complete All gates.

Compiler default remains LEGACY and Cache V2 remains default-disabled. The
remaining percentage is smaller by count but contains the highest-risk
backend, lifetime, HIR-retirement and final-cutover work.

## 2026-08-27 scope addendum — retain native AST, still delete HIR

The latest user scope decision corrects one ambiguity in every earlier progress
snapshot. “LEGACY semantic retirement” must not be read as physical deletion of
AngelScript's native Parser AST/compiler. This change now has two different
dispositions:

| Existing structure | Current-change disposition |
| --- | --- |
| `asCScriptNode` native syntax/recovery tree | Retain |
| `asCBuilder` / `asCCompiler` explicit LEGACY pipeline | Retain as independent compatibility/reference/rollback selection |
| Canonical Decl/Type/Stmt/Expr AST | Complete, verify, and make the default pipeline's semantic authority |
| `asCTypedSemanticFunction` TypedSemantic HIR | Migrate all consumers and physically delete |

CANONICAL completion remains strict: its Sema and backends may not semantically
replay `asCScriptNode`, merge Builder/Compiler facts, reconstruct HIR, decode
Bytecode for source meaning, or silently fall back. An explicit LEGACY Engine
is allowed and must remain honestly identified as LEGACY. One build still has
one publisher; unknown and `dual` selections remain rejected.

CTA-S22 is unaffected because it removed an inactive Canonical whole-tree
declaration replay entry, not the native node types or LEGACY compiler. Future
CTA-S23+ work still removes named Parser-node semantic adapters from the
CANONICAL path while leaving the underlying syntax tree available.

The mechanical count remains **86/125 checked, 39 open**. The architecture-
weighted estimate remains **72.24% -> 72%** for now: deferring native source
deletion does not make any currently incomplete Canonical semantic/backend/HIR/
publication gate green, so no artificial progress credit is taken. The 9%
workstream label is corrected from “Canonical default cutover and LEGACY
semantic retirement” to **“Canonical default cutover and explicit LEGACY
isolation”**; TypedASTJIT HIR retirement remains unchanged at 50%.

Authoritative scope record:
`attachments/legacy-native-ast-retention-scope-revision-2026-08-27.md`.
Recommended later removal record: `retire-as-legacy-native-compiler-pipeline`
(named only; not created). Compiler default remains LEGACY, Cache V2 remains
default-disabled, and no code/test/checkbox/commit/archive changed in this
scope-only reconciliation.

## 2026-08-27 CTA-S-23 lambda expression typed-action slice

CTA-S-23 removes one more CANONICAL semantic replay without deleting the
native AngelScript AST. Before the repair, Parser had already created the exact
lambda declaration and attached its body, but expression and bare-statement
lowering rediscovered that declaration from `snFunction` and attached the body
again. The replacement creates one pointer-free lambda-expression action,
binds the resulting exact `ExprId` to the retained syntax identity for the same
build, and makes later lowering consume only that identity.

The native-reference boundary is now regression-tested in both directions:

- the Canonical API test requires `ActOnLambdaFromNode` to be absent and the
  typed expression action to reference exactly one existing lambda DeclId;
- the native ScriptNode test requires the retained lambda `snFunction`,
  `snParameterList` and `snStatementBlock` shapes to remain present.

Evidence is Runtime/Editor build PASS, SemaAuthority **341/341**, native
ScriptNode shape **14/14**, Parser declarations **18/18**, and
ProductionCodeGen **114/114**. The final production scan has zero old-adapter
matches. Direct node references move from **25/41/20/5** to **22/41/20/7**:
the declaration adapter loses three lines, while the identity-only core map
adds two pointer-bearing lines without decoding node meaning.

The literal task count remains **86/125 checked, 39 open, 68.8%** and the
architecture-weighted headline remains **72%**. This slice materially reduces
the Canonical semantic critical path but does not finish contextual lambda
inference, other node adapters, detached backend coverage, TypedSemantic HIR
deletion, production-entry proof, or default cutover, so no umbrella checkbox
or percentage-point credit is manufactured. Compiler default remains LEGACY,
the explicit native LEGACY path remains retained, and Cache V2 remains
default-disabled. Detailed RED/GREEN and encountered issues:
`attachments/canonical-lambda-expression-typed-action-gate-2026-08-27.md`.

## 2026-08-27 HIR physical-retirement clarification

The requested deletion target is the added function-owned TypedSemantic HIR,
not AngelScript's native AST/compiler. A new physical-retirement inventory
therefore separates three outcomes:

| Surface | Outcome in this change |
| --- | --- |
| `asCTypedSemanticFunction` / builder / capture / storage / accessors | Physically delete after consumer migration |
| HIR-only TypedASTJIT, Editor dump, diagnostic, test and Standalone paths | Port required oracles to Canonical AST, then delete |
| `asCScriptNode` / native Parser / `asCBuilder` / `asCCompiler` / explicit LEGACY | Retain and isolate from CANONICAL semantic authority |

The broad case-insensitive scan currently finds HIR names/contracts in **44
Runtime files, 6 Editor files, 93 test files, and 5 Standalone files**. This is
larger than the two HIR model files because capture instrumentation,
script-function ownership, compatibility branches, command surfaces and test
oracles remain. One additional prerequisite is now explicit: source provenance
is a valid shared capability but still uses `asSTypedSemantic*` names and an
`as_typed_semantic_ir.h` dependency in ScriptCode/module ingestion. It must be
extracted to neutral SourceManager/ScriptCode ownership, not deleted with HIR.

Task 10.5 remains open and the headline stays **72%**. No implementation,
checkbox, default, native AST, LEGACY compiler, commit, or archive is claimed
by this audit. The dependency-ordered deletion plan and final positive/negative
source gates are recorded in
`attachments/typed-semantic-hir-physical-retirement-gate-2026-08-27.md`.

## 2026-08-27 CTA-HIR-02 neutral source-provenance extraction

The first physical HIR-retirement prerequisite is implemented. Source
provenance is no longer defined only by or included through the HIR model:

- `as_source_provenance.h` owns neutral authored/generated source records;
- ScriptCode, Module and UE source ingestion use neutral names directly;
- `as_scriptcode.h` no longer includes `as_typed_semantic_ir.h`;
- the TypedASTJIT backend testing seam accepts the neutral span type;
- HIR retains only temporary aliases while its remaining consumers migrate.

The exact behavior/API matrix is **7/7 PASS**, Canonical SourceManager is
**9/9 PASS**, Runtime/Editor build passes, and Standalone independently compiles
the maintained fork and passes **21/21**. Direct HIR include and old HIR
provenance names in neutral ScriptCode/module ingestion scan to zero. Positive
scans still find native AST/Builder/Compiler and explicit LEGACY selection.

Across active Source/Standalone inputs, the five old provenance names fall
from 203 to 173 line matches. That remaining frontier is deliberately not
hidden: HIR, TypedASTJIT and HIR-era tests still use the old names and Task 10.5
remains open. The literal task count remains **86/125 checked, 39 open** and the
headline stays **72%**; this is a required dependency extraction, not physical
HIR deletion or final cutover credit. Detailed evidence and issues:
`attachments/hir-neutral-source-provenance-extraction-gate-2026-08-27.md`.

## 2026-08-27 CTA-HIR-03 Editor HIR dump retirement

One real HIR surface is now physically gone. The four Editor command/
Commandlet files, dedicated Commandlet test, HIR-only generated-provenance
integration test, `DeveloperHIRDump` request mode and its scratch branch are
deleted. Canonical `as.AST` diagnostics remain the supported read-only AST
tooling surface.

Containment and lease coverage was preserved at the lower authority boundary:
the contained ProjectSourceGraph success/failure test and the primary public
V1 snapshot lease test are **2/2 PASS**; the existing ProjectSourceGraph group
is **2/2 PASS**. Runtime/Editor builds and Standalone is **21/21 PASS**. The
Standalone architecture gate proves all five product/test dump paths are absent
while Canonical AST diagnostics remain; Source scans have zero live HIR dump or
ProjectSourceGraph request-kind symbols.

This slice also uncovered an honest remaining migration: generated authored/
generated provenance still lacks Canonical SourceManager/structured-diagnostic
ownership. Neutral ScriptCode propagation is covered, but the removed HIR E2E
format test is not represented as equivalent Canonical coverage yet. That gap,
compiler HIR capture/storage, TypedASTJIT branches, diagnostics, Standalone HIR
tests and the remaining UE HIR oracles keep Task 10.5 open.

The literal task count remains **86/125 checked, 39 open** and the headline
stays **72%**; this bounded deletion reduces the retirement frontier without
completing the full HIR task or Canonical cutover. Detailed evidence and every
encountered issue:
`attachments/hir-editor-dump-retirement-gate-2026-08-27.md`.

## 2026-08-27 CTA-HIR-04 Canonical source-provenance retention

The generated-origin gap exposed by CTA-HIR-03 is now closed at the Canonical
ownership boundary. SourceManager owns copied neutral provenance ranges,
Parser/Sema source-session reuse verifies those ranges together with source
bytes/line mapping, and `ResolveSourceSpan` returns the authored/generated
chain. Optional Cache restore now preserves the same facts through
`ASTBodySidecar` V6; V5 is an explicit safe miss and malformed provenance does
not publish a partial source model.

This data is diagnostic-only. A permanent test proves two identical semantic
graphs with different authored anchors retain the same function record hash;
the sidecar payload/schema changes, but semantic function identity, stable type
identity and generation Runtime bindings do not.

Final evidence is Runtime/Editor build PASS, ASTBodySidecar **21/21**,
SourceManager **12/12**, neutral ownership **3/3**, real Preprocessor
provenance **2/2**, and Standalone **21/21**. The test suite still builds and
runs TypedSemanticIR, so Task 10.5 honestly remains open. Compiler HIR capture/
storage/accessors, TypedASTJIT compatibility, HIR-era diagnostics/tests and
Standalone wiring remain the deletion frontier.

The literal count remains **86/125 checked, 39 open** and the architecture-
weighted headline remains **72%**. Compiler default remains LEGACY, Cache V2
remains default-disabled, and native `asCScriptNode`/Parser/Builder/Compiler
remain retained. Full RED/GREEN, schema/identity boundaries and every command/
validation issue:
`attachments/canonical-source-provenance-retention-gate-2026-08-27.md`.

## 2026-08-27 CTA-HIR-05 compiler-capture deletion

The complete function-local `asCTypedSemanticIRBuilder` and its expression,
statement, call, control-flow, cleanup and publication hooks have been removed
from `as_compiler.h/.cpp`. This is a physical deletion of 3,763 implementation
lines and 23 header lines, not capture-default-off. Native `asCScriptNode`,
`asCBuilder`, `asCCompiler`, LEGACY selection, and later non-HIR compiler
fixes remain.

The first Runtime/Editor build reached a single compile failure in the old
ExprContext HIR carrier-field test. Restoring the deleted field would have
reintroduced HIR state, so the HIR-only test was removed. The rerun passed the
complete `AngelscriptProjectEditor Development` build. Compiler HIR scans and
`asCTypedSemanticIRBuilder` file scans are now zero.

Task 10.5 remains open because `asCTypedSemanticFunction`, ScriptFunction
storage/accessors, Engine capture configuration, TypedASTJIT legacy APIs,
diagnostic/Provider compatibility names, Standalone wiring, and old HIR tests
remain. Literal task count stays **86/125**, while architecture-weighted
progress advances conservatively to **73%**. Full evidence and issue record:
`attachments/typed-semantic-hir-compiler-capture-removal-gate-2026-08-27.md`.

## 2026-08-27 CTA-HIR-06 ownership/configuration/consumer migration RED

The next HIR retirement slice is implemented far enough to expose the true
consumer boundary. `asCScriptFunction` no longer owns or exposes a
`asCTypedSemanticFunction`; `asCScriptEngine` no longer exposes the HIR capture
switch/freeze state; UE Engine/ProjectSourceGraph/StaticJIT configuration no
longer writes that switch; Canonical snapshot retention is independent of it;
and restore no longer discards a donor HIR. The exact production configuration
and ownership scan for `bCaptureTypedSemanticIR`, the Engine setters/getters,
the frozen/config fields and ScriptFunction HIR accessors is zero under active
`Source` and `Standalone` inputs.

HIR-only SDK, TypedASTJIT control/conversion and Standalone tests have been
physically removed, while mixed Language/Cache tests keep their native syntax
and runtime assertions. The AOT test generator has begun moving its scalar
probe from `asCTypedSemanticFunction` to the retained Canonical snapshot and
DeclId.

The first full Runtime/Editor build is intentionally recorded as RED, not
waived:

`Saved/Build/cta-hir-delete-ownership-consumers-check/20260827_191004_450_41c70479/RunMetadata.json`

Result: exit 1, UBT `OtherCompilationError`, 194 scheduled actions with the XGE
executor draining to 171 completed actions after early failures. The failures
form three bounded repair groups:

1. one residual `VerifyTypedSemanticPowerShape` call in a mixed native Power
   test after its HIR-only helper was removed;
2. two valuable generation-isolation helpers
   (`AssertGenerationServicesSuppressed` and
   `AssertNoGenerationPersistence`) were accidentally removed with a large
   mixed historical HIR hunk and must be restored without restoring HIR;
3. AOT migration still contains wrong invocation/receiver enum spellings, an
   undefined old `HIR` emission input, and six
   `GetTypedSemanticCaptureDiagnostic` call sites whose formatting errors are
   secondary to the deleted accessor.

No Runtime compiler error currently indicates damage to the intentionally
retained native `asCScriptNode`/Parser/Builder/Compiler/LEGACY path. However,
`as_typed_semantic_ir.h/.cpp` and the production TypedASTJIT analyzer/emitter/
eligibility/dependency/call-closure compatibility contracts still exist, so
Task 10.5 remains open. Literal progress remains **86/125 (68.8%)** and the
architecture-weighted headline remains **73%** until this slice has a green UE
build, Standalone rerun and final forbidden-symbol/model deletion gates.

## 2026-08-27 CTA-HIR-06 ownership/configuration/consumer migration partial GREEN

The bounded failures above were repaired without restoring HIR. The mixed
Power test keeps native compile/runtime coverage but no longer invokes the
deleted HIR assertion. The two generation-isolation helpers were restored in
their non-HIR form. StaticJIT AOT generation now emits from the retained
Canonical snapshot/DeclId input; its first-version benchmark records Canonical
AST build time and working-set delta instead of the retired HIR capture phase.

The first repair build compiled but exposed four missing AOT public entry-point
definitions at link time; root cause was the same broad historical HIR reverse
hunk having removed non-HIR wrappers around `RunInternal`. The wrappers were
restored with Canonical benchmark semantics. Evidence:

- initial compilation RED:
  `Saved/Build/cta-hir-delete-ownership-consumers-check/20260827_191004_450_41c70479/RunMetadata.json`;
- repair-1 link RED:
  `Saved/Build/cta-hir-delete-ownership-consumers-fix1/20260827_192121_312_e77f830d/RunMetadata.json`;
- repair-2 Runtime/Editor GREEN:
  `Saved/Build/cta-hir-delete-ownership-consumers-fix2/20260827_192428_316_5f4ed604/RunMetadata.json`;
- Standalone Debug **20/20 PASS**:
  `Saved/StandaloneTests/cta-hir-delete-ownership-consumers_01_Standalone/20260827_192452_896_694636cf/RunMetadata.json`;
- native Power **3/3 PASS**:
  `Saved/Tests/cta-hir-delete-power-native/20260827_192631_967_77452e07/RunMetadata.json`;
- StaticJIT ProjectGeneration.Engine **32/32 PASS**:
  `Saved/Tests/cta-hir-delete-generation-engine/20260827_192711_399_07b38c33/RunMetadata.json`.

The exact ownership/configuration scan remains zero for
`bCaptureTypedSemanticIR`, Engine HIR capture/freeze state, and ScriptFunction
HIR accessors. This checkpoint is deliberately only partial GREEN:
`as_typed_semantic_ir.h/.cpp`, TypedASTJIT HIR overloads/model vocabulary and
HIR-named diagnostics still exist. Task 10.5 therefore remains open, as do the
AOT GenerationVerification/Benchmarks and CanonicalASTMigration focused gates.
The intentionally retained native `asCScriptNode`/Parser/Builder/Compiler and
explicit LEGACY pipeline are not deletion targets of this change.

## 2026-08-27 CTA-S-24 literal-expression typed action

The first expression family has crossed the actual Parser→Sema authority
boundary. Literal semantics now enter CANONICAL Sema through pointer-free
`asSLiteralExprAction` containing copied token kind, spelling and half-open
offsets. Sema owns decoding and typed Expr construction. Parser immediately
binds the returned exact `ExprId` while continuing to build the independent
native `snConstant` tree for explicit LEGACY compilation, syntax/recovery,
reference and rollback.

The old string-literal node adapter is deleted. The surviving
`ActOnExprFromNode(snConstant)` case is identity-only and fails closed if the
Parser action did not run; it cannot reconstruct literal meaning from the
native node. This is the intended transitional architecture: native syntax
retention is not permission for CANONICAL semantic replay.

The test sequence proves both boundaries: missing-action compile RED, real
Parser missing-identity runtime RED, direct action **1/1**, Parser identity
**1/1**, complete SemaAuthority **344/344**, retained native ScriptNode
**32/32**, ProductionCodeGen **114/114**, and two successful Runtime/Editor
builds. The initial CQTest selector mistakes and one per-worktree lock
rejection are recorded as non-evidence rather than hidden.

Task 4.2 remains open: decl-ref, call, unary/binary/assignment/conditional,
general statement/control/body/default/initializer/lifetime routes still have
node-replay work. Builder Runtime-shell narrowing, full-language CodeGen and
the default switch also remain open. Full gate card and report paths:
`attachments/canonical-literal-expression-typed-action-gate-2026-08-27.md`.

## 2026-08-27 CTA-S-25 declaration-reference typed action

The second leaf-expression family has crossed the Parser→Sema authority
boundary. Identifier and explicit-scope semantics now enter CANONICAL Sema
through pointer-free `asSDeclRefExprAction`, which owns the name, ordered scope
segments, leading-root-scope bit, current AST owner and half-open offsets.
Sema owns lexical/exact lookup, `this`, native-enum projection,
automatic-import projection, deferred references, diagnostics and typed Expr
construction. No native Parser node crosses this action boundary.

Parser still produces the independent `snVariableAccess` tree for explicit
LEGACY compilation, syntax/recovery, reference and rollback, and currently
copies the just-parsed grammar facts from that local node into the action. It
immediately binds the returned exact `ExprId`. The old
`InternParsedDeclRef` implementation is deleted and scans to zero; both
remaining Sema `snVariableAccess` cases are identity-only and fail closed with
`decl-ref-expression-action-missing`.

The TDD sequence has one honest compile-time RED (the action contract was
missing); both new tests were compiled together, so no separate Parser runtime
RED is claimed. Final evidence is direct action **1/1**, Parser identity
**1/1**, complete SemaAuthority **346/346**, ProductionCodeGen **114/114**,
native ScriptNode **32/32**, plus a successful Runtime/Editor build. The full
semantic matrix covers unqualified, relative and absolute explicit scopes,
while existing downstream cases retain `this`, native-enum, automatic-import,
deferred-name and executable behavior.

Task 4.2 remains open. Parser still has 18 general `ActOnParsedExpr` calls for
call/member/index/unary/binary/assignment/conditional work, followed by the
statement/control/body/default/initializer/lifetime families. Builder
Runtime-shell narrowing, full-language CodeGen and the default switch also
remain open. Full gate card and report paths:
`attachments/canonical-decl-ref-expression-typed-action-gate-2026-08-27.md`.

## 2026-08-27 CTA-S-26 conditional-expression typed action

The first composite-expression family now crosses the Parser→Sema boundary
without passing a native node. Parser builds `asSConditionalExprAction` from
three exact child ExprIds and copied offsets; Sema owns conditional conversion,
result-type selection and typed node construction. Parser binds the returned
parent identity while retaining native `snCondition` for explicit LEGACY,
syntax/recovery, reference and rollback.

This slice also corrected expression-identity architecture. The old recovery
lookup keyed by section+offset could return the first leaf for a parent that
began at the same offset. Exact-only lookup is now a distinct API, while
structural recovery additionally matches node kind and length. Composite
action construction uses only exact identities and fails closed on distinct
unmigrated descendants. A second RED exposed recovery timing: a malformed
enclosing call had all three exact conditional children, so Parser now
publishes the composite action on that path without replaying the node.

Final evidence is direct action **1/1**, Parser exact identity **1/1**,
recovery **1/1**, complete SemaAuthority **348/348**, exact differential
**1/1**, ProductionCodeGen **114/114**, retained native ScriptNode **32/32**,
and complete Canonical Semantics **12/12**. Parser `ActOnParsedExpr` calls fall
from **18** to **14**. Calls/member/index, cast/construct, unary/binary/
assignment, general statements/control/bodies/defaults/initializers/lifetimes,
Builder Runtime-shell narrowing, full CodeGen and default cutover remain open.
Task 4.2/5.2/5.4/10.6/13.2 are not checked by this slice. Full RED/GREEN,
both issue records and non-claims:
`attachments/canonical-conditional-expression-typed-action-gate-2026-08-27.md`.

## 2026-08-27 CTA-S-27 assignment-expression typed action

Complete assignment composites now cross the Parser→Sema boundary without
passing a native node. Parser builds `asSAssignExprAction` from exact left and
right ExprIds, an owned assignment-operator spelling and copied offsets. Sema
validates those facts and owns typed assignment construction. Parser binds the
returned parent identity while retaining native `snAssignment` for explicit
LEGACY, syntax/recovery, reference and rollback.

Both complete native-node Sema switches are identity-only and fail closed with
`assignment-expression-action-missing`; one-child grammar wrappers remain
transparent and two-child incomplete assignments do not synthesize semantics.
The initial action-contract build was RED. The pre-wiring Parser test was also
RED, but exposed that generic replay could still manufacture an exact-looking
assignment. Its permanent gate therefore asserts the exact AST and the
isolated `ParseAssignment` source boundary: dedicated action present, generic
`ActOnParsedExpr` absent.

Final evidence is direct action **1/1**, Parser exact/action **1/1**, complete
SemaAuthority **350/350**, ProductionCodeGen **114/114**, retained native
ScriptNode **32/32**, and complete Canonical Semantics **12/12**. Parser
`ActOnParsedExpr` calls fall from **14** to **12**. Property/index mutation
targets still depend on their unmigrated expression-term routes; binary/unary/
call/member/index/cast/construct, statements/control/bodies/defaults/
initializers/lifetimes, Builder Runtime-shell narrowing, full-language
CodeGen and default cutover remain open. Task 4.2/5.2/5.4/10.6/13.2 are not
checked by this slice. Full RED/GREEN, CTA-S27-I1 and non-claims:
`attachments/canonical-assignment-expression-typed-action-gate-2026-08-27.md`.

## 2026-08-27 CTA-S-28 binary-expression typed action

Complete flat binary/logical composites now cross the Parser→Sema boundary
without passing a native node. Parser builds `asSBinaryExprAction` from
ordered exact operand ExprIds, copied operator token/spelling pairs and the
complete source range. Sema validates those facts, owns the maintained fork's
precedence/left-associativity fold, selects logical versus ordinary binary
construction, and returns the exact parent identity. Parser retains the flat
`snExpression` tree independently for explicit LEGACY, syntax/recovery,
reference and rollback.

Both complete native-node Sema switches are identity-only and fail closed with
`binary-expression-action-missing`. The initial action-contract build was RED.
The pre-wiring Parser gate was also RED even though generic replay had already
created an exact-looking precedence tree; the permanent test therefore checks
both AST facts and the isolated `ParseExpression` source boundary. This is the
same false-green class found in CTA-S27 and is recorded as CTA-S28-I1.

Initial evidence was direct action **1/1**, Parser exact/action **1/1**,
SemaAuthority **352/352**, ProductionCodeGen **114/114**, complete Canonical
Semantics **12/12**, and retained native ScriptNode **32/32**. Parser
`ActOnParsedExpr` calls fall from **12** to **10**.

The bounded CTA-S28-I2 review edge is now resolved. A corrected nonzero-offset
fixture reproduced **0/1** outer-fold aliasing for range-less `1 + 2 + 3`.
Binary reuse was moved after conversion normalization and now requires exact
left/right child identities as well as kind/range/operator. Focused is **1/1**,
final SemaAuthority is **353/353**, ProductionCodeGen remains **114/114**, and
Canonical Semantics remains **12/12**. The initial offset-zero **1/1** probe is
explicitly non-evidence because interning is disabled at that offset.

Unary/prefix/postfix and expression-term call/member/index/cast/construct
routes remain, followed by statements/control/bodies/defaults/initializers/
lifetimes, Builder Runtime-shell narrowing, complete detached CodeGen/AOT and
the final default cutover. Task 4.2/5.2/5.4/10.6/13.2 remain unchecked. Full
RED/GREEN paths, precedence contract and non-claims:
`attachments/canonical-binary-expression-typed-action-gate-2026-08-27.md`.

## 2026-08-28 CTA-S-29 unary-expression typed action

The pointer-free unary action contract is implemented. `asSUnaryExprAction`
carries one exact operand identity, ordered owned prefix/postfix operator facts
and one copied half-open source range. Sema applies postfix operators forward
and prefixes in reverse, so `-~Value++` seals as outer `-`, then `~`, then
`post++`, then the exact `Value` declaration reference.

The first action build was a valid missing-API RED. The first behavioral run
then exposed a real interning defect: nested unary stages share the complete
term range, while the old lookup reused by range before checking operator and
child. Unary and overloaded-unary-call reuse now also require their exact
operator/callee/receiver/child identities. The repair build is green and the
direct action gate is **1/1 PASS**.

Parser now classifies pure unary versus structural postfix terms, builds the
action from the exact primary identity, copies ordered operator facts, and
binds the returned parent identity. `InternParsedExprTerm` accepts pure unary
syntax only through that exact binding, so declaration prewalk and expression
adaptation cannot recover the semantics by replaying the native node. The
retained `snExprTerm` shape remains unchanged for syntax/recovery and explicit
LEGACY.

Final evidence is Parser exact/action **1/1**, complete SemaAuthority
**355/355**, ProductionCodeGen **114/114**, Canonical Semantics **12/12**,
retained native ScriptNode **32/32**, and a successful Runtime/Editor build.
Parser generic callbacks fall from **10** to **9**.

Consequently `tasks.md` remains **87/125 (69.6%)**, weighted engineering
progress remains **about 66%**, and default-cutover readiness remains **about
38%**. Cast/construct/call/member/index, then statements/control/bodies/
defaults/initializers/lifetimes, detached CodeGen/AOT and final default cutover
remain. Full evidence, CTA-S29-I1/I2 and non-claims:
`attachments/canonical-unary-expression-typed-action-gate-2026-08-28.md`.

## 2026-08-28 CTA-S-30 explicit-cast typed action

Explicit `Cast<T>(expr)` now crosses a pointer-free `asSCastExprAction` with
the exact Parser-resolved target QualType, exact operand ExprId and copied
range. Complete native `snCast` adaptation is identity-only and fails closed
with `cast-expression-action-missing`; the retained syntax tree remains
available to LEGACY and recovery/reference tests.

Final evidence is direct action **1/1**, Parser action **1/1**,
SemaAuthority **357/357**, ProductionCodeGen **114/114**, Canonical Semantics
**12/12** and native ScriptNode **32/32**. Parser generic callbacks fall from
**9** to **6**. The maintained fork's `floatIsFloat64` setting invalidated an
initial float-versus-double test oracle; the corrected fixture compares
explicit `float32` against configured `float64`. Full evidence and issue
record: `attachments/canonical-cast-expression-typed-action-gate-2026-08-28.md`.

## 2026-08-28 CTA-S-31 construct-expression typed action

The complete native `TYPE ARGLIST` boundary now publishes through
`asSConstructExprAction`, carrying only the exact Parser-resolved target
QualType, ordered exact positional argument ExprIds and copied half-open
source range. Sema seals primitive/enum functional casts as `Conversion`; an
object target seals the selected `Construct` together with the existing
materialization and cleanup plan. Complete `snConstructCall` handling no
longer re-reads its target or argument subtree and is identity-only with the
deterministic `construct-expression-action-missing` diagnostic.

The initial missing-API build and pre-wiring Parser source-boundary test were
valid REDs. A direct class fixture also exposed a test-contract mistake:
`ActOnClassDecl` does not promise an expression-ready `Decl::type`, so the
fixture now independently interns the canonical named value type. One test
runner invocation omitted the test class and selected zero tests; it is
explicitly recorded as non-evidence.

Final evidence is direct action **1/1**, Parser action **1/1**,
SemaAuthority **359/359**, ProductionCodeGen **114/114**, Canonical Semantics
**12/12** and retained native ScriptNode **32/32**. Parser generic callbacks
fall from **6** to **5**. Named constructor arguments intentionally fail
closed until the complete call-plan action owns their names and formal/source
origin mapping; there is no generic native-tree fallback.

`tasks.md` therefore remains **87/125 (69.6%)** because the affected items are
larger umbrella tasks. The conservative weighted estimate remains **about
66%**, while default-CANONICAL cutover readiness remains **about 38%**. The
next authority slices are ordinary calls, member/index/call postfix chains and
initializer lists, followed by statements/control/body/default/lifetime
closure, detached backend/AOT closure and final product cutover. Full evidence
and non-claims:
`attachments/canonical-construct-expression-typed-action-gate-2026-08-28.md`.

## 2026-08-28 CTA-S-32 ordinary-call typed action

Standalone ordinary source calls now cross `asSCallExprAction`. The action
owns a copied callee name, copied scope segments/absolute-scope bit, lexical
owner, optional exact receiver, ordered positional/named exact arguments and
the copied half-open range. Sema retains authority over scope/declaration
projection, overload selection, conversions, source-to-formal arrangement,
default/hidden synthesis, deferred lookup, dispatch and materialization.

`ParseFunctionCall(notifySema=true)` publishes and binds the action. Complete
standalone `snFunctionCall` handling is identity-only; the retained native
tree stays available to LEGACY and syntax/recovery/reference tests. Member,
index and postfix-call chains still use their structural receiver adapter and
are explicitly outside this slice.

The broad gate exposed two useful edges. An offset-zero snippet fixture had
never established a TranslationUnit and was corrected without weakening the
action owner contract. `FValue(` also exposed Parser's empty trailing
ArgList recovery shell; only a final shell with no authored token is now
omitted, preserving the recognized zero-argument construct/lifetime prefix
without accepting malformed authored arguments.

Final evidence is direct action **1/1**, Parser action **1/1**, focused
recovery **2/2**, SemaAuthority **361/361**, ProductionCodeGen **114/114**,
Canonical Semantics **12/12** and retained native ScriptNode **32/32**. Parser
generic callbacks fall from **5** to **4**. Full RED/GREEN paths and
non-claims:
`attachments/canonical-ordinary-call-expression-typed-action-gate-2026-08-28.md`.

No umbrella checkbox is independently complete, so `tasks.md` remains
**87/125 (69.6%)**. The conservative weighted estimate remains **about 66%**
and default-CANONICAL readiness remains **about 38%**. The next authority
slice is the ordered member/index/postfix chain, followed by initializer
lists, statement/body/default/lifetime closure, detached backend/AOT closure
and final cutover.

## 2026-08-28 CTA-S-33 structural postfix expression typed action

The ordered member/index/postfix family now crosses one pointer-free
`asSStructuralPostfixExprAction`. Parser supplies the exact base ExprId,
copied prefix operators, ordered member/member-call/index/postfix-call/unary
steps, copied scopes/names, exact positional/named argument identities and
half-open source extents. Sema applies those stages in source order and makes
each stage own its immediately preceding receiver/base, so the final graph no
longer uses a replay-created Sequence that can evaluate the receiver twice.

Index AST/Sema now retain every authored argument and select `opIndex`
against the complete vector. Current Canonical Bytecode emission still owns
only the single-index-argument ABI. Multi-argument shapes now fail closed in
CodeGen instead of silently emitting only the first argument; complete ABI
emission remains an explicit Tasks 9.5/9.7 blocker.

The structural `InternParsedExprTerm` route is identity-only.
`InternParsedCall`, `SameSealedReceiverExpression` and
`TransparentCallResultOwnsReceiver` have been physically removed. Three
tests that directly depended on the deleted replay API were migrated to the
typed-action boundary rather than restoring the bridge. The retained native
`asCScriptNode` AST still passes all **32/32** ScriptNode tests and remains
available to LEGACY, syntax/recovery, reference and rollback workflows.

Final evidence is:

- successful implementation/test build at
  `Saved/Build/cta-s33-structural-focused-test-adjust-build/20260828_015421_147_72a4248e/RunMetadata.json`;
- focused structural and migrated-call boundary **4/4 PASS** at
  `Saved/Tests/cta-s33-structural-replay-removed-focused-green/20260828_015442_280_b331932a/RunMetadata.json`;
- SemaAuthority **363/363 PASS** at
  `Saved/Tests/cta-s33-sema-authority-full/20260828_015516_422_678286dc/RunMetadata.json`;
- ProductionCodeGen + Canonical Semantics + native ScriptNode **158/158
  PASS** at
  `Saved/Tests/cta-s33-secondary-gates/20260828_015610_290_828aafc9/RunMetadata.json`.

Parser generic expression callbacks fall from **4** to exactly **2**; both
remaining sites are initializer-list publication. No large umbrella task is
fully closed, so the mechanical ratio stays **87/125 (69.6%)**. The weighted
engineering estimate advances conservatively from about 66% to **about 67%**,
and safe default-CANONICAL readiness from about 38% to **about 39%**. The next
authority slice is initializer-list typed actions, followed by declaration/
statement/control/body/default/lifetime closure, detached backend and direct
AST AOT closure, entry-point coverage and the final default-switch matrix.

Full RED/GREEN chronology, encountered issues and non-claims are recorded in
`attachments/canonical-structural-postfix-expression-typed-action-gate-2026-08-28.md`
and `attachments/final-completion-issue-log-2026-08-27.md`.

## 2026-08-28 CTA-S-34 initializer-list expression typed action

The final generic expression publication family now crosses a copied,
pointer-free `asSInitListExprAction`. It carries optional explicit target type,
ordered exact scalar/nested element identities, explicit omitted and trailing
separator facts, copied source extents and recovery state. Sema owns exact
structural interning, contextual target/list-factory selection and deterministic
diagnostics. Complete `snInitList` consumption is exact-identity-only.

Production Parser/Sema now contains zero `ActOnParsedExpr` calls,
declarations or implementations. This does not delete the native AngelScript
AST/compiler: `ParseInitList`, `snInitList`, `asCScriptNode`, Builder,
`asCCompiler` and explicit LEGACY remain for syntax/recovery, reference,
differential and rollback use.

CTA-S34 also records two bounded backend gaps. A middle omitted/default element
is accepted by native Parser/LEGACY but has no durable Canonical default-element
form, so CANONICAL diagnoses and fails closed. Nested list structure is durable
in AST, but `EmitListFactoryInto` remains a flat repeat-element emitter; nested,
repeat-same, wildcard/default-constructor and default-element lowering are not
claimed complete.

Final evidence is:

- build green at
  `Saved/Build/cta-s34-empty-trailing-build/20260828_024521_626_841da958/RunMetadata.json`;
- typed/nested/omitted/recovery focus **6/6 PASS** at
  `Saved/Tests/cta-s34-init-list-typed-action-focused-green/20260828_023334_744_3f274e52/`;
- empty/trailing-comma focus **1/1 PASS** at
  `Saved/Tests/cta-s34-empty-trailing-focused/20260828_024610_888_9d872f50/`;
- final SemaAuthority **367/367 PASS** at
  `Saved/Tests/cta-s34-sema-authority-final/20260828_024644_205_2744a5b8/`;
- ProductionCodeGen + Canonical Semantics + retained native ScriptNode
  **158/158 PASS** at
  `Saved/Tests/cta-s34-secondary-gates/20260828_023808_987_62671a34/`;
- strict OpenSpec validation and parent/plugin `git diff --check` pass, with
  only existing line-ending conversion warnings.

No umbrella checkbox is independently complete, so `tasks.md` remains
**87/125 (69.6%)**. Weighted engineering completion advances to **about 68%**
and safe default-CANONICAL readiness to **about 40%**. The next authority slice
is declaration adapters plus statement/control/body/default/local-initializer/
lifetime typed actions, followed by detached backend and direct AST AOT closure,
entry-point coverage and the final default-switch matrix.

## 2026-08-28 CTA-S-35 parameter-default typed action

Parameter defaults now cross `asSParameterDefaultAction` with the exact
parameter DeclId, exact already-published default ExprId, copied authored text,
copied half-open source range and explicit recovery state. Sema validates those
facts before mutation, preserves exact AST identity, makes identical repeat
publication idempotent and rejects conflicting rebinding deterministically.

`ActOnParameterDefaultFromNode` and `InternParamDefaultExpr` have been
physically removed from production. The native `ParseParameterList`, parameter
syntax tree, Builder, compiler and explicit LEGACY route remain intentionally
available. Where a transparent native wrapper has no root identity, Parser
accepts only one distinct exact action-published descendant; it does not replay
or reconstruct semantics from the node.

Evidence is:

- expected missing-action RED build at
  `Saved/Build/cta-s35-parameter-default-action-red/20260828_030212_578_f76fb518/RunMetadata.json`;
- GREEN build at
  `Saved/Build/cta-s35-parameter-default-action-build-1/20260828_030308_552_8be50a61/RunMetadata.json`;
- focused boundary **5/5 PASS** at
  `Saved/Tests/cta-s35-parameter-default-focused-1/20260828_030345_602_e55d66b8/RunMetadata.json`;
- full SemaAuthority **369/369 PASS** at
  `Saved/Tests/cta-s35-sema-authority-full/20260828_030901_427_dc0780de/RunMetadata.json`;
- ProductionCodeGen + Canonical Semantics + retained native ScriptNode
  **158/158 PASS** at
  `Saved/Tests/cta-s35-secondary-gates/20260828_031012_497_2e89fcdd/RunMetadata.json`;
- production source scan, strict OpenSpec validation and parent/plugin
  `git diff --check` pass, with only existing line-ending warnings.

No umbrella checkbox is complete, so `tasks.md` remains **87/125 (69.6%)**.
The rounded estimates remain **about 68%** overall and **about 40%** safe
default-cutover readiness. Next is the enumerator-initializer action, followed
by global/local initializers, function/lambda bodies, statement/control and
lifetime closure.

## 2026-08-28 CTA-S-36 enumerator-initializer typed action

Explicit enum values now cross `asSEnumeratorInitializerAction` with the exact
enumerator DeclId, exact already-published ExprId, copied half-open offsets and
recovery state. Sema owns enum validation and integer constant evaluation,
publishes the exact Binary/Unary root once, freezes the value, and rejects a
conflicting rebind without changing the AST.

`ActOnEnumeratorInitializerFromNode` is physically removed. Native
`ParseEnumeration`, `snEnum`, Builder, `asCCompiler` and LEGACY remain. The
fail-closed test proves a non-constant expression binds no init and does not
replace the provisional implicit value.

Evidence is GREEN build, focused **5/5**, SemaAuthority **372/372**, and
ProductionCodeGen + Canonical Semantics + retained ScriptNode **158/158**:

- `Saved/Build/cta-s36-enumerator-initializer-action-build-1/20260828_032815_893_e41d6703/RunMetadata.json`;
- `Saved/Tests/cta-s36-enumerator-initializer-focused-1/20260828_033053_206_642701dd/RunMetadata.json`;
- `Saved/Tests/cta-s36-sema-authority-full/20260828_033127_151_a58b2e2a/RunMetadata.json`;
- `Saved/Tests/cta-s36-secondary-gates/20260828_033306_170_a3661f8d/RunMetadata.json`.

Source scan, strict OpenSpec validation and both diff checks pass; only existing
line-ending conversion warnings are reported. `tasks.md` remains **87/125
(69.6%)**, with **about 68%** weighted implementation and **about 40%** safe
default readiness. Next is the variable initializer/declarator action family.

## 2026-08-28 CTA-S-37 global/field variable-initializer typed action

Global and field declarators now finish through `asSVariableInitializerAction`.
The copied action distinguishes no initializer, an exact expression, and direct
construction with ordered exact arguments. Sema owns default-global policy,
constant evaluation, construction, init attachment and conflict handling.

The obsolete `ActOnVariableInitializerFromNode` plus `IntegerInitText`,
`FindConstantNode` and `CanonicalNodeText` native-tree helpers are physically
removed. Native declarations and LEGACY remain. Global constants retain both
their exact source expression and normalized constant facts; fields use only
their exact init expression. This fixes the former `40 + 1` versus `"40"`
field-text ambiguity.

Current general direct/dynamic global construction remains unsupported in the
prepared backend and fails closed; only scalar constants and no-initializer
value-object lifecycle publication are claimed.

Evidence is:

- GREEN build:
  `Saved/Build/cta-s37-global-field-initializer-action-build-1/20260828_034552_765_b67da432/RunMetadata.json`;
- focused **5/5 PASS**:
  `Saved/Tests/cta-s37-global-field-initializer-focused-1/20260828_034621_430_e881b7ab/RunMetadata.json`;
- SemaAuthority **374/374 PASS**:
  `Saved/Tests/cta-s37-sema-authority-full/20260828_034801_064_994333d8/RunMetadata.json`;
- downstream **158/158 PASS**:
  `Saved/Tests/cta-s37-secondary-gates/20260828_034910_266_235b8461/RunMetadata.json`.

Strict OpenSpec and both diff checks pass. Mechanical progress stays **87/125
(69.6%)**; weighted implementation advances to **about 69%** and safe default
readiness to **about 41%**. Next is local declarator/statement publication.

## 2026-08-28 CTA-S-38 local-variable declarator typed action

Local declarators now cross `asSLocalVariableDeclaratorAction`. The copied
action distinguishes no initializer, one exact expression and direct
construction with ordered exact arguments. Sema validates the local owner and
source range, rejects missing/conflicting identities before mutation, attaches
the exact init and publishes DeclStmt plus initialization/default-construction
effects in source order.

`ActOnLocalVariableDeclaratorFromNode` and its recursive expression/argument
replay are physically removed. `ActOnLocalVariableDeclarationAction` still
finishes the exact statement sequence after the semicolon and is also used for
`for` initializer declarations. Native `ParseDeclaration`, `asCScriptNode`,
Builder, `asCCompiler` and LEGACY remain intentionally available.

Evidence is:

- expected RED build:
  `Saved/Build/cta-s38-local-variable-declarator-action-red/20260828_035341_491_57ad8492/RunMetadata.json`;
- GREEN build:
  `Saved/Build/cta-s38-local-variable-declarator-action-build-1/20260828_035511_594_854d28f9/RunMetadata.json`;
- focused **5/5 PASS**:
  `Saved/Tests/cta-s38-local-variable-declarator-focused-1/20260828_035549_358_72281f8f/RunMetadata.json`;
- SemaAuthority **376/376 PASS**:
  `Saved/Tests/cta-s38-sema-authority-full/20260828_035621_161_913fc474/RunMetadata.json`;
- downstream **158/158 PASS**:
  `Saved/Tests/cta-s38-secondary-gates/20260828_035704_811_146d04ff/RunMetadata.json`.

The action does not claim complete value-object transfer cleanup; that remains
with function/body, statement/control, lifetime and CodeGen closure. Mechanical
progress stays **87/125 (69.6%)**. Weighted implementation advances to **about
70%**, safe default readiness to **about 42%**, and the action-only Sema slice
to **about 83%**.

## 2026-08-28 CTA-S-39 callable-body typed action

Functions and lambdas now attach their top-level Block through
`asSFunctionBodyAction`: exact callable DeclId, exact Block StmtId, copied body
range and recovery state. Sema requires exact callable ownership and range,
publishes the function-entry safe point, records lambda captures, makes exact
repeat publication idempotent and rejects a conflicting body.

`ActOnFunctionBodyFromNode` and `AttachParsedFunctionBody` are physically
removed. Parser temporarily locates the already-published Block through one
exact pointer-free kind/owner/full-range identity query. Native function/lambda
and statement blocks remain intact for syntax/recovery and LEGACY.

Evidence is:

- RED build:
  `Saved/Build/cta-s39-callable-body-action-red/20260828_040227_654_1cfcbe29/RunMetadata.json`;
- GREEN build:
  `Saved/Build/cta-s39-callable-body-action-build-1/20260828_040338_590_657cee75/RunMetadata.json`;
- focused **5/5 PASS**:
  `Saved/Tests/cta-s39-callable-body-focused-1/20260828_040415_969_e7b03368/RunMetadata.json`;
- SemaAuthority **377/377 PASS**:
  `Saved/Tests/cta-s39-sema-authority-full/20260828_040448_487_74f276ad/RunMetadata.json`;
- downstream **158/158 PASS**:
  `Saved/Tests/cta-s39-secondary-gates/20260828_040528_980_773ab9fc/RunMetadata.json`.

The generic statement/control node adapters are still production authority;
this slice closes only callable attachment. Status is **87/125 (69.6%)**,
**about 70%** weighted, **about 43%** safe default readiness and **about 85%**
action-only Sema.

## 2026-08-28 CTA-S-40 leaf-statement typed action

Expression statements, returns, break, continue and fallthrough now cross
`asSLeafStatementAction`: bounded kind, exact callable owner, optional exact
ExprId, copied source range and recovery state. Parser publishes the action on
success and missing-semicolon recovery paths without `ActOnParsedStmt`.

Return numeric conversion and value-object transfer cleanup moved out of
`ActOnStmtFromNode(snReturn)` into the typed action. Break and continue freeze
the current exact control target. All five leaf semantic cases are physically
removed from `ActOnParsedStmt` and `ActOnStmtFromNode`; residual compound/
control assembly may only locate an already-published exact leaf.

Evidence is:

- RED build:
  `Saved/Build/cta-s40-leaf-statement-action-red/20260828_042359_594_ed002795/RunMetadata.json`;
- GREEN build:
  `Saved/Build/cta-s40-leaf-statement-action-build-1/20260828_042950_057_df31c8f8/RunMetadata.json`;
- focused **17/17 PASS**:
  `Saved/Tests/cta-s40-leaf-statement-focused-1/20260828_043105_617_a0176912/RunMetadata.json`;
- SemaAuthority **380/380 PASS**:
  `Saved/Tests/cta-s40-sema-authority-full/20260828_043211_489_19dc3dba/RunMetadata.json`;
- downstream **158/158 PASS**:
  `Saved/Tests/cta-s40-secondary-gates/20260828_043254_834_fc203488/RunMetadata.json`.

Control stack setup and Block ordered-child assembly still use native identity
adapters, so no umbrella task closes. Status is **87/125 (69.6%)**, **about
71%** weighted, **about 44%** safe default readiness and **about 88%**
action-only Sema. Next is Block/If typed assembly.

## 2026-08-28 CTA-S-41 Block/If typed actions

Statement blocks and `if` statements now cross pointer-free typed actions.
Block carries exact ordered child `StmtId`s plus explicit local-declaration
sequence carriers; If carries the exact condition `ExprId` and exact
then/else `StmtId`s. Parser keeps a short-lived native-node-to-`StmtId` table
only as local construction state, so no native pointer crosses into Sema.

`ParseStatementBlock` and `ParseIf` no longer call `ActOnParsedStmt`, and the
completed Block/If semantic cases are absent from `ActOnParsedStmt` and
`ActOnStmtFromNode`. Native AST construction is retained for syntax, recovery,
LEGACY and reference testing. The remaining native Block/If kind mappings in
`StmtKindForNode` / `InternParsedCompoundStmt` are transitional identity
routing, not CANONICAL semantic replay.

The first full SemaAuthority run exposed 15 old-control regressions because a
loop/switch adapter publishes a stub before its body, so its end range grows.
The temporary bridge now resolves only the unique kind/owner/file/start
identity. This is sufficient for typed Block/If assembly, but CTA-S42 must
replace the remaining loop/switch adapters and delete the bridge.

Evidence is:

- expected RED build:
  `Saved/Build/cta-s41-block-if-action-red/20260828_044017_644_ac43e42f/RunMetadata.json`;
- GREEN build:
  `Saved/Build/cta-s41-block-if-action-build-1/20260828_044650_219_0abe8008/RunMetadata.json`;
- focused **8/8 PASS**:
  `Saved/Tests/cta-s41-block-if-focused-1/20260828_044906_752_d3f227de/RunMetadata.json`;
- initial SemaAuthority **368/383**, exposing the bounded control-identity
  regression:
  `Saved/Tests/cta-s41-sema-authority-full-1/20260828_045019_544_b56efd19/RunMetadata.json`;
- repair build and failed-case recheck **15/15 PASS**:
  `Saved/Build/cta-s41-control-identity-build-2/20260828_045753_104_779a640c/RunMetadata.json`,
  `Saved/Tests/cta-s41-regression-recheck-2/20260828_045823_738_4a97ef96/RunMetadata.json`;
- final SemaAuthority **383/383 PASS**:
  `Saved/Tests/cta-s41-sema-authority-full-2/20260828_045902_938_7e975366/RunMetadata.json`;
- downstream **158/158 PASS**:
  `Saved/Tests/cta-s41-secondary-gates/20260828_045948_830_f9ca48a3/RunMetadata.json`.

No umbrella row closes: `tasks.md` remains **87/125 (69.6%)**. The current
estimate is **about 72%** weighted implementation, **about 45%** safe default
readiness and **about 91%** action-only Sema. Next is typed control actions for
loops/foreach/switch/case, followed by lifetime/cleanup closure.

## 2026-08-28 CTA-S42 partial checkpoint: loop/foreach typed actions

`while`, `do-while`, `for` and `foreach` now use a pointer-free two-phase
control contract. The header action creates and pushes the exact control
`StmtId` before the body, nested break/continue actions bind that identity, and
the family-specific finish action fills the same statement with exact
condition/range/body/phase IDs and its complete source range.

For loops preserve every increment expression in authored order; Sema builds
the named increment ExprStmt and a `SequenceExpr` when required. Foreach
variables now bind the exact result of `ActOnForeachVariableAction` back into
Parser-local construction state, while Sema retains full protocol/lifetime
authority. `ActOnForStmtFromNode` is physically deleted, and `snFor`/
`snForEach` are absent from both generic semantic statement adapters.

Fresh evidence is:

- while/do-while focused **12/12 PASS** and SemaAuthority **386/386 PASS**;
- for/foreach new contract **3/3 PASS** and focused regressions **10/10 PASS**;
- final complete SemaAuthority **389/389 PASS**;
- successful incremental Runtime/Editor build.

Exact reports, the expected RED builds and the one resolved broad-rebuild
timeout are recorded in
`attachments/canonical-loop-foreach-typed-action-gate-2026-08-28.md`.

CTA-S42 remains partial because `switch/case/default` still use native-node
adapters and the temporary start-coordinate identity bridge. Mechanical
progress therefore remains **87/125 (69.6%)**. The current overall weighted
implementation estimate is **about 73%**, safe default readiness **about 46%**
and action-only Sema **about 95%**. The default remains LEGACY.

## 2026-08-28 CTA-S42 completion checkpoint: switch/case typed actions

`switch`, `case` and `default` now cross Parser-to-Sema as pointer-free typed
actions. The switch header publishes the exact control StmtId before case
parsing; every case/default carries its exact optional value and ordered child
StmtIds; switch finish validates exact parentage/order and wires fallthrough to
the exact next case. Completed `snSwitch`/`snCase` semantics are physically
absent from both generic native-node semantic adapters.

This closes the temporary control-identity transition: `BeginParsedControl`
and the kind/owner/file/start `FindStatementActionIdentity` lookup are
physically removed. Native AngelScript AST construction remains intentionally
available for syntax/recovery, LEGACY, reference and differential use.

Evidence is GREEN build, new **3/3**, control regression **10/10**, complete
SemaAuthority **392/392**, and downstream ProductionCodeGen + Canonical
Semantics + retained ScriptNode **158/158**, all PASS. The first implementation
build exposed and then removed a default-only C++ switch left after the old
semantic cases were deleted. Full evidence and decisions are in
`attachments/canonical-switch-case-typed-action-gate-2026-08-28.md`.

No umbrella task includes lifetime and backend closure yet, so `tasks.md`
remains **87/125 (69.6%)**. The current conservative estimates are **about
74%** weighted implementation, **about 47%** safe default-cutover readiness
and **about 98%** action-only Sema authority. Next is explicit lifetime/cleanup
and uncommon body closure, then detached CodeGen/runtime relocation and direct
TypedASTJIT/AOT consumption. The default remains LEGACY.

## 2026-08-28 CTA-S43 native Sema replay-adapter retirement

The generic completed-native-node semantic replay boundary has now been
physically removed from CANONICAL Sema. `ActOnExprFromNode`,
`InternParsedExprTerm`, `ActOnStmtFromNode`, `InternParsedChildStmt`,
`InternParsedCompoundStmt` and `ActOnParsedStmt` no longer exist in production
Parser/Sema source. Native `asCScriptNode` construction remains intentionally
retained for syntax/recovery, explicit LEGACY compilation, reference and
differential testing.

The source-contract gate deliberately proves both facts: Parser must still
contain native AST construction, while Sema must not contain any of the six
replay entry points. Older method-slice tests were strengthened because a
deleted method could otherwise produce an empty slice and pass falsely. The
complete SemaAuthority gate is now **393/393 PASS**, and ProductionCodeGen +
Canonical Semantics + retained native ScriptNode is **158/158 PASS**.

This closes the generic expression/statement adapter boundary but not every
temporary Parser-node identity input. Declaration/type/scope construction
still has bounded build-time identity and lexical helpers, and explicit
lifetime/cleanup remains the next semantic critical path. Full evidence and
the encountered CQTest/source-contract issues are recorded in
`attachments/canonical-native-sema-replay-adapter-retirement-gate-2026-08-28.md`.

No umbrella task closes, so `tasks.md` remains **87/125 (69.6%)**. The current
conservative estimates are **about 75%** weighted implementation, **about
48%** safe default-cutover readiness and **about 98%** whole-Sema action-only
authority. The default remains LEGACY.

## 2026-08-28 CTA-S44 lexical value-object cleanup plans

Initialized direct lexical value-object locals with an exact Canonical
destructor now seal explicit `scope-exit` cleanup statements. Normal block
exit and block-leaving return/break/continue/fallthrough paths own distinct
cleanup identities in reverse declaration order; nested early returns observe
inner-to-outer destruction. Canonical CodeGen consumes these children and
marks only the normal-path object state dead, preventing epilogue double
destruction without corrupting alternate CFG paths.

The verifier rejects a missing/wrong destructor, malformed target or stable
type-owner mismatch. The production execution fixture returns `42` on early
and normal routes while observing three constructions and exactly three
destructions. The first full ProductionCodeGen run exposed a real detached-
artifact gap: Sema-generated script destructors had declarations but no
prepared Runtime shell. Generated accessors and destructors are now staged and
published atomically, and the strengthened regression directly proves the
entry bytecode calls the published `asBEHAVE_DESTRUCT` function.

Final gates are SemaAuthority **394/394**, ProductionCodeGen **115/115**, and
ProductionCodeGen + Canonical Semantics + retained native ScriptNode **159/159
PASS**. Exact RED/GREEN paths, the **114/115** diagnostic regression and the
two invalid test selections are recorded in
`attachments/canonical-lexical-value-cleanup-plan-gate-2026-08-28.md`.

Tasks 5.7/5.8 remain open for owning handle/reference, deferred/out, global,
exception, suspend/resume and full transfer breadth. Source typedef is
primitive-only and therefore is not a value-object lifetime blocker.
Mechanical progress therefore stays
**87/125 (69.6%)**. Weighted implementation advances conservatively to **about
76%**, safe default readiness to **about 49%**, and whole-Sema action-only
authority remains **about 98%**. The default remains LEGACY.

## 2026-08-28 CTA-S45 lexical owning-reference release plans

Initialized direct lexical `ReferenceObject` and `FuncDef` locals now share
the explicit block-lifetime stack introduced by CTA-S44. Sema seals a
destructor-free `scope-release` expression with one exact local `DeclRef` for
normal block exit and for each block-leaving return/break/continue/
fallthrough. Reverse declaration order is preserved across nested blocks and
mixed owning locals.

The ownership rule deliberately does not require `IsHandle()`. This fork's
implicit-handle local is represented in Canonical AST as `ReferenceObject`
with qualifier mask zero; only a true `REFERENCE` qualifier denotes the
non-owning form. The verifier rejects borrowed targets and any forged
destructor binding. Canonical CodeGen resolves the current generation-local
Runtime type, emits `asBC_FREE` and `asOBJ_UNINIT`, and retires only the
normal-path object directory entry. Transfer copies do not mutate global
compile-time liveness, so alternate CFG routes remain valid and the common
epilogue cannot double release.

Fresh gates are build PASS, focused Sema **1/1**, execution **1/1**, verifier
**29/29**, complete SemaAuthority **388/388**, complete ProductionCodeGen
**111/111**, and ProductionCodeGen + Semantics + retained native ScriptNode
**160/160 PASS**. The execution fixture proves early and normal routes each
destroy exactly one native ref object, leave zero live objects, use the
Canonical publisher and invoke LEGACY zero times. Exact RED/GREEN evidence and
the initial invalid implicit-handle qualifier assumption are recorded in
`attachments/canonical-lexical-owning-release-plan-gate-2026-08-28.md`.

No lifetime umbrella task is fully closed: deferred/out, template/container,
global, exception, suspend/resume, capture ownership and direct AOT cleanup
remain. Mechanical progress stays **87/125 (69.6%)**. Weighted implementation
advances conservatively to **about 77%**, Canonical Bytecode/Runtime closure to
**about 73%**, safe default readiness to **about 50%**, direct AST AOT remains
**about 55%**, and whole-Sema action-only authority remains **about 98%**. The
default remains LEGACY; native `asCScriptNode` remains retained and HIR remains
deleted.

## 2026-08-28 CTA-S46 funcdef default-null lifetime fact

The CANONICAL local-declaration action now represents an unannotated valid
implicit-handle funcdef local as initialized null rather than leaving its
`Decl.inits` empty. It creates a direct `NullLiteral`, publishes it on the
declaration, emits the assignment, and lets the established lexical ownership
route seal normal and transfer `scope-release` plans. The verifier now fails a
release targeting an uninitialized owning declaration with the stable
`scope-release-cleanup-uninitialized` diagnostic. Canonical CodeGen consumes
the sealed plan through its existing null-store and `FREE` + `UNINIT` path.

The clean REDs prove the missing direct null initializer/release plans after
both frontends accept the same `asOBJ_IMPLICIT_HANDLE` funcdef. Final gates are
verifier **30/30**, SemaAuthority **389/389**, ProductionCodeGen **112/112**,
and ProductionCodeGen + Canonical Semantics + retained native ScriptNode
**161/161 PASS**. Invalid discovery attempts using disabled explicit `@`
syntax, a funcdef without the host implicit-handle flag, and an unsupported
funcdef/null comparison are recorded but excluded from the clean RED.

The complete issue decisions, implementation anchors and runner metadata are
in
`attachments/canonical-funcdef-default-null-lifetime-gate-2026-08-28.md`.
Tasks 5.7/5.8 remain open, so progress stays **87/125 (69.6%)**, weighted
delivery **about 77%**, Bytecode/Runtime **about 73%**, safe default readiness
**about 50%**, direct AST AOT **about 55%**, and action-only Sema authority
**about 98%**. LEGACY remains the default; the native AST remains retained and
HIR remains deleted.

## 2026-08-28 CTA-S47 native-node dependency audit

Completed declaration/expression/statement Sema source units now physically
exclude the native syntax-node definition. Five dead text/range/scope walkers
were deleted and a source-architecture gate prevents them from returning.
This tightens CANONICAL action-only authority without deleting the retained
AngelScript AST used by Parser, LEGACY, recovery and reference tests.

The remaining `as_sema.cpp/.h` node references are classified separately as
build-local identity maps, not semantic walkers. They map pointer/unique
section-token identity onto Canonical IDs already created by typed actions and
remain in use by Parser, Builder and LEGACY function-body reparse. Their
pointer-free replacement is still open under task 13.2.

The valid TDD sequence is clean **0/1 RED**, build PASS, focused **1/1 PASS**
and complete SemaAuthority **397/397 PASS**. An earlier assertion-macro C4002
is retained but excluded as product evidence. Exact paths and issue decisions
are in
`attachments/canonical-sema-native-node-dependency-audit-2026-08-28.md`.
Progress remains **87/125 (69.6%)** and weighted implementation **about 77%**;
LEGACY remains the default, native AST remains retained, and HIR remains
deleted.

## 2026-08-28 Task 11.4 embedding migration contract

Chinese-first and English public guides now record every embedding migration
rule required by Task 11.4, including the exact detached versus
`ADD_TO_MODULE` CompileFunction snapshot lifecycle. They also correct two stale
claims: explicit CANONICAL source compilation is the sealed-AST CodeGen route,
and HIR is physically absent while the original native AST/Builder/Compiler
remain deliberately retained.

Fresh Module Snapshot is **10/10 PASS**; strict OpenSpec and diff checks pass.
Task 11.4 is closed and mechanical progress becomes **88/125 (70.4%)**.
Weighted implementation remains **about 77%** and default readiness **about
50%** because no semantic, backend, AOT or cutover umbrella closed. Evidence:
`attachments/embedding-client-canonical-ast-migration-notes-2026-08-28.md`.

## 2026-08-28 CTA-S48 primitive property-out deferred write-back

Canonical Sema now converts an exact generated script property supplied to an
exact primitive `T&out` formal into a sealed `DeferredOut` call-edge plan. The
plan owns the exact formal type, exact setter and one opaque receiver, so
neither Bytecode nor AOT needs to reconstruct property semantics from a getter
call or backend naming. The verifier rejects wrong setter kind/type/owner and
the dump exposes the setter key and receiver ID.

Canonical CodeGen consumes that plan by capturing the receiver address once,
passing a primitive temporary to the primary call, preserving the primary
return value and invoking the exact setter afterward in reverse-formal order.
The production fixture executes `Entry() == 42`, calls `Fill` once, `SetValue`
once and `GetValue` only for the final read, publishes through
`CANONICAL_CODEGEN`, and records zero LEGACY compiler invocations. Direct local
`&out` remains unchanged.

Fresh final gates are build PASS, focused Sema/verifier **1/1**, focused
production **1/1**, direct local out **1/1**, complete SemaAuthority **391/391
PASS**, and complete ProductionCodeGen **113/113 PASS**. The Context receiver
guard correction, test retention/type-lookup failures, one invalid non-unique
test patch and the remaining capability boundary are recorded in
`attachments/canonical-deferred-property-out-writeback-gate-2026-08-28.md`.

Tasks 5.7/5.8/9.5/13.2 remain open for non-POD out, `&inout`, reference-return
aliasing, global/import, exception/suspend and direct AOT breadth. Mechanical
progress remains **88/125 (70.4%)**. Weighted implementation is now **about
78%**, Canonical Bytecode/Runtime about **74%**, direct AST AOT about **55%**,
safe default readiness about **50%**, and action-only Sema authority about
**98%**. LEGACY remains the default; native AST retention and HIR deletion are
unchanged.

## 2026-08-28 CTA-S49 direct Canonical-AST AOT cleanup facts

The production TypedASTJIT diagnostic model and provider serialization already
had cleanup/exception/suspend fields, but backend generation never populated
them from the sealed AST. Real scalar root/helper closures therefore remained
`Unverified` even when their exact function bodies contained no cleanup action.

TypedASTJIT now runs one bounded structural visitor over the same exact sealed
function body used by eligibility and C++ emission. A complete traversal with
no `CleanupExpr` publishes a pointer-free `VerifiedEmpty` fact and proves all
transfers covered because no action exists. Unsealed, malformed and non-empty
cleanup graphs remain fail-closed as `Unverified`; no bytecode, dump, native
syntax tree or reconstructed HIR is consulted.

The clean TDD sequence is backend dependency **1/2 RED**, build PASS, backend
dependency **2/2 PASS**, CanonicalASTMigration **11/11 PASS**, and complete
TypedASTJIT **40/40 PASS**. One earlier zero-selection command is recorded and
excluded. Full architecture, paths and metadata are in
`attachments/canonical-aot-cleanup-facts-gate-2026-08-28.md`.

Task 7.5 remains open for non-empty destructor/release liveness, partial
construction, exception/suspend, globals/imports, call-site fallback and
remaining provider dependency families. Mechanical progress stays **88/125
(70.4%)** and weighted implementation stays **about 78%**. Direct Canonical-
AST AOT moves from about **55% to about 57%**; Bytecode/Runtime remains about
**74%**, safe default readiness about **50%**, and action-only Sema authority
about **98%**. LEGACY remains the default; the native AST is retained and HIR
remains deleted.

## 2026-08-28 CTA-S50 non-empty Canonical-AST AOT cleanup facts

The same exact sealed-function lifetime visitor now distinguishes the two
non-empty lexical actions already authored by Canonical Sema. A
`scope-release` plan publishes `NonEmpty`; a `scope-exit` or another cleanup
bound to an exact destructor publishes `ScriptDestructor`. Scalar `cleanup`
wrappers remain transparent, and unknown non-scalar/unbound cleanup forms stay
`Unverified`.

This is classification, not liveness. Non-empty results deliberately keep
`bCleanupPlanCoversAllTransfers=false` until a later structural pass proves
that every transfer owns the correct reverse live-only cleanup sequence. The
audit also confirms that the deleted HIR-era direct AOT cleanup test supported
only an empty scalar plan. HIR non-empty cleanup tests were semantic metadata
oracles, not native object-local execution. The current scalar TypedASTJIT
emitter therefore continues to fall back for object lifetime forms; adding a
native object-frame ABI would be separate capability expansion.

The valid TDD sequence is adapter class **11/12 RED**, build PASS, adapter and
CanonicalASTMigration **12/12 PASS**, and complete TypedASTJIT **41/41 PASS**.
One pre-build zero-selection attempt is excluded. Full evidence:
`attachments/canonical-aot-nonempty-cleanup-facts-gate-2026-08-28.md`.

Task 7.5 remains open for transfer liveness, partial construction,
exception/suspend, globals/imports, call-site fallback and remaining Provider
dependency families. Mechanical progress remains **88/125 (70.4%)** and
weighted implementation remains **about 78%**. Direct Canonical-AST AOT is
now about **58%**; Bytecode/Runtime remains about **74%**, safe default
readiness about **50%**, and action-only Sema authority about **98%**. LEGACY
remains the default; native AST retention and HIR deletion are unchanged.

## 2026-08-28 CTA-S51 reverse live-only cleanup proof

The first source-level RED revealed that Canonical Sema attached every direct
cleanup-requiring declaration in a block to every exiting transfer, including
declarations located after that transfer. An early return before `Later`
therefore owned a forged `Later` destructor action and Seal failed with
`unresolved-identifier:Later`. The corrected block pass walks original direct
children in order, activates each lifetime only after its exact `DeclStmt`,
and appends only active actions in reverse order. Copies of child IDs are used
before AST allocation can grow arrays and invalidate node pointers.

TypedASTJIT's sealed-AST visitor now independently derives exact lexical
release/destructor requirements and verifies normal and transfer plans. It
tracks only `DeclId`, `StmtId`, exact type/destructor identities and owning
scope IDs while the existing snapshot lease is live. Required lifetimes with
missing actions now publish `Unverified` rather than false `VerifiedEmpty`;
exact ordinary plans may publish complete transfer coverage. Real CANONICAL
source is proven end to end from Parser/Sema through the retained sealed AST to
the pointer-free AOT fact.

The valid TDD trail is Sema **0/1 RED -> 1/1 PASS**, AOT structural proof
**0/1 RED -> 1/1 PASS**, real-source bridge **1/1 PASS**, adapter **14/14
PASS**, SemaAuthority **392/392 PASS**, and complete TypedASTJIT **43/43
PASS**. The initial source fixture that also read the later object is excluded
as ambiguous RED evidence. Full paths and architecture:
`attachments/canonical-aot-reverse-live-only-cleanup-proof-2026-08-28.md`.

Task 7.5 remains open: partial construction, exception/suspend, special
loop/foreach phase proof, native object-frame ABI, globals/imports, call-site
fallback and remaining Provider dependency publication are not complete.
Mechanical progress remains **88/125 (70.4%)**. Weighted implementation is
now **about 79%**, direct Canonical-AST AOT **about 61%**, action-only Sema
**about 99%**, Bytecode/Runtime **about 74%**, and safe default readiness
**about 50%**. LEGACY remains the default; the original native AST is retained
and HIR remains physically deleted.

## 2026-08-28 CTA-S53 lifetime ownership/lifecycle/protocol foundation

CTA-S53 Tasks 15.1–15.3 are complete. Context ownership/foreign-ID admission
is hardened; one ordered lifecycle and `IsPublishable()` predicate now govern
all consumers; and revision 1 snapshot-owned lifetime records are stored and
authenticated without raw pointers, Engine numeric TypeId, backend state or
rendered identity. The valid TDD trail includes the missing-contract compile
RED, one resolved non-exported equality link failure and one resolved residual
Standalone `IsSealed()` build failure.

Final evidence is Runtime/Editor build PASS, Context **12/12**, Verifier
**35/35**, complete Frontend CanonicalAST **159/159**, and Standalone **20/20
PASS**. Sidecar remains V6. Production Sema record authoring, shared-view
authentication, compatibility-encoding migration, Bytecode/AOT consumption
and partial construction remain 15.4–15.10; an empty current-revision protocol
is a staged compatibility state rather than a completeness proof.

The expanded OpenSpec count is **92/136 (67.6%)**, 44 open; weighted progress
remains **about 79%**. Details and issue record:
`attachments/canonical-lifetime-protocol-foundation-2026-08-28.md`.

## 2026-08-28 CTA-S52 value-object foreach lifetime phase proof

The next special-phase RED used real CANONICAL source with a value-object
iterator and `return`, targeted `break`, targeted `continue`, plus normal loop
exit. Classification already found the exact script destructor, but transfer
coverage remained false because the AOT analyzer rejected the legal fourth
`Foreach` child as an unsupported standalone cleanup.

The corrected analyzer treats the synthetic iterator initializer and its
fourth cleanup child as one exact loop lifetime phase. It independently
derives the generated iterator requirement, matches the exact
declaration/type/destructor action, and follows the same target protocol
already consumed by Canonical Bytecode: normal/break enter the cleanup label,
continue retains the iterator through increment, and return/escaping
transfers use active loop-frame cleanup. Facts remain pointer-free and no
dump, HIR or bytecode transport was introduced.

Fresh evidence is focused **0/1 RED -> 1/1 PASS**, build PASS, adapter **15/15
PASS**, production object-iterator CodeGen **1/1 PASS**, SemaAuthority
**392/392 PASS**, and complete TypedASTJIT **44/44 PASS**. Full detail:
`attachments/canonical-aot-foreach-lifetime-phase-proof-2026-08-28.md`.

Task 7.5 remains open for partial construction, exception-region metadata,
real suspend state, native object-frame ABI, globals/imports, call-site
fallback and remaining Provider dependency families. Mechanical completion
stays **88/125 (70.4%)**; weighted completion remains **about 79%**, while
direct Canonical-AST AOT advances to **about 63%**. Action-only Sema remains
**about 99%**, Bytecode/Runtime **about 74%**, and safe default readiness
**about 50%**. LEGACY remains the default, native AST retention is unchanged,
and HIR remains physically deleted.

## 2026-08-28 CTA-S53 success-sensitive local lifetime activation

Task 15.4 is complete. An AST-first two-local fixture first failed **0/1**
because the revision 1 protocol contained no local records. The sealed graph
already distinguished each `DeclStmt` from its exact initializer `Assign`, so
the production fix makes that assignment's successful completion the local
commit point. Explicit transfer cleanup activation now occurs after the
initializer expression, and Sema authors exact local/destructor/activation/
region/phase/exit records without backend inference.

The same source shape executes through Canonical CodeGen with normal
destruction `[2,1]` and throwing-Second destruction `[1]`; publisher remains
Canonical and LEGACY invocation count remains zero. Final evidence is build
PASS, focused AST **1/1**, focused execution **1/1**, SemaAuthority **400/400**
and ProductionCodeGen **119/119 PASS**.

Mechanical progress is **93/136 (68.4%)**, 43 open. Weighted completion is
**about 80%**, Bytecode/Runtime **about 75%**, direct Canonical-AST AOT
**about 63%**, action-only Sema **about 99%**, and safe default readiness
**about 51%**. Tasks 15.5–15.10 remain open for shared-view authentication,
compatibility parity, protocol-only Bytecode/AOT consumption and partial
construction. Standalone adaptation is explicitly deferred and no longer a
CTA-S53 completion gate. Evidence and issue log:
`attachments/canonical-local-success-sensitive-activation-gate-2026-08-28.md`.

## 2026-08-28 CTA-S53 deterministic transient lifetime view

Task 15.5 is complete. The maintained fork now has one shared transient
`asCASTLifetimeView` that authenticates the revision 1 Sema records and
mechanically rebuilds scope edges, success-boundary live sets, initializer
abort cleanup and reverse live-only cleanup from immutable Canonical AST
structure. It has no Context persistence, Sidecar/Provider/DTO publication,
general CFG/HIR state or backend labels/slots/stacks. Its `LTV1` structural
digest is fieldwise typed and independent of dump rendering.

The API-first fixture produced the expected compile RED because the view API
did not exist. Final negative coverage rejects wrong subject/action/
activation/order/phase, missing/duplicate/foreign actions, early complete-
object claims and revision mismatch. The nested-scope proof derives outer
liveness before an inner commit and excludes the failed current inner object
from abort cleanup.

Final evidence is build PASS, Context **12/12**, Verifier **39/39**, Frontend
CanonicalAST **163/163**, SemaAuthority **400/400** and ProductionCodeGen
**119/119 PASS**. One exported friend-linkage mismatch and one stale Construct-
activation Context fixture were fixed and recorded.

Mechanical progress is **94/136 (69.1%)**, 42 open. Weighted completion is
**about 81%**, Bytecode/Runtime **about 75%**, direct Canonical-AST AOT
**about 63%**, action-only Sema **about 99%**, and safe default readiness
**about 53%**. Task 15.6 must still reconcile named protocol accessors with
`scope-exit`/`scope-release`/foreach compatibility encodings; 15.7-15.10 must
close protocol-only backend consumption and partial construction. Standalone
remains deferred and LEGACY remains the default. Evidence:
`attachments/canonical-lifetime-derived-view-gate-2026-08-28.md`.
