# Canonical float64-to-float32 functional cast (CTA-S141)

Date: 2026-09-01

## Scope

Next Task 5.3 ProductionCodeGen remainder after CTA-S140. Canonical
`float32 Narrow(float64 Value) { return float32(Value); }` must Seal a
Conversion whose destination intern is `ttFloat32` and publish `dTOf`
temporaries. `CanonicalIntegerNarrowingPublishesNormalizedTemporaryTypes`
already Builds `uint8(Value)` / `uint16(Value)`; the float32 functional
cast currently fails Canonical `Build()`.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: `float32(Value)` seals Conversion dest=ttFloat32

- **OpenSpec task(s):** `5.3`, overlapping `13.2`
- **Source fixture:**
  ```as
  float32 Narrow(float64 Value)
  {
      return float32(Value);
  }
  ```
- **Canonical facts:**
  1. `float32(Value)` is `asAST_EXPR_CONVERSION`, not an unresolved Call.
  2. Destination QualType intern is primitive `ttFloat32` (stable key
     `float` in the current intern table).
  3. Source is the `float64` / `double` parameter.
  4. Canonical CodeGen emits `dTOf` and publishes a `ttFloat32` temporary.
- **AST test:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  `FCanonicalASTSemaAuthorityTests::CanonicalFloat64ToFloat32CastSealsConversion`
- **CodeGen test:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
  `FCanonicalASTProductionCodeGenTests::CanonicalDoubleToFloatPublishesNormalizedTemporaryType`
- **AST-red:** focused `cta-sema-call-53-float32-red2`
  `20260901_053740_169_158f1fff` **0/1**. Canonical `Build()` returned
  `-10` with
  `shadow-declaration-mismatch path=decl.type left="float/q0" right="float32/q0"`.
  `InternPrimitive(ttFloat32)` interned stable key `"float"`, colliding with
  the engine `float` spelling while Builder identity is `"float32"`.
- **AST-green:** focused `cta-sema-call-53-float32-green`
  `20260901_054007_184_5f08e9be` **1/1**. `InternPrimitive` now keys
  `ttFloat32` as `"float32"` (distinct from `ttFloat`/`ttFloat64`).
  Sealed Conversion dest intern is `ttFloat32`.
- **CodeGen/provenance:** focused
  `cta-sema-call-53-float32-codegen-green` `20260901_054035_157_aebcfb19`
  **1/1**. `CanonicalDoubleToFloatPublishesNormalizedTemporaryType`
  Builds, emits `dTOf`, publishes a `ttFloat32` temporary, publisher
  Canonical CodeGen.
- **Lifecycle:** `N/A`
- **Focused regression:** SemaAuthority **482/482**
  `cta-ast-first-sema` `20260901_054554_412_07c2e67c` (cast/literal oracles
  now expect the `float32` intern key). Frontend CanonicalAST **189/189**
  `cta-ast-first-frontend` `20260901_054715_523_9347476b`. ProductionCodeGen
  **144/149** `cta-ast-first-prodcodegen` `20260901_054746_876_39358a39`.
  `CanonicalDoubleToFloatPublishesNormalizedTemporaryType` is green. Five
  remaining: two namespace publishes, two prepared-import, native non-POD
  getter copy-ctor.
- **Remaining boundary:** 5.3 stays `[ ]`. Sibling remaining ProductionCodeGen
  failures (namespace publish, prepared import, native non-POD getter) are
  later cards. Does not check 5.4–5.9, 13.2, or section 10.
