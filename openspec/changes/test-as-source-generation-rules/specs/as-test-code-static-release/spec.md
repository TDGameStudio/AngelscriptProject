## ADDED Requirements

### Requirement: Generated static release API

The plugin SHALL expose generated AngelScript test source through `FAngelscriptTestCode`. The release API SHALL use generated value types capable of representing origin, CaseKey, axes, seed, source bundle, canonical manifest, typed oracle, comments, references, harness, negative mutation, recovery, and cells.

#### Scenario: Direct static function call

- **WHEN** C++ calls the generated static function for a reviewed fixture or product
- **THEN** it receives one complete `FAngelscriptGeneratedCase` without reading external rule/source files

### Requirement: One static function per fixture or product CaseKey

Release generation SHALL emit one named static function for each authored fixture or generated product/candidate CaseKey in `catalogs/static-function-registry.csv`. Expanded product cells SHALL be represented inside the returned product result and SHALL NOT require one C++ function per expanded cell.

#### Scenario: SDK product with many cells

- **WHEN** an SDK product has hundreds of explicit cells
- **THEN** the generated C++ API contains one product static function
- **AND** callers can enumerate the product's complete cell set from its returned value

#### Scenario: Duplicate symbol or CaseKey

- **WHEN** release generation detects a duplicate CaseKey, C++ symbol, or conflicting shard entry
- **THEN** it fails before writing partial release output

### Requirement: Generated sorted dispatch without registrars

The release mirror SHALL provide generated deterministic `TryGenerateByCaseKey`, `EnumerateCaseKeys`, and `EnumerateCells` behavior over an immutable sorted entry table. It SHALL NOT use static registrar constructors, mutable global registration maps, linker ForceLink functions, translation-unit load order, or runtime filesystem discovery.

#### Scenario: CaseKey lookup

- **WHEN** a caller looks up any registry CaseKey
- **THEN** dispatch returns the same complete value as its direct static function

#### Scenario: Enumeration order

- **WHEN** CaseKeys are enumerated in two builds produced from identical inputs
- **THEN** the order and values are identical and sorted by the canonical release rule

### Requirement: Plugin retains only final C++ release artifacts

The plugin SHALL contain only the generated C++ declaration/definitions, embedded immutable data, and release manifest required by `FAngelscriptTestCode`. Python packages, portable generator executables, rule JSON, generation-time TestSource `.as` files, bulk corpora, and run history SHALL remain outside the plugin.

#### Scenario: Release content audit

- **WHEN** the generated plugin release directory is audited
- **THEN** every file is an approved generated C++/manifest artifact
- **AND** no development-rule or generator-runtime dependency is present

### Requirement: Byte-identical and stale-safe release generation

Python and portable C++ release emitters SHALL independently produce byte-identical header, source shard, dispatch, and release-manifest bytes. Release generation SHALL use a complete output manifest to identify stale generated files and SHALL fail safely rather than leaving a mixed partial generation.

#### Scenario: Two independent release emitters

- **WHEN** Python and portable C++ emit a release from the same static-function registry and reviewed inputs
- **THEN** their complete output file sets, relative paths, and bytes match

#### Scenario: Removed registry entry

- **WHEN** an entry is deliberately removed from a reviewed future registry
- **THEN** explicit release mode identifies the now-stale generated artifact through the prior manifest
- **AND** ordinary in-memory generation does not delete or mutate files

### Requirement: Current tests remain authoritative

Adding generated static release functions SHALL NOT cause any current test, source builder, inline literal, or runner to consume them. Adoption requires a later explicit change with behavioral parity and rollback evidence.

#### Scenario: Additive release generation

- **WHEN** all static functions in this change have been generated
- **THEN** existing test source and execution paths remain unchanged
- **AND** the release API is available only to explicitly added future consumers
