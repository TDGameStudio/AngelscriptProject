# as-library-full-namespaces Specification

## Purpose
TBD - created by archiving change refactor-as-library-full-namespaces. Update Purpose after archive.
## Requirements
### Requirement: Blueprint library namespaces use registered AS type names
The system SHALL bind reflected Blueprint library functions under the library class's registered Angelscript type namespace.

#### Scenario: UClass library uses full AS type namespace
- **WHEN** a reflected function is bound from a UClass-backed Blueprint library
- **THEN** the script namespace MUST equal the library's registered Angelscript type name, such as `UKismetSystemLibrary` or `UBlueprintGameplayTagLibrary`

#### Scenario: Class ScriptName does not change library namespace
- **WHEN** a Blueprint library class has class-level `ScriptName` metadata
- **THEN** that metadata MUST NOT replace the reflected library namespace

#### Scenario: Prefix and suffix stripping is unavailable
- **WHEN** a Blueprint library class name contains common prefixes or suffixes such as `UKismet`, `UBlueprint`, `Library`, or `FunctionLibrary`
- **THEN** the reflected library namespace MUST keep the registered Angelscript type name without trimming those parts

### Requirement: Removed namespace-shortening config has no script effect
The system SHALL NOT expose or honor settings that change reflected Blueprint library namespaces through ScriptName substitution, prefix stripping, or suffix stripping.

#### Scenario: Old namespace settings are absent from active settings
- **WHEN** Angelscript runtime settings are inspected for Blueprint library namespace behavior
- **THEN** the old namespace-shortening settings MUST NOT be part of the active configurable API

#### Scenario: Engine contexts use the same full-name rule
- **WHEN** multiple Angelscript engine contexts bind reflected Blueprint library functions
- **THEN** each context MUST use the full registered AS type namespace rule rather than context-specific shortening lists

### Requirement: Subsystem helper libraries use full library namespaces
The system SHALL expose subsystem helper functions through their full library namespaces.

#### Scenario: Runtime subsystem helpers use USubsystemLibrary
- **WHEN** script calls runtime subsystem helper functions
- **THEN** the supported namespace MUST be `USubsystemLibrary`, for example `USubsystemLibrary::GetWorldSubsystem(...)`

#### Scenario: Editor subsystem helpers use UEditorSubsystemLibrary
- **WHEN** generated or user script calls editor subsystem helper functions
- **THEN** the supported namespace MUST be `UEditorSubsystemLibrary`, for example `UEditorSubsystemLibrary::GetEditorSubsystem(...)`

#### Scenario: Generated subsystem accessors use full helper namespaces
- **WHEN** the preprocessor generates `static Get()` accessors for script subsystem classes
- **THEN** the generated code MUST call `USubsystemLibrary::...` or `UEditorSubsystemLibrary::...` as appropriate

