# CTA-S98 derived-funcdef source-formal relation gate — 2026-08-30

## Outcome

CTA-S98 closes the reachable derived-funcdef producer/reuse/consumer gap left
by CTA-S90. The defect was not a Runtime calling-convention mismatch. It was a
loss of exact source identity after two distinct AngelScript formals normalized
to the same maintained Runtime ABI:

```text
source formal A: FValue
source formal B: const FValue&inout

normalized Runtime shell for both:
    parameter type = const FValue&
    passing flag   = asTM_INOUTREF
```

Before this slice, `asCScriptEngine::FindMatchingFuncdef` compared only the
normalized Runtime signature. A source-owned function could therefore reuse an
empty-metadata host funcdef, and two source-distinct functions could reuse one
derived funcdef. Lambda viability, omitted-lambda contextualization and
indirect funcdef call planning then reconstructed their formal type from that
same lossy ABI and silently accepted or published the wrong source relation.

The producer now treats exact source-formal qualifiers as part of funcdef reuse
identity whenever that metadata exists. The consumers use
`asCRuntimeTypeBridge::FromScriptFunctionParameterABI`, which authenticates and
projects the exact per-formal source metadata. Host/native funcdefs that have
no Canonical source declaration deliberately retain the older normalized-ABI
fallback.

## Root cause

CTA-S90 already publishes one
`canonicalASTSourceParameterQualifiers[formalIndex]` entry for each Canonical
source formal, including an explicit zero for by-value. The remaining break was
at the derived-funcdef boundary:

1. `FindMatchingFuncdef` used `IsSignatureExceptNameEqual` only;
2. the function also initialized its result from `func->funcdefType`;
3. in this maintained fork `asCScriptFunction::funcdefType` is historical
   `static` shared state, not an authentic per-function cache;
4. a newly allocated derived funcdef copied Runtime parameter types and passing
   flags but not the source qualifier vector;
5. Sema funcdef consumers called the ABI-only inverse and therefore had no way
   to distinguish source by-value from explicit `const &inout`.

The shared static field is wider historical debt, but trusting it here was both
unnecessary and unsafe. CTA-S98 recovers an existing funcdef type by exact
`funcDefs[n]->funcdef == func` identity and otherwise performs authenticated
signature reuse. This bounded repair does not change the public or internal
`asCScriptFunction` layout.

## Contract implemented

### Producer and reuse

`FindMatchingFuncdef` now applies the following relation:

- a non-empty source qualifier vector must have exactly one element per Runtime
  formal;
- a keyed Canonical source function with formals must carry the complete
  vector, including zero for authored by-value;
- normal Runtime signature equality remains necessary;
- exact source metadata versus empty host/native metadata is not reusable;
- two exact source signatures are reusable only when their complete qualifier
  vectors are equal;
- an exact funcdef function identity still resolves to its own existing
  `asCFuncdefType`;
- a newly allocated derived funcdef copies the complete source qualifier vector.

The donor function's stable declaration key is intentionally not copied to the
derived funcdef shell. A derived funcdef is a reusable signature type, not the
donor function declaration. Copying a declaration key would create false
ownership and would make later reuse depend on the first donor's name.

Zero-parameter signatures continue to use ordinary Runtime signature equality:
there is no source-formal relation to distinguish.

### Sema consumers

The following reachable consumers now use the function-aware bridge:

- explicit lambda viability against a Runtime funcdef;
- omitted lambda formal inference and explicit-formal validation during
  funcdef contextualization;
- indirect callable formal-view construction and call-plan publication.

For a complete exact source vector, these paths compare or publish the authored
`asCQualType`, not the normalized ABI approximation. For an empty host/native
funcdef vector, the existing normalized-ABI compatibility remains available.
A keyed source shell with missing or partial metadata fails closed.

## Adversarial fixture

`DerivedFuncdefPreservesExactSourceFormalIdentityAcrossReuseAndSemaConsumers`
registers a POD value type and an empty-metadata host funcdef with the colliding
normalized ABI, then compiles two CANONICAL source functions:

```angelscript
bool CTADerivedByValue(FCTADerivedFuncdefValue Value);
bool CTADerivedExplicit(
    const FCTADerivedFuncdefValue&inout Value);
```

The fixture first proves that both Runtime shells have identical parameter
datatypes and `asTM_INOUTREF`, while their source vectors are respectively
`[0]` and `[CONST | REFERENCE | INOUT]`. It then verifies:

- neither source-owned signature reuses the empty-metadata host funcdef;
- the two source-distinct signatures receive distinct derived funcdef types;
- each derived funcdef copies its exact qualifier vector;
- repeated lookup reuses the same exact source-owned funcdef;
- explicit by-value and explicit-reference lambdas are viable only for their
  corresponding exact funcdef;
- an omitted lambda formal infers the complete explicit-reference QualType;
- an indirect funcdef call record publishes the exact formal type;
- the resulting Canonical AST seals successfully.

This is intentionally one dense semantic fixture. The producer and three
consumers share the same non-invertible boundary, so splitting every assertion
into a separate compile/run loop would add execution overhead without improving
fault isolation.

## TDD evidence and exclusions

The first test-only implementation called the internal
`CastToFuncdefType(asCTypeInfo*)` helper from the test module. That helper is not
exported across the UE module boundary, so the build stopped with `LNK2019`
before the product assertion could execute:

