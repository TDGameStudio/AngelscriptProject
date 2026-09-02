# Canonical Typed AST compiler progress snapshot (2026-08-28)

## Executive result

The best single estimate for the complete
`refactor-as-canonical-typed-ast-compiler` change is **about 81% implemented**.
This is deliberately separate from the literal OpenSpec checkbox ratio.
Several declaration/Sema/lifetime rows are broad umbrella tasks and therefore
understate completed implementation slices, while the work still left inside
them contains the highest-risk lifetime, backend and product-cutover gates.

The three percentages answer different questions:

| Measure | Current | Interpretation |
| --- | ---: | --- |
| OpenSpec task completion | **94/136 = 69.1%** | Mechanical completion of the expanded task set; 42 rows remain open. |
| Weighted engineering completion | **about 81%** | Best estimate of the whole architecture and implementation, weighted by remaining semantic and lifecycle risk. |
| Safe default-CANONICAL readiness | **about 53%** | Readiness to make CANONICAL the product default; LEGACY intentionally remains the default. |

The headline should therefore be reported as **81% overall**, with **69.1% of
task rows checked**, but only **53% ready for the default switch**. It would be
incorrect to call the implementation 69.1% ready to ship merely because 94
task rows are checked.

## What is implemented now

### 1. Canonical AST and SourceManager foundation

The maintained fork now has a real owned typed graph rather than a dump-shaped
side model. The implementation includes AST context/type/node storage, source
provenance, traversal, diagnostics, verifier, public immutable view, dump and
Sidecar support. The graph uses explicit IDs and copied source coordinates;
public snapshots do not expose Parser-node pointers.

This layer is substantially complete. SourceManager and AST foundation task
sections are both 100% checked. The main remaining ownership item is final
module-retention/discard/publication closure under Task 3.4.

### 2. Parser to Sema typed-action boundary

The native Parser is intentionally retained and may continue to build
`asCScriptNode` for syntax recovery, LEGACY compilation, reference tests and
differential rollback. CANONICAL semantics, however, are being moved to
pointer-free typed actions that immediately bind exact AST identities.

The following expression families already cross typed actions:

- literal and declaration reference;
- conditional, assignment and precedence-folded binary/logical expression;
- ordered prefix/postfix unary expression;
- explicit cast and typed construction;
- ordinary named/scoped call, including copied positional/named arguments;
- ordered member/member-call/index/postfix-call chains with exact receiver
  ownership and complete Index argument retention;
- anonymous and explicitly typed initializer lists, including exact nested
  structure, empty lists and trailing-separator handling.

Complete migrated native-node cases are identity-only and fail closed when the
corresponding Parser action did not run. They no longer reconstruct those
semantics by walking `asCScriptNode`.

CTA-S34 removed the final two generic Parser expression callbacks. Production
Parser/Sema source now contains **zero** `ActOnParsedExpr` declarations,
implementations or calls. Initializer lists cross a copied pointer-free action;
complete native `snInitList` consumption is exact-identity-only. `ParseInitList`,
`snInitList`, `asCScriptNode`, Builder, `asCCompiler` and LEGACY remain retained
by design.

This closes the expression-level generic replay boundary. Leaf expression,
return and transfer statements now also cross one pointer-free typed action.
CTA-S41 additionally moved Block ordered-child construction and If
condition/then/else assembly to pointer-free typed actions. CTA-S42 now also
moves while/do-while/for/foreach/switch/case/default construction to exact
two-phase typed actions. Control headers publish exact targets before nested
bodies, finish actions fill those same identities, and the temporary
kind/owner/file/start control lookup is physically gone. Full semantic
authority is still open for explicit lifetime/cleanup and uncommon body forms.

CTA-S43 additionally deletes the now-dormant generic completed-node replay
surface itself. `ActOnExprFromNode`, `InternParsedExprTerm`,
`ActOnStmtFromNode`, `InternParsedChildStmt`, `InternParsedCompoundStmt` and
`ActOnParsedStmt` are physically absent from production Canonical Sema. Native
Parser AST construction remains by design. Residual declaration/type/scope
node-identity helpers are a separate build-time construction audit and prevent
a 100% whole-Sema action-only claim.

CTA-S44 begins the explicit lexical lifetime closure. Initialized direct
lexical value-object locals with an exact Canonical destructor now seal
reverse-order `scope-exit` cleanup statements for normal block exit and every
return/break/continue/fallthrough that leaves the block. Nested early returns
destroy inner locals before outer locals. The verifier checks the exact target
and destructor owner; Canonical CodeGen consumes the plan and retires only the
normal-path object state so its epilogue cannot double-destroy it. Owning
handle/reference, deferred/out, global, exception and suspend/resume lifetime
families were still open at that checkpoint.

CTA-S45 extends the same sealed lexical lifetime stack to initialized direct
`ReferenceObject` and `FuncDef` locals. Their cleanup literal is
`scope-release`, has one exact DeclRef child and deliberately has no destructor
`resolvedDecl`. The verifier rejects borrowed `REFERENCE` targets and forged
destructor bindings. Canonical CodeGen emits `asBC_FREE` + `asOBJ_UNINIT`, uses
the same Runtime release helper for the fallback epilogue, and retires only
the normal-path directory entry. Implicit handles are classified by Canonical
type kind plus the absence of `REFERENCE`, not by `IsHandle()`: this fork's
implicit-handle local has qualifier mask zero. Deferred/out, template/
container, global, exception and suspend/resume lifetime families remain open.
Source typedef is primitive-only and is not a value-object lifetime family.

