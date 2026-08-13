## ADDED Requirements

### Requirement: The plugin has a dedicated Editor-only generated-code test module

The plugin SHALL define `AngelscriptTestJIT` as an Editor/PostDefault module that depends on `AngelscriptRuntime` and is loaded before `AngelscriptTest`. `AngelscriptTest` SHALL privately depend on `AngelscriptTestJIT`; the reverse dependency MUST NOT exist. `AngelscriptTestJIT` SHALL be a fixed plugin-test target, not a project-derived or project-owned module.

#### Scenario: Test target builds generated JIT code

- **WHEN** the Editor target builds the Angelscript plugin tests
- **THEN** generated test-provider per-AS-module `.jit.cpp` sources compile inside `AngelscriptTestJIT`
- **AND** Automation/CQTest definitions remain owned by `AngelscriptTest`

#### Scenario: Game or Shipping target is built

- **WHEN** a non-Editor target evaluates the plugin modules
- **THEN** `AngelscriptTestJIT` and its fixture code are excluded

#### Scenario: Test-generated code needs a Native probe

- **WHEN** a generated fixture references a test-specific Native surface
- **THEN** the probe is owned/exported by `AngelscriptTestJIT` or replaced with a Runtime surface
- **AND** `AngelscriptTestJIT` never depends on `AngelscriptTest`

#### Scenario: Test JIT generation is requested

- **WHEN** the plugin test workflow runs `-run=AngelscriptTestJIT -Mode=Generate|Verify`
- **THEN** it consumes only committed plugin-test fixtures and an explicit test generation profile
- **AND** it writes or verifies only `AngelscriptTestJIT/Generated`
- **AND** it does not derive a project module name, read the host project `Script/` root, inspect project JIT settings, modify `.uproject`, or emit into project `Source/`

#### Scenario: Project Scaffold is requested

- **WHEN** `-run=AngelscriptJIT -Mode=Scaffold` runs for a project
- **THEN** it does not create, rename, modify, or use `AngelscriptTestJIT`
- **AND** the committed test ProviderId and test generated output remain unchanged

### Requirement: Scaffold creates the fixed project-owned AngelscriptJIT module

The `AngelscriptEditor` module SHALL provide `-run=AngelscriptJIT -Mode=Scaffold`, create the fixed module `AngelscriptJIT` under project `Source/AngelscriptJIT`, and add a Runtime/PreDefault module descriptor to `.uproject` with a private dependency on `AngelscriptRuntime`. `PreDefault` is required so monolithic Shipping targets register the Provider before the Runtime's first authoritative Engine compile; same-phase link/load order MUST NOT be treated as a lifecycle guarantee. It SHALL NOT prefix or suffix the project name. Project tooling SHALL NOT depend on `AngelscriptTest` or `AngelscriptTestJIT`.

#### Scenario: Current host project is scaffolded

- **WHEN** Scaffold runs for `AngelscriptProject.uproject`
- **THEN** it creates `Source/AngelscriptJIT` with UE module name `AngelscriptJIT`
- **AND** the `.uproject` descriptor makes it eligible for Editor and Game targets

#### Scenario: Project Provider identity is generated

- **WHEN** Scaffold or Generate builds the Provider descriptor for `AngelscriptJIT`
- **THEN** ProviderId is derived from the canonical project/source ownership domain rather than the fixed UE module name alone
- **AND** different projects may use the same module name without sharing Provider identity

#### Scenario: Reserved module name already conflicts

- **WHEN** the project already declares an incompatible or user-owned UE module named `AngelscriptJIT`
- **THEN** Scaffold reports the exact descriptor/path conflict
- **AND** it does not derive a longer alternate name or overwrite the existing module

#### Scenario: Runtime discovers the project provider

- **WHEN** the generated module loads
- **THEN** it registers `IAngelscriptJITArtifactProvider` through modular features
- **AND** `AngelscriptRuntime` has no compile-time dependency on the project module

### Requirement: Generated-code carrier modules do not use a Private wrapper

The project `AngelscriptJIT` carrier and fixed plugin `AngelscriptTestJIT` carrier SHALL place their module implementation sources directly at their respective UE module roots and SHALL place generated selectors, manifests, inventories, and per-AS-module sources beneath a root-level `Generated` directory. Neither carrier SHALL use `Private` as part of its current source layout. `AngelscriptTestJIT` SHALL also place its exported probe declaration directly at the module root and SHALL NOT retain a `Public` wrapper. `AngelscriptTest` SHALL consume that header through a private include path and private module dependency; the declaration SHALL retain `ANGELSCRIPTTESTJIT_API` for cross-DLL symbol import/export.

#### Scenario: Project scaffold is current

- **WHEN** Scaffold validates or creates `Source/AngelscriptJIT`
- **THEN** `AngelscriptJITModule.cpp` exists directly beneath the module root
- **AND** provider selectors and generated profiles exist beneath `Source/AngelscriptJIT/Generated`
- **AND** no owned current file is emitted beneath `Source/AngelscriptJIT/Private`

#### Scenario: Fixed TestJIT carrier is current

