# Canonical namespaced function runtime namespace (CTA-S142)

Date: 2026-09-01

## Scope

Next Task 5.3 ProductionCodeGen remainder after CTA-S141. Canonical
`namespace Tools::Utilities { const int Value = 41; int Entry() { return Value; } }`
must Seal nested Namespace decls, function key `Tools::Utilities::Entry()`,
and publish that function in the exact runtime namespace (not root
`Entry()`). Parser→Sema→Seal already owns scoped call keys; production
CANONICAL `Build()` currently fails closed.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: `Tools::Utilities::Entry` seals and publishes exact namespace

- **OpenSpec task(s):** `5.3`, overlapping `13.2`
- **Source fixture:**
  ```as
  namespace Tools::Utilities
  {
      const int Value = 41;

      int Entry()
      {
          return Value;
      }
  }
  ```
- **Canonical facts:**
  1. Nested `kind=Namespace name=Tools` and `name=Utilities`.
  2. Function stable key `Tools::Utilities::Entry()`.
  3. Function parent is the inner `Utilities` namespace, not the TU.
  4. Runtime `GetFunctionByDecl("int Tools::Utilities::Entry()")` succeeds;
     root `int Entry()` is absent. Canonical CodeGen publishes Bytecode.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalNamespacedFunctionSealsExactRuntimeNamespace`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::CanonicalNamespaceFunctionBuildsAndPublishesExactRuntimeNamespace`
- **AST-red:** focused `cta-sema-call-53-ns-red`
  `20260901_055233_083_431dbb5e` **0/1**. Canonical `Build()` returned
  `-10` with
  `shadow-declaration-mismatch path=decl.parent left="ns:Utilities" right="ns:Tools::Utilities"`.
  `CanonicalOwnerIdentity` used only the inner namespace spelling.
- **AST-green:** focused `cta-sema-call-53-ns-green`
  `20260901_055358_180_813910c8` **1/1**. Nested Namespace decls walk to a
  `::`-joined owner identity matching Builder `nameSpace->name`.
- **CodeGen/provenance:** focused
  `cta-sema-call-53-ns-codegen-green` `20260901_055426_207_d3ee4c50`
  **1/1**. `CanonicalNamespaceFunctionBuildsAndPublishesExactRuntimeNamespace`
  publishes `int Tools::Utilities::Entry()`, not root `Entry()`, executes
  `41`, publisher Canonical CodeGen.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **483/483**
  `cta-ast-first-sema` `20260901_055511_911_61ee3c9e`; Frontend CanonicalAST
  **189/189** `cta-ast-first-frontend` `20260901_055632_565_0e2974c7`;
  ProductionCodeGen **146/149** `cta-ast-first-prodcodegen`
  `20260901_055703_536_968ce2b7`. The sibling namespaced value-object
  method publish is also green. Three remaining: two prepared-import,
  native non-POD getter copy-ctor.
- **Remaining boundary:** 5.3 stays `[ ]`. Does not check 5.4–5.9, 13.2, or
  section 10. Product default stays LEGACY.