### 3. HIR retirement and retained native AST boundary

The old TypedSemantic HIR implementation, capture ownership, compiler hooks,
Engine configuration and HIR dump surfaces have been physically removed from
production. `asCCompiler` has no HIR capture hook and
`asCTypedSemanticIRBuilder` is absent.

This does **not** delete AngelScript's native AST/compiler. The retained
`asCScriptNode`, Parser, Builder, `asCCompiler` and explicit LEGACY Bytecode
path remain by design. Their later deletion, if ever desired, belongs to a
separate OpenSpec. The current change only forbids CANONICAL from treating the
native tree as its semantic body representation or replay source.

### 4. Canonical Bytecode and Runtime installation

`asCBytecodeCodeGen` is a real backend with `Generate`, `GenerateFunction`,
prepared-module and detached-artifact paths. An explicitly selected CANONICAL
module can seal a canonical graph, generate Bytecode, resolve Runtime
relocations and publish executable module state. The fresh exact
ProductionCodeGen class run after CTA-S45 is **111/111 PASS**. The earlier
CTA-S44 discovery/build state reported **115/115**; each count is retained with
its exact runner evidence rather than normalized across selections.

The backend/runtime boundary already contains:

- sealed-AST validation before generation;
- detached candidate state and no-partial-publication transaction tests;
- stable type/property/function relocations;
- candidate-local operand patching;
- late public TypeId projection;
- all-or-nothing commit/abandon behavior;
- list-pattern helper rollback and generation ownership tests.

The remaining backend work is breadth and closure rather than creating a
backend from scratch: full value lifetime/container/delegate/lambda/global/
import behavior, debug/source/coverage/safe-point and cleanup metadata,
complete differential corpus, and every production entry-point gate.

### 5. Dynamic TypeId identity model

The dynamic AngelScript TypeId problem is addressed by separating durable
identity from the Engine's current numeric projection:

```text
snapshot-local asASTTypeRef
    -> complete StableTypeKey
    -> complete TypeABIKey
    -> immutable generation binding/relocation table
    -> current Engine numeric TypeId projection
```

The sealed AST and detached artifact do not persist an Engine pointer or a
numeric TypeId as identity. Installation first resolves the complete stable
type/member/function and ABI set against the target Engine, freezes an
immutable generation-local binding table, then patches candidate-owned
operands and publishes current numeric TypeIds only inside the final atomic
commit. Missing, ambiguous, wrong-kind, wrong-profile, wrong-native-
environment and ABI-mismatch cases fail before publication.

This part is considered complete at the OpenSpec-task level: section 14 is
**6/6**. Remaining CodeGen and Hot Reload tests can still discover consumers
that misuse the model, but the identity architecture itself no longer relies
on stable numeric TypeIds.

### 6. TypedASTJIT / AST AOT direction

The intended AOT route is direct:

```text
sealed verified Canonical AST -> Canonical visitors -> AOT/native artifact
```

No semantic dump or HIR replay is required. Canonical snapshot input,
eligibility/dependency foundations and some emission paths exist, and the HIR
dependency has been removed. The remaining 50% of section 7 is important:
complete call closure, cleanup/exception/frame-budget/global/import handling,
provider dependency publication and production removal of obsolete
TypedSemantic access assumptions all need final Canonical-AST verification.

### 7. LEGACY and product selection

The product default remains explicitly LEGACY:

```cpp
ep.canonicalCompilerPipeline = false;
```

Explicit CANONICAL selection is available for implementation and differential
testing. There is no supported production `dual` backend. The default must not
change until residual Sema authority, detached backend, AOT, entry-point and
full matrix gates have all passed.

## Task progress by section

| Section | Done | Open | Completion |
| --- | ---: | ---: | ---: |
| 0. Mandatory AST-first quality gate | 3 | 2 | 60.0% |
| 1. Semantic/differential baselines | 6 | 0 | 100.0% |
| 2. SourceManager and AST foundation | 13 | 0 | 100.0% |
| 3. Public AST/module ownership/leases | 7 | 1 | 87.5% |
| 4. Declaration/type Sema | 2 | 5 | 28.6% |
| 5. Expression/statement/call/lifetime Sema | 2 | 8 | 20.0% |
| 6. Cache V2 default-off containment | 12 | 0 | 100.0% |
| 7. TypedASTJIT migration | 4 | 4 | 50.0% |
| 8. Generate/native-form/diagnostics absorption | 9 | 0 | 100.0% |
| 9. Canonical Bytecode CodeGen | 5 | 4 | 55.6% |
| 10. Production cutover and HIR removal | 2 | 7 | 22.2% |
| 11. Standalone/public API/documentation | 5 | 0 | 100.0% |
| 12. Final verification/archive readiness | 4 | 2 | 66.7% |
| 13. Review-blocking work | 8 | 4 | 66.7% |
| 14. Type identity/Runtime install boundary | 6 | 0 | 100.0% |
| **Total** | **88** | **37** | **70.4%** |

The low checkbox ratios in sections 4 and 5 understate their code progress
because they contain large umbrella rows that stay open while typed-action
slices are completed. Conversely, sections 9 and 10 contain large final
closure rows, so their unfinished portions carry more product risk than an
ordinary checkbox count suggests.

## Weighted implementation view

These subsystem percentages are engineering estimates, not independently
checkable task ratios and not additive:

