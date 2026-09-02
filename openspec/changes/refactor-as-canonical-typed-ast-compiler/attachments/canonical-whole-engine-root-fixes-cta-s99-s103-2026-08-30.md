# Canonical whole-Engine root fixes CTA-S99 through CTA-S103 — 2026-08-30

## Status and scope

This attachment records the first root-cause pass over the real project script
root with `-as-canonical-staged-compiler`, after the focused native SDK and
architecture gates had become broadly green. It covers CTA-S99 through CTA-S103
and the resulting whole-Engine diagnostic reduction:

```text
1169 -> 222 -> 169 -> 122 -> 122 -> 111
```

These runs intentionally fail startup while unsupported source remains. Their
value is the complete project-corpus diagnostic inventory and the before/after
delta for each root repair. They are not claimed as passing Automation runs and
do not authorize making CANONICAL the product default.

The production default remains `LEGACY`. The original AngelScript Parser,
native AST and `asCCompiler` remain available for syntax/recovery, explicit
LEGACY compilation, differential tests, rollback and reference. HIR remains
physically absent. Standalone remains deferred by explicit project decision.

## Diagnostic progression

| Slice | Total | Unresolved callee | Unresolved identifier | Other result |
|---|---:|---:|---:|---|
| Initial real-root probe | 1169 | 192 | 953 | Exposed ambient `NAME_None` namespace corruption |
| CTA-S99 | 222 | 192 | 6 | Removed 947 false unresolved identifiers |
| CTA-S100 | 169 | 139 | 6 | Removed 53 template/static-type call failures |
| CTA-S101 | 122 | 91 | 6 | Removed 48 target-construction failures; one new static-scope inventory item made the net delta 47 |
| CTA-S102 generic native ancestry | 122 | 91 | 6 | Focused path green, real UE path unchanged |
| CTA-S103 host native ancestry | 111 | 82 | 6 | Removed all 11 `__Evt_Execute`, both `SetTimer`, and two invalid native identities |

The unchanged CTA-S102 result is important evidence, not a discarded run. It
proved that the generic AngelScript object inheritance implementation was
correct but that the UE registration boundary did not represent native
inheritance through `asCObjectType::derivedFrom`.

## CTA-S99 — ambient `NAME_None` namespace corruption

### Problem

Runtime-owned default argument parsing temporarily entered a synthetic source
session. Restoring the active parser state converted an absent/default
namespace into a real namespace spelling instead of preserving the lexical
absence. Subsequent unqualified lookups then searched the wrong scope. The first
whole-Engine probe produced 953 `unresolved-identifier` diagnostics, most of
which were downstream noise rather than missing declarations.

### Repair

The projected-runtime-default action now preserves the exact lexical namespace
state, including `NAME_None`, across nested default-argument parsing. The
repair is state restoration, not a name-based lookup exception.

### Evidence

- semantic RED:
  `Saved/Tests/cta-s99-nested-runtime-default-red/20260830_211923_753_86b16c3b`;
- GREEN build:
  `Saved/Build/cta-s99-nested-runtime-default-green-build/20260830_212050_967_6011046a`;
- focused GREEN:
  `Saved/Tests/cta-s99-nested-runtime-default-green/20260830_212102_985_d12615b2`;
- call-argument regression:
  `Saved/Tests/cta-s99-call-arguments-regression/20260830_212138_723_40641b61`;
- whole-Engine delta:
  `Saved/Tests/cta-s99-whole-engine-canonical-smoke/20260830_211059_973_b0cc5420`
  to
  `Saved/Tests/cta-s99-whole-engine-canonical-after-namespace-fix/20260830_212215_886_06fe4be5`,
  **1169 -> 222** total and **953 -> 6** unresolved identifiers.

## CTA-S100 — implicit-handle spelling leaked into stable template identity

### Problem

The maintained Runtime treats many registered UObject reference types as
implicit handles. Formatting a template instance such as
`TSubclassOf<UObject>` through a Runtime datatype therefore leaked an implicit
`@` representation into the Canonical stable template key. Source spelling and
registered template identity then disagreed even though the semantic type was
the same. Static type/member lookup and calls using `TSubclassOf` failed in
bulk.

### Repair

