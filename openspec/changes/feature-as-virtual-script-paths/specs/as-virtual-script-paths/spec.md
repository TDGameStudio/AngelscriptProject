## ADDED Requirements

### Requirement: Script sources have canonical AS virtual paths

The runtime SHALL assign supported script sources a canonical `/Angelscript/...` virtual path before preprocessing or compilation.

#### Scenario: Project disk source receives game virtual path

- **WHEN** a script is discovered under the project `Script/` root
- **THEN** its virtual path SHALL be `/Angelscript/Game/<RelativePath>.as`
- **AND** its physical filename SHALL remain available for editor tooling

#### Scenario: Plugin disk source receives plugin virtual path

- **WHEN** a script is discovered under an enabled plugin `Script/` root
- **THEN** its virtual path SHALL be `/Angelscript/Plugin/<PluginName>/<RelativePath>.as`
- **AND** its physical filename SHALL remain available for editor tooling

#### Scenario: Memory source receives memory virtual path

- **WHEN** a memory-backed source is passed to the preprocessor
- **THEN** it SHALL be valid without a physical filename
- **AND** its virtual path SHALL be under `/Angelscript/Memory/<Provider>/`

#### Scenario: Immediate memory source path is reserved

- **WHEN** future realtime snippets provide memory-backed sources
- **THEN** their default source identity SHOULD be under `/Angelscript/Memory/Immediate/`
- **AND** this change SHALL NOT expose a snippet execution API

#### Scenario: Invalid virtual path is rejected

- **WHEN** a source path has a non-`/Angelscript` root, URI scheme, missing `.as` leaf, empty segment, `.` segment, `..` segment, or backslash
- **THEN** virtual path parsing SHALL fail before the source is compiled

### Requirement: Virtual paths map to stable module names

The runtime SHALL derive deterministic module names while preserving v1 disk-source compatibility.

#### Scenario: Project module name remains compatible

- **WHEN** a project source has virtual path `/Angelscript/Game/Gameplay/Enemy.as`
- **THEN** its default module name SHALL be `Gameplay.Enemy`

#### Scenario: Plugin module name remains compatible in v1

- **WHEN** a plugin source has virtual path `/Angelscript/Plugin/Inventory/Gameplay/Enemy.as`
- **THEN** its default module name SHALL be `Gameplay.Enemy`
- **AND** any future plugin-prefix migration SHALL be a separate compatibility change

#### Scenario: Memory module name is isolated

- **WHEN** a memory source has virtual path `/Angelscript/Memory/Immediate/Snippet_001.as`
- **THEN** its default module name SHALL be `Angelscript.Memory.Immediate.Snippet_001`

### Requirement: Descriptor-aware preprocessing preserves file compatibility

The preprocessor SHALL accept source descriptors while keeping existing file-based entry points working.

#### Scenario: File adapter produces a project virtual path

- **WHEN** existing code calls `FAngelscriptPreprocessor::AddFile("Gameplay/Enemy.as", PhysicalPath)`
- **THEN** preprocessing SHALL behave as before
- **AND** the file summary and code section SHALL include `/Angelscript/Game/Gameplay/Enemy.as`

#### Scenario: Memory source preprocesses without disk IO

- **WHEN** code calls `FAngelscriptPreprocessor::AddSource()` with source text and no physical filename
- **THEN** the preprocessor SHALL use the provided text
- **AND** it SHALL NOT attempt to read the source from disk

### Requirement: Compilation observability includes virtual paths

The runtime SHALL expose virtual path identity in compile metadata while retaining physical path data when it exists.

#### Scenario: Preprocessor summary includes virtual path

- **WHEN** preprocessing summarizes a source
- **THEN** the summary SHALL include `VirtualPath`
- **AND** disk-backed sources SHALL also report `AbsoluteFilename`

#### Scenario: Code section includes virtual path

- **WHEN** preprocessing emits module code sections
- **THEN** each section SHALL include `VirtualPath`
- **AND** memory-backed sections SHALL use the virtual path as their compiler section name when no physical filename exists

#### Scenario: Editor hot reload queue preserves virtual path

- **WHEN** the editor directory watcher queues a script change under a plugin script root
- **THEN** the queued filename pair SHALL include `/Angelscript/Plugin/<PluginName>/<RelativePath>.as`
- **AND** loaded code-section enumeration used for folder deletion SHALL preserve each section's `VirtualPath`

#### Scenario: Legacy root overrides remain compatible

- **WHEN** existing tests or tools temporarily override only `FAngelscriptEngine::AllRootPaths`
- **AND** `AllScriptRoots` contains stale descriptors
- **THEN** script discovery SHALL honor the current `AllRootPaths` as game roots

## Testing Requirements

- Target test layer: Runtime integration under `Plugins/Angelscript/Source/AngelscriptTest/FileSystem/`, `Preprocessor/`, and `Compiler/`; editor-only coverage under `Plugins/Angelscript/Source/AngelscriptEditor/Tests/` for hot reload queue behavior.
- Expected Automation prefixes:
  - `Angelscript.TestModule.FileSystem.VirtualScriptPaths.*`
  - `Angelscript.TestModule.Preprocessor.VirtualScriptPaths.*`
  - `Angelscript.TestModule.Compiler.VirtualScriptPaths.*`
  - `Angelscript.Editor.DirectoryWatcher.*`
- Verification entry points:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.FileSystem.VirtualScriptPaths" -Label virtual-script-paths-filesystem -TimeoutMs 600000`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Preprocessor.VirtualScriptPaths" -Label virtual-script-paths-preprocessor -TimeoutMs 600000`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Compiler.VirtualScriptPaths" -Label virtual-script-paths-compiler -TimeoutMs 600000`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.Editor.DirectoryWatcher" -Label virtual-script-paths-directorywatcher -TimeoutMs 600000`
