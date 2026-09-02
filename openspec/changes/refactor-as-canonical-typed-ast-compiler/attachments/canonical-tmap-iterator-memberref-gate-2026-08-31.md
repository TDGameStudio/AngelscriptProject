# Canonical TMap Iterator MEMBER_REF vs GetX copy gate (2026-08-31)

Clang `MemberExpr` is storage/lvalue. AngelScript generated `GetActorMap()` is
by-value property sugar. A stored `TMap` / non-POD VALUE field used as an
Iterator (or other mutating/lvalue) receiver must stay `MEMBER_REF` of the
field. Rewriting it to `GetActorMap()` iterates a copy.

This advances `5.2` and `13.2` for one stored-container lvalue family. It does
not close those umbrellas, primitive GetX (already a different card), or
section 10.

### Gate card: `ActorMap.Iterator()` is MEMBER_REF of the stored field

- **OpenSpec task(s):** `5.2`, `13.2` (slice); `5.9` language form only
- **Source fixture:** complete-type member access
  `Owner.ActorMap.Iterator()` where `Owner` is `ASemaMapActor` /
  `ACorpusMapMemberRefActor` with stored `TMap<AActor, FString> ActorMap`.
  Unqualified `ActorMap` inside the owning method is a field `DeclRef` and is
  not this card. Production twin is any complete-type TMap member used as an
  Iterator receiver. `Example_Map.as` `PrintActorMap` uses the unqualified
  field name after preprocessor rewrite.
- **Canonical fact:** sealed graph has `kind=MemberRef` whose literal/callee is
  the stored `ActorMap` field; dump does **not** contain `GetActorMap`.
  `Iterator()` is a method call on that MEMBER_REF. Forward-referenced and
  immediately-visible fields must agree (delayed rebind must not diverge).
- **AST test:**
  - `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
    `StoredTMapIteratorReceiverStaysMemberRefNotGeneratedGet`
  - `AngelscriptNativeCanonicalASTProductionScriptCorpusTests.cpp`
    `RangeForOverMapIteratorSealsMemberRefNotGeneratedGet`
- **AST-red:** focused SemaAuthority
  `cta-tmap-memberref-sema-red` `20260831_212536_231_561be304` **0/1** and
  ScriptCorpus `cta-tmap-memberref-corpus-red` `20260831_212607_925_c3597c7f`
  **0/1**. Complete-type `Owner.ActorMap.Iterator()` rewrote to Call
  `GetActorMap()`; CodeGen then failed `missing callable relocation`
  `targetName=GetActorMap` (`asNOT_SUPPORTED` / code=-6). Unqualified
  `this.ActorMap` during class parse was a false green (accessors not yet
  interned).
- **AST-green:** SemaAuthority `cta-tmap-memberref-sema-green`
  `20260831_212807_857_35361bc9` **1/1**. ScriptCorpus
  `cta-tmap-memberref-corpus-green` `20260831_212840_131_90c95528` **1/1**.
  Primitive GetX regression `GeneratedAccessorsHaveGeneratedTraitAndCallPlan`
  `cta-pod-get-rewrite-reg` `20260831_212925_343_d4047dd6` **1/1**. Repair:
  `ActOnMemberExpr` returns MEMBER_REF when
  `RequiresExactValueObjectPlan(fieldType)` before TryRewritePropertyGet.
- **CodeGen/provenance:** extra-module ScriptCorpus **18/18**
  `cta-script-corpus` `20260831_213024_741_21ea9fc0`. Whole-engine Canonical
  `Script/` compile (`-as-canonical-staged-compiler`) `cta-whole-engine-script`
  `20260831_215416_535_6962a9b8`: Cutover **15/15**, script compilation total
  931670.606 ms, Automation.log has zero `PropertyFromFieldDecl`,
  `Canonical Sema diagnostic`, or `Canonical CodeGen failed` lines. Does not
  check 5.2/13.2/10.x.
- **Lifecycle:** whole-engine row above. Repeat Cutover
  `cta-whole-engine-script-2` `20260831_221129_991_4bc8188e` also **15/15**
  with the same zero-error Automation.log scan. Not a parent-umbrella close.
- **Focused regression:** SemaAuthority primitive GetX
  `GeneratedAccessorsHaveGeneratedTraitAndCallPlan` **1/1**. Named SemaAuthority
  `cta-ast-first-sema` `20260831_213649_449_5a75723f` **475/475**. Named
  ScriptCorpus `cta-script-corpus` `20260831_213024_741_21ea9fc0` **18/18**.
  ProductionCodeGen named prefix from the factory/handle wrap-up remains
  **196/196**; re-run after this Sema skip if other umbrellas need it.
- **Remaining boundary:** user-authored GetX on TMap (explicit call is a copy
  by source), nested template Sema (`4.3`), product-default cutover.