| Subsystem | Estimate | Status |
| --- | ---: | --- |
| AST/SourceManager/public graph/stable type model | **95%** | Foundation is present; final snapshot retention/publication race gates remain. |
| Action-only declaration/expression/statement/lifetime Sema | **about 99%** | Primary declaration/expression/control paths are action-only; exact lexical value destruction, direct reference/funcdef release and declaration-position live-only transfer plans now exist, while residual uncommon semantics and lifetime families remain. |
| Canonical Bytecode/Runtime installation | **74%** | Real opt-in generation/publication, lexical cleanup and primitive property-out write-back work; complete language, debug and exceptional cleanup breadth is open. |
| TypedASTJIT/direct AST AOT | **63%** | Direct AST direction plus empty/non-empty classification, ordinary reverse live-only transfer proof, and exact value-object `foreach` iterator-phase proof exist; partial-construction/exception/suspend/native-object-ABI/eligibility/provider gates remain. |
| Product entry points/default cutover/final matrix | **50%** | Explicit opt-in works; default remains LEGACY and full cutover matrix is not complete. |
| Documentation/evidence/migration record | **84%** | Extensive review/attachment evidence exists, including the lifetime proof and fail-closed boundary; final migration, release and archive records remain. |

Weighted together by remaining risk, the overall estimate is **about 79%**
after CTA-S52. Expression-level generic native-tree replay, initializer/body
adapters, leaf statements, Block/If and every structured control semantic
replay case are physically gone. The temporary control identity bridge and
all six generic completed expression/statement replay entry points are also
gone. Ordinary exact lexical value objects, direct reference objects and
funcdefs now seal and execute normal and transfer cleanup plans; primitive
property `&out` also seals and executes an exact deferred setter plan. The AOT
consumer now independently proves ordinary reverse live-only non-empty plans
and the exact value-object `foreach` iterator phase from those same sealed
facts, failing closed on missing actions. Residual declaration/type/scope
identity helpers, partial-construction/exception/suspend/native-object-ABI
lifetime families and the remaining backend/cutover umbrella tasks stay open,
so
`88/125` remains the current mechanical count.

### Observed implementation inventory

The physical-file inventory is useful for judging implementation scale, but it
is not a completion metric. A bounded scan of the new Canonical frontend,
Runtime type binding, detached Bytecode CodeGen and direct TypedASTJIT bridge
observed **43 implementation/header files and about 39,450 physical lines** at
the preceding bounded inventory point. The two core Native SDK CanonicalAST
test directories then contained **37 test files and about 43,631 physical
lines**. CTA-S45 adds code and tests inside those same files. These figures are
retained as a scale snapshot rather than silently recomputed with a different
file set. They exclude integration
edits in Parser, Builder, Module, Cache, Hot Reload, diagnostics, generated
providers and broader regression suites, and they do not imply that every line
or worktree change belongs only to this OpenSpec.

## Latest verified evidence

CTA-S45 closes initialized direct owning reference-object and funcdef lexical
release plans:

- clean missing-contract RED: Sema **0/1**, verifier **27/29** and production
  execution **0/1**:
  `Saved/Tests/cta-s45-scope-release-sema-red-2/20260828_083425_738_c1a96274/RunMetadata.json`,
  `Saved/Tests/cta-s45-scope-release-verifier-red/20260828_083701_054_06b661c2/RunMetadata.json`,
  `Saved/Tests/cta-s45-scope-release-production-red/20260828_083937_403_e4469b6b/RunMetadata.json`;
- production build and focused GREEN tests: build PASS, Sema **1/1**,
  execution **1/1**, verifier **29/29**:
  `Saved/Build/cta-s45-scope-release-green-build/20260828_084725_209_f160d14c/RunMetadata.json`,
  `Saved/Tests/cta-s45-scope-release-sema-green/20260828_084750_247_bc7d1a40/RunMetadata.json`,
  `Saved/Tests/cta-s45-scope-release-production-green/20260828_084826_242_ca9c121b/RunMetadata.json`,
  `Saved/Tests/cta-s45-scope-release-verifier-green/20260828_084900_049_3a43464b/RunMetadata.json`;
- expanded SemaAuthority **388/388**, ProductionCodeGen **111/111**, and
  ProductionCodeGen + Semantics + retained native ScriptNode **160/160 PASS**:
  `Saved/Tests/cta-s45-sema-authority-full/20260828_085300_967_b14bd9e3/RunMetadata.json`,
  `Saved/Tests/cta-s45-production-codegen-full/20260828_085503_741_480a1248/RunMetadata.json`,
  `Saved/Tests/cta-s45-secondary-gates/20260828_085819_369_68b43581/RunMetadata.json`;
- the complete implicit-handle qualifier discovery, verifier contract,
  Runtime lowering and invalid-evidence record is in
  `attachments/canonical-lexical-owning-release-plan-gate-2026-08-28.md`.

CTA-S44 closes the first general lexical value-object cleanup slice:

- expected missing-contract RED **0/1**:
  `Saved/Tests/cta-s44-lexical-cleanup-plan-red/20260828_071106_212_c7627a7e/RunMetadata.json`;
- verifier wrong-destructor RED **30/31**, then complete verifier **31/31
  PASS**:
  `Saved/Tests/cta-s44-scope-exit-verifier-red-class/20260828_071824_047_c38bdf49/RunMetadata.json`,
  `Saved/Tests/cta-s44-scope-exit-verifier-green-class/20260828_072221_885_fe1cfeb8/RunMetadata.json`;
