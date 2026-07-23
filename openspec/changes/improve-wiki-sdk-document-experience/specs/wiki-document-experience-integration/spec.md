## ADDED Requirements

### Requirement: The Wiki preserves the localized core sidebar layout

The Wiki SHALL retain the TiddlyWiki core Open, Recent, Tools, and More tabs as its desktop sidebar layout, SHALL use the core Open tab default, SHALL leave visible sidebar captions to the active TiddlyWiki language pack rather than hard-coding English labels, and SHALL restore the reference Wiki's wide compact PC geometry without changing the accepted light palette.

#### Scenario: Reader opens the Wiki without a saved sidebar override

- **WHEN** the Wiki starts at its default documentation entry point
- **THEN** the sidebar SHALL select `$:/core/ui/SideBar/Open`
- **AND** the four core TiddlyWiki sidebar tabs SHALL remain reachable
- **AND** no custom documentation sidebar tab SHALL be loaded

#### Scenario: Reader changes the Wiki language

- **WHEN** the active `$:/language` changes
- **THEN** the core sidebar SHALL continue to obtain its visible captions from TiddlyWiki language resources
- **AND** the theme SHALL NOT force an English sidebar label

#### Scenario: Reader uses a desktop viewport

- **WHEN** the Wiki renders at a desktop width at or above the configured sidebar breakpoint
- **THEN** the sidebar width SHALL resolve from `clamp(320px, 31vw, 600px)`
- **AND** a 1280px viewport SHALL resolve to approximately 397px while a 2048px viewport SHALL stop at 600px
- **AND** core sidebar tab labels SHALL size to their localized content instead of inheriting a generic 32px minimum width
- **AND** the accepted light colors, hover feedback, keyboard focus, plugin inventory, and mobile sidebar behavior SHALL remain unchanged

#### Scenario: Reader uses the desktop page-control toolbar

- **WHEN** the SDK Wiki renders its page controls on desktop
- **THEN** the visible controls SHALL be Home, More actions, new tiddler, new Markdown, control panel, and draw.io in that order, expressed through the native `$:/tags/PageControls` list field
- **AND** each toolbar control SHALL use natural approximately 21×25px geometry rather than a forced 32×32px minimum
- **AND** save, sidebar Command Palette, new journal, refresh, layout, and advanced search SHALL be hidden through `$:/config/PageControlButtons/Visibility/<full-button-title>` tiddlers
- **AND** Batch, SCM, filter-builder, and other unregistered RefWiki plugin controls SHALL NOT be added

### Requirement: SDK documents expose friendly identity and local orientation

SDK tiddlers with presentation metadata SHALL display a friendly heading, canonical-title breadcrumb, and optional description without adding a generated or author-maintained in-page TOC card.

#### Scenario: Reader opens a metadata-enabled SDK tiddler

- **WHEN** an SDK tiddler provides a caption and description
- **THEN** the visible heading SHALL use the caption
- **AND** the canonical tiddler title SHALL remain visible as a breadcrumb or equivalent orientation cue
- **AND** the description SHALL use regular-weight, subordinate but legible typography aligned to the document content measure
- **AND** the title/description spacing SHALL remain stable when the description wraps

#### Scenario: Reader opens the long AngelScript examples page

- **WHEN** the reader opens `AngelscriptCodeExamples`
- **THEN** the example groups SHALL appear in normal document flow
- **AND** no `.as-page-toc` surface or TOC navigation startup module SHALL be present

### Requirement: Command palette idle state prioritizes navigation

An empty command palette SHALL prioritize useful recent or open documentation choices and a concise help affordance; the complete syntax help SHALL appear only after the explicit help prefix.

#### Scenario: Reader opens the command palette

- **WHEN** the command palette opens with an empty query
- **THEN** it SHALL NOT render the complete command syntax guide as the primary content
- **AND** it SHALL provide useful document navigation choices or a concise empty-state explanation

#### Scenario: Reader requests command help

- **WHEN** the reader enters the `?` help prefix
- **THEN** the complete command-palette help source SHALL remain available

### Requirement: SDK runtime excludes the Notion cover and icon surface

The Wiki SHALL NOT package or load `$:/plugins/Gk0Wk/notionpage-covericon`, SHALL NOT inject its add-icon or add-cover ViewTemplate controls, and SHALL preserve TiddlyWiki core icon resources and the separately registered draw.io diagram capability.

#### Scenario: Reader opens a normal SDK document

- **WHEN** a reader opens a metadata-enabled or ordinary SDK tiddler
- **THEN** no notionpage-covericon author action or presentation surface SHALL be present
- **AND** the title, breadcrumb, optional description, and normal TiddlyWiki toolbar icons SHALL remain available

#### Scenario: Build prepares external document plugins

- **WHEN** the external-plugin bridge and offline library are built
- **THEN** they SHALL exclude `$:/plugins/Gk0Wk/notionpage-covericon`
- **AND** they SHALL retain the registered draw.io, sidebar-resizer, and focused-tiddler plugin titles

### Requirement: Published documentation contains no known stale home link

The Wiki home tiddler SHALL not expose a known missing link for a tutorial or document that is not included in the published Wiki.

#### Scenario: Reader opens the Wiki home

- **WHEN** the home tiddler renders
- **THEN** the published primary links SHALL resolve to existing tiddlers or deliberate external destinations

### Requirement: Imported plugin source has an explicit editable vendor boundary

Imported plugin repositories SHALL live under tracked `vendor/` paths rather than the TDGameStudio-owned `src/` tree, SHALL remain editable, and SHALL continue to participate in manifest-driven preparation, development watching, typechecking for enabled runtime plugins, and product builds.

#### Scenario: Maintainer edits an enabled vendor plugin

- **WHEN** a maintainer changes a source file inside a vendor repository registered by `external-plugins.json`
- **THEN** the development watcher SHALL mirror that change into the generated plugin-source bridge
- **AND** product preparation and builds SHALL consume the vendor path without a network update

#### Scenario: Maintainer runs the complete lint gate

- **WHEN** `lint:all` runs
- **THEN** locally owned source, scripts, and browser tests SHALL use the repository's full lint policy
- **AND** vendor source SHALL use a separate bounded correctness audit
- **AND** prebuilt `files/lib/**` and minified JavaScript SHALL NOT be type-aware lint inputs
