## ADDED Requirements

### Requirement: Selected external document plugins have auditable source provenance

The Wiki SHALL retain the source for each selected external document-experience integration as ordinary files beneath `Wiki/src/`, tracked by the Wiki repository. A tracked manifest SHALL record each upstream repository, initial audited baseline commit, repository path, plugin source path, and expected plugin title. The runtime plugin set SHALL consist of sidebar resizer, focused-tiddler, autocomplete, command palette, and preview glass; Fira Code SHALL be bundled by the local Angelscript theme. The deprecated `itonnote-plugin` and the third-party CodeMirror 6 plugin SHALL NOT be installed as runtime dependencies.

#### Scenario: Source provenance is inspected

- **WHEN** a maintainer inspects the Wiki manifest and imported source directories
- **THEN** each selected integration source SHALL identify its upstream SSH repository, initial audited baseline commit, repository path, plugin source path, and expected plugin title where it produces a runtime plugin
- **AND** `$:/themes/linonetwo/itonnote` and `itonnote-plugin` SHALL NOT be among the active runtime plugins

### Requirement: Standard Wiki commands compile selected external sources reproducibly

The Wiki SHALL provide a generated plugin-source bridge that validates imported repository paths, plugin source paths, and expected plugin titles against the tracked manifest and exposes local plus selected external plugins to the normal development, build, test, and publish commands. The bridge SHALL NOT fetch, update, reset, or change an imported source.

#### Scenario: Valid imported sources are prepared

- **WHEN** a maintainer runs a standard Wiki product command with all declared imported source paths available
- **THEN** the command SHALL prepare a generated source root containing the selected external and TDGameStudio plugins
- **AND** plugin-dev SHALL compile from that source root without requiring a network request

#### Scenario: Imported external source is invalid

- **WHEN** an imported source is absent, lacks its expected plugin source directory, or exposes an unexpected plugin title
- **THEN** preparation SHALL fail with a diagnostic identifying that manifest entry
- **AND** preparation SHALL NOT fetch, reset, or otherwise update the imported source

### Requirement: Legacy document preferences are retained without importing personal workspace features

The Wiki configuration SHALL retain Chinese language, zoom view, zero animation duration, a 320px initial Vanilla sidebar width, hidden advanced-search, command-palette, layout, refresh, and save-wiki toolbar controls, plus the reviewed Markdown More preference values for admonition style and table-of-contents presentation. It SHALL port mobile navigation sidebar close behavior and opt-in bottom page controls without importing journal, notebook, graph, synchronization, or personal workspace behavior.

#### Scenario: Reader uses the document experience on mobile

- **WHEN** a narrow-screen reader navigates through a tiddler link
- **THEN** the normal TiddlyWiki sidebar state SHALL close after navigation
- **AND** opt-in bottom page controls SHALL remain reachable without obscuring story content

### Requirement: Standard Markdown rendering is available without enabling unselected extensions

The Wiki SHALL enable the bundled official TiddlyWiki Markdown plugin so `text/markdown` tiddlers are rendered. It SHALL retain the reviewed Markdown More settings in the TDGameStudio configuration plugin, but SHALL NOT enable Markdown More, Mermaid, Relink, or the stale `markdown-transformer` reference unless separately selected.

#### Scenario: A standard Markdown tiddler is loaded

- **WHEN** a reader opens a `text/markdown` tiddler
- **THEN** the official `$:/plugins/tiddlywiki/markdown` plugin SHALL be present
- **AND** the retained Markdown More values SHALL be available as configuration tiddlers without activating Markdown More behavior
