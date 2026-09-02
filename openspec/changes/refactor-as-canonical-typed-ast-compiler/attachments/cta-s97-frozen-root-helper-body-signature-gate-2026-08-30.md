# CTA-S97 frozen root/helper body-signature gate — 2026-08-30

## Outcome

CTA-S97 closes the remaining post-freeze Runtime type-name inference in the
TypedASTJIT root/helper body-signature path.

The production backend now constructs one authenticated, generation-request-
local function shape from the exact `FStaticJITEntryPlan`. Root eligibility,
direct-closure dependency analysis and final provider-body emission reuse that
same frozen shape. They no longer ask a live `asCTypeInfo::name` to recover the
C++ ABI spelling of an already frozen root/helper formal.

The same slice strengthens `FStaticJITEntryPlan` admission: structural
completeness now recomputes the complete `static-jit-entry-plan-v2` hash and
compares it with the stored value. A nonzero hash is no longer sufficient.
Changing an ABI-relevant frozen field after finalization therefore fails
closed.

The final Compiler CanonicalAST + ProjectGeneration Engine + TypedASTJIT +
NativeBridge matrix is **779/779 PASS**, with zero failures and zero skips.

## Root cause

CTA-S93 authenticated generation-local Runtime type coordinates, and CTA-S96
made nested direct native calls consume the descriptor-owned reviewed callable
signature. One independent consumer remained: production root/helper body
eligibility and emission still reconstructed reviewed value-object spelling
from the live Runtime function parameter TypeInfo.

For a function such as:

```angelscript
UFUNCTION()
int TypedFrozenRootBodySignature_65C28A(const FString&in Text)
{
    return 101;
}
```

the EntryPlan had already frozen the exact body type `FString`, entry type
`FString*` and borrowed-address marshalling. If the same Engine-local
`asCTypeInfo::name` was changed to a display-only poison string after capture,
TypedASTJIT nevertheless rejected the function as an unsupported signature.
This proved that the consumer was re-inferring ABI meaning from mutable Runtime
display state after the immutable plan existed.

The first implementation review found that provider-body emission was not the
only such consumer. Root call-closure eligibility ran earlier and performed its
own live-name classification. Fixing only the final emitter would therefore
have left an earlier rejection path and two competing function-shape builders.

A second defect was adjacent: `IsStructurallyComplete()` accepted every
nonzero `EntryPlanHash`, even if a caller changed `BodyCppType`, passing mode or
another hashed field after finalization. The hash was recorded but was not an
authentication boundary.

## TDD gates

### Frozen root-body signature

Test source:

```text
Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/
  AngelscriptStaticJITGenerationEngineTests.cpp
```

Method:

```text
RootBodySignatureUsesFrozenEntryPlanAfterRuntimeTypeNameChanges
```

The fixture compiles the real `const FString&in` UFUNCTION, verifies that its
EntryPlan contains `BodyCppType=FString` and borrowed-address marshalling,
temporarily changes the exact Runtime TypeInfo name to
`FStringDisplayPoison_65C28A`, and calls the production
`FAngelscriptTypedASTJIT::Generate` path. The assertion requires generated
`const FString& as_ast_d...` and rejects any poison spelling.

RED:

```text
Saved/Tests/cta-s97-frozen-root-signature-red/
  20260830_193324_406_0768b149/Report/index.json
```

Result: **0/1**. The old path reported:

```text
UnsupportedSignature: Canonical signature remains outside the scalar slice.
```

Focused GREEN:

```text
Saved/Tests/cta-s97-frozen-root-signature-focused-green/
  20260830_195017_496_2bbecc4d/Report/index.json
```

Result: **1/1 PASS**. The generated root body uses the frozen `FString`
spelling even while the live Runtime display name is poisoned.

### EntryPlan hash authentication

Test source:

```text
Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/TypedASTJIT/EntryPlan/
  AngelscriptStaticJITEntryPlanTests.cpp
```

Method:

```text
ScalarPlanFreezesCppVmReflectedAndReturnFacts
```

After a valid plan is finalized, the test copies it, changes
`Parameters[0].BodyCppType` to `uint32`, and requires
`IsStructurallyComplete()` to reject it.

RED:

```text
Saved/Tests/cta-s97-entryplan-hash-red/
  20260830_193629_123_c28eabdb/Report/index.json
```

Result: **0/1** with:

```text
a frozen C++ ABI field changed after hashing must fail admission
```

Focused GREEN:

```text
Saved/Tests/cta-s97-entryplan-hash-focused-green/
  20260830_195057_868_21d04091/Report/index.json
```

Result: **1/1 PASS**.

## Implementation

### EntryPlan authentication

`AngelscriptStaticJITEntryPlan.cpp` now owns one private
`BuildEntryPlanHash()` implementation for the complete existing V2 schema.
Finalization stores that hash, and structural admission recomputes it after all
ordinary structural checks. No schema/domain revision was needed because this
change authenticates the already-versioned fields rather than changing them.

### One frozen production function shape

`AngelscriptTypedASTJITModel.h` now distinguishes the body-ABI coordinates
`ScalarValue` and `BorrowedValueAddress`. A production function shape carries:

- the exact frozen return C++ type;
- one exact frozen body C++ type per formal;
- one explicit body-ABI kind per formal;
- an explicit marker proving that the shape came from a frozen EntryPlan.