- **WHEN** the plugin test target is inspected or generated
- **THEN** `AngelscriptTestJITModule.cpp` and `AngelscriptTestJITProbes.cpp` exist directly beneath the module root
- **AND** `AngelscriptTestJITProbes.h` exists directly beneath the module root and no `Public` directory is required
- **AND** test-provider generated output exists beneath `AngelscriptTestJIT/Generated`
- **AND** no current TestJIT source is emitted beneath `AngelscriptTestJIT/Private`

#### Scenario: A legacy Private root is migrated

- **WHEN** Scaffold or Generate encounters an owned `Private` layout
- **THEN** Verify reports it without mutation
- **AND** the writing operation validates the relevant scaffold marker or revision-2 generated inventory before retiring owned files
- **AND** it removes only empty legacy directories non-recursively
- **AND** an unowned or modified file is preserved and blocks unsafe retirement
- **AND** the result requires a normal build because UBT source paths changed

### Requirement: Generated targets use strict per-AS-module translation units

The committed `AngelscriptTestJIT` target and every independently generated project provider SHALL emit exactly one owned source-relative `<SourceStem>.<ShortStableModuleKey>.<TargetProfile>.jit.cpp` implementation translation unit for each non-empty AngelScript module in each selected target profile. `/Angelscript/Game` SHALL map directly beneath the profile root, plugin modules SHALL map beneath `Plugin/<Name>`, and memory modules SHALL map beneath `Memory/<Provider>`. The short key SHALL begin with eight hexadecimal characters and extend deterministically in four-character steps when any case-insensitive physical basename collides across the generated source set. The target-profile suffix SHALL distinguish otherwise identical basenames across profile directories because UBT may flatten source basenames for intermediate object naming. Every generated function owned by that StableModuleKey SHALL be defined in that file, functions from another StableModuleKey MUST NOT be defined in it, and a module MUST NOT be split across bucket, function-slice, or other implementation files. Test and project providers SHALL use the same deterministic per-module emission contract without sharing source inputs, ProviderIds, manifests, files, or output roots.

Manifest schema SHALL be revision 3 while the ownership marker/inventory remains revision 2 and Provider ABI remains revision 2. Verify MUST report `Private/Generated/<Profile>` and `Private/Generated/Profiles/<Profile>` as stale without mutation. Generate MAY migrate them only after validating the revision-2 inventory, profile, ProviderId, and ownership marker of every existing listed file; it SHALL delete only inventory-listed paths and empty legacy wrappers. Invalid or user-replaced legacy output SHALL block migration and remain untouched. Runtime/tooling MUST NOT retain a mode that emits or accepts either legacy path as current.

#### Scenario: Module is generated twice

- **WHEN** identical module/function identities, implementations, references, profile, and ABI inputs are generated in separate runs
- **THEN** the module `.jit.cpp` path, sorted function definitions, content-addressed symbols, reference-slot ordering, provider entry ordering, JSON metadata, and bytes are identical
- **AND** no per-function implementation file or fixed bucket file is emitted

#### Scenario: Several functions share one AS module

- **WHEN** one current AS module owns several generated functions
- **THEN** every function implementation is emitted into that module's one `.jit.cpp`
- **AND** the owned-file inventory contains exactly one implementation source for that StableModuleKey and profile

#### Scenario: Providers contain several AS modules

- **WHEN** one Provider owns functions from several StableModuleKeys
- **THEN** every StableModuleKey receives its own `.jit.cpp`
- **AND** no generated `.jit.cpp` contains functions from two AS modules

### Requirement: Module paths are stable while function symbols remain content-addressed

Generated module source paths SHALL derive from the virtual source domain, sanitized source stem, deterministic StableModuleKey prefix, and target profile, while the complete StableModuleKey SHALL remain in module metadata and each generated implementation symbol SHALL continue to use the complete StableFunctionKey and Execution hash. Every module file SHALL begin with the revision-2 ownership marker followed by deterministic module metadata. Every function SHALL record canonical declaration, virtual source line/column, complete stable/content/ABI hashes, and immediate Raw/VM/Parms entry comments. Adding, changing, deleting, or renaming a function within an existing stable AS module SHALL rewrite only that module's implementation source plus applicable provider metadata; it SHALL NOT create one file per function.

#### Scenario: Function body changes

- **WHEN** a stable function receives new executable content and its StableModuleKey is unchanged
- **THEN** Generate replaces the content of the same module `.jit.cpp` path with the new content-addressed symbol
- **AND** unrelated module `.jit.cpp` files remain byte-identical with unchanged timestamps
- **AND** the old symbol is absent from current provider entries

#### Scenario: Function is added, deleted, or renamed inside an existing module

- **WHEN** Generate runs after the current successful AS compilation changes the module's function set
- **THEN** the same module `.jit.cpp` is regenerated with exactly the current sorted function set
- **AND** no per-function source is added or retained

#### Scenario: AS module is added or removed

- **WHEN** a successful current compilation adds or removes a StableModuleKey
- **THEN** Generate adds or removes exactly that profile's corresponding `.jit.cpp` through the owned-file inventory
- **AND** current provider metadata contains only current modules and entries
- **AND** tooling reports that the changed UBT source-file set requires a normal full build before Live Coding refresh

