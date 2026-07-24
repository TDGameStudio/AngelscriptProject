## ADDED Requirements

### Requirement: Sidebar resize boundary is stable without shrinking its interaction target

On desktop, AngelscriptWiki SHALL keep the product-owned sidebar resizer's full-height pointer target and resize behavior while rendering a persistent quiet boundary at rest. The boundary SHALL strengthen on hover and SHALL be more prominent while dragging.

#### Scenario: Idle desktop sidebar has a quiet visible resize seam

- **WHEN** a desktop-width Wiki page renders with the sidebar open and the resize target is neither hovered nor active
- **THEN** the resize target SHALL remain present, fixed, full-height, and at least 10px wide
- **AND** its visible pseudo-element SHALL render one low-contrast seam rather than have zero opacity

#### Scenario: Hover and drag communicate resize affordance

- **WHEN** the pointer hovers over the desktop resize target
- **THEN** the seam SHALL strengthen without changing the target geometry
- **AND** WHEN dragging begins
- **THEN** the seam SHALL be more prominent than its hover state and the sidebar width SHALL remain adjustable

#### Scenario: Keyboard user resizes the sidebar

- **WHEN** keyboard focus is on the desktop resize separator
- **THEN** ArrowLeft and ArrowRight SHALL adjust the width in bounded increments
- **AND** Home and End SHALL select the effective minimum and maximum
- **AND** separator ARIA value attributes SHALL remain synchronized with the rendered width

### Requirement: More sidebar content divider does not overlap category navigation

The More-sidebar SHALL retain a single clear divider between its secondary category navigation and content panel without placing that divider over the category controls. The category list SHALL retain selected, hover, and keyboard-focus feedback.

#### Scenario: More category list retains a separated content divider

- **WHEN** a user opens the More sidebar on a desktop-width Wiki page
- **THEN** its secondary category tab buttons SHALL have no right border
- **AND** its vertical More content panel SHALL retain its single left divider
- **AND** that divider SHALL be separated from the category-column bounds rather than overlapping a category button
- **AND** the selected category SHALL remain visually identifiable
- **AND** keyboard focus on a category button SHALL remain visible

### Requirement: SDK document metadata spacing remains compact without reordering

For tiddlers marked `as-sdk-document: yes`, the view SHALL preserve its existing title, description, tag metadata, body order. The theme SHALL reduce the excessive empty interval between the description and tag group while preserving the existing normal reading separation between tags and body. Tiddlers without that field SHALL retain the standard TiddlyWiki metadata presentation.

#### Scenario: SDK tag spacing is compact and order is unchanged

- **WHEN** an SDK document has both tags and a description
- **THEN** exactly one tag wrapper SHALL render after the SDK description and before the body
- **AND** the description-to-tag spacing SHALL be visually compact without overlap
- **AND** the tag-to-body spacing SHALL remain a distinct reading break

#### Scenario: Ordinary tiddlers retain standard tag spacing and placement

- **WHEN** a tiddler is not marked `as-sdk-document: yes`
- **THEN** the theme SHALL not alter its core tags ViewTemplate, metadata order, or tag spacing

### Requirement: Visual refinements remain narrowly recorded

Each subsequent visual or interaction refinement added to this change SHALL state its user-visible intent, affected theme or plugin source, and focused verification coverage. Changes outside AngelscriptWiki visual presentation or interaction feedback SHALL use a separate OpenSpec change.

#### Scenario: A later refinement is appended to this change

- **WHEN** a later request concerns a small AngelscriptWiki layout, spacing, divider, control-state, or information-hierarchy correction
- **THEN** its record SHALL be added to this change before implementation
- **AND** its verification SHALL identify a focused browser scenario or equivalent targeted check

### Requirement: Left-sidebar alternatives remain independently previewable before selection