Canonical stable template identity now distinguishes explicit source handle
syntax from Runtime implicit-handle storage. An implicit handle is not emitted
as authored identity. Runtime representation remains generation-local and is
still available at the final binding boundary.

### Evidence

- semantic RED:
  `Saved/Tests/cta-s100-script-static-type-get-red/20260830_212623_321_938ed13c`;
- GREEN build:
  `Saved/Build/cta-s100-script-static-type-get-green-build/20260830_212820_790_199e4917`;
- focused GREEN:
  `Saved/Tests/cta-s100-script-static-type-get-green/20260830_212832_964_c6395a09`;
- whole-Engine:
  `Saved/Tests/cta-s100-whole-engine-after-template-key-fix/20260830_212913_646_39a8dfec`,
  **222 -> 169** total and **192 -> 139** unresolved callees.

## CTA-S101 — target-side implicit construction and temporary value category

### Problem

The maintained dialect supports target-owned implicit construction, including
the UE pattern:

```text
UClass -> TSubclassOf<AActor>
```

Canonical overload ranking previously searched source-side implicit conversion
operators but did not ask the target type for an implicit constructor. After
the constructor became selectable, the produced `Construct` expression also
retained the wrong source value category, so a valid temporary could be treated
as an lvalue/reference-shaped expression.

### Repair

- overload ranking admits one target-side implicit constructor;
- the conversion plan publishes a real Canonical `Construct` expression;
- ordinary user-defined conversion chaining remains forbidden;
- the constructed temporary receives the target value category rather than the
  source expression category;
- no Runtime TypeId becomes durable identity.

### Evidence

- semantic RED:
  `Saved/Tests/cta-s101-target-implicit-red/20260830_213335_025_7cc13c62`;
- final build:
  `Saved/Build/cta-s101-target-implicit-value-category-build/20260830_214524_826_b4332688`;
- exact static-type/constructor GREEN:
  `Saved/Tests/cta-s101-target-implicit-value-category-green/20260830_214537_662_2412f602`
  — **3/3 PASS**;
- whole-Engine:
  `Saved/Tests/cta-s101-whole-engine-after-target-implicit-constructor/20260830_214722_660_967a6da3`,
  **169 -> 122** total and **139 -> 91** unresolved callees.

## CTA-S102 — generic registered native ancestry

### Problem

A script PreClass may project a registered native shadow type. Canonical Sema
already created the script-to-shadow base edge, but a registered native leaf's
own `derivedFrom` and interface relations were not copied into the pointer-free
registered-type fact. Therefore a focused shape such as
`ScriptClass -> NativeLeaf -> NativeRoot` stopped at the leaf.

### Repair

`asSCanonicalRegisteredTypeDeclarationFact` now carries direct base/interface
stable keys. `CopyCanonicalRegisteredTypeDeclarations` copies those keys at the
Runtime registration boundary, and `ProjectCanonicalRegisteredBaseType`
recursively creates ordinary `Decl::bases` edges. Missing or ambiguous captured
bases fail closed with `registered-native-base-*` diagnostics.

The data flow is:

```text
live registered type relation (temporary read)
  -> stable direct base/interface names
  -> pointer-free Sema fact snapshot
  -> Canonical native type declaration + Decl::bases
```

### Evidence

- semantic RED:
  `Saved/Tests/cta-s102-native-base-chain-red/20260830_215227_134_9d0dbb17`,
  failing `ReadNativeRoot(DerivedHostValue)` with `rank0=-1`;
- GREEN build:
  `Saved/Build/cta-s102-native-base-chain-green-build/20260830_215351_360_b4c4a017`;
- focused GREEN:
  `Saved/Tests/cta-s102-native-base-chain-green/20260830_215425_399_333b8c03`
  — **1/1 PASS**;
- real-root audit:
  `Saved/Tests/cta-s102-whole-engine-after-native-base-chain/20260830_215504_370_f76a0308`,
  still **122** diagnostics.

The real-root non-delta established that UE registered reference types do not
encode Unreal inheritance through `asCObjectType::derivedFrom`.

## CTA-S103 — explicit UE host ancestry by stable names

### Root cause

`FAngelscriptBinds::ReferenceClassForTarget` registered an Unreal reference
class with:

- AngelScript name;
- size and alignment;
- reference/implicit-handle flags;
- associated `UClass*` user data.

