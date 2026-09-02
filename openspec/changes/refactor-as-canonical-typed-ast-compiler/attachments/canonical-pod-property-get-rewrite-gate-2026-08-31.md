# Canonical POD property Get rewrite gate (2026-08-31)

This card restores Clang-style property-read authority on the CANONICAL path:
`obj.Field` is a Sema-authored `GetField` Call whenever a getter exists,
including generated accessors on non-POD fields. MEMBER_REF remains only when
no GetX binds. Copying a TMap through GetActorMap() is the by-value getter
contract, not a reason to hide the accessor.

It advances tasks `5.2`, `5.3`, `5.9`, and `13.2` without completing those
umbrellas. Template-instance/namespace Sema (`4.3`), shadow mismatch (`4.6`),
full call-family provenance, and default cutover stay open.

### Gate card: primitive/POD property read rewrites to GetX

- **OpenSpec task(s):** `5.2`, `5.3`, `13.2` (slice); `5.9` language form only
- **Source fixture:**
  - `return v.Value;` on `class T { int Value = 3; }` (generated GetValue)
  - `v.Value = 4; return v.Value;` with user `GetValue`/`SetValue`
  - `return FValue().Value + 1;` (temporary receiver + generated getter)
  - `Fill(Box.Value)` with `int& out` (deferred-out requires a Get Call)
  - `FScriptReference Object; return Object.Value + 1;` (field default 41)
- **Canonical fact:** sealed Call `callee=T::GetValue()` / `GetInner()` with
  explicit receiver; generated accessors keep `traits=256` and
  `accessor=Get:Value#`; out-only formals wrap the Get into
  `asAST_EXPR_DEFERRED_OUT` with the exact setter. MEMBER_REF is only the
  no-getter residual.
- **AST test:** `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  methods `GeneratedAccessorsHaveGeneratedTraitAndCallPlan`,
  `PropertyReadWriteRewritesToAccessors`,
  `TemporaryValueReceiverSealsExactMaterializationAndGetterPlan`,
  `PropertyOutArgumentSealsDeferredWriteBackPlanBeforeCodeGen`,
  `CompileSealScriptReferenceLocalDefaultConstructRecordsInitOnVar`.
  They inspect the sealed dump / context, not VM-only output (the last method
  also executes and requires return `42`).
- **AST-red:** `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label cta-ast-first-sema`
  on 2026-08-31, report `Saved/Tests/cta-ast-first-sema/20260831_200121_741_a70e6b01`,
  **469/474**. `ActOnMemberExpr` returned MEMBER_REF whenever a stored field
  existed, so dumps lacked `callee=T::GetValue()`, deferred-out never formed,
  and the script-reference local returned the wrong default.
- **AST-green:** same prefix, report
  `Saved/Tests/cta-ast-first-sema/20260831_200829_385_1fa25210`, **474/474**.
  `as_sema_expr.cpp` `ActOnMemberExpr` rewrites GetX unless
  `RequiresExactValueObjectPlan(field->type)`. Live code later dropped that
  guard (always-GetX). Restored on 2026-08-31 by
  `attachments/canonical-tmap-iterator-memberref-gate-2026-08-31.md`.
- **CodeGen/provenance:** ProductionCodeGen named prefix after the Sema
  repair (see this wrap-up's `cta-ast-first-codegen` report). Extra-module
  ScriptCorpus range-for over `TArray`/`TMap` must remain MEMBER_REF +
  Iterator, not GetX copy.
- **Lifecycle:** N/A for this slice (no Cache/snapshot/JIT identity change).
- **Focused regression:** SemaAuthority **474/474**; Frontend.CanonicalAST
  remains a sibling named prefix (prior wrap-up **185/185** after the
  `null-conversion-target` token repair).
- **Remaining boundary:** non-POD GetX copy-construction, user-authored GetX
  on TMap, Parser-node `ActOnExprFromNode` walks, template-instance Sema,
  and product-default cutover.

## Repair

`asCSema::ActOnMemberExpr` previously short-circuited every resolved field to
`MEMBER_REF` so `ActorMap.Iterator()` would not copy a TMap. That also stole
primitive property reads from Sema. The repair keeps the TMap/TArray
MEMBER_REF exception behind `RequiresExactValueObjectPlan` and restores
`TryRewritePropertyGet` for every other stored field that has a GetX.
