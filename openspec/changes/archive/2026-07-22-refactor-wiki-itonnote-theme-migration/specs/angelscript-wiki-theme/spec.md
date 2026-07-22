## MODIFIED Requirements

### Requirement: Standalone Angelscript theme package

The Wiki project SHALL provide a buildable TiddlyWiki theme plugin titled `$:/themes/angelscript` under `Wiki/src/angelscript-theme/`, with `plugin-type` set to `theme` and a dependency on `$:/themes/tiddlywiki/vanilla`. Its visual source SHALL be a TDGameStudio-maintained migration of the reviewed itonnote theme source and it SHALL bundle the required Fira Code stylesheet. The Wiki SHALL NOT enable the upstream `$:/themes/linonetwo/itonnote` theme or `$:/plugins/linonetwo/fira-code-font` as runtime dependencies.

#### Scenario: Local migrated theme builds

- **WHEN** `pnpm run build` runs in `Wiki/`
- **THEN** the build SHALL emit a JSON plugin artifact for `$:/themes/angelscript`
- **AND** the artifact SHALL retain the theme type and Vanilla dependency metadata
- **AND** the artifact SHALL contain the migrated itonnote document styling and `$:/themes/angelscript/firacode.css` without packaging `$:/themes/linonetwo/itonnote` or `$:/plugins/linonetwo/fira-code-font`

### Requirement: Theme-owned compatibility configuration

The local Angelscript theme package SHALL contain the migrated source for the Vanilla sidebar layout value under `$:/themes/tiddlywiki/vanilla/options/sidebarlayout`, and the Wiki SHALL NOT keep a duplicate project-local system tiddler for that value.

#### Scenario: Compatibility setting is packaged

- **WHEN** the local Angelscript theme plugin is built
- **THEN** its plugin payload SHALL contain `$:/themes/tiddlywiki/vanilla/options/sidebarlayout` with the `fluid-fixed` value
- **AND** `Wiki/wiki/tiddlers/system/$__themes_tiddlywiki_vanilla_options_sidebarlayout.tid` SHALL be absent

### Requirement: Angelscript visual theme

The local Angelscript theme SHALL provide the itonnote-derived document styling and the Notion palette with readable text, visible focus states, document-oriented sidebar and tiddler presentation, and compatible generic code styling.

#### Scenario: Migrated theme styles are active

- **WHEN** the development Wiki selects `$:/themes/angelscript`
- **THEN** the page, story river, tiddlers, sidebar, controls, links, code blocks, and editors SHALL receive the migrated document styling
- **AND** the existing sidebar segments SHALL remain available

### Requirement: Development Wiki default selection

The Wiki distribution SHALL provide a regular configuration plugin with shadow tiddlers that default `$:/theme` to `$:/themes/angelscript` and `$:/palette` to `$:/palettes/Notion`. The default palette SHALL remain Notion light regardless of browser or operating-system color preference, and the distribution SHALL NOT install a browser startup action that changes the theme or palette.

#### Scenario: Wiki starts with local document defaults

- **WHEN** the development Wiki starts without a user override
- **THEN** `$:/theme` SHALL resolve to `$:/themes/angelscript`
- **AND** `$:/palette` SHALL resolve to `$:/palettes/Notion` for both light and dark operating-system preferences
- **AND** no configuration startup module SHALL change either value

### Requirement: Theme defaults use plugin shadow tiddlers

Stable Wiki defaults and feature preferences SHALL be stored under `Wiki/src/angelscript-wiki-config/` as plugin tiddlers, while browser-only document behavior SHALL be stored under `Wiki/src/angelscript-tools/`. Wiki-local `$__*.tid` files SHALL remain limited to runtime state, external plugin data, favicon assets, and filesystem bootstrap configuration.

#### Scenario: Document configuration is packaged

- **WHEN** the Wiki configuration and tools plugins are built
- **THEN** their payloads SHALL include the local selected theme and palette, site defaults, legacy document preferences, and TDGameStudio-owned mobile page-control configuration
- **AND** the Wiki system directory SHALL not contain duplicate packaged defaults or an adaptive theme startup action

### Requirement: Publish paths include the theme

The existing plugin and Wiki publishing commands SHALL include the local migrated Angelscript theme, the selected document-experience plugins, official Highlight, TDGameStudio tools, and the Wiki configuration without requiring manual copying.

#### Scenario: Online and offline publishing

- **WHEN** `pnpm run publish` or `pnpm run publish:offline` runs in `Wiki/` with validated external repository sources
- **THEN** the generated output SHALL contain `$:/themes/angelscript`, the Notion palette, selected document plugins, and official Highlight
- **AND** it SHALL NOT contain the upstream `$:/themes/linonetwo/itonnote` runtime theme
- **AND** the existing Wiki documentation and core sidebar SHALL remain renderable
