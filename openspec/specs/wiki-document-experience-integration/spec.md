# wiki-document-experience-integration Specification

## Purpose
TBD - created by archiving change refactor-wiki-itonnote-theme-migration. Update Purpose after archive.
## Requirements
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

### Requirement: The Wiki preserves the localized core sidebar layout and AS documentation outline

The Wiki SHALL retain the TiddlyWiki core Open, Recent, Tools, and More tabs, SHALL add a trailing language-neutral `AS` tab that presents the existing bilingual `AS/Navigation` outline, SHALL use the core Open tab default, SHALL leave core sidebar captions to the active TiddlyWiki language pack rather than hard-coding English labels, and SHALL restore the reference Wiki's wide compact PC geometry without changing the accepted light palette.

#### Scenario: Reader opens the Wiki without a saved sidebar override

- **WHEN** the Wiki starts at its default documentation entry point
- **THEN** the sidebar SHALL select `$:/core/ui/SideBar/Open`
- **AND** the four core TiddlyWiki sidebar tabs SHALL remain reachable
- **AND** a fifth `AS` tab SHALL follow the four core tabs without replacing them
- **AND** selecting `AS` SHALL render the existing `AS/Navigation` links as the site-wide documentation outline
- **AND** the legacy `$:/themes/angelscript/sidebar/docs` tab SHALL NOT be loaded

#### Scenario: Reader changes the Wiki language

- **WHEN** the active `$:/language` changes
- **THEN** the core sidebar SHALL continue to obtain its visible captions from TiddlyWiki language resources
- **AND** the theme SHALL NOT force an English sidebar label

#### Scenario: Reader uses a desktop viewport

- **WHEN** the Wiki renders at a desktop width at or above the configured sidebar breakpoint
- **THEN** the sidebar width SHALL resolve from `clamp(320px, 31vw, 600px)`
- **AND** a 1280px viewport SHALL resolve to approximately 397px while a 2048px viewport SHALL stop at 600px
- **AND** core and AS sidebar tab labels SHALL size to their content instead of inheriting a generic 32px minimum width
- **AND** the accepted light colors, hover feedback, keyboard focus, plugin inventory, and mobile sidebar behavior SHALL remain unchanged

#### Scenario: Reader uses the desktop page-control toolbar

- **WHEN** the SDK Wiki renders its page controls on desktop
- **THEN** the visible controls SHALL be Home, More actions, control panel, and language in that order, expressed through the native `$:/tags/PageControls` list field
- **AND** each toolbar control SHALL use natural approximately 21×25px geometry rather than a forced 32×32px minimum
- **AND** new tiddler, new Markdown, draw.io creation, save, sidebar Command Palette, new journal, refresh, layout, and advanced search SHALL be hidden through `$:/config/PageControlButtons/Visibility/<full-button-title>` tiddlers
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

### Requirement: Normal page file drops do not invoke the core importer
The Wiki SHALL replace the page-wide `$dropzone` in `$:/core/ui/PageTemplate` with an ordinary `tc-page-container-inner` layout container. Dropping an external file or cross-Wiki payload over a normal rendered page SHALL NOT invoke the TiddlyWiki `$:/Import` workflow. Explicit core Import controls SHALL remain available.

#### Scenario: A reader drops an external file on a rendered document
- **WHEN** an external file is dropped over the normal page surface
- **THEN** the normal page surface SHALL NOT be rendered as a core `tc-dropzone`
- **AND** the core `$:/Import` workflow SHALL NOT be invoked by that page surface

### Requirement: Core internal drag-to-reorder behavior remains enabled
The Wiki SHALL leave `$:/config/DragAndDrop/Enable` unset and SHALL preserve the default core drag-and-drop enablement for sidebar, tag, and list ordering targets.

#### Scenario: A reader drags an open-sidebar tiddler within the Wiki
- **WHEN** a core Open-sidebar droppable target receives a dragover event
- **THEN** that core target SHALL continue to handle the event as an enabled droppable target

### Requirement: Inactive editor reference snapshots remain outside the Wiki repository

The Wiki repository SHALL NOT track the retired CodeMirror 6 or preview-glass editor source snapshots under `Wiki/vendor/` or `Wiki/src/`. The selected product sources declared by the product manifest SHALL remain the only vendor sources admitted to normal Wiki lint, development, verification, and offline-build workflows. Parent-repository `Reference/` checkouts MAY retain upstream research sources without making them Wiki product dependencies.

#### Scenario: Maintainer inspects retired editor integration boundaries

- **WHEN** a maintainer runs the Wiki source-boundary and offline artifact checks
- **THEN** neither the CodeMirror 6 nor preview-glass vendor directory SHALL be present in the Wiki repository
- **AND** neither corresponding plugin title SHALL be serialized into the offline Wiki artifact

### Requirement: Superseded and unshipped Wiki sources remain absent

The Wiki repository SHALL NOT retain the superseded `vendor/tiddlyseq/src/sidebar-resizer` source snapshot or the unshipped `src/doc` Modern.TiddlyDev tutorial bundle. The selected source manifest SHALL NOT declare the retired sidebar-resizer or Modern.TiddlyDev documentation plugin. The product-owned `src/angelscript-tools/navigation/left-sidebar-resizer.ts` implementation SHALL remain the sole in-repository sidebar-resizing source.

#### Scenario: Maintainer verifies inactive source cleanup

- **WHEN** a maintainer runs the Wiki source-boundary and product-source checks
- **THEN** the vendor sidebar-resizer and `src/doc` directories SHALL be absent
- **AND** the product manifest SHALL contain no `sidebar-resizer` or `doc` entry
- **AND** the product-owned left-sidebar resizer source SHALL be present