Before a new left-sidebar visual system is applied to the production Wiki, AngelscriptWiki SHALL provide three independent standalone HTML previews that preserve the accepted light document theme and use identical representative Wiki content. Each preview SHALL demonstrate its own sidebar boundary, toggle placement, and resize affordance without requiring a network connection, shared runtime asset, or packaged TiddlyWiki plugin.

#### Scenario: Reviewer opens any sidebar alternative directly

- **WHEN** a reviewer opens one preview file directly from disk
- **THEN** its sidebar, controls, representative home tiddler, and inline icons SHALL render without an HTTP server or remote request
- **AND** its text fixture SHALL match the other two preview files
- **AND** the production Wiki theme source SHALL remain unchanged

#### Scenario: Reviewer exercises desktop sidebar behavior

- **WHEN** a reviewer opens, closes, drags, or keyboard-resizes a preview sidebar at desktop width
- **THEN** the sidebar and document SHALL remain aligned without horizontal overflow
- **AND** the width SHALL remain between `240px` and `min(520px, 40vw)`
- **AND** the resize affordance SHALL remain perceptible at rest instead of introducing an otherwise absent full-height line only on hover
- **AND** the open control SHALL remain visible and keyboard focus SHALL remain identifiable

#### Scenario: Preview falls back to the narrow drawer

- **WHEN** a preview is rendered at a narrow viewport
- **THEN** the sidebar SHALL behave as a left drawer
- **AND** the desktop resize target SHALL be hidden
- **AND** the toggle SHALL remain visible without moving the document canvas

### Requirement: Sidebar preview selection gates production migration

The standalone sidebar alternatives SHALL be treated as review artifacts. Production TiddlyWiki theme, template, and resize implementation files SHALL NOT be changed as part of the preview phase. A later implementation pass SHALL record the selected alternative or explicitly chosen combination before altering production behavior.

#### Scenario: Preview phase reaches its review checkpoint

- **WHEN** all three preview files and their focused browser coverage pass
- **THEN** the change SHALL pause for visual selection
- **AND** no preview SHALL be silently promoted to the production theme
- **AND** no plugin package SHALL be published or distributed

### Requirement: Preferred compact-rail preview exercises real sidebar information architecture

The compact-control-rail preview SHALL provide operable Open, Recent, Tools, More, and AS panels that preserve the meaning of the corresponding TiddlyWiki surfaces while adapting their density to the compact left sidebar. Its persistent control rail SHALL provide production-reference selected, hover, pressed, focus, separator, tooltip, and collapsed states.

#### Scenario: Reviewer switches main sidebar panels

- **WHEN** a reviewer selects any main sidebar tab with pointer or keyboard input
- **THEN** exactly one associated panel SHALL be visible
- **AND** the selected tab SHALL expose `aria-selected="true"`
- **AND** switching panels SHALL not alter the representative main tiddler

#### Scenario: Reviewer exercises refined panel content

- **WHEN** the reviewer opens Recent, Tools, More, or AS
- **THEN** Open SHALL show multiple representative open tiddlers with one current item, per-item close controls, a live count, and a close-all action
- **AND** Recent SHALL show grouped representative document history
- **AND** Tools SHALL preserve the original visibility-checkbox, page-control button, and description row structure while improving only its density, spacing, color, hover, and focus presentation
- **AND** More SHALL preserve the original vertical category column, one separated divider, and adjacent content panel while switching the real TiddlyWiki category taxonomy without horizontal sidebar overflow
- **AND** AS SHALL expose collapsible user and maintainer navigation groups with a visible current item

#### Scenario: Reviewer inspects the control rail

- **WHEN** the compact sidebar is open or closed
- **THEN** its `40px` control rail SHALL remain visible
- **AND** its top toggle, primary actions, bottom utility actions, separators, accessible labels, and interaction states SHALL remain identifiable
- **AND** hover or keyboard focus SHALL reveal a right-side text tooltip without shifting layout

#### Scenario: Reviewer opens page-level and tiddler-level More menus

