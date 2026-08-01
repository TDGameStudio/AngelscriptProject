## ADDED Requirements

### Requirement: Deterministic offline bundle publication
The UE producer SHALL publish canonical UTF-8 `manifest.json`, `symbols.jsonl`, and `assets.jsonl` with deterministic key/record ordering, LF line endings, counts, and SHA-256 hashes.

#### Scenario: Environment is unchanged
- **WHEN** the same final environment and export options are exported twice
- **THEN** all three published files and bundle identity are byte-for-byte identical

#### Scenario: Export fails before completion
- **WHEN** traversal, serialization, hashing, manifest creation, or publication fails
- **THEN** no partially written directory is published as a valid bundle

### Requirement: Final initialized environment observation
The producer SHALL observe the final engine after settings, all registration paths, optional plugins, successful included script compilation, and required asset scanning.

#### Scenario: Callable uses any registration path
- **WHEN** a declaration originates from manual, UHT-generated, native-module, reflective, Blueprint/reflection, script, optional-plugin, or unknown registration
- **THEN** the final declaration is represented with the most specific proven provenance

#### Scenario: Optional plugin is absent
- **WHEN** an optional plugin is not loaded
- **THEN** its symbols are not implied and the loaded scope records its absence

### Requirement: Stable semantic identities
Contract symbol and module identities SHALL use versioned normalized semantic tuples and SHALL NOT depend on process-local AngelScript IDs, registration order, source contents, or machine-absolute paths.

#### Scenario: Runtime registration order changes
- **WHEN** runtime IDs change but owner, kind, namespace, and complete declaration do not
- **THEN** the stable symbol ID remains unchanged

#### Scenario: Script source content changes
- **WHEN** a module keeps its logical name and virtual source identity
- **THEN** its stable module ID remains unchanged while its separate content hash changes

#### Scenario: Declaration changes
- **WHEN** normalized semantic identity changes
- **THEN** the affected stable symbol ID and contract hashes change

### Requirement: Canonical replayable symbol records
Symbol records SHALL form a complete replayable snapshot of the declared symbol scope and contain compile-relevant type, member, callable, behavior, enum, typedef, funcdef, delegate, inheritance, interface, template, flag, layout, trait, availability, origin, adapter, and scope data without requiring binding source code.

#### Scenario: Consumer inspects a callable
- **WHEN** a callable record is read
- **THEN** owner, namespace, declaration, return, argument directions/defaults, qualifiers, behavior/access, availability, provenance, layer, and stable ID are known

#### Scenario: Consumer inspects a type
- **WHEN** a type record is read
- **THEN** kind, namespace, UE path, base/interfaces, template shape, flags, compile size/alignment, traits, members, origin, layer, availability, and adapter need are known

### Requirement: Host and script layers
Every symbol SHALL be classified `host-surface` or `script-baseline`, and every script baseline SHALL carry stable module identity and declaration relationships without source bodies or bytecode.

#### Scenario: Host registration is exported
- **WHEN** a declaration originates from application registration or reflection
- **THEN** it is marked host-surface

#### Scenario: Active script module is exported
- **WHEN** a script module is in the last successful active module set and included by scope
- **THEN** its declarations are marked script-baseline with stable module identity

#### Scenario: Script module is failed or outdated
- **WHEN** a module is not part of the successful active set
- **THEN** it is excluded from baseline records and listed in scope diagnostics

### Requirement: Complete compatibility manifest
The manifest SHALL record `bundleKind` (`default-engine` or `project`), producer project identity, schema, producer, UE/plugin/fork/compiler contract, platform/configuration policy, engine properties, feature flags, loaded module/plugin scope, mandatory symbol completeness, independent asset scope/completeness, adapters, counts, and hashes needed for compatibility decisions. `default-engine` SHALL identify packaged-default selection and SHALL NOT imply a minimal or engine-only producer surface.

#### Scenario: Required field is unsupported
- **WHEN** a consumer does not support a required schema, contract, property, feature, platform policy, or adapter
- **THEN** it can reject the bundle before replay or source compilation and identify the field

#### Scenario: Symbol and asset completeness differ
- **WHEN** every final symbol is exported but the declared Asset Registry scope is incomplete
- **THEN** the manifest records `symbolScope.complete: true` and `assetScope.complete: false` independently

#### Scenario: Packaged default contains host or optional-plugin symbols
- **WHEN** the `AngelscriptProject` release producer has normally enabled project or optional-plugin registrations
- **THEN** the manifest identifies their producer/module/plugin scope and consumers can distinguish that convenience snapshot from an exact export of their own project

### Requirement: Adapter handshake
Each non-declarative adapter requirement SHALL provide a stable ID, version, canonical registration-surface hash, and required traits, while declarative-only templates SHALL be marked explicitly.

#### Scenario: Registered container surface changes
- **WHEN** the exported method or behavior surface owned by an adapter changes
- **THEN** its surface hash changes

#### Scenario: No callback is required
- **WHEN** a template can be replayed declaratively
- **THEN** the record marks it declarative-only and does not invent an adapter

### Requirement: Typed asset index
Asset records SHALL describe normalized package/object/generated-class paths, type/base relationship, mount, origin, redirect, availability, minimal type-check tags, and export-scope truth.

#### Scenario: Blueprint asset is exported
- **WHEN** an asset has a generated Blueprint class
- **THEN** asset, generated-class, and known base relationships are represented

