## ADDED Requirements

### Requirement: XConsole pipeline is absent
The UnrealEvent plugin SHALL NOT provide GMP XConsole command pipeline behavior, including command-list execution, pipeline state commands, HTTP pipeline initialization, Python pipeline execution, or XConsole commandlet execution.

#### Scenario: Runtime starts without XConsole hooks
- **WHEN** the UnrealEvent runtime module starts and maps or gameplay worlds load
- **THEN** no XConsole command-line processing hook is registered or invoked

#### Scenario: XConsole commands are not registered by UnrealEvent
- **WHEN** the plugin is built after this change
- **THEN** XConsole commands such as `z.XCmdList`, `z.PipelineExec`, `z.PipelineRunPy`, and `z.RequestExitWithStatus` are not registered by UnrealEvent source

### Requirement: XConsole dependencies are removed
The UnrealEvent plugin SHALL NOT depend on modules or plugin declarations that existed only to support XConsole pipeline behavior.

#### Scenario: Build metadata excludes XConsole-only modules
- **WHEN** Unreal Build Tool evaluates `UnrealEvent.Build.cs`
- **THEN** the module does not add `HTTPServer`, `GMP_HTTPSERVER`, or `PythonScriptPlugin` for XConsole support

#### Scenario: Plugin descriptor excludes Python XConsole support
- **WHEN** `UnrealEvent.uplugin` is parsed
- **THEN** it does not declare `PythonScriptPlugin` as an UnrealEvent plugin dependency

### Requirement: Non-XConsole diagnostics remain available
The UnrealEvent runtime SHALL preserve local non-shipping GMP signal debug controls without depending on XConsole.

#### Scenario: Signal debug controls compile without XConsole
- **WHEN** `GMPSignalsImpl.cpp` is compiled for a non-shipping target
- **THEN** `gmp.key.debug` and `gmp.msgkey.debug` remain available through standard Unreal console APIs and no XConsole header is included

### Requirement: Reference editor source does not retain XConsole symbols
The disabled `Source/GMPEditor` reference tree SHALL NOT include XConsole headers or XConsole helper registrations.

#### Scenario: GMPEditor reference tree is searched for XConsole
- **WHEN** the UnrealEvent source tree is searched for `XConsole`, `FXConsole`, `IXConsole`, or `ProcessXCommand`
- **THEN** no matches remain under `Source/GMPEditor` or the active runtime source