The actual superclass graph remained exclusively in
`UClass::GetSuperClass()` and `UClass::Interfaces`. Mutating
`asCObjectType::derivedFrom` to mirror Unreal would broaden LEGACY Runtime
semantics and lifetime/refcount behavior, while persisting TypeId or `UClass*`
inside the AST would make generation-local state durable identity. Both repairs
are rejected.

### Implemented boundary

`asCScriptEngine::RegisterCanonicalTypeBaseRelation` accepts an exact derived
stable spelling and base stable spelling. It stores only deduplicated strings.
`ReferenceClassForTarget` publishes:

- the nearest already registered Unreal superclass;
- each directly implemented, already registered Unreal interface.

The relation is merged with ordinary registered `derivedFrom/interfaces` only
when copying the ephemeral Canonical registered-type fact. Sema then consumes
the same `baseStableKeys` path introduced in CTA-S102.

The resulting authority split is:

```text
Unreal UClass graph
  -> ReferenceClassForTarget registration boundary
  -> exact stable derived/base spellings
  -> pointer-free Canonical fact snapshot
  -> Decl::bases and overload/member conversion

later, per target Engine generation:
  stable AST type identity -> current Runtime type pointer / dynamic TypeId
```

The focused regression explicitly verifies that
`HostStableLeaf->derivedFrom == nullptr`; the new path does not modify LEGACY
Runtime inheritance.

### TDD and whole-Engine evidence

- valid compile/link RED:
  `Saved/Build/cta-s103-host-stable-native-base-red-build/20260830_215925_191_ab7d5dbb`,
  failing with the intentionally absent
  `RegisterCanonicalTypeBaseRelation` implementation;
- GREEN build:
  `Saved/Build/cta-s103-host-stable-native-base-green-build/20260830_220243_874_b147c632`;
- focused GREEN:
  `Saved/Tests/cta-s103-host-stable-native-base-green/20260830_220311_972_4e9c5bfa`
  — **1/1 PASS**;
- whole-Engine:
  `Saved/Tests/cta-s103-whole-engine-after-host-native-ancestry/20260830_220358_110_7496e789`,
  **122 -> 111** total and **91 -> 82** unresolved callees.

The final run has:

```text
82 unresolved-callee
11 unresolved-scope
8 ambiguous-overload
6 unresolved-identifier
2 native-function-canonical-identity-invalid
1 generated-accessor-copy-constructor-unavailable
1 global-init-not-constant
```

All 11 `__Evt_Execute` and both `SetTimer` failures are gone. No
`registered-native-base-*` or `preclass-native-base-*` diagnostic was emitted.

## Current real-root blocker groups after CTA-S103

The remaining 111 diagnostics are not one inheritance defect. They form these
independent root groups:

1. **Runtime/test DSL global declaration projection** — `AssertEquals` 18,
   `AssertNotNull` 7, `AssertTrue` 4, `AssertNull` 4, plus `AssertSame`,
   `ExpectError*` and `GetCurrentSuite`. Candidate lookup has zero hits, so this
   is declaration authority/inventory rather than overload ranking.
2. **Type-name static member semantics** — `StaticClass` 4. These unresolved
   expressions cascade into `SpawnObject`, `SpawnActor`, `SpawnComponent` and
   part of `NewObject`. Cache restore support for a generated StaticClass body
   does not automatically make an authored type-name member expression visible
   during fresh Sema lookup.
3. **Container `auto` inference** — `Proceed` 4, `GetKey` 3, `GetValue` 2 and
   `SetValue` 1 carry `auto/_Iterator` or `auto/Element` with no type declaration.
   The loop/iterator actions need exact template-derived element and iterator
   types before call lookup.
4. **Native/inherited member inventory** — `SetReplicates` 5, `GetName` 7,
   `GetLocalPlayer`, `GetPawn`, `GetInputComponent`, `AddMovementInput` and
   related calls have no candidates. The ancestry graph now exists, but method
   lookup still does not project or traverse every registered/reflected member
   source.
5. **Template covariance** —
   `TSubclassOf<UExampleWidget> -> TSubclassOf<UUserWidget>` for `CreateWidget`
   remains invalid. This must be a first-class covariant template relation over
   stable template arguments; it must not be implemented by chaining arbitrary
   user conversions.