- **WHEN** the reviewer activates the page-control More action
- **THEN** a keyboard-operable sample of the current page-level action menu SHALL appear with representative add, search, close-all, import, management, and palette actions
- **AND** WHEN the reviewer activates More in the representative tiddler's view toolbar
- **THEN** a distinct keyboard-operable item-level action menu SHALL appear with representative information, copy, export, delete, permalink, close-other, and fold actions
- **AND** the tiddler view toolbar SHALL retain the current More, Edit, Close, and New Diagram action set
- **AND** Escape SHALL close either menu and restore focus to its invoking control

### Requirement: Selected compact control rail is the production desktop default

The production AngelscriptWiki desktop layout SHALL adapt the selected compact-control-rail preview through native TiddlyWiki PageTemplate and toolbar extension points. The rail SHALL use real PageControl button tiddlers for behavior and product-scoped line-icon tiddlers for presentation, preserve live sidebar and ViewToolbar behavior, and SHALL NOT copy preview fixtures, Unicode menu glyphs, or simulated popup scripts.

#### Scenario: Desktop Wiki renders the selected rail

- **WHEN** the Angelscript theme renders at or above the configured sidebar breakpoint
- **THEN** a `40px` control rail SHALL occupy the left edge within a `264px` default total sidebar width
- **AND** the core sidebar content SHALL begin after the rail
- **AND** the story river SHALL begin after the total sidebar width
- **AND** the rail SHALL expose native Home, More, New Tiddler, and Command Palette primary controls
- **AND** its bottom utility zone SHALL expose Language above Control Panel and SHALL NOT expose Palette as an independent rail control
- **AND** Home SHALL use the selected preview state only while the focused tiddler is `AngelscriptWikiHome`

#### Scenario: Bottom utility controls preserve native behavior

- **WHEN** the reviewer activates Language in the desktop rail
- **THEN** its native language menu SHALL open beside the rail and remain within the viewport
- **WHEN** the reviewer activates Control Panel
- **THEN** `$:/ControlPanel` SHALL open as the native focused tiddler
- **AND** Control Panel SHALL receive the rail selected presentation without introducing a settings popup

#### Scenario: Desktop sidebar is collapsed

- **WHEN** `$:/state/sidebar` is `no`
- **THEN** the core sidebar content and resize target SHALL be hidden
- **AND** the `40px` rail and core sidebar toggle SHALL remain visible
- **AND** the story river SHALL begin after the persistent rail

#### Scenario: Native sidebar and toolbar surfaces are refined

- **WHEN** the reviewer uses Open, Recent, Tools, More, AS, page-level More, or tiddler-level More
- **THEN** each surface SHALL use its real TiddlyWiki data, widgets, actions, popup state, and SVG icons
- **AND** the Open, Recent, Tools, More, and AS main tab row SHALL use the selected preview's height, gap, text states, and non-layout-shifting underline
- **AND** Tools SHALL retain checkbox/button/description rows
- **AND** More SHALL retain its vertical category column and separated content divider
- **AND** the tiddler toolbar SHALL retain the current More, Edit, Close, and New Diagram direct action set

#### Scenario: Narrow viewport preserves the existing product navigation

- **WHEN** the viewport is below the configured sidebar breakpoint
- **THEN** the desktop control rail and resize separator SHALL be hidden
- **AND** the existing left drawer, compact top-left toggle, and enabled bottom mobile PageControls SHALL remain available

### Requirement: Expanded compact-rail panels remain TiddlyWiki-native

The production Open, Recent, Tools, More/Tags, and AS panels SHALL reproduce the selected 03 information hierarchy without replacing live Wiki state with standalone-preview fixtures. Product shadow tiddlers MAY refine panel markup where CSS cannot express the reviewed hierarchy, but SHALL preserve the corresponding core filters, widgets, messages, configuration, and extension points.

#### Scenario: Open reflects the live story

