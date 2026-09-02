# Canonical bitwise-not opCom rewrite (CTA-S152)

Date: 2026-09-01

## Scope

Continues the remaining Task 5.3 call-provenance sentence that overlaps 13.2:
Canonical Bytecode must consume a sealed operator-call rewrite and must not
rerun `asCCompiler`. LEGACY `CompileUnaryOperator` maps `ttBitNot` on objects
to `opCom`. Canonical `ActOnUnaryExpr` only ranked `-`/`++`/`--`, so `~Object`
sealed leftover `Unary ~` of `T` typed as `int` while `T::opCom() const` sat
unused.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: `~Object` seals `opCom` Call

- **OpenSpec task(s):** `5.3`, overlapping `13.2`
- **Source fixture:**
  ```as
  struct T
  {
      int Stored = 0;

      int opCom() const
      {
          return Stored == 5 ? 42 : 0;
      }
  }

  int Entry()
  {
      T Object;
      Object.Stored = 5;
      return ~Object;
  }
  ```
- **Canonical facts:**
  1. Entry's return expression is `asAST_EXPR_CALL` of `T::opCom() const`,
     not leftover `Unary ~` of `T`.
  2. The Call seals `receiver=` of `Object` and zero call arguments
     (the operand is the receiver, not a positional formal).
  3. Dispatch is `direct` (VALUE owner, no script vtable).
  4. Bytecode publisher is `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` and
     `GetLastLegacyCompilerInvocationCount() == 0`.
  5. `Entry() == 42` through Canonical CodeGen.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalBitwiseNotRewritesToOpComCallWithoutLegacyCompiler`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::CanonicalBitwiseNotExecutesOpComCallWithoutLegacyCompiler`
- **AST-red:** `cta-sema-call-53-opcom-red` `20260901_081115_320_b98c56fa`
  **0/1 FAIL**. Build succeeded. Dump: `EXPR 22 Unary type=int literal=~`
  of DeclRef `Object`. `T::opCom() const` was DECL 4 and unused.
- **AST-green:** `cta-sema-call-53-opcom-green` `20260901_081307_915_b0157fdf`
  **1/1 PASS**. `ActOnUnaryExpr` maps `~` to `opCom`. Unary operator methods
  now use `ArrangeCallArguments` with empty formals so the operand is only
  the receiver.
- **CodeGen/provenance:** `cta-sema-call-53-opcom-codegen-green`
  `20260901_081347_611_73ad21fe` **1/1 PASS**. Publisher is
  `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, legacy compiler count is 0,
  `Entry() == 42`.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority
  `FCanonicalASTSemaAuthorityTests` **493/493** `cta-ast-first-sema`
  `20260901_082415_529_e3c8d4e5`, Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_081639_784_6334c015`, ProductionCodeGen
  `FCanonicalASTProductionCodeGenTests` **156/156**
  `cta-ast-first-prodcodegen` `20260901_082312_036_9584ae19`.
- **Remaining boundary:** 5.3 stays `[ ]` (remaining ordinary/member/mixin/
  import/native call families, argument provenance completeness, backends
  that still rerun Sema, and product-default LEGACY). Does not check 5.4–5.9,
  13.2, or section 10. Product default stays LEGACY.
  Primitive `~int` stays builtin Unary. A broader ProductionCodeGen prefix
  that also matches ScriptCorpus remains a separate 5.9/9.7 surface
  (`FormatSpecifiersAndNamedPrintCompile` is not this card).
