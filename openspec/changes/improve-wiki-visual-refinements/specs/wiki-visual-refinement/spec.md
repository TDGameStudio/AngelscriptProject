## ADDED Requirements

### Requirement: Sidebar resize rail is contextual without shrinking its interaction target

On desktop, AngelscriptWiki SHALL keep the enabled sidebar-resizer's full-height pointer target and resize behavior while hiding its visible rail when the pointer is not over it and no drag is active. The rail SHALL become visible on hover and SHALL be more prominent while dragging.

#### Scenario: Idle desktop sidebar has no visible resize rail

- **WHEN** a desktop-width Wiki page renders with the sidebar open and the resize target is neither hovered nor active
- **THEN** the resize target SHALL remain present, fixed, full-height, and at least 10px wide
- **AND** its visible pseudo-element rail SHALL have zero opacity

#### Scenario: Hover and drag communicate resize affordance

- **WHEN** the pointer hovers over the desktop resize target
- **THEN** the rail SHALL become visible without changing the target geometry
- **AND** WHEN dragging begins
- **THEN** the rail SHALL be more prominent than its hover state and the sidebar width SHALL remain adjustable

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
