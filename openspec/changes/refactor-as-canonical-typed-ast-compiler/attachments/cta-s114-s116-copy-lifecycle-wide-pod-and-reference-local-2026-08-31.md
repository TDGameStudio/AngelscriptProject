# CTA-S114 / CTA-S115 / CTA-S116 — implicit copy lifecycle, wide POD accessors and reference-local null initialization

Date: 2026-08-31  
Scope: non-Standalone CANONICAL source pipeline  
Status: focused AST/CodeGen gates GREEN; whole `Script/` inventory refreshed

## Executive status

- Exact OpenSpec checklist remains `102/136 = 75.0%`.  These are focused
  semantic closures under still-open acceptance umbrellas; no checkbox is
  newly claimed complete.
- Practical architecture completion remains about `98%`; practical end-to-end
  implementation is about `95%`; default-cutover readiness is about `94%`.
- CANONICAL remains explicit opt-in and the product default remains LEGACY.
- Standalone is deliberately deferred and was not modified or validated.
- The original AngelScript native AST/parser/builder/compiler remains retained
  for LEGACY, reference, differential validation and rollback.  TypedSemantic
  HIR remains physically removed.
- None of these changes stores Runtime numeric `TypeId` in Canonical AST,
  snapshots, detached artifacts or stable identity.  Exact `DeclId`/`TypeRef`
  relations stay snapshot-owned; cross-generation identity stays structural.

The whole-corpus failure inventory moved from the post-CTA-S113 baseline of
`19 Sema + 9 downstream = 28` to `17 Sema + 7 downstream = 24`.

## CTA-S114 — implicit script value copy lifecycle

### Closed defect

`FExampleStruct` in the unchanged production
`Script/Examples/Core/Example_Struct.as` has value semantics but does not
author an explicit copy constructor or `opAssign`.  LEGACY supplies those
implicit special members.  CANONICAL previously finalized generated property
accessors before it had an equivalent script-owned lifecycle route, so the
getter and setter failed with independent unavailable-copy/unavailable-
assignment diagnostics.

Sema now synthesizes exact generated special members for eligible authored
script value classes:

```text
generated opAssign(const T& Other)
  -> one exact memberwise assignment plan per assignable field
  -> returns this through the maintained generated-method convention

generated T(const T& Other)
  -> delegates its memberwise copy semantics to the exact generated opAssign
  -> remains a Canonical declaration/body, not a Runtime-name lookup
```

Authored exact copy constructors or assignment operators always win.  The
generated helpers are hidden implementation declarations and do not contaminate
source-visible overload ownership.

### Conditional availability and fail-closed behavior

The first broad regression exposed an important native-member boundary.  A
script value class can contain a native non-POD member that has an exact copy
constructor but no exact assignment operator.  Unconditionally publishing the
generated owner `opAssign` made an unrelated existing native-getter fixture
fail with `implicit-assignment-member-operator-unavailable`.

The final rule is conditional:

- if every member has an exact assignable route, the generated `opAssign` body
  is finalized and may support the generated copy constructor;
- if one member has no exact route, that generated helper remains bodyless and
  unavailable;
- unavailable generated implicit helpers are excluded from the object dispatch
  graph and are never published as callable CodeGen entries;
- CANONICAL does not fall back to raw byte copying for a non-trivial object;
- unrelated functions and accessor routes that have their own exact copy
  constructor remain valid.

This preserves failure isolation without weakening CodeGen or inventing a
different object ABI.

### Non-trivial authored member initialization

The production fixture then exposed a second gap: an authored member initializer
for a non-trivial value member reached the final class with the source
expression but without an owned copy construction.  Sema now wraps that exact
initializer in the selected `Construct(copy)` plan.  Constructor argument
lowering preserves reference-formal semantics, so the copy source remains an
addressable lvalue rather than an accidental by-value transfer.

### Evidence

