# as-blueprint-parent-class-discovery Specification

## ADDED Requirements

### Requirement: Standard blueprint parent pickers surface valid Angelscript classes
The standard Unreal Blueprint parent-class picker and Blueprint reparent picker SHALL surface loaded Angelscript-generated classes when those classes satisfy the same blueprint-base eligibility rules used for native classes.

#### Scenario: Example script actor appears in parent search
- **WHEN** `AExampleActorType` is compiled from `Script/Game/Example_Actor.as`
- **AND** the class is not explicitly marked `NotBlueprintable`, `HideDropdown`, `Abstract`, or `Deprecated`
- **THEN** the standard Blueprint parent-class picker SHALL include `AExampleActorType` in its search results
- **AND** the class SHALL be selectable as the parent of a new Blueprint

#### Scenario: Reparent picker treats the same class as eligible
- **WHEN** a loaded Angelscript class satisfies the same inheritance rules as a native blueprint base
- **THEN** the Blueprint reparent picker SHALL treat that class as a valid parent candidate
- **AND** the class SHALL not be hidden solely because it originates from Angelscript

### Requirement: Existing exclusion rules remain in force
The picker SHALL continue to suppress classes that are explicitly invalid parents because of existing class flags or metadata.

#### Scenario: Explicitly hidden or invalid script classes stay hidden
- **WHEN** an Angelscript class is marked with `NotBlueprintable`, `HideDropdown`, `Abstract`, or `Deprecated`
- **THEN** the standard Blueprint parent-class picker SHALL continue to omit that class from search results
- **AND** the change SHALL not weaken existing invalid-parent safeguards

#### Scenario: Direct Angelscript create flow remains compatible
- **WHEN** the Angelscript editor opens its direct create-blueprint popup for a valid `UASClass`
- **THEN** that flow SHALL continue to create the Blueprint from the selected class
- **AND** the new picker-discovery behavior SHALL not break or regress the direct-create path
