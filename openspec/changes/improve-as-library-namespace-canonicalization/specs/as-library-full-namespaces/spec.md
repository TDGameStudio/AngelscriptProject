## MODIFIED Requirements

### Requirement: Blueprint library namespaces use registered AS type names
The system SHALL bind reflected Blueprint library namespace functions under an exact configured canonical namespace when the owner class has a canonical function-library mapping, and SHALL otherwise bind them under the library class's registered Angelscript type namespace.

#### Scenario: Explicit canonical mapping overrides full AS type namespace
- **WHEN** a reflected static namespace function is owned by a class with an exact canonical mapping
- **THEN** the script namespace MUST equal the configured canonical namespace

#### Scenario: Unmapped UClass library uses full AS type namespace
- **WHEN** a reflected function is bound from a UClass-backed Blueprint library without an exact canonical mapping
- **THEN** the script namespace MUST equal the library's registered Angelscript type name, such as `UKismetSystemLibrary` or `UBlueprintGameplayTagLibrary`

#### Scenario: Class ScriptName does not change an ordinary library namespace
- **WHEN** an ordinary Blueprint library class has class-level `ScriptName` metadata but no exact canonical mapping
- **THEN** that metadata MUST NOT replace the reflected library namespace

#### Scenario: Prefix and suffix stripping remains unavailable
- **WHEN** a Blueprint library class name contains common prefixes or suffixes such as `UKismet`, `UBlueprint`, `Library`, or `FunctionLibrary`
- **THEN** the reflected library namespace MUST keep the registered Angelscript type name unless an exact class-path canonical mapping applies
