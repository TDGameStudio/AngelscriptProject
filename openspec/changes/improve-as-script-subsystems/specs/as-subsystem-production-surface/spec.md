## ADDED Requirements

### Requirement: Runtime engine host is not an AngelScript author subsystem

`UAngelscriptSubsystem` SHALL remain the C++ runtime owner/access point for the primary `FAngelscriptEngine`, but it SHALL NOT receive an automatically generated AngelScript `UAngelscriptSubsystem::Get()` accessor or be documented as a project-global script service. Project-wide script state SHALL use a user-defined `UScriptEngineSubsystem` or the narrower supported script subsystem scope.

#### Scenario: Native subsystem accessor registration skips the runtime host
- **WHEN** native subsystem `::Get()` accessors are generated for an AngelScript engine
- **THEN** eligible UE and project-native subsystem types SHALL retain their existing accessors
- **AND** the runtime host `UAngelscriptSubsystem` SHALL not expose a generated AngelScript `::Get()` entry

#### Scenario: Runtime C++ ownership remains available
- **WHEN** plugin runtime code initializes or resolves the primary AngelScript engine
- **THEN** it SHALL continue to use `UAngelscriptSubsystem::Get()` and `GetEngine()` in C++
- **AND** hiding the script accessor SHALL not change engine ownership, startup, or tick behavior
