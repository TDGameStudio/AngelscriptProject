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

## 4. Expand only after foundation evidence is complete

- [ ] 4.1 Audit generic and object-wrapper families (containers, optional, object/class/function/struct, pointers, and paths), distinguishing template/reflection coverage from explicit-binding candidates.
- [ ] 4.2 Select and implement a small approved wrapper-family wave with behavioral tests, provider documentation, and focused verification evidence.
- [ ] 4.3 Audit specialty families (`FMatrix`, `FBox2D`, ranges/intervals, frame values, asset bundle data, and polyglot text data) only when a concrete script need or supported dependency path exists.
- [ ] 4.4 Record specialty candidates that are unsuitable or dependency-blocked as explicit dispositions rather than carrying them as implied missing work.

## 5. Maintain the long-lived record

- [ ] 5.1 Keep `reference-inventory.md` and the audit matrix current as reference providers or AngelScript surfaces change.
- [ ] 5.2 After each completed family wave, update the OpenSpec tasks and supporting evidence with the changed APIs, test coverage, validation result, and remaining priority order.
- [ ] 5.3 Reassess whether the matrix format should move into a shared guide after multiple completed waves; retain it in this change while its format is still evolving.
