## ADDED Requirements

### Requirement: Every real Bind registrar owns a script-facing surface index

Every project-owned `Bind_*.cpp` containing a real `FAngelscriptBind` definition SHALL contain one UE/Doxygen-style file-head two-column surface block before its first registrar. The block SHALL describe the complete stable AngelScript surface owned by that file using actual script spelling and SHALL be the single owner of binding-facing purpose and parameter documentation.

#### Scenario: A static registrar exposes script declarations
- **WHEN** a registrar file binds types, enums, constructors, properties, constants, members, mixins, namespace functions, global functions, or overloads
- **THEN** every stable static declaration MUST appear in the file-head table with its actual script usage form and terminating semicolon
- **THEN** member calls MUST use `Type.`, namespace/global calls MUST use `Namespace::`, and every overload MUST have its own logical entry
- **THEN** long declarations MAY wrap inside the signature cell, but the final `);` MUST remain together and every logical entry MUST have a separator

#### Scenario: A dynamic registrar synthesizes runtime declarations
- **WHEN** a registrar expands reflected classes, functions, delegates, subsystems, or other runtime-discovered types
- **THEN** the table MUST list the stable script usage pattern with explicit placeholders rather than enumerate every runtime object
- **THEN** the Purpose column MUST explain the runtime expansion
- **THEN** every static declaration in the same file MUST still be listed exactly

#### Scenario: A parameter is non-obvious
- **WHEN** a parameter controls inferred type, cross-parameter compatibility, append semantics, lifecycle obligations, fallback routing, domain interpretation, or exceptional/null behavior
- **THEN** the right column MUST include a Doxygen-style `@param Name Description` note
- **THEN** the note MUST stay on one physical row when it fits and wrap only when needed
- **THEN** obvious switches and direct values MAY omit redundant prose

#### Scenario: Native implementation details differ from script spelling
- **WHEN** a native helper receives an injected `TypeId`, script function, generic context, or other non-script parameter
- **THEN** the injected parameter MUST NOT appear in the AngelScript usage signature
- **THEN** a review-critical detail MAY appear as a clearly labeled native implementation note in the Purpose column

#### Scenario: Documentation ownership is checked
- **WHEN** a registrar family also has a canonical family header, `_Functions.cpp`, `_Type.cpp`, or audited support headers
- **THEN** those files MUST NOT duplicate the registrar's script-facing API catalogue
- **THEN** focused local comments MAY remain where they explain algorithmic correctness or native safety rather than the exposed binding surface

### Requirement: Registrar documentation and family topology are statically audited for delivery

The implementation SHALL reconcile the frozen registrar/header/Type inventories with exact source inspection, build evidence, and diff review. The project SHALL NOT add a permanent automation test whose purpose is to assert canonical header filenames, include spelling, `_Functions.h` absence, `_Type.cpp` presence, or file-head comment markers.

#### Scenario: A migration batch is reviewed
- **WHEN** registrar comments, canonical family headers, or Type ownership change
- **THEN** the implementation record MUST reconcile affected inventory rows and exact searches
- **THEN** C++ ownership changes MUST compile through the project build entry point
- **THEN** behavior/API verification MUST use the owning Bindings, Functional, Coverage, Type, or StaticJIT tests rather than a repository-layout unittest

### Requirement: Every callable family has one canonical header

The project SHALL eliminate all 96 legacy `Bind_<Family>_Functions.h` headers and SHALL use `Bind_<Family>.h` as the single canonical declaration entry point for each affected family. The family header SHALL own native callable declarations, family-owned Type declarations, and required visible templates. `Bind_<Family>.cpp` SHALL retain registrar definitions, phases, provider callbacks, callable registration, fluent traits, native forms, and the script-facing surface block. `Bind_<Family>_Functions.cpp` SHALL own out-of-line native callable implementations.

