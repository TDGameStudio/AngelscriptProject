Implementation workspace is `D:\as-cta` (junction to `.worktrees\refactor-as-canonical-typed-ast-compiler`). Plugin source changes are dual-repo: commit `Plugins/Angelscript` first, then the parent gitlink and OpenSpec record. Use only `Tools\RunBuild.ps1`, `Tools\RunTests.ps1`, and `Tools\RunTestSuite.ps1` from that worktree (`ProjectFile=D:\as-cta\AngelscriptProject.uproject`). Wave B's sealed generated-accessor field identity, its two focused regressions, and exact verification evidence are recorded in `attachments/wave-b-accessor-sealed-field-identity.md`; the subsequent field-layout fail-closed closure, including the corrected Sema-layout test harness and final `323/323` / `513/513` evidence, is recorded in `attachments/wave-b-field-offset-fail-closed.md`; the global value-width ABI closure is recorded in `attachments/wave-b-global-write-width.md`; the 12-byte POD `COPY`, direct hidden-return-object, and generic object-pointer by-value-parameter closure (including external `SetArgObject` compatibility), with final `52/52` / `517/517` evidence, is recorded in `attachments/wave-b-pod-copy-width.md`. These are local semantic closures, not task-completion claims.

File maps, LLVM/Clang encodings, per-task verification, and milestone order: `attachments/execution-plan.md` and `attachments/llvm-ast-architecture.md`. Spec vs code mapping: `attachments/record-reconciliation.md`. Review: `reviews/implementation-review-2026-08-21.md`.

`specs/` and `design.md` remain the complete cutover. A checked implementation
item means its exact requirement and gate-card evidence are satisfied; it does
not allow a broader parent milestone to be inferred complete. A task that
touches semantic construction, lowering, snapshot, or Cache V2 cannot be
checked from a broad SDK/VM result alone: its AST-first card must be complete
first. Do not make `canonicalCompilerPipeline` the default until section 10's
rereview gates pass. Do not archive unless the user requests it.

## 2026-08-28 remaining critical path and B2 lifetime reconciliation

Historical task numbers and completed evidence remain intact. The unchecked
items are overlapping acceptance umbrellas, not independent features; do not
renumber them or infer delivery progress from raw checkbox percentage. HIR is
physically deleted and no longer belongs on the remaining path. The approved
B2 lifetime protocol tasks are added in section 15 rather than rewriting the
history under 5.7/5.8/7.5/9.x. The remaining dependency order is:

```text
A. remaining semantic authority
   4.2-5.9 + 13.2 + 13.10
             |
             v
B. Canonical lifetime protocol and partial construction
   15.1-15.11 + umbrella 5.7/5.8
             |
             +-------------------+
             v                   v
C. detached Bytecode         D. TypedASTJIT/AOT consumer
   9.1/9.5/9.6 + 13.6        7.2/7.4/7.5
             \                   /
              +--------+--------+
                       v
E. generation publication and admission
   3.4 + 13.8 + 13.11 + completed 14.x boundary
                       |
                       v
F. CANONICAL production entry/default cutover and LEGACY isolation
   10.1-10.4 + 10.6/10.7/10.9
                       |
                       v
G. documentation and final gates
   0.2/0.3 + 12.2/12.4 + 13.12
```

Section 14 is intentionally narrow. This change must prove that Canonical AST,
detached artifacts, optional AST DTOs, StaticJIT identity, and module-generation
publication never treat an Engine-local numeric `typeId` as durable identity.
It does **not** require removal of every numeric-ID operand from the legacy VM
or `FAngelscriptPrecompiledData`; the complete opcode/PrecompiledData migration
is reserved for a future `refactor-as-runtime-type-identity-relocation` change.

The 2026-08-27 native-AST scope revision is also normative. This change retains
`asCScriptNode`, `asCBuilder`, `asCCompiler`, native parser/compiler tests, and
explicit LEGACY selection. Function-owned TypedSemantic HIR is already
physically deleted and must remain absent. CANONICAL Sema/backends still must
be independent from semantic Parser-node replay or silent LEGACY fallback. See
`attachments/legacy-native-ast-retention-scope-revision-2026-08-27.md`.

The 2026-08-28 lifetime decision is normative. Clang-style success-before-
activation and reverse committed-prefix semantics are implemented through a
Sema-authored, verifier-authenticated, snapshot-owned Canonical lifetime
protocol plus one deterministic transient shared view. Backend cleanup stacks,
labels, slots and physical tables remain local. The view is not persisted or
published and is not a renamed HIR. Existing normal/transfer cleanup statements
remain during migration and must match the shared view exactly. Sidecar V6
was the lifetime checkpoint's starting schema. The active exact-version schema
now remains unchanged unless an AST-first RED proves a required sealed fact
cannot be reconstructed; each accepted append-only revision retains its own
chronology and treats the previous version as a safe miss. CTA-S53 advanced
V6→V7 for lifetime facts, Approach A advanced V7→V8 for method relations, and
CTA-S72 advanced V8→V9 for exact call-argument authority. See
`reviews/canonical-ast-vs-clang-lifetime-review-2026-08-28.md`.

## 0. Mandatory AST-first quality gate

This is a dependency rule for **every remaining TDD task** that changes Parser
actions, Sema, canonical AST nodes/types/traits, Seal/verifier, CodeGen input,
snapshot publication, or Cache V2 AST restoration. The full rule, test matrix,
and exact command forms are in `attachments/ast-first-test-gate-2026-08-23.md`.
The task-to-suite rollout and mandatory evidence card are in
`attachments/ast-first-gate-rollout-2026-08-23.md`. It intentionally sits
before implementation sections: a green end-to-end `.as -> VM` test is not
permission to skip an AST-authority assertion.

**Task protocol.** For every applicable unchecked item, the implementer first
adds a gate card to its progress attachment and checks its red AST test. The
card is then advanced in order: `AST-red` → `AST-green` →
`CodeGen/provenance-green` → `lifecycle-green` (only for crossed boundaries) →
`focused-regression-green`. A gate card is not a box to cosmetically copy into
an old attachment; it must name the exact new test method, source fixture,
sealed/public AST facts, command/report path, and any remaining unsupported
surface. Production source changes are forbidden before the `AST-red` record,
apart from the test/diagnostic scaffolding necessary to make that observation.
An existing AST test may be nominated only when its assertions already prove
the new fact; a pipeline enum, bytecode dump, legacy compiler result, or VM
output alone never qualifies.

- [x] 0.1 <!-- TDD-process --> Record the AST-first gate in this change's design and task graph. Each semantic slice starts with a failing assertion against the sealed canonical AST (or public immutable view), then proves the semantic fact before adding CodeGen execution coverage. A legacy compiler result, pipeline flag, or dump that does not assert the relevant fact is insufficient.

  Recorded 2026-08-23 after current work exposed three failures whose first reliable signal was the AST layer: a nested parameter `const` was confused with a method qualifier, const/non-const receiver selection lacked a resolved semantic rule, and `ETeam::Red` lost its enum type before overload resolution. See the attachment for the mandatory triage and evidence sequence.

- [ ] 0.2 <!-- TDD --> For every still-open semantic/cutover item in sections 2–10 and 13–14, create and advance its focused AST-first gate card before changing production lowering, persistence, or publication. The evidence must name the test source and exact method, source fixture, asserted sealed/public AST facts, red baseline, and green `SemaAuthority` / Frontend / Snapshot / Cache-AST result as applicable. Then name the relevant CodeGen/publisher and lifecycle result. A task may not be checked while any required card stage remains absent, skipped, or green only through legacy emission.

  Progress 2026-08-29: Approach A's interface-dispatch card is complete from
  AST-first RED through semantic edges, verifier, Sidecar V8, detached and
  Prepared Runtime projection, VM execution, failure/retry, Hot Reload and
  broad regressions. Final gates are interface Sema **6/6**, interface Runtime
  **9/9**, Cache ASTBodySidecar **23/23**, ProductionCodeGen **135/135**,
  Compiler CanonicalAST **614/614**, Frontend CanonicalAST **175/175**, Module
  Snapshot **10/10**, StaticJIT primary **12/12**, Hot Reload **12/12**, and
  build PASS. This completes one gate card, not every still-open semantic/
  cutover item required by 0.2, so the umbrella stays unchecked. Evidence:
  `attachments/canonical-interface-publication-gate-2026-08-29.md`.

  Progress 2026-08-30: CTA-S69 applied the revised risk-clustered TDD cadence
  to custom access metadata. Review first produced complete Stage 2 integrity
  and Parser OOM matrices; authenticated REDs were **128/131** plus one
  compile-time missing-seam failure. A final self-ID mutation cluster then
  produced exactly two intended failures (**131/133**) and closed at
  ProductionCodeGen **133/133**. Final review then grouped owner/field/method
  embedded-self-ID authentication into one RED with exactly three intended
  failures (**147/150**) and closed at **150/150**. SemaAuthority is
  **436/436**, Compiler CanonicalAST **631/631** and Frontend CanonicalAST
  **175/175**. The review-found `AS_NO_COMPILER` reset/member guard mismatch was
  also mechanically aligned; no deferred Standalone/no-compiler gate is
  claimed. This is one
  additional completed gate card, not all still-open semantic/cutover cards,
  so 0.2 remains unchecked. Evidence:
  `attachments/canonical-access-specifier-runtime-projection-transaction-gate-2026-08-30.md`.

  Progress 2026-08-30: CTA-S72 completed the call-argument authority card.
  Sema now seals exact direct/indirect formal identity, canonical formal type,
  origin, authored name/order/range and final converted expression; publication
  rejects incomplete or impossible records; CodeGen consumes the authenticated
  plan; Sidecar V9 preserves it and treats V8 as a safe miss. The adjacent
  generated-trait Cache restore and prepared-dispatch regressions are also
  closed. Final gates are Compiler CanonicalAST **634/634**, Frontend
  CanonicalAST **181/181** and Cache **584/584**, with build PASS. This closes
  one gate card, not every remaining semantic/default-cutover card, so 0.2
  remains unchecked. Evidence:
  `attachments/canonical-call-argument-provenance-gate-2026-08-30.md` and
  `attachments/cta-s72-cache-staticclass-canonical-rebuild-progress-2026-08-30.md`.

  First applied 2026-08-23 to resolved floating-point type authority. The new AST-front test failed before the repair on a `const float` namespace global, proving that the parser-resolved `ttFloat64` token had been lost when Sema round-tripped through the spelling `float`. It was then applied a second time to mixed-width comparison and function-return ABI normalization: the sealed graph initially lacked the `float32 -> float64` comparison conversion / `bool` result, while the active incremental Parser statement path did not normalize `return 2.0f` to a `float` (`float64`) signature before CodeGen copied it into the return slot. The current completed evidence sequence is: SemaAuthority **255/255**, ProductionCodeGen **69/69**, Cache V2 ASTBodySidecar **12/12**, and the broad CanonicalAST execution suite **352/352**. The permanent focused tests are `CompileSealFloatGlobalConstantsFreezeResolvedStorageWidths`, `CompileSealDefaultFloatComparisonNormalizesOperandWidths`, `CompileSealDefaultFloatReturnNormalizesToSignatureWidth`, `CanonicalFloatNamespaceGlobalInitializesExecutesAndPublishesCodeGen`, `SidecarRoundTripPreservesResolvedFloatWidthsAndConstantBits`, and `SidecarRoundTripPreservesMixedWidthComparisonNormalization`. Detailed red/green evidence and the resulting rule are in `attachments/ast-first-test-gate-2026-08-23.md`. This is enforcement evidence for two semantic slices, not a claim that every still-open cutover item is now gated.

- [x] 0.2a <!-- TDD --> Apply the gate end-to-end to one semantic fact that crosses Sema, CodeGen, and Cache V2. Use a failing sealed-AST assertion first; retain it after lowering and persistence become green.

  Closed 2026-08-23 by the resolved float-width / constant-storage case described under 0.2. The same gate was immediately exercised again by mixed-width comparison and function-return ABI normalization. In both cases the sealed-AST assertion preceded the lowering/persistence work and isolated the semantic fact before the VM symptom was used for diagnosis.

- [x] 0.2b <!-- TDD-process --> Refactor the remaining task graph into an AST-first gate rollout: define the required gate-card fields, route each open task family to an owning AST test group, distinguish source-path semantic tests from hand-built verifier tests, and define which downstream layer is mandatory before completion.

  Closed 2026-08-23 in `attachments/ast-first-gate-rollout-2026-08-23.md`.
  The attachment is normative for unchecked compiler tasks. It prevents the
  prior failure mode where an end-to-end test was introduced first, a lowering
  workaround masked a malformed graph, and a task was checked without ever
  testing the representation it claimed to make authoritative.

- [ ] 0.3 <!-- Non-TDD --> Before any default-pipeline change, run and record the complete AST gate matrix (Frontend CanonicalAST, Compiler CanonicalAST including SemaAuthority, Module Snapshot, Hot Reload snapshot, and the Cache V2 default-disabled boundary). Opt-in Cache V2 retention/restore prototypes are non-blocking regressions. A broad legacy-compatible SDK/All pass cannot substitute for this gate.

  The final record must enumerate every gate card created under 0.2, including
  its retained AST test and current report path. It must separately show that
  canonical CodeGen published the executable artifact where code generation is
  claimed; a shared source-to-VM result is not proof of backend provenance.

### Why implementation drifted, and why boxes were falsely checked

The reconciled sequence is: baselines → scaffold beside `asCCompiler` → move lookup/overload/conversion/lifetime *out of* the CANONICAL dependency chain into Sema/AST → Canonical backends consume only that sealed graph → delete TypedSemantic HIR → flip the product default while isolating the retained explicit LEGACY path. The 2026-08-27 scope revision replaces native-path deletion with LEGACY isolation; Task 9.9 said the canonical default stays off until Canonical independence is true.

The following was the historical drift sequence through the original review:
add AST/Sema/CodeGen *files* beside the old compiler → keep `asCCompiler` as
the only full-language Bytecode emitter → flip `ep.canonicalCompilerPipeline`
and `IsCanonicalBytecodeCodeGenReady()` anyway → rewrite tasks 10.4–10.7 so
leftover internals became “locks” instead of unfinished work → copy
legacy-prefix pass counts into cutover evidence → leave 12.6 (reconcile specs
vs tasks) for last. The current CANONICAL `Build()` now performs
`SealCanonicalAST()` → `asCBytecodeCodeGen::Generate()` into a candidate
module → promotion for its supported subset. That removes the old
“flag-only/no-Generate caller” premise, but does **not** prove complete
semantic authority, detached artifact installation, or all-language coverage;
those remain open under sections 4–10 and 13.

Three substitutions produced 虚标:

1. **Files + green legacy prefixes replaced authority.** Parser still builds
   `asCScriptNode`; Sema still has parser-node walks and incomplete scope/type
   authority. The current canonical-selected `Build()` calls CodeGen, whereas
   the LEGACY path still calls `BuildCompileCode()`. Prefixes such as Compiler
   203/203 can still pass because `asCCompiler` works; without sealed-AST and
   publisher assertions they are not proof that the full canonical
   Sema/Bytecode migration has taken over.
2. **Task text was lowered to match the code, specs were not.** When CodeGen could not replace `asCCompiler`, the honest state was `[ ]` on 10.4–10.7. The record instead rewrote those tasks to “lock residuals” and checked them. Specs still require production CodeGen from sealed AST and no production semantic use of `asCScriptNode`.
3. **Tests asserted flags and compatibility, not the backend.** Cutover tests check the pipeline enum and that the script executes. Cache tests accept `{1}` as AST bytes. Public-view tests pass a zero-init struct and expect a full overwrite. CompileFunction tests lock “snapshot generation unchanged” without checking completeness. TDD went green on the shadow contract.

Full mapping and examples: `attachments/record-reconciliation.md`. The
2026-08-22/24 async packages in `attachments/async-work.md` and
`attachments/next-work.md` are historical checkpoints, not the current task
status. Their then-open 4.2 and 5.4 rows were closed by later dedicated gates;
Task 5.4's current closure is recorded in
`attachments/canonical-sequencing-single-evaluation-closure-gate-2026-09-01.md`.
The still-open rows and exact current reasons are the `[ ]` items below. Do not
reopen a checked row or check an open umbrella from prefix counts or dump greens
alone.

## 1. Freeze semantic and differential baselines

- [x] 1.1 <!-- TDD --> Add `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalCompilerDifferentialTests.cpp` and support in `AngelscriptNativeTestSupport.h` that compile the same inline source in isolated legacy/canonical-selection Engines, initially failing because canonical selection does not exist. Cover compile result, diagnostics, VM return/exception, globals, and side-effect trace. Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label canonical-ast-differential-red -TimeoutMs 600000` and require the new canonical-selection cases to fail for the expected missing-pipeline reason.
- [x] 1.2 <!-- TDD --> Add normalized baseline helpers in `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Support/AngelscriptNativeCanonicalASTTestSupport.h` for diagnostics, execution traces, cleanup traces, stable dependencies, debug positions, and semantic dumps. Adapt representative current HIR tests without deleting them. Run the Compiler prefix and require existing fixtures to remain green.
- [x] 1.3 <!-- TDD --> Add Parser/Builder declaration baselines under `AngelScriptSDK/Frontend/CanonicalAST/` for namespaces, classes, interfaces, enums, funcdefs, imports, globals, properties, methods, constructors/destructors, default arguments, mixins, lambdas, list patterns, source recovery, and depth/cartesian guards. Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend" -Label canonical-ast-frontend-baseline -TimeoutMs 600000`.
- [x] 1.4 <!-- TDD --> Add VM behavior matrices for evaluation order, reverse formal argument order, named/default/hidden arguments, property rewrites, mutation single-evaluation, loops/switch transfers, cleanup/destruction, exceptions, safe points, imports, and mutable/constant globals under `AngelScriptSDK/Compiler/CanonicalAST/Semantics/`. Run the Compiler prefix and record no new skips/disabled cases.
- [x] 1.5 <!-- TDD --> Add StaticJIT baseline assertions under `AngelscriptTest/StaticJIT/TypedASTJIT/CanonicalASTMigration/` that enumerate every currently supported HIR node/call/cleanup/route capability and every current typed fallback category. Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT" -Label canonical-ast-staticjit-baseline -TimeoutMs 600000`.
- [x] 1.6 <!-- Non-TDD --> Add `attachments/semantic-contract-matrix.md` to this change, mapping every baseline category to its source tests, canonical AST requirement, Bytecode consumer, StaticJIT consumer, Cache consumer, and final legacy-removal gate. Keep execution logs out of `tasks.md`.

## 2. SourceManager and canonical AST foundation

- [x] 2.1 <!-- TDD --> Add failing tests in `AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeSourceManagerTests.cpp` for stable logical section identity, snapshot-local file IDs, authored/processed/generated ranges, line-offset mapping, generated-source provenance, invalid range rejection, and deterministic remap. Run the Frontend prefix and require missing `asCSourceManager` failures.
- [x] 2.2 <!-- TDD --> Implement `as_source_manager.h/.cpp` in the maintained fork and route current parser/compiler diagnostics through `asCSourceLocation/asCSourceRange` without changing maintained messages. Add the sources to `Plugins/Angelscript/Standalone/CMakeLists.txt`. Re-run the SourceManager tests and existing parser source-range/recovery tests.

  Closed 2026-08-23: `asCSourceManager` is compiled by Standalone and keeps
  byte-sensitive/remap-safe snapshot-local source identity. Parser token
  messages, Builder source diagnostics (including the enum overflow semantic
  error), and `asCCompiler::{Error,Warning,Information,PrintMatchingFuncs}`
  all obtain coordinates through `asCBuilder::GetDiagnosticRowColumn()`.
  That bridge first records/reads `asCSourceLocation` from the Builder source
  session and deliberately falls back to `asCScriptCode::ConvertPosToRowCol`
  only when source capture is impossible or a conflicting same-name input was
  rejected, preserving maintained user-facing section/row/column messages.
  The AST sidecar serializes the source records (logical key, origin, line
  offset, bytes); public snapshot source APIs are covered under 3.2. Focused
  red/green evidence, exact non-diagnostic residual `ConvertPosToRowCol`
  sites, and the 8/8 + legacy 6/6 + 9/9 runs are recorded in
  `attachments/source-manager-diagnostic-gate-2026-08-23.md`. This closes
  source-coordinate diagnostic authority only; Cache V2 DTO compatibility and
  candidate publication remain separately open under 6.x/13.x.
- [x] 2.3 <!-- TDD --> Add failing tests in `AngelscriptNativeCanonicalASTContextTests.cpp` for arena ownership, translation-unit root, snapshot-local opaque IDs, foreign-ID rejection, node-kind casts, sealing, no post-seal mutation, and bulk destruction. Require missing `asCASTContext/asCDecl/asCStmt/asCExpr` failures.
- [x] 2.4 <!-- TDD --> Implement `as_ast_fwd.h`, `as_ast_context.h/.cpp`, `as_decl.h/.cpp`, `as_stmt.h/.cpp`, and `as_expr.h/.cpp` with compact tagged nodes, arena allocation, child/reference ranges, explicit construction APIs, and sealed read-only traversal. Keep Unreal types out of these files. Run Frontend and Compiler prefixes.

  Closed 2026-08-21: 64 KiB slab placement-new, private `DestroyAll`, construction APIs (`SetBody`/`AddDeclChild`/`SetTarget`/…), public `GetDecl`/`GetStmt`/`GetExpr`/`GetSourceManager` const-only with privately named `Mutable*`. Sema and CanonicalAST tests write through those APIs. Snapshot `GetContext()` is const-only. Frontend CanonicalAST 58/58, HotReload CanonicalAST 5/5, Cutover 5/5 LEGACY. Node fields stay public POD for placement-new (a later friend-fields change, not this task).
- [x] 2.5 <!-- TDD --> Add failing tests in `AngelscriptNativeCanonicalASTTypeTests.cpp` for primitive, enum, funcdef, value/reference object, template/container, const/reference/handle/auto-handle/in/out/inout canonicalization and invalid qualifier combinations.
- [x] 2.6 <!-- TDD --> Implement `as_ast_type.h/.cpp` with `asCType/asCQualType/asASTTypeRef` interning and `as_runtime_type_bridge.h/.cpp` mapping current Engine `asCDataType/asCTypeInfo/typeId` views to stable AST type keys. Prove public/cache identity contains no Engine pointer or numeric ID.

  Closed 2026-08-21: `FromDataType` classifies ENUM / FUNCDEF / TEMPLATE / VALUE / REF from Engine flags (not handle-as-kind); `stableKey` is namespace-aware `Format` without typeId/pointer; null handle is `void`+handle; QualType layout stays intern-id + quals. Qualifier intern tightening was already landed. Evidence: Type prefix `wave-c-26-green` 13/13. Sema still invents named kinds from parse nodes (task 4.3) and sidecar still force-VALUE_OBJECT (6.3) — those are not this box.
- [x] 2.7 <!-- TDD --> Add malformed-graph and deterministic-dump failures in `AngelscriptNativeCanonicalASTVerifierTests.cpp` and `AngelscriptNativeCanonicalASTDumpTests.cpp` for dangling/foreign/wrong-kind IDs, invalid types/ranges/children/owners, address-free dumps, and repeated-build equality.
- [x] 2.8 <!-- TDD --> Implement `as_ast_verifier.h/.cpp` and `as_ast_dump.h/.cpp`; verification must run before seal publication and return stable category, source range, and detail token. Run `Tools\RunBuild.ps1 -Label canonical-ast-foundation -TimeoutMs 1800000 -NoXGE`, then the Frontend and Compiler prefixes.

  Closed 2026-08-21: `asCASTVerify` rejects stmt-id/expr-id, decl parent/child + decl-cycle, stmt-multi-owner, stmt-cycle, break-ancestor, fallthrough-switch, expr type/value-category/operand, and CLEANUP `resolvedDecl` that is not a destructor. `asCASTVerifyPublication` emits `UNSEALED_PUBLICATION`; `asCASTVerify` still accepts unsealed graphs so `Seal()` works. Hard no: CALL/CONSTRUCT missing callee. Evidence: Verifier 13/13 (`wave-c-28-green`), Frontend CanonicalAST 63/63, Compiler CanonicalAST 37/37. Dump remains address-free. Do not invent stmt-level cleanup-plan fields (CLEANUP/MATERIALIZE are expr kinds).
- [x] 2.9 <!-- TDD --> Add `as_ast_traversal.h/.cpp` and `AngelscriptNativeCanonicalASTTraversalTests.cpp` for one generic const Decl/Type/Stmt/Expr traversal with named edge roles, deterministic pre/post order, depth/budget/cycle guards, and an on-demand parent/edge index over a sealed context. Cover source-built and malformed hand-built graphs, then migrate verifier/dump plus at least one canonical TypedASTJIT walk to the shared traversal without changing eligibility. Run Runtime build, Frontend CanonicalAST, and the focused TypedASTJIT prefix.
  Completed 2026-08-23: the shared internal traversal now exposes first-class Decl/Type/Stmt/Expr node refs, named structural/reference edges, deterministic pre/edge/post visitation, consumer edge filtering, full-context one-visit inventory traversal, target-validation controls, and bounded depth/node/cycle failure. `asCASTParentEdgeIndex` builds only over sealed contexts and answers unique structural-parent plus deterministic incoming-edge queries without following semantic-reference cycles. Verifier stmt/expr cycle checks, the compatibility flat dump inventory, and TypedASTJIT canonical eligibility now consume the shared traversal; receiver descent remains explicitly skipped in eligibility to preserve the prior reviewed behavior. Array edge slots preserve malformed zero IDs instead of treating them as absent optionals. Fresh gates: Runtime/Editor build succeeds; Frontend CanonicalAST **114/114**; complete `Angelscript.TestModule.StaticJIT.TypedASTJIT` **64/64**; Standalone **21/21**. The Standalone run first exposed an unrelated completed-8.4 violation where a failure diagnostic borrowed `GetCanonicalASTContext()` only to print `PendingCanonicalAST`; that raw read/log field was removed and the architecture gate then passed. Evidence and edge model: `attachments/ast-traversal-parent-edge-index-2026-08-23.md`.
- [x] 2.10 <!-- TDD --> Extend canonical inspection with deterministic tree text and JSON while preserving the flat compatibility dump. Add filters for module, stable declaration key, node ID/kind, and logical source; include exact types, traits, named edges, resolved targets, line/column and optional source snippets. Add `AngelscriptNativeCanonicalASTStructuredDumpTests.cpp` proving repeated-build equality, escaping, filter closure, address/Engine-ID absence, and explicit diagnostic-only/non-Cache status. Run Frontend CanonicalAST and Cache ASTBodySidecar regressions.

  Completed 2026-08-23: `asCASTStructuredDump` now provides deterministic hierarchical text and valid JSON over sealed contexts while retaining the old flat dump unchanged. Exact module/stable-key/node-class+ID/kind/logical-source filters preserve structural ancestors and matched subtrees; semantic references remain named target metadata without importing unrelated sibling subtrees. Nodes include exact canonical type key/kind/qualifiers, numeric traits, source line/column/end, and opt-in byte-bounded snippets. Both formats explicitly state `diagnosticOnly=true` and `cacheInput=false` and tests exclude raw addresses/Engine-local IDs. TDD evidence: expected missing-API RED; focused **3/3**; complete Frontend CanonicalAST + Cache ASTBodySidecar **129/129** (117 AST + 12 sidecar); Standalone **21/21**. Design, Clang comparison, filter closure, and paths: `attachments/structured-ast-dump-2026-08-23.md`.
- [x] 2.11 <!-- TDD --> Enrich verifier diagnostics with offending node kind/ID, edge role, related target, logical source line/column, deterministic root-to-node path, and a bounded local subtree. Add `AngelscriptNativeCanonicalASTVerifierDiagnosticTests.cpp` covering dangling/foreign/wrong-kind/cycle/owner/control/call/cleanup failures and proving failed publication remains mutation-free. Keep stable category/detail compatibility. Run Runtime build, Frontend CanonicalAST, Module Snapshot, and Cache ExactWarm negative gates.

  Completed 2026-08-23: all verifier failure sites now retain category/detail/range compatibility while recording a snapshot-local offending D/T/S/E node and kind, named edge, related target/kind, logical source line/column, deterministic structural TU path, and a local dump bounded to 8 nodes/16 edges/3 levels with explicit truncation. Dangling targets are reported but not followed; detached nodes use `unreachable:<node>`. Conditional formatting keeps manually constructed legacy one-line results byte-compatible. Tests cover dangling/foreign/wrong-kind/owner/control/cycle/call/cleanup and prove failed sealed call publication is count-, Seal-, and dump-mutation-free. Focused **4/4**; complete Frontend CanonicalAST + Module Snapshot + Cache ExactWarmStartup **145/145**; Standalone **21/21**. The first combined run was externally cut off at 131 green tests and is not evidence; the recorded run is the complete rerun. Details: `attachments/verifier-path-diagnostics-2026-08-23.md`.
- [x] 2.12 <!-- TDD --> Add a compact AngelScript-native query/matcher/assertion layer in `AngelscriptNativeCanonicalASTTestSupport.h` (unique decl by stable key, exact type/qualifiers, named child edge, resolved callee/receiver, conversion, control target, cleanup, source range) and extend `asCASTShadowDiff` to compare Decl/Type/Stmt/Expr facts with a first deterministic mismatch path. Migrate representative brittle dump-substring SemaAuthority tests without weakening their facts. Do not implement Clang's full generated/dynamic matcher DSL. Run SemaAuthority, Frontend CanonicalAST, and isolated differential tests.

  Completed 2026-08-23: test support now provides exact stable-decl, QualType, named-edge, resolved/no-callee, receiver, conversion, control-target, cleanup, and logical-source-range queries with typed node/related refs, cardinality, and precise failures. Unique facts reject 0/many; cleanup correctly accepts one-or-more exit-path sites and reports `MatchCount`. `asCASTShadowDiff` compares deterministic Source/Type/Decl/Stmt/Expr facts and returns the first structural path/field/value mismatch without addresses, snapshot-owner values, or Engine IDs. Representative overload, conversion, continue-target, and destructor-cleanup SemaAuthority assertions no longer parse dump text; old Shadow tests now assert `.parent/.type/.traits/.range/.dependencies[i]` paths. Expected missing-API RED; isolated **2/2**; SemaAuthority **256/256**; Frontend CanonicalAST **123/123**; Standalone **21/21**. The initial 255/256 run exposed and corrected the invalid unique-cleanup assumption without deleting valid AST facts. Details: `attachments/typed-ast-matchers-and-shadow-diff-2026-08-23.md`.
- [x] 2.13 <!-- TDD --> Expose developer/commandlet read-only AST diagnostics equivalent to `list`, filtered `dump`, `verify`, `query`, and `diff`, with Standalone-compatible output where the host has a retained snapshot. Every operation must acquire/release an immutable snapshot lease, identify module/generation/provenance, refuse mutation, and keep JSON/text/DOT outside Cache inputs. Add Runtime integration and Standalone tests, then run Runtime build and `Tools\RunTestSuite.ps1 -Suite Standalone`.

  Completed 2026-08-23: the maintained standard-C++ `asCASTRunDiagnostics` service now owns deterministic text/JSON `list`, filtered structural `dump`, publication `verify`, exact-match `query`, and complete semantic `diff`. Every module read goes through an operation-local public V1 snapshot lease; tests prove the internal reference count returns exactly to its anchor value and the AST flat dump remains byte-identical. Snapshot-owned internal provenance distinguishes `source-build` from `cache-v2-restore` without changing public AST V1 or Cache identity. Runtime exposes the mutation-refusing `as.AST` console parser; `UAngelscriptASTDiagnosticsCommandlet` reuses it and can log or write diagnostic-only UTF-8 output. A real commandlet `list` run completed successfully. All envelopes state diagnostic-only/non-Cache/read-only/mutation-refused status; exact query does not include dump closure, and every operation's JSON parses successfully. Final Runtime build succeeds; focused **3/3**, Snapshot **9/9**, Cache ExactWarmStartup **15/15**, and Standalone **21/21** pass. DOT remains reserved for the later typed-CFG stage and inherits the same non-Cache boundary. Details and commands: `attachments/read-only-ast-diagnostics-2026-08-23.md`.

## 3. Public AST V1, module ownership, and Hot Reload leases

- [x] 3.1 <!-- TDD --> Add compile-time/public-header tests in `AngelScriptSDK/Module/AngelscriptNativeASTSnapshotAPITests.cpp` for `asEASTRetentionPolicy`, opaque ID types, `structSize/apiVersion` POD views, `asIASTSnapshot`, and the three `asIScriptModule` methods. Require failure before editing public `Core/angelscript.h`.
- [x] 3.2 <!-- TDD --> Add the exact V1 declarations from `design.md` to `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h`; implement internal snapshot adapters in maintained-fork `as_module.h/.cpp` and `as_ast_public_view.h/.cpp`. Keep concrete node layouts and Engine-local pointers private. Re-run public-header and Native SDK Module tests.

  Closed 2026-08-23: V1 now exposes snapshot-owned source-file IDs/ranges, source metadata and line/column mapping, public kinds/qualifiers/traits/value categories, Decl/Stmt/Expr semantic edges, and one-child-at-a-time traversal. Every view validates full `structSize`; zero means the V1 convenience request and an explicit non-V1 `apiVersion` fails closed without output. Node/source IDs carry a snapshot owner. Concrete node and Engine pointers remain private. Evidence: traversal red build, version red test, final build, and Snapshot group **8/8** in `attachments/public-ast-v1-semantic-snapshot-contract-2026-08-23.md`.
- [x] 3.3 <!-- TDD --> Add module tests for policy selection before `Build()`, policy freeze at build start, post-build change rejection, retain/discard behavior, unsupported API version, null acquisition without retained/restored AST, and AddRef/Release balance.
- [x] 3.4 <!-- TDD --> Implement module-owned `asCASTSnapshotStorage` and retention in `as_module.h/.cpp`; every CANONICAL source build owns AST through Bytecode CodeGen, discard policy releases bodies afterward, and retain policy publishes only a sealed verified snapshot.

  Closed 2026-08-30 for the CANONICAL source-build scope. The concrete
  `asCASTSnapshot` is the module-owned storage: policy freezes at build start;
  CANONICAL `Build()` seals/verifies a candidate Context, emits detached
  Bytecode from that exact Context, and publishes executable + snapshot only
  after success; discard consumes the same Context and exposes no public
  snapshot. Missing pending Context now fails closed instead of fabricating an
  empty translation unit. Snapshot-preparation failure after a valid
  generation proves the exact previous executable and snapshot remain current,
  while successful replacement and public leases preserve older generations.
  Public CANONICAL `CompileFunction()` is separately verified as node-free and
  does not advertise an incomplete module snapshot. The explicit LEGACY path
  and native AngelScript AST remain intentionally available; their physical
  removal is a separate future OpenSpec and is not a reason to keep this
  CANONICAL ownership task permanently open. Evidence: Snapshot **12/12** plus
  focused RED/GREEN and lifecycle details in
  `attachments/cta-s73-s75-snapshot-builder-authority-cache-lifetime-and-typedjit-audit-2026-08-30.md`.
- [x] 3.5 <!-- TDD --> Add `AngelscriptTest/HotReload/AngelscriptCanonicalASTSnapshotReloadTests.cpp` for generation A leases surviving successful generation B publication, `IsCurrentGeneration`, old snapshot traversal, failed replacement preservation, and final storage destruction after the last lease.
- [x] 3.6 <!-- TDD --> Integrate immutable AST snapshot leases into `AngelscriptRuntime/Core/AngelscriptEngine` module replacement/Hot Reload publication. Cross-module references must remain stable-key based and old snapshots must not resolve through mutable current-module pointers.
- [x] 3.7 <!-- TDD --> Added concurrent successful-rebuild acquisition and failed-rebuild preservation coverage in `AngelscriptNativeASTSnapshotAPITests.cpp`; verified the existing locked Acquire/candidate-first publication protocol and recorded the 9/9 focused result in `attachments/snapshot-publication-protocol-audit-2026-08-23.md`.

  Why this is still open: Hot Reload tests acquire generation A *before* replacement and then walk it; they do not race Acquire with publish, and they do not fail a replacement and prove the previous generation stayed current. `AcquireASTSnapshot` reads a raw `astSnapshot` pointer and only then `AddRef`s — a publisher can Release/delete between those operations. `currentGeneration` is a plain `bool`. `PublishCanonicalASTSnapshot` invalidates and Releases the previous snapshot *before* sealing/allocating the replacement, so a failed seal loses the last good graph. StaticJIT generation stores a raw `const asCASTContext*` instead of an `asIASTSnapshot` lease. It was checked because sequential lease tests passed, which is not a concurrency protocol (review R06).
- [x] 3.8 <!-- Non-TDD --> Run `Tools\RunBuild.ps1 -Label canonical-ast-public-snapshot -TimeoutMs 1800000 -NoXGE`, `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Module" -Label canonical-ast-public-api -TimeoutMs 600000`, and `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload" -Label canonical-ast-hot-reload -TimeoutMs 600000`.

## 4. Declaration, namespace, and type Sema migration

- [x] 4.1 <!-- TDD --> Add failing canonical declaration-dump tests for all Task 1.3 forms, including stable owner keys, declaration order, source ranges, access/trait metadata, default argument ownership, mixin origins, import modules, and type qualifiers.
- [x] 4.2 <!-- TDD --> Implement `as_sema.h/.cpp`, `as_sema_decl.h/.cpp`, and typed Parser Sema-action entry points for translation unit, namespace, typedef, enum, funcdef, interface, class, function, method, constructor/destructor, variable, property, import, and parameter declarations. Initially shadow current `asCBuilder` registration and compare results. The native Parser MAY continue building `asCScriptNode` for syntax/recovery and the explicitly selected LEGACY path, but CANONICAL declaration semantics MUST NOT be reconstructed by walking it.

  Why this is still open: retaining a complete native `asCScriptNode` syntax
  tree is now intentional and is not itself incomplete. Lambda headers and
  explicit typed parameters use exact typed actions, but lambda/body and
  general expression/statement adapters still consume Parser
  nodes for meaning. Builder remains production declaration authority. Script
  `funcdef` stays fork-rejected. Not Clang action-only Sema for the language.

  Progress 2026-08-22: param identity GREEN; enumerator intern GREEN. Leftover `snVariableAccess` / `snFunctionCall` / `snExprTerm` FromNode peeled (`InternParsedDeclRef` / `InternParsedCall` / `InternParsedExprTerm`). Term identity GREEN **208/208** `wave-b-term-sema2` after dropping whole-term CALL FindExisting. Builder remains production declaration authority. Production Bytecode still `asCCompiler`. **Not 4.2/13.2 close.**

  Progress 2026-08-27: namespace-path creation now crosses a typed segment
  payload with SourceManager ranges; `WalkOne` no longer handles
  `snNamespace`. Removing that replay exposed and then repaired a hidden
  post-body dependency for namespace children. Final SemaAuthority is
  **309/309** and ProductionCodeGen is **114/114**. Function/class/etc. still
  use a transitional completed-child Parser-node callback until each family
  gains a typed finish action, so 4.2 remains unchecked. Evidence:
  `attachments/canonical-namespace-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: enum and enumerator declaration identity now crosses
  validated typed name/range actions; `WalkOne` no longer handles `snEnum` and
  the generic completed-declaration callback excludes enum. Final
  SemaAuthority is **310/310** and ProductionCodeGen is **114/114**.
  Enumerator initializer expressions remain a named Parser-node adapter, and
  other declaration/type/expression/statement families remain transitional,
  so 4.2 stays unchecked. Evidence:
  `attachments/canonical-enum-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-09 removes `snTypedef` declaration replay for the
  fork's existing non-void primitive typedef grammar. Parser publishes the
  alias name, exact range, and Parser-resolved primitive token through a typed
  action before `;`; the generic completion callback excludes typedef. Final
  SemaAuthority is **311/311** and ProductionCodeGen is **114/114**. General
  type payloads and the remaining declaration families keep 4.2 unchecked.
  Evidence:
  `attachments/canonical-typedef-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-10 removes `snImport` declaration replay.
  Parser publishes a typed signature before parameters and a typed origin
  before `;`; parameters attach under the exact import context. `WalkOne` has
  no `snImport` case and `ParseImport()` has no whole-node notification. The
  required backend gate found and repaired a missing prepared-shell stable key
  through an explicitly non-semantic producer identity bridge. Final
  SemaAuthority is **313/313** and ProductionCodeGen is **114/114**. General
  return-type/parameter payloads and remaining declaration families keep 4.2
  unchecked. Evidence:
  `attachments/canonical-import-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-11 removes ordinary function-family
  `snFunction` replay for globals, methods, constructors/destructors, mixins,
  locals and interface methods. Parser publishes typed signature/traits around
  an exact parameter context and uses only a body-specific adapter after a
  complete body. Generic completion excludes ordinary functions,
  `WalkOne(case snFunction)` is lambda-only, and the obsolete
  `ActOnFunctionLike` decoder is deleted. Final SemaAuthority is **315/315**,
  ProductionCodeGen **114/114**, and Parser declarations **18/18**. General
  type/parameter/default/body actions and other declaration families keep 4.2
  unchecked. Evidence:
  `attachments/canonical-function-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-12 removes class/struct/interface whole-record
  replay. Parser publishes typed header, complete ordered qualified-base and
  real-`}` finish actions; Sema owns record kind/type, exact base edges,
  dependencies and generated lifecycle/accessors. `WalkOne` has no class or
  interface cases and the old recursive base decoder is deleted. Final
  SemaAuthority is **317/317**, ProductionCodeGen **114/114**, and Parser
  declarations **18/18**. Member fields/properties/defaults/funcdefs and
  general type/parameter/body actions keep 4.2 unchecked. Evidence:
  `attachments/canonical-record-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-13 removes global/field whole-declaration
  replay. Parser publishes one typed header and exact initializer action per
  comma-separated declarator; private/protected traits cross the header, the
  generic/class callbacks no longer notify the declaration shell, and the
  residual walker fails closed for global/field owners. A full backend RED
  also repaired folded global default `41` being overwritten by source literal
  `40`. Final SemaAuthority is **319/319**, ProductionCodeGen **114/114**,
  and Parser declarations **18/18**. Local declarations, properties/defaults/
  funcdefs and general type/parameter/body actions keep 4.2 unchecked.
  Evidence:
  `attachments/canonical-global-field-variable-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-14 removes the remaining local/`for`/`foreach`
  declaration-shell replay. Parser publishes one typed header and exact
  initializer action per local/`for` declarator, finishes an exact-range
  statement sequence, and publishes `foreach` identity without default
  construction. Normal sequences flatten into their enclosing block while
  `for` declarations retain loop scope; missing exact actions fail closed.
  All maintained-fork Sema `case snDeclaration:` decoders are absent. Final
  SemaAuthority is **321/321**, ProductionCodeGen **114/114**, and Parser
  declarations **18/18**. Properties/defaults/funcdefs, general type/parameter/
  body actions, lambdas and remaining expression/statement/lifetime adapters
  keep 4.2 unchecked. Evidence:
  `attachments/canonical-local-loop-variable-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-15 removes class-default whole-node replay.
  Parser starts/reuses one generated `__InitDefaults` method before parsing
  the authored statement, enters that exact DeclContext, then finishes by
  exact method owner and complete source range. Multiple defaults attach once
  in source order; missing exact routing fails closed. Final SemaAuthority is
  **324/324**, ProductionCodeGen **114/114**, and the synthesized-default
  TypedSemanticIR boundary is **1/1**. Properties/access groups/funcdefs,
  general type/parameter/body actions, lambdas and remaining expression/
  statement/lifetime adapters keep 4.2 unchecked. Evidence:
  `attachments/canonical-class-default-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-16 removes retained Parser `funcdef` whole-node
  replay without enabling the fork-rejected script keyword. Parser publishes
  typed callable identity/return type before parameters, enters the exact
  FuncDef DeclContext, and no completed `snFuncDef` callback or decoder remains.
  Final SemaAuthority is **326/326**, ProductionCodeGen **114/114**, script
  Parser/language rejection is **1/1 + 1/1**, and host registration/call/rebuild
  is **1/1**. General type/parameter/default/property/access-group/lambda/body
  and expression/statement/lifetime actions keep 4.2 unchecked. Evidence:
  `attachments/canonical-funcdef-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-17 removes custom access-declaration semantic
  replay. Parser publishes a complete pointer-free specifier/permission action
  after `;`; member headers carry the authored group name, and Sema creates one
  exact record-local DeclId edge. Verifier/traversal/public view, dump and
  Sidecar V5 preserve the new metadata. Final SemaAuthority is **329/329**,
  Snapshot **10/10**, Sidecar **18/18**, ProductionCodeGen **114/114**, and
  Parser declarations **18/18**. General type/parameter/default/property/
  lambda/body and expression/statement/lifetime actions keep 4.2 unchecked.
  Final Canonical Runtime installation also remains open. Evidence:
  `attachments/canonical-access-specifier-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-18 removes the four-Parser-node
  `ActOnParsedParam` boundary for ordinary/import/interface/funcdef
  parameters. Parser publishes the exact callable DeclId, canonical qualified
  type, name and range before an optional default; Sema owns ParamDecl
  construction and type dependency, while a complete default uses a separately
  named expression adapter. Final SemaAuthority is **331/331**,
  ProductionCodeGen **114/114**, and Parser declarations **18/18**. General
  qualified/template type production, defaults, properties, lambdas, bodies
  and expression/statement/lifetime actions keep 4.2 unchecked. Evidence:
  `attachments/canonical-parameter-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-19 removes declaration-type Parser nodes from
  the Parser-to-Sema boundary. Import/funcdef/function/interface returns,
  callable parameters, global/field/local/`for` variables and `foreach`
  variables now publish a complete spelling/token/qualifier/range action;
  Sema alone resolves its local canonical QualType. Parser has zero
  `ActOnQualTypeFromNode` calls. Final SemaAuthority is **333/333**,
  ProductionCodeGen **114/114**, Parser declarations **18/18**, and Frontend
  Type **20/20**. Residual lambda/property/default/body/expression/statement/
  lifetime adapters and final Builder/LEGACY authority keep 4.2 unchecked.
  Evidence:
  `attachments/canonical-declaration-qualtype-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-20 removes the target-type node adapter from
  primitive functional casts and object constructions. Parser publishes the
  already-resolved local QualType through exactly two transient exact
  node/section/offset bindings; missing or ambiguous bindings fail closed.
  Final SemaAuthority is **335/335**, ProductionCodeGen **114/114**, Parser
  declarations **18/18**, Frontend Type **20/20**, Conversions **17/17** and
  Expression Chain **1/1**. General expression/default/property/lambda/body/
  statement/lifetime adapters and final Builder/LEGACY authority keep 4.2
  unchecked. Evidence:
  `attachments/canonical-expression-target-type-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-21 publishes a pointer-free lambda header and
  every explicitly typed parameter under the exact returned lambda DeclId.
  `ParseLambda` no longer calls `NotifySema(node)` for the header or enters the
  body through `lastActedDecl`; the retained node adapter is body-only and
  fails closed without the exact binding. Final SemaAuthority is **337/337**,
  TypeSema **1/1**, Parser declarations **18/18**, ProductionCodeGen
  **114/114**, and Frontend Type **20/20**. Contextual lambda signature/return
  inference, untyped parameters, default/property/body/general expression/
  statement/lifetime actions and Builder/LEGACY authority keep 4.2 unchecked.
  Evidence:
  `attachments/canonical-lambda-header-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-22 physically deletes the inactive generic
  declaration replay path: Parser `NotifySema`/action counter/zero-action
  fallback, public Sema `ActOnParsedDeclaration`/`ActOnParsedScript`, and
  recursive `WalkOne`/`WalkDecls` plus replay-only helpers are absent. Final
  SemaAuthority is **339/339** and the combined TypeSema/Parser declarations/
  ProductionCodeGen/Frontend Type matrix is **152/152**. Direct declaration
  Parser-node references fall from **49** to **25**. Named property/default/
  body/expression/statement/lifetime adapters and CANONICAL dependence on
  Builder/LEGACY facts keep
  4.2 unchecked. Evidence:
  `attachments/canonical-declaration-replay-retirement-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-23 removes the completed-lambda expression/body
  replay adapter. Parser now creates one pointer-free expression action from
  the exact lambda DeclId and binds the resulting ExprId to the retained native
  syntax identity; expression and bare-statement lowering only retrieve that
  identity and fail closed when it is absent. `ActOnLambdaFromNode` and its
  child search are deleted, while a real ScriptNode-shape test locks the native
  `snFunction`/parameter-list/body tree. Final SemaAuthority is **341/341**,
  native ScriptNode shape **14/14**, Parser declarations **18/18**, and
  ProductionCodeGen **114/114**. Contextual lambda inference and the remaining
  default/property/body/general expression/statement/control/lifetime adapters
  keep 4.2 unchecked. Evidence:
  `attachments/canonical-lambda-expression-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-24 removes literal token semantics from native
  `snConstant` replay. Parser now sends copied token kind/spelling/range through
  pointer-free `asSLiteralExprAction`, binds the exact returned `ExprId`, and
  still retains the independent native node for LEGACY/reference/recovery.
  The remaining literal `ActOnExprFromNode` case is identity-only and fails
  closed; `ActOnParsedStringLiteral` is deleted. Final SemaAuthority is
  **344/344**, ProductionCodeGen **114/114**, and native ScriptNode shape
  **32/32**. Decl-ref/composite expressions and the statement/body/default/
  initializer/lifetime families keep 4.2 unchecked. Evidence:
  `attachments/canonical-literal-expression-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-25 removes declaration-reference name/scope
  semantics from native `snVariableAccess` replay. Parser sends copied
  identifier, ordered scope segments, root-scope bit, owner and range through
  pointer-free `asSDeclRefExprAction`, binds the exact returned `ExprId`, and
  still retains the independent native node for LEGACY/reference/recovery.
  `InternParsedDeclRef` is deleted; remaining Sema cases are identity-only and
  fail closed. Final SemaAuthority is **346/346**, ProductionCodeGen
  **114/114**, and native ScriptNode shape **32/32**. Eighteen general
  `ActOnParsedExpr` Parser calls plus statement/body/default/initializer/
  lifetime families keep 4.2 unchecked. Evidence:
  `attachments/canonical-decl-ref-expression-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-26 removes complete ternary semantics from
  native `snCondition` replay. Parser composes a pointer-free
  `asSConditionalExprAction` from three exact child ExprIds and copied range,
  binds the returned exact composite identity, and retains the independent
  native condition tree for LEGACY/reference/recovery. Exact-only lookup is
  now separate from structural recovery; the latter includes node kind and
  length so a parent cannot alias its first leaf by section+offset. Complete
  ternary Sema cases are identity-only and fail closed. Final SemaAuthority is
  **348/348**, ProductionCodeGen **114/114**, native ScriptNode **32/32**, and
  complete Canonical Semantics **12/12**. Parser `ActOnParsedExpr` calls fall
  from 18 to 14. Calls/member/index/cast/construct/unary/binary/assignment plus
  statement/body/default/initializer/lifetime families keep 4.2 unchecked.
  Evidence:
  `attachments/canonical-conditional-expression-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-27 removes complete assignment semantics from
  native `snAssignment` replay. Parser composes pointer-free
  `asSAssignExprAction` from exact left/right ExprIds, an owned operator
  spelling and copied range, then binds the returned exact composite identity.
  Complete assignment Sema cases are identity-only and fail closed; the
  independent native node remains for LEGACY/reference/recovery. A permanent
  source-boundary assertion was required because the old generic replay could
  otherwise publish an exact-looking assignment and mask a missing Parser
  action. Final SemaAuthority is **350/350**, ProductionCodeGen **114/114**,
  native ScriptNode **32/32**, and Canonical Semantics **12/12**. Parser
  `ActOnParsedExpr` calls fall from 14 to 12. Binary/unary/call/member/index/
  cast/construct plus statement/body/default/initializer/lifetime families
  keep 4.2 unchecked. Evidence:
  `attachments/canonical-assignment-expression-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-28 removes complete flat binary/logical
  precedence semantics from native `snExpression` replay. Parser composes a
  pointer-free `asSBinaryExprAction` from ordered exact operand ExprIds,
  copied operator token/spelling pairs and the complete range; Sema validates
  and folds the maintained-fork precedence/associativity table, then binds the
  returned exact composite identity. Complete `snExpression` Sema cases are
  identity-only and fail closed; the independent native flat tree remains for
  LEGACY/reference/recovery. Final SemaAuthority is **352/352**,
  ProductionCodeGen **114/114**, Canonical Semantics **12/12**, and native
  ScriptNode **32/32**. The subsequent same-operator exact-child repair makes
  final SemaAuthority **353/353** while ProductionCodeGen remains **114/114**
  and Canonical Semantics **12/12**. Parser `ActOnParsedExpr` calls fall from
  12 to 10.
  Unary/prefix/postfix, call/member/index/cast/construct plus statement/body/
  default/initializer/lifetime families keep 4.2 unchecked. The bounded
  range-less direct-action interning edge CTA-S28-I2 is closed by
  conversion-normalized exact-child reuse. Evidence:
  `attachments/canonical-binary-expression-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-29 (CTA-S54): the residual build-local
  `asCScriptNode* -> DeclId/ExprId/QualType` storage is removed from Canonical
  Sema. Parser and prepared Builder shells now copy one exact transient
  `section + nodeKind + offset + length` value; same-value binds are
  idempotent, conflicting Decl/Expr/Type binds diagnose and fail closed, and
  completed declaration/cast/construct ranges are bound only at their correct
  grammar phase. `as_sema.h/.cpp` contain zero `asCScriptNode`, `firstChild`,
  `lastChild`, or `->next` references. Final build passes, SemaAuthority is
  **405/405**, and ProductionCodeGen + Module Snapshot + TypedASTJIT are
  **186/186 PASS**. This closes the pointer-lifetime/identity sub-boundary, not
  the complete declaration-family inventory and Sema environment, so 4.2
  remains unchecked. Evidence:
  `attachments/canonical-pointer-free-parse-action-identity-gate-2026-08-29.md`.

  Closure 2026-08-29 (CTA-S55): the accumulated CTA-S09 through CTA-S54
  declaration migrations now satisfy the complete maintained-language
  declaration inventory. Translation unit, namespace, typedef, enum,
  retained funcdef boundary, record/interface, ordinary function family,
  variable/field/local/loop, import, parameter, access and lambda headers all
  publish Canonical declarations through typed/pointer-free actions. Across
  `as_sema*`, native child traversal and all generic `ActOn*FromNode` /
  `ActOnParsed*` APIs are absent; the one textual `asCScriptNode` hit is a
  comment stating it is not revisited. Removed virtual-property syntax remains
  an explicit Parser rejection rather than a missing Canonical declaration.
  Fresh SemaAuthority is **405/405** and the corrected current Frontend Parser
  declaration prefix is **18/18 PASS**. One stale prefix run selected no tests
  and is excluded. This closes declaration action construction only; 4.3-4.6,
  5.x, 13.2, Runtime-shell authority and default cutover remain open. Evidence:
  `attachments/canonical-declaration-sema-action-closure-gate-2026-08-29.md`.

  Progress 2026-08-30: CTA-S69 carries the complete custom access definition
  and permission aggregate through typed Parser/Sema actions, makes permission
  append OOM fail before aggregate publication, and projects Runtime metadata
  without walking `snAccessDeclaration`. General declaration/body adapters
  outside this family remain unchanged, so this does not broaden the existing
  4.2 closure claim. Evidence:
  `attachments/canonical-access-specifier-runtime-projection-transaction-gate-2026-08-30.md`.

- [x] 4.3 <!-- TDD --> Port `asCBuilder::CreateDataTypeFromNode`, scope/name extraction, namespace resolution, qualifier modification, and template-instance decisions into type Sema APIs that produce `asCQualType`; retain builder adapters only for legacy comparison.

  Progress 2026-08-29: exact interface/base method selection now compares
  Sema-owned return and ordered parameter `asCQualType` values, and the final
  verifier rejects invalid, foreign or dangling-but-equal signature types
  before equality can authenticate a relation. This closes the type-safety
  prerequisite for interface relations only; template-instance decisions,
  remaining namespace/type rules and CANONICAL independence from Builder type
  adapters keep 4.3 open. Evidence:
  `attachments/canonical-interface-sidecar-v8-issue-2026-08-29.md`.

  Progress 2026-08-29: prepared Runtime type resolution now supplies an exact
  current-generation transient view for classes, enums, typedefs and funcdefs.
  It resolves stable Canonical type keys without treating dynamic TypeId or a
  Runtime pointer as durable identity, including when Hot Reload keeps an old
  same-name generation alive. This closes the interface/prepared projection
  case only; the broader type-Sema sentence remains open. Evidence:
  `attachments/canonical-interface-publication-gate-2026-08-29.md`.

  Why this was still open before CTA-S125: the generic `ActOnQualTypeFromNode`
  migration API is deleted and live Parser type routes use typed actions, but
  CANONICAL Stage 2 still walked `CreateDataTypeFromNode` for Runtime shells.
  That remaining adapter is closed by CTA-S125. Builder remains the explicit
  LEGACY declaration path, which is allowed. Host `Register*` declaration
  strings also retain the walk as a Sema-less adapter.

  Progress 2026-08-24: lexical script `class`/`interface` and `struct` now
  retain distinct REFERENCE/VALUE canonical kinds, imported host class symbols
  synchronize the engine's `asOBJ_VALUE` fact, and the runtime bridge resolves
  a transient script type by its exact namespace-qualified stable key. The new
  native VALUE identity AST gate is **1/1**, SemaAuthority **264/264**, and
  CanonicalAST **365/365**. This closes three type-identity slices only;
  template-instance decisions, the remaining namespace/type rules, and
  CANONICAL independence from builder adapters keep 4.3 open. See
  `attachments/canonical-temporary-receiver-object-return-gate-2026-08-24.md`.

  Progress 2026-08-27: the current primitive typedef grammar no longer calls
  `ActOnQualTypeFromNode`; Parser passes its already-resolved primitive token
  and Sema interns the canonical primitive QualType directly. This closes only
  that restricted type-production slice. Qualified/template/handle types,
  namespace resolution, template-instance decisions and CANONICAL independence
  from builder adapters keep 4.3 unchecked. Evidence:
  `attachments/canonical-typedef-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-10 no longer lets an import replay decode its
  return type, but Parser still obtains the short-lived `asCQualType` through
  the general `ActOnQualTypeFromNode` adapter. This is now explicit debt rather
  than hidden inside `case snImport`; it keeps 4.3 unchecked.

  Progress 2026-08-27: CTA-S-11 carries the already-resolved canonical return
  `asCQualType` in its typed function signature payload, so ordinary function
  replay no longer rediscovers that type. Parser still obtains the value
  through `ActOnQualTypeFromNode`; qualified/template/handle decisions and
  CANONICAL independence from builder adapters remain open, so 4.3 stays
  unchecked.

  Progress 2026-08-27: CTA-S-12 carries record kind and complete qualified
  base spellings through typed payloads. Sema resolves each base against exact
  stable keys and lexical namespace prefixes instead of recursively taking a
  first identifier from `snClass/snInterface`. General data-type production,
  qualifiers, templates and CANONICAL independence from Builder adapters remain open, so 4.3
  stays unchecked.

  Progress 2026-08-27: CTA-S-13 carries the already-resolved canonical
  `asCQualType` in each global/field header, so comma-separated declarations
  do not independently rediscover a type from a completed node. Parser still
  obtains that value through `ActOnQualTypeFromNode`; qualified/template/
  handle production and CANONICAL independence from Builder adapters keep 4.3 unchecked.

  Progress 2026-08-27: CTA-S-14 reuses the already-resolved canonical
  `asCQualType` for every local/`for`/`foreach` header, so later comma
  declarators do not rediscover type syntax from `snDeclaration`. Parser still
  obtains the value through `ActOnQualTypeFromNode`; qualified/template/handle
  production, namespace decisions and CANONICAL independence from Builder adapters keep 4.3
  unchecked.

  Progress 2026-08-27: CTA-S-19 makes complete declaration-site type syntax a
  pointer-free Parser action and moves primitive, lexical, explicitly scoped,
  template and qualifier resolution behind `ActOnQualTypeAction`. All seven
  declaration route families are migrated and Parser has zero calls to the
  node adapter. The direct semantic gate covers `array<int>` with `const &in`;
  Frontend Type is **20/20**. `ActOnQualTypeFromNode` still exists inside Sema
  for residual lambda/property/expression/cast/construct recovery, and Builder
  adapters remain as comparison authority, so 4.3 stays unchecked. Evidence:
  `attachments/canonical-declaration-qualtype-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-20 routes cast/construct target syntax through
  `ActOnQualTypeAction` in Parser and deletes expression-side
  `ActOnQualTypeFromNode` use. Only three lambda/declaration-related production
  calls remain in `as_sema_decl.cpp`. Lambda/property type production and
  CANONICAL independence from Builder comparison adapters keeps 4.3 unchecked. Evidence:
  `attachments/canonical-expression-target-type-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-21 removes the final three production calls and
  physically deletes `ActOnQualTypeFromNode` plus the lambda signature/type
  walkers. Explicit lambda parameter types now use
  `BuildQualTypeSyntaxAction -> ActOnQualTypeAction`. Contextual lambda/funcdef
  inference, remaining namespace/template parity and CANONICAL independence
  from Builder comparison authority keep 4.3 unchecked. Evidence:
  `attachments/canonical-lambda-header-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-29: CTA-S56 replaces the flat type spelling/qualifier
  payload with a pointer-free indexed pre-order action, so root and nested
  template qualifiers remain separately owned. Sema recursively resolves
  children, rejects `array<const int>` at the exact child range, validates the
  exact Runtime template instance without retaining its pointer or numeric
  TypeId, and interns the parent only after child validation. Configured
  `float` width is preserved from the Parser-recognized root token. Final
  SemaAuthority is **406/406**, Parser declarations **18/18**, downstream
  ProductionCodeGen + Module Snapshot + TypedASTJIT **186/186**, and Frontend
  Type/TypeIdentity/TypeSema **20/20**. Qualified scope-segment templates,
  contextual lambda/funcdef inference, implicit-handle parity, fully AST-local
  template declaration authority and final Builder-adapter reconciliation keep
  4.3 unchecked. All RED/GREEN and issue evidence:
  `attachments/canonical-structured-qualtype-action-gate-2026-08-29.md`.

  Progress 2026-08-29 (CTA-S57): Sema now derives the effective handle
  qualifier from `asOBJ_IMPLICIT_HANDLE` on an exactly resolved Runtime named
  type or template instance, matching the retained LEGACY
  `CreateDataTypeFromNode` behavior without putting a Runtime pointer or
  numeric TypeId into Parser actions, AST identity, snapshots or backend DTOs.
  The permanent Parser-to-Sema gate proves bare source with no authored `@`
  seals the exact named and `array<int>` stable keys as handle QualTypes. Final
  focused result is **1/1**, SemaAuthority **407/407**, Frontend
  Type/TypeIdentity/TypeSema **20/20**, and ProductionCodeGen + Module Snapshot
  + TypedASTJIT **186/186 PASS**. Script-only lexical implicit-handle
  derivation, complete namespace/parent-type lookup, template-bearing scope
  segments, contextual lambda/funcdef inference, AST-local template authority
  and final Builder-adapter reconciliation keep 4.3 unchecked. Evidence:
  `attachments/canonical-implicit-handle-qualtype-gate-2026-08-29.md`.

  Progress 2026-08-29 (CTA-S58): script-declared class/interface records now
  own `REFERENCE_OBJECT + HANDLE` in the Canonical declaration environment,
  and ordinary lexical uses derive that intrinsic qualifier from the matched
  AST declaration before any Runtime publication. Script structs remain
  `VALUE_OBJECT` without `HANDLE`/`AUTO_HANDLE`; Parser actions still carry no
  Builder/Runtime pointer or numeric TypeId. A valid focused RED exposed
  `quals=0`; final gates are focused **1/1**, corrected-signature regressions
  **4/4**, SemaAuthority **408/408**, Parser Declarations **18/18**, Frontend
  Type/TypeIdentity/TypeSema **20/20**, and ProductionCodeGen + Module Snapshot
  + TypedASTJIT **186/186 PASS**. The first complete Sema run's four failures
  were recorded and proven to be stale pre-handle key expectations, not lost
  conversions or receiver binding. Complete namespace/parent-type lookup,
  template-bearing scope segments, contextual lambda/funcdef inference,
  AST-local template declaration authority and final Builder-adapter
  reconciliation keep 4.3 unchecked. Evidence:
  `attachments/canonical-lexical-record-implicit-handle-gate-2026-08-29.md`.

  Progress 2026-08-29 (CTA-S59): Parser now preserves absolute/simple scope
  segments and template arguments owned by an innermost qualified parent as a
  pointer-free indexed QualType action instead of flattening
  `TScopedParent<int>::FChild` to `TScopedParentintFChild`. Sema validates the
  complete topology, resolves the exact Runtime parent instance and child,
  proves the parent relationship, derives only the child kind/effective
  qualifiers, and interns stable identity `TScopedParent<int>::FChild` without
  publishing a Runtime pointer or dynamic TypeId. Malformed indices,
  overlapping template children and out-of-subtree children fail closed. Final
  gates are focused malformed topology **1/1**, SemaAuthority **410/410**, and
  Parser Declarations + Frontend Type/TypeIdentity/TypeSema + ProductionCodeGen
  + Module Snapshot + TypedASTJIT **224/224 PASS**. Contextual lambda/funcdef
  inference, fully AST-local template declaration authority, remaining
  namespace/type parity and final Builder comparison-adapter reconciliation
  keep 4.3 unchecked. Registration ABI exploration, exact RED/GREEN evidence,
  diagnostic de-duplication and the pre-existing provisional-registration debt
  are recorded in
  `attachments/canonical-template-qualified-parent-type-gate-2026-08-29.md`.

  Progress 2026-08-29 (CTA-S60): qualified script-only nominal types now
  resolve against the Canonical declaration environment before Runtime
  publication. Relative `Types::CRef` walks `Outer::Use` and its enclosing
  namespaces to select `Outer::Types::CRef`; parent-qualified
  `Outer::Types::FValue` reaches the translation-unit candidate; absolute
  `::Outer::Types::EKind` skips the relative search and publishes stable
  identity without the authored leading `::`. The selected lexical declaration
  determines enum/reference/value kind and declared implicit-handle semantics;
  only stable keys/kinds/qualifiers cross into the AST. Final gates are focused
  **1/1**, SemaAuthority **411/411**, and Parser Declarations + Frontend
  Type/TypeIdentity/TypeSema + ProductionCodeGen + Module Snapshot +
  TypedASTJIT **224/224 PASS**. Contextual lambda/funcdef inference, fully
  AST-local template declaration authority, any remaining type parity exposed
  by those closures, and final Builder comparison-adapter reconciliation keep
  4.3 unchecked. The exact RED/GREEN trail, invalid first test-prefix
  invocation, compile-time lookup-index debt and static boundary audit are in
  `attachments/canonical-qualified-lexical-type-scope-gate-2026-08-29.md`.

  Progress 2026-08-29 (CTA-S64): Canonical type Sema now snapshots
  pointer-free host template declaration facts at translation-unit start and
  resolves final template instances plus template-qualified parent child
  funcdefs without `GetTypeInfoByDecl`, `IsTemplateType`,
  `GetTemplateInstanceType`, Runtime instance allocation or dynamic TypeId
  identity. The copied facts cover namespace-qualified stable key, flags,
  arity, declarative value/reference subtype restrictions, Runtime-callback
  presence and child-funcdef names. A declaration-lifecycle bridge that still
  instantiated `TScopedParent<int>` merely to choose `DEFAULT_INITIALIZED`
  was also replaced with a Canonical storage-kind query; malformed template
  topology is now rejected before semantic child traversal. Final gates are
  focused policy **3/3**, SemaAuthority **423/423**, and Parser Declarations +
  Frontend Canonical type + ProductionCodeGen + Module Snapshot + TypedASTJIT
  **224/224 PASS**. Three ordinary non-template `GetTypeInfoByDecl` projection
  sites, application-callback install validation and final Builder-adapter
  reconciliation keep 4.3 unchecked. Complete RED/GREEN, localization,
  topology-regression and static-boundary evidence:
  `attachments/canonical-template-declaration-snapshot-gate-2026-08-29.md`.

  Progress 2026-08-29 (CTA-S65): ordinary host/imported nominal type and
  record-base resolution in declaration Sema now consumes a deterministic,
  translation-unit-local registered-declaration snapshot instead of three live
  `GetTypeInfoByDecl`/`GetTypeInfoByName` queries. Facts contain only stable
  key, Canonical kind, semantic flags, interface projection and ambiguity;
  current lexical declarations retain precedence, conflicting same-key facts
  fail closed, and no Runtime pointer or numeric TypeId enters AST identity.
  Stable-key ordered merge avoids registry-order authority and O(n-squared)
  copying; Sema uses binary lookup. The causal pre-change gate was **0/2**;
  final focused policy is **6/6**, SemaAuthority **425/425**, and Parser
  Declarations + Frontend Canonical Type + ProductionCodeGen + Module Snapshot
  + TypedASTJIT **224/224 PASS**. `PreClassData::ShadowType`, one expression
  enum-scope registry query, install-time application callback validation and
  final Builder-adapter reconciliation keep 4.3 unchecked. Evidence:
  `attachments/canonical-registered-nominal-declaration-snapshot-gate-2026-08-29.md`.

  Progress 2026-08-29 (CTA-S66): registered `Enum::Value` expression lookup
  now consumes the same translation-unit-local declaration snapshot. Enum
  facts own exact ordered names and signed values; lexical current-TU scopes
  retain precedence, conflicting copied facts fail closed, and expression
  Sema has zero `GetTypeInfoByDecl`/`GetTypeInfoByName` calls. The lifecycle
  gate changed from **0/1 RED** to **1/1 GREEN**; focused policy is **5/5**,
  complete SemaAuthority is **426/426**, and the five-surface consumer matrix
  is **224/224 PASS**. `PreClassData::ShadowType`, install-time application
  callback validation and final Builder-adapter reconciliation still keep 4.3
  unchecked. Evidence:
  `attachments/canonical-registered-enum-literal-snapshot-gate-2026-08-29.md`.

  Progress 2026-08-31 (CTA-S117): Canonical QualType intern now copies the
  Sema-generation `requiresRuntimeValidation` marker onto the sealed `asCType`
  of a template instance. Parser→Sema→Seal of
  `TSemaCallbackGate<int>` vs `TSemaNoCallbackGate<int>` proves the flag
  without calling the application callback or allocating a Runtime instance.
  AST-red was **0/1** (`requiresRuntimeValidation` stayed false); AST-green is
  focused **1/1** and SemaAuthority **476/476**. A second permanent test locks
  CANONICAL `Build()` fail-closed when the callback rejects
  (`cta-sema-template-callback-reject` **1/1**). CodeGen still materializes
  through `GetTemplateInstanceType` rather than the sealed flag alone, so
  `PreClassData::ShadowType`, remaining template-declaration authority and
  Builder-adapter reconciliation keep 4.3 unchecked. Evidence:
  `attachments/canonical-template-callback-install-gate-2026-08-31.md`.

  Progress 2026-08-31 (CTA-S122): PreClass `ShadowType` native-view Decls now
  intern Clang-style QualType handle bits from copied registered flags.
  `asOBJ_IMPLICIT_HANDLE` hosts seal `HANDLE`; bare `asOBJ_REF` hosts do not.
  AST-red was native-view `quals=0`; focused **1/1** and SemaAuthority
  **478/478**. Remaining AST-local template declaration authority, contextual
  lambda/funcdef inference and production Builder-adapter isolation keep 4.3
  unchecked. Evidence:
  `attachments/canonical-preclass-shadow-qualtype-gate-2026-08-31.md`.

  Progress 2026-09-01 (CTA-S123): structured QualType intern now stores
  Clang-style template-argument QualTypes on interned `asCType` without
  `GetTemplateInstanceType`. Fixture `TSemaScriptArgGate<LocalScript>` seals
  `kind=TEMPLATE`, one `REFERENCE_OBJECT` `LocalScript` argument with
  `HANDLE`, and unchanged Runtime buckets. AST-red was empty
  `templateArguments`; focused **1/1**, SemaAuthority **479/479**, Frontend
  CanonicalAST **189/189**. Contextual lambda/funcdef inference and remaining
  Builder-adapter isolation keep 4.3 unchecked. Evidence:
  `attachments/canonical-script-template-argument-qualtype-gate-2026-08-31.md`.

  Progress 2026-09-01 (CTA-S124): host funcdef return/formals are copied as
  pointer-free QualType facts and projected as a native-view `DECL_FUNCDEF`.
  `IsLambdaViableForFuncdef` and `ContextualizeLambdaToFuncdef` consume those
  Decls/facts and no longer call `asCRuntimeTypeBridge`. Fixture
  `TSemaHostFnGate` / `function(int x)` seals `void` return and one `int`
  formal. AST-red was missing native-view FUNCDEF; focused **1/1**,
  SemaAuthority **480/480**, Frontend CanonicalAST **189/189**. Remaining
  Builder `CreateDataTypeFromNode` isolation keeps 4.3 unchecked. Evidence:
  `attachments/canonical-host-funcdef-formal-qualtype-gate-2026-09-01.md`.

  Closed 2026-09-01 (CTA-S125): CANONICAL script type production no longer
  walks `CreateDataTypeFromNode`. Native `Build()` already skipped that walk;
  Stage 2 `ParseScripts` was the remaining adapter (`count=2` RED on
  `void F(int x) {}`). GetParsedFunctionDetails, globals, class/mixin
  properties, enums, and virtual-property emulated types now fill Runtime
  `asCDataType` from Sema QualTypes. Script-path `CreateDataTypeFromNode`
  fail-closes when `canonicalSema` is attached. Host `Register*` and explicit
  LEGACY `asCCompiler` retain the node walk. Focused **1/1**, SemaAuthority
  **481/481**, Frontend CanonicalAST **189/189**. 4.4+ stay open. Evidence:
  `attachments/canonical-create-datatype-from-node-isolation-gate-2026-09-01.md`.

  Progress 2026-08-31: function/method signature actions now start at the
  return-type token so Canonical `range.begin` matches Builder `declaredAt`
  (function-node start), not the identifier-only span. This is source-coordinate
  reconciliation for 4.6's identity oracle, not full type-Sema closure. Evidence:
  `attachments/canonical-builder-declaration-identity-oracle-2026-08-31.md`.

- [x] 4.4 <!-- TDD --> Port function signatures, default/named arguments, access specifiers, traits, virtual properties, mixins, lambdas, and list patterns into canonical declaration nodes while maintaining existing public function/type registration results and diagnostics.

  Why this is still open: migrated ordinary/import/funcdef signatures,
  callable parameter headers, mixin/access traits and custom access-group edges
  are now Canonical facts. Complete default/named-argument diagnostics,
  property/accessor behavior, lambda identity/body and list-pattern actions are
  not all action-only, and public registration still has Builder/`asCCompiler`
  comparison authority. The historical "virtual properties" wording refers to
  syntax already removed by `refactor-as-remove-autoaccessor`; this task must
  preserve its rejection diagnostic, not restore the deleted dialect.

  Progress 2026-08-27: CTA-S-10 proves a two-parameter import attaches both
  parameters incrementally to the exact import declaration and preserves the
  configured canonical `double` type. Parameters still cross the general
  `ActOnParsedParam` node adapter, so typed parameter/default payload closure
  and 4.4 remain open.

  Progress 2026-08-27: CTA-S-11 publishes ordinary function identity, kind,
  canonical return type and access/mixin/const/final/override/external traits
  through typed actions before body recovery. Parameters attach under the
  exact function context, and constructor identity comes from exact owner/name.
  Parameter/default payloads, lambda capture/body actions, virtual properties
  and list patterns remain open, so 4.4 stays unchecked.

  Progress 2026-08-27: CTA-S-12 moves record header/base/finish ordering into
  explicit actions and makes generated class lifecycle/accessors a finish
  phase rather than a completed-node side effect. Class member fields,
  defaults, funcdefs, virtual properties and general parameter/body actions
  remain open, so 4.4 stays unchecked.

  Progress 2026-08-27: CTA-S-13 publishes private/protected field access as a
  typed trait mask and preserves one exact initializer per declarator before
  later recovery. Custom named access groups, virtual properties, default
  arguments, funcdefs, lambdas and list patterns remain open, so 4.4 stays
  unchecked.

  Progress 2026-08-27: CTA-S-14 pins comma-declarator ordering and exact
  initializer ownership for ordinary locals and `for` initializers, plus a
  `foreach` DeclStmt that is not default-constructed before the loop protocol
  supplies its element. The malformed list-pattern recovery gate remains
  green after replay removal. Default/named argument ownership, virtual
  properties, custom access groups, funcdefs, lambdas and complete list-pattern
  actions remain open, so 4.4 stays unchecked.

  Progress 2026-08-27: CTA-S-15 makes generated class-default method identity,
  traits, origin and ordered body ownership Sema actions instead of a completed
  `snClassDefaultStatement` side effect. It does not migrate parameter/default-
  argument payloads, virtual properties, access groups, funcdefs, lambdas or
  list patterns, so 4.4 stays unchecked.

  Progress 2026-08-27: CTA-S-16 makes the retained Parser funcdef's name,
  canonical return type and exact parameter owner explicit Sema-action facts.
  It deliberately leaves authored script `funcdef` rejected and does not
  replace the general `ActOnParsedParam`/default-expression adapters, virtual
  properties, access groups, lambdas or list patterns, so 4.4 stays unchecked.

  Progress 2026-08-27: CTA-S-17 makes named access definitions, ordered
  permission traits and exact field/method access-group membership immutable
  Canonical declaration facts. It preserves the existing LEGACY Runtime
  registration path as a comparison boundary. General parameter/default-
  argument payloads, virtual properties, lambdas and list patterns remain
  open, so 4.4 stays unchecked.

  Progress 2026-08-27: CTA-S-18 makes callable parameter identity, exact
  owner, qualified type/direction and source range a pointer-free action before
  default parsing. `ActOnParsedParam` and its mutable owner fallback are
  deleted; a complete default remains a separately named transitional adapter.
  The virtual-property audit confirms Parser still emits the removal diagnostic
  and Sema has no production virtual-property route. Default/named-argument
  closure, property/accessor behavior, lambdas and list patterns keep 4.4
  unchecked.

  Progress 2026-08-27: CTA-S-19 moves every ordinary/import/funcdef/interface
  callable return and parameter type across the typed QualType action rather
  than a Parser-node adapter. The signature actions therefore receive only a
  locally resolved canonical type. Defaults/named-argument diagnostics,
  property/accessor behavior, lambdas/list patterns and public Runtime
  registration parity remain open, so 4.4 stays unchecked. Evidence:
  `attachments/canonical-declaration-qualtype-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-27: CTA-S-21 makes lambda identity, exact owner, explicit
  parameter type/name/range and header-before-body ordering typed Canonical
  facts. The body adapter may only retrieve that exact declaration; it cannot
  reconstruct the signature. Contextual funcdef binding, untyped parameters,
  return inference, default/named arguments, property/accessor behavior, list
  patterns and public Runtime registration parity keep 4.4 unchecked.
  Evidence:
  `attachments/canonical-lambda-header-typed-action-gate-2026-08-27.md`.

  Progress 2026-08-30: CTA-S69 now maintains existing public Runtime custom-
  access results through exact Canonical declaration order, name uniqueness,
  permission traits and field/method edges. Different DeclIds with one
  definition name fail closed; repeated wildcard declarations preserve LEGACY
  OR semantics. Defaults/named arguments, property/accessor behavior, lambdas,
  list patterns and other registration families keep 4.4 unchecked. Evidence:
  `attachments/canonical-access-specifier-runtime-projection-transaction-gate-2026-08-30.md`.

  Closed 2026-09-01: CTA-S126 seals ParamDecl default Expr ownership, named
  plus default call-argument plans, lambda Decl `body` Block, and list-factory
  origin `repeat int`. CTA-S127 seals compile-path AccessSpecifier /
  AccessPermission children, `Vault::F` trait mask
  `PRIVATE|CONST_METHOD|FINAL|OVERRIDE`, mixin kind/trait/origin `Vault`,
  generated Get/Set inheriting the field specifier, and virtual-property
  rejection with `TXT_VIRTUAL_PROPERTY_REMOVED` and no PropertyDecl. Named
  prefixes: SemaAuthority **483/483** `cta-ast-first-sema`
  `20260901_014746_098_c9cf659e`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_014940_764_074d6f19`. Evidence:
  `attachments/canonical-decl-default-lambda-list-pattern-gate-2026-09-01.md`
  and
  `attachments/canonical-decl-access-traits-mixin-virtual-property-gate-2026-09-01.md`.
  4.5 is closed by CTA-S128/S129. 4.6 production `Build()` shadow-mismatch
  fail-closed remains open.

- [x] 4.5 <!-- TDD --> Port declaration dependency marking, editor-only checks, conflict/default-argument validation, class/interface inheritance, global/property registration, and generated lifecycle declarations into Sema-owned stable dependency/diagnostic records.

  Progress 2026-08-29: class/interface ancestry and exact override/
  implementation choice now produce pointer-free record-owned relation facts.
  The verifier enforces single class inheritance, class/interface cycles,
  interface base kind, exact owner/signature/closure, unique implementation and
  complete concrete-class coverage. Sidecar V8 preserves these facts without
  Runtime IDs or pointers. Runtime interface shell/registration parity plus the
  other conflict/default/property/editor-only parts remain open, so 4.5 is not
  checked. Evidence:
  `attachments/canonical-interface-sidecar-v8-issue-2026-08-29.md`.

  Progress 2026-08-29: detached CodeGen now registers exact interface shells
  and bodyless `asFUNC_INTERFACE` requirements, and Prepared CodeGen binds the
  exact current Builder shell through producer-carried declaration identity.
  Class/interface closure, legacy-observable ordering, offsets and dispatch
  chunks are mechanically derived from the sealed relation set and fail closed
  on a Stage 2 mismatch. Conflict/default/editor-only and other registration
  families still keep 4.5 unchecked. Evidence:
  `attachments/canonical-interface-publication-gate-2026-08-29.md`.

  Why this is still open: keys still miss param qualifiers/ABI, module, and profile. StaticJIT identity is fail-closed on ambiguous same-name rather than exact owner match. Dependencies remain an append-only string list. Sidecar hash still ignores function body (review F2).

  Progress 2026-08-21: dumps distinguish `F(int)`/`F(float)`, `T::T()`/`T::T(int)`/`T::~T()`, `Game::F(int)`, `T::opAdd(int)`, mixin `MixHelper(T,int)`, `<lambda>(int)@offset`, `T::F()` vs `T::F() const`, `ByVal(int)` vs `ByRef(const int&in)`, and `InF(int&in)` vs `OutF(int&out)`. Param `const` is no longer leaked as `TRAIT_CONST_METHOD`. StaticJIT identity prefix **8/8**. Not 4.5/13.3 close: production backends still rerun Sema.

  Progress 2026-08-27: CTA-S-13 makes global/field registration identity,
  named type dependency, recognized access and exact initializer ownership
  Sema facts. The ProductionCodeGen gate caught and repaired a split global
  default (`constant=41`, stale `default=40`). Conflict/editor-only/default-
  argument/property/access-group validation and aggregate registration parity
  remain open, so 4.5 stays unchecked.

  Progress 2026-08-27: CTA-S-14 makes local/`for`/`foreach` declaration
  identity, type dependency and exact initializer/statement ownership Sema
  facts. Its full regressions found and repaired `stmt-multi-owner` plus
  partial list-pattern recovery loss. Editor-only/conflict/default-argument/
  property registration and aggregate parity remain open, so 4.5 stays
  unchecked.

  Progress 2026-08-27: CTA-S-15 makes the generated `__InitDefaults`
  declaration and authored default-body ordering exact Sema-owned facts. The
  complete CodeGen and TypedSemanticIR boundary remain green, but property/
  access-group registration, conflict/default-argument validation and
  aggregate registration parity remain open, so 4.5 stays unchecked.

  Progress 2026-08-27: CTA-S-17 validates the complete access-definition
  shape, rejects dangling/foreign/wrong-kind member edges, and persists the
  exact relationship through Sidecar V5 and capacity-aware snapshots. Builder
  `RegisterAccessSpecifier` and Runtime installation are deliberately still
  the shadow path; property registration, conflict/default-argument checks and
  aggregate Canonical registration parity remain open, so 4.5 stays unchecked.

  Progress 2026-08-27: CTA-S-18 records each parameter's named-type
  dependency against the exact callable and preserves qualifier-sensitive
  stable-key behavior. It deliberately does not claim conflict/default-
  argument validation, property registration or aggregate Runtime parity, so
  4.5 stays unchecked.

  Progress 2026-09-01: CTA-S128 seals compile-path `Vault:Base` dependencies,
  generated `__InitDefaults`, global constant `41`, and fail-closed Sema
  token `default-argument-overload-conflict` for `F(int)` vs
  `F(int, int = 1)` without walking the native syntax tree. Named prefixes:
  SemaAuthority **484/484** `cta-ast-first-sema`
  `20260901_015933_699_bb79021c`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_020110_503_32a6e1ca`. Evidence:
  `attachments/canonical-decl-dependency-lifecycle-default-conflict-gate-2026-09-01.md`.

  Progress 2026-09-01: CTA-S129 makes editor-only override a Sema fact over
  sealed `asAST_TRAIT_EDITOR_ONLY` and `asSASTMethodRelation` BASE_OVERRIDE
  edges. Native CANONICAL `Build()` copies Builder `#if WITH_EDITOR` character
  ranges at attach, applies the trait from source offsets, and fail-closes
  with token `editor-only-override-mismatch` before snapshot publication.
  Named prefixes after this card: SemaAuthority **485/485**
  `cta-ast-first-sema` `20260901_021713_171_051d023e`, Frontend CanonicalAST
  **189/189** `cta-ast-first-frontend` `20260901_021845_916_995b08df`.
  Evidence:
  `attachments/canonical-decl-editor-only-override-gate-2026-09-01.md`.
  This closes Task 4.5. 4.6 production `Build()` shadow-mismatch fail-closed
  remains open.

  Progress 2026-08-30: prepared class registration now stages every Runtime
  AccessSpecifier DTO, validates exact owner/definition/permission/member
  identities, commits the class aggregate once, and resolves field/method
  borrowers before publishing their shells. This closes custom-access Runtime
  parity and its local transaction only. Editor-only, default/conflict,
  property and remaining aggregate registration families keep 4.5 unchecked.
  Evidence:
  `attachments/canonical-access-specifier-runtime-projection-transaction-gate-2026-08-30.md`.

- [x] 4.6 <!-- TDD --> Add shadow mismatch tests that intentionally perturb declaration owner/type/trait/source/dependency fields and prove the migration gate reports deterministic differences without merging legacy and canonical facts.

  Why this is still open: there is no gate that compares builder facts to Sema facts and fails closed on mismatch. Production still publishes builder/`asCCompiler` output regardless of AST content. Tests that compile under the canonical *flag* and execute are not shadow-mismatch tests. Checking this without a differential mismatch oracle is how two graphs can silently disagree.

  Progress 2026-08-30: the access-specific negative matrix now perturbs source
  spellings, exact definition/member edges, owner children, duplicate names and
  duplicate/embedded definition, permission, owner, field and method identities
  and proves no CANONICAL Runtime
  aggregate or affected member shell is merged on mismatch. This is not the
  complete owner/type/trait/source/dependency differential oracle required for
  all declarations, so 4.6 remains unchecked. Evidence:
  `reviews/canonical-access-specifier-runtime-projection-transaction-review-2026-08-30.md`.

  Progress 2026-08-31 (CTA-S118): `asCASTShadowDiffBuilderFunctionIdentity`
  compares LEGACY Builder `asCScriptFunction` owner/type/trait/source/dependency
  against a sealed Canonical function Decl without merging graphs. The first
  implemented RED was `decl.range` column 5 vs 1 (name token vs function-node
  start); Parser now publishes return-type `beginOffset` for function/method
  signatures. Focused **1/1** and Frontend Shadow **3/3**. Class/method/enum/
  import families and production fail-closed publication keep 4.6 unchecked.
  Evidence:
  `attachments/canonical-builder-declaration-identity-oracle-2026-08-31.md`.

  Progress 2026-08-31 (CTA-S119): `asCASTShadowDiffBuilderTypeIdentity` compares
  LEGACY Builder `asCObjectType` owner/type/trait/source/dependency against a
  sealed Canonical class Decl. Class `declaredAt`/`scriptSectionIdx` now come
  from the already computed name-token `r,c`. Method `T::M` reuses the function
  identity oracle with owner `class:T`. Focused **1/1** and Frontend Shadow
  **4/4**. Enum/import families and production fail-closed publication keep 4.6
  unchecked. Evidence:
  `attachments/canonical-builder-class-method-identity-oracle-2026-08-31.md`.

  Progress 2026-08-31 (CTA-S120): the same type-identity oracle now compares
  LEGACY Builder `asCEnumType` against a sealed Canonical enum Decl. Enum
  `declaredAt`/`scriptSectionIdx` come from the name token. Focused **1/1**
  and Frontend Shadow **5/5**. Import families and production fail-closed
  publication keep 4.6 unchecked. Evidence:
  `attachments/canonical-builder-enum-identity-oracle-2026-08-31.md`.

  Progress 2026-08-31 (CTA-S121): imported `int F(int) from "Other"` matches
  through function identity. Builder now publishes import `declaredAt` from
  the name token and includes `importFromModule` as a dependency. Focused
  **1/1** and Frontend Shadow **6/6**. Evidence:
  `attachments/canonical-builder-import-identity-oracle-2026-08-31.md`.

  Progress 2026-09-01: CTA-S130 closes production fail-closed. After Canonical
  CodeGen installs Runtime functions, `asCASTValidateBuilderShadowIdentity`
  compares sealed Decl owner/type/trait/source against the candidate. A
  FINAL Runtime `F` vs un-FINAL Canonical Decl fails `Build()` with token
  `shadow-declaration-mismatch` and publishes neither snapshot nor `F`.
  Named prefixes: SemaAuthority **486/486** `cta-ast-first-sema`
  `20260901_025214_805_c5a28808`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_025347_764_17a4a64c`. Evidence:
  `attachments/canonical-decl-shadow-mismatch-publication-gate-2026-09-01.md`.
  This closes Task 4.6. 5.2 expression Sema remains open.
- [x] 4.7 <!-- Non-TDD --> Run `Tools\RunBuild.ps1 -Label canonical-ast-decl-sema -TimeoutMs 1800000 -NoXGE`, Frontend, Compiler, Module, and `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.TypeSystem" -Label canonical-ast-type-sema -TimeoutMs 600000`.

## 5. Expression, statement, call, and lifetime Sema migration

- [x] 5.1 <!-- TDD --> Add failing canonical expression tests for literals, declaration/member/global references, unary/binary/logical/conditional operations, assignment/compound/prefix/postfix mutation, explicit/implicit conversion, construction, calls, index/property access, and exact `asCQualType`/value category.
- [x] 5.2 <!-- TDD --> Implement `as_sema_expr.h/.cpp` and AST expression builders; migrate value/type, overload/operator/conversion, assignability, literal, variable/member/global, and construction decisions out of Bytecode emission while keeping legacy output authoritative in shadow mode.

  Why this is still open: `ActOnExprFromNode` walks parser nodes. Name lookup returns the first same-name child walking parents. Bool and int constants are handled; other constants, including strings, become `int`. `ttNull` becomes an int primitive with a handle qualifier. Overload, conversion, and assignability still happen in `asCCompiler` when Bytecode is emitted. “Shadow mode” was supposed to mean two isolated Engines with comparable facts; production execution still never reads these expression nodes. It was checked because expression IDs existed in dumps (review R02).

  Progress 2026-08-27: real UE source `TArray<int> LocalIntArray;` now seals an
  exact zero-argument constructor after Sema materializes a template-base
  behaviour as an instance-local function shell. The permanent source/AST/
  Canonical-CodeGen/VM test is **1/1**, SemaAuthority is **301/301**, and
  ProductionCodeGen is **111/111**. This closes one construction family, not
  expression authority or the remaining parser-node/overload/conversion work.
  Evidence: `attachments/tarray-local-default-construction-gate-2026-08-27.md`.

  Progress 2026-08-30 (CTA-S79): the shared expression type-owner lookup no
  longer treats `Decl::name` as a substitute for complete Canonical type
  identity. An unqualified `FValue` previously rewrote `Object.Value` into
  `Wrong::FValue::GetValue()` when only the namespaced same-name class existed.
  Exact declaration stable-key matching now protects property/member,
  operator, conversion, native projection and base-convertibility callers. The
  adversarial/source-guard pair went **0/2 RED -> 2/2 GREEN** and Compiler
  CanonicalAST plus TypedASTJIT is **693/693 PASS** (**639+54**). This closes
  the known short-name owner fallback, not the full expression/language
  authority umbrella. Evidence:
  `attachments/cta-s79-exact-expression-type-owner-gate-2026-08-30.md`.

  Progress 2026-08-31: complete-type `Owner.ActorMap.Iterator()` now seals
  MEMBER_REF of the stored TMap instead of Call `GetActorMap()` (by-value copy).
  AST-red was CodeGen `missing callable relocation targetName=GetActorMap`;
  AST-green is SemaAuthority **475/475** and ScriptCorpus **18/18**. Primitive
  GetX still rewrites. Evidence:
  `attachments/canonical-tmap-iterator-memberref-gate-2026-08-31.md`.

  Progress 2026-09-01: CTA-S131 makes assignability a Sema fact over sealed
  QualType and value category. Authored assignment that is not a declaration
  initializer fail-closes with token `expression-not-assignable` when the lhs
  is not a modifiable lvalue (`asAST_VALUE_LVALUE` and not const). Named
  prefixes: SemaAuthority **487/487** `cta-ast-first-sema`
  `20260901_030206_494_e5bc15ba`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_030347_637_a85be34d`. Evidence:
  `attachments/canonical-expr-const-lvalue-assignability-gate-2026-09-01.md`.
  This closes Task 5.2. Call/overload provenance remains 5.3; 13.2 stays open.

- [x] 5.3 <!-- TDD --> Port resolved ordinary/member/mixin/import/native calls, effective receivers, source/default/hidden/named arguments, argument provenance/order, call rewrites, route traits, and stable dependencies into canonical call nodes. Reuse every `TypedSemanticIR/Call*` test oracle.

  Why this is still open: remaining ordinary/member/mixin/import/native
  families are not all sealed, and the product default is LEGACY. Mixin
  `IMPLICIT_RECEIVER` dump, import
  named+default, converting constructor, Construct dump `callArgs=`,
  user-authored `opAssign` / `opAddAssign` Call rewrites, reverse
  `opAdd_r`, inequality `!opEquals`, `opCmp` compared against 0, bitwise
  `opOr` (`|`), swapped `opCmp` (`3 < Object` → `opCmp > 0`), bitwise-not
  `opCom` (`~Object`), `ApplyFormat(FName)` plus named `Print Duration`,
  prefix `++Make().Value` Get/Set Sequence, prefix `++Make()[0]`
  lvalue `opIndex` Sequence, postfix `Make()[0]++` old-value Sequence,
  rvalue `Make() += 7` `opAddAssign` Call, mixin omitted-default
  `MixHelper()`, member named+default `Pack(B: 7)`, unary-not
  `!Object` via `opImplConv`, Conditional `Object ? 42 : 0`
  via `opImplConv`, `if (Object)` / `while (Object)` via
  `opImplConv`, `for (; Object; )` via `opImplConv`, leftover
  `!bool` Unary typed bool, WorldContext hidden-call execute
  (`WithWorld(3)` injects `__WorldContext()`), Logical
  `Object && true` via `opImplConv`, CANONICAL staged
  factory / CompileFunction / global-init sites that no longer
  construct `asCCompiler`, object functor `Object(41)` rewritten
  to `T::opCall(int)`, postfix `Make()(41)` characterization-green
  from that rewrite, explicit `Cast<int>(Object)` rewritten
  to `T::opConv() const`, `return Object` rewritten through
  implicit `T::opImplConv() const`, and local initialization
  `int Value = Object` plus call argument `Consume(Object)` rewritten through
  the same implicit conversion are now locked
  (CTA-S132–S137, CTA-S139, CTA-S146–S170).
  Function first-same-name fallback is gone; ranking miss returns no callee.
  13.2 stays open. Do not check 5.3 from Sema dump greens while backends
  rerun Sema.

  Progress 2026-08-21: compile→seal dumps now record selected overloads, named/default args, reverse-formal **stored** children, mixin implicit receiver as `nargs=2`, import `route=import`, property Get/Set rewrite, destructor cleanup callee. That is dump progress, not 5.3/13.2 close.

  Progress 2026-08-24: host funcdef calls now prove the exact sealed callable
  declaration, funcdef identity, reverse-formal argument slots, conversion, and
  signature `int` result type before CodeGen. Focused AST **1/1** and complete
  SemaAuthority **263/263** are green; see
  `attachments/canonical-funcdef-call-abi-gate-2026-08-24.md`. This closes one
  callable slice only; hidden/native/import/mixin provenance and the rest of
  this task remain open.

  Progress 2026-08-24: property getter/setter calls now retain an explicit
  receiver, and compound property/index rewrites prove that one body-owned
  `OpaqueValue` is the receiver for every read/write phase. The AST-first gate
  exposed the downstream object-return ABI defect without changing the already
  correct call graph. Semantics is **12/12** and CanonicalAST **365/365**; this
  remains a receiver/mutation slice rather than full call provenance closure.

  Progress 2026-08-24: an earlier script section can now retain an unresolved
  call until a later section publishes its exact declaration. Final binding
  updates the call's callee/type/arguments and removes provisional ERROR-only
  lifetime wrappers from the owned body graph. The permanent CANONICAL AST +
  execution gate and the explicitly routed LEGACY Builder protocol gate are
  **2/2 PASS**; complete Compiler is **497/556**, with this former failure
  removed. This is cross-section recovery, not full call provenance or
  declaration precollection. See
  `attachments/canonical-cross-section-forward-call-gate-2026-08-24.md`.

  Progress 2026-08-27: explicit qualified calls and `DeclRef`s now preserve
  exact scope through deferred resolution, fail closed on a missing scope or
  member, and never retain direct dispatch without a resolved declaration.
  Later-resolved primitive children also trigger AST-only fixed-point
  recomputation of dependent binary parents and explicit numeric promotion.
  Complete SemaAuthority is **308/308** and ProductionCodeGen is **114/114**.
  Evidence:
  `attachments/canonical-explicit-scope-resolution-gate-2026-08-27.md`,
  `attachments/canonical-explicit-scope-declref-gate-2026-08-27.md`, and
  `attachments/canonical-deferred-expression-reconciliation-gate-2026-08-27.md`.
  This advances the call/conversion matrix but does not complete hidden/native/
  import/mixin provenance or the full task.

  Progress 2026-08-30: CTA-S72 replaces diagnostic-literal and parallel-child
  inference with typed `asSASTCallArgument` records. Candidate ranking and
  selected arrangement share one pure binding plan; direct calls retain exact
  `ParamDecl` identity, indirect funcdef calls retain authenticated ordinal and
  canonical formal type, and ordinary versus mixin receiver shapes are
  explicit. Publication verification is coverage- and relation-complete for
  this record family; Sidecar V9 and production CodeGen preserve/consume the
  same facts. Compiler CanonicalAST is **634/634**, Frontend CanonicalAST is
  **181/181**, and Cache is **584/584**. Task 5.3 remains open for constructor
  provenance and the complete import/mixin/native/call-family matrix. Evidence:
  `attachments/canonical-call-argument-provenance-gate-2026-08-30.md`.

  Progress 2026-09-01: CTA-S132 rewrites overloaded `[]` to a Sema Call.
  Production `Values[3]` no longer seals leftover `Index` with only
  `resolvedDecl`; the returned expression is `asAST_EXPR_CALL` of
  `T::opIndex(int)` with `receiver=`, non-`NONE` dispatch, and one positional
  `Index` formal. Compound `Make()[0] += 1` rebuilds that Call on an
  `OpaqueValue` of the original receiver. Builtin indexing without `opIndex`
  still intern `Index`. Named prefixes: SemaAuthority **488/488**
  `cta-ast-first-sema` `20260901_032737_604_6b620666`, Frontend CanonicalAST
  **189/189** `cta-ast-first-frontend` `20260901_032902_886_6e2a7b71`. Evidence:
  `attachments/canonical-call-opindex-rewrite-gate-2026-09-01.md`.

  Progress 2026-09-01: CTA-S133 seals native REF method calls as `DIRECT`.
  Interned system methods now carry `asAST_TRAIT_EXTERNAL`;
  `ClassifyCallDispatch` no longer treats them as AngelScript vtable slots.
  Named prefixes: SemaAuthority **489/489** `cta-ast-first-sema`
  `20260901_033732_702_7f687a9c`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_033856_321_e1d97aad`. Evidence:
  `attachments/canonical-native-ref-method-direct-dispatch-gate-2026-09-01.md`.

  Progress 2026-09-01: CTA-S134 seals `Consume(3)` as Construct of
  `TConv::TConv(int)` with positional formal `A`. Script one-parameter
  constructors convert without requiring `asAST_TRAIT_IMPLICIT_CONSTRUCTOR`.
  Evidence: `attachments/canonical-implicit-ctor-conversion-gate-2026-09-01.md`.

  Progress 2026-09-01: CTA-S135–S136 lock production-shaped WorldContext
  (`hiddenArgumentIndex=0`, `__WorldContext()`), mixin `IMPLICIT_RECEIVER`, and
  import named+default call records. Those Sema facts were already implemented;
  the new fixtures are characterization locks, not new ranking. Evidence:
  `attachments/canonical-worldcontext-hidden-injection-gate-2026-09-01.md`,
  `attachments/canonical-import-named-default-call-gate-2026-09-01.md`.

  Progress 2026-09-01: CTA-S137 authentic RED then GREEN for Construct dump
  `callArgs=`. `asCASTDump` now prints the sealed argument plan on
  `asAST_EXPR_CONSTRUCT` as well as CALL. Focused RED
  `cta-sema-call-53-construct-dump-red` `20260901_040943_545_b28ae870` 0/1;
  focused GREEN `cta-sema-call-53-construct-dump-green`
  `20260901_041055_966_bb36e185` 1/1. Named prefixes: SemaAuthority **493/493**
  `cta-ast-first-sema` `20260901_041135_244_e747affc`, Frontend CanonicalAST
  **189/189** `cta-ast-first-frontend` `20260901_041310_601_6332049f`. Evidence:
  `attachments/canonical-construct-dump-callargs-gate-2026-09-01.md`.

  Progress 2026-09-01: CTA-S139 authentic RED then GREEN for user-authored
  overloaded assignment. `Object = 7` no longer converts int→T then leftover
  Assign (CodeGen `emitterLine=7950`). Sema ranks the authored rhs against
  `opAssign` first and rewrites a non-generated, non-external method to a Call
  of `T::opAssign(int)` with `receiver=`, `dispatch=direct`, and one positional
  `Value` formal. Canonical Bytecode publisher is CodeGen with zero
  `asCCompiler` invocations; `Entry() == 7`. Generated implicit copy-assign and
  native EXTERNAL `opAssign` stay Assign. Focused RED
  `cta-sema-call-53-opassign-red` `20260901_044409_422_f7649271` 0/1; focused
  GREEN `cta-sema-call-53-opassign-green` `20260901_044831_226_a8999e8b` 1/1;
  CodeGen GREEN `cta-sema-call-53-opassign-codegen-green`
  `20260901_044908_780_52a088ab` 1/1. Named prefixes: SemaAuthority **495/495**
  `cta-ast-first-sema` `20260901_045210_282_d29fb05b`, Frontend CanonicalAST
  **189/189** `cta-ast-first-frontend` `20260901_045506_464_ff4efe8b`.
  ProductionCodeGen prefix **188/198**
  `cta-ast-first-prodcodegen` `20260901_045545_714_7f92d78d` still has ten
  failures in array/native/import/namespace/print families, not this card.
  Evidence: `attachments/canonical-opassign-call-rewrite-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`.

  Progress 2026-09-01: CTA-S140 authentic RED then GREEN for array opIndex
  LValueToRValue. After S132, `Values[0] + 1` sealed Binary of leftover
  `int&` Call; CodeGen added 1 to the pointer (`F()==1904702641`). Sema now
  decays scalar reference operands before builtin arithmetic; CodeGen loads
  the pointee. First Sema prefix after that decay was **493/496**: stripping
  only `REFERENCE` left `IN`/`INOUT` on non-reference Conversion types, so
  Seal rejected `expr-quals` (`const int &in x + 1`, foreach
  `int &inout Iterator + 1`). A quals-only dest then crashed Canonical
  foreach execution: `EmitDeclRef` of `T&` already loads, so Conversion
  double-dereferenced `Iterator + 1`. Decay is now CALL/INDEX only, and
  still strips `PARAM_DIR_MASK`. Named prefixes: SemaAuthority **481/481**
  `cta-ast-first-sema` `20260901_053039_163_2f6f1bb1`, Frontend
  CanonicalAST **189/189** `cta-ast-first-frontend`
  `20260901_053159_759_1889c9fb`, ProductionCodeGen **143/149**
  `cta-ast-first-prodcodegen` `20260901_053231_051_0f66a039` (array
  `F()==42` green; six remaining conversion/namespace/import/getter
  families). Evidence:
  `attachments/canonical-array-index-rvalue-decay-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`.

  Progress 2026-09-01: CTA-S141 authentic RED then GREEN for
  `float32(Value)` of a `float64` parameter. Canonical `Build()` failed
  `-10` with `shadow-declaration-mismatch left="float/q0" right="float32/q0"`
  because `InternPrimitive(ttFloat32)` interned key `"float"`. Intern now
  keys `ttFloat32` as `"float32"`. Focused RED
  `cta-sema-call-53-float32-red2` `20260901_053740_169_158f1fff` 0/1; focused
  GREEN `cta-sema-call-53-float32-green` `20260901_054007_184_5f08e9be` 1/1;
  CodeGen GREEN `cta-sema-call-53-float32-codegen-green`
  `20260901_054035_157_aebcfb19` 1/1. Named prefixes: SemaAuthority
  **482/482** `cta-ast-first-sema` `20260901_054554_412_07c2e67c`, Frontend
  CanonicalAST **189/189** `cta-ast-first-frontend`
  `20260901_054715_523_9347476b`, ProductionCodeGen **144/149**
  `cta-ast-first-prodcodegen` `20260901_054746_876_39358a39`. Remaining
  ProductionCodeGen: two namespace publishes, two prepared-import, native
  non-POD getter. Evidence:
  `attachments/canonical-float64-to-float32-cast-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`.

  Progress 2026-09-01: CTA-S142 authentic RED then GREEN for nested
  namespace function publication. Canonical `Build()` of
  `namespace Tools::Utilities { int Entry() { return Value; } }` failed
  `-10` with `shadow-declaration-mismatch path=decl.parent
  left="ns:Utilities" right="ns:Tools::Utilities"`.
  `CanonicalOwnerIdentity` now walks nested Namespace decls to a
  `::`-joined owner matching Builder `nameSpace->name`. Focused RED
  `cta-sema-call-53-ns-red` `20260901_055233_083_431dbb5e` 0/1; focused
  GREEN `cta-sema-call-53-ns-green` `20260901_055358_180_813910c8` 1/1;
  CodeGen GREEN `cta-sema-call-53-ns-codegen-green`
  `20260901_055426_207_d3ee4c50` 1/1. Named prefixes: SemaAuthority
  **483/483** `cta-ast-first-sema` `20260901_055511_911_61ee3c9e`, Frontend
  CanonicalAST **189/189** `cta-ast-first-frontend`
  `20260901_055632_565_0e2974c7`, ProductionCodeGen **146/149**
  `cta-ast-first-prodcodegen` `20260901_055703_536_968ce2b7` (sibling
  namespaced value-object method also green). Remaining ProductionCodeGen:
  two prepared-import, native non-POD getter. Evidence:
  `attachments/canonical-namespaced-function-runtime-namespace-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`.

  Progress 2026-09-01: CTA-S143 authentic RED then GREEN for prepared-import
  Stage 2 QualType recovery. Parser binds completed identity on `snImport`;
  `GetParsedFunctionDetails` walked inner `snFunction` and failed
  `cannot recover Sema QualTypes`. Lookup now falls back to parent `snImport`.
  Focused RED `cta-sema-call-53-import-red` `20260901_060354_851_7477bbb2` 0/1;
  focused GREEN `cta-sema-call-53-import-green` `20260901_061038_438_cb9dba5d`
  1/1; CodeGen GREEN `cta-sema-call-53-import-codegen-green`
  `20260901_061114_164_ea767737` 1/1. Named prefixes: SemaAuthority **484/484**
  `cta-ast-first-sema` `20260901_061152_437_f7c1bec3`, Frontend CanonicalAST
  **189/189** `cta-ast-first-frontend` `20260901_061319_387_6a74cd10`,
  ProductionCodeGen **147/149** `cta-ast-first-prodcodegen`
  `20260901_061357_349_e698d4a3`. Remaining ProductionCodeGen: imported-
  dependency generation, native non-POD getter. Evidence:
  `attachments/canonical-prepared-import-runtime-shell-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`.

  Progress 2026-09-01: CTA-S144 authentic RED then GREEN for generated
  non-POD getter Call. `Owner.Inner.ReadStored()` sealed leftover
  `MemberRef Inner` as the `ReadStored` receiver even though `GetInner`
  existed with a copy-constructor plan. Sema now rewrites that MEMBER_REF to
  generated GetX for rvalue Call receivers, while `Iterator` / `opFor*` stay
  MEMBER_REF. Focused RED `cta-sema-call-53-getter-red2`
  `20260901_062110_234_012f6df7` 0/1; focused GREEN
  `cta-sema-call-53-getter-green` `20260901_062246_768_39a5eb9c` 1/1; CodeGen
  GREEN `cta-sema-call-53-getter-codegen-green` `20260901_062322_673_2bc653e0`
  1/1. Named prefixes: SemaAuthority **485/485** `cta-ast-first-sema`
  `20260901_062358_914_cc1d2fd6`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_062531_999_0ea96fe4`, ProductionCodeGen
  **148/149** `cta-ast-first-prodcodegen` `20260901_062610_066_3bf4fffe`.
  Remaining ProductionCodeGen: imported-dependency generation. Evidence:
  `attachments/canonical-nonpod-generated-getter-call-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`.

  Progress 2026-09-01: CTA-S145 authentic RED then GREEN for imported
  dependency generation. Stage 2 `BuildGenerateFunctions` failed because
  `PreparedDependency::Payload` was ambiguous with a coexisting old module
  type (`Unknown PreparedImportedDependencyProbe()`). Canonical registered-
  type snapshot now skips historical script modules unless the current build
  imports them; Stage 2 QualType recovery resolves through that imported-type
  authority. Focused RED `cta-sema-call-53-import-dep-red`
  `20260901_062904_971_da53ef61` 0/1; Sema GREEN
  `cta-sema-call-53-import-dep-sema-green` `20260901_063539_285_ebd886f7` 1/1;
  CodeGen GREEN `cta-sema-call-53-import-dep-codegen-green`
  `20260901_063615_313_2341cf72` 1/1. Named prefixes: SemaAuthority **486/486**
  `cta-ast-first-sema` `20260901_063651_779_c389f9ad`, Frontend CanonicalAST
  **189/189** `cta-ast-first-frontend` `20260901_063823_238_d731ad3e`,
  ProductionCodeGen **149/149** `cta-ast-first-prodcodegen`
  `20260901_063902_755_600571a2`. Evidence:
  `attachments/canonical-imported-dependency-generation-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`.

  Progress 2026-09-01: CTA-S146 authentic RED then GREEN for user-authored
  overloaded compound assignment. `Object += 7` no longer converts int→T then
  leftover Assign (CodeGen `code=-7 line=7971`). Sema ranks the authored rhs
  against `opAddAssign` (and the sibling `-=`/`*=`/… map) and rewrites a
  non-generated, non-external method to a Call of `T::opAddAssign(int)` with
  `receiver=`, `dispatch=direct`, and one positional `Value` formal.
  Canonical Bytecode publisher is CodeGen with zero `asCCompiler` invocations;
  `Entry() == 7`. Primitive `int += 1` stays Assign. Focused RED
  `cta-sema-call-53-opaddassign-red` `20260901_065144_030_88903aed` 0/1;
  focused GREEN `cta-sema-call-53-opaddassign-green`
  `20260901_065353_197_2890de06` 1/1; CodeGen GREEN
  `cta-sema-call-53-opaddassign-codegen-green` `20260901_065429_154_8c9af873`
  1/1. Named prefixes: SemaAuthority **487/487** `cta-ast-first-sema`
  `20260901_065509_444_0da33b85`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_065641_158_b24dad4e`, ProductionCodeGen
  **150/150** `cta-ast-first-prodcodegen` `20260901_065719_788_4cbc3ae5`.
  Evidence:
  `attachments/canonical-opaddassign-call-rewrite-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`. Do not check 5.3 or 13.2 from this sibling green.

  Progress 2026-09-01: CTA-S147 authentic RED then GREEN for reverse operator
  calls. `40 + Object` no longer seals leftover Binary `+` of int and T while
  `T::opAdd_r(int) const` sits unused. After lhs `opAdd` misses, Sema ranks
  `opAdd_r` on the rhs and rewrites a Call with `receiver=` Object,
  `dispatch=direct`, and one positional `Value` formal (the original lhs).
  Canonical Bytecode publisher is CodeGen with zero `asCCompiler` invocations;
  `Entry() == 42`. Primitive `int + int` stays Binary. Focused RED
  `cta-sema-call-53-opaddr-red` `20260901_070216_747_07720a1b` 0/1; focused
  GREEN `cta-sema-call-53-opaddr-green` `20260901_070439_804_2388408d` 1/1;
  CodeGen GREEN `cta-sema-call-53-opaddr-codegen-green`
  `20260901_070520_836_e82bbc85` 1/1. Named prefixes: SemaAuthority **488/488**
  `cta-ast-first-sema` `20260901_070559_418_e01d26b7`, Frontend CanonicalAST
  **189/189** `cta-ast-first-frontend` `20260901_070728_113_b02f8409`,
  ProductionCodeGen **151/151** `cta-ast-first-prodcodegen`
  `20260901_070807_341_640c74f7`. Evidence:
  `attachments/canonical-reverse-operator-call-rewrite-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`. Do not check 5.3 or 13.2 from this sibling green.

  Progress 2026-09-01: CTA-S148 authentic RED then GREEN for inequality
  `opEquals`. `Left != Right` no longer uses a bare equality Call as the
  Conditional condition. Sema still ranks `!=` as `opEquals`, then wraps the
  Call in Unary `!`. Focused RED `cta-sema-call-53-ineq-red`
  `20260901_071446_620_decf9de5` 0/1; Sema GREEN
  `cta-sema-call-53-ineq-green` `20260901_071623_608_e456978c` 1/1; CodeGen
  GREEN `cta-sema-call-53-ineq-codegen-green` `20260901_071700_443_d52901ae`
  1/1. Named prefixes: SemaAuthority **489/489** `cta-ast-first-sema`
  `20260901_071738_647_7c3cf43c`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_071917_506_cb8a5e36`, ProductionCodeGen
  **152/152** `cta-ast-first-prodcodegen` `20260901_071956_466_89f6234d`.
  Task 5.3 remains `[ ]`.

  Progress 2026-09-01: CTA-S149 authentic RED then GREEN for `opCmp`
  comparison wrap. `Left < Right` no longer leaves a bare `T::opCmp` Call as
  the Conditional condition (`3 < 1` executed as truthy because opCmp
  returned 2). Sema wraps rewritten `opCmp` in Binary `<`/`>`/`<=`/`>=`
  against IntegerLiteral `0` with `bool` result. Canonical Bytecode publisher
  is CodeGen with zero `asCCompiler` invocations; `Entry() == 0`. Focused RED
  `cta-sema-call-53-opcmp-lt-red` `20260901_072804_392_205c9579` 0/1; Sema
  GREEN `cta-sema-call-53-opcmp-lt-green` `20260901_072923_116_3895b5fc` 1/1;
  CodeGen GREEN `cta-sema-call-53-opcmp-lt-codegen-green`
  `20260901_073000_612_04cbf720` 1/1. Named prefixes: SemaAuthority **490/490**
  `cta-ast-first-sema` `20260901_073316_833_a5c1a20a`, Frontend CanonicalAST
  **189/189** `cta-ast-first-frontend` `20260901_073450_491_3c24299d`,
  ProductionCodeGen **153/153** `cta-ast-first-prodcodegen`
  `20260901_073528_418_ed109df9`. Evidence:
  `attachments/canonical-opcmp-less-than-rewrite-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`. Do not check 5.3 or 13.2 from this sibling green.

  Progress 2026-09-01: CTA-S150 authentic RED then GREEN for bitwise-or
  operator calls. `Object | 2` no longer seals leftover Binary `|` of T and
  int while `T::opOr(int) const` sits unused. `OperatorMethodNameFromText`
  maps `|` (and sibling `**`/`&`/`^`/`<<`/`>>`/`>>>`) to `opOr`/`opPow`/
  `opAnd`/`opXor`/`opShl`/`opShr`/`opUShr`. Lhs operator ranking now uses
  `TryRewriteOverloadedBinaryToCall` so the Call seals `receiver=`,
  `dispatch=direct`, and one positional `Value` formal. Canonical Bytecode
  publisher is CodeGen with zero `asCCompiler` invocations; `Entry() == 10`.
  Focused RED `cta-sema-call-53-opor-red` `20260901_074121_683_f900e2ed` 0/1;
  Sema GREEN `cta-sema-call-53-opor-green` `20260901_074413_088_481e69bc` 1/1;
  CodeGen GREEN `cta-sema-call-53-opor-codegen-green`
  `20260901_074448_248_e5e97866` 1/1. Named prefixes: SemaAuthority **491/491**
  `cta-ast-first-sema` `20260901_074526_489_4a5323f0`, Frontend CanonicalAST
  **189/189** `cta-ast-first-frontend` `20260901_074654_691_afee2967`,
  ProductionCodeGen **154/154** `cta-ast-first-prodcodegen`
  `20260901_074737_090_fc9a97e9`. Evidence:
  `attachments/canonical-opor-call-rewrite-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`. Do not check 5.3 or 13.2 from this sibling green.

  Progress 2026-09-01: CTA-S151 authentic RED then GREEN for swapped `opCmp`.
  `3 < Object` no longer seals leftover Binary `<` of int and T while
  `T::opCmp(int) const` sits unused. After lhs `opEquals`/`opCmp` miss, Sema
  retries the same method on the rhs and wraps swapped comparisons with the
  inverted operator against 0 (`<` → `>`). Canonical Bytecode publisher is
  CodeGen with zero `asCCompiler` invocations; `Entry() == 42`. Focused RED
  `cta-sema-call-53-opcmp-swap-red` `20260901_075220_885_104afa44` 0/1; Sema
  GREEN `cta-sema-call-53-opcmp-swap-green` `20260901_075357_516_29b3a99e` 1/1;
  CodeGen GREEN `cta-sema-call-53-opcmp-swap-codegen-green`
  `20260901_075445_215_5fc7361e` 1/1. Named prefixes: SemaAuthority **492/492**
  `cta-ast-first-sema` `20260901_075521_020_39eaf01e`, Frontend CanonicalAST
  **189/189** `cta-ast-first-frontend` `20260901_075649_388_47f41398`,
  ProductionCodeGen **155/155** `cta-ast-first-prodcodegen`
  `20260901_075728_562_6190b19b`. Evidence:
  `attachments/canonical-swapped-opcmp-rewrite-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`. Do not check 5.3 or 13.2 from this sibling green.

  Progress 2026-09-01: CTA-S152 authentic RED then GREEN for bitwise-not
  operator calls. `~Object` no longer seals leftover Unary `~` of T typed as
  int while `T::opCom() const` sits unused. `ActOnUnaryExpr` maps `~` to
  `opCom`. Unary operator methods now use `ArrangeCallArguments` with empty
  formals so the operand is only `receiver=`. Canonical Bytecode publisher is
  CodeGen with zero `asCCompiler` invocations; `Entry() == 42`. Primitive
  `~int` stays Unary. Focused RED `cta-sema-call-53-opcom-red`
  `20260901_081115_320_b98c56fa` 0/1; Sema GREEN
  `cta-sema-call-53-opcom-green` `20260901_081307_915_b0157fdf` 1/1; CodeGen
  GREEN `cta-sema-call-53-opcom-codegen-green` `20260901_081347_611_73ad21fe`
  1/1. Named prefixes: SemaAuthority
  `FCanonicalASTSemaAuthorityTests` **493/493** `cta-ast-first-sema`
  `20260901_082415_529_e3c8d4e5`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_081639_784_6334c015`, ProductionCodeGen
  `FCanonicalASTProductionCodeGenTests` **156/156** `cta-ast-first-prodcodegen`
  `20260901_082312_036_9584ae19`. Evidence:
  `attachments/canonical-opcom-call-rewrite-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`. Do not check 5.3 or 13.2 from this sibling green.

  Progress 2026-09-01: CTA-S153 authentic RED then GREEN for
  `FString::ApplyFormat(GetName(), ">40")` plus named `Print Duration`.
  Equal-score ranking no longer ties the converting `FString` overload with
  `const ?&`; fewer wildcard formals win, matching LEGACY
  `asCC_TO_OBJECT_CONV` over `asCC_VARIABLE_CONV`. CONSTRUCT of
  `FString(const FName&)` passes the VALUE lvalue address. Named Print
  Duration is sealed. Focused RED `cta-sema-call-53-applyformat-red`
  `20260901_083411_660_91625a75` 0/1; Sema GREEN
  `cta-sema-call-53-applyformat-green` `20260901_083816_248_35e2a456` 1/1;
  ScriptCorpus `FormatSpecifiersAndNamedPrintCompile` 1/1
  `cta-sema-call-53-applyformat-scriptcorpus` `20260901_083859_634_605b766f`;
  ScriptCorpus prefix **18/18** `cta-sema-call-53-applyformat-scriptcorpus-all`
  `20260901_083957_276_4c6b634f`. Named prefixes: SemaAuthority
  `FCanonicalASTSemaAuthorityTests` **494/494** `cta-ast-first-sema`
  `20260901_084656_813_20df8ba9`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_084838_473_b1a20f1c`. Evidence:
  `attachments/canonical-applyformat-fname-named-print-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`. Do not check 5.3 or 13.2 from this sibling green.

  Progress 2026-09-01: CTA-S154 authentic RED then GREEN for prefix
  `++Make().Value`. Postfix Sequence already existed (CTA-S138); prefix still
  intern leftover Unary `pre++` of GetValue, and CodeGen failed closed at
  `emitterLine=4911`. Prefix now reuses the property Get/Set Sequence and
  yields the incremented value. Focused RED `cta-sema-call-53-prefix-inc-red`
  `20260901_090302_155_e64d77c1` 0/1; Sema GREEN
  `cta-sema-call-53-prefix-inc-green` `20260901_090458_727_5db4dbc6` 1/1;
  CodeGen GREEN `cta-sema-call-53-prefix-inc-codegen-green`
  `20260901_090533_977_0c03ce0c` 1/1 `Entry()==6`. Named prefixes:
  SemaAuthority `FCanonicalASTSemaAuthorityTests` **495/495**
  `cta-ast-first-sema` `20260901_090724_547_10d33db7`, Frontend CanonicalAST
  **189/189** `cta-ast-first-frontend` `20260901_090906_382_8d1e74f2`,
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **157/157**
  `cta-ast-first-prodcodegen` `20260901_090949_590_664ba19c`. Evidence:
  `attachments/canonical-prefix-property-increment-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`. Do not check 5.3 or 13.2 from this sibling green.

  Progress 2026-09-01: CTA-S155 authentic RED then GREEN for prefix
  `++Make()[0]`. Compound `Make()[0] += 1` already existed (CTA-S132);
  prefix still intern leftover Unary `pre++` of the lvalue `opIndex` Call,
  and CodeGen failed closed at `emitterLine=4911`. Lvalue `opIndex` now
  reuses the OpaqueValue Sequence plus Assign through the Call. By-value
  `opIndex` stays Unary so the structural postfix action remains ordered.
  Focused RED `cta-sema-call-53-prefix-index-red`
  `20260901_091610_608_dab83c01` 0/1; Sema GREEN
  `cta-sema-call-53-prefix-index-green` `20260901_092258_683_f5a3e7e1` 1/1;
  CodeGen GREEN `cta-sema-call-53-prefix-index-codegen-green`
  `20260901_092339_064_da81d9ba` 1/1 `Entry()==6`. Named prefixes:
  SemaAuthority `FCanonicalASTSemaAuthorityTests` **496/496**
  `cta-ast-first-sema` `20260901_092414_625_859cf5b2`, Frontend CanonicalAST
  **189/189** `cta-ast-first-frontend` `20260901_092557_131_b99869ed`,
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **158/158**
  `cta-ast-first-prodcodegen` `20260901_092636_786_e744a5ef`. Evidence:
  `attachments/canonical-prefix-index-increment-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`. Do not check 5.3 or 13.2 from this sibling green.

  Progress 2026-09-01: CTA-S156 authentic RED then GREEN for postfix
  `Make()[0]++`. Prefix already yielded the incremented value (CTA-S155);
  postfix still yielded the lvalue `opIndex` Call (`parts=...,21`).
  Postfix now decays that Call to an rvalue int, snapshots it, Assigns
  `orig + 1`, and yields `orig`. Focused RED
  `cta-sema-call-53-postfix-index-red` `20260901_093228_479_8e7f2eef` 0/1;
  Sema GREEN `cta-sema-call-53-postfix-index-green`
  `20260901_093354_403_5ed4f9dc` 1/1; CodeGen GREEN
  `cta-sema-call-53-postfix-index-codegen-green`
  `20260901_093431_589_511490b6` 1/1 `Entry()==5`. Named prefixes:
  SemaAuthority `FCanonicalASTSemaAuthorityTests` **497/497**
  `cta-ast-first-sema` `20260901_093508_711_49a96479`, Frontend CanonicalAST
  **189/189** `cta-ast-first-frontend` `20260901_093643_583_158d5adc`,
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **159/159**
  `cta-ast-first-prodcodegen` `20260901_093723_000_75c636e1`. Evidence:
  `attachments/canonical-postfix-index-increment-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`. Do not check 5.3 or 13.2 from this sibling green.

  Progress 2026-09-01: CTA-S157 authentic RED then GREEN for rvalue
  `Make() += 7`. Overloaded `+=` required an lvalue, so the VALUE
  temporary was `expression-not-assignable`. Sema now rewrites
  overloaded compound assignment on a non-const VALUE temporary to
  `T::opAddAssign(int)` and materializes the receiver. Focused RED
  `cta-sema-call-53-rvalue-addassign-red2` `20260901_095803_319_95667f0b`
  0/1; Sema GREEN `cta-sema-call-53-rvalue-addassign-green`
  `20260901_095913_231_e5bf06f6` 1/1; CodeGen GREEN
  `cta-sema-call-53-rvalue-addassign-codegen-diag`
  `20260901_100331_234_928907f4` 1/1 `Entry()==42`. Named prefixes:
  SemaAuthority `FCanonicalASTSemaAuthorityTests` **498/498**
  `cta-ast-first-sema` `20260901_100412_721_05254227`, Frontend CanonicalAST
  **189/189** `cta-ast-first-frontend` `20260901_100619_479_0c81dcc8`,
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **160/160**
  `cta-ast-first-prodcodegen` `20260901_100704_554_6cf9e29f`. Evidence:
  `attachments/canonical-rvalue-opaddassign-call-rewrite-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`. Do not check 5.3 or 13.2 from this sibling green.

  Progress 2026-09-01: CTA-S158 authentic RED then GREEN for unary-not
  `!Object`. Leftover Unary `!` of VALUE `T` was typed `int` while
  `T::opImplConv() const` sat unused. Sema now wraps Unary `!` of that
  Call typed `bool`. Mixin omitted-default and member named+default
  execute gates in the same batch were already green (characterization).
  Focused RED `cta-sema-call-53-unary-not-red`
  `20260901_101808_022_8c99b271` 0/1; Sema GREEN
  `cta-sema-call-53-unary-not-green` `20260901_101954_006_850c93ec` 1/1;
  CodeGen GREEN `cta-sema-call-53-unary-not-codegen-green`
  `20260901_102035_097_a1d054ab` 1/1 `Entry()==42`. Named prefixes:
  SemaAuthority `FCanonicalASTSemaAuthorityTests` **501/501**
  `cta-ast-first-sema` `20260901_102114_678_4a6368a8`, Frontend CanonicalAST
  **189/189** `cta-ast-first-frontend` `20260901_102326_106_439491a0`,
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **163/163**
  `cta-ast-first-prodcodegen` `20260901_102802_514_736135af`. Evidence:
  `attachments/canonical-unary-not-opimplconv-call-rewrite-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`. Do not check 5.3 or 13.2 from this sibling green.

  Progress 2026-09-01: CTA-S159 authentic RED then GREEN for Conditional
  `Object ? 42 : 0`. Leftover `cond=` was DeclRef of VALUE `T` while
  `T::opImplConv() const` sat unused. Sema now rewrites the condition
  through the shared `opImplConv` helper also used by unary `!`.
  Focused RED `cta-sema-call-53-cond-implconv-red`
  `20260901_103314_213_a149c09e` 0/1; Sema GREEN
  `cta-sema-call-53-cond-implconv-green` `20260901_103744_917_b39fdc0b`
  1/1; CodeGen GREEN `cta-sema-call-53-cond-implconv-codegen-green`
  `20260901_103828_445_08d69c22` 1/1 `Entry()==0`. Named prefixes:
  SemaAuthority `FCanonicalASTSemaAuthorityTests` **502/502**
  `cta-ast-first-sema` `20260901_103912_922_701ff05f`, Frontend CanonicalAST
  **189/189** `cta-ast-first-frontend` `20260901_104142_252_6e3255bc`,
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **164/164**
  `cta-ast-first-prodcodegen` `20260901_104228_529_43d9e184`. Evidence:
  `attachments/canonical-conditional-opimplconv-call-rewrite-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`. Do not check 5.3 or 13.2 from this sibling green.

  Progress 2026-09-01: CTA-S160 authentic RED then GREEN for
  `if (Object)` / `while (Object)`. Leftover stmt conds were DeclRef of
  VALUE `T`. `ActOnIfStmt` rewrites through
  `RewriteValueToBoolViaOpImplConv`; typed while finish wrote
  `action.condition` directly and needed the same rewrite.
  Focused RED `cta-sema-call-53-if-while-implconv-red`
  `20260901_104710_813_9a9871de` 0/1; Sema GREEN
  `cta-sema-call-53-if-while-implconv-green`
  `20260901_105225_262_887c5cb2` 1/1; CodeGen GREEN
  `cta-sema-call-53-if-while-implconv-codegen-green`
  `20260901_105305_350_7541c833` 1/1 `Entry()==0`. Named prefixes:
  SemaAuthority `FCanonicalASTSemaAuthorityTests` **503/503**
  `cta-ast-first-sema` `20260901_105345_268_ad6bbd4b`, Frontend CanonicalAST
  **189/189** `cta-ast-first-frontend` `20260901_105622_183_15889422`,
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **165/165**
  `cta-ast-first-prodcodegen` `20260901_105709_266_a6994173`. Evidence:
  `attachments/canonical-if-while-opimplconv-call-rewrite-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`. Do not check 5.3 or 13.2 from this sibling green.

  Progress 2026-09-01: CTA-S161 authentic RED then GREEN for
  `for (; Object; )`. Leftover stmt cond was DeclRef of VALUE `T`.
  Typed for finish wrote `action.condition` directly; it now rewrites
  through `RewriteValueToBoolViaOpImplConv`, matching `ActOnForStmt`.
  Focused RED `cta-sema-call-53-for-implconv-red`
  `20260901_110108_737_1bdc5f9c` 0/1; Sema GREEN
  `cta-sema-call-53-for-implconv-green` `20260901_110238_866_636b24ed`
  1/1; CodeGen GREEN `cta-sema-call-53-for-implconv-codegen-green`
  `20260901_110546_244_1a88677e` 1/1 `Entry()==0`. Named prefixes:
  SemaAuthority `FCanonicalASTSemaAuthorityTests` **504/504**
  `cta-ast-first-sema` `20260901_110630_450_438d9790`, Frontend CanonicalAST
  **189/189** `cta-ast-first-frontend` `20260901_111036_640_dfc1bd63`,
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **166/166**
  `cta-ast-first-prodcodegen` `20260901_111131_914_cde5bbd1`. Evidence:
  `attachments/canonical-for-cond-opimplconv-call-rewrite-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`. Do not check 5.3 or 13.2 from this sibling green.

  Progress 2026-09-01: CTA-S168 authentic RED then GREEN for
  `return Object`. Leftover Return was DeclRef of VALUE `T` while
  `T::opImplConv() const` sat unused. Return now rewrites through
  `TryRewriteObjectConvOperator(..., false)` so implicit conversion
  cannot pick explicit `opConv` (CTA-S167). Focused RED
  `cta-sema-call-53-opimplconv-return-red` `20260901_125450_643_feaae34d`
  0/1; Sema GREEN `cta-sema-call-53-opimplconv-return-green`
  `20260901_125727_919_e38ebcb2` 1/1; CodeGen GREEN
  `cta-sema-call-53-opimplconv-return-codegen-green`
  `20260901_130241_310_e6b09276` 1/1 `Entry()==42`. Named prefixes:
  SemaAuthority `FCanonicalASTSemaAuthorityTests` **511/511**
  `cta-ast-first-sema` `20260901_130509_797_a4d678fd`, Frontend CanonicalAST
  **189/189** `cta-ast-first-frontend` `20260901_130657_339_d9b78116`,
  ProductionCodeGen `FCanonicalASTProductionCodeGenTests` **174/174**
  `cta-ast-first-prodcodegen` `20260901_130742_201_92ae2c69`. Evidence:
  `attachments/canonical-return-object-opimplconv-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`. Do not check 5.3 or 13.2 from this sibling green.

  Progress 2026-09-01: CTA-S169 authentic RED then GREEN for local
  initialization `int Value = Object`. The declaration init previously
  retained a VALUE `T` DeclRef / generic Conversion while
  `T::opImplConv() const` sat unused. `EmitTypedLocalVariableStmts` now
  rewrites the authored initializer through
  `TryRewriteObjectConvOperator(..., false)` before funcdef conversion and
  `AddDeclInit`. Focused RED `cta-sema-call-53-opimplconv-init-red`
  `20260901_131237_872_d1e996b9` 0/1; Sema GREEN
  `cta-sema-call-53-opimplconv-init-green`
  `20260901_131349_241_cd61fc59` 1/1; CodeGen GREEN
  `cta-sema-call-53-opimplconv-init-codegen-green`
  `20260901_131427_149_9e24b4d0` 1/1 `Entry()==42`. Named prefixes:
  SemaAuthority `FCanonicalASTSemaAuthorityTests` **512/512**
  `cta-ast-first-sema` `20260901_131504_061_96d355a1`, Frontend
  CanonicalAST **189/189** `cta-ast-first-frontend`
  `20260901_131648_284_c5dc602f`, ProductionCodeGen
  `FCanonicalASTProductionCodeGenTests` **175/175**
  `cta-ast-first-prodcodegen` `20260901_132413_481_dca91aa3`. Evidence:
  `attachments/canonical-local-init-object-opimplconv-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`: call-argument implicit conversion and the other
  unsealed call families are outside this card. Do not check 13.2.

  Progress 2026-09-01: CTA-S170 authentic RED then GREEN for call-argument
  implicit conversion `Consume(Object)`. Candidate ranking already recognized
  `T::opImplConv() const`, but formal conversion published a generic
  Conversion annotated with that declaration; CodeGen failed closed with
  `unsupported conversion`, `srcType=T`, `dstType=int`. Sema now materializes
  the selected implicit operator as an ordinary Call with exact receiver and
  result type before the enclosing call argument is sealed. The enclosing
  `asSASTCallArgument` retains formal `Value`, formal index 0, positional
  origin and canonical formal type. This follows the Clang boundary where
  Sema `ActOnCallExpr` / `BuildCallExpr` constructs the final typed expression
  and CodeGen only consumes it; no CodeGen semantic fallback was added.
  Focused AST RED `cta-sema-call-53-opimplconv-arg-red`
  `20260901_133454_183_c064f2b2` 0/1 and CodeGen RED
  `cta-sema-call-53-opimplconv-arg-codegen-red`
  `20260901_133536_786_582e9851` 0/1; Sema GREEN
  `cta-sema-call-53-opimplconv-arg-green`
  `20260901_133900_388_25b9043a` 1/1; CodeGen GREEN
  `cta-sema-call-53-opimplconv-arg-codegen-green`
  `20260901_133934_915_fe8f7b26` 1/1, publisher Canonical CodeGen,
  legacy count 0, `Entry()==42`. Named prefixes: SemaAuthority
  `FCanonicalASTSemaAuthorityTests` **513/513** `cta-ast-first-sema`
  `20260901_134019_465_a5b28263`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_134218_459_3ab151d8`, ProductionCodeGen
  `FCanonicalASTProductionCodeGenTests` **176/176**
  `cta-ast-first-prodcodegen` `20260901_134259_602_bf729e29`. Evidence:
  `attachments/canonical-call-argument-object-opimplconv-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`: `opHndlAssign`, funcdef-variable calls, remaining
  reverse operators, mixin/import execute leftovers and converting-constructor
  execute are outside this card. Do not check 13.2.

  Progress 2026-09-01: CTA-S171 reconciles that provisional remaining-call
  list without adding production behavior. Converting-constructor execute,
  mixin omitted-default/method execution, direct/import named/default
  execution, and local funcdef-variable `CallPtr` execution all passed
  immediately under Canonical CodeGen with zero LEGACY compiler invocation.
  A wider SemaAuthority run found two stale post-S170 test oracles that still
  expected generic Conversion; the production dumps already contained the
  correct `MaterializeTemporary(Call(opImplConv))`. The tests now authenticate
  exact Call receiver/result and argument-formal provenance. Final gates:
  build PASS `cta-sema-call-53-funcdef-local-characterization`
  `20260901_140646_347_aba60165`; SemaAuthority **528/528**
  `cta-sema-call-53-characterization-full`
  `20260901_140141_107_39780a54`; ProductionCodeGen full prefix **225/225**
  `cta-sema-call-53-inventory-prodcodegen-full`
  `20260901_140759_466_f2a66118`. Evidence:
  `attachments/canonical-call-inventory-reconciliation-2026-09-01.md`.
  Task 5.3 remains `[ ]`: the authentic remaining call families are now
  `opHndlAssign` and reverse-operator family completeness beyond `opAdd_r`.
  Do not check 13.2.

  Progress 2026-09-01: CTA-S172 closes ASHANDLE plain assignment without
  backend inference. The authentic positive RED sealed `Left = Right` as
  `Assign(... callee=opAssign)` despite `asOBJ_ASHANDLE`. Canonical Sema now
  reads the pointer-free registered/template declaration fact, selects an
  exact EXTERNAL `opHndlAssign`, and publishes a real Call with receiver,
  result and formal provenance. Production execution distinguishes the two
  registered operators and returns `42`, with Canonical CodeGen publisher and
  zero LEGACY compiler invocation. A second authentic RED showed a missing
  `opHndlAssign` could still fall back to `opAssign`; Sema now emits
  `no-appropriate-opHndlAssign` and returns no generic Assign. Final build PASS
  `cta-sema-call-53-hndlassign-negative-green`
  `20260901_143215_383_ff9b993d`; positive/negative focused **2/2**
  `cta-sema-call-53-hndlassign-negative-green`
  `20260901_143311_549_5fc2edfb`; SemaAuthority **530/530**
  `cta-sema-call-53-hndlassign-sema-full`
  `20260901_143410_833_cbbe970c`; ProductionCodeGen full prefix **226/226**
  `cta-sema-call-53-hndlassign-prodcodegen-full`
  `20260901_143618_627_89cd71b5`. Evidence:
  `attachments/canonical-ashandle-ophndlassign-call-rewrite-gate-2026-09-01.md`.
  Task 5.3 remains `[ ]`: only reverse-operator family completeness beyond
  `opAdd_r` remains in the current call-family inventory. Do not check 13.2.

  Progress 2026-09-01: CTA-S173 replaces the single `opAdd_r` example with a
  family-complete matrix for all twelve reverse binary operator names used by
  the LEGACY compiler: `opAdd_r`, `opSub_r`, `opMul_r`, `opDiv_r`, `opMod_r`,
  `opPow_r`, `opOr_r`, `opAnd_r`, `opXor_r`, `opShl_r`, `opShr_r`, and
  `opUShr_r`. Every row passed characterization-first as an exact rhs-receiver
  Call with formal provenance; production Canonical CodeGen executed the
  unique sentinel sum `78` with zero LEGACY compiler invocations. Build PASS
  `cta-sema-call-53-reverse-matrix-characterization`
  `20260901_144937_383_654a9ba1`; Sema matrix **1/1**
  `20260901_145015_984_640531a7`; execution matrix **1/1**
  `20260901_145059_838_84d11a36`. No production edit was required. Evidence:
  `attachments/canonical-reverse-operator-family-matrix-gate-2026-09-01.md`.
  Task 5.3 nevertheless remains `[ ]`: resolving the explicit
  `TypedSemanticIR/Call*` clause against the pre-deletion Git tree exposed the
  LEGACY-only compile-out rewrite oracle and an absent exact import
  bind/rebind/unbind immutability characterization. Native ABI/bridge metadata
  remains intentionally assigned to Task 7.4's immutable Runtime binding
  snapshot rather than copied into ABI-independent `CallExpr`. Audit:
  `reviews/task-5.3-call-oracle-closure-audit-2026-09-01.md`.

  Progress 2026-09-01: CTA-S174 ports the deleted
  `TypedSemanticIR/CallRewrites` oracle into Canonical Sema. The append-only
  `CallRewrite` expression and declaration traits seal `CompileOutEntirely`,
  `ReplaceWithFirstParam`, and `CompileOutAsMethodChain` as final semantic
  values before CodeGen. Discarded argument subtrees are removed from
  diagnostics/deferred work and tombstoned, so unresolved authored operands
  are neither diagnosed nor retained as dangling nodes. Production CodeGen
  consumes only the sealed rewrite and never queries live `compileOutType`.
  Sidecar V12 preserves all three shapes byte-exactly, and the UE Cache wrapper
  is synchronized to V12 with a compile-time schema-skew guard. Authentic RED
  and two intermediate verifier failures precede GREEN; exact Sema + CodeGen +
  Sidecar is **3/3 PASS**, complete SemaAuthority + ProductionCodeGen is
  **760/760 PASS**, complete Cache V12 is **586/586 PASS**, complete Frontend
  CanonicalAST is **189/189 PASS**, and the post-guard build passes. Evidence:
  `attachments/canonical-compile-out-call-rewrite-gate-2026-09-01.md` and
  `reviews/cta-s174-compile-out-call-rewrite-review-2026-09-01.md`.
  Task 5.3 remains `[ ]` only for the exact import bind/rebind/unbind retained-
  snapshot immutability characterization and final call-family audit. Do not
  check 13.2 or native ABI/bridge Task 7.4 from this gate.

  Completed 2026-09-01: CTA-S175 ports the final historical
  `TypedSemanticIR/CallTargets/Imported` oracle. The retained Canonical graph
  names one provider-A `ImportDecl` by stable signature/origin and one exact
  zero-argument Call with a concrete `int` result; it contains neither the
  Engine-local import slot nor either mutable provider FunctionId. Binding
  provider A, rebinding provider B, and unbinding change only
  `sBindInfo::boundFunctionId`; after every mutation the complete AST dump and
  Sidecar V12 bytes remain identical. Canonical CodeGen keeps `CALLBND`, uses
  zero LEGACY compiler invocations, and executes `11 -> 29 -> exception`.
  Characterization RED first proved the test had not requested retained AST;
  enabling the public `asAST_RETAIN_SNAPSHOT` policy closed the test-only
  fixture gap, with no production edit. Build PASS; focused Sema and CodeGen
  are **1/1 PASS** each; complete SemaAuthority is **533/533 PASS**; complete
  ProductionCodeGen is **229/229 PASS**; the immediately preceding CTA-S174
  closure also supplies Frontend CanonicalAST **189/189 PASS** and Cache V12
  **586/586 PASS**. The Git-history mapping of every deleted
  `TypedSemanticIR/Call*` oracle is now closed, so Task 5.3 is checked.
  Evidence: `attachments/canonical-import-binding-immutability-gate-2026-09-01.md`
  and `reviews/cta-s175-task-5.3-closure-review-2026-09-01.md`. This does not
  check broader Sema Task 13.2 or native ABI/bridge consumer Task 7.4.

- [x] 5.4 <!-- TDD --> Add and implement explicit sequencing/single-evaluation nodes for property/index/mutation chains, short-circuit logic, conditional expressions, temporaries, and compiler-generated values. Prove side-effect trace parity in separate legacy/canonical Engines.

  Closed by CTA-S177 on 2026-09-01. Canonical Sema now seals explicit
  `Sequence` / `OpaqueValue` phases for supported property and index compound
  assignment plus prefix/postfix mutation, while logical short-circuit,
  conditional reference/value selection, value temporaries and generated
  struct values execute with independent LEGACY/CANONICAL side-effect oracles.
  The final review found a real scalar-reference alias bug in
  `MutateAndReturn()[0] += GetSharedRhs()`: Canonical delayed the RHS load until
  after the receiver changed the referenced storage and produced `21` instead
  of `11`. Both index-compound paths now decay a scalar reference to an rvalue
  before the RHS `OpaqueValue`, preserving the required RHS-first snapshot and
  trace `8,9,2` with single evaluation.

  The supported-source boundary is explicit: LEGACY property-accessor unary
  forms remain independently rejected and therefore are not claimed as parity;
  assignment-as-expression is rejected by the current parser and is not used
  as a false execution gate. Cache V2/V12 remains the user-approved deferred
  prototype and is not a Task 5.4 blocker. Final gates: Build PASS, Semantics
  **15/15**, SemaAuthority **538/538**, ProductionCodeGen **230/230**, and
  Frontend CanonicalAST **189/189**, all with zero failures/skips. Evidence:
  `attachments/canonical-sequencing-single-evaluation-closure-gate-2026-09-01.md`
  and `reviews/cta-s177-task-5.4-closure-review-2026-09-01.md`. This closes only
  5.4; structured control 5.5/5.6, lifetime 5.7/5.8, broad Sema 13.2,
  backend/install and product-cutover rows remain independently open.

- [x] 5.5 <!-- TDD --> Add failing statement/control tests for block, declaration/expression statement, if/else, for/while/do, switch/case/default/fallthrough, break/continue/return, initializer/condition/body/increment phases, and safe-point roles.

  Closed by CTA-S178 on 2026-09-01 at plugin `182da08`. The positive
  source-to-sealed-AST matrix now locks authored Block/DeclStmt/ExprStmt,
  no-else If and bare Returns, exact For init/condition/body/multi-increment
  phases and source ranges, While/DoWhile, unsigned grouped Switch with ordered
  Case/default geometry, Fallthrough, nearest Break/Continue targets, Return,
  and exact FunctionEntry/Statement/Call/Return/LoopEntry/LoopBackedge/Transfer
  roles. Synthetic declaration-initializer ExprStmt remains deliberately
  `None`, so an authored declaration does not publish a duplicate source
  stepping event.

  The review found two production losses with authentic RED/GREEN evidence:
  authored Decl/Expr/If/Case statement roles were not all sealed, and Canonical
  Bytecode dropped the sealed LoopBackedge safe point for For/foreach and
  DoWhile. The loop oracle disables line cues so a transformed LINE opcode
  cannot create a false SUSPEND green. The strengthened VM control sentinel
  executes all three transfer paths: Switch Break must continue to the body
  tail (`305`), For Continue must skip that tail (`32`), and default Return
  exits early (`0`). Final gates are Build PASS, SemaAuthority **542/542**,
  ProductionCodeGen **231/231**, Semantics **15/15**, and the isolated VM
  control sentinel **1/1**, all with zero failures/skips. Independent code and
  test review returned APPROVE with no blocker/major. Evidence:
  `attachments/canonical-statement-control-positive-matrix-gate-2026-09-01.md`
  and `reviews/cta-s178-task-5.5-closure-review-2026-09-01.md`.

  This closes the positive statement/control matrix only. Task 5.6 remains
  open for forged wrong-kind/dangling/non-ancestor/skipped-nearer/default/
  fallthrough/phase graphs and fail-closed verifier/publication. A separately
  discovered local `Tail` declaration-slot anomaly is tracked under 9.2/9.6;
  it is not classified as another `+=` semantic failure or as a 5.5 transfer
  failure.

- [x] 5.6 <!-- TDD --> Implement `as_sema_stmt.h/.cpp` with structured control targets and source-order phases; verifier must reject wrong-kind, non-ancestor, skipped-nearer, dangling, duplicate-case/default-order, and invalid fallthrough edges using migrated HIR control tests.

  Historical reason this remained open: the first implementation still had
  backend `asCCompiler` reruns, incomplete control-test migration, and missing
  `SwitchInvalidValue` / statement-role behavior. That state is superseded by
  the closure below. Cleanup-on-transfer belongs to the lifetime tasks
  `5.7/5.8/7.5/9.5`; the complete backend/cutover isolation remains under
  sections 9, 10 and 13.6. Task 5.6 closes only structured statement/control
  semantics and their fail-closed publication firewall. The maintained fork
  has no production HIR layer, so the migrated evidence is the source-built
  Canonical AST, forged verifier graphs, snapshot/sidecar round trip and
  Canonical Bytecode execution, not a fictional HIR artifact.

  Progress 2026-08-22: Continue→While and Break→nearest Switch dump on compile→seal. Fallthrough targets the next Case. Compile→seal dumps Clang ForStmt `init=`/`body=`/`incr=` and IfStmt `then=`/`else=`. B-56 dump lock `safepoint=` + verifier oracles landed (SemaAuthority **213/213**). Frontend Seal `decl-body` closed by reusing BLOCK only when `owner == fn` (Frontend **85/85** `wave-b-56-frontend4`, CanonicalAST **261/261** `wave-b-56-canonical`). **Not 5.6/13.2 close** — backends still rerun Sema; HIR control tests not fully migrated.

  Progress 2026-08-24: source `foreach` now preserves its distinct AST node
  while Sema seals Clang-style `init` / condition / `body` / `incr` phases.
  All four resolved protocol calls share one opaque range receiver, so range
  single-evaluation is an AST fact rather than a backend convention. The dump
  names the sealed phases. The follow-up keyed form retains both source
  declarations and seals exact `opForKey`; all five protocol calls share the
  same receiver. SemaAuthority is **274/274**, and production execution is
  **82/82** with zero legacy compiler invocations. The complete Compiler
  CanonicalAST gate is **389/389** after aligning an independent stale
  field-offset negative to the stronger `class-field-layout` Seal firewall.
  Object-iterator cleanup,
  transfer cleanup, and the full migrated HIR control matrix remain open. Evidence:
  `attachments/canonical-foreach-protocol-gate-2026-08-24.md`.

  Closed 2026-09-02 (CTA-S180/CTA-S181): Canonical Sema now authors structured
  Break/Continue/Fallthrough targets, If/For/Foreach source-order phases,
  statement and loop-safe-point roles, authenticated 32-bit Switch Case
  comparison domains, and the exhaustive-enum `SwitchInvalidValue` edge.
  The verifier rejects wrong-kind, non-ancestor, skipped-nearer, dangling,
  duplicate Case, default-order, malformed phase and invalid fallthrough
  graphs before publication. The final closure repaired three independently
  reviewed gaps: cross-enum mismatch now diagnoses then continues duplicate
  analysis with analyze-all/commit-none; exact case-sensitive `MAX`/`*_MAX`
  enum sentinels no longer prevent exhaustiveness; and Canonical Bytecode
  consumes only the authenticated invalid-value role, including a jump around
  the synthetic throw after the last ordinary Case body. Final current-source
  owners are SemaAuthority **566/566**, Cache ASTBodySidecar **27/27**,
  Frontend Verifier **74/74**, Frontend CanonicalAST **203/203**,
  ProductionCodeGen **234/234**, Semantics **16/16**, and Module Snapshot
  **13/13**, all with zero failures and skips. Detailed RED/GREEN paths,
  structural requirements and non-claims are recorded in
  `attachments/canonical-structured-control-verifier-closure-gate-2026-09-01.md`
  and `reviews/semantic-correctness-issue-ledger-2026-09-01.md`.

- [ ] 5.7 <!-- TDD --> Complete the AST-first lifetime matrix for value objects, owning handles/references, exact constructor/destructor/release selection, temporary materialization/lifetime extension, initializer success activation, base/member/delegating/array partial construction, deferred/out parameters, return/transfer cleanup, global initialization, explicitly supported exceptional/abort exits, suspend boundaries, and current `try/catch` rejection. Each source case must assert the sealed protocol before Bytecode/AOT behavior and include a forged-protocol negative where the fact can be malformed.

  Why this is still open: complete value/temporary lifetime authority is not
  yet canonical. The value-object foreach slice now proves one exact source
  lifetime end-to-end: generated iterator construction, sealed destructor
  cleanup, verifier rejection of a forged cleanup, transfer-aware Canonical
  CodeGen, and no double destruction. Deferred/out parameters, general return
  temporaries, global and exceptional cleanup, suspend/resume lifetimes, and
  `try/catch` rejection still need AST-first coverage. Tests that merely execute
  old VM destructor behavior do not prove those AST cleanup plans.

  Progress 2026-08-25: `SourceObjectIteratorForeachSealsExactLifetimeCleanupPlan`
  and `VerifierRejectsForgedForeachScopeExitCleanupLiteral` establish the
  object-iterator source and malformed-graph gates. The production test proves
  cleanup before the first post-loop call after `break`. Final SemaAuthority is
  **276/276** and complete CanonicalAST is **392/392**. See
  `attachments/canonical-foreach-protocol-gate-2026-08-24.md`. This is one
  lifetime family, not the complete 5.7 matrix.

  Progress 2026-08-27: a real UE `TArray<int>` local now proves exact default
  constructor binding before publication and executes through Canonical
  CodeGen with its existing scope cleanup intact. ScriptCorpus is **5/5** and
  complete TypedASTJIT is **71/71**. This does not cover arbitrary container
  destructors, exceptional/transfer cleanup, deferred/out values, or suspend
  lifetimes; 5.7 remains open.

  Progress 2026-08-28 (CTA-S44): initialized direct lexical value-object
  locals with an exact Canonical destructor now seal reverse-order cleanup for
  normal block exit and transfers that leave the block. Nested early return
  proves inner-to-outer order; production execution proves three constructs
  and exactly three destructs on both early and normal routes. A forged
  wrong-owner destructor is rejected by the verifier. This does not cover
  deferred/out values, globals, exception-only paths, suspend/resume or owning
  handle/reference cleanup plans, so 5.7 remains open. Source `typedef` is
  primitive-only and is not counted as a value-object lifetime family. Evidence:
  `attachments/canonical-lexical-value-cleanup-plan-gate-2026-08-28.md`.

  Progress 2026-08-28 (CTA-S48): an exact primitive script property passed to
  `T&out` now has AST-first RED/GREEN coverage, including a forged-setter
  verifier rejection, single-evaluation receiver, exact setter call count and
  execution result `42` with zero LEGACY compiler invocations. Non-POD/value-
  object out, `&inout`, reference-return aliasing, exception/suspend and global
  deferred lifetimes remain open, so 5.7 is not checked. Evidence:
  `attachments/canonical-deferred-property-out-writeback-gate-2026-08-28.md`.

  Progress 2026-09-02 (CTA-S182): the first remaining temporary-lifetime card
  is GREEN. `SourceTemporaryFullExpressionSealsExactLifetimeRecord` proves a
  real source `FTracked();` expression statement authors one exact
  `TEMPORARY / DESTROY_VALUE / FULL_EXPRESSION` record with the materialize
  activation, exact destructor and ExprStmt semantic region. The shared view
  derives its success-sensitive commit and full-expression exit plan without
  fabricating a lexical scope. Read-only review found and closed three
  publication-firewall gaps: missing/foreign destructor facts could not be
  confused with a non-candidate, Construct/wrapper types and owners are exact,
  and coherent `REFERENCE_OBJECT + HANDLE + AUTO_HANDLE` class temporaries are
  excluded without letting a partially forged value temporary escape.
  Authentic source RED was **0/1** and forged/shared-view RED was **70/72**.
  Final owners at plugin commit `41cafb7` are Frontend Verifier **80/80**,
  SemaAuthority **567/567**, ProductionCodeGen temporary execution **1/1**
  with Canonical publisher and zero LEGACY compiler invocations, and AST Body
  Sidecar **27/27**. Complete-owner runs also exposed and repaired the legal
  empty `for (; Cond; )` hook regression and a class/reference-object
  misclassification; neither was accepted as GREEN until the owning prefix
  passed. LLVM/Clang's
  `MaybeBindToTemporary` plus `ActOnFinishFullExpr` remains the ownership
  model: Sema closes the full expression; backends do not infer destruction.
  Multiple/call/conditional/Return temporaries, lifetime extension,
  deferred/reference/global/suspend families and runtime consumption remain
  open, so 5.7 is not checked. Evidence and non-claims:
  `attachments/canonical-temporary-full-expression-lifetime-gate-2026-09-02.md`.

  Progress 2026-09-02 (CTA-S183): Canonical Bytecode now consumes the exact
  authenticated full-expression plan for the direct expression-statement
  temporary family introduced by CTA-S182. The authentic RED retained and
  verified the record/plan, then returned destruction trace `0` instead of
  `7`, proving the materialized value remained live until the generic function
  epilogue. The GREEN emitter evaluates the expression once, looks up only the
  owning ExprStmt's `FULL_EXPRESSION` plan, maps the exact Materialize ExprId to
  its backend-local slot, calls the record's exact destructor target, and marks
  the slot uninitialized/dead so epilogue cleanup cannot destroy it twice. It
  does not inspect Cleanup literals, destructor spelling, dump text or
  `beh.destruct` to select the action. Focused execution is **1/1 PASS** with
  Canonical publisher provenance and zero LEGACY invocations. Plugin commit
  `0816dd4` carries the implementation. Complete
  ProductionCodeGen is **235/235 PASS** and AST Body Sidecar is **27/27 PASS**,
  while unchanged SemaAuthority is **567/567 PASS** and Frontend Verifier is
  **80/80 PASS**, all with zero failures/skips. Return/call/conditional/multiple temporaries,
  returned ownership, lifetime extension, exception/suspend execution and
  TypedASTJIT native object-frame cleanup remain open, so 5.7 is not checked.
  Evidence and non-claims:
  `attachments/canonical-temporary-full-expression-bytecode-consumer-gate-2026-09-02.md`.

- [ ] 5.8 <!-- TDD --> Implement the approved B2 lifetime boundary: `as_sema_lifetime.h/.cpp` authors exact lifetime/action/activation/region/construction facts into a versioned snapshot-owned protocol; shared `as_ast_lifetime.h/.cpp` derives and verifies committed-live sets and reverse cleanup edges; final publication authenticates the protocol before Bytecode/AOT consume it. Preserve current rejection boundaries, VM exception behavior, destructor order, no-cleanup-after-dead-value, no HIR/dump transport, and backend-local cleanup state.

  Current reason this remains open: section 15 has landed the versioned shared
  protocol, publication proof, success-sensitive local activation, committed
  construction prefixes, derived view and authenticated Bytecode/TypedASTJIT
  boundaries. This umbrella now waits on the complete 5.7 source lifetime
  matrix and matching production dispositions for the still-open temporary,
  returned ownership, deferred/reference/global, exception/abort and suspend
  families. CTA-S183 adds one exact Bytecode full-expression consumer but does
  not close those families or provide a native TypedASTJIT object-frame ABI.

  Decision 2026-08-28: do not persist an expanded cleanup list for every CFG
  edge and do not move semantic cleanup selection into CodeGen. Store minimal
  exact semantic facts in the sealed protocol, derive edge liveness once in a
  transient shared view, and keep physical cleanup/EH state backend-local.
  Existing `scope-exit`/`scope-release` statements are migration inputs whose
  exact equivalence is verified, not the long-term protocol. Sidecar V6 is
  retained unless a focused RED proves an irreducible fact requires a schema
  revision. Evidence:
  `reviews/canonical-ast-vs-clang-lifetime-review-2026-08-28.md`.

  Progress 2026-08-27: `TArray<int>` construction now uses an exact concrete
  constructor declaration rather than a bare template-owner alias, so the
  existing materialization/cleanup plan can be verified and detached. This is
  one constructor/lifetime input repair; it is not the general reverse/live-
  only cleanup plan required by 5.8.

  Progress 2026-08-28 (CTA-S44): normal lexical cleanup and block-exiting
  transfer cleanup are now explicit sealed `Cleanup(scope-exit,
  DeclRef(local))` statements. CodeGen consumes the plan and retires only the
  normal-path live object so the epilogue cannot double-destroy it. Prepared
  artifacts also publish Sema-generated destructor shells atomically. The
  complete exceptional/deferred/global/suspend live-value model remains open;
  5.8 is not checked. Evidence:
  `attachments/canonical-lexical-value-cleanup-plan-gate-2026-08-28.md`.

  Progress 2026-08-28 (CTA-S48): Sema now seals a primitive property-out
  call-edge plan with exact out type, exact setter and an opaque receiver.
  Canonical CodeGen captures the receiver once, calls through a temporary,
  preserves the primary return register and performs the sealed write-back in
  reverse-formal order. This is the first deferred lifetime family, not the
  complete materialization/cleanup model required by 5.8. Evidence:
  `attachments/canonical-deferred-property-out-writeback-gate-2026-08-28.md`.

- [ ] 5.9 <!-- TDD --> Add canonical coverage for containers/templates, delegates, lambdas/closures, funcdefs, imports, mutable/constant globals, generated accessors/defaults/lifecycle/list factories, suspend/safe-point metadata, and all active SDK language fixtures. Valid Bytecode forms must never require an executable `Unsupported` AST node at final cutover.

  Why this is still open: SDK language prefixes pass because the legacy compiler still accepts those fixtures. The AST does not represent them exactly. Isolated CodeGen does not cover that surface. Marking 5.9 done was a prerequisite fiction for “cutover the default” in section 10.

  Progress 2026-08-24: a host-registered `funcdef int Callback(int)` passed as
  a script argument and invoked indirectly now has a permanent AST-first test
  plus production execution returning **42**. This does not cover script
  funcdef declarations, stored/capturing closures, delegates, funcdef returns,
  cache replay, or the other forms listed by the task.

  Progress 2026-08-24: the one-value and keyed source `foreach` forms now have
  AST-first resolved-protocol gates and production Canonical CodeGen execution.
  Parser/Sema retain both value/key declarations, seal exact `opForKey`, and
  rebind both body placeholders within their authored range. This adds active
  language forms without an executable `Unsupported` node, but does not cover
  object iterator lifetimes, arbitrary containers, or the rest of the full SDK
  surface. SemaAuthority is **274/274** and ProductionCodeGen is **82/82**. Evidence:
  `attachments/canonical-foreach-protocol-gate-2026-08-24.md`.

  Progress 2026-08-27: the active language matrix now contains a permanent
  real-UE `TArray<int>` local default-construction gate, rather than relying on
  an array-parameter fallback fixture. The owning ScriptCorpus is **5/5** and
  TypedASTJIT **71/71**. Other containers/templates, list factories, generated
  lifecycle and the full SDK surface remain open.

  Progress 2026-08-31: native same-arity/zero-arg factory selection, list-factory
  `{41}`/`{41.25}` Marker payload, aggregate committed-prefix execute, and
  lexical owning-handle sealed release now have AST-first cards and execute
  through Canonical CodeGen. Named ProductionCodeGen is **196/196**
  (`cta-ast-first-codegen` `20260831_210231_401_c5b5ef43`) and SemaAuthority
  remains **474/474**. This is not the full SDK surface, suspend/exception
  tables, or stored capturing closures, so 5.9 stays `[ ]`. Evidence:
  `attachments/canonical-native-factory-selection-gate-2026-08-31.md`,
  `attachments/canonical-list-factory-marker-payload-gate-2026-08-31.md`,
  `attachments/canonical-lexical-owning-handle-release-gate-2026-08-31.md`.
- [x] 5.10 <!-- Non-TDD --> Run `Tools\RunBuild.ps1 -Label canonical-ast-body-sema -TimeoutMs 1800000 -NoXGE`, Compiler, Language, Runtime, Module, TypeSystem, Embedding, and Conformance SDK prefixes through `Tools\RunTests.ps1`; store only summarized results in a change attachment.

## 6. Cache V2 default-off containment and deferred redesign

Scope revised 2026-08-24: items 6.1-6.8 retain historical prototype work and
evidence. Checked 6.3/6.6 now record an explicit deferral decision, not a claim
that the old full cross-Engine/incremental wording was implemented. Product
acceptance for this change is 6.9-6.12: Cache V2 is off by default, disabled
means absent from the compiler lifecycle, and focused prototypes opt in.

- [x] 6.1 <!-- TDD --> Add `AngelscriptTest/Cache/AngelscriptCacheASTBodySidecarTests.cpp` with failing byte-exact cases for record kind/version, FunctionBody optional link, canonical absence coordinate, FunctionKey/profile/owner mismatch, empty-payload-not-absence, bounded counts/sizes/depth, unknown node/type kind, and no pointer/numeric-ID durability.
- [x] 6.2 <!-- TDD --> Extend `AngelscriptRuntime/Cache/AngelscriptCacheTypes.h` with the final `ASTBodySidecar` record kind replacing the unimplemented `TypedHIRSidecar` plan. Add versioned pointer-free DTO types in `AngelscriptCacheASTBodySidecar.h/.cpp`; do not alter FunctionBody VM bytes or `SaveByteCode`.
- [x] 6.3 <!-- Non-TDD --> Preserve the implemented canonical AST encode/decode and ExactStartup prototype, but explicitly defer complete target-Engine remap, import replay, invocation-family parity, and production readiness to a later Cache V2 redesign. Do not make this work a canonical compiler cutover gate.

  Current verified boundary (corrected 2026-08-23): the previous reason
  described an obsolete V1 placeholder. `asCASTEncodeSidecar`/decode now
  round-trip source records, interned type identity, complete Decl/Stmt/Expr
  arrays, body/child/reference edges, ranges, stable keys, traits, captures,
  initializers, literals and safe-point fields. Decode builds a fresh Context,
  rejects bad IDs and trailing bytes, then seals it; the UE wrapper validates
  and preserves that exact DTO rather than replacing it with an empty
  TranslationUnit. Cache V2 capture emits one shared sidecar for a retained
  module and ExactStartup decodes it on a private staging module. The focused
  DTO gate is 12/12 and the exact-start gate is 15/15; see
  `attachments/cache-v2-canonical-ast-gate-2026-08-23.md`.

  The target-Engine **type** and first source-owned **declaration** parts of
  that contract are now enforced after Cache V2 materializes private staging
  type/function skeletons, but before it assigns `ModuleDesc->ScriptModule`.
  `asCRuntimeTypeBridge::ValidateContextTypes` resolves every named AST type.
  `ValidateContextDeclarations` first requires **every** decoded declaration
  (including a non-body enum/namespace-style declaration) to rebuild the
  canonical stable key implied by its restored graph. It then requires every
  body-owning function/method/constructor/destructor/mixin declaration to bind
  exactly once to a current staging `asFUNC_SCRIPT` skeleton with matching
  owner/namespace, name, return type, parameters, passing flags, and constness.
  Either mismatch rejects the whole restore and discards staging. Full AST
  import replay is outside the currently admitted complete-module clean-capture
  shape, and a verified CodeGen/typed-native consumer remains open. Do not
  reopen the already fixed source/body DTO work or claim that an empty graph is
  restored.

  Progress 2026-08-23: `RetainedCanonicalAstReencodesByteExactSidecarWithoutFrontendWork`
  now gets the actual linked `ASTBodySidecar` payload from an opened Cache V2
  generation, restores it in a new Engine, then re-encodes the public retained
  sealed context under the same owner/profile. The two pointer-free payloads
  are byte-for-byte identical, while all frontend/publication counters remain
  zero. This proves exact DTO fidelity across source/type/declaration/body
  graph restoration. The subsequent type and declaration red/green slices
  establish target-Engine named-type validation and source-owned skeleton
  binding without parser/Sema/Bytecode work:
  `RetainedPolicyRejectsUnremappableAstTypeBeforeEngineActivation` and
  `RetainedPolicyRejectsUnremappableAstDeclarationBeforeEngineActivation`.
  The latter mutates the sidecar declaration name `Answer` to `Xnswer` and its
  derived stable key `Answer()` to `Xnswer()` at equal byte length, leaving the
  AST key self-consistent while Cache graph/VM declaration validity stays
  intact. The independent non-skeleton gate
  `RetainedPolicyRejectsDetachedEnumDeclarationIdentityBeforeEngineActivation`
  mutates `EExactWarmState` to same-length `XExactWarmState`; it was red before
  generic declaration-key reconstruction and now rejects before module
  activation. The full ExactWarmStartup lifecycle group is **15/15 PASS**.
  Full AST import replay and a later CodeGen/native consumer are still absent,
  so 6.3 stays open.

  Progress 2026-08-24: the maintained DTO is schema V3. Runtime wrapper schema
  2 was rejecting every valid current sidecar, and the ExactWarm adversarial
  declaration cursors skipped the V3 layout fields but not the final 64-bit
  constant payload. Runtime/header/layout alignment plus the repaired V3
  corruption fixtures are now covered by FunctionBody **5/5**, ASTBodySidecar
  **12/12**, and ExactWarmStartup **15/15**. The latter proves the declaration
  and verifier-invalid mutations actually reach private restore validation
  before activation. See
  `attachments/cache-v2-sidecar-schema-v3-alignment-2026-08-24.md`. Import
  replay, incremental closure, and downstream backend consumption remain open.

- [x] 6.4 <!-- TDD --> Add ExactStartup tests proving retain-policy restore performs zero preprocess/parse/Sema/Bytecode CodeGen, publishes one complete verified module AST, and fails before mutation for missing/corrupt/wrong-profile/unremappable/verifier-invalid fragments.

  Current verified boundary (corrected 2026-08-23): retained ExactStartup
  already requires every FunctionBody to point at the same module AST sidecar,
  decodes the sidecar into a private `asCASTContext`, seals it, attaches it to
  the staging module, and publishes it before the single module-set swap. The
  warm-start gate checks zero preprocess/parse/module-compiler/function-
  compiler/publication counters and traverses the restored function body,
  return statement, and literal through AST V1. It also checks changed raw
  source and transient projection mismatches are misses before activation.

  The missing-sidecar whole-restore case is now closed:
  `RetainedPolicyRejectsMissingAstSidecarBeforeEngineMutation` produces a valid
  discard-policy VM generation with zero `ASTBodySidecar` records, then asks a
  retain-policy consumer to restore it. ExactStartup rejects it before target
  module activation, while every frontend/publication counter remains zero.
  The trailing-byte whole-restore case is now also closed:
  `RetainedPolicyRejectsTrailingAstSidecarBeforeEngineMutation` rewrites the
  Cache V2 record graph so all linked record IDs/hashes remain valid, but the
  AST DTO has one forbidden trailing byte. This deliberately reaches strict
  `asCASTDecodeSidecar` during ExactStartup and rejects before activation with
  the same zero-work assertion. The owner/profile whole-restore case is also
  closed: `RetainedPolicyRejectsAstSidecarProfileMismatchBeforeEngineMutation`
  changes one profile-hash nibble in the self-describing sidecar header while
  keeping the Cache V2 graph self-consistent; ExactStartup rejects it at the
  owner/profile guard before activation with the same zero-work assertion. It
  also closes the corrupt-body case:
  `RetainedPolicyRejectsTruncatedAstSidecarBeforeEngineMutation` removes the
  final AST DTO byte after repairing Cache V2 record links/hashes, so strict
  decode—not generic graph admission—rejects it before activation with the
  same zero-work assertion. The unremappable target-type case is now also
  closed: `RetainedPolicyRejectsUnremappableAstTypeBeforeEngineActivation`
  changes only the type-table stable key `EExactWarmState` to the same-length
  nonexistent key, then repairs the Cache V2 record graph. ExactStartup first
  materializes its private skeletons, rejects the unresolved AST type before
  `ModuleDesc` assignment or module activation, and observes the same
  zero-work invariant. The declaration-key whole-restore case is now also
  closed: `RetainedPolicyRejectsUnremappableAstDeclarationBeforeEngineActivation`
  changes the body-owning `Answer` declaration name and matching `Answer()`
  stable key to same-length `Xnswer` / `Xnswer()`, then repairs Cache V2 graph
  links/hashes. ExactStartup rejects it after private skeleton materialization
  but before `ModuleDesc` assignment and activation, with the same zero-work
  invariant. The verifier-invalid whole-restore case is also
  closed: `RetainedPolicyRejectsVerifierInvalidAstGraphBeforeEngineActivation`
  rewrites only an in-bounds `decl.body` / `stmt.owner` agreement to a
  different valid declaration. Cache V2 graph admission remains valid, but
  the strict decoder's final `context.Seal()` verification rejects before
  staging attachment or activation, again with the zero-work invariant. The
  full ExactWarmStartup gate is **15/15 PASS**. This completes 6.4; the direct
  DTO tests remain complementary coverage rather than the lifecycle proof.
- [x] 6.5 <!-- TDD --> Add discard-policy restore tests proving valid VM state loads while sidecars are ignored, public snapshot remains unavailable, and sidecar presence cannot alter execution or FunctionBody payload identity.
- [x] 6.6 <!-- Non-TDD --> Defer the unfinished function-granular incremental FunctionBody/ASTBodySidecar identity and invalidation contract to the later Cache V2 redesign; preserve the current module-shared sidecar prototype and its tests without claiming this behavior.

  Current boundary corrected 2026-08-24: a real pointer-free V3 AST DTO now
  exists and ExactWarm restores it, so the obsolete "DTO does not exist"
  rationale no longer applies. The remaining gap is the incremental identity
  contract itself: capture currently links FunctionBodies to one module-shared
  AST sidecar. A focused matrix must prove which source/body/type/decl/global/
  import edits reuse or replace each record, reconcile that shared shape with
  this task's per-function wording, and prove failed candidate activation keeps
  the prior FunctionBody, AST snapshot, and module generation atomically.
- [x] 6.7 <!-- TDD --> Add Cache V2 + Hot Reload tests for sidecar replacement, old snapshot leases, content hashes, generation publication, source authority, old schema safe miss, and no `.hir.txt/.hir.json`/AST dump input path.
- [x] 6.8 <!-- Non-TDD --> Run `Tools\RunBuild.ps1 -Label canonical-ast-cache-v2 -TimeoutMs 1800000 -NoXGE` and `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache" -Label canonical-ast-cache-v2 -TimeoutMs 600000`.
- [x] 6.9 <!-- TDD --> Change the product Cache V2 default to disabled and add a focused default-settings red/green test.
- [x] 6.10 <!-- TDD --> Make disabled Cache V2 a real lifecycle bypass: no ExactStartup, initial/Hot Reload capture, function-reuse publication, or shutdown persistence. Prove a default-disabled Engine still compiles authoritative `.as` source and publishes a usable module/function with no Cache publications/files.
- [x] 6.11 <!-- Non-TDD --> Add explicit per-Engine opt-in for focused Cache V2 tests and update production-lifecycle Cache fixtures to request it rather than relying on a global enabled default.
- [x] 6.12 <!-- Non-TDD --> Retain the unfinished cross-Engine invocation-family parity test as Disabled `#cache-v2-redesign`, preserve its test body and failure evidence, and record the redesign boundary in proposal/design/spec/attachment.

## 7. TypedASTJIT migration to canonical AST

- [x] 7.1 <!-- TDD --> Add canonical AST adapters to existing TypedASTJIT test support and failing tests proving analysis/emission receives sealed AST, never calls `GetByteCode()` for body meaning, never reconstructs HIR, and leaves AST dumps unchanged.
- [ ] 7.2 <!-- TDD --> Complete TypedASTJIT eligibility and dependency analysis directly over Frozen/Publishable Canonical Decl/Type/Stmt/Expr plus validated Runtime bindings while preserving root/closure validation, receiver/call shape, source provenance, semantic dependencies, observability/control, exception, lifetime, recursion, and typed fallback categories. HIR is already absent and must not be recreated as an adapter.

  Why this is still open: visitor files exist and HIR is physically gone, but
  binding a Runtime function to AST still takes the first function/method
  declaration with the same name (`AngelscriptStaticJITGenerationSnapshot.cpp`).
  Overloads, operators, constructors and lambdas can attach the wrong body while
  keeping B's FunctionKey. The remaining blocker is complete declaration/call/
  dependency/lifetime coverage from exact Canonical identity, not HIR migration.

  Progress correction 2026-08-24: Task 13.3 has since removed the name-first
  production binding described above by carrying and structurally validating
  the exact producer declaration key, including lambdas. HIR implementation
  and compatibility branches were physically removed under 10.5/7.8. The
  remaining 7.2 blockers are incomplete Canonical call/dependency/lifetime
  facts and eligibility coverage, not an input migration. Existing green
  groups do not prove the complete language closure. See
  `attachments/typed-semantic-hir-physical-retirement-gate-2026-08-27.md` and
  section 15.

  Audit 2026-08-30: VerifiedCanonicalAST capture, V1 snapshot lease ownership,
  exact producer declaration binding, direct Decl/Stmt/Expr traversal,
  same-Context exact script-call DeclId closure/SCC and authenticated
  pointer-free lifetime summaries are present. The highest-priority open
  safety defect is receiver omission: eligibility skips the receiver edge,
  call collection visits only ordinary children, and emission evaluates only
  reverse-formal children. Until exact receiver provenance/evaluation/ABI
  lowering lands, receiver-bearing calls require explicit per-function
  `UnsupportedReceiver` fallback. Native target/global reconciliation and some
  Runtime type projections also remain hybrid. Details:
  `attachments/cta-s73-s75-snapshot-builder-authority-cache-lifetime-and-typedjit-audit-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S76/S77): receiver omission is now closed as a
  safety defect. Any Canonical call with a dedicated receiver selects exact
  per-function `UnsupportedReceiver` fallback before typed closure; an
  adversarial receiver-only nested call proves dependencies cannot be silently
  lost. The full current TypedASTJIT prefix is **54/54 PASS**, and the combined
  Frontend+Compiler CanonicalAST matrix is **817/817 PASS** (**182+635**).
  CTA-S77 also
  aligns authored script inheritance and PreClass native shadowing as separate
  sealed relations across Sema, verifier, Runtime type registration and
  prepared CodeGen. Complete receiver lowering, immutable native-target
  binding, exception/suspend facts and remaining dependency families keep 7.2
  open. Evidence:
  `attachments/cta-s76-s77-typedjit-receiver-and-preclass-dual-relation-gates-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S79): the expression-Sema type-to-owner association
  used by property/member/operator/conversion families now requires complete
  stable-key equality and cannot attach a typed receiver to a namespaced
  same-name declaration. The combined Compiler/TypedASTJIT gate is
  **693/693 PASS**. This removes one hybrid type-projection heuristic; native
  target binding, receiver lowering, exception/suspend and the remaining
  dependency families still keep 7.2 open. Evidence:
  `attachments/cta-s79-exact-expression-type-owner-gate-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S80): TypedASTJIT native-call closure now consumes
  reviewed descriptor suspend/exception capabilities before choosing an
  emission disposition. `MaySuspend` selects exact per-function
  `SuspendOrExceptionState`; direct-callable + `MaySetScriptException` selects
  `ExceptionPayloadUnavailable`; VM scalar bridge + MaySet remains eligible
  because nested context exception adoption is already implemented. The two
  adversarial gates went **0/2 RED -> 2/2 GREEN**, the complete generation
  Engine class is **34/34 PASS**, and Compiler CanonicalAST + TypedASTJIT is
  **693/693 PASS** (**639+54**). Native target identity, complete call families,
  and remaining exception/dependency facts keep 7.2 open. Current
  `bHasSuspendState=false` is the truthful language-level result; native
  `MaySuspend` is a separate call-edge capability. Evidence:
  `attachments/cta-s80-typedjit-native-exception-suspend-fallback-gate-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S81): bound-call infrastructure failures now retain
  a structured direct first-failure payload, while an already-adopted nested
  VM exception keeps first-failure authority. Successful direct/CurrentNative
  closures report `DirectFailureRecord`; any emitted VM bridge reports
  `DirectFailureRecordAndNestedBridgeAdoption`. Exact behavior/serialization is
  **3/3 PASS**, NativeBridge is **10/10 PASS**, and ProjectGeneration Engine
  plus AOT Diagnostics Generation is **38/38 PASS**. The combined Compiler
  CanonicalAST, TypedASTJIT and NativeBridge regression is **703/703 PASS**
  with zero failures/skips. Immutable native target
  identity and the remaining call/dependency families keep 7.2 open. Evidence:
  `attachments/cta-s81-typedjit-exception-payload-aggregate-gate-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S82): the resolved Canonical native-call target now
  keeps one producer-carried exact stable relation through Sema, the current
  Runtime system function, the frozen generation snapshot and TypedASTJIT
  closure. Runtime binding authenticates owner/namespace/return/parameter/
  passing/const structure; closure indexes only `CanonicalTargetDeclKey` and
  no longer compares `origin` with `GetDeclaration()`. Diagnostic spelling can
  change without affecting identity, while wrong, missing, duplicate or
  ambiguous keys fail closed. Exact relation gates are **3/3 PASS**, the
  complete ProjectGeneration Engine class is **37/37 PASS**, and Compiler
  CanonicalAST + TypedASTJIT + NativeBridge is **703/703 PASS** with zero
  failures/skips. Complete receiver lowering and the remaining call/dependency
  families keep 7.2 open. Evidence:
  `attachments/cta-s82-exact-native-target-relation-gate-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S83): folded/global semantic dependencies now
  retain one exact producer-carried Canonical global declaration key from the
  sealed `VarDecl`, through the current Runtime property, generation global,
  semantic dependency and backend graph, into TypedASTJIT. The consumer no
  longer reconstructs identity from live Runtime namespace/name; diagnostic
  name mutation remains eligible, while wrong, missing and duplicate keys
  select per-function `SemanticDependencyMismatch` with no emission. The
  exact matrix is **1/1 PASS**, generation Engine is **37/37 PASS**, and broad
  Compiler CanonicalAST + TypedASTJIT + NativeBridge is **703/703 PASS**.
  Direct `callArguments.formalIndex` consumption, root formal-ordinal identity
  and remaining mutable-global/import/call families keep 7.2 open. Evidence:
  `attachments/cta-s83-exact-global-dependency-relation-gate-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S84): TypedASTJIT direct-call emission now consumes
  the verifier-authenticated `Expr.callArguments` relation instead of deriving
  formal placement from reverse child position. Stored child/record order still
  determines evaluation order; sealed `formalIndex` determines invocation slot
  and sealed `formalType` determines its reviewed C++ ABI spelling. A
  verifier-valid two-`int` graph whose relation differs from positional
  reconstruction went **0/1 RED -> 1/1 GREEN**. The complete adapter class is
  **26/26 PASS**, and Compiler CanonicalAST + TypedASTJIT + NativeBridge is
  **704/704 PASS** with zero failures/skips. Root-entry formal ordinal identity
  and the remaining receiver/import/mutable-global/call families keep 7.2 open.
  Evidence:
  `attachments/cta-s84-direct-call-argument-relation-consumption-gate-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S85): every Canonical `ParamDecl` now publishes a
  sealed zero-based `formalIndex`; verifier, stable signatures, Runtime shape
  authentication, public snapshot view, Sidecar V10 and TypedASTJIT root
  emission consume the exact relation instead of associating the nth parameter
  child with Runtime slot N. A same-typed reordered-child fixture went **0/1
  RED -> GREEN** inside the complete adapter **27/27 PASS** gate. Verifier is
  **53/53**, Sidecar V10 **24/24**, Snapshot **12/12**, and the broad Compiler
  CanonicalAST + TypedASTJIT + NativeBridge matrix is **705/705 PASS** with zero
  failures/skips. Remaining call/language/provider families keep 7.2 open.
  Evidence:
  `attachments/cta-s85-sealed-formal-ordinal-relation-gate-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S86): Canonical Bytecode/VM now consumes the sealed
  formal relation for registered/prepared/import/current-module callable
  lookup, method/constructor/list-factory matching, generated setter binding,
  callee-entry Runtime stack slots, Runtime signature publication and detached
  imports. The same-typed reordered-child VM fixture went **0/1 RED -> 1/1
  GREEN** and returns 42 instead of the old silent 24. ProductionCodeGen is
  **137/137**, CodeGen transaction/rollback **21/21**, and Compiler CanonicalAST
  + TypedASTJIT + NativeBridge **706/706 PASS**. The read-only production Sema
  audit at that checkpoint found call-plan/method-relation/lambda/constructor/
  native-projection child-order consumers; the following CTA-S87 paragraph
  records their closure. Other language/provider families still keep 7.2 open.
  Evidence:
  `attachments/cta-s86-bytecode-formal-ordinal-consumption-gate-2026-08-30.md`,
  `reviews/formal-ordinal-production-consumer-audit-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S87): the reviewed production Sema consumers now
  preserve structural child order while resolving formal slots only through
  exact `ParamDecl.formalIndex`. This covers common named/default/direct/method/
  mixin/import/lambda/funcdef call planning, generated call records, override
  and interface matching, lambda contextualization, constructor selection and
  conversion, native/external/global/method/behavior projection, mixin receiver
  origin, singleton setter/deferred-out hardening, operator conversion and
  unresolved-call diagnostics. Seven adversarial reordered-child fixtures are
  green; the final grouped projection/origin gate is **6/6 PASS**,
  ProductionCodeGen is **137/137**, CodeGen transaction/rollback **21/21**, and
  Compiler CanonicalAST + TypedASTJIT + NativeBridge **713/713 PASS** with zero
  failures/skips. The residual audit found no remaining high-risk nth-PARAM-
  child production consumer in the reviewed Sema files. Complete unsupported
  language/provider/lifetime families still keep 7.2 open. Evidence:
  `attachments/cta-s87-production-sema-formal-ordinal-consumption-gate-2026-08-30.md`,
  `reviews/formal-ordinal-production-consumer-audit-2026-08-30.md`.
- [x] 7.3 <!-- TDD --> Port scalar/enum literal, conversion, arithmetic, comparison, bitwise/logical, assignment/mutation, branch/loop/switch/return, and safe-point C++ emission to canonical AST. Require generated-output determinism and existing VM/Raw/Parms entry plans.
- [ ] 7.4 <!-- TDD --> Complete resolved script/native/import/mixin/property call closure, argument provenance/order, native ABI, bridge/direct/fallback disposition, stable call dependencies, and cross-TU restrictions from Canonical declaration/call nodes and immutable Runtime binding snapshots; do not reconstruct retired HIR call records.

  Why this is still open: call nodes do not carry complete resolved provenance
  (see 5.3). TypedASTJIT must therefore fall back for missing plans. Existing
  supported fixtures that emit prove only their covered Canonical subset; they
  do not prove complete call plans. HIR is absent and is not an allowed source.

  Audit 2026-08-30: receiver subgraphs are not currently included in typed
  eligibility, closure/dependency discovery or emission, and native targets
  still reconcile through declaration/owner strings rather than a verifier-
  authenticated immutable binding relation. Production script-callee scalar
  bridging is also disabled, so unsupported callees fall back at whole-root
  granularity. The next safe TDD gate is receiver-bearing-call fallback, not
  partial receiver lowering. Details:
  `attachments/cta-s73-s75-snapshot-builder-authority-cache-lifetime-and-typedjit-audit-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S76): the recommended safe gate is implemented.
  Receiver-bearing calls can no longer enter typed closure without receiver
  provenance/evaluation/ABI support; they fall back as `UnsupportedReceiver`.
  This closes silent receiver loss, not the complete 7.4 native/import/mixin/
  property/cross-TU call matrix. Evidence:
  `attachments/cta-s76-s77-typedjit-receiver-and-preclass-dual-relation-gates-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S80): native disposition selection now fails closed
  with typed reasons before an unsupported suspend or direct exception route
  can become an emission plan. Existing VM bridge emission remains green in
  the complete **34/34** generation Engine class. This closes the reviewed
  direct exception/suspend route gap, not immutable native target binding or
  the complete import/mixin/property/receiver/cross-TU call matrix, so 7.4
  remains open. Evidence:
  `attachments/cta-s80-typedjit-native-exception-suspend-fallback-gate-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S81): emitted call-site routes now drive one truthful
  closure aggregate instead of the old unconditional direct-only stamp. A
  bridge-containing closure keeps both the mandatory Provider-root direct
  record and nested VM adoption. This closes exception-route diagnostic
  reconstruction, not the declaration-string native target reconciliation or
  the complete import/mixin/property/receiver/cross-TU matrix, so 7.4 remains
  open. Evidence:
  `attachments/cta-s81-typedjit-exception-payload-aggregate-gate-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S82): immutable native target binding is now exact
  and pointer-free. Canonical Sema publishes the selected system function's
  declaration key, the Runtime bridge structurally authenticates it, the
  generation snapshot freezes it and closure resolves only the call target's
  stable key. `CanonicalDeclaration` is diagnostic-only and Engine-local
  FunctionId remains an execution coordinate after relation selection. Wrong,
  missing, duplicate and ambiguous keys cannot fall back to spelling. This
  closes the reviewed native declaration-string reconciliation, not the full
  import/mixin/property/constructor/delegate/receiver/cross-TU matrix, so 7.4
  remains open. Exact **3/3**, generation Engine **37/37** and broad
  **703/703** gates pass. Evidence:
  `attachments/cta-s82-exact-native-target-relation-gate-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S83): the folded-global dependency relation is now
  exact and pointer-free. Sema/Canonical CodeGen publishes the global Decl key,
  the Runtime bridge authenticates module/TU/namespace/name/type structure,
  generation freezes the same key and TypedASTJIT selects only exact key
  equality. Engine-local property ID remains a current-generation execution
  coordinate; stable artifact reference, ABI and content/value hashes remain
  independent dependency coordinates. Wrong, missing and duplicate keys fail
  closed as `SemanticDependencyMismatch`; live Runtime spelling cannot redirect
  the relation. This closes the reviewed global name reconstruction, not
  direct structured argument consumption or the full import/mixin/property/
  constructor/delegate/receiver/mutable-global/cross-TU matrix, so 7.4 remains
  open. Generation Engine **37/37** and broad **703/703** pass. Evidence:
  `attachments/cta-s83-exact-global-dependency-relation-gate-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S84): the current supported direct-call profile no
  longer reconstructs formal argument placement. It requires sealed `DIRECT`
  dispatch, one authenticated relation per stored argument, exact
  same-index expression ownership, unique in-range `formalIndex`, reviewed
  `formalType`, and complete formal-slot population before invocation. The
  emitter preserves stored evaluation order while placing temporaries by the
  sealed formal relation; malformed relations fail closed. Exact reordered
  same-type **1/1**, adapter **26/26**, and broad **704/704** gates pass. This
  closes the reviewed direct argument-placement defect, not root-entry ordinal
  binding or the complete import/mixin/property/constructor/delegate/receiver/
  indirect/cross-TU matrix, so 7.4 remains open. Evidence:
  `attachments/cta-s84-direct-call-argument-relation-consumption-gate-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S85): callee-entry parameter identity is now the
  verifier-authenticated `ParamDecl.formalIndex`, persisted by Sidecar V10 and
  exposed through the append-only public view. TypedASTJIT root wrappers resolve
  exact formals by slot and verify Canonical/Runtime ABI spelling; declaration-
  child order is no longer argument identity. The adversarial same-type gate is
  green within adapter **27/27**, with verifier **53/53**, Sidecar **24/24**,
  Snapshot **12/12** and broad **705/705** regressions. This closes root-entry
  ordinal binding, not the complete import/mixin/property/constructor/delegate/
  receiver/indirect/cross-TU matrix, so 7.4 remains open. Evidence:
  `attachments/cta-s85-sealed-formal-ordinal-relation-gate-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S86): Bytecode CodeGen no longer reconstructs
  positional parameter identity from declaration children. Exact formal slots
  drive Runtime lookup, signature arrays, import shells and VM callee-entry
  binding, while sealed call-record storage order remains the evaluation order.
  The focused relation is **1/1**, ProductionCodeGen **137/137**, transaction
  **21/21**, and the broad matrix **706/706 PASS**. This closes the reviewed
  Bytecode half of formal ordinal consumption. The audit at that checkpoint
  found several production Sema call, override/interface, lambda/funcdef,
  constructor and native-projection views built from nth PARAM children; the
  following CTA-S87 paragraph records their closure. The broader call-family
  matrix still keeps 7.4 open. Evidence:
  `attachments/cta-s86-bytecode-formal-ordinal-consumption-gate-2026-08-30.md`,
  `reviews/formal-ordinal-production-consumer-audit-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S87): production Sema no longer reconstructs
  callable parameter identity from declaration child position. Exact formals
  now drive common call planning and call records, override/interface and
  lambda/funcdef relations, constructor/operator conversions, native/external
  projection and exact mixin receiver origin; declaration and call storage
  order are unchanged. The final grouped relation gate is **6/6 PASS**,
  ProductionCodeGen **137/137**, transaction/rollback **21/21**, and the broad
  Compiler CanonicalAST + TypedASTJIT + NativeBridge matrix **713/713 PASS**.
  This closes the reviewed Sema half of formal-ordinal consumption after
  CTA-S86 closed Bytecode/VM. It does not prove the complete import/mixin/
  property/constructor/delegate/receiver/indirect/mutable-global/cross-TU
  matrix, so 7.4 remains open. Evidence:
  `attachments/cta-s87-production-sema-formal-ordinal-consumption-gate-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S98): derived funcdef reuse now authenticates both
  normalized Runtime ABI and the complete producer-carried source-formal
  qualifier vector. A Canonical by-value value object cannot reuse an
  empty-metadata host funcdef or an explicit `const T&inout` derived funcdef
  merely because those forms normalize to the same Runtime shell. Explicit
  lambda viability, omitted lambda inference and indirect funcdef call plans
  consume the same function-aware source relation. The valid semantic gate is
  **0/1 RED -> 1/1 PASS**, SemaAuthority **458/458** and complete native SDK
  Compiler **798/798**. Cache is **585/585**, TypedASTJIT **56/56**, native SDK
  Module **65/65**, and the final Compiler CanonicalAST + ProjectGeneration
  Engine + TypedASTJIT + NativeBridge matrix is **780/780 PASS**. This closes
  the reachable derived-funcdef relation,
  not the complete import/mixin/property/constructor/delegate/receiver/
  mutable-global/cross-TU matrix, so 7.4 remains open. Evidence:
  `attachments/cta-s98-derived-funcdef-source-formal-relation-gate-2026-08-30.md`.

- [ ] 7.5 <!-- TDD --> Make TypedASTJIT/AOT consume the verifier-authenticated Canonical lifetime protocol/shared derived view for cleanup, transfer, partial-construction and reviewed exception facts; preserve native frame budget, call-site fallback, mutable/global/import eligibility and provider dependency publication without retaining AST/protocol pointers. Remove AOT destructor-name scans, type-kind lifetime reclassification, `DeclStmt` activation and positional/string cleanup interpretation. Unsupported native object-frame/exception/suspend facts remain typed per-function fallback.

  Current open boundary: generation now owns the required snapshot lease and
  Provider diagnostics remain pointer-free. CTA-S49 proves and publishes
  `VerifiedEmpty` directly from the same exact sealed Canonical function body
  used by TypedASTJIT eligibility/emission. CTA-S50 now classifies exact
  `scope-release` as `NonEmpty` and exact destructor cleanup as
  `ScriptDestructor`. CTA-S51 fixes Sema's declaration-before-transfer
  liveness bug and independently proves exact reverse live-only ordinary block
  plans from the sealed AST. CTA-S52 additionally proves the exact fourth
  value-object `foreach` iterator cleanup phase across normal exit, `return`,
  targeted `break`, and live-through `continue`, matching the Canonical
  Bytecode loop-frame route. Missing required actions now fail closed instead
  of masquerading as `VerifiedEmpty`; proven non-empty plans may publish
  complete transfer coverage without retaining AST pointers. Partial
  construction, exception/suspend state, other future special loop phases,
  native object-frame ABI, mutable globals/imports, call-site fallback and the
  remaining provider dependency families are still incomplete, so 7.5 stays
  open.
  Evidence:
  `attachments/canonical-aot-cleanup-facts-gate-2026-08-28.md` and
  `attachments/canonical-aot-nonempty-cleanup-facts-gate-2026-08-28.md` and
  `attachments/canonical-aot-reverse-live-only-cleanup-proof-2026-08-28.md` and
  `attachments/canonical-aot-foreach-lifetime-phase-proof-2026-08-28.md` and
  `attachments/cta-s73-s75-snapshot-builder-authority-cache-lifetime-and-typedjit-audit-2026-08-30.md`.

  Audit 2026-08-30: cleanup authoring/lifetime verification now requires exact
  complete destructor-owner stable-key equality; the same-name namespaced
  adversarial fixture and Frontend **182/182** + Compiler **634/634** pass.
  TypedASTJIT already consumes the authenticated lifetime view, but suspend and
  zero-cleanup exception-region facts still do not drive complete explicit
  fallback, so this umbrella remains open.

  Progress 2026-08-30 (CTA-S78): the earlier audit fixed verifier-side owner
  matching, but three Sema authors still accepted
  `owner.name == valueType.stableKey` after exact stable-key comparison failed.
  The lexical, aggregate-element and declaration lifetime producers now require
  complete owner stable-key equality. An adversarial unqualified `FValue`
  versus `Wrong::FValue` fixture and a four-source regression guard went
  **0/2 RED -> 2/2 GREEN**. Compiler CanonicalAST plus TypedASTJIT is
  **691/691 PASS** (**637+54**). This closes the lifetime-author name fallback,
  not the remaining exception/suspend/native-frame/global/import/provider
  families, so 7.5 remains open. Evidence:
  `attachments/cta-s78-exact-lifetime-author-owner-gate-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S80): unsupported native suspend and direct native
  exception-payload facts now use the required typed per-function fallback
  categories and cannot be emitted as an unsafe direct call. VM bridge
  exception adoption is preserved. Current `bHasSuspendState=false` is a
  truthful Canonical language fact, not a missing native-descriptor producer.
  The other language/runtime families still keep 7.5 open. Evidence:
  `attachments/cta-s80-typedjit-native-exception-suspend-fallback-gate-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S81): direct bridge-infrastructure failures now own
  structured first-failure records, nested VM exceptions remain adopted, and
  successful mixed closures serialize the combined payload mechanism. The
  exact **3/3**, NativeBridge **10/10**, Generation/AOT **38/38**, and combined
  Compiler/TypedASTJIT/NativeBridge **703/703** gates are green with zero
  failures/skips. Native object-frame cleanup, mutable global/import lifecycle and the
  remaining provider dependency families still keep 7.5 open. Evidence:
  `attachments/cta-s81-typedjit-exception-payload-aggregate-gate-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S83): the supported folded hard-value global route
  now consumes the exact verifier-sealed declaration relation plus independent
  current-property-id, artifact-reference, ABI and expected-value coordinates.
  TypedASTJIT no longer reconstructs that relation from Runtime spelling, and
  malformed graph relations select `SemanticDependencyMismatch` with no native
  emission. Mutable-global/import lifecycle routes, native object-frame cleanup
  and the remaining provider dependency families still keep 7.5 open.
  Evidence:
  `attachments/cta-s83-exact-global-dependency-relation-gate-2026-08-30.md`.
- [x] 7.6 <!-- TDD --> Add Hot Reload/generation lease tests: generation may complete consistently against leased generation A or fail freshness when B publishes; later provider selection uses stable key/content/profile/ABI and not AST addresses.
- [x] 7.7 <!-- TDD --> Run the complete existing TypedASTJIT/StaticJIT test prefix under canonical input and prove no current supported fixture regresses and no current fallback becomes an unsafe direct call.

  Fresh evidence 2026-08-23: forcing Typed generation to retain/publicly lease every module AST exposed a previously silent `continue-ancestor` publication failure in the control-flow fixture. The permanent AST-first test `ForMultipleIncrementExpressionsRetainsBodyAndContinueTargetOnCompileSealPath` reproduced the fault before JIT snapshot construction (`0/1`, `cta-for-multi-increment-ast-red`) and now proves that multiple `for` increment clauses form one ordered `SequenceExpr`, the real body remains the `For` body, and `continue.target` names its ancestor loop (`1/1`, `cta-for-multi-increment-ast-green`). The original `TypedASTJIT.BytecodeIsolation` symptom is `1/1 PASS`, and the complete `Angelscript.TestModule.StaticJIT.TypedASTJIT` prefix is **64/64 PASS** (`cta-typedast-full-after-for-fix`). This refreshes 7.7 compatibility evidence only; it does not close 7.2/7.4/7.5. HIR retirement was closed independently by 7.8/10.5.

  Current refresh 2026-08-30 (CTA-S77): the original BytecodeIsolation symptom
  plus the two existing PreClass Sema/prepared-CodeGen gates are **3/3 PASS**,
  the currently discoverable TypedASTJIT prefix is **54/54 PASS**, and the
  directly affected SemaAuthority prefix is **438/438 PASS**. The count is a
  current discovery snapshot and does not rewrite the earlier historical
  64-test run. Evidence:
  `attachments/cta-s76-s77-typedjit-receiver-and-preclass-dual-relation-gates-2026-08-30.md`.
- [x] 7.8 <!-- Non-TDD --> Keep TypedASTJIT production and test/build surfaces permanently free of function-owned HIR types, storage, builders, accessors, capture flags, dump transport and fallback branches. TypedASTJIT consumes Canonical snapshots or performs typed per-function fallback; it must never recreate HIR as an adapter. Run the supported build and StaticJIT/CanonicalAST migration gates.

  Closed 2026-08-27: function-owned HIR was physically retired across
  production, tests, dumps and build surfaces. Forbidden-symbol/source scans,
  Runtime/Editor builds and the recorded focused gates prove the permanent
  no-HIR boundary. Evidence:
  `attachments/typed-semantic-hir-physical-retirement-gate-2026-08-27.md`.
  Tasks 7.2, 7.4 and 7.5 remain open for complete Canonical call, dependency,
  lifetime and backend capability coverage; they are not HIR migration tasks.

## 8. Primary Generate, native-form catalog, and diagnostics absorption

- [x] 8.1 <!-- TDD --> Port the superseded change's native-form catalog tests into `AngelscriptTest/StaticJIT/AngelscriptNativeFormCatalogTests.cpp`: stable declaration/profile keying, repeated Engine replay, conflict rejection, HeaderInline/module-exported/bridge distinction, second-Engine lookup, and no pointer/lambda ownership.
- [x] 8.2 <!-- TDD --> Implement `FAngelscriptNativeFormCatalog` and populate it only after real bind registration through reviewed native-form attachment paths. Preserve per-Engine registration and existing BytecodeJIT compatibility forms until catalog parity passes.
- [x] 8.3 <!-- TDD --> Add `AngelscriptPrimaryEngineCanonicalASTGenerateTests.cpp` proving a current matching profile leases primary compiled graph/AST, constructs no `StaticJITGeneration` Engine, performs no source compile/reload, and fails `ASTSnapshotRequired` or `AuthoritativeEngineStale` without implicit sibling fallback.
- [x] 8.4 <!-- TDD --> Implement matching-profile Generate in `AngelscriptProjectSourceGraph` and generator orchestration with immutable inventory/module/AST leases, Hot Reload queue freeze, freshness gate, stable native-form catalog lookup, and owned-output-only writes.
- [x] 8.5 <!-- TDD --> Add containment tests for success and every early-fail stage covering `/Script/Angelscript` ownership, reflection/UClass/UFunction/CDO state, routes, registries, cache state, delegates, worlds, contexts, Hot Reload queue, and output ownership.
- [x] 8.6 <!-- TDD --> Add non-matching Editor/commandlet tests proving exactly one contained Engine per profile, complete bind/source/AST/descriptor graph, selected EmitModuleSet, sequential multi-profile execution, distinct artifact identity, and destruction without primary mutation.
- [x] 8.7 <!-- TDD --> Implement the shared sequential generation helper for non-matching profiles and commandlets; canonical AST retention is on only for typed generation, Bytecode-only generation may discard it, and no two extra Engines coexist.
- [x] 8.8 <!-- TDD --> Replace HIR-specific dump/selection diagnostics with canonical AST snapshot origin/version/generation/current/verification/eligibility/fallback diagnostics. Dump remains read-only and never a Provider or Cache input.
- [x] 8.9 <!-- Non-TDD --> Run `Tools\RunBuild.ps1 -Label canonical-ast-primary-generate -TimeoutMs 1800000 -NoXGE`, StaticJIT, HotReload, and Cache prefixes. Update `attachments/superseded-change-map.md` only if implementation evidence changes the absorbed mapping.

## 9. Canonical Bytecode CodeGen

Isolated `asCBytecodeCodeGen` is a subset prototype. CANONICAL `asCModule::Build()` now calls `Generate()`; LEGACY still uses `asCCompiler`. 9.2–9.4 mean “some isolated tests lower those shapes”, not full-language production CodeGen. 9.5 stays `[ ]`.

- [ ] 9.1 <!-- TDD --> Add `as_bytecode_codegen.h/.cpp` interface tests proving CodeGen accepts only Frozen/Publishable AST with a verifier-authenticated Canonical lifetime protocol/shared derived view, owns all VM-local state, never mutates nodes, and produces no partial function/module state on failure. The detached artifact SHALL carry stable type/property/function relocation identity and expected target/profile ABI compatibility until candidate installation resolves it; Engine-local numeric type IDs or pointers may appear only as candidate-owned/runtime operands, never as durable relocation identity. Missing, forged, wrong-revision or incomplete lifetime facts fail before artifact publication. Initially fail before the complete backend/install boundary exists.

  Progress 2026-08-29: the frozen input carries verifier-authenticated exact
  interface relations through Sidecar V8, and CodeGen now consumes them to
  prepare declaration-only interface shells, slots, offsets and chunks without
  method target rematching. Detached publication is Commit/Abandon atomic;
  Prepared publication authenticates the Builder-owned graph read-only before
  detaching bodies/globals. Source metadata and pure-constant rollback REDs,
  failure/retry, last-good retention and Hot Reload are green. Funcdefs and the
  broader declaration/publication sentence still keep 9.1 open. Evidence:
  `attachments/canonical-interface-publication-gate-2026-08-29.md`.

  Progress 2026-08-30: CTA-S72 makes call emission consume the publication-
  authenticated formal plan and reject empty/partial or semantically impossible
  records before mutation. Sidecar V9 carries the same pointer-free facts, and
  the generated StaticClass Cache restore uses a focused transactional
  `GeneratePreparedFunctionBody()` boundary. This advances the publication
  firewall but does not prove every declaration category or complete lifetime
  matrix, so 9.1 remains open. Evidence:
  `attachments/canonical-call-argument-provenance-gate-2026-08-30.md` and
  `attachments/cta-s72-cache-staticclass-canonical-rebuild-progress-2026-08-30.md`.

  Why this is still open: the class and sealed-only tests exist. Isolated artifact `Abandon`/`Commit` landed. Candidate script functions (including property-owned global initializers), imports, global properties, and script object types now remain outside engine/module publication tables until `Commit()`; types resolve through an artifact-local `asCRuntimeTypeBridge` view, and globals install their address-map entries before `AddReferences()`. This is detached for the currently supported objects, but funcdefs and broader declaration kinds remain unproven/unsupported. CANONICAL `Build()` now stages a private candidate and promotes it only after a successful candidate commit, so an ordinary failed rebuild preserves the active generation. 9.1 nevertheless stays open until review proves this rollback discipline across every declaration category and every `Commit()` publication boundary, rather than only the currently supported objects.

  Progress 2026-08-23: the failure-path matrix no longer assumes that a
  language form remains unsupported. `asCBytecodeCodeGen` now has the
  `WITH_ANGELSCRIPT_UNITTESTS`-only
  `SetTestFailureBeforeFunctionEmission(ordinal, error)` diagnostic fault
  boundary. At ordinal 1, it fails after the first candidate body has emitted
  but before the second body, with stable
  `injected-function-emission` detail; normal builds expose no hook and have
  no behavior change. The three source-path transaction fixtures first inspect
  their sealed AST class/function, import/function, or class-method/function
  facts, then inject the same boundary and assert complete module/engine table
  rollback. It now also injects after each currently supported `Commit()`
  publication phase (types, globals, imports, functions); the final
  transaction group is **17/17 PASS**. Red/green evidence, API boundary, and
  remaining limits are in
  `attachments/canonical-codegen-emission-failure-gate-2026-08-23.md`. This is
  a durable diagnostic/rollback test improvement, **not** a 9.1 completion:
  it does not cover per-item failures inside those phases, funcdefs/other
  declaration categories, or full-language detached publication.
- [x] 9.2 <!-- TDD --> Implement local/parameter/global reads/writes, literals, exact conversions, scalar/enum unary/binary/logical/comparison operations, assignments/mutations, and return-value marshalling from canonical expressions.
- [x] 9.3 <!-- TDD --> Implement structured block/if/for/while/do/switch/case/default/break/continue/return lowering, labels/patches, safe points, and AST-recorded cleanup/transfer plans. Compare VM traces against legacy in isolated Engines.
- [x] 9.4 <!-- TDD --> Implement ordinary/member/mixin/import/native/property/constructor/destructor call lowering from resolved canonical call nodes, including reverse formal order, source/default/hidden/named origins, effective receivers, references/out parameters, and route/ABI metadata.
- [ ] 9.5 <!-- TDD --> Implement value-object/temporary lifetime, handles/references, containers/templates, delegates/funcdefs, lambdas/closures, globals/imports, generated lifecycle/default/accessor/list factory bodies, and current exception/suspend semantics from canonical AST. Lifetime coverage SHALL include initializer-success activation, failed-current-object exclusion, base/member/delegating-constructor committed prefixes, array/aggregate progress, complete-object commit and reverse live-only cleanup on every supported exit.

  Progress 2026-08-29: exact interface callable relations now publish bodyless
  `asFUNC_INTERFACE` shells and class interface chunks, and real prepared and
  detached `asBC_CALLINTF` fixtures execute `42` with zero legacy invocations.
  The same failure/retry gate proves source-body and scalar-global transaction
  symmetry. This closes the interface-call slice only; stored capturing
  closures, exception tables and the full language/lifetime sentence keep 9.5
  open. Evidence:
  `attachments/canonical-interface-publication-gate-2026-08-29.md`.

  Why this is still open: this is the full-language CodeGen surface. Integer `int F() { return 7; }` production routing executes via CodeGen. Live ProductionCodeGen has since grown beyond the historical **33/33** baseline. Direct capturing lambdas now consume Sema-owned capture plans; stored noncapturing lambdas execute through `CallPtr`. A true stored capturing closure requires a new `{function identity, capture environment}` value/GC/call ABI and is now explicitly rejected by Sema instead of failing accidentally in late CodeGen. Exception tables and the rest of the spec sentence are still incomplete. Leave `[ ]`.

  Progress 2026-08-31: handle `DECL_REF` lvalues, owning-handle `REFCPY`,
  sealed-release retire, native factory identity publish, and list-factory
  buffer intern skip closed the remaining ProductionCodeGen reds. Named prefix
  **196/196**. Nested/omitted list-pattern, exception/suspend tables, and stored
  capturing closures keep 9.5 `[ ]`. Evidence as under 5.9.

  Progress 2026-08-24: Canonical production CodeGen now executes the host
  funcdef argument/indirect `CallPtr` path after Sema records the registered
  signature return type instead of the callable handle type. Focused execution
  is **1/1**, complete ProductionCodeGen is **73/73**. Non-POD script value
  objects by value remain unsupported and were deliberately not hidden by this
  result. Evidence is in
  `attachments/canonical-funcdef-call-abi-gate-2026-08-24.md`.

  Progress 2026-08-24: Canonical CodeGen now returns reference objects and
  funcdefs through the VM object register using the legacy-compatible
  ownership-transferring `LOADOBJ` protocol; callers already consume that
  contract with `STOREOBJ`. Temporary property/index receivers execute without
  null `this`, while twelve-byte POD by-value and namespace-qualified script
  value-object regressions remain green. ProductionCodeGen is **73/73** and
  CanonicalAST **365/365**. Stored closures, exception/suspend tables, cache
  replay, and the rest of the task keep 9.5 open.

  Progress 2026-08-24: Canonical CodeGen now consumes Sema-sealed source
  `foreach` phases directly and executes the resolved begin/end/value/next
  protocol with publisher `CANONICAL_CODEGEN` and legacy invocation count
  zero. The keyed form consumes the same backend route and executes exact
  `opForKey` with no backend reconstruction. Complete ProductionCodeGen is
  **82/82**. Object iterator lifetime/cleanup, stored closures, exception/suspend tables, and
  the remaining full-language forms keep 9.5 open. Evidence:
  `attachments/canonical-foreach-protocol-gate-2026-08-24.md`.

  Progress 2026-08-25: value-object foreach iterators now carry a fourth exact
  `scope-exit` destructor phase. Canonical CodeGen performs trait-gated exact
  storage copy (including one-dword values), tracks live ownership, emits the
  cleanup on natural exit and transfers that cross the lifetime, and retires
  the object from the common epilogue. The permanent execution gate passes and
  the complete ProductionCodeGen group is **83/83**; complete CanonicalAST is
  **392/392**. Containers, stored closures, exceptional cleanup,
  suspend/resume, and the other full-language families keep 9.5 open. Evidence:
  `attachments/canonical-foreach-protocol-gate-2026-08-24.md`.

  Progress 2026-08-25: production prepared-module CodeGen now creates detached
  Runtime shells for nested lambda declarations, appends Sema-sealed captures
  as hidden parameters, emits their bodies, and publishes them only after the
  candidate succeeds. Runtime anonymous names restore the maintained `$...$N`
  internal-function protocol while exact Canonical identity remains the
  producer-carried parent/signature/source-offset stable key. Two sibling
  lambdas independently capture the same enclosing `X`, receive distinct
  FunctionIds, are both called, and execute `21 + 21 == 42`. StaticJIT
  CanonicalASTIdentity is **12/12 PASS** and complete ProductionCodeGen is
  **94/94 PASS**. Stored closures, complex capture lifetimes,
  exception/suspend combinations, and the remaining full-language families
  keep 9.5 open. Evidence:
  `attachments/canonical-declaration-identity-and-lambda-publication-gate-2026-08-25.md`.

  Progress 2026-08-25: the current funcdef/lambda storage contract is now
  explicit and fail-closed. A stored noncapturing lambda publishes through
  `CANONICAL_CODEGEN`, executes via real `CallPtr`, and returns `42`. A
  capturing lambda remains supported for exact direct/IIFE calls, where its
  sealed captures are hidden arguments; attempting to store/return/otherwise
  escape it is rejected across the whole candidate graph with the stable Sema
  diagnostic `capturing-lambda-cannot-escape` before CodeGen or either
  publisher runs. This deliberately does not invent a heap-closure ABI that
  current funcdef values cannot represent. Exact Sema, noncapturing storage,
  and captured rejection are each **1/1 PASS**; complete ProductionCodeGen is
  **96/96 PASS**, the focused `CompileFunction` capture regression is **1/1
  PASS**, and StaticJIT CanonicalASTIdentity remains **12/12 PASS**. Complex
  object/capture lifetimes, containers, globals/imports, list factories,
  exceptional cleanup, suspend/resume, and the other full-language families
  keep 9.5 open. Evidence:
  `attachments/canonical-lambda-storage-boundary-gate-2026-08-25.md`.

  Scope decision 2026-08-25: the product does not materially rely on stored
  capturing lambdas. For this change, the lambda-family completion contract is
  the already-proven minimal compatibility surface: direct captured calls,
  stored noncapturing funcdefs, and an early stable Sema rejection for captured
  escape. A new heap-closure/capture-environment ABI is explicitly deferred and
  is not a prerequisite for Canonical default cutover, HIR retirement, or 9.5.
  Remaining 9.5 work therefore prioritizes the actually used import/global,
  object/container, generated lifecycle, exceptional cleanup, and suspend
  families rather than expanding the language.

  Progress 2026-08-25: the real staged Builder -> `GeneratePreparedModule`
  path now consumes explicit imports instead of rejecting every non-empty
  `bindInformations` inventory. Stage2 remains the sole owner of the imported
  Runtime shell and Engine FunctionId; the sealed import binds exactly by
  producer stable key, source module, namespace, normalized complete Runtime
  signature/directions, and exact Engine slot, then emits `CALLBND`. A poisoned
  identity fails before body/import mutation and the same module succeeds after
  restoring the key. Canonical source identity and Builder Runtime ABI now
  share one parameter-normalization helper, while call semantics continue to
  consume the sealed source formal so by-value VALUE objects are not mistaken
  for explicit references. Parameterized prepared import is **1/1 PASS**,
  complete ProductionCodeGen is **98/98 PASS**, Module Imports is **7/7 PASS**,
  and StaticJIT CanonicalASTIdentity is **12/12 PASS**. Imported/indirect
  non-POD ownership, exceptional cleanup, suspend/resume, globals/containers,
  and the remaining full-language families keep 9.5 open. Evidence:
  `attachments/canonical-prepared-import-publication-gate-2026-08-25.md`.

  Progress 2026-08-28 (CTA-S48): Production CodeGen now consumes a Sema-owned
  primitive property `&out` plan directly. It passes the address of a temporary
  to the primary call, evaluates the opaque receiver once, preserves the
  primary result, then invokes the exact sealed setter; it never reconstructs
  property identity or invokes LEGACY. Focused execution is **1/1**, direct
  local out remains **1/1**, and complete ProductionCodeGen is **113/113
  PASS**. Non-POD out, `&inout`, reference-return aliasing, exceptional/
  suspend lifetimes and the remaining full-language families keep 9.5 open.
  Evidence:
  `attachments/canonical-deferred-property-out-writeback-gate-2026-08-28.md`.

- [ ] 9.6 <!-- TDD --> Implement debug line/variable metadata, source maps, coverage/timeout/safe-point roles, stable type/property/function dependency relocations, exception/cleanup tables, stack/local layout, and final `asCScriptFunction::ScriptFunctionData` publication as backend output rather than Sema state. Semantic lifetime inputs come only from the verifier-authenticated Canonical protocol/shared view; physical cleanup/EH tables, labels, patches, slots and frame layout remain backend output. Installation must resolve the complete relocation set before publication and may then patch generation-local pointers/offsets/slots/current public IDs; no persisted or cross-generation identity may depend on those resolved values.

  Progress 2026-08-24: the parser-source line-table gate now proves that
  Canonical CodeGen publishes a valid first executable source row and matches
  an explicitly selected LEGACY compiler build. The test also verifies the
  LEGACY publisher/invocation instead of relying on a misleading module name.
  `asCBytecodeCodeGenDumpFunction` now reports declared location, logical
  section, every line-table tuple, and every section transition; the exact gate
  is **1/1 PASS** and complete Frontend CanonicalAST is **123/123 PASS**. This
  closes only the single-section source-line slice; variable tables,
  cross-section transitions, coverage/timeout/safe-point roles, exception
  tables, and the remaining `ScriptFunctionData` contract keep 9.6 open. See
  `attachments/canonical-debug-line-metadata-contract-2026-08-24.md`.

  Why this is still open: production `ScriptFunctionData` is still filled by `asCCompiler`. Isolated CodeGen may write some metadata in tests. Debugger/coverage/timeout prefixes that passed in All used the legacy emitter. Checking 9.6 implied debug/coverage were CodeGen products; they are not.

  Progress 2026-08-25: Canonical CodeGen now publishes parameter/local
  `variables`, lexical `Block` lifetimes, line metadata, and an actionable
  frame/debug-variable/temporary dump. While bringing the Runtime
  LocalVariables oracle onto that path, an earlier Module's same-name Runtime
  script type was proven to reclassify the current Module's authored class as
  a native projection, leaving the current field layout at `byteOffset=-1`.
  Sema native projection now refuses to populate any ranged authored script
  class; only range-less `canonical-native-type-view` declarations may consume
  Runtime ABI facts. The independent simultaneous cross-Module same-name
  script-type publication case remains deliberately fail-closed and is not
  claimed as supported. LocalVariables is **1/1 PASS** and the combined debug
  metadata + VariableScope + CanonicalAST Type regression is **24/24 PASS**.
  Exception/cleanup tables, coverage/timeout/safe-point roles, complete
  Save/Load publication, and broad debugger regressions keep 9.6 open. Root
  cause, ownership diagrams, evidence, and the remaining type-identity design
  boundary are recorded in
  `attachments/canonical-runtime-registry-reverse-pollution-2026-08-25.md`.

- [ ] 9.7 <!-- TDD --> Expand isolated differential execution over all active Native SDK Compiler/Runtime/Module/TypeSystem/Language/Embedding/Conformance fixtures plus project Script corpus. Compare behavior/diagnostics/metadata/dependencies and report bytecode-byte differences separately.

  Why this is still open: AngelScriptSDK 821/821 in All is `asCCompiler` Bytecode vs VM, not `asCBytecodeCodeGen` vs legacy. Isolated differential tests exist for a handful of shapes. They were generalized into “SDK corpus is done”. Bytecode-byte differences were never the pass criterion; observable behavior was — but that behavior was not produced by the new backend.
- [x] 9.8 <!-- TDD --> Add SaveByteCode/LoadByteCode and Cache V2 version tests for canonical Bytecode, prior supported payloads, unsupported-version safe rejection, and no AST/HIR bytes in VM archives.
- [x] 9.9 <!-- Non-TDD --> Run `Tools\RunBuild.ps1 -Label canonical-ast-bytecode -TimeoutMs 1800000 -NoXGE` and all AngelScriptSDK prefixes through `Tools\RunTests.ps1`; canonical default remains disabled until all focused results pass.

## 10. Production cutover and LEGACY isolation (HIR retirement closed)

HIR is physically retired and is no longer a cutover dependency. The native
`asCScriptNode` Parser AST, Builder and `asCCompiler` remain intentionally
available for explicit LEGACY, syntax/recovery and reference/differential use.
Do not default `canonicalCompilerPipeline` or report
`IsCanonicalBytecodeCodeGenReady()` until these gates pass. Until then the
product default remains LEGACY so tests cannot attribute `asCCompiler`
Bytecode to canonical CodeGen (review R01).

- [ ] 10.1 <!-- TDD --> Add a cutover test matrix proving canonical Parser/Sema/Bytecode is selected for every in-scope UE source build purpose (primary, Hot Reload, single-function compile, generation and commandlet) and that no production `dual` selection is registered. Standalone adaptation/verification is explicitly deferred to a separate future OpenSpec and is not a completion row for this task.

  Historical starting point: early Cutover tests asserted pipeline `CANONICAL`,
  `Ready() == true`, and execution, but did not prove every real host publisher.
  Integer `F()` and value-object Cutover later added `CANONICAL_CODEGEN`
  provenance and dual enum rejection became real. This paragraph is retained
  as the original gap statement; the current row status is updated below.

  Progress 2026-08-24: the single-function row is no longer an alias for the
  legacy backend. Public attached and detached `CompileFunction` now seal an
  ephemeral canonical AST and publish through `asCBytecodeCodeGen`; complete
  Cutover is **11/11 PASS** with publisher, zero-legacy-invocation, digest,
  execution, rollback, snapshot, lambda-closure, and exact current-module
  function/global-view assertions.

  Progress 2026-08-25: the real UE staged primary path is **12/12 PASS** and
  the real `SoftReloadOnly` Hot Reload row now proves A-to-B canonical digest
  replacement, `CANONICAL_CODEGEN`, zero legacy compiler invocations, retained
  snapshot leases, and failed-C last-good atomicity. The focused publisher /
  rollback gate is **1/1 PASS** and the complete Hot Reload CanonicalAST group
  is **6/6 PASS**. See
  `attachments/canonical-hotreload-publisher-gate-2026-08-25.md`. Primary,
  public `CompileFunction`, and Hot Reload are therefore closed rows;
  generation and commandlet still need real entry-point gates, so 10.1 remains
  open. The historical Standalone row is deferred and no longer blocks this
  task.

- [ ] 10.2 <!-- TDD --> Make canonical pipeline the default behind a reversible source/config transition only after Tasks 1-9 pass **and** production Bytecode comes from `asCBytecodeCodeGen::Generate()` on the sealed snapshot. Keep `LEGACY` as opt-out. Focused SDK/Cache/HotReload/StaticJIT gates belong to 10.9; Standalone is deferred to a separate future OpenSpec.

  Why this is still open: the default must stay LEGACY until Tasks 1–9 (authority) pass **and** production Bytecode comes from `Generate()` on the sealed snapshot for the language surface, not only `int F()`. `Ready()` is true as a binary capability because CANONICAL `Build()` already calls `Generate()`; that is not Wave G. Do not flip `ep.canonicalCompilerPipeline`. Do not check 10.2 from Ready true or integer ProductionCodeGen.

- [ ] 10.3 <!-- TDD --> Attach typed Parser+Sema canonical actions for module `Build()` and public `CompileFunction`. `CompileFunction` must not replace a retained module snapshot unless a documented complete-snapshot policy republishes one. The native Parser tree may remain syntax/recovery input and may feed the separately selected LEGACY pipeline; the CANONICAL sealed graph must already contain every backend decision and MUST NOT semantically replay that tree.

  Why this is still open: attach exists as a post-parse walk. Builder continues after Sema/Context allocation failure. `CompileFunction` tests lock “generation key unchanged” without checking that the snapshot contains the new function. Parser nodes are still the semantic input, not recovery-only. The rewritten 10.3 that said “`asCScriptNode` remains the grammar tree feeding Sema, not the product semantic contract” described the bug as the task.

  Progress 2026-08-24: public `CompileFunction` now uses Parser/Sema, seals one
  verified ephemeral graph, and never adopts it as a complete module snapshot.
  Attached success retires the previous now-incomplete snapshot; detached
  success and every failure preserve the current complete generation. The
  remaining blocker is the broader action-only Parser/Sema migration: legacy
  parser nodes are still semantic input for unresolved language slices.

  Progress 2026-08-30: custom access permissions now use checked typed-action
  growth, and the Parser fails before Sema publication on append OOM. The
  prepared CANONICAL path consumes only the completed exact declaration graph;
  the native access node remains LEGACY/recovery storage. Other unresolved
  body/expression/statement adapters keep 10.3 open. Evidence:
  `attachments/canonical-access-specifier-runtime-projection-transaction-gate-2026-08-30.md`.

- [ ] 10.4 <!-- TDD --> Production Bytecode for a canonical-selected Engine SHALL be published by `asCBytecodeCodeGen` from the same sealed AST. Sema/AST/CodeGen sources must not include `as_compiler.h`. `asCExprContext::bc` stays inside `asCCompiler` only for the LEGACY opt-out path.

  Why this is still open: this is the actual cutover. CANONICAL `asCModule::Build()` now calls `Generate()` after parse+seal and skips `BuildCompileCode`; LEGACY still uses `asCCompiler`. That is integer/subset routing, not full-language production CodeGen (9.5). Candidate functions, imports, global properties, and script object types are deferred and published only by `Commit()`. Candidate-to-active replacement stages the new generation before promotion, but the supported language subset is still far from complete. Sema/AST sources must still not include `as_compiler.h`; header isolation is not Bytecode cutover. Do not check from ProductionCodeGen 59/59.

  Progress 2026-08-24: both public CANONICAL source entry points now publish
  from CodeGen: module `Build()` uses `Generate`, and `CompileFunction` uses the
  new `GenerateFunction` attached/detached transaction. Cutover is **11/11**
  and ProductionCodeGen remains **73/73**. The task remains open for the full
  language surface and final removal of residual semantic dependence, not for
  single-function routing.

- [x] 10.5 <!-- TDD --> Remove production HIR capture/builder/accessors after TypedASTJIT and tests no longer consult `asCTypedSemanticFunction` oracles. Cache has `ASTBodySidecar` (kind 8) and no `TypedHIRSidecar`. Default `captureTypedSemanticIR` stays off throughout.

  Historical blocker (closed 2026-08-27): default HIR capture off and kind 8
  replacing the unimplemented TypedHIRSidecar *plan* were initially only
  defaults. Accessors, types, consumers and test oracles still existed, so
  capture-off alone was not deletion.

  Progress 2026-08-24: production TypedAST generation no longer uses the HIR
  capture switch as a proxy for AST retention, and the source-owned generation
  snapshot stores null `VerifiedTypedHIR` pointers. This narrows the removal
  frontier to explicit compatibility fields/diagnostics, fallback overloads,
  the HIR builder/storage/accessors still hosted by the LEGACY compiler
  implementation, and migrated tests. The native `asCBuilder` is explicitly
  retained and is not this HIR builder. It does not
  satisfy deletion. See
  `attachments/staticjit-canonical-capture-boundary-gate-2026-08-24.md`.

  Audit 2026-08-27: the retirement boundary is now explicit. Delete the added
  function-owned TypedSemantic HIR model/builder/capture/storage/accessors,
  HIR-only TypedASTJIT branches, Editor dump surfaces and active HIR tests;
  retain native `asCScriptNode`, Parser, `asCBuilder`, `asCCompiler`, and the
  explicit LEGACY pipeline. The broad case-insensitive scan still finds 44
  Runtime, 6 Editor, 93 test and 5 Standalone files with HIR names or contracts.
  Source provenance is a required neutral capability currently expressed with
  HIR-named types and must move to SourceManager/ScriptCode ownership before
  model deletion. Task remains open. See
  `attachments/typed-semantic-hir-physical-retirement-gate-2026-08-27.md`.

  Progress 2026-08-27: `as_source_provenance.h` now owns neutral anchor,
  generated-origin, span and range records. ScriptCode, Module and UE source
  ingestion no longer include HIR or use HIR provenance names; exact API/
  behavior tests are 7/7, Canonical SourceManager is 9/9, Runtime/Editor builds,
  and Standalone is 21/21. Old provenance-symbol matches fall from 203 to 173;
  temporary aliases plus remaining HIR/TypedASTJIT/test consumers keep this
  task open. See
  `attachments/hir-neutral-source-provenance-extraction-gate-2026-08-27.md`.

  Progress 2026-08-27: the Editor `AngelscriptHIRDump` command and Commandlet,
  their dedicated tests, the `DeveloperHIRDump` ProjectSourceGraph mode and
  HIR-specific scratch route are physically deleted. Two valuable containment/
  snapshot behaviors now test ProjectSourceGraph and the public Canonical AST
  lease directly. Runtime/Editor builds, migrated behavior is 2/2,
  ProjectSourceGraph is 2/2 and Standalone is 21/21; active Source inputs have
  zero `AngelscriptHIRDump`, `DeveloperHIRDump` or request-kind symbols. The
  removed generated-origin HIR integration test exposes an open migration:
  Canonical SourceManager diagnostics did not yet retain/display the neutral
  authored/generated provenance chain. Compiler capture, function storage,
  TypedASTJIT HIR branches, diagnostics and remaining tests still keep this
  task open. See
  `attachments/hir-editor-dump-retirement-gate-2026-08-27.md`.

  Progress 2026-08-27: Canonical SourceManager now owns copied neutral
  authored/generated ranges, Parser/Sema source sessions verify provenance on
  FileID reuse, and `ResolveSourceSpan` exposes the chain. `ASTBodySidecar`
  schema V6 serializes/restores that snapshot-owned diagnostic metadata;
  malformed records fail closed and the previous V5 schema is a safe miss.
  Function record identity deliberately excludes authored/generated anchors.
  Runtime/Editor builds pass; ASTBodySidecar is 21/21, SourceManager 12/12,
  neutral ownership 3/3, Preprocessor provenance 2/2 and Standalone 21/21.
  Compiler HIR capture/storage/accessors, TypedASTJIT compatibility, HIR-era
  diagnostics/tests and Standalone HIR wiring still keep this task open. See
  `attachments/canonical-source-provenance-retention-gate-2026-08-27.md`.

  Progress 2026-08-27 CTA-HIR-05: the function-local
  `asCTypedSemanticIRBuilder` and all HIR hooks in `as_compiler.h/.cpp` are
  physically deleted (3,763 implementation lines plus 23 header lines).
  Native `asCScriptNode`, `asCBuilder`, `asCCompiler`, and explicit LEGACY are
  retained. The first build failed only in the obsolete ExprContext HIR-field
  test; deleting that HIR-only test produced a full Runtime/Editor/test-module
  build pass. Compiler HIR matches and `asCTypedSemanticIRBuilder` files are
  now zero, but function storage/accessors, Engine configuration, TypedASTJIT
  compatibility, diagnostics, Standalone wiring, and old tests remain. Task
  stays open. See
  `attachments/typed-semantic-hir-compiler-capture-removal-gate-2026-08-27.md`.

  Closure 2026-08-27: the complete function-owned TypedSemantic HIR model,
  capture/configuration, compiler builder hooks, script-function ownership and
  accessors, Editor dump surfaces, TypedASTJIT compatibility overloads,
  Standalone wiring, diagnostics and HIR-only tests are physically absent.
  `as_typed_semantic_ir.h/.cpp` do not exist. Active product/build/test
  consumers have zero matches for the full forbidden symbol set; the only
  filename literals are permanent negative architecture assertions proving
  the two retired model files remain absent. Cache kind 8 is
  `ASTBodySidecar`, and `TypedHIRSidecar` is absent. Native `asCScriptNode`,
  Parser, `asCBuilder`, `asCCompiler`, and explicit LEGACY remain present.
  Fresh Runtime/Editor build is green; complete Standalone Debug is **20/20**;
  direct Canonical AOT groups are **48/48**; exact repeated generation is
  **1/1** and final Cutover is **12/12**. See
  `attachments/typed-semantic-hir-physical-retirement-gate-2026-08-27.md` and
  `attachments/canonical-parser-lifetime-gate-2026-08-27.md`. This closes only
  physical HIR retirement; Parser-node semantic replay remains open in 10.6.

- [ ] 10.6 <!-- TDD --> After cutover, no CANONICAL compiler/backend path uses `asCScriptNode` as a semantic body representation. `ScriptFunctionData` does not store parser nodes. Retain the native syntax tree, Parser/Builder tests, and explicitly selected LEGACY path for reference, syntax coverage, differential testing, and rollback; do not copy legacy semantic facts into the Canonical graph after Sema actions.

  Why this is still open: CANONICAL Sema’s production attach still semantically
  walks `asCScriptNode` for named body/expression/statement/lifetime adapters.
  Merely retaining parser nodes as a grammar tree is allowed; rediscovering
  Canonical facts from them is not. `ScriptFunctionData` not storing parser
  nodes is already true and is not the whole task.

  Progress 2026-08-30: the exact custom-access Runtime projector has zero
  `snAccessDeclaration` references and zero LEGACY `RegisterAccessSpecifier`
  calls; access definition order, permissions and member relations all come
  from Canonical DeclIds. Native class/member nodes remain build-local exact
  completed-coordinate keys, not semantic payloads. This retires Parser-node
  semantic replay for this declaration family only. General body/expression/
  statement/lifetime adapters keep 10.6 unchecked. Evidence:
  `reviews/canonical-access-specifier-runtime-projection-transaction-review-2026-08-30.md`.

- [ ] 10.7 <!-- TDD --> Canonical is the product-default source-compiler selection after the complete gate, while LEGACY remains an explicit independent compatibility/reference/rollback selection. Unknown/dual values are rejected; one build publishes through exactly one selected pipeline, and CANONICAL never silently falls back or merges facts. Physical removal of the native AST/Builder/Compiler is deferred to a later dedicated OpenSpec.

  Why this is still open: dual rejection and explicit independent pipeline
  selection exist, but the default is still LEGACY and full CANONICAL
  provenance is incomplete. A second Engine labeled CANONICAL that executes
  legacy Bytecode would still launder provenance; retaining an honestly labeled
  explicit LEGACY Engine does not.

- [x] 10.8 <!-- TDD --> Add final forbidden-symbol/source scans for `llvm::`, `clangAST`, `TypedHIRSidecar`, `asCOMPILER_PIPELINE_DUAL`, default HIR capture, and Sema/AST backends including the legacy compiler header.

  Kept checked: the scan exists and LLVM/Clang are not linked. It does **not** prove production CodeGen. Do not treat 10.8 as 10.4.

- [ ] 10.9 <!-- Non-TDD --> Run `Tools\RunBuild.ps1 -Label canonical-ast-cutover -TimeoutMs 1800000 -NoXGE`, focused SDK/HotReload/StaticJIT tests plus the Cache V2 default-disabled boundary test, and do not check this milestone if any CANONICAL-selected active fixture still requires the LEGACY semantic frontend or accepts a missing/invalid Canonical lifetime protocol. Explicitly labeled LEGACY compatibility/differential fixtures and enabled Cache V2 prototype restore tests remain separate non-blocking regressions. HIR fallback is impossible and must remain absent.

  Why this is still open: those prefixes were run and are green *because* the legacy frontend is still the production path. The last clause of the original task forbids checking 10.9 in that situation. The counts in `cutover-results.md` remain useful as regression evidence, not as this gate.

## 11. Standalone, public API, and documentation closure

- [x] 11.1 <!-- TDD --> Update Standalone CMake/source lists and add CTests for canonical Parser/Sema/AST/Bytecode, discard/retain policy, public V1 traversal, deterministic dump, Cache DTO round-trip where host-neutral, and absence of UE/Clang/LLVM link dependencies.
- [x] 11.2 <!-- Non-TDD --> Run `Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix canonical-ast-standalone -TimeoutMs 600000` and keep Debug/Release counts separate; later run `-Suite StandaloneRelease` when the implementation reaches release verification.
- [x] 11.3 <!-- Non-TDD --> Keep `Documents/Guides/AngelscriptForkStrategy.md`, build/test/cache/StaticJIT/Standalone guides, plugin README, public API notes, and Chinese knowledge articles synchronized with the migration: product default remains LEGACY until section 10; function-owned HIR is physically absent; explicit LEGACY retains the native AST/Builder/Compiler; explicit CANONICAL publishers use sealed-AST CodeGen for their supported surface; LLVM remains a non-goal.

  Why checked: Wave A documentation first established the truthful LEGACY
  default and Canonical migration boundary. Later documentation updates now
  also record physical HIR retirement, explicit CANONICAL CodeGen publication
  for supported surfaces and continued native AST/Builder/Compiler retention
  for explicit LEGACY/reference use. Public V1 size/version negotiation is
  covered by 11.4.

- [x] 11.4 <!-- Non-TDD --> Add migration notes for embedding clients: public header/product version, AST API V1 negotiation (append-only or extension interface, caller size/version), module retention timing, null acquisition, snapshot lease/current-generation rules, Cache/SaveByteCode boundaries, and no concrete node ABI.

  Closed 2026-08-28: Chinese-first and English migration guides now document
  product/header `1.0.0`/`10000`, trailing module ABI slots, caller-capacity V1
  view negotiation, foreign snapshot IDs, pre-Build retention freeze, normal
  null acquisition, AddRef/Release and current/old/failed-generation rules,
  exact detached versus `ADD_TO_MODULE` CompileFunction snapshot behavior,
  Cache V2 sidecar versus `SaveByteCode`, stable pointer-free persistence and
  no concrete node ABI. The audit also corrected two stale claims: explicit
  CANONICAL source compilation is the sealed-AST CodeGen route, and HIR is
  physically deleted while the native AST/Builder/Compiler remain retained.
  Fresh Module Snapshot, strict OpenSpec and diff-check evidence is recorded in
  `attachments/embedding-client-canonical-ast-migration-notes-2026-08-28.md`.

  Why this is still open: `Documents/Guides/AngelscriptCanonicalAST.md` exists but cannot honestly describe size/version negotiation or a compatible vtable (see 3.2). Product version is still 1.0.0 after a mid-vtable insertion. Migration notes that tell embedders “call AcquireASTSnapshot(V1)” without warning about ABI and buffer size are harmful.
- [x] 11.5 <!-- Non-TDD --> Update state dumps/diagnostics/catalogues only through public/read-only observers; do not add intrusive dump ownership to AST, Sema, CodeGen, Runtime, or Editor classes.

## 12. Final verification and archive readiness

- [x] 12.1 <!-- Non-TDD --> Run `Tools\RunBuild.ps1 -Label canonical-ast-final -TimeoutMs 1800000 -NoXGE` and require exit 0 with the plugin submodule and parent gitlink aligned.
- [ ] 12.2 <!-- Non-TDD --> Run focused `Tools\RunTests.ps1` prefixes for AngelScriptSDK Frontend, Compiler, Runtime, Module, TypeSystem, Language, Embedding, Conformance, Cache, HotReload, StaticJIT, Debugger, and CodeCoverage; record exact pass/fail/skip/timeout counts in a change attachment.

  Why this is still open: `canonical-ast-final-all2` recorded the SDK/Cache/HotReload/StaticJIT/Debugger counts in `attachments/final-results.md` (legacy-compatible). CodeCoverage is not an All-suite entry, so it has no fresh count. Even after CodeCoverage, 12.2 is regression evidence for the *current* production path, not a section 10 pass.
- [x] 12.3 <!-- Non-TDD --> Run `Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix canonical-ast-standalone -TimeoutMs 600000` and `Tools\RunTestSuite.ps1 -Suite StandaloneRelease -LabelPrefix canonical-ast-standalone-release -TimeoutMs 1200000`.
- [ ] 12.4 <!-- Non-TDD --> Run `Tools\RunTestSuite.ps1 -Suite All -LabelPrefix canonical-ast-final-all -TimeoutMs 3600000`; require zero failures, skips, and timeouts except repository-baselined Disabled cases that predate this change.

  Why this is still open as a *cutover* gate: `canonical-ast-final-all2` already ran (36 Unreal prefixes 3632/3632, Standalone 21/21, suite exit 0). The review said a green All suite would not change Request changes. Re-check 12.4 only after section 10/13 when All is evidence that *canonical CodeGen* did not regress, not that `asCCompiler` still works. The numeric run is recorded in `attachments/final-results.md` so it is not lost.
- [x] 12.5 <!-- Non-TDD --> Run `openspec validate "refactor-as-canonical-typed-ast-compiler"`, Markdown/link checks, `git diff --check`, public ABI/source scans, Cache schema scans, and deterministic AST/Provider output comparisons.
- [x] 12.6 <!-- Non-TDD --> Reconcile every requirement/scenario against completed tasks and test evidence, update proposal/design/specs when implementation overturned an assumption, mark no task complete without fresh evidence, and archive only after the user requests closure. Specs were **not** overturned. False-complete tasks reopened. Mapping: `attachments/record-reconciliation.md`. Archive still requires an explicit user request.

## 13. Review blocking work (do before another cutover attempt)

Order matches `reviews/implementation-review-2026-08-21.md`. Keep the scaffold; do not delete it to start over. These are the same gaps as the reopened 2–10 tasks, listed in the order they must be fixed so we do not flip the default again first.

- [x] 13.1 <!-- TDD --> R01 naming and provenance: canonical-selected module Build and public `CompileFunction` publish Bytecode from `asCBytecodeCodeGen`, retain the exact sealed-AST digest, and expose every `asCCompiler` construction through a deterministic invocation counter. `IsCanonicalBytecodeCodeGenReady()` follows explicit pipeline selection and is false for LEGACY. Candidate-to-active promotion now publishes the invocation counter with the publisher/digest, preventing false zero provenance. The real UE staged primary compiler also seals the prepared graph and publishes through `asCBytecodeCodeGen::GeneratePreparedModule()` with zero legacy invocations. Fresh closure evidence is Cutover **12/12** and PrimaryCanonicalASTGenerate **12/12**; see `attachments/canonical-provenance-closure-audit-2026-08-24.md`.

  Why first: every later green test is untrustworthy until provenance is visible. This is the cheapest honesty fix and unblocks real Sema/CodeGen work without pretending it is done.

  Wave A honesty (2026-08-21): LEGACY default, observable publisher. Progress 2026-08-22: CANONICAL module `Build()` calls `Generate()`; integer `F()` publishes `CANONICAL_CODEGEN` and executes 7; `CompileFunction` stays `COMPILER`; default pipeline LEGACY; `Ready()` true as binary capability. TDD 9.5 ProductionCodeGen is **16/16** (`d95-array-rdr4`, includes `&in`/`&out`/handle/funcdef/`array<T>`) and Cutover **5/5**; that is a language **slice**, not 9.5. **Still `[ ]`**: 9.5 remainder (imports / generated accessors / dtor / list factory), `CompileFunction` provenance, and rereview of Ready-as-capability vs Ready-as-this-module. Do not check 10.2 default CANONICAL.

  Progress 2026-08-24: the `CompileFunction` provenance blocker is closed.
  Attached, detached, rejected, and nested-lambda cases all show
  `CANONICAL_CODEGEN`, or `NONE` on failure, with zero `asCCompiler`
  invocations. A strengthened detached case also binds an existing module
  function and global through exact declaration-only views without republishing
  either inventory. The remaining 13.1 work is the full-language/Ready/default-
  path audit; this focused closure does not justify checking 13.1 or 10.2.

  Additional progress 2026-08-24: the canonical Bytecode generator now lowers
  `**` / `**=` using the operand-width/signedness-correct VM power instruction;
  the migration group that exposed the missing mapping is **14/14**. This is
  one full-language CodeGen gap closed, not the final Ready/default-path audit.

  Reopened 2026-08-24 after auditing every snapshot publisher and real source
  entry point: `FAngelscriptEngine` does not call `asCModule::Build()` for its
  primary/hot-reload batch. Its four-stage compiler still reaches
  `CompileModule_Code_Stage3()` and unconditionally invokes
  `asCBuilder::BuildCompileCode()`, which constructs `asCCompiler`, then
  publishes the retained AST only as a sidecar. The permanent primary-engine
  provenance test is **9/10 PASS with this one expected RED**. A CANONICAL
  selection flag therefore does not yet prove the UE product path uses
  canonical Bytecode. 13.1, 10.1, 10.4, and 13.6 remain open until the staged
  backend consumes the sealed graph and reports zero legacy invocations.

  Closed 2026-08-24: the staged backend now preserves its Stage 1/2 Runtime
  shells while Stage 3 consumes the sealed graph through
  `GeneratePreparedModule()`. Scalar globals, property-owned initializers,
  authored/generated constructors and factories, and the generated static
  class object-global lifecycle all publish canonical provenance. Fresh audit:
  Cutover **12/12** at
  `Saved/Tests/cta-131-native-cutover-audit/20260824_235448_777_53bf6686`
  and real PrimaryCanonicalASTGenerate **12/12** at
  `Saved/Tests/cta-131-ue-primary-audit/20260824_235528_424_96c3617b`.
  This closes R01 provenance only. The all-purpose selection matrix, remaining
  language/lifetime lowering, final default/LEGACY isolation, and HIR removal
  remain governed by 10.1–10.7 and 13.2/13.6.

- [ ] 13.2 <!-- TDD --> R02 CANONICAL Sema authority: replace semantic `asCScriptNode` walks in the CANONICAL path with a Sema environment (scopes, symbols, overload candidates, canonical types, conversions, call plans, exact lifetime action/activation/region/construction facts, and control targets). The native syntax tree and LEGACY Parser/Builder/Compiler remain available independently. HIR is physically absent and must not be recreated. Frozen/Publishable views must show every CANONICAL semantic fact so backends only perform mechanical derivation/lowering and never rerun Sema or fall back to legacy meaning. **Gate 0 applies:** each migrated rule first gains a focused `SemaAuthority` assertion of the sealed fact; only then may verifier, CodeGen or VM execution evidence be counted.

  Progress 2026-08-29: exact class override and interface implementation
  selection lives in Canonical Sema as ordered record-owned
  `asSASTMethodRelation` edges. The verifier and Sidecar V8 preserve the full
  set, while both detached and Prepared CodeGen mechanically project exact
  declaration bindings; the production source scan finds no CodeGen
  `DoesMethodExist` or implementation-selection signature loop. Remaining
  expression/statement/lifetime adapters and the rest of the Sema environment
  keep 13.2 open. Evidence:
  `attachments/canonical-interface-publication-gate-2026-08-29.md`.

  Progress 2026-08-31: stored TMap member access used as an Iterator receiver
  is a Sema-owned MEMBER_REF fact, not a CodeGen skip of GetX. Named
  SemaAuthority **475/475**. Whole-engine Canonical `Script/` compile with
  `-as-canonical-staged-compiler` completed with zero `PropertyFromFieldDecl`
  / Canonical Sema / Canonical CodeGen errors (`cta-whole-engine-script`
  `20260831_215416_535_6962a9b8`, Cutover **15/15**, script compilation total
  931670 ms). Remaining Sema environment work keeps 13.2 `[ ]`. Evidence:
  `attachments/canonical-tmap-iterator-memberref-gate-2026-08-31.md`.

  Progress 2026-08-30: AccessSpecifier definition/permission/member facts are
  now sufficient for mechanical prepared Runtime projection. Parser append OOM
  cannot publish a truncated aggregate, and CodeGen does not perform native-
  node lookup or reclassify wildcard traits. Remaining Sema environment and
  body/expression/statement/lifetime adapters keep 13.2 unchecked. Evidence:
  `attachments/canonical-access-specifier-runtime-projection-transaction-gate-2026-08-30.md`.

  Why this is still open: Parser still builds `asCScriptNode` as recovery.
  Parameter and lambda headers, enumerator identity and all live Parser type
  routes are typed actions now, but default/property/lambda-body and general
  expression/statement/lifetime adapters still decode parts of that tree.
  LEGACY Bytecode still reruns `asCCompiler`.
  Capture list is Sema-owned (`ActOnLambdaCapture` + sealed `decl->captures`),
  but that is not a complete Sema environment for 4.2–5.9 (scopes, overloads,
  conversions, call plans, lifetimes and control targets). Eleventh-pass review
  therefore remains Request changes.

  Progress 2026-08-23: dedicated intern through F5 + 1070, compile-seal dumps, InitPlan/MemberRef execute 42, native 0-arg intern, dummy CONSTRUCT deleted, Get-miss fail-closed, script+native `byteOffset` on Seal, exact-byte RDR/WRTV, `EmitSwitch` + no innermost-loop break fallback (21/7), `LookupInScope` grovels sealed children, host globals unique-signature intern+bind (`HostPick(int)` execute 42), VAR `inits` CONSTRUCT, `PropertyFromFieldDecl` sealed offset match, **packed int8/int16 execute 1934/902** (shunting-yard intern of flat `snExpression`; WRTV1 path was already correct). SemaAuthority **250/250**. ProductionCodeGen **48/48**. CanonicalAST **321/321**. Compiler **511/511**. LEGACY still `asCCompiler`. Accessor name-strip / `fieldOffsets[]` miss remain. **Not 13.2 close**. Live trail: `attachments/async-work.md`. Next exclusive: Generate-local leftover (`attachments/wave-b-codegen-remaining.md`).

  Progress 2026-08-24: the AST-first funcdef gate found and removed a concrete
  false semantic fact: `Cb(X)` had inherited the `Callback` handle type rather
  than the registered signature's `int` result. `ActOnCall` also no longer
  overwrites Sema's explicit call result with the callee declaration type.
  Complete SemaAuthority is now **263/263** and ProductionCodeGen **73/73**;
  this is one rule migration, not completion of the Sema environment.

  Progress 2026-08-24: the temporary-receiver gate added explicit property
  receiver facts and corrected source `class`/`struct` plus imported native
  VALUE identity. The permanent native identity test records one canonical
  VALUE kind before CodeGen; SemaAuthority is now **264/264** and complete
  CanonicalAST **365/365**. Parser recovery still retains residual expressions
  and the full action-only Sema environment is not complete.

  Progress 2026-08-24: cross-section deferred calls now survive per-section
  reconciliation and, after exact binding, discard provisional ERROR-only
  Cleanup/Materialize ownership edges before Seal. The source-built AST gate
  also executes `Entry() == 42`; the old direct-Builder test explicitly selects
  LEGACY. Focused evidence is **2/2 PASS** and complete Compiler is
  **497/556**. This narrows parser recovery but does not replace the remaining
  `asCScriptNode` semantic walk or complete the Sema environment. See
  `attachments/canonical-cross-section-forward-call-gate-2026-08-24.md`.

  Progress 2026-08-24: the AST-first `PreClassData.PropertyOffset` gate first
  failed with exact class field offset `0`/size `4`, then moved the exact
  embedding prefix into the module-aware Sema layout pass. The sealed class now
  records prefix `32`, field offset `32`, size `36`, and exact control-class
  isolation before CodeGen. The broad gate also exposed and closed an
  independent missing stable `unresolved-identifier:<name>` diagnostic prefix.
  Final SemaAuthority is **270/270**, Module ApiContracts is **8/8**, and
  ProductionCodeGen is **73/73**. This closes one layout/diagnostic slice, not
  the remaining parser-tree semantic walk. Evidence:
  `attachments/canonical-preclass-layout-gate-2026-08-24.md`.

  Progress 2026-08-24: `foreach` protocol discovery is now Sema-owned. The
  sealed graph records exact resolved `opForBegin`, `opForEnd`, `opForValue`,
  and `opForNext` calls, a shared opaque receiver, the generated iterator, the
  exact source value/key declarations, and ordered control phases. A scoped
  repair rebinds both incremental-Parser placeholders inside the exact authored
  body range, leaving unrelated diagnostics fail-closed.
  SemaAuthority is **274/274**. Residual parser-tree extraction, complete scope
  authority, lifetime plans, and all remaining language forms keep 13.2 open.
  Evidence: `attachments/canonical-foreach-protocol-gate-2026-08-24.md`.

  Progress 2026-08-25: object iterators extend that protocol with a Sema-owned
  exact destructor and generated-iterator cleanup target. Class layout now
  computes the conservative `asAST_TRAIT_TRIVIAL_STORAGE_COPY`, and retained
  LEGACY comparison snapshots run canonical layout/lifecycle finalization
  before Seal so they cannot publish a verified half-product. The verifier
  rejects forged cleanup literals/targets/types; Parser-action-only int-range
  fixtures explicitly remain non-executable syntax shapes. Final
  SemaAuthority is **276/276** and complete CanonicalAST is **392/392**. This
  closes one lifetime/control rule, not the residual parser-node walk or the
  complete Sema environment.

  Progress 2026-08-27: exact qualified call/`DeclRef` lookup no longer falls
  back through missing qualifiers or parent scopes, qualifier traversal accepts
  only scope-capable declaration kinds, and deferred primitive binary parents
  are recomputed from Canonical AST facts after child resolution. The final
  focused groups are SemaAuthority **308/308** and ProductionCodeGen
  **114/114**. This closes CTA-S-05/06 bounded slices only; residual
  `asCScriptNode` extraction, action-only scope/type/call/lifetime authority and
  non-primitive dependent-expression families keep Task 13.2 unchecked.

  Progress 2026-08-27: CTA-S-07 removes whole `snNamespace` semantic replay
  and verifies exact namespace ownership plus authored function-body attachment.
  The first repair's ProductionCodeGen **109/114** regression and the AST-first
  missing-body **0/1** RED proved that child finalization must remain explicit
  during migration. The corrected boundary is SemaAuthority **309/309** and
  ProductionCodeGen **114/114**. Remaining declaration-family completion
  callbacks and expression/statement walks keep 13.2 unchecked.

  Progress 2026-08-27: CTA-S-08 removes `snEnum` declaration replay and uses
  typed enum/enumerator name actions with SourceManager-validated ranges.
  SemaAuthority is **310/310** and ProductionCodeGen is **114/114**. The enum
  initializer expression adapter and remaining declaration/type/expression/
  statement node consumers keep 13.2 unchecked.

  Progress 2026-08-27: CTA-S-09 removes `snTypedef` replay and publishes the
  exact primitive alias fact through a typed Parser-to-Sema action. The
  permanent AST gates prove early-before-`;` publication, uniqueness and
  `type=int`; final SemaAuthority is **311/311** and ProductionCodeGen is
  **114/114**. Remaining declaration/type/expression/statement node consumers
  keep 13.2 unchecked.

  Progress 2026-08-27: CTA-S-10 removes `snImport` replay and publishes typed
  signature/origin phases around incremental parameters. The architecture and
  early-error gates are green, and a ProductionCodeGen **113/114** RED exposed
  the old replay's hidden prepared-shell identity side effect. The repair is a
  named identity-only bridge, not semantic node decoding. Final SemaAuthority
  is **313/313** and ProductionCodeGen is **114/114**. General type/parameter
  adapters, remaining declaration families, body/expression/statement walks
  and final removal of the Parser identity map keep 13.2 unchecked.

  Progress 2026-08-27: CTA-S-11 migrates ordinary global/method/constructor/
  destructor/mixin/local/interface function start and traits to typed actions,
  and deletes the obsolete whole-function decoder. Early recovery now sees the
  exact method key, both parameters and trait mask before body failure. Final
  SemaAuthority is **315/315**, ProductionCodeGen **114/114**, and Parser
  declarations **18/18**. `ActOnQualTypeFromNode`, `ActOnParsedParam`, the
  body statement adapter, lambdas and remaining class/interface/expression/
  statement/lifetime actions keep 13.2 unchecked.

  Progress 2026-08-27: CTA-S-12 migrates class/struct/interface header,
  ordered qualified bases and real-body completion to typed Parser actions.
  The valid pre-edit gate was **315/317, 2 FAIL**; final SemaAuthority is
  **317/317**, ProductionCodeGen **114/114**, and Parser declarations
  **18/18**. Record whole-node cases and the old base decoder are absent.
  Remaining member/default/funcdef adapters, general types/parameters/bodies,
  lambdas and expression/statement/lifetime walks keep 13.2 unchecked.

  Progress 2026-08-27: CTA-S-13 migrates top-level/namespace global and
  class/struct field declarations to one typed header plus one exact
  initializer action per declarator. The valid pre-edit gate was **317/319,
  2 FAIL**; final SemaAuthority is **319/319**, ProductionCodeGen **114/114**,
  and Parser declarations **18/18**. Global/field whole-node callbacks are
  absent and residual replay fails closed for those owners. Local declaration,
  general type/property/default/funcdef/lambda/body and expression/statement/
  lifetime adapters keep 13.2 unchecked.

  Progress 2026-08-27: CTA-S-14 migrates ordinary local declarations, `for`
  initializer declarations and `foreach` variable identity to exact typed
  actions. The valid pre-edit gate was **319/321, 2 FAIL**; final
  SemaAuthority is **321/321**, ProductionCodeGen **114/114**, and Parser
  declarations **18/18**. The successful fixture executes comma declarators
  and loop scope through Canonical CodeGen with `Entry() == 34`. No semantic
  `case snDeclaration:` decoder remains. General type/property/default/
  funcdef/lambda/body/expression/statement/lifetime actions and final CANONICAL
  independence from Builder/LEGACY facts keep 13.2 unchecked.

  Progress 2026-08-27: CTA-S-15 migrates class `default <statement>` to a
  typed start action, exact generated-method DeclContext and exact-range finish
  action. The valid pre-edit gate was **0/2**; final SemaAuthority is
  **324/324**, ProductionCodeGen **114/114**, and multiple defaults attach
  exactly once in source order. No `case snClassDefaultStatement:` remains.
  General type/property/access-group/funcdef/lambda/body/expression/statement/
  lifetime actions and final CANONICAL independence from Builder/LEGACY facts keep 13.2
  unchecked.

  Progress 2026-08-27: CTA-S-16 migrates the retained Parser funcdef shell to
  a typed signature action and exact parameter DeclContext. The valid RED was a
  test-only compile failure for the missing action API; final SemaAuthority is
  **326/326** and ProductionCodeGen **114/114**. No `case snFuncDef:` remains,
  while script rejection and host dynamic funcdef ABI are unchanged. General
  type/parameter/default/property/access-group/lambda/body/expression/
  statement/lifetime actions and final CANONICAL independence from
  Builder/LEGACY facts keep 13.2
  unchecked.

  Progress 2026-08-27: CTA-S-17 migrates `snAccessDeclaration` semantics to a
  typed complete-declaration action and exact record-local member edges. The
  valid RED is a test-only compile failure for the missing AST/action/public/
  sidecar contract; final SemaAuthority is **329/329**, traversal **6/6**,
  Sidecar **18/18**, Snapshot **10/10**, and ProductionCodeGen **114/114**.
  No `case snAccessDeclaration:` remains. General type/parameter/default/
  property/lambda/body/expression/statement/lifetime actions plus Canonical
  Runtime installation and final CANONICAL independence from Builder/LEGACY
  facts keep 13.2 unchecked.

  Progress 2026-08-27: CTA-S-18 migrates ordinary/import/interface/funcdef
  parameter headers to one pointer-free action with an exact callable DeclId.
  The valid pre-edit gate was **329/331, 2 FAIL**; final SemaAuthority is
  **331/331**, ProductionCodeGen **114/114**, and Parser declarations
  **18/18**. `ActOnParsedParam` is absent, malformed defaults no longer erase
  complete parameters, and authored virtual-property syntax remains rejected.
  General type/default/property/lambda/body/expression/statement/lifetime
  adapters plus final CANONICAL independence from Builder/LEGACY facts keep
  13.2 unchecked.

  Progress 2026-08-27: CTA-S-19 migrates all declaration-site type syntax to
  one pointer-free action. The valid pre-edit RED is the test-only compile
  failure for the missing action/API; final SemaAuthority is **333/333**,
  ProductionCodeGen **114/114**, Parser declarations **18/18**, and Frontend
  Type **20/20**. Parser now has zero `ActOnQualTypeFromNode` calls, while
  residual Sema lambda/property/expression/cast/construct type decoding plus
  default/body/expression/statement/lifetime adapters and final CANONICAL
  independence from Builder/LEGACY facts keep 13.2 unchecked.

  Progress 2026-08-27: CTA-S-20 migrates primitive functional-cast and object-
  construction target types to exact Parser-published local QualTypes. The
  valid pre-edit run was **333/335, 2 FAIL**; one assertion was the intended
  architecture RED and one exposed unsupported scalar `cast<T>` fixture
  spelling, corrected to `double(...)` without a production change. Final
  SemaAuthority is **335/335**, ProductionCodeGen **114/114**, Parser
  declarations **18/18**, Frontend Type **20/20**, Conversions **17/17** and
  Expression Chain **1/1**. Parser/expression Sema contain no node-to-type
  decoder, but lambda/property/default/body/general expression/statement/
  lifetime adapters and final CANONICAL independence from Builder/LEGACY facts
  keep 13.2 unchecked.

  Progress 2026-08-27: CTA-S-21 removes completed-lambda header replay,
  mutable `lastActedDecl` body ownership and the final generic node-to-type
  decoder. The valid pre-edit build failed for the missing action/API; final
  SemaAuthority is **337/337**, TypeSema **1/1**, Parser declarations
  **18/18**, ProductionCodeGen **114/114**, and Frontend Type **20/20**.
  Declaration Sema direct Parser-node references fall from **80** to **49**,
  but contextual lambda inference, property/default/body/general expression/
  statement/lifetime adapters and final CANONICAL independence from
  Builder/LEGACY facts keep 13.2
  unchecked.

  Progress 2026-08-27: CTA-S-22 removes the last generic whole-tree
  declaration entry rather than adding another compatibility flag. Permanent
  API-surface tests prove both public replay methods are absent; a forbidden-
  symbol scan also proves Parser/Sema have no callback, action counter or
  replay walker. SemaAuthority is **339/339**, the four-group regression matrix
  is **152/152**, and declaration Sema direct node references are **25**.
  Explicit property/default/body plus general expression/statement/control/
  lifetime adapters and LEGACY `asCCompiler` still prevent 13.2 closure.

  Progress 2026-08-27: CTA-S-23 replaces lambda expression and bare-statement
  semantic replay with one pointer-free action and exact transient ExprId
  identity. The old node adapter and duplicate body attachment are absent;
  native `ParseLambda`/`snFunction` construction remains intentionally covered.
  SemaAuthority is **341/341**, native ScriptNode shape **14/14**, Parser
  declarations **18/18**, and ProductionCodeGen **114/114**. The direct node
  inventory is declaration/expression/statement/core **22/41/20/7**; the core
  node references are identity-only bindings. Remaining expression/statement/
  control/lifetime adapters and final CANONICAL independence keep 13.2 open.

  Progress 2026-08-28: CTA-S47 removes the last dead native-node text/range/
  scope walkers and unused `as_scriptnode.h` dependencies from the completed
  declaration/expression/statement Sema units. A clean **0/1 RED** preceded
  the deletion; final build, focused **1/1**, and complete SemaAuthority
  **397/397** are green. The remaining `as_sema.cpp/.h` node references are
  classified as build-local pointer/section/token identity maps to already-
  created Canonical IDs, not child-walking semantic replay. Parser, Builder
  and LEGACY body reparse still use them, so their pointer-free replacement,
  the complete Sema environment, backend facts and final AST-first matrix keep
  13.2 unchecked. Evidence:
  `attachments/canonical-sema-native-node-dependency-audit-2026-08-28.md`.

  Progress 2026-08-28 (CTA-S48): exact primitive property-out semantics are
  now a sealed `DeferredOut` call-edge plan, not a getter-shaped expression
  interpreted by CodeGen. The verifier checks exact setter/type/receiver
  ownership and rejects a forged non-setter with stable token
  `deferred-out-setter`; the dump exposes setter and receiver. Complete
  SemaAuthority is **391/391 PASS** and complete ProductionCodeGen is
  **113/113 PASS**. Pointer-free replacement of the remaining build-local
  identity maps plus the other lifetime/backend families keep 13.2 unchecked.
  Evidence:
  `attachments/canonical-deferred-property-out-writeback-gate-2026-08-28.md`.

  Progress 2026-08-29 (CTA-S54): CTA-S47's residual pointer/coordinate map is
  superseded by a pointer-free, copied, exact build-local parse-action
  identity. Canonical Sema no longer declares, stores, or decodes
  `asCScriptNode`; native syntax ownership stays in Parser/LEGACY. Exact range
  semantics exposed and repaired two hidden timing bugs: cast/construct target
  types were bound before the expression range finished, and declaration
  wrappers were queried after their early range grew. Deterministic conflict
  diagnostics, final SemaAuthority **405/405**, and cross-consumer
  ProductionCodeGen/Module Snapshot/TypedASTJIT **186/186 PASS** close that
  identity-storage issue. The full scope/type/call/lifetime/control Sema
  environment, language-family coverage, mechanical-only backend proof, and
  final AST-first matrix still keep 13.2 unchecked. Evidence:
  `attachments/canonical-pointer-free-parse-action-identity-gate-2026-08-29.md`.

  Progress 2026-08-29 (CTA-S65): Canonical declaration Sema no longer observes
  the mutable Engine type registry while resolving ordinary named/qualified
  host types or authored host bases. Sema snapshots stable declaration facts
  at its translation-unit boundary, lexical declarations win before copied
  facts, and late registrations are visible only to a new Sema generation.
  Two lifecycle tests changed from **0/2 RED** to **2/2 GREEN**; final
  SemaAuthority is **425/425** and the five-surface consumer matrix is
  **224/224 PASS**. This does not close 13.2: expression enum-scope lookup,
  build-only `PreClassData::ShadowType`, remaining full scope/call/lifetime
  authority, mechanical-only backend proof and the final AST-first matrix stay
  open. Evidence:
  `attachments/canonical-registered-nominal-declaration-snapshot-gate-2026-08-29.md`.

  Progress 2026-08-29 (CTA-S66): Canonical expression Sema no longer queries
  the mutable Engine type registry for registered `Enum::Value` literals. The
  pointer-free Sema-generation snapshot owns the enumerator spelling and
  signed value; an old translation unit cannot observe a late registration,
  while a new Sema generation can. The causal gate changed from **0/1 RED** to
  **1/1 GREEN**; final SemaAuthority is **426/426** and the five-surface
  consumer matrix is **224/224 PASS**. This does not close 13.2: build-only
  `PreClassData::ShadowType`, automatic import/native expression symbol
  projections, remaining full scope/call/lifetime authority,
  mechanical-only backend proof and the final AST-first matrix stay open.
  Evidence:
  `attachments/canonical-registered-enum-literal-snapshot-gate-2026-08-29.md`.

  Why this is the real compiler work: 4.2–5.9 cannot complete without it. CodeGen/Cache/JIT on the current graph would freeze wrong types and first-name overloads into native code.

- [x] 13.3 <!-- TDD --> R03 identity: replace `parent::name` keys with complete stable signature + owner identity. Runtime FunctionKey↔AST mapping must reject ambiguous or signature-mismatched matches. Tests: global/method/constructor/operator/mixin/namespace overloads and multiple lambdas.

  Why before JIT/Cache: name-first binding can emit the wrong body for the right FunctionKey.

  Closed 2026-08-23: direct canonical CodeGen and the current staged UE compile bridge carry the exact sealed declaration stable key on every produced `asCScriptFunction`; the staged bridge uses the live parse-node pointer or an exact logical-section/token-offset fallback for reparsed lambdas and rejects ambiguous coordinates. `asCRuntimeTypeBridge::BindFunctionDeclaration` first resolves one exact stable key and then verifies owner, namespace, return, parameter types/directions, method constness, and lambda captures. StaticJIT consumes this exact binding; Cache V2 validates all restored declaration/function pairs before committing any Runtime keys. Lifecycle declarations now seal with canonical `void`. Identity **11/11**, Cache ExactWarm **15/15**, CanonicalAST **354/354**, Compiler **544/544**, and Standalone **21/21**. The default compiler remains LEGACY, and its compatibility reconstruction remains available, but canonical producers no longer perform name-first or lambda-rank reconstruction. TDD trail and non-claims: `attachments/canonical-function-decl-identity-gate-2026-08-23.md`.

- [x] 13.4 <!-- TDD --> R07 arena and seal: slab/bump ownership, construction APIs separate from sealed const traversal, no public `DestroyAll` reseal, no mutable Context on snapshot surfaces.

  Closed 2026-08-21: construction catalog + const-only public `Get*` + privately named `Mutable*`. Sema free helpers use `const asCSourceManager&` / `AddSourceSection`. Evidence: `wave-c-construction-frontend` 58/58, `wave-c-construction-hotreload` 5/5, `wave-c-construction-cutover` 5/5. See `attachments/wave-c-results.md`.

- [x] 13.5 <!-- TDD --> R08 verifier firewall: stmt/expr indices, operand kinds, parent/child ownership, cycles, control targets, types/value categories, resolved signatures, cleanup plans, sealed publication. Seal must fail before any consumer sees an incomplete graph.

  Closed 2026-08-21: remainder landed — stmt-multi-owner, stmt-cycle, fallthrough-switch, CLEANUP dtor-when-set, `asCASTVerifyPublication` / `UNSEALED_PUBLICATION`. `asCASTVerify` still OK on unsealed construction graphs. CALL-without-callee not required. Full signature compatibility and stable cross-module refs stay later Sema/Wave F work, not a reason to keep this firewall box open. Evidence: `wave-c-28-green` 13/13, Frontend 63/63, Compiler CanonicalAST 37/37.

  Refreshed 2026-08-24: the missing script-field layout negative now locks the
  strengthened firewall end to end: exact offending field, `decl-parent` edge,
  owning class, `class-field-layout`, Seal rejection, then CodeGen
  `UNSEALED_PUBLICATION`. Complete Compiler CanonicalAST is **389/389**. See
  `attachments/wave-b-field-offset-fail-closed.md`.

- [ ] 13.6 <!-- TDD --> R09 + production CodeGen: `asCBytecodeCodeGen::Generate` is the canonical `Build()` backend; accept only Frozen/Publishable AST plus the verifier-authenticated Canonical lifetime protocol/shared derived view; emit a detached artifact; resolve section 14's stable type/property/function relocations and Runtime binding view; install executable + snapshot + identity + bindings atomically; roll back type/funcdef/global/function mutations on failure. This is restored 9.1/9.5/10.4. **Gate 0 applies:** every newly supported lowering form must first prove its sealed AST shape/type/callee/control/lifetime contract; execution tests then prove the backend consumes that already-green graph without selecting cleanup actions or reclassifying lifetime.

  Progress 2026-08-29: Approach A Tasks 1–4 are complete. Exact sealed method
  edges survive Sidecar V8 and drive detached interface-shell/dispatch
  publication plus read-only Prepared Stage 1/2 authentication. The final
  post-Hot-Reload matrix is build PASS, ProductionCodeGen **135/135**, Compiler
  CanonicalAST **614/614**, Frontend **175/175**, Module Snapshot **10/10**,
  StaticJIT primary **12/12**, Hot Reload **12/12**, interface Sema **6/6** and
  interface Runtime **9/9**. Dynamic TypeId/pointers remain generation-local;
  producer stable keys and a current-generation transient view prevent old
  Hot Reload types from becoming identity. Full-language detached publication,
  remaining declaration categories and final cutover keep 13.6 unchecked.
  Final prepared-path plugin commit is `e474dc4`. Evidence:
  `attachments/canonical-interface-publication-gate-2026-08-29.md`.

  Progress 2026-08-30: custom access metadata now has a private staged
  preparation boundary inside the prepared class: all DTOs validate/allocate
  before one aggregate swap, and exact field/method borrowers authenticate
  before their own member-shell publication. Numeric Runtime pointers remain
  generation-local bindings. This is not detached CodeGen, a per-class
  member-set transaction or the full module-wide type/funcdef/global/function
  transaction. Task 13.6 therefore remains unchecked. Final focused
  ProductionCodeGen is **150/150**; the latest broad Compiler CanonicalAST is
  **631/631** and Frontend CanonicalAST is **175/175**.
  Evidence:
  `attachments/canonical-access-specifier-runtime-projection-transaction-gate-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S70): the reachable UE per-module Stage 2 failure
  lifecycle is now fail-closed. Failed candidates skip their own reference
  collection/diff, class/destructor layout, global allocation and function
  layout; Stage 3 performs deterministic Builder release without Seal,
  CodeGen, AST publication or JIT. Failed Layout/CompileCode milestones remain,
  Globals is absent, generation A remains executable, and same-name generation
  C retries successfully. A natural CANONICAL mutable-global rejection
  previously crashed in `BuildAllocateGlobalVariables` on a null property and
  is now a permanent regression. Build PASS, BuilderIntegration **4/4**,
  Compiler Events **7/7**, project Compiler **83/83** and ProductionCodeGen
  **150/150**. Engine-global deferred template validation and indirect
  replacement writes in a mixed success/failure batch remain a separate
  transaction gate, so 9.1/9.5/10.4/13.6 stay unchecked. Plugin commit:
  `9cba53b`. Evidence:
  `attachments/ue-stage2-failed-candidate-abandon-gate-2026-08-30.md` and
  `reviews/ue-stage2-failed-candidate-lifecycle-review-2026-08-30.md`.

  Progress 2026-08-30 (CTA-S71): the mixed success/failure UE transaction now
  restores every suppressed generation-A module to Engine lookup after all
  candidates are reset, skips old-to-new reflection replacement for candidates
  already known to be failed, and tracks exact requesting-module provenance for
  deferred template instances. Healthy/shared/unknown requests still receive
  size/validation work; newly created failed-only instances are quarantined,
  safely retired after candidate rollback and removed from the non-owning raw
  queue. A batched **3/6** RED closed at BuilderIntegration **6/6**; build PASS,
  Compiler Events **7/7**, project Compiler **85/85**, ProductionCodeGen
  **150/150**, HotReload **12/12**, Compiler CanonicalAST **631/631** and
  Frontend CanonicalAST **175/175**. Public AST/Cache identity is unchanged,
  HIR/dump input remains absent, LEGACY/native AST remains retained and
  Standalone is excluded. This closes the CTA-S70 recorded mixed-batch/template
  sub-boundary, not the full detached/full-language 13.6 sentence. Evidence:
  `attachments/ue-mixed-batch-template-replacement-transaction-gate-2026-08-30.md`
  and `reviews/ue-mixed-batch-template-replacement-review-2026-08-30.md`.

  Why this is still open: CANONICAL `Build()` now calls `Generate()`, but 9.5 is still a subset (ProductionCodeGen **59/59** is not the spec sentence — stored capturing closures / exception tables / full language remain). Candidate script-function slots, global-init functions, imports, global properties, and script object types are now deferred until `Commit()`; funcdefs and other declaration forms are not yet detached/complete. `Build()` no longer destroys the active generation before a Canonical candidate is known good: it now stages in a private owner and promotes with allocation-free container swaps after a successful candidate commit. That resolves the old module-replacement loss, but does not prove the full task. `Commit()` skips `objectType != 0` from global function lists. F1 empty-`functionDecls` is install-or-fail-closed, not a detached artifact. Do not check 9.1/9.5/13.6/10.4 from ProductionCodeGen 59/59 or Cutover 5/5.

  Progress 2026-08-23: the candidate-rebuild regression set is **3/3 PASS** (failed rebuild keeps executable A; successful function and same-name type generations replace through the same public module pointer). Explicit qualified automatic imports bridge committed script functions by marked, exact-signature binding. They now also bind an explicit qualified script global only to the unique already-published provider property; the consumer never creates a duplicate global. Bytecode reference installation records an exact `asCGlobalProperty` lease for every emitted provider-address instruction, so provider `Discard()` plus forced GC keeps the property/address map alive until the consumer is discarded, after which ordinary engine GC reclaims it. The production regression executes that complete sequence and passes; focused ProductionCodeGen is **64/64**, Cache `ASTBodySidecar+ExactWarmStartup` is **16/16**, and the Runtime/Editor build succeeds. This is deliberately only a direct, unique, explicit-namespace automatic-import route: ambiguity remains fail-closed; writes, richer initializer/lifetime forms, imports across cache restore/reload generations, funcdefs, and the complete language remain open. A broad native SDK run is **1208/1218**: its ten failures are pre-existing Canonical coverage/compatibility gaps (eight failed compile-to-snapshot forms plus enum-alias metadata and typedef-boundary expectations), not failures on the new property-reference route. Evidence: `attachments/canonical-module-candidate-replacement-design-2026-08-23.md`, `attachments/canonical-codegen-transaction-rollback-2026-08-23.md`, `attachments/canonical-automatic-import-script-global-lifetime-2026-08-23.md`, and current transaction matrix **17/17 PASS**. This remains a partial 13.6 closure only.

  Progress 2026-08-24: the host funcdef indirect-call slice is now consumed
  from an AST-first verified graph and complete ProductionCodeGen is **73/73**.
  The result does not establish detached funcdef declaration publication,
  Commit fault coverage, cache replay, or the remaining full-language forms;
  Task 13.6 therefore remains open.

  Progress 2026-08-24: reference-object return epilogues now consume the sealed
  type fact to select `LOADOBJ`; exact property/index compound mutations and the
  complete **73/73** ProductionCodeGen group execute successfully. The complete
  CanonicalAST gate is **365/365**. This strengthens the backend ABI slice but
  does not close detached publication, all commit phases, Cache V2 replay, or
  the remaining full-language forms.

  Current transaction proof is refreshed at
  `attachments/canonical-codegen-emission-failure-gate-2026-08-23.md`: its
  three post-first-body failures cover a normal type/function candidate, an
  import candidate, and class-method/type ownership. It now also tests failure
  after every currently implemented Commit phase (type/global/import/function
  publication). The hooks are test-only; this still does not establish
  per-item Commit fault coverage, funcdef coverage, or the full spec sentence.

  Progress 2026-08-24: `GenerateFunction` reuses the detached artifact for the
  public single-function boundary. Attached commit transfers a direct function
  plus nested lambda closure into module ownership; detached commit installs
  Engine IDs without module mutation. A rejected compile proves exact Engine
  slot/free-ID, module inventory, executable generation, and snapshot rollback;
  attached/detached capturing lambdas both execute. The incomplete source unit
  receives a CompileFunction-only projection of exact current-module functions
  and globals, which CodeGen binds back to existing Runtime objects without
  artifact ownership or publication. Cutover is **11/11**, the focused original
  lifecycle pair is **2/2**, and the new function/global binding gate is **1/1**.
  This closes the CompileFunction slice, not the remaining full-language 13.6
  sentence.

  Progress 2026-08-24: canonical class registration now consumes the sealed
  `PreClassData` prefix/field/extent/alignment facts and fails candidate
  publication if the current embedding map disagrees. It attaches
  `basePropertyOffset`, `ShadowType`, and initial user data only after that
  check. The exact public contract and complete Module ApiContracts are green
  (**1/1**, **8/8**), and ProductionCodeGen remains **73/73**. This removes a
  CodeGen-side layout-authority gap but does not complete all declaration,
  lifetime, debug, or transaction forms. Evidence:
  `attachments/canonical-preclass-layout-gate-2026-08-24.md`.

  Progress 2026-08-24: the detached Canonical candidate now lowers sealed
  `asAST_STMT_FOREACH` through the existing structured loop emitter; it does
  not rediscover protocol methods. The permanent production test executes
  `CanonicalForeachSum() == 41` and keyed result `65`, requires the canonical
  publisher, and proves zero legacy compiler calls. ProductionCodeGen is
  **82/82**. This advances
  the supported backend subset but does not complete detached publication for
  all declaration/lifetime forms, full-language lowering, default cutover, or
  physical HIR removal. Evidence:
  `attachments/canonical-foreach-protocol-gate-2026-08-24.md`.

  Progress 2026-08-25: the detached candidate backend now consumes the sealed
  value-object iterator cleanup phase. It uses only a Sema-proven exact
  storage-copy trait, emits the exact destructor before a post-loop call after
  `break`, handles return/nested transfer cleanup, and prevents epilogue double
  destruction. The focused gate and complete ProductionCodeGen **83/83** are
  green; complete CanonicalAST is **392/392**. This remains a partial 13.6
  closure because all declaration/lifetime/exception/metadata families,
  staged UE publication, default cutover, and physical HIR removal are not all
  complete.

  Progress 2026-08-22: Wave D Tasks 6–10 integer routing plus 9.5 named rows through capturing IIFE and selected-overload CALL, then F1–F5 ABI/execute slices (ProductionCodeGen **33/33** `wave-d-f4-prod3`; F5 Legacy **2/2** `wave-d-f5-exec`). `Ready()` true because CANONICAL `Build()` calls `Generate()`. Default pipeline LEGACY. `CompileFunction` stays Compiler. Do not mark 9.1/9.5/13.6/10.4. Do not flip default CANONICAL (Wave G). Current exclusive UBT is body attach intern (`attachments/wave-b-body-attach-next.md`).

- [x] 13.7 <!-- TDD --> R05 public ABI: move module AST methods off the mid-vtable insertion (extension interface or append-only). Honor caller `structSize`/`apiVersion`. If the broken vtable already shipped in this worktree, call out product version / compatibility explicitly. Tests: smaller-view canary, incompatible version rejection, foreign-snapshot IDs.

  Closed 2026-08-23: `asIScriptModule` AST methods are trailing slots; snapshot traversal methods are appended to the new snapshot interface. Views reject undersized output buffers before writes, request an explicit incompatible API version with `asNOT_SUPPORTED`, and reject foreign snapshot IDs before version negotiation. The attached ABI note calls out that a separately distributed old incomplete V1 binary would require a release-level compatibility audit rather than a claim of binary compatibility. Evidence: `attachments/public-ast-v1-semantic-snapshot-contract-2026-08-23.md`, final Snapshot group **8/8**.

- [ ] 13.8 <!-- TDD --> R06 snapshot protocol: construct and verify the new snapshot before publication; atomic exchange; Acquire retains in the same protocol; atomic current-generation; documented CompileFunction completeness; generation holds both its `asIASTSnapshot` and immutable Runtime type-resolution/binding lifetime. Tests must race Acquire vs publish, retain old same-name/different-layout type revisions safely, and keep the complete last-good executable + snapshot + bindings generation on failed publish. **Gate 0 applies:** snapshot/view/lease semantics are asserted before any VM/Cache execution result is used as evidence.

  Progress 2026-08-23: a retained Canonical source-build generation now has a direct failed-rebuild regression: after generation B is rejected, the held A lease remains current and a fresh `AcquireASTSnapshot()` returns A's generation key. The public snapshot group also includes the 64-generation concurrent Acquire-vs-successful-rebuild stress test and failed-build concurrent-reader test; it is currently **9/9 PASS**. Cache Exact Startup applies the same staging-before-swap principle and the AST sidecar/ExactWarm/root-class/inheritance regression bundle is **18/18 PASS**. The last runtime Cache raw-context consumer (`TryCaptureCanonicalASTBodySidecar`) now holds a V1 snapshot lease while serializing; a full Runtime/Editor production search leaves raw `GetCanonicalASTContext()` calls only in CanonicalAST white-box tests. The source-contract red/green, Standalone **21/21**, and Cache ASTBodySidecar+ExactWarm **16/16** evidence is in `attachments/snapshot-publication-protocol-audit-2026-08-23.md`. This does not check 13.8: `CompileFunction` still has no complete AST-generation construction protocol, and final cutover still requires a multi-publisher/default-path audit rather than assuming the current consumer set is permanent. Earlier evidence: `attachments/canonical-module-candidate-replacement-design-2026-08-23.md`, `Saved/Tests/cta-canonical-failed-rebuild-snapshot-green/20260823_141051_644_63c57e0f/RunMetadata.json`, `Saved/Tests/cta-canonical-ast-snapshot-protocol-regression/20260823_141308_622_80ee531e/RunMetadata.json`, `Saved/Tests/cta-cache-canonical-ast-retention-regression/20260823_140744_031_a44db1d8/RunMetadata.json`.

  Progress 2026-08-24: the missing `CompileFunction` policy is now explicit and
  tested. Its ephemeral AST is complete only for the emitted function closure:
  attached success retires the module snapshot, detached success preserves it,
  and failure keeps the prior generation current and freshly acquirable. The
  held old lease stays immutable in every case. Exact public API/snapshot is
  **2/2 PASS** and Cutover is **11/11**. Cache V2 restoration is excluded from
  this compiler change; the remaining 13.8 decision is the final multi-publisher
  audit, not cross-Engine cache recovery.

  Progress 2026-08-25: the real Hot Reload publisher now participates in this
  audit. Successful A-to-B replacement retires A while its held lease remains
  valid, publishes B as current with a changed exact AST digest, and executes
  B. Rejected generation C keeps B's publisher, digest, generation key, and
  executable body. The permanent gate is **1/1 PASS** and the complete Hot
  Reload CanonicalAST group is **6/6 PASS**. Task 13.8 remains open only for
  the final combined multi-publisher/default-path audit.

  Progress 2026-08-27: the core module/HotReload/runtime-binding aggregate is
  freshly green: Module Snapshot **9/9**, HotReload CanonicalAST **12/12**,
  Canonical CodeGen Transaction **20/20**, RuntimeTypeBinding **10/10**, and
  Frontend CanonicalAST **140/140**. Failed Runtime resolution and injected
  snapshot preparation now explicitly preserve generation A's exact immutable
  binding row/table in addition to its executable, snapshot, generation key
  and TypeId projection. This closes the core R06 facts but not the full task:
  StaticJIT generation, commandlet, Standalone, explicit restore and the final
  default source-build route still require the combined publisher audit. See
  `attachments/final-completion-issue-log-2026-08-27.md` (`CTA-SNAP-01/02`).

- [x] 13.9 <!-- Non-TDD --> R04 Cache boundary: preserve the pointer-free FunctionBody-linked DTO/ExactStartup prototype and its existing fidelity tests, make Cache V2 default-off with a complete lifecycle bypass, and defer unfinished cross-Engine remap/import/incremental/downstream-consumer closure to a later Cache V2 redesign. This check records scope containment, not full implementation of the superseded Cache DTO production requirement.

  Progress 2026-08-23: Cache ExactStartup now has a direct byte-fidelity gate:
  it takes the actual linked `ASTBodySidecar` record from the validated
  generation and requires a new Engine's retained public snapshot to re-encode
  to exactly the same pointer-free DTO bytes before any execution assertion;
  the current ExactStartup run is **15/15 PASS** and has zero
  frontend/publication work. Its unremappable-type negative proves a
  target-Engine stable type key is validated after private materialization and
  before activation. Its declaration gates now prove both that every decoded
  declaration re-derives its stable key (including a non-body enum) and that a
  body-owning source declaration finds one target staging skeleton. The
  verifier-invalid graph lifecycle route is also covered. Clean complete-module
  capture still rejects import declarations, so import replay needs a new
  Cache V2 capture/restore shape rather than a false claim of existing support;
  verified CodeGen/native consumption also remains open. Under the original
  Cache-production scope this review requirement therefore remained open.

  Progress 2026-08-24: schema V3 is now aligned end-to-end between the
  maintained encoder, Runtime wrapper, FunctionBody optional link, header
  inspection, and ExactWarm adversarial fixtures. Focused evidence is
  FunctionBody **5/5**, ASTBodySidecar **12/12**, and ExactWarmStartup
  **15/15**. The three negative declaration/verifier fixtures had previously
  failed before mutation because their old cursor omitted V3's 64-bit constant
  tail; they now reach and prove the intended pre-activation restore firewall.
  Details: `attachments/cache-v2-sidecar-schema-v3-alignment-2026-08-24.md`.
  Imports, incremental dependency closure, and complete downstream backend
  consumption remain unproven and are deliberately carried into the later
  Cache V2 redesign. The 2026-08-24 check closes only the default-off
  containment/scope decision now stated by 13.9.

- [x] 13.10 <!-- TDD --> R10 SourceManager truth: Lexer/Parser/Sema/diagnostics/backend coordinates; remap validates content identity; public/cache views persist the source model.

- [x] 13.11 <!-- TDD --> Adversarial tests from the review rereview matrix: same-index foreign IDs, smaller public views, concurrent Acquire/publish, failed publication keeps previous executable/snapshot/Runtime bindings, CodeGen failure leaves no module mutation, different Engines assign different numeric type IDs to the same stable type, same-name Hot Reload revisions keep distinct ABI/runtime bindings, and hash/display-name aliases fail closed.

  Progress 2026-08-24: the public CompileFunction boundary now has a permanent
  failure-before-publication test that compares the complete Engine function
  slot table/free-ID stack, module inventory, old executable identity, digest,
  and retained snapshot generation. It passes together with the nested closure
  ownership test (**2/2**); the additional current-module symbol-view gate is
  **1/1** and proves no function/global inventory duplication. Other adversarial rows remain governed by their
  public-view/verifier/snapshot groups and need one fresh combined audit before
  13.11 is checked.

  Progress 2026-08-25: Hot Reload now adds a direct failed-publication row:
  malformed generation C cannot replace the active B snapshot, digest,
  publisher, or executable body, and it cannot enter a legacy fallback. This
  is green together with the successful A-to-B lease transition. A fresh
  combined audit of the remaining foreign-ID, small-view, concurrency, and
  detached-CodeGen rows is still required before 13.11 is checked.

  Closed 2026-08-27: the fresh combined audit covers every named row. Module
  Snapshot is **9/9**, HotReload CanonicalAST **12/12**, Canonical CodeGen
  Transaction **20/20**, RuntimeTypeBinding **10/10**, and Frontend
  CanonicalAST (including Type/TypeIdentity) **140/140**. The failed-generation
  fixture additionally pins the exact immutable Runtime binding count and row
  across Runtime-resolution and snapshot-preparation failures. The three
  candidate-publication snapshot fixtures were first observed RED under the
  restored LEGACY default, then repaired to select CANONICAL explicitly; their
  focused runs and full group are green without changing the default. Evidence
  and RED/GREEN paths: `attachments/final-completion-issue-log-2026-08-27.md`
  (`CTA-SNAP-01/02`).

- [ ] 13.12 <!-- Non-TDD --> After 13.1–13.11 and section 14, rerun focused SDK/Cache/HotReload/StaticJIT, then All. Do not re-check section 10 from compatibility prefixes alone. Standalone Debug/Release is explicitly deferred to a separate future OpenSpec and is not a completion gate here.

## 14. Canonical type identity and Runtime-install boundary

- [x] 14.1 <!-- TDD --> Add `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTTypeIdentityTests.cpp` and extend `AngelscriptNativeCanonicalASTTypeTests.cpp` with an AST-first identity matrix. Prove: same complete type+qualifiers intern once inside one snapshot; numerically equal `asASTTypeRef` values from different snapshots are foreign; enum/funcdef/template/value/reference kinds and template arguments cannot alias through display spelling; two Engines may assign different numeric type IDs to the same stable type; a hash collision/incomplete spelling cannot pass complete-key equality. Keep `asCType/asCQualType` free of Engine pointers and numeric IDs. RED preceded the `as_ast_context.cpp` owner check. Fresh focused evidence is Type/TypeIdentity **19/19 PASS**; the broader Frontend run's pre-existing 11 CodeGen/Verifier failures are recorded in `reviews/implementation-progress-2026-08-27.md` and remain gates for 14.6/12.2.

  **Files/interfaces:** modify only the maintained-frontend `as_ast_type.h/.cpp`, `as_ast_context.h/.cpp`, and `as_runtime_type_bridge.h/.cpp` as required. `asASTTypeRef` remains snapshot-local. Durable equality is complete type kind + canonical stable key/structure; qualifier equality remains `asCQualType`'s packed mask. A hash is an index accelerator and must be followed by complete equality.

- [x] 14.2 <!-- TDD --> Add `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalRuntimeTypeBindingTests.cpp`, then add maintained-fork `as_runtime_type_binding.h/.cpp` and list the `.cpp` in `Plugins/Angelscript/Standalone/CMakeLists.txt`. Define an internal target/profile compatibility key and immutable generation-local binding table that maps complete stable type identity to the candidate Engine's `asCDataType`, `asCTypeInfo*`, layout/behaviours, property/function targets, and current numeric type-ID projection. Prove exact success plus missing, ambiguous, wrong-kind, wrong-profile, wrong-native-environment, and layout/ABI mismatch results. The table must freeze before publication and must not expose Engine pointers through Public AST or DTO views. Run the focused Compiler CanonicalAST prefix and `Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix canonical-runtime-type-binding -TimeoutMs 600000`.

  **Interfaces:** `asSTypeABIKey` is a complete expected compatibility value, not only a hash; `asSTypeRelocation` names stable type/member identity plus use kind and artifact operand; `asCRuntimeTypeBindingTable::Build(...)` is validate-all/commit-none and returns a stable result category. Published tables are immutable and owned by one module/function generation. Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.RuntimeTypeBinding" -Label canonical-runtime-type-binding -TimeoutMs 600000` before the Standalone gate.

  Progress 2026-08-27: `as_runtime_type_binding.h/.cpp`、Standalone source listing、exact bridge resolver 和 10 项 acceptance matrix 已实现。两个 RED 分别证明 string-only wrong-kind 接受（0/1）与 hash 被错误当作 equality authority（9/10）；最终 focused RuntimeTypeBinding **10/10 PASS**。`Build` 使用 pending array 做 validate-all/commit-none，成功 freeze，映射完整 layout/member/behaviour signature、property/function target 和 current public ID；`asSTypeRelocation` 不含 pointer、numeric typeId 或 snapshot-local TypeRef。Standalone 同源 fork 编译/链接成功，但 CTest 为 **8/21 PASS**：当前 worktree 已把 Engine 默认设为 CANONICAL，而 Standalone 仍断言 LEGACY，且 array/member Sema、HIR publication、部分 CodeGen/cleanup cutover 尚未闭合。该 gate 不豁免，故 14.2 保持 unchecked；详见 `reviews/implementation-progress-2026-08-27.md`。

  Closed 2026-08-27: supported-runner reproduction confirmed that the earlier
  **8/21** Standalone result was caused by a premature product-wide CANONICAL
  constructor default, not by the Runtime binding table. Restoring the
  migration-phase LEGACY default returned Standalone to **21/21 PASS** while
  explicit Canonical Cutover remained **12/12 PASS**. Fresh focused
  RuntimeTypeBinding is **10/10 PASS** at
  `Saved/Tests/cta-runtime-type-binding-after-standalone-repair/20260827_045712_422_fc785665/Report/index.json`.
  RED/root-cause/GREEN evidence is recorded in
  `attachments/final-completion-issue-log-2026-08-27.md`. This closes the
  immutable binding-table task only; Task 10.2 remains open. Task 14.6 was
  closed later by its complete boundary matrix.

- [x] 14.3 <!-- TDD --> Extend `as_bytecode_codegen_artifact.h`, `as_bytecode_codegen.cpp`, and Canonical ProductionCodeGen transaction tests so every canonical type/property/function dependency required after emission has an `asSTypeRelocation` carrying stable identity, expected `asSTypeABIKey`, use kind, owning function and operand location before installation. Classify uses as metadata-only, Runtime-type target, or public numeric-ID projection. Candidate installation SHALL resolve the complete relocation set before `Commit()` publishes any Engine/module entry; it may then patch active bytecode to pointers, offsets, slots, or the current numeric ID. Inject one failure for each relocation class and prove `Abandon()` leaves Engine slots/free lists, module inventories, executable publisher/digest, AST snapshot, generation key, and Runtime bindings byte-for-byte/logically unchanged. Run the complete ProductionCodeGen group and transaction matrix.

  **Files/tests:** modify `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen_artifact.h`, `as_bytecode_codegen.h/.cpp`, `as_runtime_type_binding.h/.cpp`, and the existing Canonical CodeGen transaction tests; add `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalTypeRelocationTests.cpp`. Do not serialize candidate pointers or numeric IDs as relocation identity. Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label canonical-type-relocation -TimeoutMs 600000` and the existing focused transaction prefix recorded by Task 13.6.

  Evidence 2026-08-27: detached `typeRelocations`、frozen `runtimeTypeBindings`、candidate-local `Prepare/CommitPendingTypeIds`、exact target function ordinal，以及 metadata-only/Runtime-target/public-ID/property/function/list-pattern 六类 explicit relocation 已接入。新增 class-targeted injection，在 complete binding-table Build 之后、任一 operand patch/Commit 之前逐类失败；`EveryRelocationClassFailureKeepsCurrentGenerationUnchanged` 比较 Engine slots/free lists、type-ID sequence/map、module inventories、list helpers、publisher/digest、AST snapshot/current/generation key、Runtime binding count/fingerprint。矩阵 RED 进一步发现 wildcard `?&` call 丢失 hidden public TypeId；Canonical emitter 现发出 `TYPEID` placeholder 并通过 relocation 晚投影，生产 generic callback 验证 `GetArgTypeId(0)` 等于当前 Engine 的 `FPayload` ID。最终 transaction **20/20 PASS**、ProductionCodeGen **111/111 PASS**、Module Snapshot **9/9 PASS**、HotReload **12/12 PASS**。完整分类、fixture 探索中暴露但未掩盖的 Sema 问题、RED/GREEN 与报告路径见 `reviews/canonical-type-relocation-failure-matrix-2026-08-27.md`。

- [x] 14.4 <!-- TDD --> Integrate the immutable Runtime type-binding table into the aggregate module-generation transaction in `as_module.h/.cpp` and Hot Reload publication. Add `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptCanonicalRuntimeTypeGenerationTests.cpp` proving: generation A remains executable/traversable with its original type object/layout/public ID while same-nominal-type generation B publishes a different ABI revision; new readers use B; no A slot is retargeted; failed B resolution or snapshot publication keeps all of A current; final A resources and type-ID map dependencies release only after its last execution/snapshot lease. Run Module CanonicalAST Snapshot, HotReload CanonicalAST, and Canonical ProductionCodeGen transaction prefixes.

  **Publication contract:** `Generation = executable + sealed snapshot + stable identities + publisher/digest/provenance + immutable Runtime bindings`. Allocate, resolve, seal, verify, and failure-inject before the single publication exchange. `CompileFunction`, normal Build, Hot Reload, generation Engine, and any explicitly enabled restore path must each declare replace/retire/preserve behavior for this aggregate. Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Module.CanonicalAST.Snapshot" -Label canonical-runtime-type-generation-module -TimeoutMs 600000`, `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.CanonicalAST" -Label canonical-runtime-type-generation-hotreload -TimeoutMs 600000`, and the ProductionCodeGen transaction prefix.

  Evidence 2026-08-27: local artifact 的 frozen `runtimeTypeBindings` 已转移给 candidate `asCRuntimeTypeGeneration`；same-module replacement 通过预分配 retired carrier 保留 A 的 executable/type/global/import state；snapshot lease 和 external-function execution lease 共同保活旧代，且没有内部 ownership cycle。prepared-execution 与 concurrent current-publication 两个 RED 均先稳定失败，再由 execution lease 和 `astSnapshotLock` 下的 retire/promote/snapshot/current-marker 单点交换修复。最终 generation lifecycle **6/6 PASS**、HotReload CanonicalAST **12/12 PASS**、Module Snapshot **9/9 PASS**、ProductionCodeGen **111/111 PASS**、transaction **20/20 PASS**；统一 reset build 成功。完整 ownership、问题矩阵、RED/GREEN 与 discard/JIT/global 边界见 `reviews/canonical-runtime-type-generation-lifecycle-2026-08-27.md`。

- [x] 14.5 <!-- Non-TDD --> Keep `reviews/type-identity-runtime-boundary-reconciliation-2026-08-27.md` synchronized with the implementation inventory. Record every current `GetTypeIdFromDataType` CodeGen/VM/PrecompiledData site in one of three categories: metadata-only (`COPY`, property-owner metadata such as `ADDSi`/`LoadThisR`), Runtime type target (`Cast` and equivalent), or public-ID projection (`TYPEID`, `SetListType`, embedding APIs). This compiler change closes only canonical/durable identity and generation-install correctness. Do not remove every legacy operand, redesign public `int typeId`, or convert all `FAngelscriptPrecompiledData` references here. Record those as the required scope of a later `refactor-as-runtime-type-identity-relocation` OpenSpec; do not create or implement that follow-up without an explicit request.

  Evidence 2026-08-27: `reviews/type-identity-runtime-boundary-reconciliation-2026-08-27.md` section 11 records the canonical path, every direct legacy `as_compiler.cpp` call line, `as_restore.cpp` opcode groups, `StaticJIT/PrecompiledData.cpp` store/load/property sites, and embedding/reflection projections. It explicitly classifies `COPY` and property-owner operands as metadata-only, `Cast` as Runtime target, and `TYPEID`/`SetListType`/embedding APIs as public projections; the later OpenSpec scope is recorded but not created.

- [x] 14.6 <!-- Non-TDD --> Run and record the type-identity boundary gate before section 10 default cutover: Runtime/Editor build; Frontend CanonicalAST Type; Compiler CanonicalAST SemaAuthority + ProductionCodeGen + transaction groups; Module Snapshot; HotReload CanonicalAST; StaticJIT TypedASTJIT/generation identity; Cache V2 default-disabled boundary; and Standalone. Add source/determinism scans proving Public AST, diagnostic JSON/text, optional AST DTOs, Provider identity and detached relocation records contain no Engine pointer/numeric type ID/snapshot-local type ref as durable identity. Then run `openspec validate "refactor-as-canonical-typed-ast-compiler"` and `git diff --check`; this task does not replace section 12's final focused/All gates.

  Evidence 2026-08-27: Runtime/Game and Editor builds passed; Frontend Type **20/20**, SemaAuthority **301/301**, ProductionCodeGen **111/111**, CodeGen transaction **20/20**, Module Snapshot **9/9**, HotReload CanonicalAST **12/12**, StaticJIT CanonicalASTIdentity **12/12**, ProjectGeneration.Engine **32/32**, TypedASTJIT **70/70**, Cache SettingsAndShutdown/default-disabled **7/7**, and Standalone Debug **21/21** all passed. Generated-output/dump/structured-dump/diagnostic/ASTBodySidecar determinism groups are green. Durable source scans found zero forbidden Engine-pointer/numeric-TypeId/snapshot-local-ref identities in AST storage, emitted diagnostics, optional DTO/sidecar, Provider identity and detached relocations. The gate also repaired explicit Provider capture setup, per-Engine Cache enablement and `TArray<int>` default-array nominal late binding. Local `TArray<int>` default construction still exposes `DANGLING_ID construct-decl` and remains an explicit Sema/lifetime/lowering gap; it was not counted as fixed. Exact RED/GREEN paths, scan classifications and non-claims: `attachments/type-identity-boundary-gate-2026-08-27.md`. The compiler default remains LEGACY, Cache V2 remains default-disabled, and section 12 final focused/All gates remain open.

## 15. Canonical lifetime protocol and partial-construction closure (CTA-S53)

This section implements the B2 lifetime architecture approved on 2026-08-28.
It closes the shared semantic/proof boundary required by 5.7, 5.8, 7.5, 9.1,
9.5, 9.6, 13.2 and 13.6; it does not independently close those broader
umbrella tasks. The governing review is
`reviews/canonical-ast-vs-clang-lifetime-review-2026-08-28.md`; normative
requirements are in `design.md` and the Canonical AST, compiler pipeline,
TypedASTJIT and test spec deltas.

**Implementation map:** add maintained-fork `as_ast_lifetime.h/.cpp`; modify
`as_ast_context.h/.cpp`, `as_ast_verifier.h/.cpp`, `as_sema_lifetime.h/.cpp`,
`as_sema_stmt.cpp`, `as_ast_sidecar.h/.cpp`, `as_bytecode_codegen.h/.cpp` and
`StaticJIT/TypedASTJIT/AngelscriptTypedASTJITCanonical.cpp`; add or extend
Frontend/Compiler CanonicalAST and StaticJIT TypedASTJIT tests. Standalone
adaptation is explicitly deferred to a separate future OpenSpec: the existing
20/20 result remains historical evidence, but no further Standalone source,
CMake or test change is part of CTA-S53 and Standalone is not a completion gate.
Do not introduce HIR, a persisted CFG, backend labels/slots into the snapshot,
or Engine pointers/numeric TypeIds into the protocol.

- [x] 15.1 <!-- TDD --> Harden `asCASTContext` ownership and admission before adding protocol state. Add compile-time/runtime tests proving the arena owner is noncopyable/nonmovable as appropriate; foreign snapshot Decl/Stmt/Expr/Type IDs are rejected consistently; and no consumer can publish or resolve through a foreign owner. Implement the smallest context/API changes that make those RED tests pass.

  **Focused gate:** extend Frontend CanonicalAST Context/Type/Verifier tests,
  then run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" -Label cta-s53-context-owner -TimeoutMs 600000`.

  Evidence 2026-08-28: two AST-first tests produced an exact **6/8 RED**:
  the arena owner was implicitly copy-constructible and a numerically equal
  foreign public declaration ID resolved through the internal Context. The
  smallest fix deletes copy/move construction and assignment and requires
  owner zero in every const/mutable Decl/Stmt/Expr/Type lookup. Runtime/Editor
  build then passed, focused Context is **8/8 PASS**, and the complete Frontend
  CanonicalAST prefix is **154/154 PASS**. Public snapshots continue to validate
  their own token before converting to owner-zero internal IDs. Exact reports,
  root cause and non-claims are recorded in
  `attachments/canonical-lifetime-context-admission-gate-2026-08-28.md`.

- [x] 15.2 <!-- TDD --> Replace the overloaded `sealed` admission meaning with one explicit lifecycle contract: `Building -> SemaFinalized -> LifetimePlanned -> Frozen/Publishable`. Add negative tests for skipped, repeated, stale and post-freeze mutation transitions. Sidecar encode/decode, Bytecode and AOT must all use the same admission predicate; consumer-specific weaker substitutes are forbidden.

  **Files:** `as_ast_context.h/.cpp`, `as_ast_verifier.h/.cpp`,
  `as_ast_sidecar.h/.cpp`, `as_bytecode_codegen.cpp` and the TypedASTJIT
  Canonical consumer. This is an internal maintained-fork state contract, not
  a new public embedding ABI.

  Evidence 2026-08-28: an API-first lifecycle test produced the expected build
  RED because no state, transition or shared admission contract existed. The
  Context now permits only adjacent, one-shot transitions; stale, skipped,
  repeated and post-Building/freeze mutation attempts fail closed. Existing
  `Seal()` callers execute all three adjacent transitions exactly once; a
  repeated `Seal()` is rejected. Verifier, Module/Cache, Sidecar encode,
  Bytecode publication, StaticJIT snapshotting and TypedASTJIT now use the one
  `IsPublishable()` predicate; Sidecar decode accepts only a fresh `Building`
  destination and publishes only after completing that same lifecycle. The
  final build passed; Frontend CanonicalAST is **156/156 PASS**, Cache
  ASTBodySidecar **22/22 PASS**, and TypedASTJIT CanonicalASTMigration **16/16
  PASS**. Source scan finds no Canonical `IsSealed()` consumer; remaining
  same-name uses belong only to the unrelated bind collection. Exact evidence
  and the Task 15.3 non-claim are recorded in
  `attachments/canonical-lifecycle-admission-gate-2026-08-28.md`.

- [x] 15.3 <!-- TDD --> Define revisioned snapshot-owned lifetime protocol types and Context storage. Records SHALL identify the lifetime subject, exact action target, activation/commit point, semantic region/phase, supported exit mask, construction step/order and complete-object commit using only snapshot-local IDs inside the owning snapshot. They SHALL contain no raw pointer, Engine-local numeric TypeId, backend label/slot/stack state or rendered dump identity. Add deterministic equality/hash and wrong-revision tests before implementation.

  **Files:** create `as_ast_lifetime.h/.cpp`; modify
  `as_ast_context.h/.cpp`, `as_sema_lifetime.h/.cpp`, verifier tests and the
  Standalone source list. Sidecar V6 remains unchanged unless 15.11's AST-first
  RED proves that a required semantic fact cannot be derived after decode.

  Evidence 2026-08-28: tests first required pointer-free value records,
  fieldwise equality/hash, Context ownership/freeze and wrong-revision
  rejection. The expected compile RED was the missing `as_ast_lifetime.h`
  contract. The maintained fork now owns revision 1 protocol records with
  snapshot-local Decl/Stmt/Expr coordinates, exact subject/action/activation/
  region/phase/exit/construction fields, fieldwise structural hashing and
  verification during the `SemaFinalized -> LifetimePlanned` transition. A
  first GREEN link attempt exposed an out-of-line, non-exported equality
  operator; equality was made inline. The first Standalone build then exposed
  one residual `IsSealed()` test consumer from 15.2; it was migrated to the
  shared `IsPublishable()` contract. Final Runtime/Editor build passed,
  Context is **12/12**, Verifier **35/35**, complete Frontend CanonicalAST
  **159/159**, and Standalone **20/20 PASS**. Sidecar remains V6. Empty current-
  revision protocols are accepted only as a staged compatibility state;
  production success-sensitive record authoring and consumption remain 15.4-
  15.8. Full evidence and non-claims are in
  `attachments/canonical-lifetime-protocol-foundation-2026-08-28.md`.

- [x] 15.4 <!-- TDD --> Make local lifetime activation success-sensitive. First add an AST-first RED with two local value objects where the second initializer throws: the snapshot must activate/commit only the first object on the abort edge, must exclude the failed current object, and must destroy both in strict reverse order on the normal edge. Then author exact activation/commit facts in Sema without letting `DeclStmt` itself imply liveness.

  **Focused gates:** SemaAuthority sealed-fact assertions plus
  ProductionCodeGen VM execution. Run
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label cta-s53-local-activation -TimeoutMs 600000`
  and
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label cta-s53-local-activation-codegen -TimeoutMs 600000`.

  Evidence 2026-08-28: the AST-first fixture produced the expected focused
  **0/1 RED** because the protocol contained no local records even though the
  sealed graph exposed `First` commit `Assign` Expr 18 and `Second` commit
  `Assign` Expr 25. Sema now treats `DeclStmt` as name introduction only,
  activates cleanup after the exact initializer assignment completes, and
  authors two `LOCAL / DESTROY_VALUE / LEXICAL_SCOPE / EXIT_ALL` records with
  exact local, destructor, activation and block identities. The focused AST
  gate is **1/1 PASS**. A production exception fixture proves normal cleanup
  order `[2,1]`, failed-Second cleanup `[1]`, Canonical CodeGen publication and
  zero LEGACY compiler invocation. Runtime/Editor build passed; complete
  SemaAuthority is **400/400 PASS** and ProductionCodeGen **119/119 PASS**.
  The VM already preserved success-before-active exception unwind; this task
  closes Sema protocol authoring and explicit transfer activation, not 15.7
  protocol-only backend consumption. Exact paths, issues and non-claims:
  `attachments/canonical-local-success-sensitive-activation-gate-2026-08-28.md`.

- [x] 15.5 <!-- TDD --> Implement one shared deterministic transient derived lifetime/control view over a Frozen snapshot. The view may mechanically derive scope edges, committed-live sets and reverse live-only cleanup order; it may not perform lookup, type/destructor selection, mutate AST, persist, publish, or become a general CFG/HIR. Make the verifier authenticate this view and fail closed for wrong subject/action/activation/order/phase, missing/duplicate action, failed-current-object cleanup, early complete-object destruction, foreign ID and revision mismatch.

  **Files/tests:** `as_ast_lifetime.h/.cpp`, `as_ast_verifier.h/.cpp` and
  forged-protocol tests under Frontend/Compiler CanonicalAST. Rebuilding the
  view repeatedly from the same snapshot must produce identical typed records
  and a dedicated structural digest independent of `asCASTDump()` text.

  Evidence 2026-08-28: `asCASTLifetimeView` now rebuilds typed scope edges,
  authenticated record ordinals and success-sensitive commit/live/abort/reverse
  cleanup sets from immutable Context facts. Verifier authenticates it before
  `LifetimePlanned` admission and again before Frozen publication. Wrong
  subject/action/activation/order/phase, missing/duplicate/foreign actions,
  early complete-object claims and wrong revision fail closed. A nested-scope
  proof confirms outer live state and reverse cleanup; repeated reconstruction
  has an independent `LTV1` typed digest and is unaffected by `asCASTDump()`.
  Runtime/Editor build, Context **12/12**, Verifier **39/39**, Frontend
  CanonicalAST **163/163**, SemaAuthority **400/400** and ProductionCodeGen
  **119/119** pass. MSVC export/friend linkage and one stale Construct-as-
  activation Context fixture were repaired and recorded. Exact RED/GREEN paths,
  scans and staged non-claims are in
  `attachments/canonical-lifetime-derived-view-gate-2026-08-28.md`. Standalone
  was neither changed nor run and remains deferred.

- [x] 15.6 <!-- TDD --> Migrate current `scope-exit`, `scope-release` and foreach positional phase handling behind named protocol accessors. During migration retain the existing normal/transfer cleanup statements and foreach child only as compatibility encodings, verify exact bidirectional equivalence with the protocol/shared view, and reject disagreement. Remove magic-string/child-position interpretation from Bytecode and AOT consumer paths after parity tests pass.

  **Coverage:** ordinary block exit, return, targeted break, live-through
  continue, foreach normal/transfer exits, owning reference release and value
  destructor order. Do not delete native Parser AST or explicit LEGACY logic.

  Closed 2026-08-28: `asCASTLifetimeView` now exposes named, authenticated
  cleanup bindings and foreach phases. The shared view proves exact
  protocol-to-compatibility equivalence in both directions and rejects
  missing, extra, duplicate, wrong-order, wrong-target and wrong-exit-mask
  encodings. Bytecode and TypedASTJIT contain no cleanup magic-string decode;
  foreach-specific consumers use `FindForEachPhases()` rather than child
  positions. A normal-cleanup ordinal error, duplicate unqualified lookup for
  namespaced destructors, unauthenticated old AOT fixtures and one MSVC member
  initialization warning were found and repaired. Final gates: build PASS,
  Frontend CanonicalAST **165/165**, SemaAuthority **401/401**,
  ProductionCodeGen **119/119**, TypedASTJIT **45/45**, Cache ASTBodySidecar
  **22/22** and Cache default-disabled/shutdown **7/7**. Exact RED/GREEN paths,
  scans, issue log and 15.7/15.8 non-claims:
  `attachments/canonical-lifetime-compatibility-accessor-gate-2026-08-28.md`.
  Standalone was neither changed nor run and remains deferred.

- [x] 15.7 <!-- TDD --> Make Canonical Bytecode consume only the authenticated protocol/shared view for semantic cleanup. Preserve backend-local cleanup/EH stacks, labels, patches, slots and active bits; preserve VM `asOBJ_INIT` success-before-active behavior; reject invalid protocol before detached artifact publication; and prove the emitter never reads dump text, destructor spelling or type-family heuristics to select an action.

  **Focused gate:** run the full ProductionCodeGen group with normal, transfer,
  initializer-failure and rollback cases through `Tools\RunTests.ps1`; do not
  count an explicitly selected LEGACY differential fixture as Canonical proof.

  **Completed 2026-08-28:** Bytecode now consumes typed `NORMAL`, `TRANSFER`
  and `FOREACH` exit plans derived from authenticated lifetime records. A
  nested foreach/return RED exposed and fixed the required
  `inner-local -> iterator -> outer-local` cleanup order. Final build,
  Frontend 168/168, SemaAuthority 401/401, ProductionCodeGen 121/121,
  Verifier 44/44, CodeGen Transaction 20/20, TypedASTJIT regression 45/45,
  Cache sidecar 22/22 and Cache Settings/Shutdown 7/7 all pass with zero
  failures/skips. Standalone was excluded and not run. Architecture,
  RED/GREEN paths, fixture limitations and 15.8-15.11 non-claims are recorded
  in
  `attachments/canonical-bytecode-protocol-only-lifetime-gate-2026-08-28.md`.

- [ ] 15.8 <!-- TDD --> Make TypedASTJIT consume the same authenticated protocol/shared view. Remove AOT destructor-name scans, type-kind lifetime reclassification, `DeclStmt` activation and positional/string cleanup decoding. Copy only a pointer-free stable-key/ABI-key lifetime summary into backend/provider records; never retain snapshot/protocol pointers. Until native object-frame ABI and an exit kind are implemented, emit a precise typed per-function fallback rather than a partial cleanup plan.

  **Focused gate:** extend StaticJIT TypedASTJIT CanonicalASTMigration,
  execution-profile and provider dependency tests, then run
  `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.TypedASTJIT" -Label cta-s53-typedastjit-lifetime -TimeoutMs 600000`.

  **Reopened 2026-09-02 (CTA-S184a):** the prior completion statement below
  claimed a precise typed fallback for every authenticated non-empty plan, but
  the newly source-authored legal
  `TEMPORARY / DESTROY_VALUE / FULL_EXPRESSION` plan exposed a real omitted
  family. The committed baseline produced an unverified summary and
  `InvalidCleanupPlan` instead of a pointer-free authenticated summary and
  precise `UnsupportedLifetime` fallback. The current worktree has authentic
  source-summary and provider-forgery RED/GREEN evidence, but the generated
  TestJIT provider regeneration is blocked after
  `ASStaticJITAotFixture::ObjectLifetimeEntryForAOT` fails stable-dependency
  capture. The exact Complete-composition RED identifies the missing edge as
  `FString(const FString&inout)`; see `CTA-S184a-DEP` in
  `reviews/semantic-correctness-issue-ledger-2026-09-01.md`. Keep this row
  unchecked until generation, generated-source build,
  Verify, generated diagnostic transport and the focused TypedASTJIT/provider
  owner gates are green and recorded. The 2026-08-28 paragraph remains below
  as historical evidence for the previously covered NORMAL/TRANSFER/FOREACH
  families.

  **Validation update 2026-09-02 05:46:** CTA-S184a-DEP is now an authentic
  RED→GREEN: the selected `FString` copy constructor is published as an exact
  compiler dependency, the Complete oracle passes **1/1**, full
  GenerationFacts passes **2/2**, and the following commandlet stays at
  `Candidates=7 Captured=7 Skipped=0`. Official StaticJIT Generate then
  reaches a later deterministic gate and fails because the non-final
  `ObjectLifetimeEntryForAOT` fixture has a stale `UnsupportedFunctionTrait`
  expectation while the authoritative frozen entry-plan rejection is
  `UnsupportedSignature: StaticJITEntryPlanTypedReceiverUnsupported`.
  Bytecode fallback is still emitted. Independent review confirms that the
  production receiver/signature precedence predates this worktree; synchronize
  the exact expectation without accepting arbitrary fallback categories. The
  legacy `NonCloneableEffectRejected` target exits before lifetime analysis,
  so it is not CTA-S184a lifetime evidence. Keep 15.8 unchecked while the
  separate source-authentic/generated-summary proof and the remaining
  Generate/build/Verify/provider-owner chain are rerun. Current evidence:
  `reviews/current-overall-progress-2026-09-02-0546.md`.

  **Validation update 2026-09-02 06:20:** the exact fallback expectation is
  synchronized and the complete official StaticJIT Mode All chain now passes
  baseline build, Generate, generated-source build and Verify. Generate is
  deterministic, all owned outputs are unchanged, and every observed complete
  composition remains `Candidates=7 Captured=7 Skipped=0`. The final
  `Angelscript.TestModule.StaticJIT` owner prefix found 405 tests but completed
  only 39 Success and three Fail before the next test crashed with a native
  access violation; 362 tests did not complete. One Fail is a stale installed
  diagnostic schema-1 assertion for the new schema 3, and the opt-in Cache V2
  restore Fail stays deferred/non-gating. Two independent owner blockers
  remain: the recurring 1-versus-61 differential oracle/function-ABI mismatch,
  and an authentic generated BytecodeJIT `FString` copy-constructor operand
  bug that dereferences `&v_TEMP_11` instead of the `FString*` stored in
  `v_TEMP_11`. The latter crashes at generated line 2182. Keep 15.8 unchecked
  until the oracle is authenticated, the native crash is fixed and the
  complete owner matrix is green. Current evidence:
  `reviews/current-overall-progress-2026-09-02-0620.md`.

  **Main-checkpoint update 2026-09-02 10:30:** the installed diagnostic test
  now derives the exact expected revision from
  `FAngelscriptJITProviderDiagnosticsAbi::SchemaRevision`; its focused rerun
  passes. The indirect value-object copy path now carries explicit source
  pointer provenance, emits `PshVPtr` for a pointer-valued string literal and
  has a production RED-to-GREEN runtime/lifecycle regression; the complete
  ProductionCodeGen class passes **183/183**. The regenerated source shows the
  corrected operand shape, but the generated TestJIT DLL and the original
  `NestedReferenceLifetimeAndRecursionMatchInterpreter` crash case were not
  rebuilt/re-executed after that regeneration. The recurring 1-versus-61
  differential oracle remains red, Cache V2 opt-in restore remains deferred,
  and the owner matrix remains incomplete. This change is therefore merged as
  an unfinished, default-disabled checkpoint; keep 15.8 unchecked and keep the
  OpenSpec active on main.

  Progress 2026-08-28 (CTA-S53/15.8): TypedASTJIT now derives a typed
  structural stable key and cleanup ABI key from the authenticated shared
  lifetime view, copies only pointer-free protocol/action/exit/count/capability
  facts into backend and Provider rows, and emits the precise
  `AuthenticatedLifetimeRequiresNativeObjectFrameABI` per-function fallback
  for every non-empty plan. Destructor-name/type-family/`DeclStmt`/positional
  cleanup reclassification is absent from the consumer. Prepared Canonical
  Cache restore now admits authored/generated bodies, resolves exact
  same-module pending functions through a synchronous non-owning transaction
  view, and balances restored references across commit and rollback. Final
  TypedASTJIT is **48/48**, ProductionCodeGen **121/121**, focused Fresh Cache
  restores **69/69**, and the UE build passes. Standalone remains excluded;
  15.9-15.11 and the section 5/7/9/13 umbrellas remain open. Evidence:
  `attachments/canonical-typedastjit-protocol-only-lifetime-gate-2026-08-28.md`.

- [x] 15.9 <!-- TDD --> Add constructor partial-construction protocol and parity: base, member, delegating-constructor and complete-object steps become live only after their individual commit; failure at step N destroys only committed steps `0..N-1` in reverse order; a complete-object destructor is unreachable until a distinct complete commit. Prove Sema facts, verifier rejection, Bytecode behavior and AOT acceptance/fallback for every supported shape.

  **Completed 2026-08-29:** Canonical Sema now authors exact base/member and
  distinct complete-object commit records; the shared lifetime view and
  verifier authenticate deterministic committed-prefix plans, including the
  future same-owner delegating typed shape. Canonical Bytecode lowers the plan
  to a private `ttUInt` committed-count frame dword plus a generation-local
  cleanup directory, emits `asBC_FinConstruct` before complete commit, and the
  VM unwinds only the successful prefix in reverse. Raw factories remain
  non-owning but JIT-addressable; UASClass aborts incomplete UObjects without a
  complete destructor. Detached/module restore uses semantic type/function/
  property tables, rejects out-of-frame or wrong-role factory coordinates and
  reconstructs the Runtime/JIT directories. TypedASTJIT publishes a
  pointer-free `PartialConstruction` summary and the precise per-function
  native-object-frame fallback; Provider no longer mistakes construction
  commits for lexical exits. Final relevant gates pass: ProductionCodeGen +
  RestorePrimitives **129/129**, TypedASTJIT **50/50**, SemaAuthority
  **402/402**, Frontend CanonicalAST **171/171**, UASClass construction **2/2**
  and AOT diagnostics **4/4** (`758/758` total), with CodeGenTransaction
  separately **20/20**. Standalone was excluded and not run; explicit
  `super(...)`/same-class delegating source authoring, arrays/aggregates,
  native object-frame ABI, default cutover and the 15.11 boundary gate remain
  open. Design, I1-I12 issue chronology, RED/GREEN paths and restore security
  fixes are recorded in
  `attachments/canonical-constructor-partial-construction-plan-2026-08-29.md`.

- [x] 15.10 <!-- TDD --> Add array/aggregate partial-construction progress using a pointer-free committed count/cursor and exact element cleanup action. Prove zero/one/many committed elements, middle-element failure, reverse cleanup, nested aggregate composition, deterministic view reconstruction and safe AOT fallback where native element-frame ABI is unsupported.

  **Completed 2026-08-29:** Canonical Sema now authors one exact aggregate-wide
  lifetime record for the list Expr, element value type, destructor action,
  semantic owner and deterministic element steps. The shared lifetime view
  authenticates zero/one/many committed prefixes, strict reverse cleanup and
  independent nested child/parent plans without persisting a dynamic cursor.
  Canonical Bytecode allocates the list buffer before element evaluation,
  initializes a private committed-count cursor to zero, advances it only after
  each successful element, retires it in reverse and registers the buffer in
  the ordinary typed heap cleanup directory. VM exception unwind therefore
  destroys only the successful prefix before freeing the buffer. Full module
  stream v3 and detached Function Artifact V6 encode semantic type/action/count
  facts through existing presence bits, reconstruct and authenticate physical
  offsets from decoded bytecode, and retain no pointer or numeric TypeId.
  Malformed count/bytecode disagreement fails before writer publication; module
  restore and artifact roundtrip execute middle-element/factory failures without
  leaking or double-destroying. TypedASTJIT hashes the pointer-free aggregate
  plan shape, element count and nested parent ordinal into StableKey/ABIKey and
  emits the precise `UnsupportedLifetime` fallback while native element-frame
  ABI is unavailable. The complete Frontend CanonicalAST + SemaAuthority +
  ProductionCodeGen + StaticJIT TypedASTJIT gate is **752/752 PASS**; the
  restore/transaction regression is separately **150/150 PASS**. Standalone
  was excluded and not run. Design, I1-I21 issue chronology, RED/GREEN reports,
  restore-format rationale and ownership audit are recorded in
  `attachments/canonical-aggregate-partial-construction-plan-2026-08-29.md`.

- [x] 15.11 <!-- Non-TDD --> Run the CTA-S53 boundary and regression gate. Keep Sidecar V6 when all protocol facts are reconstructible from the decoded snapshot; bump schema only after a recorded AST-first RED proves one required semantic fact is otherwise lost. Prove protocol identity uses a typed structural hash rather than dump/JSON/DOT rendering; HIR production symbols stay absent; native `asCScriptNode` semantic traversal and `asCCompiler` function-body publication stay confined to explicit LEGACY/syntax/recovery/reference routes; CANONICAL may reuse `asCBuilder` only as the already accepted non-semantic Stage 1/2 Runtime registration/transaction shell and MUST NOT derive expression/statement semantics from its native tree or invoke the legacy compiler; product default stays LEGACY; and Provider/detached artifacts contain no pointer, numeric TypeId or snapshot-local ID.

  **Completed 2026-08-29:** the AST-first Sidecar roundtrip RED proved V6
  erased required Sema-authored lifetime facts, so V7 now persists and restores
  the exact pointer-free protocol before seal/verification; malformed protocol
  data destroys the candidate and fails closed. Lifetime/Provider identities
  use typed domain-separated structural hashes and stable ABI keys, never
  diagnostic rendering, pointers, numeric TypeIds or retained snapshot-local
  IDs. Final gates pass: four-prefix regression **752/752**, Sidecar plus
  default-disabled Cache **30/30**, and the additional ExactWarmStartup restore/
  corruption integration **15/15**. The exact required build passes at
  `Saved/Build/cta-s53-lifetime-protocol/20260829_073810_020_d4f98b66`.
  Final scans prove HIR production symbols and dual mode remain absent, product
  defaults remain LEGACY, and CANONICAL neither traverses native body structure
  in Sema nor invokes `asCCompiler`; its accepted `asCBuilder` use remains only
  the non-semantic Stage 1/2 Runtime registration/transaction shell. Standalone
  was not built, tested or modified. Issue chronology, RED/GREEN reports,
  ownership audit and exact evidence paths are recorded in
  `attachments/canonical-lifetime-boundary-regression-gate-2026-08-29.md`.

  **Required commands:** `Tools\RunBuild.ps1 -Label cta-s53-lifetime-protocol -TimeoutMs 1800000 -NoXGE`; the complete Frontend CanonicalAST, SemaAuthority, ProductionCodeGen and StaticJIT TypedASTJIT prefixes through `Tools\RunTests.ps1`; and Cache sidecar/default-disabled gates through `Tools\RunTests.ps1`. Then run `openspec validate "refactor-as-canonical-typed-ast-compiler"` and diff/source scans. Standalone is explicitly excluded from this gate and deferred to a separate future OpenSpec. Leave the section 5/7/9/13 umbrellas unchecked until their own full acceptance surfaces pass.
