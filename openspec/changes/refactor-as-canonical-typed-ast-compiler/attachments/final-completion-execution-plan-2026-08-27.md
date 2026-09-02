# Canonical Typed AST Compiler Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete `refactor-as-canonical-typed-ast-compiler` as a real production compiler cutover: typed Parser actions and Canonical Sema own all CANONICAL source semantics, one sealed Canonical AST drives Bytecode and TypedASTJIT, every CANONICAL source entry point publishes an atomic executable/AST/type-binding generation, and TypedSemantic HIR plus every CANONICAL parser-node semantic dependency is removed before the final default and full-suite gates. The native `asCScriptNode`/Builder/Compiler implementation remains as an explicitly selected LEGACY reference/rollback path for a later retirement OpenSpec.

**Architecture:** Keep the landed Clang-style layering and finish its authority boundaries: `SourceManager -> Parser actions -> Sema scopes/types/call/control/lifetime plans -> ASTContext -> Verify/Seal -> detached Bytecode artifact or TypedASTJIT visitor -> generation-local relocation binding -> atomic publication`. `asASTTypeRef` remains snapshot-local; durable identity is the complete stable type key plus `asSTypeABIKey`; numeric AngelScript TypeId remains an Engine/generation-local late projection. Cache V2 remains default-off and is not expanded into a production restore redesign in this change.

**Tech Stack:** Unreal Engine 5.7 C++, maintained AngelScript fork, CQTest/UE Automation, Standalone CMake/CTest, PowerShell project runners, OpenSpec.

**Spec:** `openspec/changes/refactor-as-canonical-typed-ast-compiler/{proposal.md,design.md,specs/**/spec.md,tasks.md}`. This plan supersedes the execution pointer in `attachments/remaining-open-tasks-sequential-plan-2026-08-26.md`; historical RED/GREEN records remain valid evidence for their named slices.

## Global Constraints

- [ ] Work only in `D:\as-cta`; preserve the existing dirty parent and plugin worktrees.
- [ ] Do not commit, reset, discard, archive, or create a follow-up OpenSpec unless the user explicitly requests it.
- [ ] Use only `Tools\RunBuild.ps1`, `Tools\RunTests.ps1`, and `Tools\RunTestSuite.ps1` for build/test execution.
- [ ] Before each semantic production edit, add a focused Gate 0 card and record `AST-red -> AST-green -> CodeGen/provenance-green -> lifecycle-green (when crossed) -> focused-regression-green`.
- [ ] Do not count a LEGACY compile, a pipeline enum, `Ready()==true`, or a broad SDK/All pass as canonical authority evidence.
- [ ] Fail closed on an incomplete AST fact; do not silently invoke `asCCompiler`, rebuild HIR, decode Bytecode for body meaning, or add a production `dual` selection.
- [ ] Preserve the native `asCScriptNode` syntax tree and explicit LEGACY Parser/Builder/Compiler path. Removing those sources or that selection is outside this change; retaining them never counts as CANONICAL evidence.
- [ ] Treat TypeId as a runtime projection only. Public AST, diagnostics, DTOs, provider identity, stable dependencies, and detached relocation identity must not persist Engine pointers, numeric TypeIds, or foreign snapshot-local refs.
- [ ] Keep Cache V2 disabled by default and outside the compiler lifecycle. Its explicit prototype tests remain regressions, not cutover prerequisites beyond the default-disabled boundary.
- [ ] Update `tasks.md` only when the full wording of a task is proven; a completed vertical slice is recorded as progress, not used to check an umbrella prematurely.

## Reconciled Baseline

The initial 2026-08-27 audit reported **82/125 complete and 43 unchecked**.
After restoring the truthful transitional default, closing the Runtime
type-binding/relocation/generation/source/adversarial slices and completing the
Task 14.6 type-identity boundary gate, the live count is **86/125 complete and
39 unchecked**. The unchecked rows overlap and form seven implementation
packages:

| Package | Open tasks | Current truthful boundary |
| --- | --- | --- |
| Gate umbrellas | `0.2`, `0.3` | Existing cards cover many slices; the matrix is not complete and must be rerun immediately before default cutover. |
| Sema authority | `4.2`–`4.6`, `5.2`–`5.9`, `13.2` | Many AST slices are green, but CANONICAL Sema still recursively interprets `asCScriptNode`; scope/candidate/type/call/lifetime/control authority is not complete. The native tree itself is retained. |
| Detached Bytecode/install | `9.1`, `9.5`–`9.7`, `13.6` | Canonical CodeGen and six relocation classes are real; full declaration/lifetime/exception/debug/corpus closure is not proven. |
| TypedASTJIT | `7.2`, `7.4`, `7.5`, `7.8` | Production capture selects sealed AST, but HIR-shaped overloads/oracles and capability paths remain in source/tests. |
| Generation/source/snapshot | `3.4`, `13.8` | Source truth, the adversarial matrix and the type-identity boundary are closed. The remaining umbrella requires the complete production entry-point/multi-publisher audit, including CompileFunction completeness. |
| Production cutover | `10.1`–`10.7`, `10.9` | Primary, Hot Reload and CompileFunction have canonical provenance slices; generation/commandlet/Standalone and action-only Sema are incomplete. Final state is CANONICAL default plus explicit isolated LEGACY, not native-AST deletion. |
| Delivery gates | `11.4`, `12.2`, `12.4`, `13.12` | Migration ABI note and post-cutover focused/All evidence are outstanding. |

Already-closed foundations must be preserved, not rebuilt: immutable AST snapshots/public V1, exact declaration keys, verifier firewall, native-form catalog, Cache V2 default-off containment, aggregate runtime type generations, complete stable type/ABI keys, and metadata/runtime/public-ID/property/function/list-pattern relocations.