#### Scenario: A legacy callable header is consolidated
- **WHEN** a family currently declares callable owners in `Bind_<Family>_Functions.h`
- **THEN** those declarations MUST move to `Bind_<Family>.h`
- **THEN** all checked-in consumers MUST include the canonical family header
- **THEN** the `_Functions.h` file MUST be deleted rather than retained as a forwarding include
- **THEN** callable owner spelling, export visibility, native forms, generated callable spelling, and behavior MUST remain unchanged

#### Scenario: A canonical family header already exists
- **WHEN** `Bind_<Family>.h` already owns operations, payloads, templates, or another part of the family contract
- **THEN** callable and Type declarations MUST merge into that existing header
- **THEN** the migration MUST NOT create a competing facade or a `Bind_<Family>Type.h`

#### Scenario: A responsibility has no out-of-line implementation
- **WHEN** a family has no out-of-line native callable body or no out-of-line Type implementation
- **THEN** an empty `_Functions.cpp` or `_Type.cpp` MUST NOT be created solely for naming symmetry
- **THEN** template definitions MUST remain visible in the canonical family header or an audited shared helper header

#### Scenario: A support header remains separate
- **WHEN** an operation payload, generated-prep contract, shared helper, struct payload, or other support declaration cannot merge into the family header without creating a false dependency or losing template/export correctness
- **THEN** the ownership audit MUST record its distinct responsibility, consumers, and retention reason
- **THEN** the support header MUST NOT duplicate the family declaration catalogue

### Requirement: Actor providers remain locally reviewable

`AActor.Manual` and `AActor.PostReflection` SHALL keep their logical name, explicit phase, and non-capturing `FAngelscriptBinds&` provider lambda expanded directly at the `FAngelscriptBind` definition. Direct AngelScript callables SHALL remain named `FAngelscriptActorBinds` functions.

#### Scenario: Provider and callable lambdas are classified
- **WHEN** the existing Actor provider-lambda regression inspects `Bind_AActor.cpp`
- **THEN** both registrars MUST contain a direct `[](FAngelscriptBinds& Binds)` provider body at the registration site
- **THEN** that provider MUST NOT be classified as a direct AS-callable lambda
- **THEN** production callable registrations MUST continue to reference semantic owner functions

### Requirement: Obsolete Actor internal binding paths are removed with evidence

The project SHALL remove an obsolete internal double-underscore entry point only after repository-wide inspection distinguishes active consumers from disabled/commented source and identifies retained public replacements.

#### Scenario: `__Actor_GetAllByClass` is removed
- **WHEN** the confirmed Actor cleanup is implemented
- **THEN** the registration, `GetAllActorsByClassUnchecked` declaration/definition, file-head row, disabled preprocessor stub, and internal-only test branch MUST be removed together
- **THEN** inferred-class, explicit-class, and tag-based public query assertions MUST remain
- **THEN** exact repository searches MUST report no remaining internal symbol or helper references

### Requirement: Compatibility-only Bind headers use canonical owners

A checked-in Bind header containing only an include of a canonical callable owner SHALL be deleted after all active consumers include that owner directly.

#### Scenario: `Bind_Actor.h` is removed
- **WHEN** the Actor compatibility shim is removed
- **THEN** the intermediate cleanup MAY point StaticJIT and Engine Hooks tests at `Bind_AActor_Functions.h` while verification is pending
- **THEN** the final family-header migration MUST point them at `Bind_AActor.h` and delete `Bind_AActor_Functions.h`
- **THEN** `FAngelscriptActorBinds` spelling, export visibility, native forms, and generated callable behavior MUST remain unchanged
- **THEN** similarly named Editor CodeGen output MUST remain unchanged

### Requirement: Every non-exempt Type adapter has explicit family ownership