6. **Static scopes** — 11 unresolved scopes, predominantly `FString`, `FText`
   and `UEnhancedInputLocalPlayerSubsystem` static/type-name expressions.
7. **Generated/accessor and CodeGen closures** — generated accessor copy
   construction, dangling construct-decl in `Example_MixinMethods`, 24-byte
   `FVector` generated-accessor read, `FString` literal construction, and a
   materialized `FString` lvalue receiver remain separate CodeGen/lifetime
   problems.

## Non-claims

- The real project script root does not yet compile under CANONICAL.
- CANONICAL is not ready to replace the product default.
- CTA-S103 does not make Runtime TypeId stable. It removes TypeId from nominal
  semantic identity and resolves it only at the current-generation binding
  boundary.
- The native AngelScript AST/Parser/Builder/LEGACY compiler are not being
  deleted by this change.
- Standalone is not part of this completion slice.

## CTA-S104 — inherited native methods and implicit-`this` lookup bootstrap

### Root cause

The largest post-S103 group was initially classified as missing test-DSL or
native-member inventory. Static inspection showed a more precise common root:

- `AssertEquals`, `AssertTrue`, `AssertNull`, `AssertNotNull`, `AssertSame`,
  `ExpectError*` and `GetCurrentSuite` are native methods registered on
  `UAngelscriptTestSuite`; they are not parser-only DSL syntax or global
  functions;
- `SetReplicates`, `GetName`, `GetLocalPlayer`, `GetPawn`,
  `GetInputComponent` and `AddMovementInput` have the same inherited-native
  method shape on ordinary Unreal base classes;
- S103 had already projected the native ancestry into `Decl::bases`, and
  `LookupCandidatesFrom` already performed breadth-first inherited lookup;
- `InternNativeMethods` deliberately refused to populate an authored script
  class from a same-spelled Runtime type, so no native base MethodDecl existed
  in the Canonical graph;
- an unqualified class-body call selected its MethodDecl *before*
  `ActOnCallExpr` manufactured implicit `this`, while native method projection
  was entered only when a receiver already existed.

That last ordering formed a cycle:

```text
no projected inherited MethodDecl
  -> initial unqualified lookup cannot select a method
  -> implicit `this` is not created
  -> receiver-based native projection is never entered
  -> no projected inherited MethodDecl
```

The first S104 implementation added breadth-first native-base projection to the
explicit-receiver path. It compiled successfully but the valid semantic test
remained RED with `unresolved-callee:MarkFromRoot nargs=0 hits=0`. This was the
evidence that ancestry traversal alone was insufficient and that lookup order,
not the base graph, was the remaining defect.

### Implemented boundary

`InternNativeMethodsFromCanonicalBases` now walks only the pointer-free
`Decl::bases` graph and interns a requested method onto the exact native base
declaration that owns it. It does not:

- copy a native method into the authored derived class;
- mutate `asCObjectType::derivedFrom` or interface arrays;
- persist a Runtime object pointer, FunctionId or TypeId in the AST;
- change LEGACY method lookup.

For an unqualified, non-explicit-scope class-body call, `ResolveCallee` now
projects same-name methods from Canonical native bases before its first lexical
candidate lookup. Existing lookup/hiding, overload ranking and call formation
still decide whether the name is a method, free function or local callable.
Only after a MethodDecl wins does the existing `ActOnCallExpr` path create the
implicit `this`. Explicit receiver calls keep using the receiver-type path.

The resulting lifecycle is:

```text
authored class + stable Decl::bases
  -> request same-name declarations from exact native base scopes
  -> ordinary inherited lookup and overload ranking
  -> selected MethodDecl
  -> synthesize implicit `this`
  -> sealed CallExpr with exact stable native declaration identity
```

### TDD and whole-Engine evidence

The focused fixture registers `HostMethodRoot` and `HostMethodLeaf`, registers
the native `void MarkFromRoot() const` method only on the root, publishes the
leaf-to-root relation by stable names, and verifies that
`HostMethodLeaf->derivedFrom == nullptr`. An authored PreClass-shadowed script
class calls `MarkFromRoot()` without a receiver.