- excluded fixture/link build:
  `Saved/Build/cta-s98-derived-funcdef-red-build/20260830_201928_477_5d939b69/Build.log`.

This is not counted as semantic RED. The fixture was corrected to use the
already type-proven `asCTypeInfo*` to `asCFuncdefType*` cast, with no production
change:

- corrected fixture build:
  `Saved/Build/cta-s98-derived-funcdef-semantic-red-build/20260830_202504_137_26e2c750`
  — UBT succeeded.

The corrected fixture then reached the intended product boundary:

- valid semantic RED:
  `Saved/Tests/cta-s98-derived-funcdef-semantic-red/20260830_202527_897_68bedee1/Report/index.json`
  — **0/1**, failing exactly because the source-owned by-value function reused
  the host funcdef whose normalized ABI had lost source identity;
- GREEN build:
  `Saved/Build/cta-s98-derived-funcdef-green-build/20260830_202858_490_27e1b3c3`
  — UBT succeeded;
- focused GREEN:
  `Saved/Tests/cta-s98-derived-funcdef-focused-green/20260830_202918_330_55f084e5/Report/index.json`
  — **1/1 PASS**;
- complete SemaAuthority:
  `Saved/Tests/cta-s98-sema-authority-full-green/20260830_203001_171_7341344c/Report/index.json`
  — **458/458 PASS**;
- complete native SDK Compiler:
  `Saved/Tests/cta-s98-native-compiler-full-green/20260830_203057_000_4ec043cf/Report/index.json`
  — **798/798 PASS**.
- complete Cache:
  `Saved/Tests/cta-s98-cache-full-green/20260830_203148_759_46a9fb5c/Report/index.json`
  — **585/585 PASS**.
- complete TypedASTJIT:
  `Saved/Tests/cta-s98-typed-ast-jit-full-green/20260830_204642_992_cb045361/Report/index.json`
  — **56/56 PASS**.
- final Compiler CanonicalAST + ProjectGeneration Engine + TypedASTJIT +
  NativeBridge matrix:
  `Saved/Tests/cta-s98-derived-funcdef-final-regression/20260830_204911_328_d22c4771/Report/index.json`
  — **780/780 PASS**, zero failures and zero skips;
- complete native SDK Module:
  `Saved/Tests/cta-s98-native-module-full-green/20260830_205650_554_aa366d59/Report/index.json`
  — **65/65 PASS**.

## Static consumption audit

After the repair, production searches under the maintained AngelScript source
show direct `FromScriptParameterABI` use only inside the Runtime type bridge's
own documented fallback. The reviewed funcdef consumers use
`FromScriptFunctionParameterABI`. The remaining `funcdefType` references belong
to retained native AST/Builder, save/restore, declaration formatting and type
ownership machinery; CTA-S98 removes only the unsafe arbitrary-function lookup
from `FindMatchingFuncdef`.

## Architecture effect

The resulting authority flow is:

```text
Canonical ParamDecl QualType
        │ exact formal ordinal
        ▼
Runtime source-qualifier vector + normalized calling ABI
        │ authenticated funcdef reuse
        ▼
derived funcdef source-qualifier vector
        │ function-aware Runtime bridge
        ├── explicit lambda viability
        ├── omitted lambda contextualization
        └── indirect call formal plan
```

This keeps source semantics and VM ABI as two related but non-interchangeable
layers. It does not make dynamic TypeId durable identity and does not derive
source qualifiers from display names. The vector is generation-local semantic
metadata authenticated against the current function shape.

## Non-claims and remaining work

- The historical static `asCScriptFunction::funcdefType` field is not redesigned
  in this bounded slice. Wider native save/restore and ownership cleanup would
  require a separate compatibility audit.
- Empty-metadata host/native funcdefs necessarily retain a lossy normalized-ABI
  fallback because no Canonical source spelling exists.
- This slice does not re-enable authored script `funcdef` syntax, which remains
  rejected at the maintained fork's tokenizer boundary.
- Cache can rebuild generation-local metadata from authenticated current source
  and retained Canonical records; the Runtime vector is not a new independent
  durable identity authority.
- The original AngelScript parser/native AST/Builder/compiler remain available
  for LEGACY, syntax support, recovery, differential reference and rollback.
- HIR remains physically absent.
- Standalone remains explicitly outside this change's current completion scope.
- Product default remains LEGACY. The remaining blockers are unsupported
  call/language/provider breadth, production-entry/default-cutover scans and
  final focused plus All-suite evidence, not this derived-funcdef relation.

## Progress effect

CTA-S98 closes the concrete derived-funcdef source-formal bullet recorded by
CTA-S90, but it does not by itself close an additional `tasks.md` umbrella row.
Formal progress therefore remains **102/136 = 75.0%** until the overlapping
cutover and final-verification obligations are fully demonstrated. With the
focused, SemaAuthority, native SDK Compiler, Cache, TypedASTJIT, final combined
and Module regressions green, the conservative non-Standalone estimate remains
**93% overall**, about
**98% architecture-weighted implementation**, and about **92% safe default-
cutover readiness**. The next work is the remaining production-entry/
unsupported-family audit and final cutover matrix, not this relation.
