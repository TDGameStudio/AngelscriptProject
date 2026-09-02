# Canonical array opIndex rvalue decay (CTA-S140)

Date: 2026-09-01

## Scope

Starts the next Task 5.3 ProductionCodeGen remainder: Canonical
`array<int> F()` must execute `42`, not a garbage pointer. After CTA-S132,
`Values[0]` is a Call of `array<int>::opIndex(uint)` whose QualType is `int&`
lvalue. Builtin `+` currently takes that Call as a Binary operand. CodeGen
`EmitCall` returns the pointer slot for a reference result; `EmitBinary` then
adds `1` to the address bits (`F() == 1904702641`). Clang loads an lvalue
reference before arithmetic (`LValueToRValue`). Canonical Sema must seal that
decay before CodeGen consumes it.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: `Values[0] + 1` decays `opIndex` int& to rvalue int

- **OpenSpec task(s):** `5.3`, overlapping `13.2`
- **Source fixture:**
  ```as
  int Entry()
  {
      array<int> Values;
      Values.insertLast(41);
      return Values[0] + 1;
  }
  ```
- **Canonical facts:**
  1. `Values[0]` is `asAST_EXPR_CALL` of `array<int>::opIndex(uint)`.
  2. That Call is an `int` reference lvalue.
  3. The Binary `+` left operand is a Conversion of that Call to non-reference
     rvalue `int`, not the leftover reference Call.
  4. Canonical CodeGen loads the aliased int so `Entry() == 42` / `F() == 42`.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalArrayIndexCallDecaysToRvalueBeforeArithmetic`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::CanonicalArrayIntBuildPublishesCodeGenAndExecutes`
- **AST-red:** focused `cta-sema-call-53-array-red`
  `20260901_050918_197_e512852a` **0/1**. First fact (opIndex Call is `int&`
  lvalue) passed; Binary `+` lhs stayed the leftover reference Call
  (`callee=array<int>::opIndex(uint)`, `type=int quals=8`).
- **AST-green:** focused `cta-sema-call-53-array-green`
  `20260901_051109_516_783b1b24` **1/1**. Sema
  `DecayScalarLValueReferenceToRValue` after operator-method rewrite; CodeGen
  `EmitConversion` loads primitive/enum src-ref → dest-nonref.
- **CodeGen/provenance:** focused
  `cta-sema-call-53-array-codegen-green` `20260901_051149_381_b29d8d8e` **1/1**.
  `CanonicalArrayIntBuildPublishesCodeGenAndExecutes` `F()==42`, publisher
  Canonical CodeGen, zero `asCCompiler` invocations.
- **Lifecycle:** `N/A` (no Cache/snapshot/JIT boundary).
- **Prefix regression after first green:** SemaAuthority **493/496**
  `cta-ast-first-sema` `20260901_051226_145_8a8f2949`. Three Seal failures:
  `ParamQualifiersKeepDistinctStableKeysOnCompileSeal` (CANONICAL Build
  discarded the graph), `SourceForeachSealsResolvedProtocolPlanBeforeCodeGen`
  and `SourceKeyedForeachSealsBothDeclarationsAndResolvedKeyProtocol`
  (LEGACY Build succeeded, retained Canonical AST was null).
  `SourceObjectIteratorForeachSealsExactLifetimeCleanupPlan` stayed green
  because `Iterator.Index` is a non-reference member lvalue.
- **Root cause:** `asASTQualifiersAreValid` rejects parameter direction
  (`IN`/`OUT`/`INOUT`) without `REFERENCE`. Decay copied `const int &in` /
  `int &inout` QualTypes and only cleared `REFERENCE`, so the Conversion
  node had `IN`/`INOUT` on a non-reference type and Seal failed with
  `expr-quals`.
- **Repair:** strip `asAST_QUAL_REFERENCE | asAST_QUAL_PARAM_DIR_MASK` on
  the decay destination. LValueToRValue is a value, not a parameter.
- **Focused quals GREEN:** param `cta-s140-quals-param`
  `20260901_052044_386_e053c91a` **1/1**; foreach `cta-s140-quals-foreach`
  `20260901_052112_418_45e78ee6` **1/1**; keyed `cta-s140-quals-keyed`
  `20260901_052139_873_2b098a70` **1/1**; array `cta-s140-quals-array`
  `20260901_052207_420_c52de6c3` **1/1**.
- **CodeGen crash after quals-only repair:** ProductionCodeGen
  `CanonicalForeachExecutesSealedProtocolWithoutLegacyCompiler` AV
  `0xffffffffffffffff` in `asCContext::ExecuteNext`. `EmitDeclRef` of a
  parameter `T&` already loads the pointee; wrapping that DeclRef in
  LValueToRValue made `EmitConversion` dereference the loaded int as a
  pointer (`Iterator = Iterator + 1`).
- **Second repair:** decay only `asAST_EXPR_CALL` / `asAST_EXPR_INDEX`
  (EmitCall/EmitIndex leave a pointer slot). DeclRef of `const int &in` /
  `int &inout` stays a Binary operand; CodeGen already loads it.
- **Focused DeclRef GREEN:** param `cta-s140-declref-param`
  `20260901_052736_945_498d90fa` **1/1**; foreach AST
  `cta-s140-declref-foreach`; keyed `cta-s140-declref-keyed`; array Sema
  `cta-s140-declref-array`; foreach exec `cta-s140-declref-foreach-exec`;
  array exec `cta-s140-declref-array-exec`
  `20260901_052954_825_d177d0a4` **1/1** (`F()==42`).
- **Focused regression:** SemaAuthority **481/481**
  `cta-ast-first-sema` `20260901_053039_163_2f6f1bb1`; Frontend
  CanonicalAST **189/189** `cta-ast-first-frontend`
  `20260901_053159_759_1889c9fb`; ProductionCodeGen **143/149**
  `cta-ast-first-prodcodegen` `20260901_053231_051_0f66a039`. Array and
  native same-arity index/method are green. Six remaining Build/Stage2
  failures: `CanonicalDoubleToFloatPublishesNormalizedTemporaryType`,
  two namespace publishes, two prepared-import, native non-POD getter
  copy-ctor.
- **Remaining boundary:** 5.3 stays `[ ]` until those named
  ProductionCodeGen failures are green. Does not check 5.4–5.9, 13.2, or
  section 10. Product default stays LEGACY.