- invalid fixture compile (not semantic RED):
  `Saved/Build/cta-s104-inherited-native-method-red-build/20260830_221135_776_bb169e5d`
  — the new test callback lacked its C++ namespace qualifier;
- valid fixture build:
  `Saved/Build/cta-s104-inherited-native-method-red-fixture-build/20260830_221158_913_960f3c61`;
- invalid test selection (not semantic RED):
  `Saved/Tests/cta-s104-inherited-native-method-red/20260830_221224_110_25e8bde7`
  — the automation path omitted the generated test class segment and found no
  test;
- valid semantic RED:
  `Saved/Tests/cta-s104-inherited-native-method-red-semantic/20260830_221316_491_3623df90`
  — **1/1 FAIL**, `unresolved-callee:MarkFromRoot nargs=0 hits=0`;
- first base-walk-only build:
  `Saved/Build/cta-s104-inherited-native-method-green-build/20260830_221510_503_116616a1`;
- first base-walk-only run, still valid RED:
  `Saved/Tests/cta-s104-inherited-native-method-green/20260830_221524_984_5440eaad`
  — **1/1 FAIL**, proving the implicit-`this` lookup cycle;
- lookup-bootstrap GREEN build:
  `Saved/Build/cta-s104-implicit-this-bootstrap-green-build/20260830_221826_398_f7204baf`;
- focused GREEN:
  `Saved/Tests/cta-s104-implicit-this-bootstrap-green/20260830_221846_738_1bc0a387`
  — **1/1 PASS**;
- whole-Engine:
  `Saved/Tests/cta-s104-whole-engine-after-inherited-native-methods/20260830_221937_593_1a467ff1`,
  **111 -> 64** total and **82 -> 35** unresolved callees.

The whole-Engine reduction is:

```text
AssertEquals        18 -> 0
GetName              7 -> 0
SetReplicates        5 -> 0
AssertTrue           4 -> 0
GetCurrentSuite      3 -> 0
AssertNotNull        7 -> 4
ExpectError          1 -> 0
ExpectErrorRegex     1 -> 0
GetLocalPlayer       2 -> 0
GetPawn              1 -> 0
GetInputComponent    1 -> 0
AddMovementInput     1 -> 0
AssertNear           1 -> 0
```

The remaining 64 diagnostics are:

```text
35 unresolved-callee
11 unresolved-scope
 8 ambiguous-overload
 6 unresolved-identifier
 2 native-function-canonical-identity-invalid
 1 generated-accessor-copy-constructor-unavailable
 1 global-init-not-constant
```

### Refined next roots after CTA-S104

1. `AssertNull` / `AssertNotNull` / `AssertSame` now have visible candidates
   (`hits=1`) but derived Unreal object arguments rank `-1` against `UObject`.
   This is no longer declaration inventory; it is a Canonical native ancestry
   conversion-relation defect.
2. `StaticClass` remains unresolved and cascades into `SpawnObject`,
   `SpawnActor`, `SpawnComponent` and `NewObject`.
3. Container `auto` iterator/element types remain unresolved for `Proceed`,
   `GetKey`, `GetValue` and `SetValue`.
4. `FString`, `FText` and `UEnhancedInputLocalPlayerSubsystem` static scopes
   remain unresolved.
5. `TSubclassOf<UExampleWidget> -> TSubclassOf<UUserWidget>` covariance remains
   unresolved for `CreateWidget`.
6. Delegate/mixin/property inventory still leaves `Execute`, `AddUFunction`,
   `GetOuter` and `Tags.Add` cases.
7. Generated/accessor and CodeGen failures remain independent closures.

## CTA-S105 — unified registered native declaration and ancestry projection

### Root cause

After S104, the inherited assertion methods were visible, but calls such as
`AssertNotNull(World)` still failed with one viable-looking declaration and an
argument rank of `-1`:

```text
params=UObject ... arg0=UWorld typeDecl=UWorld authored=0 rank0=-1
```

The focused ambient-Engine fixture first proved that the host registration
snapshot was already correct: the copied registered type facts contained the
stable relation `UWorld -> UObject`. The data was lost one layer later:

- `ResolveQualifiedNominalType` could intern a registered `QualType` without
  materializing its corresponding native `ClassDecl`;
