## ADDED Requirements

### Requirement: Evidence-based binding-surface classification

The binding-surface audit SHALL maintain a traceable classification for every reference member or coherent API group it reviews. The record MUST identify the reference, native type family, AngelScript-facing form where available, disposition, supporting evidence, and rationale.

#### Scenario: A differently shaped equivalent exists

- **WHEN** a reference static helper is available to AngelScript as an instance method, operator, global helper, `FMath` helper, reflected member, or generic/template operation with equivalent semantics
- **THEN** the audit SHALL classify it as `AvailableEquivalent` or `ReflectionOrTemplate` rather than as a missing explicit binding

#### Scenario: A candidate has no verified equivalent

- **WHEN** an audit finds no AngelScript form with equivalent behavior after the required normalization checks
- **THEN** the audit SHALL classify it as `MissingCandidate`, `BlockedByDependency`, or `IntentionalNonGoal` and SHALL record the supporting rationale

### Requirement: Reference inventories are discovery inputs, not parity mandates

UnrealCSharp or another language plugin MAY provide discovery evidence, but the binding-surface work SHALL NOT add an AngelScript API solely to match a reference count, file, or member name. Each approved addition MUST have an AngelScript use-case and a compatible Unreal Engine semantic shape.

#### Scenario: A reference member is redundant or inappropriate

- **WHEN** a reviewed reference member is redundant, unsafe, unsuitable for the plugin's module boundaries, or not valuable to AngelScript users
- **THEN** the audit SHALL record it as `IntentionalNonGoal` with a rationale and SHALL NOT treat its absence as unfinished parity work

### Requirement: Existing binding lifecycle ownership is preserved

New ordinary hand-authored binding APIs selected by this change SHALL use the existing explicit binding lifecycle and SHALL NOT introduce a new bind phase or alter generated, reflective, or template binding ownership solely for surface parity.

#### Scenario: An approved explicit API is implemented

- **WHEN** an audited candidate is approved as a new ordinary manual binding
- **THEN** its provider SHALL participate in the existing `EAngelscriptBindPhase::ExplicitBindings` lifecycle or retain the established type-specific phase ownership, without changing unrelated registration paths

### Requirement: New hand-authored APIs have behavioral script coverage

Every newly added hand-authored script API selected from the audit SHALL have focused automated coverage that compiles and invokes the public AngelScript form and verifies an observable result, state change, or error behavior. A source-layout assertion alone SHALL NOT satisfy this requirement.

#### Scenario: A selected API is exposed to scripts

- **WHEN** a wave adds a new explicit AngelScript method, constructor, property, or helper
- **THEN** the wave SHALL add or update a focused binding test that exercises that API from AngelScript and verifies its intended behavior

### Requirement: Incremental waves keep documentation and verification evidence current

Each completed implementation wave SHALL update its audit evidence and provider-adjacent script API documentation where the public surface changed. The wave SHALL run focused validation appropriate to its changed family before it is recorded as complete.

#### Scenario: A type-family wave is completed

- **WHEN** the selected family has completed implementation and focused validation
- **THEN** the audit record SHALL capture the resulting disposition and validation evidence, and the owning bind provider SHALL document any added public API and non-obvious parameters in its file-header API table

### Requirement: Approved value-type wave uses current engine representations

The approved high- and medium-priority wave SHALL provide focused
AngelScript-facing value bindings for `FPrimaryAssetType`, `FPrimaryAssetId`,
`FAssetBundleEntry`, `FAssetBundleData`, `FBox2D`, `FFrameNumber`,
`FFrameTime`, and the engine-default `FMatrix` alias. The wave SHALL bind
current engine representations rather than mechanically reproduce historical
reference signatures.

#### Scenario: A script assembles an asset-bundle description

- **WHEN** a script creates an `FAssetBundleData` and adds or replaces bundle asset paths
- **THEN** the paths SHALL use the current `FTopLevelAssetPath` representation and the script SHALL be able to observe the resulting bundle data through a safe value/query API

#### Scenario: A script uses a matrix value

- **WHEN** a script declares `FMatrix` and uses its approved transform-oriented operations
- **THEN** the operations SHALL use the engine-default matrix representation without requiring the script to choose a float or double matrix type

### Requirement: Value-owned native references do not escape into AngelScript

An approved value-type binding SHALL NOT expose a native pointer or reference
whose lifetime is owned by another script value as an independently retained
AngelScript object/reference. Such APIs SHALL use a copied result, an index,
or an explicit boolean-plus-`out` query form.

#### Scenario: A script searches asset-bundle data

- **WHEN** a script queries `FAssetBundleData` for a named bundle entry
- **THEN** the query SHALL return a result that remains valid without retaining a pointer or reference into the source `FAssetBundleData`
