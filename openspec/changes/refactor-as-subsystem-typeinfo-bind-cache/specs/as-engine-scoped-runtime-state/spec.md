## ADDED Requirements

### Requirement: Subsystem TypeBindInfo is replayable metadata, not asITypeInfo

`FAngelscriptTypeBindInfo` stored on `UAngelscriptSubsystem` SHALL count as process-wide replayable bind metadata. It MAY hold Angelscript type names, member declarations, UE reflection identities, C++ callable pointers, and native recipes. It SHALL NOT hold `asITypeInfo*`, `asIScriptFunction*`, `asIScriptObject*`, or `asCContext*`. Per-engine `asITypeInfo*` for the same C++ type SHALL remain engine-scoped after apply.

#### Scenario: Two engines apply the same TypeInfo row

- **GIVEN** the subsystem array contains one `FAngelscriptTypeBindInfo` for `FString`
- **WHEN** Engine A and Engine B both apply that row
- **THEN** Engine A's `asITypeInfo*` for `FString` is associated only with Engine A
- **AND** Engine B's `asITypeInfo*` is associated only with Engine B
- **AND** the subsystem TypeBindInfo row still contains no `asITypeInfo*`

#### Scenario: Engine teardown leaves TypeInfo in the subsystem

- **WHEN** Engine A shuts down after applying TypeInfo
- **THEN** the subsystem `FAngelscriptTypeBindInfo` array remains sealed for later engines
- **AND** no `asITypeInfo*` from Engine A remains reachable through that array
