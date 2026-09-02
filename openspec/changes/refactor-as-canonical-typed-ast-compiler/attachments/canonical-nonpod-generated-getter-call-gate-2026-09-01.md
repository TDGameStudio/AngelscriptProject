# Canonical non-POD generated getter Call (CTA-S144)

Date: 2026-09-01

## Scope

Next Task 5.3 ProductionCodeGen remainder after CTA-S143. A stored non-POD
VALUE field used as a property rvalue (`Owner.Inner.ReadStored()`) must
rewrite to the generated `GetInner()` Call so the getter's by-value copy
constructor runs. TMap `Iterator` / `opFor*` receivers stay MEMBER_REF
(CTA TMap gate 2026-08-31).

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: `Owner.Inner.ReadStored()` is Call of generated GetInner

- **OpenSpec task(s):** `5.3`, overlapping `13.2`
- **Source fixture:**
  ```as
  struct FGeneratedGetterOwner
  {
      FGeneratedGetterValue Inner;
      void SetInner() {}
  }

  int Entry()
  {
      FGeneratedGetterOwner Owner;
      return Owner.Inner.ReadStored() + 1;
  }
  ```
- **Canonical facts:**
  1. Sealed `GetInner` method with `accessor=Get` of field `Inner`.
  2. `ReadStored` Call receiver is a Call of that `GetInner`, not leftover
     `MemberRef Inner`.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalGeneratedNonPodGetterCallRewritesMemberRead`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::PreparedNativeNonPodGeneratedGetterSealsAndInvokesExactCopyConstructor`
- **AST-red:** `cta-sema-call-53-getter-red2` `20260901_062110_234_012f6df7` 0/1.
  First `Build()` RED (`cta-sema-call-53-getter-red`) failed CodeGen of
  generated `opAssign` (`code=-6`); retargeted to Stage2+Seal. Sealed graph
  had leftover `MemberRef Inner` as `ReadStored` receiver while generated
  `GetInner` existed with copy-constructor inits.
- **AST-green:** `cta-sema-call-53-getter-green` `20260901_062246_768_39a5eb9c` 1/1.
  `ActOnCallExpr` rewrites MEMBER_REF of an exact-value field to generated
  GetX except for in-place protocol callees (`Iterator` / `opFor*`).
- **CodeGen/provenance:** `cta-sema-call-53-getter-codegen-green`
  `20260901_062322_673_2bc653e0` 1/1.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **485/485** `cta-ast-first-sema`
  `20260901_062358_914_cc1d2fd6` (includes TMap Iterator MEMBER_REF);
  Frontend CanonicalAST **189/189** `cta-ast-first-frontend`
  `20260901_062531_999_0ea96fe4`; ProductionCodeGen **148/149**
  `cta-ast-first-prodcodegen` `20260901_062610_066_3bf4fffe`. Remaining
  ProductionCodeGen: imported-dependency generation.
- **Remaining boundary:** 5.3 stays `[ ]`. Does not check 5.4–5.9, 13.2, or
  section 10.
