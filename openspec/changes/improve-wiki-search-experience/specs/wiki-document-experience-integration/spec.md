## MODIFIED Requirements

### Requirement: Selected external document plugins have auditable source provenance

The Wiki SHALL retain the source for each selected external document-experience integration as ordinary files beneath `Wiki/src/`, tracked by the Wiki repository. A tracked manifest SHALL record each upstream repository, initial audited baseline commit, repository path, plugin source path, and expected plugin title. The runtime plugin set SHALL consist of sidebar resizer, focused-tiddler, draw.io, Notion page cover/icon, autocomplete, and command palette; Fira Code SHALL be bundled by the local Angelscript theme. Preview glass, the deprecated `itonnote-plugin`, and the third-party CodeMirror 6 plugin SHALL NOT be installed as runtime dependencies. Imported preview-glass source MAY remain in its audited upstream source snapshot for reference without being declared by the runtime manifest.

#### Scenario: Source provenance is inspected

- **WHEN** a maintainer inspects the Wiki manifest and imported source directories
- **THEN** each selected integration source SHALL identify its upstream SSH repository, initial audited baseline commit, repository path, plugin source path, and expected plugin title where it produces a runtime plugin
- **AND** `$:/themes/linonetwo/itonnote`, `itonnote-plugin`, and `$:/plugins/linonetwo/preview-glass` SHALL NOT be among the active runtime plugins

### Requirement: Standard Wiki commands compile selected external sources reproducibly

The Wiki SHALL provide a generated plugin-source bridge that validates imported repository paths, plugin source paths, and expected plugin titles against the tracked manifest and exposes local plus selected external plugins to the normal development, build, test, and publish commands. The bridge SHALL NOT fetch, update, reset, or change an imported source. During product development, changes made to a validated real plugin source SHALL be mirrored incrementally to its generated plugin directory so the existing development compiler and browser refresh pipeline can hot-reload the change without manually recreating the entire bridge.

#### Scenario: Valid imported sources are prepared

- **WHEN** a maintainer runs a standard Wiki product command with all declared imported source paths available
- **THEN** the command SHALL prepare a generated source root containing the selected external and TDGameStudio plugins
- **AND** plugin-dev SHALL compile from that source root without requiring a network request

#### Scenario: Imported external source is invalid

- **WHEN** an imported source is absent, lacks its expected plugin source directory, or exposes an unexpected plugin title
- **THEN** preparation SHALL fail with a diagnostic identifying that manifest entry
- **AND** preparation SHALL NOT fetch, reset, or otherwise update the imported source

#### Scenario: Maintainer edits an imported plugin during development

- **WHEN** a maintainer adds, changes, or deletes a file beneath a validated real plugin source while a product development command is running
- **THEN** the corresponding file operation SHALL be applied beneath that plugin's generated source directory
- **AND** the existing plugin-dev watcher SHALL receive the generated path change and refresh the running Wiki

## ADDED Requirements

### Requirement: Desktop search uses one compact theme-aligned command surface

The Wiki SHALL use command palette as its primary search surface and SHALL hide the redundant Vanilla sidebar search through the command-palette preference contract. On a desktop viewport, the command palette SHALL appear as a centered surface no wider than 720px or the viewport minus 48px, with a theme-aligned input, focus treatment, result panel, selected state, and restrained backdrop. The result panel SHALL remain bounded within the viewport and SHALL scroll internally when its content exceeds the available height.

#### Scenario: Reader opens search on desktop

- **WHEN** a reader opens command palette with the supported keyboard shortcut on a 1440px-wide viewport
- **THEN** the search input and results SHALL be centered and SHALL NOT expand beyond 720px
- **AND** the Vanilla sidebar search SHALL not be displayed
- **AND** focus, border, background, shadow, and selected-result styling SHALL use the local Angelscript light-theme treatment

#### Scenario: Reader opens search on a narrow screen

- **WHEN** a reader opens command palette on a narrow viewport
- **THEN** the search controls and results SHALL remain inside the viewport without horizontal document overflow
- **AND** the existing command-palette search behavior SHALL remain usable
