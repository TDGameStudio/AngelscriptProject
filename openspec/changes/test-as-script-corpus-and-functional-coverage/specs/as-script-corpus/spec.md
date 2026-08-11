## ADDED Requirements

### Requirement: The project SHALL organize reader-facing AngelScript corpus files by stable user themes
The project SHALL place curated corpus material beneath approved `Script/<Theme>/` roots and SHALL keep the corpus structurally separate from `Script/Tests/` and the cooked `Script/Game/` fixture surface.

#### Scenario: Reader discovers a theme corpus
- **WHEN** a reader looks for Math, Containers, Actor, Component, inheritance, interface, World, or another approved core subject
- **THEN** the corresponding corpus files are grouped under the matching `Script/<Theme>/` directory
- **AND** `Script/README.md` links to those files by purpose

#### Scenario: Special cooked fixture remains stable
- **WHEN** current examples are reorganized into corpus themes
- **THEN** `Script/Game/Example_Actor.as` remains in its cooked fixture location
- **AND** the migration does not break its content dependency

### Requirement: Corpus examples SHALL express a real function or workflow purpose
Every curated corpus file SHALL use meaningful domain names, inputs, operations, and observable results, and SHALL NOT use arbitrary constant-return fixtures or empty compile-only declarations as reader-facing material.

#### Scenario: Container corpus demonstrates a useful operation
- **WHEN** a Containers file teaches TArray, TMap, or TSet
- **THEN** it performs a coherent workflow such as building, querying, updating, deduplicating, iterating, or removing domain data
- **AND** its public functions describe those outcomes

#### Scenario: Placeholder fixture is encountered
- **WHEN** a candidate file contains names such as `FPhase2*`, `FixtureValue`, or a generic `Step()` whose only effect is returning an unexplained constant
- **THEN** it is rewritten into a meaningful scenario, retained only as an explicitly non-corpus infrastructure fixture, or removed after its consumers migrate
- **AND** it is not catalogued as corpus material

### Requirement: Every corpus file SHALL contain a truthful source card
Every curated `.as` file SHALL state its purpose, demonstrated AS-facing capabilities, prerequisites, and expected observable result in a leading comment.

#### Scenario: No-setup example is catalogued
- **WHEN** an example can run without an asset, World, editor, or network setup
- **THEN** its source card explicitly records `Prerequisites: None`
- **AND** its expected result identifies the return, state, event, or log a reader will observe

#### Scenario: Environment-bound example is catalogued
- **WHEN** an example needs a World, asset, editor-only API, RHI, UI host, or network role
- **THEN** its source card names the exact prerequisite and valid execution context
- **AND** it does not imply an asset-free or local-only path covers that behavior

### Requirement: API-dense corpus files SHALL provide verified AS usage tables
Corpus files that teach a bound API family SHALL include a source-local table containing the AS-facing operation, purpose, important parameters or effects, the local example entry point, current limits, and exact publishing/test evidence.

#### Scenario: Bind provider is represented in a corpus table
- **WHEN** a Math, container, text, UObject, Actor, Component, World, subsystem, timer, engine-system, networking, or interop file lists an API
- **THEN** the listed spelling is verified against the actual bind/reflection/function-library surface
- **AND** an executable symbol in the same file demonstrates its principal use
- **AND** the row cites the publishing source and representative Bindings or FunctionLibraries test evidence

#### Scenario: Native and script names differ
- **WHEN** a `Bind_*.cpp` provider registers an alias, mixin, namespace function, operator, generated call, or reflective form whose AS spelling differs from C++
- **THEN** the table records the AS-facing form
- **AND** it does not expose the registration callback or native helper name as user syntax

#### Scenario: Operation is unsupported or environment-limited
- **WHEN** a related native API is not bound or its behavior is editor-only, asset-bound, RHI-bound, or network-bound
- **THEN** the table states that limit explicitly or omits the operation
- **AND** it never claims availability based only on a similarly named Unreal C++ method

### Requirement: The corpus SHALL use README as its authoritative catalogue
`Script/README.md` SHALL catalogue every curated corpus file and SHALL record its theme, purpose, principal symbols, prerequisites, expected result, related script-test prefix, and local evidence.

#### Scenario: Corpus file and catalogue agree
- **WHEN** corpus validation enumerates approved `Script/<Theme>/*.as` files
- **THEN** each curated file has exactly one catalogue entry
- **AND** every catalogue path resolves to a curated file in the declared theme

#### Scenario: Machine indexing is requested later
- **WHEN** a future Wiki, search, export, or AI tool needs structured corpus metadata
- **THEN** it generates the metadata from README/source-card truth
- **AND** v1 does not introduce a second hand-maintained JSON manifest

### Requirement: Corpus code SHALL remain independent of the test framework
Reader-facing corpus files SHALL NOT derive from `UAngelscriptTestSuite`, call `FAngelscriptTest`, or depend on test-only native types from `AngelscriptTest`.

#### Scenario: Corpus behavior also has an AS functional test
- **WHEN** a script test naturally exercises a public corpus function or class
- **THEN** the dependency flows from `Script/Tests/<Theme>` to the corpus surface
- **AND** the corpus file does not acquire a reverse dependency on the test suite