- exact early/normal path construction/destruction execution **1/1 PASS**:
  `Saved/Tests/cta-s44-lexical-cleanup-runtime-focused/20260828_072853_437_71a5c242/RunMetadata.json`;
- the first ProductionCodeGen run was **114/115** and exposed the missing
  prepared generated-destructor Runtime shell:
  `Saved/Tests/cta-s44-lexical-cleanup-production-full/20260828_072925_652_ae67d44a/RunMetadata.json`;
- final SemaAuthority **394/394 PASS**:
  `Saved/Tests/cta-s44-lexical-cleanup-sema-full-final/20260828_073717_442_fd6463e3/RunMetadata.json`;
- ProductionCodeGen + Canonical Semantics + retained native ScriptNode
  downstream gate **159/159 PASS**:
  `Saved/Tests/cta-s44-lexical-cleanup-secondary-gates/20260828_074313_559_241b64f9/RunMetadata.json`;
- the strengthened destructor-publication/call regression is **1/1 PASS** and
  final ProductionCodeGen is **115/115 PASS**:
  `Saved/Tests/cta-s44-generated-dtor-contract-focused-final/20260828_080026_587_a647b6f2/RunMetadata.json`,
  `Saved/Tests/cta-s44-production-full-final/20260828_080135_903_de82f8e9/RunMetadata.json`;
- the complete issue and invalid-evidence record is in
  `attachments/canonical-lexical-value-cleanup-plan-gate-2026-08-28.md`.

CTA-S43 physically closed the generic completed-node Sema adapter boundary
after CTA-S42 completed structured-control actions:

- expected physical-retirement RED **0/1**:
  `Saved/Tests/cta-s43-native-sema-adapter-retirement-red/20260828_064723_976_1cae12bc/RunMetadata.json`;
- final complete SemaAuthority **393/393 PASS**:
  `Saved/Tests/cta-s43-native-sema-adapter-retirement-sema-authority-full-2/20260828_070010_099_8112d571/RunMetadata.json`;
- ProductionCodeGen + Canonical Semantics + retained native ScriptNode
  downstream gate **158/158 PASS**:
  `Saved/Tests/cta-s43-native-sema-adapter-retirement-secondary-gates/20260828_070052_050_b4d2b424/RunMetadata.json`;
- exact build history, test-assumption repair and source-contract hazards are
  recorded in
  `attachments/canonical-native-sema-replay-adapter-retirement-gate-2026-08-28.md`.

The preceding CTA-S42 evidence remains:

- while/do-while focused **12/12 PASS** and full SemaAuthority **386/386
  PASS**;
- for/foreach new action tests **3/3 PASS**, regressions **10/10 PASS** and
  full SemaAuthority **389/389 PASS**;
- expected switch/case missing-contract RED build:
  `Saved/Build/cta-s42-switch-case-action-red/20260828_061229_824_2557a40a/RunMetadata.json`;
- first switch/case implementation build recorded the default-only C++ switch
  cleanup error:
  `Saved/Build/cta-s42-switch-case-action-build-1/20260828_062002_324_7ac7bfcd/RunMetadata.json`;
- repaired GREEN build:
  `Saved/Build/cta-s42-switch-case-action-build-2/20260828_062030_096_6c95586b/RunMetadata.json`;
- new switch/case exact-action and source-boundary coverage **3/3 PASS**:
  `Saved/Tests/cta-s42-switch-case-action-focused-new-1/20260828_062052_094_f9397003/RunMetadata.json`;
- switch/default/fallthrough/break/safe-point/recovery regressions **10/10
  PASS**:
  `Saved/Tests/cta-s42-switch-case-action-regression-1/20260828_062302_161_99707505/RunMetadata.json`;
- final complete SemaAuthority **392/392 PASS**:
  `Saved/Tests/cta-s42-switch-case-sema-authority-full-1/20260828_062447_874_bf24afab/RunMetadata.json`;
- combined ProductionCodeGen, Canonical Semantics and retained ScriptNode
  boundary **158/158 PASS**:
  `Saved/Tests/cta-s42-switch-case-secondary-gates/20260828_063033_755_2365aab4/RunMetadata.json`;
- strict OpenSpec validation and both parent/plugin `git diff --check` pass;
  diff checks report only existing LF-to-CRLF conversion warnings.

These focused gates do not claim that the complete UE `All` suite, final
Standalone Release suite, StaticJIT matrix or final default-cutover matrix was
rerun after CTA-S45. Earlier green evidence remains useful regression history,
but the final change cannot close on focused results alone.

## Remaining critical path

The recommended execution order is now:

1. Extend the now-explicit lexical cleanup contract to deferred/out values,
   template/container and delegate/lambda capture ownership, globals,
   exception edges and suspend/resume frames.
2. Audit and close the residual uncommon declaration/body semantic surfaces;
   action-only control assembly itself is complete.
3. Close module-owned snapshot retention and Hot Reload generation leases.
4. Complete detached Bytecode breadth, including nested/default list-pattern
   lowering, multi-argument Index ABI,
   debug/source/coverage/safe-point/
   cleanup metadata and isolated differential execution.
5. Finish TypedASTJIT direct Canonical-AST visitors and provider dependency/
   fallback gates; no dump or HIR bridge should be introduced.
6. Cover every production source-build entry point, then run the complete AST,
   SDK, Cache, Hot Reload, StaticJIT, Standalone and final configured suite
   matrices.
