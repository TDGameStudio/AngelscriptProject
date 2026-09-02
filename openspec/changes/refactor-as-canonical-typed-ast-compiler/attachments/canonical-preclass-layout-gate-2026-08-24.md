# Canonical PreClass layout gate (2026-08-24)

## Scope

This gate closes one non-Cache canonical compiler compatibility gap:
`asIScriptModule::AddPreClassData()` supplies embedding-owned storage and
metadata for an exact script class declaration. `PropertyOffset` affects every
authored property offset and the final object extent, so it is a source-level
layout input. It must be frozen by Sema in the sealed canonical AST before
Bytecode CodeGen creates the Runtime type.

Cache V2 is not part of this gate. It remains default-disabled and its
cross-Engine restore/remap work is deferred to a later redesign.

## AST-first card

- Owning tasks: 0.2, 4.2, 13.2, 13.6.
- Permanent test:
  `FCanonicalASTSemaAuthorityTests::PreClassPropertyOffsetIsAnExactSealedLayoutFact`.
- Source fixture:
  - exact metadata: `PreClassExact`, `PropertyOffset = 32`;
  - unmatched metadata: `PreClassMissing`, `PropertyOffset = 64`;
  - authored classes: `PreClassExact { int Value; }` and
    `PreClassControl { int Value; }`.
- Required sealed facts:
  - `PreClassExact.byteOffset == 32`; class `byteOffset` is the canonical
    pre-class storage prefix;
  - `PreClassExact::Value.byteOffset == 32`;
  - `PreClassExact.byteSize == 36` and alignment is `alignof(int)`;
  - the unmatched control remains offset `0`, size `4`, alignment `4`;
  - an unmatched `PreClassData` entry never affects another declaration.

### AST-red

The test was added before the production repair and failed as intended:

- report:
  `Saved/Tests/cta-preclass-ast-red/20260824_190029_319_99aedde5`;
- result: **0/1 PASS**;
- observed graph: the exact class still had layout `4:4` and `Value` offset
  `0`. This proved that the fact was absent from Sema/Seal; a Runtime-only
  CodeGen patch could not satisfy the gate.

### AST-green

The implementation moves the input into `asCSema::LayoutScriptClassFields`:

1. `asCBuilder::SealCanonicalAST()` supplies its current `asCModule` to the
   Sema layout pass.
2. `LayoutOneScriptClass` performs an exact `PreClassData` name lookup, rejects
   offsets larger than `INT_MAX`, stores the prefix in the class declaration,
   begins root-class field layout at that prefix, and includes `ShadowType`
   alignment.
3. Recursive source-value and base-class layout use the same module-aware
   pass.
4. `asCASTVerify` treats the sealed class prefix as the minimum root field
   offset; derived authored fields continue after the sealed base-class extent,
   matching the maintained ABI.

Evidence:

- build:
  `Saved/Build/cta-preclass-layout-green-build/20260824_190339_027_0c9e3c2e`;
- exact AST test:
  `Saved/Tests/cta-preclass-ast-green/20260824_190415_448_03b483cd` —
  **1/1 PASS**;
- complete SemaAuthority after the follow-up diagnostic closure:
  `Saved/Tests/cta-preclass-sema-authority-green/20260824_190944_839_9af9ec53`
  — **270/270 PASS**.

## CodeGen and public contract

`asCBytecodeCodeGen` does not recompute the source layout. It copies the sealed
size/alignment, requires the current exact `PreClassData.PropertyOffset` and
sealed prefix to agree, and only then attaches Runtime-only metadata:
`basePropertyOffset`, `shadowType`, and `plainUserData`. A mismatch rejects the
candidate before publication.

The pre-existing public contract test is now green:

- `FModulePreClassMetadataTests::PreClassMetadataAppliesOnlyToExactDeclaration`;
- exact result:
  `Saved/Tests/cta-preclass-runtime-green/20260824_190453_392_b38f1cb6` —
  **1/1 PASS**;
- complete Module ApiContracts:
  `Saved/Tests/cta-preclass-module-api-contracts-regression/20260824_191108_690_ae505344`
  — **8/8 PASS**;
- complete ProductionCodeGen:
  `Saved/Tests/cta-preclass-production-codegen-regression/20260824_191027_065_85b81a77`
  — **73/73 PASS**.

The public test proves exact type user data, property offset, type size, and
control-class isolation. The production suite proves the Sema layout change
does not regress ordinary canonical Bytecode generation.

## Follow-up diagnostic closure discovered by the broad gate

The first complete SemaAuthority rerun was **269/270**:
`UnresolvedDeclRefMissingIsErrorTypeNotInt` already produced an Error-typed
`DeclRef`, but its diagnostic lacked the stable
`unresolved-identifier:<name>` category. This was an independent, previously
incomplete Sema test rather than a PreClass layout regression.

The diagnostic now has a machine-stable prefix while retaining the maintained
human explanation:

```text
unresolved-identifier:Missing: 'Missing' is not declared
```

Evidence:

- isolated red:
  `Saved/Tests/cta-preclass-unresolved-isolation/20260824_190625_082_b989937a`
  — **0/1 PASS**;
- build:
  `Saved/Build/cta-unresolved-identifier-diagnostic-green-build/20260824_190825_297_a863e25b`;
- isolated green:
  `Saved/Tests/cta-unresolved-identifier-green/20260824_190902_590_9840bebf`
  — **1/1 PASS**;
- final complete SemaAuthority: **270/270 PASS**, as recorded above.

## Result and non-claims

This closes the `PreClassData` source-layout slice and its public metadata
compatibility. It does not close the complete Sema-authority, full-language
CodeGen, HIR-consumer migration, subsystem cutover, or final regression tasks.
It creates no Cache V2 dependency and supplies no cross-Engine restore claim.