## Issue Ledger

| ID | State | Issue | Required disposition |
| --- | --- | --- | --- |
| CTA-P0-01 | Resolved for migration phase | A premature `ep.canonicalCompilerPipeline = true` routed normal Standalone through the incomplete Canonical surface before Task 10.2. | Restored transitional LEGACY default. Standalone is 21/21; explicit Canonical Cutover is 12/12. The final default still waits for Batch 7. |
| CTA-P0-02 | Resolved | The SemaAuthority dump helper released the just-built snapshot and made later assertions observe an empty graph. | Preserve snapshot ownership through the complete dump/assertion interval; focused SemaAuthority is 301/301. |
| CTA-S-01 | Open | `as_sema_decl/expr/stmt` still consume `as_scriptnode.h` through explicitly named default/property/body/expression/statement/lifetime adapters. CTA-S-22 deleted the generic declaration callback/walker and CTA-S-23 deleted lambda expression/body replay, but the language is not action-only. | Introduce action payloads/environment APIs, migrate one construct family at a time, and leave parser nodes only as transient syntax/recovery objects. |
| CTA-S-02 | Open | Overload/scope fallback paths can still bind first-same-name or use incomplete ranking for qualifiers/ref/handle/native hidden args. | Add source-to-sealed-AST ambiguity and call-plan tests, then remove permissive fallback. |
| CTA-S-03 | Open | Some implicit-handle and native POD local copy/member-assignment fixtures leave speculative unreachable `DeclRef` nodes in the arena. | Define and test the reachable-body invariant. Recovery arena nodes may remain only if no public/body traversal treats them as executable facts. |
| CTA-S-04 | Open dialect boundary | Raw canonical Parser rejects script `@`; script `funcdef` and `is` are fork-rejected while host `RegisterFuncdef` is supported. | Preserve the fork rejection with explicit diagnostics/tests. Do not invent a new language/closure ABI in this change. |
| CTA-S-05 | Resolved bounded slice | Explicitly qualified calls and `DeclRef`s could lose their qualifier, climb to a parent after an exact-scope member miss, retain direct dispatch while unresolved, or select a same-name non-scope declaration as a qualifier. | Exact-scope state, scope-kind filtering, fail-closed recovery, deferred exact reconciliation and generation rollback are covered. SemaAuthority is 306/306 and ProductionCodeGen is 113/113. This does not close CTA-S-01/02 or their umbrella tasks. |
| CTA-S-06 | Resolved bounded slice | A deferred call/`DeclRef` repaired its own type after a later qualified declaration appeared while an already-built primitive `BinaryExpr` retained provisional `int` type, operand plan and return conversion. | AST-only fixed-point primitive binary recomputation, explicit promotion and stale no-op conversion disconnection are covered. SemaAuthority is 308/308 and ProductionCodeGen is 114/114. Object operators and other parent families remain open under CTA-S-01/02 and the umbrella tasks. |
| CTA-S-07 | Resolved bounded slice | Namespace Sema received and recursively decoded a completed `snNamespace`; removing it exposed that namespaced child functions/classes had also depended on that replay for post-body finalization. | Namespace paths now use a short-lived typed segment payload and `WalkOne` has no `snNamespace` case. Completed non-namespace children retain an explicitly transitional final callback until each family gains a typed finish action. AST-first body and architecture tests pass; SemaAuthority is 309/309 and ProductionCodeGen is 114/114. Tasks 4.2/13.2 remain open. |
| CTA-S-08 | Resolved bounded slice | Enum and enumerator identity was decoded from `snEnum`/identifier Parser nodes, and the generic completed-declaration callback could replay the enum shell. | Enum/enumerator names now cross validated typed name/range actions; `WalkOne` has no `snEnum` case and the generic final callback excludes enum. The initializer remains an explicitly named expression adapter. SemaAuthority is 310/310 and ProductionCodeGen is 114/114. Tasks 4.2/13.2 remain open. |
| CTA-S-09 | Resolved bounded slice | Primitive typedef name/type facts were reconstructed by `WalkOne(case snTypedef)` from a completed Parser node. | Parser now publishes recognized alias name, Parser-resolved primitive token and exact range through `ActOnTypedefAction`; `WalkOne` has no `snTypedef` case and the generic final callback excludes typedef. Incomplete-before-`;` and complete unique `type=int` facts are pinned. SemaAuthority is 311/311 and ProductionCodeGen is 114/114. Tasks 4.2/4.3/13.2 remain open. |
| CTA-S-10 | Resolved bounded slice | Import signature, parameters and origin were reconstructed by `WalkOne(case snImport)`; deleting replay also removed the transitional producer identity association needed by prepared Runtime import shells. | Parser now publishes typed signature/origin actions, parameters attach under the exact import context, and no import whole-node notification/case remains. An explicit identity-only shell bridge restores the already-built stable key without decoding syntax. SemaAuthority is 313/313 and ProductionCodeGen is 114/114. General type/parameter payloads and Tasks 4.2/4.3/4.4/13.2 remain open. |
| CTA-S-11 | Resolved bounded slice | Ordinary global/method/constructor/destructor/mixin/local/interface functions were reconstructed from completed `snFunction` shells; early recovery could not observe trailing traits, and the obsolete whole-node decoder remained even after its call sites were removed. | Parser now publishes typed signature, exact parameter context, typed traits and a body-only adapter in order. Generic completion excludes ordinary functions; `WalkOne(case snFunction)` is lambda-only; the old `ActOnFunctionLike` decoder is deleted. SemaAuthority is 315/315, ProductionCodeGen 114/114 and Parser declarations 18/18. General type/parameter/default/body actions and Tasks 4.2/4.3/4.4/13.2 remain open. |
| CTA-S-12 | Resolved bounded slice | Class/struct/interface kind, qualified bases and lifecycle completion were reconstructed from growing/completed `snClass`/`snInterface` shells; the old base walker selected a recursive first identifier and could truncate `Right::Base`. | Parser now publishes typed record header, complete ordered qualified-base payloads and a finish action only after `}`. Sema owns record kind/type, exact fail-closed base resolution, dependencies, native-base completion and generated lifecycle/accessors. Record cases and the old base decoder are deleted. SemaAuthority is 317/317, ProductionCodeGen 114/114 and Parser declarations 18/18. Member/default/funcdef and general type/parameter/body actions keep Tasks 4.2/4.3/4.4/13.2 open. |
| CTA-S-13 | Resolved bounded slice | One completed global/field `snDeclaration` was replayed through first-child extraction, so later comma-separated declarators and access/initializer ownership were not independent typed facts. A GREEN run also exposed global folded constant `41` being overwritten by first source literal `40`. | Parser now publishes one typed header and one exact initializer action per global/field declarator; whole-declaration completion is absent and the residual walker fails closed for global/field owners. Global normalized default text is owned only by `ActOnGlobalVarInit`, while fields retain explicit InitPlans. Final SemaAuthority is 319/319, ProductionCodeGen 114/114 and Parser declarations 18/18. Local/type/property/funcdef/lambda/body/expression/statement/lifetime adapters keep Tasks 4.2/4.3/4.4/4.5/13.2 open. |
| CTA-S-14 | Resolved bounded slice | Ordinary local and `for` declarations were still replayed from `snDeclaration`; comma declarators depended on recursive first-child extraction, and removing replay initially exposed statement double ownership plus partial list-pattern recovery loss. | Parser now publishes one typed header and exact initializer action per local/`for` declarator, finishes an exact-range sequence, and publishes `foreach` identity without default construction. Normal sequences flatten with single ownership; `for` retains loop-scoped phases; missing exact actions fail closed. All Sema `case snDeclaration:` decoders are deleted. Final SemaAuthority is 321/321, ProductionCodeGen 114/114 and Parser declarations 18/18. General type/property/default/funcdef/lambda/body/expression/statement/lifetime actions keep Tasks 4.2/4.3/4.4/4.5/13.2 open. |
| CTA-S-15 | Resolved bounded slice | Class `default <statement>` was parsed under the record and then replayed through `case snClassDefaultStatement:` so Sema could synthesize/reparent a generated `__InitDefaults` body only after the complete shell existed. | Parser now starts/reuses one generated method before statement parsing, enters that exact DeclContext and finishes by exact method owner plus complete source range. Missing routing fails closed; multiple defaults attach exactly once in source order; the ParseClass callback and decoder are deleted. Final SemaAuthority is 324/324, ProductionCodeGen 114/114 and the synthesized-default TypedSemanticIR boundary is 1/1. General type/property/access-group/funcdef/lambda/body/expression/statement/lifetime actions keep Tasks 4.2/4.3/4.4/4.5/13.2 open. |
| CTA-S-16 | Resolved bounded slice | The retained Parser `funcdef` family still reconstructed callable identity, return type and parameter ownership from a completed `snFuncDef`, even though authored script `funcdef` is fork-rejected and host registration is a separate Runtime path. | Parser now publishes a pointer-free typed signature before parameters, enters the exact FuncDef DeclContext, and never notifies the completed shell; `WalkOne(case snFuncDef)` is deleted. Script rejection and host registration/call/rebuild each remain 1/1; final SemaAuthority is 326/326 and ProductionCodeGen 114/114. General type/parameter/default/property/access-group/lambda/body/expression/statement/lifetime actions keep Tasks 4.2/4.3/4.4/13.2 open. |
| CTA-S-17 | Resolved bounded slice | Custom `access NAME = ...;` syntax had no immutable Canonical declaration/permission representation, and `access:NAME` members had no exact edge; detached consumers would have needed Runtime pointers or repeated name lookup. | Parser now publishes a pointer-free complete access action and member headers carry the authored group name; Sema creates ordered specifier/permission declarations and resolves one exact same-record DeclId edge. Verifier/traversal/dump/public view and Sidecar V5 preserve the facts. Final SemaAuthority is 329/329, traversal 6/6, Sidecar 18/18, Snapshot 10/10, ProductionCodeGen 114/114 and Parser declarations 18/18. Builder/Runtime registration remains the shadow path; property/general type/parameter/default/lambda/body/expression/statement/lifetime authority and final Canonical Runtime installation keep Tasks 4.2/4.4/4.5/13.2 open. |
| CTA-S-18 | Resolved bounded slice | Ordinary/import/interface/funcdef parameter declarations waited for a complete optional default and crossed four Parser nodes; malformed defaults erased otherwise complete headers, while Sema could recover the owner from `lastActedDecl`. Historical Task 4.4 wording also risked restoring already-removed virtual-property syntax. | Parser now publishes a pointer-free parameter-header action before default parsing and every Canonical call site passes its exact callable DeclId. Sema validates owner/type/range, constructs the ParamDecl and records its dependency; a complete default uses a separately named adapter. `ActOnParsedParam` is deleted. Virtual-property syntax remains rejected. Final SemaAuthority is 331/331, ProductionCodeGen 114/114 and Parser declarations 18/18. General type/default/property/lambda/body/expression/statement/lifetime authority and final CANONICAL independence from Builder/LEGACY facts keep Tasks 4.2/4.3/4.4/4.5/13.2 open. |
| CTA-S-19 | Resolved bounded slice | Every declaration-site return/parameter/variable type was still converted by passing `snDataType` and modifier nodes from Parser into `ActOnQualTypeFromNode`; that mixed syntax ownership with type authority and exposed Parser nodes at the semantic boundary. | Parser now copies one pointer-free complete type-syntax action and all seven declaration route families call `ActOnQualTypeAction`; Sema alone resolves the local QualType and qualifier mask. Parser contains zero `ActOnQualTypeFromNode` calls and the action contains no Runtime pointer, numeric TypeId or foreign AST ref. Final SemaAuthority is 333/333, ProductionCodeGen 114/114, Parser declarations 18/18 and Frontend Type 20/20. Residual lambda/property/expression type recovery plus default/property/lambda/body/expression/statement/lifetime authority and final CANONICAL independence from Builder/LEGACY facts keep Tasks 4.2/4.3/4.4/13.2 open. |
| CTA-S-20 | Resolved bounded slice | Cast and construct target types were still passed back into Sema as `snDataType` and decoded through `ActOnQualTypeFromNode`; the incremental cast route duplicated that recovery. The first semantic fixture also used unsupported scalar `cast<T>` syntax, and an independent test file missing its macro include blocked aggregate test-module compilation. | Parser now resolves both targets from the pointer-free type-syntax action and publishes the local QualType through exactly two transient exact node/section/offset bindings. Expression Sema requires an unambiguous binding and fails closed; Parser, `as_sema_expr.cpp` and the incremental cast slice contain no node-to-type decoder. The fixture was corrected to `double(...)`, and the unrelated include was used only as a reverted validation workaround. Final SemaAuthority is 335/335, ProductionCodeGen 114/114, Parser declarations 18/18, Frontend Type 20/20, Conversions 17/17 and Expression Chain 1/1. General expression/default/property/lambda/body/statement/lifetime authority and CANONICAL independence from Builder/LEGACY facts keep Tasks 4.2/4.3/4.4/5.2–5.9/13.2 open. |
| CTA-S-21 | Resolved bounded slice | `ParseLambda` still sent the completed header through `NotifySema(node)`, entered the body through mutable `lastActedDecl`, and declaration Sema reconstructed the lambda signature and recovery type with the last three `ActOnQualTypeFromNode` call sites plus dedicated parameter walkers. | Parser now publishes one pointer-free lambda header, resolves and attaches explicit parameters through typed actions under the exact returned DeclId, and pushes that exact lambda context. The retained node adapter is body-only and fails closed when the exact binding is absent. The generic node-to-type API and all lambda signature walkers were physically deleted; TypeSema migrated to the typed boundary instead of restoring compatibility. Final SemaAuthority is 337/337, TypeSema 1/1, Parser declarations 18/18, ProductionCodeGen 114/114 and Frontend Type 20/20. Contextual funcdef binding, untyped parameters, return inference, body/default/property/general expression/statement/lifetime actions and CANONICAL independence from Builder/LEGACY facts keep Tasks 4.2/4.3/4.4/13.2 open. |
| CTA-S-22 | Resolved bounded slice | Parser and public Sema retained an inactive zero-action whole-tree declaration fallback (`NotifySema`/counter -> `ActOnParsedScript` -> `ActOnParsedDeclaration` -> `WalkOne/WalkDecls`) after all accepted top-level declaration families had migrated away from it. | The callback, counter, two public APIs, recursive walker, exclusion list and replay-only helpers are physically deleted. This deletes a Canonical duplicate replay, not the native `asCScriptNode` tree or LEGACY compiler. Permanent API-surface tests and global-absence assertions prevent restoration. Final SemaAuthority is 339/339 and the combined TypeSema/Parser-declaration/ProductionCodeGen/Frontend-Type matrix is 152/152. Direct node inventory is 25/41/20/5. Named default/property/body/expression/statement/lifetime adapters and CANONICAL independence from Builder/LEGACY facts keep Tasks 4.2–5.9/13.2 open. |
| CTA-S-23 | Resolved bounded slice | Parser already created the exact lambda declaration and attached its body, but expression and bare-statement lowering called `ActOnLambdaFromNode`, rediscovered the declaration from `snFunction` and attached the same body again. | A pointer-free expression action creates one exact `DeclRef`; Parser binds its `ExprId` to the retained native syntax identity and later lowering only retrieves it. The node adapter/child search are deleted, missing identity fails closed, native lambda ScriptNode shape remains 14/14, SemaAuthority is 341/341, Parser declarations 18/18 and ProductionCodeGen 114/114. Contextual lambda inference, other node adapters, HIR deletion and final cutover remain open. |
| CTA-SCOPE-01 | Resolved scope ambiguity | “Legacy AST” and “HIR” were treated as one deletion target, risking removal of AngelScript's native syntax/compiler implementation. | Retain `asCScriptNode`/Builder/Compiler plus explicit LEGACY selection; still delete TypedSemantic HIR and all CANONICAL semantic replay/fallback. See `attachments/legacy-native-ast-retention-scope-revision-2026-08-27.md`. |
| CTA-HIR-01 | Open retirement frontier | HIR is not just two model files: compiler capture, function ownership, engine config, TypedASTJIT compatibility overloads, Editor dump surfaces, active tests and Standalone wiring remain. Required source provenance is also expressed with HIR-named types. | Migrate TypedASTJIT/test oracles, extract neutral SourceManager provenance, remove HIR consumers/config/storage/build wiring, then physically delete `as_typed_semantic_ir.*`. Retain native AST/Builder/Compiler and explicit LEGACY. See `attachments/typed-semantic-hir-physical-retirement-gate-2026-08-27.md`. |
| CTA-HIR-02 | Resolved bounded prerequisite | ScriptCode/module source ingestion could not outlive HIR because provenance structs were physically declared in and included from `as_typed_semantic_ir.h`; a TypedASTJIT forward declaration also assumed a distinct HIR span struct. | Added HIR-independent `as_source_provenance.h`; migrated ScriptCode, Module, Engine ingestion and the backend testing seam to neutral types. Exact tests are 7/7, SourceManager 9/9, Runtime/Editor build and Standalone 21/21 pass. HIR-local aliases remain temporary; old provenance matches are 173 and Task 10.5 stays open. See `attachments/hir-neutral-source-provenance-extraction-gate-2026-08-27.md`. |
| CTA-HIR-03 | Resolved bounded deletion slice | The Editor HIR dump command/Commandlet and its `DeveloperHIRDump` ProjectSourceGraph mode kept a product-facing HIR surface and HIR-only tests alive after Canonical AST diagnostics existed. | Physically deleted the four Editor sources, dedicated Commandlet test, HIR generated-provenance integration test, one-value request-kind and HIR scratch route. Retained containment and primary-snapshot behavior as direct Canonical tests. Runtime/Editor build, migrated 2/2, ProjectSourceGraph 2/2 and Standalone 21/21 pass; active Source has zero HIR dump symbols. Generated-origin E2E diagnostics still need Canonical SourceManager ownership before final HIR deletion. See `attachments/hir-editor-dump-retirement-gate-2026-08-27.md`. |
| CTA-HIR-04 | Resolved bounded prerequisite | Neutral source provenance reached ScriptCode but Canonical SourceManager and V5 sidecar did not own/restore authored/generated anchors after the HIR dump test was deleted. | SourceManager now owns and resolves copied neutral ranges; Parser/Sema verifies them on source-session reuse; ASTBodySidecar V6 round-trips them, rejects malformed input and treats V5 as a safe miss. Provenance remains diagnostic-only and does not alter function record identity. Build, Sidecar 21/21, SourceManager 12/12, neutral ownership 3/3, Preprocessor 2/2 and Standalone 21/21 pass. HIR consumers/model still keep 10.5 open; native AST/LEGACY remain retained. See `attachments/canonical-source-provenance-retention-gate-2026-08-27.md`. |
| CTA-I-01 | Resolved test infrastructure | Three native SDK context test files used `ASTEST_AS[_ANSI]` without directly including `AngelscriptTestMacros.h`; adaptive non-unity builds repeatedly exposed the unity include leak. | Added the direct include to ReturnValue, PublicApiDepth and Invocation tests after scanning all 450 macro-user `.cpp` files. A `Shared/AngelscriptTestMacros.h` user was correctly excluded as a scan false positive. This repair has no compiler-semantic completion credit. |
| CTA-B-01 | Open | Full object/container/generated/exception/suspend/debug/coverage semantics are not yet proven as detached Canonical CodeGen output. | Close by AST-first semantic families and transaction tests; never infer completion from the current ProductionCodeGen count alone. |
| CTA-J-01 | Open | TypedASTJIT files still expose `asCTypedSemanticFunction` visitors/test-only HIR compatibility and HIR capability baselines. | Replace production and migrated oracle paths with canonical visitors, then delete residual production HIR types/accessors after complete StaticJIT proof. |
| CTA-T-01 | Closed for this change | Dynamic numeric TypeId cannot be a durable key; it changes across Engines/generations. | The stable-key -> ABI-key -> immutable generation binding -> numeric projection model and final scans are green. Full legacy VM/PrecompiledData relocation cleanup remains deferred to an explicitly authorized follow-up. |
| CTA-T-02 | Resolved | TypedASTJIT dependency fixtures implicitly relied on premature global Canonical/Cache defaults and crashed through a fatal helper check. | Fixtures explicitly select Canonical capture and per-Engine Cache V2; helper failure is assertion-friendly; TypedASTJIT was 70/70 at closure and is 71/71 after the CTA-B-02 regression was added. |
| CTA-T-03 | Resolved | Cache ForceClean read mutable global settings and ignored the target Engine's explicit Cache V2 override. | Maintenance now uses `Engine->IsCacheV2Enabled()`; default-disabled behavior is preserved. |
| CTA-T-04 | Resolved | Stable `TArray<int>` identity did not match the target Engine's `int[]` default-array surface. | Reconstruct the registered nominal candidate only during target-generation resolution; no alias, pointer or numeric ID becomes durable identity. |
| CTA-B-02 | Resolved | Local `TArray<int>` default construction reached Canonical CodeGen with `DANGLING_ID construct-decl`; importing the base behaviour alone then exposed a concrete-owner relocation mismatch. | Sema now materializes an instance-local template behaviour shell before import. The real source/AST/CodeGen/VM gate is 1/1, ScriptCorpus 5/5, Type 20/20, SemaAuthority 301/301, ProductionCodeGen 111/111 and TypedASTJIT 71/71. Broad container/lifetime tasks remain open. |