7. Only after those gates are green, switch the default to CANONICAL while
   retaining explicit LEGACY rollback. Archive and release notes come last.

## Current issues and risk register

1. **Initializer-list lowering breadth is incomplete.** AST/Sema now retain
   nested lists exactly, but current Canonical `EmitListFactoryInto` is still a
   flat repeat-element emitter. Nested patterns, omitted/default elements,
   repeat-same, wildcard slots and default constructors require durable AST and
   CodeGen contracts; unsupported forms must continue to fail closed.
2. **Initializer-list grammar has a sharp edge.** `Identifier = {...}` is
   parsed as native `[TYPE '='] INITLIST`; `(Identifier) = {...}` is required
   to select anonymous-list assignment without changing retained Parser
   semantics.
3. **Multi-argument Index emission is incomplete.** AST/Sema retain and select
   the complete argument vector, but Canonical CodeGen currently fails closed
   for more than one Index argument until its Runtime ABI route is complete.
4. **Large Sema umbrella tasks remain open.** Initializers, callable-body
   attachment, leaf statements, Block/If and all structured controls are now
   action-only. All six generic completed expression/statement replay adapters
   are physically removed. Exact lexical value-object cleanup plus direct
   owning reference-object/funcdef release are now sealed and executable, but
   deferred/out, template/container, global, exception, suspend/resume and
   uncommon declaration/type/scope surfaces
   still keep the umbrella rows open; bounded build-time native-node identity
   helpers require separate classification.
5. **Backend breadth is incomplete.** The opt-in backend is real and consumes
   sealed value destruction and reference release, but complete language
   coverage, debug metadata, exceptional cleanup and remaining lifetime
   publication are final blockers.
6. **AOT is not yet a complete Canonical visitor.** HIR is gone, but all
   production eligibility, closure and fallback policies have not been
   re-proven against the sealed AST.
7. **No default switch yet.** LEGACY being the default is intentional risk
   control, not an accidental stale setting.
8. **The worktree is very large and dirty.** The plugin tracked diff currently
   observes 250 files, 22,634 added lines and 47,690 deleted lines. Plugin
   status contains **357 total entries**, specifically 176 modified, 75
   deleted and 106 untracked entries; there are no tracked-added entries. These
   figures are an observed worktree inventory, not a claim that every change
   belongs only to this OpenSpec. Cleanup/reset must not be used to manufacture
   a smaller diff.
9. **Final broad verification is still outstanding.** Focused CTA-S46 gates
   are green, but completion requires the named full matrices and strict
   OpenSpec closure.

## Bottom line

This is past the prototype stage: the typed AST, verifier, snapshots, stable
identity/relocation model, explicit CANONICAL CodeGen and several real
execution paths exist. It is not yet at product-default stage because the
remaining work sits exactly on semantic completeness, lifetime correctness,
AOT closure and publication/cutover boundaries.

Current reportable status:

- **overall implementation: about 79%**;
- **OpenSpec rows: 88/125, 70.4%**;
- **safe default switch: about 50%**;
- **action-only Parser-to-Sema authority: about 99%**;
- **direct Canonical-AST AOT: about 63%**;
- **next concrete milestone:** define and prove partial-construction and
  exception metadata while keeping polling safe points distinct from a real
  suspend state, then address native
  object-frame ABI, mutable-global/import, call-fallback and Provider
  dependency families.

## CTA-S46 checkpoint: funcdef default-null live state

A valid implicit-handle funcdef local without an explicit initializer now has
an explicit Canonical lifetime fact. Sema seals a direct `NullLiteral` in the
local `Decl.inits`, emits the typed assignment, and the existing lexical
classifier consequently produces normal and return-path `scope-release`
plans. The verifier now rejects any forged owning release whose target has no
initializer with `scope-release-cleanup-uninitialized`. Canonical Bytecode
uses the existing pointer-clear and `FREE` + `UNINIT` routes; no backend-only
inference from zeroed VM frame storage remains necessary.

Fresh gates are build PASS, focused verifier/Sema/production **1/1** each,
verifier class **30/30**, SemaAuthority **389/389**, ProductionCodeGen
**112/112**, and ProductionCodeGen + Canonical Semantics + retained native
ScriptNode **161/161 PASS**. The invalid explicit-`@` fixture, missing
`asOBJ_IMPLICIT_HANDLE` registration, unsupported funcdef/null comparison,
clean REDs and final GREEN evidence are all retained in
`attachments/canonical-funcdef-default-null-lifetime-gate-2026-08-28.md`.

No umbrella task closes: deferred/out, aggregate/container, capture, global,
exception, suspend/resume, detached Bytecode breadth and direct AOT cleanup
remain. Mechanical progress therefore stays **87/125 (69.6%)**. Weighted
implementation stays **about 77%**, Canonical Bytecode/Runtime **about 73%**,
safe default readiness **about 50%**, direct Canonical-AST AOT **about 55%**,
and action-only Sema authority **about 98%**. The default remains LEGACY; the
native AngelScript AST remains retained and HIR remains deleted.

## CTA-S47 checkpoint: CANONICAL Sema native-node dependency classification

The audit found five dead adapters in completed Sema units: declaration
`RangeOf`, expression `NodeText`, `ScopeText`, `ExprRange` and
`ResolveScopeOwner`. None had callers, but they retained a physical
native-tree traversal path and made the action-only boundary ambiguous. They
and the now-unused `as_scriptnode.h` includes are deleted; a new source gate
prevents their return.