Every project-owned concrete direct or indirect `FAngelscriptType` adapter SHALL be inventoried and moved into its semantic family topology unless it is one of the explicitly deferred `Bind_BlueprintType.cpp` object adapters. Its declaration SHALL live in `Bind_<Family>.h`; its out-of-line virtual implementations and Type-private helpers SHALL live in `Bind_<Family>_Type.cpp`. Small scalar adapters SHALL NOT remain local solely because they are small. Reusable header-only template infrastructure SHALL remain in its audited helper header.

#### Scenario: A family Type implementation is extracted
- **WHEN** one or more related adapters move from a registrar or mixed callable header
- **THEN** the canonical family header MUST own the adapter declarations
- **THEN** `_Type.cpp` MUST own out-of-line virtual implementations and adapter-only helpers
- **THEN** the original registrar file MUST retain registrar definitions, phases, callbacks, callable registration, fluent traits, native forms, and the script surface block
- **THEN** existing script declarations, registration order, TypeDB ownership, exports, GC/property behavior, and callable behavior MUST remain unchanged

#### Scenario: A template adapter requires visible implementation
- **WHEN** an adapter is reusable shared template infrastructure
- **THEN** it MUST remain in the appropriate `Helper_*Type.h`
- **WHEN** a template is local to the Primitives family
- **THEN** its complete definition MUST live in `Bind_Primitives.h`, while concrete/out-of-line Type implementation MAY live in `Bind_Primitives_Type.cpp`
- **THEN** no empty `.cpp` SHALL be created only to satisfy naming symmetry

#### Scenario: A Blueprint object adapter is encountered
- **WHEN** inventory reaches `FUObjectType`, `FSubclassOfType`, `FObjectPtrType`, or `FWeakObjectPtrType`
- **THEN** the adapter MUST remain in `Bind_BlueprintType.cpp` for this change
- **THEN** its reflection/property/type-lookup/hot-reload risk MUST remain recorded as a focused future checkpoint

#### Scenario: A callable owner is not a Type adapter
- **WHEN** a symbol such as `FAngelscriptActorBinds` does not derive directly or indirectly from `FAngelscriptType`
- **THEN** its declaration MUST remain with callable ownership in the canonical family header and MUST NOT move into `_Type.cpp`

### Requirement: Binding test responsibility is selected by behavior

Every implemented test gap SHALL use the narrowest behavior-owning layer: Bindings CQTests for AS-visible resolution and native reachability, Coverage/Functional for semantic matrices and lifecycle, TypeUsage/TypeRegistry/TypeDatabase for adapter registration behavior, and StaticJIT NativeForms for generated/native callability. The already-verified Actor provider-lambda regression is retained as a specific historical architecture guard; it SHALL NOT be generalized into canonical-header or comment-marker tests.

#### Scenario: A registrar inventory row lacks representative contract coverage
- **WHEN** the exposed entry point or dynamic pattern has no representative compile/resolve/invoke or focused failure assertion
- **THEN** the owning test layer MUST receive the smallest missing regression before the row is Verified
- **THEN** broad semantic combinations MUST NOT be duplicated in Bindings solely to increase row counts

#### Scenario: A filename or comment convention changes
- **WHEN** the change affects only canonical header naming, include shape, implementation-file placement, or registrar surface comments
- **THEN** the project MUST use static audit, build/diff review, and existing behavior tests as appropriate
- **THEN** it MUST NOT add a dedicated long-term automation test for that repository shape

### Requirement: Verification evidence gates completion

An issue or inventory row SHALL become `Verified` only after its required commands, report paths, and pass/fail counts are recorded. Comment-only edits require source inspection and whitespace validation. C++ ownership or runtime changes require static ownership audit, the plugin build, and affected focused prefixes, including StaticJIT when native callability may be affected.

#### Scenario: An implementation row is closed
- **WHEN** an issue or inventory row is proposed for `Verified`
- **THEN** its required commands, report paths, and pass/fail counts MUST already be recorded
- **THEN** comment-only work MUST include source inspection and whitespace validation
- **THEN** C++ ownership or runtime work MUST include the plugin build and every affected focused prefix
