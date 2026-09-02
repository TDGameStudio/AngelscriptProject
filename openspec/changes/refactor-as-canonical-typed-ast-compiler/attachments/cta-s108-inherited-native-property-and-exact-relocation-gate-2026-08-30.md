# CTA-S108 inherited native property and exact relocation gate

Date: 2026-08-30

## Scope and conclusion

CTA-S108 closes the production failure in which a Canonical receiver could not
see a property declared on an exact native ancestor. The visible
`AddUFunction` failures were a cascade, not a callback-name or function-reference
defect:

```text
receiver event property is unresolved
  -> recovery receiver becomes int
  -> AddUFunction has no candidate on int
```

The implemented relation is deliberately split across phases:

- Canonical Sema walks the pointer-free Canonical base graph and projects only
  the requested direct property on its exact registered native owner;
- ordinary Canonical base lookup applies nearest-base visibility, hiding and
  fail-closed same-depth ambiguity;
- Bytecode CodeGen authenticates the sealed field by exact owner stable key,
  property name, exact type and byte offset;
- Runtime object/type pointers and dynamic TypeId remain generation-local
  relocation coordinates and are not persisted in the Canonical AST.

The focused regression is **1/1 PASS**. The staged whole-Engine gate reduces
Canonical Sema diagnostics from **29 to 21**. All three `AddUFunction`
diagnostics, `Tags.Add`, the two overlap-event identifiers, `Tags`, and one
inherited `NodeName` identifier disappear from the production inventory.

## Corrected root-cause analysis

The three `AddUFunction` sites pass `n"..."` name literals. The preprocessor
already lowers those literals to `FName`, and the pre-fix diagnostics showed
the third argument resolving as `FName`. There is no source-language function
reference at these sites.

The missing expressions were the receivers:

```text
UExampleOverlapComponent : UPrimitiveComponent
  -> OnComponentBeginOverlap
  -> OnComponentEndOverlap

CollisionSphere : USphereComponent
  -> UShapeComponent
  -> UPrimitiveComponent
  -> OnComponentBeginOverlap
```

The maintained legacy compiler performs inheritance-aware property lookup
through `FindPropertyUntil`. Canonical native-method projection had already
learned to walk Canonical bases, but native-property projection still observed
only the receiver's direct Runtime property list and skipped authored script
classes. This left both authored-derived and native-leaf receiver shapes
incomplete.

The same root also explains the production `Tags.Add` cascade and one
`NodeName` occurrence. Their receiver properties live on native ancestors; once
the exact field is visible, the ordinary member-call path can resolve `Add`
without a name-specific repair.

## Implemented Sema boundary

`asCSema::InternNativePropertyCandidates(owner, name)` now performs an exact,
lazy property projection:

1. Resolve the receiver's Canonical record declaration.
2. Do not reinterpret an authored class itself as a same-spelled native shadow.
3. Traverse only sealed Canonical `Decl::bases`, with visited tracking.
4. For each exact native base, inspect only the requested direct property.
5. Create the field on that exact base `ClassDecl`, retaining the declaring
   owner stable key, exact QualType and byte offset.
6. Run ordinary nearest-depth base lookup over Canonical declarations.
7. Reject same-depth competing matches instead of choosing by traversal order.

Both implicit `NativeMarker` and explicit `this.NativeMarker` use this route.
No inherited field is copied into the authored derived class, and Runtime
`derivedFrom` is not mutated to make the lookup appear to work.

## Exact CodeGen relocation boundary

The first Sema GREEN exposed a separate but adjacent bug: CodeGen found the
field declaration but tried to materialize or relocate it against the derived
receiver type. That produced errors such as:

```text
missing runtime property: DerivedHostPropertyValue::NativeMarker
```

The property actually belongs to `HostPropertyRoot`. `PropertyFromFieldDecl`
now resolves and authenticates the exact declaring record stable key, returning
the exact Runtime property owner to the caller. Reads, writes, compound writes,
implicit-this references and explicit member references all carry that owner
into relocation capture.

Authentication is not offset-only. The candidate must match:

- the exact declaring record identity;
- the exact property name;
- the exact Runtime/Canonical type relation;
- the exact byte offset.

The direct receiver Runtime owner remains only a compatibility fallback for
older native views that do not yet carry an exact record relation. It is not
written back into the sealed AST.

## TDD evidence

Focused test:

```text
Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.
FCanonicalASTSemaAuthorityTests.
HostStableNativeBasePropertyIsVisibleToDerivedReceivers
```

Evidence sequence:

- RED build:
  `Saved/Build/cta-s108-inherited-native-property-red-build/20260830_231734_376_64d5a0f1`;