| Gate | Result | Evidence |
|---|---:|---|
| implicit special-member AST RED | expected failure | `Saved/Tests/cta-s114-implicit-script-copy-ast-red/20260831_083853_160_c55721dc/` |
| refined implicit special-member AST RED | expected failure | `Saved/Tests/cta-s114-implicit-script-copy-ast-red-v2/20260831_083942_355_3d567f85/` |
| first Sema GREEN | progression | `Saved/Tests/cta-s114-implicit-script-copy-sema-first-green/20260831_084539_342_c42a5978/` |
| hidden-copy-helper GREEN | progression | `Saved/Tests/cta-s114-hidden-copy-helper-first-green/20260831_084934_612_2d9e9b1e/` |
| non-trivial member-init AST RED | expected failure | `Saved/Tests/cta-s114-nonpod-member-init-ast-red/20260831_085404_604_b3cd36c3/` |
| member-init first GREEN | progression | `Saved/Tests/cta-s114-nonpod-member-init-first-green/20260831_085606_357_e0103c9f/` |
| conditional lifecycle build | PASS | `Saved/Build/cta-s114-conditional-copy-lifecycle-first-green-build/20260831_091225_501_e627416a/` |
| final copy/accessor regression group | `6/6 PASS` | `Saved/Tests/cta-s114-s115-accessor-copy-regression-green/20260831_091250_347_e59bbf38/` |
| unchanged preprocessed `Example_Struct.as` | `1/1 PASS` | `Saved/Tests/cta-s114-s115-production-example-struct-green/20260831_090658_455_498635ed/` |

The intermediate combined regression at
`Saved/Tests/cta-s114-s115-accessor-copy-regression/20260831_090757_220_9f3871c7/`
was `5/6` and is retained as the evidence that led to conditional availability;
it must not be cited as a final GREEN.

## CTA-S115 — wide POD generated accessors

### Closed defect

Generated accessor CodeGen had narrow scalar paths but rejected or truncated
POD values wider than the scalar operand forms.  The corpus exposed a 24-byte
`FVector` getter after CTA-S114 allowed `Example_Struct.as` to progress.

CodeGen now uses exact-width `asBC_COPY` for wide trivial storage:

- generated getter: backing field to hidden return storage;
- generated setter: owned parameter storage to backing field;
- member assignment: source storage to destination field.

The copy width comes from the sealed Canonical type/layout facts.  This is not
a dynamic `TypeId` lookup and it does not classify non-trivial value objects as
POD.  Existing 12-byte triple assignment/return tests remain part of the final
`6/6` regression group.

### Evidence

| Gate | Result | Evidence |
|---|---:|---|
| wide generated getter RED | expected failure | `Saved/Tests/cta-s115-wide-pod-getter-red/20260831_090016_069_8bc14bcd/` |
| wide generated getter first GREEN | progression | `Saved/Tests/cta-s115-wide-pod-getter-first-green/20260831_090238_241_eb862e49/` |
| wide generated setter RED | expected failure | `Saved/Tests/cta-s115-wide-pod-setter-red/20260831_090506_456_12f1c11c/` |
| wide generated setter first GREEN | progression | `Saved/Tests/cta-s115-wide-pod-setter-first-green/20260831_090616_344_b755792b/` |
| final copy/accessor regression group | `6/6 PASS` | `Saved/Tests/cta-s114-s115-accessor-copy-regression-green/20260831_091250_347_e59bbf38/` |

The post-CTA-S115 corpus at
`Saved/Tests/cta-s115-whole-engine-post-copy-lifecycle-refresh/20260831_091351_166_bef9a5e7/`
confirmed both improvements: Sema diagnostics moved `19 -> 17` and downstream
failures moved `9 -> 8`.  `Example_Struct.as` and the unsupported 24-byte
accessor failure both disappeared.

## CTA-S116 — default-null reference locals

### Closed defect

`CreateDefaultMemberInit()` already initialized handle/reference fields with a
typed null plan, but `AppendImplicitLocalInitialization()` sent a non-reference
local whose type kind was `REFERENCE_OBJECT` through the value-object default
constructor path.  For source such as:

```angelscript
AActor ActorReference;
```

Sema therefore authored `Construct` with no valid constructor declaration, and
CodeGen later rejected the dangling `DeclId`.

The local rule now mirrors the existing ownership model:

```text
implicit-handle/reference-object local
  -> canonical NullLiteral
  -> typed null Conversion
  -> exact DeclRef(local) = converted null Assign
  -> scope-release cleanup when ownership requires it

value/template local
  -> exact default Construct path (unchanged)
```

The production test was extended with an implicit-handle reference object and
retains its existing funcdef local.  It authenticates both null initialization
paths in the sealed AST and executes the release plan.  A separate value-local
control test proves that value objects still use `Construct`.

### Adjacent verifier regression found by review

The first focused run failed before reaching the new reference assertion:

