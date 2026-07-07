## ADDED Requirements

### Requirement: Configurable Development-Only Script Directories

The runtime SHALL determine which script subdirectories are treated as development-only from a
project-configurable list (`UAngelscriptSettings::DevelopmentOnlyScriptDirectories`) instead of
hardcoded names. When development scripts are excluded (cooked builds, cook commandlet,
simulate-cooked), the source walker SHALL skip any directory whose name matches an entry in this
list. The default list SHALL be `Examples`, `Dev`.

#### Scenario: Default development directories skipped in cooked build

- **WHEN** discovering `.as` sources in a cooked build with `bSkipDevelopmentScripts` true and default settings
- **THEN** directories named `Examples` and `Dev` are skipped
- **AND** their `.as` files are not compiled

#### Scenario: Custom development directory honored

- **WHEN** `DevelopmentOnlyScriptDirectories` is configured to include `Sandbox`
- **AND** development scripts are excluded
- **THEN** a `Sandbox` directory is skipped during source discovery

#### Scenario: Development directories included when editor scripts are used

- **WHEN** discovering `.as` sources with `bSkipDevelopmentScripts` false (e.g. in-editor)
- **THEN** directories in the development-only list are NOT skipped and their files compile

### Requirement: Configurable Editor-Only Script Directories

The runtime SHALL determine which script subdirectories are treated as editor-only from a
project-configurable list (`UAngelscriptSettings::EditorOnlyScriptDirectories`). When editor
scripts are excluded, the source walker SHALL skip any directory whose name matches an entry in
this list. The default list SHALL be `Editor`.

#### Scenario: Default editor directory skipped when editor scripts excluded

- **WHEN** discovering `.as` sources with `bSkipEditorScripts` true and default settings
- **THEN** a directory named `Editor` is skipped

#### Scenario: Renamed editor directory honored

- **WHEN** `EditorOnlyScriptDirectories` is configured to `EditorTools` instead of `Editor`
- **AND** editor scripts are excluded
- **THEN** a directory named `EditorTools` is skipped and a directory named `Editor` is NOT skipped

### Requirement: Defaults Preserve Existing Behavior

With unmodified settings, source discovery SHALL behave identically to the previous hardcoded
implementation (skip `Examples`, `Dev` for development-only; `Editor` for editor-only). An empty
configured list SHALL cause no directory to be skipped for that category.

#### Scenario: No configuration matches prior behavior

- **WHEN** no project overrides are present
- **THEN** the set of skipped directories equals the previous hardcoded set (`Examples`, `Dev`, `Editor`)

#### Scenario: Empty list skips nothing in that category

- **WHEN** `DevelopmentOnlyScriptDirectories` is set to an empty array
- **AND** development scripts are excluded
- **THEN** no directory is skipped on account of being development-only

### Requirement: Single Source Of Truth Across Discovery Paths

All script-discovery code paths SHALL consult the same configured directory lists, so that the
production source provider and any legacy discovery path skip the same directories for identical
configuration.

#### Scenario: Both discovery paths honor a custom list

- **WHEN** a custom development-only list is configured
- **THEN** both `FAngelscriptDiskSourceProvider` discovery and the legacy `FindAllScriptFilenames`
  path skip exactly the configured directories