- `ProjectCanonicalRegisteredBaseType` materialized `Decl::bases`, but was
  entered only by record-base and PreClass-shadow paths;
- native property/method/behaviour interning could independently create a
  range-less `canonical-native-type-view` declaration shell with no base edges;
- two lexical fast paths in `ActOnQualType` returned that partial shell before
  registered nominal projection could repair it.

The result was a split semantic identity: the expression had the right stable
`UWorld` `QualType`, while the class relation query saw an incomplete
declaration graph. Runtime TypeId was not the missing datum and is not used by
the fix.

### Implemented boundary

Registered object nominal resolution now routes through the same native
declaration projector used for explicit native bases. The projector itself was
changed from recursive create-and-return to a two-phase reachable-graph
projection:

1. breadth-first create or reuse every `canonical-native-type-view` declaration
   by exact stable key;
2. normalize its registered kind/traits, then connect all stable base edges in
   a second pass.

This has three useful properties:

- member-import-created partial shells are repaired rather than duplicated;
- repeated projection is idempotent;
- an invalid cyclic host ancestry graph terminates instead of recursively
  overflowing.

The two `ActOnQualType` lexical shortcuts now keep lexical precedence for real
authored declarations, but allow native views to fall through to this unified
projection path. The compile/install boundary is therefore:

```text
host UClass/asCObjectType registration
  -> copied stable registered fact { key, kind, baseStableKeys }
  -> Canonical native ClassDecl graph + Decl::bases
  -> overload/reference conversion ranking
  -> generation-local Runtime type resolution only for binding/execution
```

No Runtime `TypeId`, type pointer or generation-local object is persisted in
the Canonical AST.

### TDD and whole-Engine evidence

The production fixture uses the initialized UE AngelScript engine, asserts
that its copied fact set contains `UWorld -> UObject`, and canonically compiles
`AcceptAmbientObject_5E71(UObject)` called with a `UWorld` argument.

- fact-check RED build:
  `Saved/Build/cta-s105-ambient-uobject-fact-red-build/20260830_222929_922_33b633e2`;
- semantic RED:
  `Saved/Tests/cta-s105-ambient-uobject-fact-red/20260830_222951_034_02081f25`
  — **1/1 FAIL** after the fact assertion passed, with
  `hits=1 ... arg0=UWorld ... rank0=-1`;
- unified projection build:
  `Saved/Build/cta-s105-unified-native-nominal-projection-green-build/20260830_223317_576_76d78682`;
- focused GREEN:
  `Saved/Tests/cta-s105-unified-native-nominal-projection-green/20260830_223330_021_4ea07da9`
  — **1/1 PASS**, including Canonical CodeGen publication;
- first whole-Engine run:
  `Saved/Tests/cta-s105-whole-engine-after-unified-native-nominal-projection/20260830_223424_508_e69a3bdd`
  — **65 diagnostics**, still showing the assertion conversions. This run
  exposed the two lexical native-view bypasses that a fresh focused module did
  not contain;
- bypass-closure build:
  `Saved/Build/cta-s105-close-lexical-native-view-bypass-build/20260830_223643_838_578d81ce`;
- final whole-Engine run:
  `Saved/Tests/cta-s105-whole-engine-after-closing-native-view-bypass/20260830_223657_000_3d5ef81f`
  — **64 -> 55** total diagnostics and **35 -> 24** unresolved callees.

The final whole-Engine reduction includes:

```text
AssertNotNull  4 -> 0
AssertNull     4 -> 0
AssertSame     2 -> 0
GetOuter       1 -> 0
```

The remaining 55 Sema diagnostics are:

```text
24 unresolved-callee
13 unresolved-scope
 8 ambiguous-overload
 6 unresolved-identifier
 2 native-function-canonical-identity-invalid
 1 generated-accessor-copy-constructor-unavailable
 1 global-init-not-constant
```

The unresolved-scope count became `13` because later sections now progress far
enough to report two additional scope failures; this is downstream exposure,
not a regression of the repaired object-reference relation. Separate staged
CodeGen failures are also visible after Sema advances further and remain
tracked as independent roots.

### Refined next roots after CTA-S105

1. `StaticClass` is unresolved four times and cascades into `SpawnObject`,
   `SpawnActor`, `SpawnComponent` and `NewObject`; this is the next largest
   coherent reflected-class/template cluster.
