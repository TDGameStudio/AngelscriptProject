## ADDED Requirements

### Requirement: Source-layout engine detection

The build runner SHALL detect source-layout Unreal Engine roots that provide UnrealBuildTool source but do not yet provide a precompiled UnrealBuildTool DLL.

#### Scenario: Source-layout engine is configured

- **WHEN** `AgentConfig.ini` points `Paths.EngineRoot` at an engine root where `Engine\Source\Programs\UnrealBuildTool\UnrealBuildTool.csproj` exists
- **AND** `Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.dll` does not exist
- **THEN** the build runner identifies the engine as source-layout instead of failing during UBT path resolution

#### Scenario: Precompiled engine is configured

- **WHEN** `AgentConfig.ini` points `Paths.EngineRoot` at an engine root where `Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.dll` exists
- **THEN** the build runner uses the existing precompiled-engine path

#### Scenario: Invalid engine is configured

- **WHEN** `AgentConfig.ini` points `Paths.EngineRoot` at an engine root without a usable UnrealBuildTool DLL or source project
- **THEN** the build runner fails with a configuration error that explains which UBT artifacts were expected

### Requirement: Source-layout build execution

The build runner SHALL build the configured project target through a source-layout-compatible path when a source-layout engine is configured.

#### Scenario: Source-layout build starts

- **WHEN** a maintainer runs `Tools\RunBuild.ps1` with a source-layout engine root
- **THEN** the runner launches a source-layout-compatible build path for the configured editor target, platform, configuration, project file, and architecture
- **AND** the maintainer does not need to manually invoke an engine batch command

#### Scenario: Source-layout build writes engine outputs

- **WHEN** a source-layout build may generate UnrealBuildTool or engine-side build products
- **THEN** the runner serializes the build by engine root before launching the source-layout build path

### Requirement: Consistent runner contract

The source-layout branch SHALL preserve the existing runner contract for timeout handling, live logging, cleanup, metadata, and final exit codes.

#### Scenario: Build artifacts are inspected

- **WHEN** a source-layout build finishes
- **THEN** the run has an isolated build output directory under the configured build log root
- **AND** the run records mode, target, project file, engine root, timeout, arguments or adapter details, process exit code, final exit code, and duration in metadata

#### Scenario: Build times out

- **WHEN** a source-layout build exceeds the requested timeout
- **THEN** the runner stops the launched build process tree
- **AND** returns the existing timeout exit-code category

### Requirement: Documentation for source-layout engines

The build guide SHALL describe source-layout engine behavior through the standard project build runner without hardcoding local machine paths.

#### Scenario: Maintainer reads build guidance

- **WHEN** a maintainer needs to build against a source-layout engine
- **THEN** `Documents\Guides\Build.md` explains that `Tools\RunBuild.ps1` handles source-layout engines through the standard runner
- **AND** the guide keeps local engine paths in `AgentConfig.ini`