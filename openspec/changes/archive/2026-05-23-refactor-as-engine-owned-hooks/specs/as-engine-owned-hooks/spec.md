## ADDED Requirements

### Requirement: Engine-scoped hooks are owned by the active engine
The runtime SHALL store AngelScript runtime and behavior-changing compilation hooks on `FAngelscriptEngine` rather than on `FAngelscriptRuntimeModule`.

#### Scenario: Hook fires for its owning engine
- **WHEN** a caller registers a pre-compile, post-compile, class-analyze, pre-generate-classes, post-compile-class-collection, component-created, literal-asset-created, dynamic-spawn-level, debug-break, or debug-object-suffix hook through an engine-owned hook surface
- **THEN** that hook SHALL be invoked at the same lifecycle moment previously provided by the module-level hook

#### Scenario: Hook does not leak to a different engine
- **WHEN** two independent `FAngelscriptEngine` instances exist and a hook is registered on only one instance
- **THEN** operations performed through the other engine SHALL NOT invoke that hook

### Requirement: Runtime module no longer exposes hook storage
`FAngelscriptRuntimeModule` SHALL NOT expose static hook getter APIs after the migration is complete.

#### Scenario: Module keeps only module lifecycle responsibilities
- **WHEN** code includes `AngelscriptRuntimeModule.h`
- **THEN** the module API SHALL expose UE module startup/shutdown and initialization compatibility behavior, and SHALL NOT expose migrated `Get*` hook getters

#### Scenario: Callers use explicit owners
- **WHEN** runtime, bind, debug, preprocessor, compiler, editor, or test code needs a migrated hook
- **THEN** it SHALL access the hook through `FAngelscriptEngine` or the dedicated editor/debug bridge instead of `FAngelscriptRuntimeModule`

### Requirement: Behavior-changing class analysis remains mutable
Class analysis hooks SHALL preserve their ability to mutate generated statics and class static metadata.

#### Scenario: Class analyze hook mutates generated statics
- **WHEN** a class analysis hook appends generated static code and updates the static flag during preprocessing
- **THEN** the generated code SHALL include the hook-provided static content and the static flag SHALL affect whether generated code is emitted

### Requirement: Editor/debug bridge hooks are not owned by the runtime module
Editor-facing debug and asset creation hooks SHALL move out of `FAngelscriptRuntimeModule` without becoming general runtime module globals.

#### Scenario: Editor module registers bridge behavior
- **WHEN** `AngelscriptEditor` starts up and registers debug asset listing, blueprint creation, or create-blueprint-default-path behavior
- **THEN** runtime debug requests SHALL still reach the registered editor behavior through the dedicated bridge

#### Scenario: Bridge can be reset in tests
- **WHEN** editor or debugger automation tests temporarily override bridge behavior
- **THEN** the tests SHALL be able to restore or clear the bridge without using `FAngelscriptRuntimeModule`

## Testing Requirements

- Target test layer: Runtime CppTests for engine hook ownership and isolation; Compiler/Preprocessor integration for compile/class-analysis timing; Editor tests for editor bridge behavior.
- Expected Automation prefixes:
  - `Angelscript.TestModule.CppTests.Engine.Hooks`
  - `Angelscript.TestModule.Compiler`
  - `Angelscript.TestModule.Preprocessor`
  - `Angelscript.Editor.*`
- Recommended helpers/harnesses: existing `AngelscriptTestSupport` engine helpers for runtime tests, existing compiler/preprocessor fixture helpers, and current editor module test guards for editor bridge override/restore.
- Verification entry points:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.Engine.Hooks" -Label engine-owned-hooks -TimeoutMs 900000`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Compiler" -Label engine-owned-hooks-compiler -TimeoutMs 900000`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Preprocessor" -Label engine-owned-hooks-preprocessor -TimeoutMs 900000`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.Editor" -Label engine-owned-hooks-editor -TimeoutMs 900000`
