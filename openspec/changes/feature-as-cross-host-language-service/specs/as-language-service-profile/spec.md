## ADDED Requirements

### Requirement: A compact profile is derived from explicit authoritative inputs
The `.aslp` packer SHALL require one explicitly selected, complete, valid UE offline bundle, one reviewed root-symbol allowlist, the adapter set, rule-set identity, and the packer version. It SHALL resolve stable-ID dependency closure and SHALL NOT infer inputs from caches, arbitrary directories, running UE state, or network sources.

#### Scenario: Valid Wiki profile is packed
- **WHEN** the complete bundle, allowlist, adapters, and tool versions are valid
- **THEN** the packer SHALL emit exactly the declarations and relationships required by the reviewed roots and their validated dependency closure
- **AND** it SHALL record all input identities in the manifest

#### Scenario: Explicit bundle is invalid
- **WHEN** the selected bundle fails schema, integrity, completeness, or relationship validation
- **THEN** packing SHALL fail before publication
- **AND** the packer SHALL not search for or fall back to another bundle

### Requirement: Profile publication is deterministic and atomic
Identical normalized inputs SHALL produce byte-identical `.aslp` payloads and manifests with canonical ordering. Publication SHALL be atomic and SHALL never expose a partially written profile as valid.

#### Scenario: Inputs are unchanged
- **WHEN** the same bundle, allowlist, adapters, rule set, and packer version are packed twice
- **THEN** payload bytes, manifest bytes, record counts, and SHA-256 hashes SHALL match exactly

#### Scenario: Packing fails during publication
- **WHEN** closure, serialization, hashing, manifest creation, or final publication fails
- **THEN** no valid destination profile SHALL contain a mixture of old and new files

### Requirement: The manifest proves profile compatibility
The manifest SHALL include pack schema version, source offline schema version, producer product version and revision, source bundle identity, allowlist hash, rule-set version/hash, adapter-set hash, deterministic record counts, completeness, and hashes for every payload.

#### Scenario: Consumer loads a compatible profile
- **WHEN** every schema, identity, count, dependency, adapter, rule-set, and file hash is supported
- **THEN** the consumer MAY initialize the profile index

#### Scenario: Rule or adapter identity differs
- **WHEN** the profile rule-set or adapter-set identity is incompatible with the consumer
- **THEN** loading SHALL fail before any document is opened
- **AND** the error SHALL identify the incompatible field

#### Scenario: Payload is corrupted
- **WHEN** a payload hash or record count does not match the manifest
- **THEN** loading SHALL fail as an infrastructure error without partial symbol availability

### Requirement: Wiki profiles are explicitly partial
The Wiki sandbox profile SHALL declare `completeness: partial` and SHALL identify its reviewed root allowlist. Consumers SHALL preserve that status in analysis, completion, diagnostics, and UI rather than presenting the profile as a complete engine or project environment.

#### Scenario: Symbol is outside the selected closure
- **WHEN** a document references a declaration not present in the partial profile
- **THEN** the consumer SHALL distinguish unavailable profile knowledge from an authoritative complete-environment absence
- **AND** absence-dependent static rules SHALL not turn unknown into a definitive missing result

#### Scenario: Widget initializes the Wiki profile
- **WHEN** the embedded profile loads successfully
- **THEN** the widget SHALL visibly identify it as a Wiki Sandbox partial UE API profile

### Requirement: Profiles contain declarations, not executable or private state
An `.aslp` profile MAY contain compact strings, declaration signatures, stable semantic IDs, type/member relationships, documentation summaries, explicit diagnostic flags, adapter identities, and completeness facts. It MUST NOT contain source text, code bodies, executable bytecode, native addresses, UObject layouts, property offsets, asset payloads, arbitrary metadata maps, credentials, or absolute/private machine paths.

#### Scenario: Security scan inspects a profile
- **WHEN** the release profile is scanned structurally and as raw bytes
- **THEN** only allowlisted record kinds SHALL be present
- **AND** forbidden code, address, path, and private-data patterns SHALL be absent

#### Scenario: Producer receives unrelated metadata
- **WHEN** a bundle declaration carries metadata not selected by the profile schema
- **THEN** the packer SHALL omit it rather than copying an arbitrary metadata map

### Requirement: Dependency closure is complete within the selected profile
Every retained declaration SHALL have all schema-required referenced strings, types, owners, bases, signatures, semantic flags, and adapter records present in the same profile or explicitly classified as external/unknown by the schema.

#### Scenario: Retained method references a parameter type
- **WHEN** a method is included by the allowlist closure
- **THEN** its parameter and return type records and required owners SHALL also be included or explicitly classified

#### Scenario: Required dependency is missing
- **WHEN** a required relationship cannot be resolved from the complete source bundle
- **THEN** packing SHALL fail rather than emit a dangling reference

### Requirement: Normal Wiki builds consume pinned profile assets only
The Wiki repository SHALL store the selected profile payload and manifest as audited product assets. Normal dev, test, verify, and build commands SHALL validate the committed assets but SHALL NOT run UE, invoke the packer, access the parent plugin checkout, or fetch replacement assets.

#### Scenario: Offline Wiki builds in isolation
- **WHEN** `Wiki` is built with its committed dependencies and no UE process or network
- **THEN** the embedded profile assets SHALL validate and package successfully

#### Scenario: Plugin release produces a new profile
- **WHEN** producer revision, rule set, allowlist, or payload changes
- **THEN** Wiki integration SHALL require an explicit reviewed asset and provenance update
- **AND** stale manifest hashes SHALL fail release validation

### Requirement: Profile size and content growth are reviewed
The profile builder SHALL report deterministic payload bytes and record counts by category. The selected Wiki profile SHALL remain within the Workbench payload budget, and adding new root symbols SHALL require an allowlist and benchmark update.

#### Scenario: New API root expands the profile
- **WHEN** an author adds a root declaration needed by an interactive example
- **THEN** the profile report SHALL identify the added transitive records and bytes
- **AND** release SHALL fail if the configured payload budget is exceeded
