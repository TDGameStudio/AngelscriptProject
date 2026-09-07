## ADDED Requirements

### Requirement: Native definitions preserve explicit member addressing

The SDK SHALL define native fields using explicit validated storage and addressing facts and SHALL preserve those facts through freeze, fingerprinting and Engine registration.

#### Scenario: Define a padded native object

- **GIVEN** a C++ object with declared size, alignment and member offsets
- **WHEN** its native definition is frozen and registered
- **THEN** member queries and runtime access use the declared C++ storage rather than recomputed AS sequential offsets

  > Padding is observable: writing one declared member changes only that member, leaving surrounding sentinel bytes intact.

- **AND** direct, inline-composite and indirect-composite addressing remain distinguishable in layout compatibility
- **BUT** a null indirect composite cannot be dereferenced and produces a runtime exception

#### Scenario: Reject an invalid native address without mutation

- **WHEN** a definition request supplies invalid native member storage

  - Foreign owner, duplicate member or frozen mutation.
  - Overflow, out-of-bounds extent, unsupported alignment/packing or overlapping direct members.
  - Incomplete or incompatible composite storage contracts.

- **THEN** the request returns a specific failure and leaves member count, layout and prior fields unchanged

### Requirement: Executable bodies remain separate from immutable callable declarations

The SDK SHALL allow frozen callable declarations to acquire Engine-local executable bindings without modifying their semantic metadata, stable identity or single-Engine ownership.

#### Scenario: Bind a declared method body

- **GIVEN** a frozen class with a declared method and complete return/parameter contract
- **WHEN** its owning Engine installs a compatible executable body
- **THEN** the original method and owner pointers remain unchanged and the executable binding is owned separately
- **BUT** an undeclared method, incompatible signature or already installed body is rejected without modifying the frozen class

#### Scenario: Use equivalent definitions in separate Engines

- **WHEN** two Engines register separately constructed equivalent definition images
- **THEN** their keys and compatible fingerprints agree while their object pointers and runtime IDs are independently owned
- **BUT** one attached or retired image cannot be shared or reattached to obtain cross-Engine execution

## MODIFIED Requirements

### Requirement: Transactional single-engine definition binding

The system SHALL register a complete frozen image without copying its metadata objects or exposing a partial registration.

#### Scenario: Retire an attached image

- **WHEN** the owning Engine retires or is destroyed
- **THEN** it stops new executable admissions and completes active runtime cleanup before removing binding visibility and Engine-owned resources

  1. Active Contexts stop or unwind while their type, callable and native bindings remain valid.
  2. Runtime objects and executable leases finish their required cleanup.
  3. Runtime IDs and binding visibility retire; externally held metadata remains readable.

- **BUT** Engine-only queries and reattachment of the retired image fail explicitly

  > A metadata lease preserves the definition, not a live Engine binding. Shutdown requested within an active callback is deferred until that execution lease exits rather than deadlocking or retiring underneath it.

