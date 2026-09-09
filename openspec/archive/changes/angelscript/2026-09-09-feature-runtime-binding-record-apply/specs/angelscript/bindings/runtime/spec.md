## Purpose

Provide the complete UE-facing Runtime binding surface as reusable descriptions that can be installed into explicitly owned reconstructed AngelScript engines.

## ADDED Requirements

### Requirement: Runtime bindings can be recorded without a script engine

The system SHALL record eligible Runtime providers without creating or querying a script engine, and SHALL expose a sealed immutable snapshot suitable for repeated application.

#### Scenario: Record and seal native type declarations
- **WHEN** a host records a value type with properties, constructors and native methods and seals the store
- **THEN** the snapshot retains its declarations, native targets, UE recipes and provider provenance without engine-bound type or function objects
- **AND** attempted mutation after sealing is rejected without changing the snapshot

#### Scenario: Reuse a recorded snapshot
- **WHEN** the same sealed snapshot is applied to two separately owned engines
- **THEN** the providers are not invoked again and each engine obtains independently owned mutable binding state

### Requirement: Application preserves type dependencies and callable behavior

The system SHALL install complete type definitions and native call bindings in deterministic serial dependency order, preserving the eligible Runtime surface and UE type semantics.

#### Scenario: Resolve dependencies declared in a different order
- **GIVEN** a derived type, its base and member types appear in a different provider order from their dependencies
- **WHEN** the snapshot is applied
- **THEN** the resulting types expose the correct inheritance, layouts, properties and methods
- **BUT** an unresolved required type or inheritance/by-value layout cycle produces a provenance-bearing failure

#### Scenario: Call native members through the current VM
- **WHEN** a context invokes an installed constructor, method or global function
- **THEN** argument direction, const/reference/handle qualifiers, native caller selection, return values and object lifetimes follow the recorded binding contract
  > Observables: Value returns, reference returns, out/inout writes and destructor effects are visible to the host.

#### Scenario: Materialize template instances
- **WHEN** an engine requests a supported container instance, including a nested instance
- **THEN** it obtains the correctly typed layout and element operations, reusing the same instance identity on repeated requests within that engine
- **BUT** unsupported element operations fail explicitly without modifying previously installed definitions

### Requirement: Every eligible Runtime provider is accounted for

The system SHALL account for every current Runtime provider as installed under its active target conditions or explicitly excluded by those conditions, preserving existing manual, generated and reflection precedence.

#### Scenario: Install a full loaded Runtime snapshot
- **WHEN** a host requests the full Runtime surface for the selected build and currently loaded UE types
- **THEN** all eligible declarations and finalization effects are installed, with no silent unsupported-provider fallback
- **AND** UE structs, classes, enums, interfaces, containers, delegates, mixins and native/reflected callers preserve their applicable binding contracts
- **BUT** modules or reflected types loaded after snapshot capture require a new snapshot and engine

#### Scenario: Exclude target-specific declarations
- **WHEN** an editor-only or development-only declaration is evaluated for an ineligible target
- **THEN** coverage identifies its condition-based exclusion and the declaration is absent from the installed surface

### Requirement: Hosts can inspect the intended AS surface before installation

The system SHALL export versioned diagnostic JSON and readable tables of sealed bindings without creating an engine, distinguishing intended AS declarations from reflection-only facts and excluded candidates.

#### Scenario: Dump sealed binding declarations
- **GIVEN** a sealed snapshot with types, inheritance, members, namespace globals, recipes and reflection
- **WHEN** the host requests its binding dump
- **THEN** output exposes intended declarations, relationships, layout, modifiers, target categories and provenance
  > Details: Captured-only UE identities and excluded candidates appear separately. Recorded declarations are not labeled installed or executable.
- **AND** equivalent captured inputs produce identical semantic output independent of process addresses, timestamps and unordered map traversal
- **BUT** export does not execute providers or targets, dereference borrowed payloads, or restore an executable snapshot from disk

#### Scenario: Validate and compare dumps offline
- **WHEN** the host validates or compares manifests with the provided Python tools
- **THEN** invalid schema, duplicate identities, missing required references, illegal layout/inheritance and missing expected symbols produce structured symbol/source diagnostics and nonzero exit codes
  > Details: Builtins, template parameters and declared external dependencies have explicit reference categories; handle cycles remain legal.
- **AND** comparison identifies added, removed and changed types, members and globals while ignoring cosmetic ordering
- **BUT** incompatible schema versions cannot silently pass

### Requirement: Snapshot inspection preserves ownership and complete accounting

The system SHALL distinguish copied records/constants, borrowed host targets, retained reflection and engine-owned state. Full coverage SHALL reconcile source inventory, registered providers, recorded declarations/effects and installed results.

#### Scenario: Seal namespace globals and retain snapshot lifetime
- **GIVEN** root and named scopes contain functions, constants and borrowed global properties
- **WHEN** a sealed snapshot is reused by separately owned engines
- **THEN** namespace identities, overload declarations, copied values and provenance remain immutable while mutable engine state is independently owned
- **AND** borrowed global storage remains host-owned and intentionally shared where bound as a process-global property
  > Boundaries: Seal freezes records, not pointees. Callback code and borrowed payloads must outlive consumers. Captured reflection identities remain retained until the final snapshot consumer releases them.
- **BUT** mismatched effective reflection policy fails before publishing mixed records or attachment

#### Scenario: Reconcile all eligible providers and expected members
- **WHEN** the complete Runtime surface is checked against independent inventory expectations
- **THEN** each source provider maps to recorded/installed declarations or explicit effects, or an evidenced compile-time/policy exclusion
  > Details: Intentional no-output, compiled-out, policy-excluded and unsupported/unaccounted entries remain distinct.
- **BUT** an unexplained eligible entry or missing expected member fails even when aggregate counts match

### Requirement: Sealed snapshots receive engine-free pre-installation validation

The system SHALL validate sealed binding records before engine creation and SHALL distinguish write closure from structural and installation readiness. Validation SHALL be read-only, deterministic and provenance-bearing.

#### Scenario: Reject a sealed but invalid binding surface
- **GIVEN** a sealed snapshot contains an unresolved required type, illegal inheritance/layout, incompatible duplicate member, inconsistent policy/provenance or a missing required native target
- **WHEN** the host validates it for installation
- **THEN** validation fails with stage, symbol and provider/source diagnostics without creating an engine
- **AND** the store remains unchanged and may be inspected with its failed validation report
- **BUT** successful sealing alone cannot be reported as successful installation validation

#### Scenario: Revalidate without changing a sealed snapshot
- **WHEN** the same sealed snapshot is validated repeatedly before and after rejected mutation attempts
- **THEN** its semantic contents and validation result remain unchanged
- **AND** a valid snapshot reused by two engines passes the same pre-installation checks without re-executing providers
  > Boundaries: Validation proves recorded structure and required descriptor presence. Runtime ABI, invocation and lifecycle effects still require their execution tests.