`BuildAngelscriptTypedASTJITFunctionShape()` in the eligibility layer is the
single production normalization boundary. It requires an exact Engine-local
function and an authenticated, typed-representable EntryPlan, verifies formal
counts and structural Runtime coordinates, and copies the exact EntryPlan
spelling. Borrowed reviewed values require the EntryPlan relation
`EntryCppType == BodyCppType + "*"`, a read-only non-handle Runtime reference,
and `asTM_INREF`. Opaque compatibility parameters fail closed.

The Runtime `asCDataType` coordinates remain generation-local structural
evidence. They are not used to rediscover the C++ type name.

### Shared eligibility, dependency and emission authority

`AngelscriptTypedASTJITEligibility.cpp` builds the root shape from the root or
function EntryPlan and publishes a deterministic failure if the production
plan is missing or malformed.

`AngelscriptTypedASTJITBackend.cpp` removed its duplicate private shape
builder. After Runtime binding authentication and provider EntryPlan capture,
each direct closure member receives one frozen shape; dependency analysis and
emission reuse that same value.

`AngelscriptTypedASTJITCanonical.cpp` now:

- admits a reviewed managed input from the frozen body ABI plus structural
  Runtime reference facts, not from the TypeInfo name;
- emits the exact frozen root/helper return and formal spelling;
- compares that spelling against the sealed Canonical formal relation;
- retains a provider-independent scalar-only inspection path for unit-level
  pure scalar analysis, but never uses it to admit managed/reference formals;
- removes the unsafe default return-spelling fallback to `int32`.

`AngelscriptTypedASTJITProviderEmitter.cpp` no longer contains the unused
live-name scalar/borrowed spelling helpers and no longer includes
`as_typeinfo.h`.

## Verification

Build:

```text
Saved/Build/cta-s97-frozen-root-signature-green-build/
  20260830_194943_255_87b4bd0c/Build.log
```

Result: PASS, exit code 0. Only pre-existing warning classes were present.

Focused and layered regression:

| Gate | Result | Report |
| --- | ---: | --- |
| Frozen root-body poison-name gate | 1/1 PASS | `Saved/Tests/cta-s97-frozen-root-signature-focused-green/20260830_195017_496_2bbecc4d/Report/index.json` |
| EntryPlan hash gate | 1/1 PASS | `Saved/Tests/cta-s97-entryplan-hash-focused-green/20260830_195057_868_21d04091/Report/index.json` |
| ProjectGeneration Engine class | 40/40 PASS | `Saved/Tests/cta-s97-generation-engine-green/20260830_195139_849_bca187c8/Report/index.json` |
| EntryPlan TypedASTJIT | 2/2 PASS | `Saved/Tests/cta-s97-entryplan-green/20260830_195630_566_95a0b074/Report/index.json` |
| Complete TypedASTJIT prefix | 56/56 PASS | `Saved/Tests/cta-s97-typed-ast-jit-green/20260830_195706_790_85417418/Report/index.json` |
| Compiler CanonicalAST + ProjectGeneration Engine + TypedASTJIT + NativeBridge | 779/779 PASS | `Saved/Tests/cta-s97-frozen-signature-final-regression/20260830_195920_029_55f09360/Report/index.json` |

The final matrix has zero failures and zero skips.

## Authority after CTA-S97

```text
sealed Canonical declaration/formal relation
    + immutable generation-local Runtime signature-binding authentication
    + authenticated FStaticJITEntryPlan exact C++ body ABI
        -> one frozen root/helper function shape
        -> root eligibility
        -> direct-closure dependency analysis
        -> mechanical provider-body emission
```

Dynamic numeric TypeId remains a current-Engine/current-generation coordinate.
It is not persisted, published as stable identity or used to reconstruct the
post-freeze C++ body signature.

## Non-claims and remaining work

- EntryPlan capture still recognizes the deliberately reviewed borrowed value
  types at capture time. CTA-S97 removes post-freeze re-inference; it does not
  redesign the capture-time reviewed-type registry.
- Eligibility still reads names to classify unsupported container families
  such as `TArray`, `TSet` and `TMap`. That is fallback-family classification,
  not C++ ABI spelling, but it remains part of the unsupported-breadth audit.
- This slice does not complete derived-funcdef source-formal qualifier
  producer/consumer propagation.
- It does not add native object-frame, mutable-global/import, complete
  receiver/property/mixin/constructor/delegate/lambda/container or cross-TU
  direct-call support. Unsupported forms continue to fail per function.
- Tasks 7.2, 7.4 and 7.5 remain unchecked until their family-wide obligations
  are complete.
- Product default remains LEGACY. The original AngelScript
  AST/Parser/Builder/Compiler remains intentionally available for the explicit
  LEGACY/reference/differential/rollback path.
- HIR remains physically absent and was not recreated.
- Standalone remains outside this change's completion gate.

## Next blocker

The next bounded implementation gate is the remaining CTA-S90
derived-funcdef source-formal relation: prove that producer-carried source
qualifier/passing identity survives derived funcdef materialization and that
each consumer authenticates the exact formal relation instead of recovering it
from normalized Runtime ABI or child position. After that, continue the
unsupported-family/default-cutover matrix rather than reopening the resolved
dynamic-TypeId identity model.
