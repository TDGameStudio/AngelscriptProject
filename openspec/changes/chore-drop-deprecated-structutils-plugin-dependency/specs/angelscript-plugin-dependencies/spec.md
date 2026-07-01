# Spec — angelscript-plugin-dependencies

## ADDED Requirements

### Requirement: Plugin Dependencies Exclude Deprecated Or Removed Plugins

The `Plugins` dependency list in `Angelscript.uplugin` SHALL NOT declare plugins that are deprecated or removed in the current engine version, UE 5.8. Functionality that has moved into `CoreUObject`, such as `FInstancedStruct`, SHALL be consumed through the existing `CoreUObject` module dependency rather than the deprecated `StructUtils` plugin or module dependency.

#### Scenario: Startup Has No StructUtils Deprecation Warning

- **WHEN** the Angelscript plugin loads under UE 5.8
- **THEN** no warning appears that the `StructUtils` plugin is deprecated or will be removed

#### Scenario: FInstancedStruct Bindings Remain Available

- **WHEN** the build runs after removing the StructUtils plugin dependency from `Angelscript.uplugin`
- **THEN** `AngelscriptRuntime` still links types such as `FInstancedStruct` through the Build.cs `CoreUObject` module dependency with no binding behavior regression

#### Scenario: Module Dependencies Exclude Deprecated StructUtils

- **WHEN** `AngelscriptRuntime.Build.cs` declares its public module dependencies for UE 5.8
- **THEN** it does not list the deprecated `StructUtils` module dependency
