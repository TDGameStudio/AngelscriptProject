## 1. Establish the auditable baseline

- [ ] 1.1 Create and maintain the normalized binding-surface matrix from the seed UnrealCSharp inventory, including reference, native family, AngelScript form, disposition, evidence, priority, and rationale.
- [ ] 1.2 Classify the known normalization paths for each reviewed family: constructors, operators, globals, `FMath`, reflection, and template registrations.
- [ ] 1.3 Record each reviewed item as `AvailableExact`, `AvailableEquivalent`, `ReflectionOrTemplate`, `MissingCandidate`, `IntentionalNonGoal`, or `BlockedByDependency`; do not promote a raw name diff directly to an implementation task.

## 2. Audit and select foundation value-type waves

- [ ] 2.1 Audit the geometry family (`FVector`, `FVector2D`, `FVector4`, `FPlane`, `FQuat`, `FRotator`, and `FTransform`) and rank only the candidates with a clear script-facing benefit.
- [ ] 2.2 Audit the utility-value family (`FColor`, `FLinearColor`, `FDateTime`, `FTimespan`, `FGuid`, and `FRandomStream`) and select one small coherent implementation cluster.
- [ ] 2.3 For each selected candidate, confirm its Unreal Engine semantics, module availability, declaration shape, existing bind phase, and whether a StaticJIT-specific regression is relevant.

## 3. Implement approved foundation candidates incrementally

- [ ] 3.1 Add focused AngelScript behavioral tests for the first approved geometry or utility-value candidate before or alongside its manual binding change.
- [ ] 3.2 Implement the approved explicit binding using the established owner/provider and existing `ExplicitBindings` lifecycle, without changing generated, reflected, or template ownership.
- [ ] 3.3 Update the owning `FAngelscriptBind` file-header API table with purpose and non-obvious `@param` notes for every public API added by the wave.
- [ ] 3.4 Run the focused binding tests and any justified StaticJIT regression, then record the command/result in the audit evidence.

## 3A. Implement the actor spawn-parameter wave

- [x] 3A.1 Add a functional Actor test that compiles and exercises `FActorSpawnParameters`, transform-based spawning, typed spawning, and deferred-spawn completion. <!-- TDD -->
- [x] 3A.2 Register `FActorSpawnParameters` as a non-reflected AngelScript value type, including construction, copying, common spawn fields, and safe bitfield accessors.
- [x] 3A.3 Register `ESpawnActorNameMode` and add transform-plus-parameter overloads for global, `UWorld`, and reflected typed Actor spawning.
- [ ] 3A.4 Update the Actor provider API table and audit evidence with the chosen public surface and focused validation result.

## 4. Expand only after foundation evidence is complete

- [ ] 4.1 Audit generic and object-wrapper families (containers, optional, object/class/function/struct, pointers, and paths), distinguishing template/reflection coverage from explicit-binding candidates.
- [ ] 4.2 Select and implement a small approved wrapper-family wave with behavioral tests, provider documentation, and focused verification evidence.
- [ ] 4.3 Audit specialty families (`FMatrix`, `FBox2D`, ranges/intervals, frame values, asset bundle data, and polyglot text data) only when a concrete script need or supported dependency path exists.
- [ ] 4.4 Record specialty candidates that are unsuitable or dependency-blocked as explicit dispositions rather than carrying them as implied missing work.

## 4A. Implement the approved high- and medium-priority value-type wave

- [x] 4A.1 Verify exact current-engine declarations, target module availability, and existing AngelScript registrations; record confirmed public type representations in `high-medium-value-types-wave.md`.
- [x] 4A.2 Add failing CQTest scenarios for `FPrimaryAssetType` / `FPrimaryAssetId` construction/parsing plus `FAssetBundleEntry` / `FAssetBundleData` mutation and safe lookup. <!-- TDD -->
- [x] 4A.3 Bind the AssetManager value cluster in direct-lambda `ExplicitBindings` providers, using `FTopLevelAssetPath` and a non-escaping `FindEntry` adaptation.
- [x] 4A.4 Add failing CQTest scenarios and implement `FBox2D`, covering the geometry operations selected in the wave record. <!-- TDD -->
- [x] 4A.5 Add failing CQTest scenarios and implement `FFrameNumber` / `FFrameTime`, including construction, conversion, rounding, and scalar arithmetic. <!-- TDD -->
- [x] 4A.6 Add a failing CQTest and implement the bounded engine-default `FMatrix` API (`FMatrix` public alias, not parallel float/double types). <!-- TDD -->
- [x] 4A.7 Add or update each provider's file-header API table, including non-obvious `@param` notes and the final safe `FindEntry` form.
- [x] 4A.8 Run each new focused binding prefix, then run `Tools\\RunBuild.ps1`; add StaticJIT coverage only for a demonstrated declaration/operator risk.
- [x] 4A.9 Update the audit inventory and wave record with final signatures, intentionally deferred members, test/build evidence, and next priority order.

## 4B. Close range and matrix parity deltas

- [x] 4B.1 Add and observe failing public AngelScript tests for float/int
  range bounds, ranges, intervals, and the required range algebra. <!-- TDD -->
- [x] 4B.2 Supplement reflection-owned range/interval types in
  `PostReflectionBindings`, without duplicate class/default-constructor
  registration.
- [x] 4B.3 Correct `FMatrix` transform return types to `FVector4`, expose the
  selected native matrix operations, and provide script-visible `FMatrix::Zero()`
  instead of the unavailable `EForceInit` token. <!-- TDD -->
- [x] 4B.4 Record the registration constraint and focused build/test evidence.

## 5. Maintain the long-lived record

- [ ] 5.1 Keep `reference-inventory.md` and the audit matrix current as reference providers or AngelScript surfaces change.
- [ ] 5.2 After each completed family wave, update the OpenSpec tasks and supporting evidence with the changed APIs, test coverage, validation result, and remaining priority order.
- [ ] 5.3 Reassess whether the matrix format should move into a shared guide after multiple completed waves; retain it in this change while its format is still evolving.