```text
INVALID_TYPE null-conversion-target target=FuncDef
```

The same funcdef production test had previously passed `1/1` at
`Saved/Tests/cta-s46-funcdef-default-null-production-green/20260828_101823_703_dfc98fa4/`.
The later generic null-conversion verifier accepted only `REFERENCE_OBJECT`,
while its own `scope-release` verification already accepted both
`REFERENCE_OBJECT` and `FUNCDEF`.  The nullable-target predicate is now
consistent with the lifetime rule: it still requires a non-reference handle,
then accepts either of those two exact Canonical type kinds.  No arbitrary
value type or raw pointer was added to the nullable set.

### Evidence

| Gate | Result | Evidence |
|---|---:|---|
| first reference-local run | expected adjacent verifier failure | `Saved/Tests/cta-s116-reference-local-null-first-green/20260831_091838_968_91e436c7/` |
| nullable-target verifier build | PASS | `Saved/Build/cta-s116-nullable-target-verifier-green-build/20260831_092130_383_47cd3a40/` |
| funcdef + reference-object default null | `1/1 PASS` | `Saved/Tests/cta-s116-reference-and-funcdef-default-null-green/20260831_092143_076_d93480b5/` |
| value-local Construct control | `1/1 PASS` | `Saved/Tests/cta-s116-value-local-construct-control-green/20260831_092231_760_e5ec9a7d/` |
| whole `Script/` refresh | expected startup failure; inventory captured | `Saved/Tests/cta-s116-whole-engine-post-reference-local-refresh/20260831_092305_872_cc0bcb2b/` |

One failed build invocation at
`Saved/Build/cta-s116-nullable-target-verifier-green-build/20260831_092119_714_0a572b66/`
was a runner-argument error: `ConcurrentNoEngineChanges` was accidentally
passed as the UBT target.  UBT never compiled project code.  The immediately
corrected invocation above is the authoritative build evidence.

## Post-CTA-S116 whole-Engine inventory

The current whole `Script/` root contains `17` exact Sema diagnostics:

| Family | Count | Current examples / interpretation |
|---|---:|---|
| `ambiguous-overload` | 11 | still lacks actionable candidate/name/range detail in the emitted corpus diagnostic |
| `unresolved-callee` | 3 | `ApplyFormat`, `CreateWidget`, `NewObject` |
| `unresolved-identifier` | 2 | inherited native `NodeName` in `Example_BehaviorTreeNodes.as` |
| `global-init-not-constant` | 1 | remaining global-initializer classification/lowering root |

The current downstream inventory contains `7` unique failures:

| Family | Count | Current examples / interpretation |
|---|---:|---|
| interface-dispatch authentication mismatch | 4 | `AExampleMovingObject`, `AExamplePickupBase`, `AExampleReplicatedActor`, `AExampleActorType`; cardinalities match, identity/order authentication is the likely boundary |
| invalid materialized `FString` lvalue receiver | 3 | Enhanced Input mapping, damage implementation, session tracker |

The following failures are now absent from the corpus:

- generated `FExampleStruct` copy-constructor unavailable;
- generated `FExampleStruct::opAssign` unavailable;
- unsupported 24-byte `FVector` generated accessor read;
- dangling `AActor` local default Construct.

The whole run intentionally exits during startup compilation with status 3;
that exit is expected while the inventory is non-empty and is not a test-suite
PASS claim.

## Next critical path

1. diagnose the four same-cardinality interface-dispatch authentication
   mismatches as one batch and fix the underlying exact relation/order rule;
2. diagnose the three `FString` materialized-lvalue receiver failures as one
   ownership/lifetime batch;
3. make the eleven ambiguous-overload diagnostics attributable before changing
   ranking, then close `ApplyFormat`, `CreateWidget`, `NewObject`, `NodeName`
   and global initialization;
4. refresh the complete non-Standalone corpus after each batch, then run the
   full build/cache/hot-reload/StaticJIT acceptance matrix;
5. retain LEGACY as default until that matrix is clean.

## Explicit non-goals

- Standalone adaptation or validation;
- deleting the original native AngelScript AST/compiler;
- restoring HIR;
- consuming AST dump/JSON/DOT text as compiler input;
- weakening sealed relation, lifecycle, SYSTEM identity or backend fail-closed
  checks;
- treating focused GREEN evidence as authorization for default cutover.