### Requirement: Project generation supports explicit target profiles

The generated project module SHALL support `EditorDevelopment`, `GameDevelopment`, and `GameShipping` profile shards. Generate/Verify SHALL accept one of those profiles or `All`; an isolated generation Engine SHALL use explicit script preprocessor, cooked-binding, artifact-profile, and target inputs rather than inheriting incompatible Editor process assumptions.

#### Scenario: Editor profile is generated

- **WHEN** Generate selects `EditorDevelopment`
- **THEN** it includes the Editor script/binding surface and emits the matching artifact profile/environment
- **AND** only the Editor profile's guarded per-module sources contribute definitions to the Editor target

#### Scenario: Shipping profile is generated from the tool host

- **WHEN** Generate selects `GameShipping`
- **THEN** the isolated Engine uses Shipping-equivalent `EDITOR`, `EDITORONLY_DATA`, `RELEASE`, `TEST`, cooked-binding, and artifact inputs
- **AND** the resulting provider cannot claim the Editor environment fingerprint

#### Scenario: Package profile is missing or stale

- **WHEN** package verification selects a profile without current generated artifacts
- **THEN** Verify fails before packaging acceptance with the missing/stale profile and affected identities

### Requirement: Scaffold is idempotent and protects user files

Scaffold MUST mark owned files with a scaffold revision, write missing or byte-different owned files atomically, preserve byte-identical files, and MUST NOT overwrite arbitrary user source or duplicate an existing module name.

#### Scenario: Scaffold runs twice unchanged

- **WHEN** a valid scaffold is processed twice
- **THEN** the second run reports no changes
- **AND** it does not alter bytes or timestamps of unchanged owned files

#### Scenario: User file conflicts with an owned path

- **WHEN** a target path exists without the expected ownership/revision marker
- **THEN** Scaffold stops with that path
- **AND** it does not overwrite, delete, or partially update project state

#### Scenario: Project descriptor already has conflicting module metadata

- **WHEN** `.uproject` contains the derived name with incompatible type/loading phase
- **THEN** Scaffold reports the structured conflict
- **AND** it does not append a duplicate descriptor

### Requirement: First project-module use requires a complete target build

Scaffold SHALL report that a complete Editor/Game build is required before the module can participate in Live Coding. Verify SHALL validate the module descriptor, Build.cs Runtime dependency, per-profile per-AS-module layout, compile guards, owned-file inventory, and target discovery prerequisites. Generate/Refresh SHALL distinguish content changes within an already discovered module source from a source-set change that adds or removes a `.jit.cpp`.

#### Scenario: Module has not entered the active Editor target

- **WHEN** Generate/Refresh is requested before the scaffolded module is loaded in the Live Coding session
- **THEN** the tool refuses patch refresh and prints the required full-build instruction
- **AND** current functions remain VM-executable

#### Scenario: Existing AS module changes without changing the source set

- **WHEN** Generate changes functions inside an AS module whose profile `.jit.cpp` already belongs to the active target
- **THEN** Refresh may request Live Coding for the existing generated UE module
- **AND** it validates the expected newer ProviderGeneration before publishing routes

#### Scenario: AS module source set changes

- **WHEN** Generate adds or removes a profile `.jit.cpp`
- **THEN** Generate writes the authoritative owned output but Refresh refuses to claim that Live Coding can discover or remove the translation unit
- **AND** it reports the added/removed StableModuleKeys and exact normal-build requirement
- **AND** current script execution remains VM-correct until a compatible provider generation is loaded

### Requirement: Test and project generation share only deterministic emission primitives

The Runtime generation library SHALL provide common stable-identity, reference capture, per-AS-module function grouping/emission, provider-manifest, owned-file inventory, and deterministic comparison primitives. `AngelscriptEditor` project tooling and `AngelscriptTest` test tooling SHALL supply separate source discovery, target descriptors, ProviderIds, commands, profiles, ownership roots, and outputs. Neither orchestration path SHALL call through or depend on the other.

#### Scenario: Project generated artifacts are current

- **WHEN** project `-run=AngelscriptJIT -Mode=Verify` runs with unchanged scripts, target profile, generator, scaffold, references, and environment
- **THEN** it reports all expected per-AS-module `.jit.cpp` files, provider manifest, owned-file inventory, and JSON metadata current
- **AND** source remains unmodified

#### Scenario: One module source or reference is stale

- **WHEN** current identity/content/reference slots differ from generated output
- **THEN** Verify identifies provider, profile, StableModuleKey, module source path, affected StableFunctionKeys, symbols, and expected content/profile/ABI values
- **AND** it reports every missing, unexpected, ownership-conflicting, or content-mismatched owned file
- **AND** it returns failure

#### Scenario: Test Provider is regenerated independently

- **WHEN** `AngelscriptTest` runs `-run=AngelscriptTestJIT -Mode=Generate`
- **THEN** it writes owned output beneath `AngelscriptTestJIT/Generated`
- **AND** the next normal Editor build compiles the generated per-AS-module `.jit.cpp` files
- **AND** no project module, project descriptor, project source root, or project ProviderId is read or changed