- exact Sema RED:
  `Saved/Tests/cta-s108-inherited-native-property-red/20260830_231758_208_06879882`
  — **1/1 FAIL**, `unresolved-identifier:NativeMarker`;
- first implementation build:
  `Saved/Build/cta-s108-inherited-native-property-green-build/20260830_232010_738_2cb2dc07`;
- first post-Sema run:
  `Saved/Tests/cta-s108-inherited-native-property-green/20260830_232047_112_7e3c99f0`
  — the Sema diagnostic was gone and the next CodeGen slot-lookup defect became
  visible;
- CodeGen owner-bridge build:
  `Saved/Build/cta-s108-inherited-native-property-codegen-green-build/20260830_232312_180_4e275fcc`;
- relocation RED:
  `Saved/Tests/cta-s108-inherited-native-property-codegen-green/20260830_232325_403_a789376e`
  — `missing runtime property: DerivedHostPropertyValue::NativeMarker`;
- more exact relocation builds/runs:
  `Saved/Build/cta-s108-inherited-native-property-relocation-green-build/20260830_232455_161_1ed0afd2`,
  `Saved/Tests/cta-s108-inherited-native-property-relocation-green/20260830_232508_812_b84bd6db`,
  `Saved/Build/cta-s108-exact-native-property-owner-green-build/20260830_232606_286_1ecff5c6`,
  `Saved/Tests/cta-s108-exact-native-property-owner-green/20260830_232622_317_fb4f1b25`;
- final build:
  `Saved/Build/cta-s108-explicit-native-property-owner-green-build/20260830_232721_478_7161a3d8`;
- final focused GREEN:
  `Saved/Tests/cta-s108-explicit-native-property-owner-green/20260830_232740_350_352aad61`
  — **1/1 PASS**, covering implicit and explicit-this access and the exact
  `HostPropertyRoot::NativeMarker` declaration key.

## Whole-Engine evidence

Staged run:

```text
Saved/Tests/cta-s108-whole-engine-after-inherited-native-property/
20260830_232947_262_8551e40d
```

The process exits with the expected startup compile failure because later
Canonical roots remain open. The relevant semantic delta is nevertheless
deterministic:

```text
before CTA-S108                         after CTA-S108
-------------------------------         -------------------------------
11 ambiguous-overload                   11 ambiguous-overload
 8 unresolved-callee                     4 unresolved-callee
 6 unresolved-identifier                 2 unresolved-identifier
 2 native-function-identity-invalid      2 native-function-identity-invalid
 1 generated-accessor-copy-ctor          1 generated-accessor-copy-ctor
 1 global-init-not-constant              1 global-init-not-constant
-------------------------------         -------------------------------
29 total                                21 total
```

Removed production diagnostics:

```text
unresolved-identifier:OnComponentBeginOverlap  1 -> 0
unresolved-identifier:OnComponentEndOverlap    1 -> 0
unresolved-identifier:Tags                     1 -> 0
unresolved-identifier:NodeName                 3 -> 2
unresolved-callee:AddUFunction                 3 -> 0
unresolved-callee:Add                          1 -> 0
```

The remaining unresolved callees are now:

```text
ApplyFormat   1
CreateWidget  1
Execute       1
NewObject     1
```

This whole-Engine result also covers the native-leaf production shape through
`USphereComponent -> ... -> UPrimitiveComponent`: the
`Example_BlueprintSubclass.as` `AddUFunction` failure is gone. The fixture's
authored-derived implicit/explicit checks and the production native-leaf run
together cover both inheritance shapes without adding product-name special
cases.

## Newly exposed and remaining roots

1. `Execute` is a generated script delegate-wrapper method, not a native
   function reference. The authored consumer precedes generated helper text;
   its Canonical type/method shell must reconcile later, while script functions
   must not enter the `asFUNC_SYSTEM` native-identity publication route.
2. `CreateWidget` requires flag-governed template covariance for
   `TSubclassOf<UExampleWidget> -> TSubclassOf<UUserWidget>`. This is a general
   same-template relation, not a `CreateWidget` special case.
3. `NewObject` still combines an authored-object conversion and an unresolved
   template/class argument and needs a focused split before ranking changes.
4. `ApplyFormat`, the two remaining inherited `NodeName` cases and eleven
   ambiguous overloads are independent Sema roots.
5. Ten staged CodeGen failures are now visible after semantic progress:
   dangling construct identity, four prepared-interface graph mismatches,
   generated `FVector` accessor width, string-literal construction, and three
   materialized `FString` lvalue receivers.

CTA-S108 does not make CANONICAL the product default. LEGACY remains the
default and the original AngelScript AST/compiler path remains intentionally
available for explicit compatibility, rollback and differential reference.
HIR remains physically absent.