The audit also prevents an overclaim: `as_sema.cpp/.h` still has build-local
identity maps from node pointer or unique section/token coordinates to an
already-created Canonical `DeclId`, `ExprId` or `QualType`. Parser composition,
Builder shell binding and LEGACY body reparse use these maps. They do not walk
children or reconstruct semantics, so they are not the retired replay path,
but task 13.2 remains open until a pointer-free parse-action identity replaces
them.

Fresh evidence is build PASS, focused **1/1 PASS**, and complete
SemaAuthority **397/397 PASS**. The clean pre-implementation result was
**0/1 RED**; an earlier C4002 assertion-macro error is explicitly excluded as
invalid product evidence. Full details are in
`attachments/canonical-sema-native-node-dependency-audit-2026-08-28.md`.

Progress remains **87/125 (69.6%)**, weighted implementation **about 77%**,
Bytecode/Runtime **about 73%**, direct AST AOT **about 55%**, safe default
readiness **about 50%**, and action-only Sema authority **about 98%**. LEGACY
remains the default; native AST retention and HIR deletion are unchanged.

## Task 11.4 checkpoint: embedding-client migration notes

The public migration contract is now complete in Chinese and English. It
covers the current `1.0.0`/`10000` header, trailing module slots, caller-size
and V1 negotiation, append-only/foreign-ID rules, retention timing, normal null
acquisition, lease/current generation, `CompileFunction` invalidation,
Cache/SaveByteCode/dump boundaries, stable pointer-free persistence and no
concrete node ABI. The audit also repairs stale documentation that claimed HIR
remained or that explicit CANONICAL Build still published through the legacy
compiler.

Fresh Module Snapshot is **10/10 PASS** and strict/diff gates pass. Task 11.4
is checked, so mechanical progress is now **88/125 (70.4%)**. This is a real
documentation/embedding closure, not a backend maturity claim: weighted
implementation remains **about 77%**, Bytecode/Runtime **about 73%**, direct
AST AOT **about 55%**, safe default readiness **about 50%**, and action-only
Sema authority **about 98%**. LEGACY remains the default; native AST retention
and HIR deletion are unchanged.

## CTA-S48 checkpoint: primitive property `&out` write-back

The first deferred/out lifetime family now runs end to end from sealed AST.
Sema converts an exact primitive generated property bound to `T&out` into a
`DeferredOut` plan with exact formal type, exact setter and one opaque
single-evaluation receiver. The verifier rejects a forged non-setter with the
stable token `deferred-out-setter`, and the dump exposes setter and receiver
identity.

Canonical CodeGen captures the receiver once, passes a primitive temporary to
the primary call, preserves the primary return register and invokes the exact
sealed setter afterward. The fixture executes `42`, calls `Fill` once,
`SetValue` once and `GetValue` only for the final read; publisher provenance is
CANONICAL and LEGACY invocation count is zero. Direct local out is unchanged.

Fresh final gates are build PASS, focused Sema/verifier **1/1**, focused
production **1/1**, direct local out **1/1**, complete SemaAuthority **391/391
PASS**, and complete ProductionCodeGen **113/113 PASS**. Full evidence and the
test-lifetime/type-lookup corrections are in
`attachments/canonical-deferred-property-out-writeback-gate-2026-08-28.md`.

No umbrella row closes. Mechanical progress remains **88/125 (70.4%)**;
weighted implementation is **about 78%**, Canonical Bytecode/Runtime about
**74%**, direct AST AOT about **55%**, safe default readiness about **50%**,
and action-only Sema authority about **98%**. LEGACY remains the default;
native AST retention and HIR deletion are unchanged.

## CTA-S49/S50 checkpoint: direct AOT cleanup facts

CTA-S49 connected the exact sealed Canonical function body to pointer-free
production/provider lifetime diagnostics and proved the vacuous
`VerifiedEmpty` case. CTA-S50 now distinguishes exact `scope-release` as
`NonEmpty` and exact destructor cleanup as `ScriptDestructor`. Scalar cleanup
wrappers remain transparent; unknown cleanup forms fail closed as
`Unverified`; non-empty transfer coverage remains false until a liveness proof
exists.

The audit also corrects the scope of the remaining work. The retired HIR-era
direct TypedASTJIT cleanup regression emitted only scalar control flow with an
explicit empty plan. Non-empty/partial-construction/script-destructor tests
were semantic metadata oracles, not native object-cleanup execution. The
current scalar-only C++ emitter should therefore retain per-function
BytecodeJIT/VM fallback for object lifetime forms unless a separate native
object-frame ABI is deliberately designed.

Fresh CTA-S50 evidence is build PASS, adapter and CanonicalASTMigration
**12/12 PASS**, and complete TypedASTJIT **41/41 PASS**. The valid RED was
**11/12**; a preceding zero-selection attempt is excluded. Full evidence and
the remaining transfer/exception/provider boundary are in
`attachments/canonical-aot-nonempty-cleanup-facts-gate-2026-08-28.md`.

No umbrella row closes. Mechanical progress remains **88/125 (70.4%)**,
weighted implementation remains **about 78%**, direct Canonical-AST AOT is
**about 58%**, safe default readiness remains **about 50%**, and action-only
Sema authority remains **about 98%**. LEGACY remains the default; native AST
retention and HIR deletion are unchanged.

## CTA-S51 checkpoint: reverse live-only AOT cleanup proof

