## Context

`refactor-as-manual-binding-architecture` is complete and remains the authority for explicit binding phases, engine-scoped state, fluent results, named native callable ownership, generated binding transport, and StaticJIT integration. This change applies a repository-wide presentation and file-ownership convention on top of that architecture.

The current source snapshot contains 120 `Bind_*.cpp` files with real `AS_FORCE_LINK const FAngelscriptBind` definitions. Only `Bind_AActor.cpp` currently has the selected file-head AngelScript surface table. Actor also demonstrates the desired registrar form: the logical name, `EAngelscriptBindPhase`, and non-capturing `FAngelscriptBinds&` provider lambda are visible together, while the AS-callable implementation remains a named owner function.

The source snapshot also contains 96 `Bind_<Family>_Functions.h` headers beside 95 `_Functions.cpp` implementations and several pre-existing `Bind_<Family>.h` files. Callable declarations, Type declarations, operations, template definitions, registrars, and implementations therefore have no single predictable family entry point. The Type-adapter scan likewise shows container, reflection, delegate, primitive, and scalar adapters variously local to registrar `.cpp` files, mixed into callable headers, or grouped in reusable helper templates. This change establishes one deterministic family convention rather than a pilot or optional extraction rule.

## Goals / Non-Goals

**Goals:**

- Give every real Bind registrar one locally reviewable, script-facing source index.
- Keep the source index accurate for methods, globals, constructors, properties, constants, enums, mixins, overloads, and stable dynamic-generation patterns.
- Preserve Actor provider lambdas at the registrar definition site without turning direct AS callables into anonymous lambdas.
- Remove the audited Actor internal entry point and include-only shim.
- Replace all 96 `_Functions.h` headers with one canonical `Bind_<Family>.h` entry point per affected family.
- Give every non-exempt concrete Type adapter explicit family-header and `_Type.cpp` ownership.
- Select and record the narrowest correct test layer for each discovered gap.

**Non-Goals:**

- Redesign binding phases, the typed bind DSL, reflective fallback, UHT emission, StaticJIT architecture, generic-call marshalling, or native-module POD transport.
- Change supported public AS declarations or behavior.
- Enforce prose wording, exact ASCII width, or wrapping geometry in an automation test.
- Move registrar definitions or script documentation out of `Bind_<Family>.cpp`.
- Create empty `_Functions.cpp`, `_Type.cpp`, or support headers merely to make filenames symmetrical.
- Extract `FUObjectType`, `FSubclassOfType`, `FObjectPtrType`, or `FWeakObjectPtrType` from `Bind_BlueprintType.cpp` in this change.

## Decisions

### 1. Keep one finite follow-up change

This OpenSpec owns the complete current registrar-documentation migration, Actor cleanup, Type ownership migration, and directly discovered contract-test gaps. It remains open while implementation is active, but it is not an indefinite “second exemplar” experiment. A finding is split only when it changes a supported public contract or shared binding/UHT/StaticJIT/native-module architecture.

### 2. The registrar `.cpp` is the single documentation owner

Every `Bind_*.cpp` containing a real `FAngelscriptBind` has one `/** ... */` block before its first registrar. The block contains a two-column ASCII table headed `AngelScript usage signature` and `Purpose / parameter notes`.

The left column uses actual script spelling:

- member calls use `Type.Method(...)`;
- namespace/global calls use `Namespace::Function(...)`;
- constructors, properties, enum constants, and types use their stable AS syntax;
- generated families use explicit placeholders such as `<ActorType>::Spawn(...)`;
- every static overload has its own logical entry and declarations end in `;`;
- long signatures wrap inside the signature cell, with the final `);` kept together;
- every logical entry has a separator.

The right column starts with a compact purpose, followed only by non-obvious Doxygen-style `@param Name Description` notes. Notes explain inferred types, cross-parameter constraints, append semantics, lifecycle obligations, fallback routing, domain ambiguity, and exceptional/null behavior. Obvious flags and direct values are not restated. Purpose and parameter lines pack from the top and wrap only when they exceed the column.

Static registrations are listed exactly. Dynamic/reflection registrars list their stable script pattern and explain runtime expansion rather than attempting to enumerate every runtime UClass or UFunction. Native-only injected values such as `TypeId` appear only in a clearly labeled implementation note and never as script parameters.

The canonical `Bind_<Family>.h` owns family-facing declarations: native callable owners, family-owned Type adapter declarations, exported operations or payload declarations that form the family contract, and template definitions that must be visible at the point of instantiation. `Bind_<Family>_Functions.cpp` owns out-of-line native callable algorithms and may keep algorithm or safety comments, but not a duplicate script API catalogue. `Bind_<Family>_Type.cpp` owns out-of-line `FAngelscriptType` virtual implementations and Type-private helpers. Neither implementation file owns the surface table because neither owns the registrar.

### 3. File ownership and documentation completeness are delivery audits, not unit-test contracts