## Batch 1 — Reproduce and Restore a Truthful Transitional Baseline

### Task 1.1: Capture current Standalone failures

**Files to inspect:**

- `Plugins/Angelscript/Standalone/Tests/AngelscriptStandaloneCanonicalASTTests.cpp`
- `Plugins/Angelscript/Standalone/Tests/AngelscriptStandaloneArchitectureTests.cpp`
- `Plugins/Angelscript/Standalone/Tests/AngelscriptSemanticObserverTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.h`

- [x] Run `Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix cta-final-baseline -TimeoutMs 600000`.
- [x] Record CTest names, first diagnostics, and report paths in `attachments/final-completion-issue-log-2026-08-27.md`.
- [x] Separate configuration/default failures from real Canonical Sema, CodeGen, lifecycle, and legacy-HIR oracle failures.
- [x] Confirm whether any result differs from the earlier 8/21 record; the new run is authoritative.

### Task 1.2: Repair only the confirmed transitional-default inconsistency

**Test first:** the existing Standalone assertion that a newly created Engine is LEGACY until Task 10.2, plus a UE canonical cutover/default-settings test if the current UE suite does not assert the same state.

- [x] Record the failing test as RED for CTA-P0-01.
- [x] If the only root cause is the premature constructor default, change `ep.canonicalCompilerPipeline` back to `false` without altering explicit `SetCompilerPipeline(CANONICAL)` tests.
- [x] Verify Standalone and the focused Canonical Cutover group. Record that this is a transitional truth fix, not final Task 10.2 completion.
- [x] Do not weaken explicit CANONICAL source-build tests; they remain the implementation development route.

