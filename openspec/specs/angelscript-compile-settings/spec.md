# angelscript-compile-settings Specification

## Purpose
TBD - created by archiving change chore-angelscript-compile-settings. Update Purpose after archive.
## Requirements
### Requirement: Angelscript compile options file controls test compilation policy

The project SHALL define Angelscript compile-time build policy in `Config/DefaultAngelscriptCompileOptions.ini`, using `[/Script/AngelscriptRuntime.AngelscriptCompileOptions]` and a boolean `bCompileAngelscriptUnitTests` setting.

#### Scenario: Build settings file is present

- **WHEN** the project `Config` directory is inspected after this change is implemented
- **THEN** `DefaultAngelscriptCompileOptions.ini` exists
- **AND** it contains `bCompileAngelscriptUnitTests` under `[/Script/AngelscriptRuntime.AngelscriptCompileOptions]`

#### Scenario: Build tests disabled

- **WHEN** `bCompileAngelscriptUnitTests=false`
- **THEN** `AngelscriptTest.Build.cs` defines `WITH_ANGELSCRIPT_UNITTESTS=0`

#### Scenario: Build tests enabled

- **WHEN** `bCompileAngelscriptUnitTests=true`
- **THEN** `AngelscriptTest.Build.cs` defines `WITH_ANGELSCRIPT_UNITTESTS=1`

### Requirement: Editor settings surface writes the compile options file

The editor SHALL expose the compile option through a dedicated runtime-owned `UAngelscriptCompileOptions` settings object rather than through the broad `UAngelscriptSettings` section.

#### Scenario: Settings class exists

- **WHEN** the Angelscript editor module is built
- **THEN** `AngelscriptRuntime` provides `UAngelscriptCompileOptions` with `config = AngelscriptCompileOptions` and `defaultconfig`
- **AND** the class has a config property named `bCompileAngelscriptUnitTests`

#### Scenario: Settings panel registration

- **WHEN** `AngelscriptEditor` starts in the editor
- **THEN** it registers `UAngelscriptCompileOptions` in Project Settings under `Plugins`
- **AND** the settings section is independent from the existing `Angelscript` settings section

#### Scenario: Settings are saved

- **WHEN** a user changes `bCompileAngelscriptUnitTests` from the settings panel
- **THEN** UE saves the project default value to `Config/DefaultAngelscriptCompileOptions.ini`
- **AND** the section name is `[/Script/AngelscriptRuntime.AngelscriptCompileOptions]`

### Requirement: Compile option changes invalidate UBT makefiles

The `AngelscriptTest` module rules SHALL register `Config/DefaultAngelscriptCompileOptions.ini` as an external dependency so changes to the file invalidate UBT makefiles for targets that include the test module.

#### Scenario: Build config is modified

- **WHEN** `Config/DefaultAngelscriptCompileOptions.ini` is modified after a target including `AngelscriptTest` has been built
- **THEN** a subsequent UBT build treats the makefile as stale because the external dependency changed

### Requirement: Compile settings stay isolated from editor settings

The project SHALL keep compile-affecting Angelscript options in a dedicated config file rather than a broad editor preferences file.

#### Scenario: Generic editor setting changes

- **GIVEN** an Angelscript editor settings ini exists for ordinary editor preferences
- **WHEN** a non-compile editor preference changes
- **THEN** that change does not invalidate C++ makefiles through the Angelscript test compile gate

#### Scenario: Compile option changes

- **GIVEN** `Config/DefaultAngelscriptCompileOptions.ini` contains only compile-affecting options
- **WHEN** any option in that file changes
- **THEN** makefile invalidation is acceptable because the file is dedicated to compile policy

### Requirement: Disabled test builds omit Angelscript test registration

When `WITH_ANGELSCRIPT_UNITTESTS=0`, Angelscript C++ automation tests SHALL not register Angelscript test cases with Unreal's automation framework.

#### Scenario: Automation test discovery with tests disabled

- **WHEN** the editor automation framework scans tests from a build compiled with `WITH_ANGELSCRIPT_UNITTESTS=0`
- **THEN** Angelscript test prefixes from `AngelscriptTest` are not registered

#### Scenario: Automation test discovery with tests enabled

- **WHEN** the editor automation framework scans tests from a build compiled with `WITH_ANGELSCRIPT_UNITTESTS=1`
- **THEN** Angelscript test prefixes from `AngelscriptTest` remain registered

### Requirement: Existing module layout remains unchanged

The change SHALL keep `AngelscriptTest` in the existing `Angelscript` plugin module layout and SHALL NOT require a separate test plugin.

#### Scenario: Plugin descriptor remains structurally compatible

- **WHEN** `Plugins/Angelscript/Angelscript.uplugin` is inspected after this change is implemented
- **THEN** the existing `AngelscriptTest` module declaration remains present
- **AND** no new Angelscript test plugin is required for the config gate to work

### Requirement: Scheme boundary is documented

Documentation for the build setting SHALL state that this config gate controls test registration and test-only compile paths, not whether UBT scans or includes the `AngelscriptTest` module itself.

#### Scenario: Consumer reads build documentation

- **WHEN** a consumer reads the Angelscript build/test documentation after this change is implemented
- **THEN** the documentation explains how to set `bCompileAngelscriptUnitTests`
- **AND** it states that complete module-level exclusion requires a separate target/plugin-level module gate