The implementation uses the frozen 120-registrar and 96-header inventories, exact source searches, review scripts, the Runtime build, and `git diff --check` to prove that every required surface block and canonical family header was delivered. It does not add a permanent `BindFamiliesUseCanonicalDeclarationHeaders`-style test, a comment-marker test, or another SourceLayout assertion for filenames/include shape. Those details are maintainability conventions reviewed when the source changes, not supported runtime behavior.

The already-verified Actor provider regression may continue to distinguish `FAngelscriptBinds&` provider lambdas from direct AS-callable lambdas because it protects the specific Actor registrar decision already implemented. It is not generalized into a repository-wide header/comment topology suite. Named `FAngelscriptActorBinds` functions remain the callable owners.

### 4. Internal cleanup is evidence-gated

`__Actor_GetAllByClass` has no active project script, generator, or runtime consumer. Its only preprocessor occurrence is a disabled generated-GetAll stub, and its only executable AS use is an internal-only test branch. Removal therefore deletes the registration, `GetAllActorsByClassUnchecked` helper declaration/definition, table row, disabled stub, and that branch together. Public inferred-class, explicit-class, and tag-based queries remain covered.

`Bind_Actor.h` contains only the then-current Actor callable include. Its two active consumers have already been changed to include `Bind_AActor_Functions.h` directly and the shim has been deleted in the unverified implementation. The final family-header migration then moves the callable declarations into `Bind_AActor.h`, retargets those consumers again, and deletes `Bind_AActor_Functions.h`. `Bind_Actor.h` and `Bind_AActor.h` are different paths: the former is obsolete, while the latter is the required canonical family header. Similarly named Editor CodeGen files/functions are unrelated and remain unchanged.

### 5. One canonical header and responsibility-specific implementations per family

All 96 `Bind_<Family>_Functions.h` headers are eliminated. Their declarations merge into `Bind_<Family>.h`; when that path already exists, the migration merges responsibilities into the existing header rather than creating a second facade. The registrar remains in `Bind_<Family>.cpp`, and native callable bodies remain or move to `Bind_<Family>_Functions.cpp`.

Every concrete direct or indirect `FAngelscriptType` adapter outside the explicit Blueprint exceptions moves into the same semantic family topology. Its declaration lives in `Bind_<Family>.h`; its out-of-line virtual implementations and Type-private helpers live in `Bind_<Family>_Type.cpp`. Primary, iterator, const-iterator, and tightly coupled base adapters remain grouped by family. Small scalar families are included.

Templates obey C++ visibility rather than filename symmetry. Shared templates in `Helper_CppType.h`, `Helper_PODType.h`, and `Helper_StructType.h` remain header-only. Family-local templates such as the Primitive hierarchy move in full to `Bind_Primitives.h`. A `_Type.cpp` contains only concrete/out-of-line Type implementation; a `_Functions.cpp` contains only out-of-line callable implementation. If a family has no such implementation, the corresponding file is not created.

Existing export visibility is preserved: currently exported adapters and callable owners remain exported; module-private declarations do not become public merely because they move to a family header. Support headers such as operation payloads, generated-prep contracts, struct payloads, or shared helpers may remain only when an audit identifies a responsibility distinct from the family facade, real consumers, and the export/template reason they cannot merge. A retained support header must not become a second family declaration catalogue.

The four object adapters in `Bind_BlueprintType.cpp` are inventoried but not moved because reflection/property/hot-reload/type-lookup coupling requires a separate high-risk change. `FAngelscriptActorBinds` is a callable owner, not a Type adapter; its declaration moves from `Bind_AActor_Functions.h` into `Bind_AActor.h`, while its implementation remains in `Bind_AActor_Functions.cpp`.

### 6. Tests prove Bind interfaces and behavior, not repository layout

Bindings CQTests prove representative AS declaration resolution and native reachability. Coverage/Functional tests own value matrices, world lifecycle, and Actor spawn routing. TypeUsage/TypeRegistry/TypeDatabase protect adapter registration, and StaticJIT NativeForms protects callable/native spelling. No new automation test is added merely to assert the canonical header filename, include spelling, `_Functions.h` absence, `_Type.cpp` presence, or file-head comment marker.

Comment-only batches require source inspection, inventory reconciliation, and `git diff --check`; they do not require a fresh UE build. Header/Type ownership waves require static inventory reconciliation, the plugin build, and the focused family/API prefixes plus the shared Type/StaticJIT prefixes. Verification paths and counts are recorded before an issue becomes `Verified`.

## Migration Order

1. Rewrite the record and freeze registrar/Type inventories.
2. Close Actor internal-symbol and header-shim cleanup.
3. Migrate all remaining registrar surface blocks, handling static registrars first and dynamic/reflection registrars last.
4. Consolidate all 96 legacy callable headers into canonical family headers, auditing every separately retained support header.
5. Move all non-Blueprint concrete Type declarations into those family headers and their out-of-line implementations into `_Type.cpp` files in template/container, reflection/complex, and scalar/value waves.
6. Run final build and shared regressions, reconcile inventories, and commit the plugin before the parent gitlink.
