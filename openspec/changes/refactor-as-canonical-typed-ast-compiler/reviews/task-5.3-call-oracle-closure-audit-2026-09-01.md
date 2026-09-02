# Task 5.3 historical call-oracle closure audit — 2026-09-01

## Decision

Task 5.3 is `[x]` after CTA-S175. The twelve reverse-operator families, the
historical compile-out call-rewrite oracle, and import bind/rebind/unbind
snapshot immutability are complete. Binding changes only the Runtime import
slot; the retained Canonical `ImportDecl`, call relation, dump and Sidecar bytes
remain immutable.

Formal status is now **108/136 (79.4%)** with **28** rows open.

## Audit basis

- HIR removal commit: `4e5d3d2` (`[CanonicalAST] Refactor: add canonical typed AST compiler checkpoint`).
- Last tree containing the retired tests: `ed22fbdf`.
- Literal historical path match: seven test methods in `CallMetadata`,
  `CallRewrites`, `CallTargets`, and `EvaluationOrder/Calls`.
- Current Canonical contract inspected: `asCExpr`, `asSASTCallArgument`,
  `asCDecl`, Sema call construction, verifier, Sidecar, production CodeGen,
  and Canonical test prefixes.
- CTA-S174 evidence: Canonical Sema seals the three generic-call compile-out
  dispositions, CodeGen consumes only the sealed `CallRewrite`, verifier and
  Sidecar V12 authenticate the final relation, and discarded operands are
  removed without diagnostics or dangling semantic nodes.

The empty `TypedSemanticIR` directories in the worktree are not missing
checkout content. Git records the files as deliberately deleted with HIR.

## Historical oracle mapping

| Retired test method | Canonical disposition | Audit result |
|---|---|---|
| `HiddenDefaultRemainsAHostOriginInFinalFormalOrder` | `HiddenArgumentInjectedOnNativeCallee`, `HiddenMiddleArgumentExecutesSealedFormalPlan`, and the WorldContext gate authenticate HIDDEN origin, no source ordinal, exact formal, reverse-formal child identity, injection and execution. | Covered for 5.3. |
| `NativeOnlyInputsRemainOutsideScriptOperandsAndResultIsConcrete` | Canonical calls retain only source/hidden/receiver expressions and the concrete Sema result type. Registered native callee identity is an EXTERNAL Canonical declaration. First-param metadata, generic context, user data, determines-output ABI and bridge selection belong to Task 7.4's immutable Runtime binding snapshot, not ABI-independent AST children. | 5.3 call shape covered; 7.4 ABI closure intentionally not claimed. |
| `CompilerRewritesPublishFinalValuesWithoutExecutableCalls` | CTA-S174 adds append-only `CallRewrite` plus sealed traits for `CompileOutEntirely`, `ReplaceWithFirstParam`, and `CompileOutAsMethodChain`. Sema publishes the final rewrite before ordinary argument resolution; verifier, Sidecar V12 and CodeGen consume the sealed shape. | **Covered for 5.3.** |
| `ConcreteScriptSystemSharedAndExternalTargetsRetainDistinctBodyOwnership` | Canonical uses exact Decl kind, EXTERNAL/generated traits, `body`, `origin`, parent and stable key rather than a duplicate HIR body-ownership enum. Prepared-shell/body and native/script call tests authenticate these facts. | Canonical representation covered; downstream closure still belongs to 7.2/7.4. |
| `BindRebindAndUnbindRetainTheImportedSlotInsteadOfTheMutableBoundFunction` | CTA-S175 seals one provider-A `ImportDecl` plus stable signature/origin and a concrete zero-argument `int` Call. Bind A, rebind B and unbind mutate only `sBindInfo::boundFunctionId`; dump and Sidecar V12 bytes remain identical. CodeGen retains `CALLBND` and executes `11 -> 29 -> exception`. | **Covered for 5.3**; 7.4 still owns complete native ABI/bridge consumption. |
| `TwoThreeAndEightOperandsRetainResolvedCallsAndReceiverPosition` | Canonical construction/index/call tests authenticate explicit receiver, formal records, source identities, and ordered children; production tests consume the sealed relation. | Covered for 5.3; sequencing umbrella 5.4 remains separate. |
| `TwoThreeAndEightArgumentsRetainReverseFormalEvaluation` | `ReverseFormalChildrenMatchStoredOrder`, formal-ordinal mutation tests, Sidecar V9, and production call-argument tests authenticate reverse-formal storage independently of declaration child order. | Covered for 5.3. |

The task also names non-literal `Call*` themes. Current gates cover ordinary,
member, mixin and import calls; positional/named/default/hidden arguments;
effective receivers; exact formal provenance; property/operator/conversion
rewrites; direct/virtual/indirect/import dispatch; and stable declaration
dependencies. CTA-S132–S173 record those slices individually.

## Why native ABI is not copied into `CallExpr`

The approved design assigns Sema the **ABI-independent call shape** and assigns
native bridge/direct/fallback metadata to an immutable Runtime binding
snapshot. Copying Runtime `asCScriptFunction` fields such as first-param
metadata, generic user data, determines-output indices, or generation-local
function/import IDs into `asCExpr` would make the retained AST a mutable
Runtime cache and violate the pointer-free/stable-identity design.

Task 5.3 now proves that ABI-only inputs do not masquerade as script operands,
that Sema publishes the concrete result type, and that mutable Runtime import
binding never retargets the AST. Task 7.4 must still prove the complete native
ABI and bridge disposition from the sealed call plus the binding snapshot.
This audit does not collapse those tasks into one checkbox.

## Corrected remaining sequence for Task 5.3

1. CTA-S174: complete. Canonical Sema publishes the final value/void/method-
   chain rewrite and removes discarded authored operands before diagnostics;
   CodeGen executes only the retained final value.
2. CTA-S175: complete. Bind/rebind/unbind changes only the Runtime slot; the
   sealed declaration, call relation, dump and V12 bytes remain immutable.
3. Native call-shape audit: complete for the ABI-independent AST. Only
   Canonical arguments and the concrete result type cross Sema; ABI/bridge
   consumption remains in 7.4.
4. Complete gates: SemaAuthority **533/533**, Frontend CanonicalAST **189/189**,
   ProductionCodeGen **229/229**, and Cache V12 **586/586**, all zero
   failures/skips. Task 5.3 is accepted.

This supersedes the CTA-S171/S172 statement that reverse-family completeness
was the only remaining 5.3 item. That statement was accurate for the actively
enumerated source-language call-family list, but it had not yet resolved the
task's explicit historical-oracle clause against Git history.
