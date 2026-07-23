## MODIFIED Requirements

### Requirement: Standalone Angelscript theme package

The Wiki project SHALL provide a buildable TiddlyWiki theme titled `$:/themes/angelscript` under `Wiki/src/angelscript-theme/`, with `plugin-type` set to `theme` and a dependency on `$:/themes/tiddlywiki/vanilla`. Its visual source SHALL remain a TDGameStudio-maintained migration of the reviewed itonnote theme and SHALL bundle the required Fira Code stylesheet. The theme SHALL be compiled into the integrated Wiki product and SHALL NOT require publishing a standalone plugin package.

#### Scenario: Local migrated theme builds into the product

- **WHEN** `pnpm run build:wiki` runs in `Wiki/`
- **THEN** the offline Wiki SHALL contain `$:/themes/angelscript`
- **AND** the theme SHALL retain the Vanilla dependency metadata and bundled Fira Code stylesheet
- **AND** no standalone theme JSON package or plugin library SHALL be retained

### Requirement: Angelscript visual theme

The local Angelscript theme SHALL provide modular document styling with semantic tokens, readable text, visible keyboard focus, document-oriented left-sidebar and tiddler presentation, compatible generic code styling, and responsive behavior derived from the configured sidebar breakpoint.

#### Scenario: Migrated theme styles are active

- **WHEN** the development Wiki selects `$:/themes/angelscript`
- **THEN** the accepted left sidebar, story river, tiddlers, SDK documents, controls, links, code blocks, editors, and More panel SHALL remain renderable
- **AND** keyboard focus SHALL not be globally suppressed
- **AND** the existing sidebar segments SHALL remain available

### Requirement: Theme defaults use plugin shadow tiddlers

Stable Wiki defaults and feature preferences SHALL be stored under `Wiki/src/angelscript-wiki-config/` as plugin tiddlers, browser interaction behavior SHALL be stored under `Wiki/src/angelscript-tools/`, and visual behavior SHALL be stored under `Wiki/src/angelscript-theme/`. Wiki-local `$__*.tid` files SHALL remain limited to approved runtime state, favicon assets, filesystem bootstrap configuration, and explicitly reviewed core patches.

#### Scenario: Product configuration is packaged

- **WHEN** the Wiki configuration, tools, and theme plugins are compiled
- **THEN** each concern SHALL be provided by its owning plugin
- **AND** the Wiki system directory SHALL not contain unowned serialized runtime plugins or duplicate packaged defaults

### Requirement: Publish paths include the theme

The Wiki product build SHALL include the local Angelscript theme, selected document-experience plugins, official Highlight, TDGameStudio tools, and Wiki configuration without requiring manual copying or building a plugin library.

#### Scenario: Offline product build

- **WHEN** `pnpm run build:wiki` runs with validated product sources
- **THEN** the generated offline Wiki SHALL contain the approved theme, palette, document integrations, Highlight, tools, and configuration
- **AND** it SHALL NOT contain the upstream itonnote runtime theme or standalone plugin packages
- **AND** the existing Wiki documentation and core sidebar SHALL remain renderable

