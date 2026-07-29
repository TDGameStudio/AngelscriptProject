## ADDED Requirements

### Requirement: Deterministic source case generation
The tool SHALL generate AngelScript source cases from an explicit profile, case kind, seed, count, expression-depth bound, and statement-count bound. Repeating the same invocation SHALL produce byte-identical source and catalog output.

#### Scenario: Repeat a native positive generation request
- **WHEN** the CLI is invoked twice with the same `native-core`, `valid`, count, seed, and bounds
- **THEN** both output directories contain identical case IDs, source bytes, metadata, and index SHA-256 values

### Requirement: Typed valid-program construction
The valid generator SHALL construct source through a typed internal program model that enforces variable visibility, type compatibility, lvalue requirements, control-flow legality, and declared profile context requirements before source lifting.

#### Scenario: Generate a bounded native expression program
- **WHEN** a valid native-core case requests expressions within configured depth and statement bounds
- **THEN** the model contains no unresolved variable, incompatible return, invalid loop transfer, or expression exceeding those bounds

### Requirement: Isolated invalid-program construction
The invalid generator SHALL begin from a valid baseline and apply exactly one named invalid rule with one declared expected failure category.

#### Scenario: Generate a type mismatch negative case
- **WHEN** a native-core invalid request selects `type-mismatch`
- **THEN** its metadata declares `compile-fail` and `type-mismatch`, while no second invalid rule is recorded for the case

### Requirement: Reviewed profile layering
The tool SHALL load inherited JSON profiles for native core, UE values, UE annotations, and UE World/Actor source shapes. A profile SHALL only expose declared capabilities and SHALL report an error for unresolved parent, type, callable, or fragment references.

#### Scenario: Load the UE World profile
- **WHEN** the loader resolves `ue-world`
- **THEN** it includes inherited native/UE capabilities, records a World harness requirement, and exposes only its explicitly declared world fragments

### Requirement: Source and catalog output
The tool SHALL write source under an explicit output directory or the default `Saved/AngelscriptCodeGen/` directory. Every source SHALL contain leading machine-readable case metadata, and the directory SHALL include an `index.json` mapping each case to metadata and source SHA-256.

#### Scenario: Emit a generated UE annotation case
- **WHEN** the CLI emits an `ue-annotated` case
- **THEN** the `.as` file includes case ID, profile, seed, expected outcome, and harness metadata, and the same values appear in `index.json`
