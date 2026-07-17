# angelscript-wiki-theme Specification

## Purpose
TBD - created by archiving change feature-tw-angelscript-theme. Update Purpose after archive.
## Requirements
### Requirement: Standalone Angelscript theme package

The Wiki project SHALL provide a buildable TiddlyWiki theme plugin titled `$:/themes/angelscript` under `Wiki/src/angelscript-theme/`, with `plugin-type` set to `theme` and a dependency on `$:/themes/tiddlywiki/vanilla`.

#### Scenario: Theme plugin build

- **WHEN** `pnpm run build` runs in `Wiki/`
- **THEN** the build SHALL emit a JSON plugin artifact for `$:/themes/angelscript`
- **AND** the artifact SHALL retain the theme type and Vanilla dependency metadata

### Requirement: Theme-owned compatibility configuration

The theme package SHALL contain the source for the sidebar layout value currently required under `$:/themes/tiddlywiki/vanilla/options/sidebarlayout`, and the Wiki SHALL NOT keep a duplicate project-local system tiddler for that value.

#### Scenario: Compatibility setting is packaged

- **WHEN** the theme plugin is built
- **THEN** its plugin payload SHALL contain `$:/themes/tiddlywiki/vanilla/options/sidebarlayout` with the `fluid-fixed` value
- **AND** `Wiki/wiki/tiddlers/system/$__themes_tiddlywiki_vanilla_options_sidebarlayout.tid` SHALL be absent

### Requirement: Angelscript visual theme

The theme SHALL provide a stylesheet and palette using a dark editor-oriented visual baseline with readable text, visible focus states, blue interactive accents, and amber code/highlight accents.

#### Scenario: Theme styles are active

- **WHEN** the development Wiki selects `$:/themes/angelscript`
- **THEN** the page, story river, tiddlers, sidebar, controls, links, code blocks, and editors SHALL receive Angelscript theme styling
- **AND** the existing sidebar segments SHALL remain available

### Requirement: Development Wiki default selection

The Wiki distribution SHALL provide a regular configuration plugin with a shadow tiddler titled `$:/theme` whose default text is `$:/themes/angelscript`, and SHALL provide a guarded browser startup action that selects the packaged Angelscript palette while retaining the existing dark-mode startup behavior.

#### Scenario: Wiki starts with Angelscript theme

- **WHEN** the development Wiki starts without a user override
- **THEN** `$:/theme` SHALL resolve to `$:/themes/angelscript`
- **AND** `$:/palette` SHALL resolve to the Angelscript palette for the active light/dark mode path
- **AND** the startup action SHALL be loaded from the Wiki configuration plugin rather than a Wiki-local `$__*.tid` file

### Requirement: Theme defaults use plugin shadow tiddlers

Stable Wiki defaults and startup behavior SHALL be stored under `Wiki/src/angelscript-wiki-config/` as plugin tiddlers, while Wiki-local `$__*.tid` files SHALL remain limited to runtime state, external plugin data, favicon assets, and filesystem bootstrap configuration.

#### Scenario: Theme configuration is packaged

- **WHEN** the Wiki configuration plugin is built
- **THEN** its payload SHALL include `$:/theme`, `$:/SiteTitle`, `$:/SiteSubtitle`, `$:/DefaultTiddlers`, the CPL startup default, and the guarded browser startup action
- **AND** the Wiki system directory SHALL not contain separate files for those packaged defaults

### Requirement: Publish paths include the theme

The existing plugin and Wiki publishing commands SHALL include the Angelscript theme without requiring manual copying.

#### Scenario: Online and offline publishing

- **WHEN** `pnpm run publish` or `pnpm run publish:offline` runs in `Wiki/`
- **THEN** the generated output SHALL contain the Angelscript theme and a Wiki that selects it by default
- **AND** the existing Wiki documentation and core sidebar SHALL remain renderable