CTA-S51 first exposed and corrected a producer bug: a return before a later
cleanup-requiring declaration incorrectly received that unconstructed local's
cleanup action. Sema now activates a direct lexical lifetime only after its
exact `DeclStmt`, appends active actions in reverse order, and preserves
inner-to-outer ordering without retaining pointers that can be invalidated by
AST-array growth.

TypedASTJIT now independently derives required release/destructor actions from
sealed declaration/type facts and compares them with exact normal and transfer
edges. Missing plans fail closed as `Unverified`; exact ordinary non-empty
plans may publish complete transfer coverage. The transport remains
pointer-free and dump-free. This is structural eligibility truth, not a native
object-frame ABI, so object lifetime functions continue to use precise
per-function fallback.

The clean TDD trail is Sema **0/1 RED -> 1/1 PASS**, AOT coverage **0/1 RED ->
1/1 PASS**, real-source bridge **1/1 PASS**, adapter **14/14 PASS**, complete
SemaAuthority **392/392 PASS**, and complete TypedASTJIT **43/43 PASS**. One
initial fixture with an additional source-level use of the later local is
recorded and excluded. Full proof, paths and conservative boundaries:
`attachments/canonical-aot-reverse-live-only-cleanup-proof-2026-08-28.md`.

No umbrella row closes. Mechanical progress remains **88/125 (70.4%)**;
weighted implementation is now **about 79%**, direct Canonical-AST AOT is
**about 61%**, action-only Sema is **about 99%**, Bytecode/Runtime remains
**about 74%**, and safe default readiness remains **about 50%**. Partial
construction, exception/suspend and special loop/foreach phase proofs, native
object-frame ABI, mutable globals/imports, call-site fallback and remaining
Provider dependency families keep Task 7.5 open.

## CTA-S52 checkpoint: value-object foreach lifetime phase

CTA-S52 identified a legal Canonical lifetime protocol that the AOT analyzer
previously rejected. A value-object `foreach` owns a generated iterator whose
lifetime spans the whole loop, while the cleanup action is stored as the exact
fourth `Foreach` child. Treating the synthetic initializer `Block` as an
ordinary lexical scope would destroy the iterator before the body; treating
the fourth child as an unsupported standalone cleanup left correct source
classified but unproven.

The direct Canonical-AST analyzer now derives exactly one generated iterator
requirement from the initializer, matches the exact fourth phase, and tracks
that lifetime against the loop target. Normal exhaustion and targeted
`break` enter the common cleanup label, targeted `continue` retains the live
iterator through increment, and `return`/escaping transfers use the active
loop-frame cleanup route. The published fact remains pointer-free and does not
use dump, HIR, bytecode transport, or durable numeric TypeId.

The final real-source fixture covers `return`, `break`, `continue`, and normal
exit. Fresh evidence is final build PASS, focused **0/1 RED -> 1/1 PASS**,
adapter **15/15 PASS**, production Canonical Bytecode object-iterator execution
**1/1 PASS**, SemaAuthority **392/392 PASS**, and complete TypedASTJIT **44/44
PASS**. Full protocol, evidence paths and conservative boundaries:
`attachments/canonical-aot-foreach-lifetime-phase-proof-2026-08-28.md`.

No umbrella row closes. Mechanical progress remains **88/125 (70.4%)** and
weighted implementation remains **about 79%**; direct Canonical-AST AOT is now
**about 63%**, action-only Sema **about 99%**, Bytecode/Runtime **about 74%**,
and safe default readiness **about 50%**. Partial construction,
exception-region metadata, real suspend state, native object-frame ABI,
mutable globals/imports, call-site fallback and remaining Provider dependency
families keep Task 7.5 open. LEGACY remains the default; the original native
AST is retained and HIR remains physically deleted.

## CTA-S53 Tasks 15.1–15.3 checkpoint: ownership, lifecycle and protocol foundation

The Clang/daScript comparison and lifetime re-review split the previously
implicit cleanup work into eleven explicit CTA-S53 tasks. The first three are
now complete. Context cannot be copied/moved, every internal node lookup
rejects public/foreign owner tokens, and all consumers share the ordered
`Building -> SemaFinalized -> LifetimePlanned -> Frozen/Publishable`
admission contract.

Task 15.3 adds revision 1 snapshot-owned lifetime value records with exact
subject, action target, activation point, region/phase, exit mask,
construction step/order and complete-object commit fields. Context owns the
copied records; planning authenticates the revision and snapshot-local IDs;
equality/hash are fieldwise and independent of pointers, numeric TypeId,
backend state or rendered dumps.

Fresh evidence is Runtime/Editor build PASS, Context **12/12**, Verifier
**35/35**, Frontend CanonicalAST **159/159** and Standalone **20/20 PASS**.
The implementation also exposed and fixed one DLL equality link boundary and
one residual Standalone `IsSealed()` call. A current-revision empty protocol is
only a staged compatibility state: 15.4 must author success-sensitive facts,
15.5–15.6 must derive/authenticate the shared view and migrate compatibility
encodings, and 15.7–15.10 must close Bytecode/AOT/partial-construction parity.

The expanded task set is now **92/136 (67.6%)**, 44 open. Architecture-
weighted implementation remains **about 79%**; direct Canonical-AST AOT
remains **about 63%**, Bytecode/Runtime **about 74%**, action-only Sema
**about 99%**, and safe default readiness **about 50%**. Full evidence,
issues and non-claims:
`attachments/canonical-lifetime-protocol-foundation-2026-08-28.md`. The
Chinese integration snapshot is
`reviews/main-integration-checkpoint-2026-08-28.md`.