#### Scenario: Redirect exists
- **WHEN** a source path redirects
- **THEN** source and normalized final target are represented

#### Scenario: Plugin asset is exported
- **WHEN** an asset belongs to a plugin mount
- **THEN** the mount and plugin origin are recorded without treating it as `/Game`

### Requirement: Explicit scope and completeness
The bundle SHALL record its kind, loaded module/plugin scope, mandatory complete final symbol scope, asset roots/filters, skipped asset scope, and complete/incomplete Asset Registry state. Symbol filtering or failed final-engine traversal SHALL NOT publish a manifest-valid complete bundle.

#### Scenario: Default engine snapshot is produced
- **WHEN** release automation invokes the export Commandlet against the repository's checked-in `AngelscriptProject.uproject` and normal release configuration
- **THEN** it publishes a `default-engine` bundle containing that host's complete final symbol surface, including its project registrations, successful script baseline, and normally enabled optional-plugin registrations, with the exact loaded module/plugin and asset scope recorded in the manifest

#### Scenario: Project snapshot is produced
- **WHEN** a target project exports after final initialization
- **THEN** it publishes a `project` bundle containing that project's complete final symbol surface, including loaded optional plugins and project registrations

#### Scenario: Symbol export is incomplete
- **WHEN** final symbol enumeration fails, is filtered, or cannot prove complete scope
- **THEN** the commandlet fails and publishes no manifest-valid bundle

#### Scenario: Authoritative asset export is incomplete
- **WHEN** required Asset Registry state is incomplete and incomplete output was not explicitly allowed
- **THEN** the commandlet fails and publishes no valid bundle

#### Scenario: Incomplete output is explicitly allowed
- **WHEN** incomplete export is requested
- **THEN** the manifest marks it incomplete and exposes enough scope data to prevent authoritative missing claims

### Requirement: Contract integrity
The producer and fixture reader SHALL validate encoding, required files, record counts, hashes, schemas, stable IDs, and consistent duplicate identities.

#### Scenario: Data file is modified
- **WHEN** a JSONL file no longer matches manifest count or hash
- **THEN** integrity validation fails

#### Scenario: Stable ID is reused inconsistently
- **WHEN** records reuse an ID with different normalized identity or payload
- **THEN** validation fails with a contract-consistency error

### Requirement: Safe exported content
The bundle SHALL NOT contain native pointers, live object addresses, C++ source, script function bodies, source text, bytecode, executable code, asset payloads, or mutable editor state.

#### Scenario: Native address changes
- **WHEN** restart, ASLR, rebuild, or hot reload changes an implementation address without changing its declaration
- **THEN** the contract remains semantically identical because no address is serialized

#### Scenario: Asset is exported
- **WHEN** an asset enters the index
- **THEN** only path, type, registry, redirect, origin, availability, and scope metadata needed for offline analysis is serialized

### Requirement: Commandlet export entry
The `AngelscriptEditor` module SHALL provide an offline export Commandlet discoverable from any Unreal project that has the `Angelscript` plugin installed. It SHALL accept explicit output, `default-engine`/`project` bundle kind, asset-root/filter, and incomplete-asset options and use a default ignored destination under the invoking project's `Saved/AngelscriptStandalone/`. It SHALL depend only on plugin-owned runtime/editor APIs, SHALL always export the invoking process's complete final symbol surface, and SHALL NOT expose module/plugin symbol filters or require changes to binding providers.

#### Scenario: Commandlet succeeds
- **WHEN** prerequisites are complete and arguments are valid
- **THEN** it publishes one valid bundle and exits successfully

#### Scenario: Project-specific registrations exist
- **WHEN** the commandlet runs with project bundle kind after project and optional-plugin registration completes
- **THEN** those final registrations are included without requiring changes to their `Bind_*.cpp` providers

#### Scenario: Another Unreal project exports its contract
- **WHEN** a consuming project installs and enables the `Angelscript` plugin and invokes the Commandlet through that project's normal Unreal commandlet entry
- **THEN** the Commandlet publishes a `project` bundle from that project's final initialized registrations and declared asset scope without depending on `AngelscriptProject` host-module code or repository-only wrapper scripts

#### Scenario: Default bundle kind is requested
- **WHEN** the official release workflow invokes the Commandlet with `BundleKind=DefaultEngine` in `AngelscriptProject`
- **THEN** the same unfiltered final-engine traversal is used, the result is labeled for packaged-default selection, and project or optional-plugin registrations are not rejected merely because of their origin

#### Scenario: Commandlet fails
- **WHEN** options, prerequisites, traversal, integrity, or publication fails
- **THEN** it exits nonzero and leaves no manifest-valid partial destination

### Requirement: Versioned machine-readable schemas and canonical normalization
The producer and consumer SHALL share versioned machine-readable schemas for the manifest, symbol records, asset records, stable semantic identities, and canonical JSON/JSONL normalization rules.

#### Scenario: Producer and consumer use the same canonical fixture
- **WHEN** both sides normalize the same schema-valid fixture
- **THEN** field defaults, semantic tuples, ordering, UTF-8 encoding, line endings, stable IDs, record hashes, and bundle identity agree exactly

#### Scenario: Schema compatibility is unsupported
- **WHEN** a required schema version, canonicalization rule, or stable-ID tuple version is not supported
- **THEN** export or loading fails before publication, replay, or source compilation and identifies the incompatible contract component