#### Scenario: Test requires a native fixture
- **WHEN** an interop test uses a test-only UFUNCTION/USTRUCT/object/delegate fixture
- **THEN** that use remains under `Script/Tests/Interop`
- **AND** no `Script/<Theme>` corpus file references the fixture

### Requirement: Corpus logging SHALL be meaningful and bounded
Corpus files SHALL use logs only to explain important inputs, state transitions, decisions, or final outcomes and SHALL NOT use log volume as a substitute for useful behavior.

#### Scenario: Lifecycle example logs progress
- **WHEN** an Actor, Component, subsystem, timer, or network example logs multiple phases
- **THEN** the messages identify the scenario and meaningful transition
- **AND** the example also exposes state or behavior that can be observed without parsing log volume

#### Scenario: Loop processes a collection
- **WHEN** a corpus function iterates a collection
- **THEN** it emits at most the logs needed to teach the iteration or summarize the result
- **AND** it does not log every element by default without a stated reader purpose

### Requirement: Existing examples SHALL be migrated by explicit disposition
Every existing `Script/Examples/**` file SHALL be classified as `Migrate`, `Split`, `RetireAsRedundant`, or `KeepSpecialPurpose` before source movement begins.

#### Scenario: Existing example overlaps multiple themes
- **WHEN** one current example combines capabilities owned by different corpus themes
- **THEN** it is split into focused theme files or assigned to the dominant cohesive workflow with cross-links
- **AND** its old path references are updated in the same migration task

#### Scenario: Existing example duplicates richer material
- **WHEN** an example contains only a shallow compile demonstration already superseded by a meaningful corpus workflow
- **THEN** it is classified `RetireAsRedundant`
- **AND** useful reader guidance is retained in the new corpus/catalogue rather than preserving duplicate code

### Requirement: UE Blueprint and Runtime function libraries SHALL have discoverable workflow cases
The corpus SHALL provide a `BlueprintLibraries` theme for stable UE-provided Blueprint libraries and AngelscriptRuntime static/mixin libraries whose published AS usage is not sufficiently discoverable from domain examples alone.

#### Scenario: Static or namespaced library is taught
- **WHEN** a supported library publishes functions through a script namespace or generated static surface
- **THEN** a BlueprintLibraries workflow records the final AS-facing spelling after aliases and WorldContext handling
- **AND** the executable body combines the functions into a meaningful developer task
- **AND** native `UKismet*`, wrapper, or UClass names appear only as evidence unless they are the actual published AS form

#### Scenario: Mixin library is taught
- **WHEN** a Runtime library uses `ScriptMixin` to publish static native helpers as receiver methods
- **THEN** the corpus calls them through the verified AS receiver form
- **AND** its API table cites the mixin header, manual/generated bind source, and representative function-library test

#### Scenario: Library workflow overlaps a domain example
- **WHEN** Math, Actor, Component, World, Input, Assets, UI, Collision, or another domain file already teaches the underlying behavior
- **THEN** the BlueprintLibraries file demonstrates a distinct library-composition or discovery workflow and cross-links the domain owner
- **AND** it does not copy the domain file's complete executable body

#### Scenario: Generated or reflected UE library is not present in the hand-written wrapper list
- **WHEN** the final initialized engine exposes a core `UBlueprintFunctionLibrary` through generated, UHT, or reflective binding
- **THEN** the implementation-time library audit maps its AS-visible function families to domain/BlueprintLibraries rows or an explicit disposition
- **AND** the audit does not assume the Runtime `FunctionLibraries/` directory is the complete UE library inventory

### Requirement: AS binding semantics SHALL have focused learning cases
The corpus SHALL provide a `Bindings` theme for stable AS-visible behavior introduced by manual, generated, reflective, or function-library publication when that behavior cannot be learned clearly from a domain workflow alone.

#### Scenario: Binding changes the user-facing form
- **WHEN** publication introduces an alias, overload family, namespace, mixin receiver, operator, constructor, iterator, implicit context, or reference-writeback form
- **THEN** a Bindings case demonstrates the final AS syntax and observable behavior
- **AND** registrar callbacks, thunks, provider classes, and generated shard names are not exposed as user syntax

#### Scenario: Internal binding path has no reader value
- **WHEN** a binding file only implements registration order, configuration, native-module bridging, generated storage, or another internal mechanism
- **THEN** it receives an `InternalOnly` crosswalk disposition with a reason
- **AND** no empty corpus file is generated to match the C++ source count

### Requirement: Binding and function-library sources SHALL have a complete crosswalk
The implementation SHALL map every current `Bind_*.cpp`, Bindings test source, and FunctionLibraries test source to logical provider families, user-capability rows, corpus/test targets, and explicit dispositions.

#### Scenario: Split provider files are audited
- **WHEN** one logical type or library is implemented by `_Type`, `_Functions`, and registration files
- **THEN** every physical source remains represented in the audit
- **AND** the files normalize to one logical provider family rather than generating duplicate cases

#### Scenario: Bindings test is evidence rather than backlog
- **WHEN** an existing Bindings or FunctionLibraries source already proves spelling, signature, routing, parity, or behavior
- **THEN** the crosswalk attaches that evidence to normalized user scenarios
- **AND** an AS test is added only when executing the real project-script path provides additional signal
