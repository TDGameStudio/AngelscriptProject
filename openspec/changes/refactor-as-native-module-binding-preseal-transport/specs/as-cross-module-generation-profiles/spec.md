## MODIFIED Requirements

### Requirement: Profile configuration preserves runtime dependency boundaries
Profile-configured modules SHALL be eligible only for target-module-local module-binding wrapper shards and SHALL NOT be added to `AngelscriptRuntime.Build.cs` dependencies for binding generation. Their generated NativeModuleFunctionAddress payloads SHALL become discoverable through a dependency-safe pre-seal transport rather than a reverse dependency on `AngelscriptRuntime`.

#### Scenario: Profile module is not a runtime dependency
- **WHEN** a module appears only in the JSON module-binding generation profile
- **THEN** `AngelscriptRuntime.Build.cs` does not list that module for generated binding coverage
- **AND** generated entries for that module use `EntryKind=ModuleBinding` and `ThunkStyle=FrameWrapper`
- **AND** no DirectNative or Stub rows are generated for that module-binding-only module
- **AND** the module can publish or expose its payload before binding seal without linking Runtime-owned binding provider symbols