2. Range-for/container lowering still leaves `auto` iterator/element values,
   causing `Proceed`, `GetKey`, `GetValue`, `SetValue` and some ambiguous
   overloads.
3. Static/type scopes remain unresolved for `FString`, `FText`,
   `UBillboardComponent` and `UEnhancedInputLocalPlayerSubsystem`.
4. Covariant `TSubclassOf<Derived> -> TSubclassOf<Base>` remains unresolved for
   `CreateWidget`.
5. Delegate/mixin/property inventory still leaves `Execute`, `AddUFunction`
   and `Tags.Add` cases.
6. Generated accessor, string/value materialization, interface-dispatch graph
   authentication and other CodeGen/lifetime failures are now an explicit
   downstream closure rather than being hidden behind the object conversion
   root.

## CTA-S106 — type and companion-namespace qualified scope

### Root cause

The maintained Unreal AngelScript surface represents many static-looking APIs
with two declarations that intentionally share one source qualifier:

```text
ClassDecl/EnumDecl  TypeName
NamespaceDecl       TypeName
                    └─ static helper/global function
```

Examples include generated script-class `StaticClass()`,
`FText::FromString`, `UBillboardComponent::Create`,
`UEnhancedInputLocalPlayerSubsystem::Get` and formatting helpers. Canonical
preserved both declaration owners correctly, but `FindQualifierScopeCandidate`
treated any two qualifier declarations as ambiguous. Consequently:

- native global interning created the companion namespace before qualifier
  lookup, producing `unresolved-scope:<Type>`;
- generated script `StaticClass` was parsed into the same-key namespace but an
  earlier call had already selected the class scope and found no direct child,
  producing `unresolved-callee:StaticClass`;
- those failures cascaded into reflected spawn/helper calls whose class
  argument never formed.

The focused RED contained both `DECL kind=Class name=Companion key=Companion`
and `DECL kind=Namespace name=Companion key=Companion`, plus an unresolved
`Companion::StaticValue()` call and `unresolved-scope:Companion`.

### Implemented boundary

A qualifier collision is now recognized as a legal companion pair only when:

- both declarations have the same parent and exact stable key;
- exactly one is a namespace;
- the other is a class, interface or enum.

The type declaration remains the stable representative of the source
qualifier. Exact call lookup first searches the type scope and only after a
miss searches the unique same-key companion namespace. Two namespaces, two
types, different stable keys or any non-companion collision still fail closed.

This preserves actual ownership instead of copying static functions into the
record:

```text
TypeName::Member()
  -> unique type/namespace companion qualifier
  -> type member lookup
  -> exact companion namespace lookup on miss
  -> CallExpr owns the real FunctionDecl stable key
```

### TDD and whole-Engine evidence

- focused RED build:
  `Saved/Build/cta-s106-companion-scope-red-build/20260830_224213_823_2ccfa478`;
- focused RED:
  `Saved/Tests/cta-s106-companion-scope-red/20260830_224239_148_e7c65ae7`
  — **1/1 FAIL**, exact `unresolved-scope:Companion` with both same-key
  declarations visible in the AST dump;
- GREEN build:
  `Saved/Build/cta-s106-companion-qualified-scope-green-build/20260830_224348_768_639360fc`;
- focused GREEN:
  `Saved/Tests/cta-s106-companion-qualified-scope-green/20260830_224402_237_f9685516`
  — **1/1 PASS**, `Companion::StaticValue()` resolves to the namespace-owned
  stable FunctionDecl;
- whole-Engine:
  `Saved/Tests/cta-s106-whole-engine-after-companion-qualified-scope/20260830_224441_423_c3fe9eba`
  — **55 -> 39** Sema diagnostics.

The whole-Engine delta includes:

```text
unresolved-scope  13 -> 0
StaticClass        4 -> 0
SpawnObject        1 -> 0
SpawnActor         1 -> 0
SpawnComponent     1 -> 0
```

`ApplyFormat` and three additional ambiguous-overload diagnostics are newly
visible downstream because those expressions now pass scope resolution and
reach real overload selection. The remaining 39 Sema diagnostics are:

```text
18 unresolved-callee
11 ambiguous-overload
 6 unresolved-identifier
 2 native-function-canonical-identity-invalid
 1 generated-accessor-copy-constructor-unavailable
 1 global-init-not-constant
```

### Refined next roots after CTA-S106

1. Range-for/container type recovery is now the largest coherent cluster:
   `Proceed` 4, `GetKey` 3, `GetValue` 2 and `SetValue` 1, plus related
   ambiguous-overload diagnostics. Their arguments remain `auto` instead of
   exact iterator/element types.
2. `AddUFunction` remains three times with unresolved function-name/member
   expressions; `Execute` is the corresponding delegate-call cluster.
3. `TSubclassOf<UExampleWidget> -> TSubclassOf<UUserWidget>` covariance still
   blocks `CreateWidget`.
4. `NewObject` now remains as the only reflected spawn/new helper failure; its
   authored script receiver relation and unresolved class argument need to be
   separated before changing conversion ranking.
5. `Tags.Add`, format `ApplyFormat`, generated accessor copy construction,
   native identity diagnostics and the now-visible CodeGen/lifetime failures
   remain independent closures.

## CTA-S107 — exact `auto` deduction and production range-for

The UE preprocessor lowers production range-for to ordinary `auto` iterator
and element declarations.  Their initializer expressions already owned exact
canonical types, but declaration commit retained the parser placeholder
`auto`.  Member calls therefore had no exact nominal owner.

CTA-S107 now consumes local/global declaration intent, commits the exact
initializer `asASTQualType`, refreshes shared declaration groups, preserves
the preprocessor's transient auto-const-ref intent, records exact dependencies
and rejects any sealed declaration that still carries the `auto` placeholder.
The closure remains pointer-free and does not persist dynamic TypeId state.

Evidence:

- focused RED:
  `Saved/Tests/cta-s107-local-auto-inference-red/20260830_225438_358_44a04c96`
  — **1/1 FAIL**;
- exact range-for GREEN:
  `Saved/Tests/cta-s107-auto-intent-green/20260830_230844_389_e994ba48`
  — **1/1 PASS**;
- whole-Engine:
  `Saved/Tests/cta-s107-whole-engine-after-auto-intent/20260830_230928_898_4b098535`
  — Sema diagnostics **39 -> 29**, unresolved-callee **18 -> 8**;
  `Proceed`, `GetKey`, `GetValue` and `SetValue` are all absent from the
  remaining inventory.

The full root analysis, semantic matrix, evidence and known follow-ups are in
`attachments/cta-s107-auto-deduction-and-range-for-gate-2026-08-30.md`.

## CTA-S108 — inherited native properties and exact relocation owner

The apparent `AddUFunction` callback cluster was a receiver-property cascade.
The name-literal arguments were already exact `FName` values; Canonical Sema
could not see event/tag/name properties declared on exact native ancestors.

CTA-S108 lazily projects only the requested direct native property onto its
exact Canonical base `ClassDecl`, then uses pointer-free nearest-depth base
lookup with fail-closed ambiguity. Bytecode relocation now authenticates and
carries the exact declaring property owner instead of reconstructing ownership
from the derived receiver.

Evidence:

- focused RED:
  `Saved/Tests/cta-s108-inherited-native-property-red/20260830_231758_208_06879882`
  — **1/1 FAIL**, `unresolved-identifier:NativeMarker`;
- focused GREEN:
  `Saved/Tests/cta-s108-explicit-native-property-owner-green/20260830_232740_350_352aad61`
  — **1/1 PASS**, implicit/explicit-this access and exact root owner;
- staged whole-Engine:
  `Saved/Tests/cta-s108-whole-engine-after-inherited-native-property/20260830_232947_262_8551e40d`
  — Sema diagnostics **29 -> 21**, unresolved-callee **8 -> 4** and
  unresolved-identifier **6 -> 2**.

`AddUFunction ×3`, `Tags.Add`, both overlap-event identifiers, `Tags`, and one
inherited `NodeName` occurrence disappear. Remaining unresolved callees are
`ApplyFormat`, `CreateWidget`, `Execute` and `NewObject`. The exact architecture,
full RED-to-GREEN relocation sequence and downstream failure inventory are in
`attachments/cta-s108-inherited-native-property-and-exact-relocation-gate-2026-08-30.md`.