## Batch 2 — Complete Canonical Sema Authority

This batch closes the implementation behind `4.2`–`4.6`, `5.2`–`5.9`, and `13.2`. Work in small source families; one gate card per semantic fact.

### Task 2.1: Make Parser actions the declaration authority

**Production files:**

- `.../source/as_parser.h/.cpp`
- `.../source/as_sema.h/.cpp`
- `.../source/as_sema_decl.h/.cpp`
- `.../source/as_decl.h/.cpp`
- `.../source/as_ast_context.h/.cpp`

**Tests:**

- `.../Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
- `.../Frontend/CanonicalAST/AngelscriptNativeCanonicalASTDeclarationBaselineTests.cpp`
- `.../Frontend/CanonicalAST/AngelscriptNativeCanonicalASTShadowTests.cpp`

- [ ] Add a source fixture whose first valid declarations survive a later syntax error and whose sealed successful form proves namespace, typedef, enum, interface/class, function/method/ctor/dtor, property/import, parameters, defaults, traits, mixin origin, bases, and exact stable owner keys.
- [ ] Add an action counter/diagnostic showing those declarations are not reconstructed by a post-parse `WalkOne` fallback.
- [ ] Introduce Parser-to-Sema action payloads that contain tokens/source ranges and already-parsed syntax operands, not semantic `asCScriptNode` ownership.
- [x] Remove the production declaration fallback once equivalent facts and deterministic diagnostics are green. CTA-S-22 physically deletes the callback/counter, public whole-tree APIs and recursive replay walker; SemaAuthority is 339/339 and the combined regression matrix is 152/152.
- [ ] Add a deliberate shadow perturbation test for owner/type/trait/source/dependency mismatch and require deterministic fail-closed output without merging graphs.

### Task 2.2: Complete type/scope/symbol/candidate authority

**Production files:** `as_sema.cpp`, `as_sema_decl.cpp`, `as_sema_expr.cpp`, `as_ast_type.*`, `as_runtime_type_bridge.*`.

- [ ] Add AST-red cases for namespace-qualified lookup, typedef/enum/interface inheritance, template instances, const/ref/handle direction, ambiguous overloads, wrong receiver constness, and hash/display aliases.
- [ ] Replace first-same-name fallback with scoped symbol tables and explicit candidate sets.
- [ ] Freeze exact `asCQualType`, conversion rank, selected declaration, and rejection reason in the sealed graph.
- [ ] Preserve fork boundaries: script `funcdef`, `@`, and `is` stay rejected; host funcdef remains supported.
- [ ] Run complete SemaAuthority and Frontend CanonicalAST gates.

### Task 2.3: Complete call and sequencing plans

**Production files:** `as_sema_expr.*`, `as_expr.*`, `as_ast_verifier.*`.

- [ ] Add AST-red cases for ordinary/member/mixin/import/native/property/index/operator calls, effective receiver, source/default/hidden/named argument origin, reverse-formal storage, native route/ABI, and stable dependencies.
- [ ] Add explicit single-evaluation facts for property/index compound mutation, short-circuit logic, conditional expressions, temporary receivers, and generated values.
- [ ] Prove the reachable function-body graph contains exactly one evaluation identity even if recovery nodes remain in the arena.
- [ ] Migrate all applicable TypedSemanticIR `Call*` semantic oracles to sealed-AST assertions before changing CodeGen.
- [ ] Run SemaAuthority, Semantics differential VM, and ProductionCodeGen groups.

### Task 2.4: Complete control and lifetime plans

**Production files:** `as_sema_stmt.*`, `as_sema_lifetime.*`, `as_stmt.*`, `as_ast_verifier.*`.

- [ ] Add AST-red cases covering block/local/expression statements; if/else; for/while/do/foreach; switch/case/default/fallthrough; break/continue/return; explicit phases and safe-point roles.
- [ ] Add wrong-kind, non-ancestor, skipped-nearer, dangling, duplicate-case/default-order, and invalid-fallthrough verifier negatives.
- [ ] Add AST-red lifetime cases for non-POD values, handles/references, constructor/destructor selection, temporary materialization/extension, deferred/out parameters, return/transfer cleanup, globals, exceptional edges, and suspend/resume.
- [ ] Represent live-only reverse cleanup plans for every transfer edge; preserve stable source-level `try/catch` rejection.
- [ ] Run SemaAuthority, Verifier, ProductionCodeGen cleanup, Runtime exception, and differential groups.

### Task 2.5: Close the active language matrix

- [ ] Enumerate every active Compiler/Runtime/Module/TypeSystem/Language/Embedding/Conformance fixture and project Script construct against a sealed supported node or an intentional stable rejection.
- [ ] Add missing container/template, delegate/host-funcdef, lambda boundary, import, const-global, generated accessor/default/lifecycle/list-factory and safe-point fixtures.
- [ ] Require that no accepted executable body contains `Unsupported` or ERROR placeholder nodes.
- [ ] Source-scan the CANONICAL Sema path for semantic `asCScriptNode` walks. Remaining native syntax-tree use is allowed only for syntax/recovery or the explicitly selected LEGACY path and must be classified in the issue log.
- [ ] Check `4.2`–`5.9` and `13.2` only after this full audit, not after individual greens.

## Batch 3 — Complete Detached Canonical Bytecode and Metadata

### Task 3.1: Prove complete detached installation

**Production files:** `as_bytecode_codegen.h/.cpp`, `as_bytecode_codegen_artifact.h`, `as_runtime_type_binding.*`, `as_module.h/.cpp`.

- [ ] Extend the existing transaction matrix to every declaration and publication category, including funcdefs, generated lifecycle/list factories, globals/imports, nested lambdas and behaviour tables.
- [ ] Add per-item and per-phase injection after emission/binding but before Commit.
- [ ] Compare Engine slots/free lists/type maps, module inventories, globals/imports/behaviours, executable publisher/digest, AST generation, and runtime-binding fingerprint after every failure.
- [ ] Require all stable type/property/function relocations and ABI compatibility to resolve before any public mutation.
- [ ] Check `9.1` only when unsupported declaration categories no longer bypass the artifact transaction.

### Task 3.2: Complete remaining lowering and lifecycle families

- [ ] For each missing form discovered in Batch 2.5, first name the green AST card, then add a Canonical ProductionCodeGen test proving the backend consumes that exact graph.
- [ ] Cover objects/temporaries, containers/templates, delegate/funcdef, supported lambda boundary, globals/imports, generated bodies, list factories, exceptions, cleanup and suspend/resume.
- [ ] Preserve VM exception behavior and the existing capture-lambda rejection boundary; do not add a heap closure ABI.
- [ ] Check `9.5` only after every CANONICAL-selected active-language fixture has sealed-AST CodeGen coverage; explicitly labeled LEGACY regression fixtures remain separate.

### Task 3.3: Publish complete debug/runtime metadata as backend output

**Production files:** `as_bytecode_codegen.*`, `as_scriptfunction.*`, debug/coverage/timeout consumers.

- [ ] Add exact source-map, section-transition, local/parameter scope, stack/local layout, coverage, timeout, safe-point, exception and cleanup-table tests.
- [ ] Prove `ScriptFunctionData` is fully produced by Canonical CodeGen for a canonical-selected Engine.
- [ ] Run Debugger and CodeCoverage prefixes in addition to ProductionCodeGen.
- [ ] Check `9.6` only after no tested metadata row is inherited from `asCCompiler`.

### Task 3.4: Differential active corpus

- [ ] Extend the isolated LEGACY-vs-CANONICAL harness to all active native SDK and project Script fixtures without a shipped `dual` enum.
- [ ] Compare compile acceptance/rejection category, diagnostics, behavior, side effects, dependencies, debug metadata and lifecycle; report bytecode byte differences separately.
- [ ] Require each CANONICAL run to assert publisher, sealed digest and zero legacy compiler invocations.
- [ ] Check `9.7` and `13.6` only after the matrix has no unexplained canonical gap.

## Batch 4 — Migrate TypedASTJIT and Delete HIR Consumers

**Production files:**

- `Source/AngelscriptRuntime/StaticJIT/TypedASTJIT/AngelscriptTypedASTJITCanonical.*`
- `.../AngelscriptTypedASTJITEligibility.*`
- `.../AngelscriptTypedASTJITCallClosure.*`
- `.../AngelscriptTypedASTJITAnalyzer.*`
- `.../AngelscriptTypedASTJITEmitter.*`
- `.../AngelscriptTypedASTJITDependencies.*`
- generation snapshot/profile and Editor dump files.

- [ ] Add canonical visitor tests for eligibility, call closure, receiver/argument provenance, native/import/mixin/property routes, cleanup, exception metadata, recursion/frame budget, mutable/global/import categories and provider dependencies.
- [ ] Migrate each remaining HIR oracle to a sealed-AST fixture or a clearly test-only LEGACY differential utility.
- [ ] Ensure generation owns an `asIASTSnapshot` plus immutable runtime-binding lifetime while analyzing/emitting; Provider rows retain stable copied identities, not AST pointers.
- [ ] Delete production overloads/branches accepting `asCTypedSemanticFunction` after canonical tests are green.
- [ ] Remove production reads of `GetTypedSemanticFunction()` and HIR capability/dump assumptions; retain no production HIR builder/storage/accessor.
- [ ] Run CanonicalASTMigration, complete TypedASTJIT, StaticJIT generation/identity/provider/reload prefixes and the Runtime/Editor build.
- [ ] Check `7.2`, `7.4`, `7.5`, `7.8`, and then `10.5` only after the physical source audit is clean.

## Batch 5 — SourceManager, Snapshot, Generation and Adversarial Audit

### Task 5.1: SourceManager truth

- [ ] Add source identity/content-remap tests spanning Lexer, Parser action, Sema diagnostic, sealed node, backend line table, public AST and optional DTO.
- [ ] Reject a remap that matches display/path/hash aliases but not complete content identity.
- [ ] Verify authored, processed and generated source ranges survive deterministic dump and cache DTO round trip.
- [ ] Check `13.10` only after all consumers use one source model.

### Task 5.2: Combined generation/publication protocol

- [ ] Exercise module Build, public CompileFunction, staged UE primary, Hot Reload, StaticJIT generation, commandlet, Standalone and explicitly enabled restore policy against the documented replace/retire/preserve behavior.
- [ ] Race Acquire vs publish; retain old same-name/different-layout generations; hold snapshot and external execution leases; fail resolution, Seal, relocation and publication independently.
- [ ] Require failure to preserve the complete current executable + snapshot + stable identity + provenance + immutable runtime binding generation.
- [ ] Run the complete foreign-ID/small-view/hash-alias/different-Engine-TypeId/same-name-revision matrix.
- [ ] Check `3.4`, `13.8`, and `13.11` only when the combined audit is green. Task 14.2 is already closed by its focused binding and Standalone gates.

### Task 5.3: Type-identity boundary gate

- [x] Run Runtime/Editor build; Frontend Type/TypeIdentity; SemaAuthority; ProductionCodeGen and transaction; Module Snapshot; HotReload CanonicalAST; StaticJIT TypedASTJIT/generation identity; Cache default-disabled; Standalone.
- [x] Scan Public AST, diagnostics, DTO, provider records and relocation structures for durable Engine pointer/numeric TypeId/snapshot-local ref leakage.
- [x] Run deterministic outputs, OpenSpec strict validation and `git diff --check`.
- [x] Record exact reports in the issue log and check `14.6` only when all rows pass.

Evidence and non-claims:
`attachments/type-identity-boundary-gate-2026-08-27.md` and
`attachments/tarray-local-default-construction-gate-2026-08-27.md`. The local
`TArray<int>` default-construction issue CTA-B-02 is resolved as one bounded
container/lifetime slice; the umbrella language matrices remain open. Compiler
default and Cache V2 default are unchanged.

## Batch 6 — Production Entry-Point Cutover

### Task 6.1: Complete the purpose matrix while CANONICAL is explicit

- [ ] Add/refresh one real-entry test for primary Build, Hot Reload, CompileFunction, StaticJIT generation, commandlet and Standalone.
- [ ] Each row must inspect the sealed AST, publisher/digest, legacy invocation count, snapshot policy and rollback; a config enum is insufficient.
- [ ] Prove there is no registered/accepted production `dual` selection and no silent legacy fallback.
- [ ] Check `10.1`, `10.3`, `10.4`, `10.7` only after every row is green.

### Task 6.2: Gate 0 umbrella audit

- [ ] Index every still-open semantic/cutover task to at least one completed gate card.
- [ ] Run Frontend CanonicalAST, Compiler CanonicalAST/SemaAuthority, Module Snapshot, HotReload snapshot and Cache V2 default-disabled boundary.
- [ ] Record exact counts, paths and canonical provenance in a new final matrix attachment.
- [ ] Check `0.2` and `0.3` only after the index has no missing/red/skipped card.

## Batch 7 — Final Canonical Default, Legacy Isolation and Delivery

### Task 7.1: Make Canonical the final production default

- [ ] Add a RED default-settings test only after Batch 6.2 is completely green.
- [ ] Set the Engine/product default to CANONICAL and keep LEGACY as an explicit independent compatibility/reference/rollback selection until a later retirement OpenSpec.
- [ ] Prove a canonical production gap fails closed rather than invoking `asCCompiler`.
- [ ] Remove CANONICAL semantic-body dependence on `asCScriptNode`; keep the native tree for parser syntax/recovery/tests and the explicit LEGACY Parser/Builder/Compiler path.
- [ ] Run the cutover build and focused SDK/HotReload/StaticJIT/Cache-default-off/Standalone gates.
- [ ] Check `10.2`, `10.6`, `10.9` only from this post-cutover evidence.

### Task 7.2: Embedding migration notes

- [ ] Update `Documents/Guides/AngelscriptCanonicalAST.md` with public header/product version, V1 caller size/version negotiation, append-only/extension contract, retention timing, null acquisition, lease/current-generation semantics, Cache/SaveByteCode boundary and no concrete-node ABI.
- [ ] Cross-check plugin README and Chinese compiler/AST knowledge docs against the final code.
- [ ] Check `11.4` only after source/API declarations match the migration text.

### Task 7.3: Final verification

- [ ] Run `Tools\RunBuild.ps1 -Label canonical-ast-final-cutover -TimeoutMs 1800000 -NoXGE`.
- [ ] Run focused Frontend, Compiler, Runtime, Module, TypeSystem, Language, Embedding, Conformance, Cache, HotReload, StaticJIT, Debugger and CodeCoverage prefixes; record exact pass/fail/skip/timeout counts.
- [ ] Run `Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix canonical-ast-final-standalone -TimeoutMs 600000`.
- [ ] Run `Tools\RunTestSuite.ps1 -Suite StandaloneRelease -LabelPrefix canonical-ast-final-standalone-release -TimeoutMs 1200000`.
- [ ] Run `Tools\RunTestSuite.ps1 -Suite All -LabelPrefix canonical-ast-final-all -TimeoutMs 3600000` and require zero new failures/skips/timeouts beyond repository-baselined Disabled tests.
- [ ] Run `openspec validate "refactor-as-canonical-typed-ast-compiler" --strict`, Markdown/link/source/ABI/determinism scans and parent/plugin `git diff --check`.
- [ ] Reconcile all requirements and scenarios against fresh evidence; check `12.2`, `12.4`, `13.12` and remaining umbrella tasks only when their exact wording is true.
- [ ] Do not archive. Report completion and wait for an explicit archive/integration request.

## Working Rule for Progress Updates

At the end of every slice, append to `attachments/final-completion-issue-log-2026-08-27.md`:

1. issue/root cause and affected task IDs;
2. exact source fixture and sealed AST fact;
3. RED report path;
4. production changes and why they preserve the architecture;
5. AST, CodeGen/provenance, lifecycle and focused regression reports;
6. remaining boundaries and whether any checkbox may truthfully close.

This avoids turning `tasks.md` into an unreadable debug journal while keeping every problem and decision inside the OpenSpec attachment set as requested.
