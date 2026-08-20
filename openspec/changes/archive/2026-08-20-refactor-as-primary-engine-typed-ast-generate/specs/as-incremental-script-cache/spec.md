## ADDED Requirements

### Requirement: FunctionBody may link an optional TypedHIR sidecar

Each FunctionBody SHALL be the sole authority for its optional TypedHIR sidecar link. A present sidecar MUST carry the same FunctionKey and full ArtifactProfileKey. An absent sidecar SHALL be an unset optional plus the shared artifact-identity `H("function-typed-hir-absent", full ArtifactProfileKey)` coordinate, never a zero RecordId/hash or typed-HIR hash of empty bytes. Sidecar payload schema SHALL be versioned independently from FunctionBody bytecode and DebugSidecar.

#### Scenario: Shipping packaged runtime omits typed HIR payload

- **WHEN** a valid Shipping FunctionBody has no TypedHIR sidecar
- **THEN** its execution content remains independently verifiable
- **AND** its typed-HIR coordinate equals the canonical profile-specific absent digest

#### Scenario: Sidecar function key differs

- **WHEN** a FunctionBody links a valid TypedHIR sidecar belonging to another FunctionKey
- **THEN** graph validation reports a typed HIR-link mismatch
- **AND** the sidecar is not attached

#### Scenario: Empty typed HIR is used as absence

- **WHEN** a body has no sidecar but carries the typed-HIR hash of an empty payload rather than the profile-specific absence hash
- **THEN** graph validation reports a HIR-link mismatch
- **AND** it does not reinterpret the empty payload coordinate as absence

### Requirement: TypedHIR sidecar restore is capture-profile gated

ExactStartup SHALL restore TypedHIR sidecars only into capture-on Engines whose frozen Static backend requires verified HIR. A capture-off Engine MUST ignore sidecar bytes for execution and MUST NOT attach HIR. A capture-on typed-ast Engine MUST miss ExactStartup when selected FunctionBodies lack sidecars.

#### Scenario: Capture-on restore rebuilds HIR

- **WHEN** ExactStartup activates a generation with valid TypedHIR sidecars into a capture-on Engine
- **THEN** restored functions own verified HIR
- **AND** preprocess/parse/function-compiler counters remain at zero for those restored bodies

#### Scenario: Capture-off restore leaves HIR unset

- **WHEN** ExactStartup activates the same generation into a capture-off `"bytecode"` Engine
- **THEN** restored functions execute from bytecode
- **AND** they have no typed semantic HIR

#### Scenario: Mixed bytecode-without-HIR is illegal for typed-ast

- **WHEN** a capture-on typed-ast Engine selects a module whose FunctionBodies are bytecode-valid but only some have TypedHIR sidecars
- **THEN** ExactStartup rejects that module or generation as ineligible
- **AND** no mixed attach occurs
