# angelscript-wiki-theme Specification

## Purpose
TBD - created by archiving change feature-tw-angelscript-theme. Update Purpose after archive.
## Requirements
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

The local Angelscript theme SHALL provide modular itonnote-derived document styling and the Notion palette with readable text, visible focus states, document-oriented left-sidebar and tiddler presentation, compatible generic code styling, and responsive behavior derived from the configured sidebar breakpoint. On desktop it SHALL use the selected compact-control-rail layout with a persistent native-icon control rail, a quiet always-present resize seam that strengthens on hover and active drag, one More-sidebar content divider clearly separated from its category controls, and compact spacing only between SDK description and tags without changing title, description, tag, body order or the normal tag-to-body reading break. Narrow layouts SHALL retain the existing left drawer and mobile PageControls instead of the desktop rail.

#### Scenario: Migrated theme styles are active

- **WHEN** the development Wiki selects `$:/themes/angelscript`
- **THEN** the accepted left sidebar, story river, tiddlers, SDK documents, controls, links, code blocks, editors, and More panel SHALL receive the migrated document styling
- **AND** the existing sidebar segments SHALL remain available
- **AND** the `40px` production control rail SHALL keep native TiddlyWiki and enabled-plugin button tiddlers as its behavior layer while using product-scoped line-icon tiddlers as its visual layer
- **AND** its bottom utility zone SHALL contain only Language above Control Panel, with no independent Palette button
- **AND** the five main sidebar tabs SHALL match the selected compact preview without using a selected border that changes button layout
- **AND** an idle sidebar resize target SHALL show a quiet boundary while hover and active drag SHALL provide progressively stronger feedback
- **AND** the More-sidebar SHALL show a single content divider that does not overlap its category controls
- **AND** an SDK document with tags and a description SHALL retain one compact tag group after its description and before its body
- **AND** standalone sidebar experiment fixtures and Unicode icon placeholders SHALL not be copied into the production runtime

#### Scenario: Expanded desktop panels preserve live Wiki behavior

- **WHEN** Open, Recent, Tools, More/Tags, or AS is selected in the production desktop sidebar
- **THEN** the panel SHALL use the selected 03 hierarchy and compact styling
- **AND** its items, counts, current state, configuration, actions, or navigation SHALL still derive from live TiddlyWiki tiddlers, filters, widgets, messages, and state
- **AND** no representative preview item, simulated timestamp, or standalone preview script SHALL enter the production runtime

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

### Requirement: Desktop controls expose coherent interaction states

The Angelscript Wiki theme SHALL render interactive desktop controls with stable hit targets and visually distinguish default, hover, pressed, selected, and keyboard-focus states while retaining the accepted light Notion palette.

#### Scenario: Reader points and presses a desktop control

- **WHEN** a desktop reader hovers and presses a sidebar, toolbar, tab, or document control
- **THEN** the control SHALL retain its geometry without movement
- **AND** hover and pressed states SHALL be visually distinguishable from each other and from the default state

#### Scenario: Reader navigates by keyboard

- **WHEN** keyboard navigation places focus on an interactive control or document link
- **THEN** the focused element SHALL expose a visible focus indicator with sufficient contrast
- **AND** focus SHALL NOT depend on hover to become visible

### Requirement: SDK prose remains readable without constraining technical surfaces

The Angelscript Wiki theme SHALL constrain ordinary long-form prose to a readable desktop measure while allowing code cards, preformatted blocks, tables, and explicitly wide technical surfaces to use the document width.

#### Scenario: Reader opens a long SDK page

- **WHEN** a desktop reader opens a long SDK documentation tiddler
- **THEN** ordinary paragraphs and lists SHALL use a bounded readable line length
- **AND** code and table surfaces SHALL remain wide enough for technical content

### Requirement: Document links and title actions remain calm and discoverable

Document links SHALL use text emphasis appropriate for prose rather than blanket bold styling, and title actions SHALL reveal quickly on pointer or keyboard interaction without a long opacity delay.

#### Scenario: Reader interacts with a document link and title toolbar

- **WHEN** a reader hovers a body link or focuses a title action
- **THEN** the link and action SHALL visibly respond without substantially darkening the page
- **AND** title actions SHALL complete their reveal within 160 milliseconds

### Requirement: Sidebar metadata actions remain legible in the light palette

The theme SHALL render the core untagged action as quiet secondary metadata with readable foreground/background contrast and SHALL NOT apply the ordinary dark tag surface to that action.

#### Scenario: Reader opens the Tags section under More

- **WHEN** the reader views the localized untagged action
- **THEN** the action SHALL use `#eef2f7` background, `#5d6b7b` foreground, and a subtle neutral border
- **AND** hover SHALL reuse the existing light blue interaction treatment
- **AND** ordinary tagged-title colors SHALL remain unchanged

### Requirement: The desktop sidebar resize affordance remains stable and restrained

The sidebar resizer SHALL remain aligned to the story/sidebar boundary for the full desktop viewport while sidebar content scrolls, SHALL preserve a forgiving transparent pointer target, and SHALL render a visual rail substantially thinner than its hit area.

#### Scenario: Reader scrolls the long Tools sidebar

- **WHEN** the desktop Tools tab is taller than the viewport and the reader scrolls it vertically
- **THEN** the resize hit area SHALL retain viewport-top and viewport-bottom alignment
- **AND** its visual rail SHALL remain visible for the full viewport height rather than shrinking with `scrollTop`

#### Scenario: Reader discovers and drags the sidebar boundary

- **WHEN** the pointer rests away from, hovers over, and actively drags the sidebar boundary
- **THEN** the hit area SHALL remain at least 10px wide
- **AND** the visual rail SHALL be one pixel at rest and on hover, increasing to two pixels only during active dragging
- **AND** hover and drag SHALL raise contrast without filling the complete hit area with the primary colour
- **AND** the sidebar width SHALL continue to update from pointer movement
