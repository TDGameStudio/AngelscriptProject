## ADDED Requirements

### Requirement: Direct optimized calls preserve observable behavior
`UASFunction` direct optimized call helpers SHALL preserve script-observable argument, return, and reference-writeback behavior for supported helper shapes.

#### Scenario: Direct helpers pass values and write references
- **WHEN** a generated `UASFunction` is invoked through a direct optimized helper for no-param, byte-return, float-arg, double-arg, ref-arg, or ref-arg-byte-return shapes
- **THEN** the script-visible state, return value, and referenced C++ value match the values produced by the script implementation

#### Scenario: Direct helpers expose defined fallback behavior
- **WHEN** a direct helper executes a script exception or is called after its module has been discarded
- **THEN** the helper returns or preserves the documented fallback value without crashing

### Requirement: Runtime wrappers preserve reflected ABI behavior
`UASFunction` runtime wrappers SHALL preserve reflected parameter and return layouts across BPVM `ProcessEvent` and direct `RuntimeCallEvent` entry points.

#### Scenario: ProcessEvent dispatch preserves reflected values
- **WHEN** byte, bool, dword, qword, float, double, object-return, primitive-return, and reference-shaped script functions are invoked through `UObject::ProcessEvent`
- **THEN** script state, return slots, and reference/output values match the reflected parameter buffer values

#### Scenario: RuntimeCallEvent dispatch preserves Parms values
- **WHEN** the same generated functions are invoked directly through `UASFunction::RuntimeCallEvent`
- **THEN** the `Parms` buffer is consumed and updated according to the generated `UFunction` property layout

### Requirement: Virtual dispatch resolves script overrides
Optimized `UASFunction` dispatch SHALL resolve script virtual functions against the runtime object class.

#### Scenario: Parent function invoked on child object executes child override
- **WHEN** a parent script class defines a virtual generated function and a child script class overrides it
- **THEN** invoking the parent `UASFunction` with a child object executes the child implementation

### Requirement: Metadata predicates classify generated entities
`UASFunction` metadata helpers SHALL distinguish AS-generated functions, generated properties, world-context properties, native functions, and stale generated functions.

#### Scenario: Generated and native metadata are classified
- **WHEN** AS-generated and native `UFunction`/`FProperty` values are inspected
- **THEN** generated predicates return true only for AS-generated entities and world-context predicates return true only for AS world-context parameters

#### Scenario: Source metadata has explicit stale behavior
- **WHEN** a generated function is inspected before and after module discard
- **THEN** source path and line metadata are present before discard and clear or invalid after discard

## Testing Requirements

- Target test layer: Runtime Integration under `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/`.
- Expected Automation prefix: `Angelscript.TestModule.ClassGenerator.ASFunction`.
- Recommended helpers: `FAngelscriptEngine`, `FAngelscriptEngineScope`, `AngelscriptFunctionalTestUtils`, `FStructOnScope`, and existing `FindGeneratedFunction` / reflected property helpers.
- Verification entry point: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.ClassGenerator.ASFunction" -Label uasfunction-dispatch -TimeoutMs 600000`.