## CTA-S53 Task 15.4 checkpoint: success-sensitive local activation

Task 15.4 now separates declaration from lifetime activation. Sema finds the
exact local initializer `Assign`, treats successful completion of that
expression as the commit point, delays explicit transfer cleanup activation
until that point, and authors exact `LOCAL / DESTROY_VALUE` records against
the enclosing lexical block and selected destructor. `DeclStmt` no longer
implies liveness.

The AST-first fixture produced the expected **0/1 RED -> 1/1 PASS**. The
production fixture executes the same two-local shape through Canonical
CodeGen: normal cleanup is `[2,1]`, while a throwing second initializer cleans
only `[1]`. Complete SemaAuthority is **400/400 PASS**, ProductionCodeGen is
**119/119 PASS**, and the Runtime/Editor build succeeds. Existing VM object
initialization/unwind state already preserved success-before-active; this
slice does not claim the Bytecode backend consumes only the new protocol.

The expanded task set is **93/136 (68.4%)**, 43 open. Weighted implementation
is **about 80%**, Bytecode/Runtime **about 75%**, direct Canonical-AST AOT
**about 63%**, action-only Sema **about 99%**, and safe default readiness
**about 51%**. Standalone adaptation is deferred to a separate future
OpenSpec and is excluded from subsequent CTA-S53 gates. Full evidence and
issues:
`attachments/canonical-local-success-sensitive-activation-gate-2026-08-28.md`.

## CTA-S53 Task 15.5 checkpoint: deterministic transient lifetime view

Task 15.5 now provides the single shared rebuildable proof view over immutable
Canonical facts. It authenticates each exact local/value cleanup record,
derives nearest lifetime-scope edges, computes committed-live sets at every
success boundary, and emits initializer-abort plus reverse live-only cleanup
orders. The view is not owned or published by Context, has no DTO/Sidecar/
Provider surface, and introduces no CFG/HIR or backend labels, slots, stacks
or frame ABI.

The API-first test produced the expected missing-contract compile RED.
Wrong subject/action/activation/order/phase, missing/duplicate/foreign actions,
early complete-object claims and wrong revision now fail closed. A nested
scope proves `Outer` is live before `Inner`, normal cleanup is
`[Inner, Outer]`, and failed `Inner` initialization cleans only `[Outer]`.
Repeated reconstruction produces identical typed records and an independent
`LTV1` digest even when `asCASTDump()` runs between builds.

Final evidence is Runtime/Editor build PASS, Context **12/12**, Verifier
**39/39**, complete Frontend CanonicalAST **163/163**, SemaAuthority
**400/400** and ProductionCodeGen **119/119 PASS**. The implementation exposed
and fixed one MSVC friend/export linkage mismatch and one stale Context fixture
that still treated Construct as activation. Exact paths, scans and non-claims:
`attachments/canonical-lifetime-derived-view-gate-2026-08-28.md`.

The expanded task set is **94/136 (69.1%)**, 42 open. Weighted implementation
is **about 81%**, Bytecode/Runtime **about 75%**, direct Canonical-AST AOT
**about 63%**, action-only Sema **about 99%**, and safe default readiness
**about 53%**. Tasks 15.6-15.11 remain mandatory for compatibility parity,
protocol-only Bytecode/AOT consumption, partial construction and the final
boundary gate. Standalone remains deferred; LEGACY remains the default.

## 2026-08-29 CTA-S54 supersession

The pointer/coordinate identity residual recorded at lines 490-496 is now
closed. Canonical Sema stores only the copied exact build-local value
`section + nodeKind + offset + length`; `as_sema.h/.cpp` have no
`asCScriptNode` type or native child traversal. Same bindings are idempotent,
conflicting Decl/Expr/Type bindings diagnose and preserve the first binding.

Exact identity exposed two previously hidden range-growth bugs. Cast and
construct target types were bound before the expression range completed, and
declaration wrappers were queried by Builder after their early range had grown.
Parser now binds target types at the completed expression phase and publishes
the same Decl under the completed wrapper identity without pointer retention or
fuzzy fallback. Final SemaAuthority is **405/405 PASS**; ProductionCodeGen,
Module Canonical Snapshot, and TypedASTJIT are **186/186 PASS**.

This supersedes only that residual finding. Tasks 4.2 and 13.2 remain open for
their full semantic environment, language-family, sealed-fact and
mechanical-backend requirements. The formal checklist is **100/136 (73.5%)**;
Standalone remains deferred and LEGACY remains the default. Evidence:
`attachments/canonical-pointer-free-parse-action-identity-gate-2026-08-29.md`.

## 2026-08-29 CTA-S55 declaration Sema closure

Task 4.2 is now complete. The previously separate namespace, enum, typedef,
import, function/record/variable, funcdef, access, parameter, QualType, lambda,
generic replay-retirement and parse-identity TDD cards collectively cover the
maintained declaration inventory. Canonical Sema no longer accepts or walks a
native declaration tree; the native Parser tree and LEGACY path remain.

Fresh SemaAuthority is **405/405** and the current exact Frontend Parser
Declarations prefix is **18/18 PASS**. The formal checklist is now
**101/136 (74.3%)**, 35 open. This is not a 4.3-4.6, 5.x, 13.2 or default
cutover claim, and Standalone remains deferred. Evidence and the excluded
stale-prefix no-selection run are recorded in:
`attachments/canonical-declaration-sema-action-closure-gate-2026-08-29.md`.
