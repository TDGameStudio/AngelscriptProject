## ADDED Requirements

### Requirement: AS reflection declarations exclude Blueprint accessor metadata

The frontend SHALL reject AS-authored BlueprintGetter and BlueprintSetter requests instead of projecting accessor-specific flags or silently ignoring them.

#### Scenario: Author a Blueprint accessor request
- **WHEN** an AS property or function attribute contains BlueprintGetter or BlueprintSetter directly or inside nested metadata
- **THEN** the frontend reports the unsupported request at its authored range and exposes no publishable resolved descriptor set for the failed compilation

#### Scenario: Preserve ordinary reflected fields and explicit methods
- **WHEN** source declares an ordinary UPROPERTY with supported read/write metadata and explicit UFUNCTION GetValue/SetValue methods
- **THEN** normal field/function descriptors and stable semantic keys are preserved
- **BUT** no automatic accessor association is inferred from those method names

#### Scenario: Consume native UE reflection
- **WHEN** the host provides an existing native UE type with its own reflection metadata
- **THEN** the AS source-authoring restriction does not rewrite UE's native type or engine-wide Blueprint behavior
