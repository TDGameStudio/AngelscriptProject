## ADDED Requirements

### Requirement: Explicit preprocessor environment
The runtime SHALL allow Angelscript preprocessing to be configured from an explicit value-style context that contains preprocessor flags and preprocessing defaults needed for script transformation.

#### Scenario: Explicit context controls preprocessing flags
- **WHEN** a caller constructs a preprocessor with an explicit context containing custom flag values
- **THEN** preprocessing SHALL evaluate conditional preprocessing using those explicit flag values rather than implicitly recomputing them from current engine state

#### Scenario: Context carries default preprocessing options
- **WHEN** a caller constructs a preprocessor with explicit default function/property preprocessing options
- **THEN** reflected function and property preprocessing SHALL use those explicit options for generated descriptors and processed code

### Requirement: Current-engine compatibility construction
The runtime SHALL preserve existing default preprocessor construction behavior by providing a compatibility path that creates the explicit context from the current engine/editor/cook/settings state.

#### Scenario: Default construction preserves existing behavior
- **WHEN** existing code constructs `FAngelscriptPreprocessor` without passing a context
- **THEN** preprocessing SHALL use the same effective editor/cook/release/test/server flags and settings-derived defaults as before this change

#### Scenario: Current-engine factory is observable in tests
- **WHEN** tests create a context from current engine state and construct a preprocessor from it
- **THEN** the resulting preprocessor SHALL expose the same effective flags and defaults as the compatibility constructor

### Requirement: Preprocessor execution avoids scattered engine lookups
The runtime SHALL centralize preprocessing environment lookup in the context factory instead of requiring preprocessing execution steps to repeatedly read `FAngelscriptEngine` singleton state for flags and defaults.

#### Scenario: Preprocess uses stored context
- **WHEN** a preprocessor has been constructed with an explicit context and `Preprocess()` is executed
- **THEN** preprocessing SHALL use the stored context values for preprocessing environment decisions throughout the run

## Testing Requirements

- Target test layer: Runtime Integration under `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/` because the behavior uses `FAngelscriptEngine`-backed preprocessing but does not require a World or Actor lifecycle.
- Expected Automation prefix: `Angelscript.TestModule.Preprocessor.*`.
- Recommended helper/harness: existing `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/AngelscriptPreprocessorTestHelpers.h` plus `Shared/AngelscriptTestEngineHelper.*` when an engine-backed context is needed.
- Verification entry point: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Preprocessor" -Label preprocessor-context -TimeoutMs 600000`.