- **WHEN** `$:/StoryList` changes while the Open panel is visible
- **THEN** its item rows, count, current treatment, and empty state SHALL update from the live story list
- **AND** item close and close-all controls SHALL send the native TiddlyWiki close messages
- **AND** the storyview, droppable, insert-before, and drag/drop contexts SHALL remain present

#### Scenario: Recent reflects real session history

- **WHEN** `$:/HistoryList` contains regular tiddler visits, duplicates, and system or missing titles
- **THEN** Recent SHALL show unique existing regular tiddlers in newest-first order
- **AND** the first five SHALL be grouped as “本次访问” and the remainder as “较早”
- **AND** current state and optional metadata SHALL come from real fields
- **AND** the panel SHALL NOT invent elapsed-time labels

#### Scenario: Tools remains extensible

- **WHEN** the Tools panel renders with the configured common-control list and additional `$:/tags/PageControls` shadows or tiddlers
- **THEN** the sixteen common controls SHALL retain their declared order, native visibility checkboxes, action tiddlers, and descriptions
- **AND** every remaining current or future PageControl SHALL appear in a collapsible “其他工具” group
- **AND** a product icon mapping or generic fallback MAY decorate the native action without replacing it

#### Scenario: More and AS retain their native control planes

- **WHEN** the reviewer opens More/Tags or the AS navigation panel
- **THEN** More SHALL retain the eleven native secondary categories, one separated divider, the core all-tags filter, tag templates, untagged template, and tag-manager action
- **AND** AS SHALL expose user and maintainer groups whose expanded and current states are backed by TiddlyWiki state/history tiddlers
- **AND** both panels SHALL remain keyboard-operable and free of standalone-preview state scripts

### Requirement: Selected compact reference owns the final sidebar type and icon tokens

After production selection, the comparison directory SHALL retain `03-compact-control-rail.html` as the single standalone sidebar reference. Production SHALL apply its compact Tools and More typography through panel-scoped rules, SHALL use a single product line chevron over the native desktop sidebar show/hide control, and SHALL omit decorative file glyphs from Open rows and the close-all action without replacing native behavior.

#### Scenario: Reviewer compares Tools and More with 03

- **WHEN** Tools or More is rendered at desktop width
- **THEN** Tools action labels SHALL use `11px / 400`, descriptions SHALL use `10px / 400`, and rows SHALL retain the compact `29px` rhythm
- **AND** More categories SHALL use `10px / 400` with the production font stack, selected categories SHALL use `600`, the tag-manager heading SHALL use `11px / 600`, and tag labels SHALL use `10px / 400`
- **AND** these rules SHALL not reset ordinary tiddler buttons, links, tags, or mobile PageControls

#### Scenario: Native toggle and Open actions receive quieter icons

- **WHEN** the desktop sidebar is open or closed
- **THEN** the native show/hide button SHALL retain its message, label, focus, and state behavior
- **AND** one product-scoped single line chevron SHALL provide the visible glyph and reverse with the sidebar state
- **AND** the native double filled chevron SHALL not remain visibly underneath it
- **AND** Open item titles and the close-all label SHALL have no leading document/file glyph while their native close actions and live count remain available

#### Scenario: Reviewer opens the comparison directory

- **WHEN** the selected standalone reference set is inspected
- **THEN** `03-compact-control-rail.html` SHALL remain independently openable and fully interactive
- **AND** the rejected 01 and 02 variants and the untracked 03 backup SHALL not remain in the directory

#### Scenario: Command Palette remains recognizable at rail size

- **WHEN** the native Command Palette control renders in the compact desktop rail
- **THEN** its product-owned `command` icon SHALL render as an unframed `>_` line glyph at the established `17px` size
- **AND** the glyph SHALL use one chevron path and one separate baseline path with no fill
- **AND** the native Command Palette control SHALL continue to own its action, accessible label, focus, popup, and keyboard behavior
- **AND** the selected 03 standalone reference SHALL not be rewritten by this production-only correction
