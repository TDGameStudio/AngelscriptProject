## ADDED Requirements

### Requirement: Operational icons have one governed canonical catalog

The Wiki SHALL maintain a TDGameStudio-owned line-icon catalog containing every canonical operational icon used by product-owned WikiText, generated system overrides, and browser controls. Each catalog record MUST provide a semantic identifier, canonical tiddler title, SVG asset reference, source kind, and source/license metadata appropriate to that kind.

#### Scenario: A catalog icon is used by a control

- **WHEN** a product control needs an operational icon
- **THEN** it SHALL reference a catalog semantic identifier or its generated canonical tiddler
- **AND** it SHALL NOT define an independent SVG path for that icon

#### Scenario: An externally derived icon is proposed

- **WHEN** a catalog record adopts or adapts artwork from an external source
- **THEN** the record SHALL identify the exact upstream source and compatible license
- **AND** the repository SHALL NOT import an entire third-party icon library solely for that record

### Requirement: Generated icons preserve the lightweight line language

Every generated operational image tiddler SHALL use a 24-by-24 SVG coordinate system, `currentColor` stroke, no fill, round line caps and joins, and the established 1.5 stroke width. Generated canonical image tiddlers SHALL continue to accept the existing `size` parameter.

#### Scenario: Sidebar icon renders at its requested size

- **WHEN** a sidebar or compact-rail control transcludes a generated canonical icon with a `size` value
- **THEN** the rendered SVG SHALL use that size
- **AND** its geometry SHALL conform to the lightweight line language

#### Scenario: Browser code renders a copy-state icon

- **WHEN** the `as-code` copy control changes between idle, success, or error state
- **THEN** it SHALL render a catalog-backed icon for that state
- **AND** the resulting SVG SHALL conform to the lightweight line language

### Requirement: System and enabled-plugin operational imagery is replaced through owned overrides

The Wiki SHALL classify every candidate user-visible operational image title contributed by core or an enabled product plugin as `override`, `canonical`, or `excluded`. An `override` classification MUST yield a generated ordinary tiddler with the exact target title; an `excluded` classification MUST state a non-operational reason.

#### Scenario: A core operational image has a replacement

- **WHEN** a candidate core image is classified as `override`
- **THEN** the ordinary Wiki tiddler set SHALL contain a generated tiddler with the same title
- **AND** the generated tiddler SHALL render the catalog-backed lightweight line icon

#### Scenario: A candidate is deliberately excluded

- **WHEN** an image is branding, loading artwork, favicon media, a page emoji, or a cover/Notion selection asset
- **THEN** its inventory entry MAY be classified as `excluded`
- **AND** the entry SHALL name that exclusion reason

### Requirement: Icon generation and inventory stay auditable

The catalog generator SHALL produce deterministic output and SHALL reject duplicate semantic identifiers, duplicate override titles, missing assets, malformed source metadata, or an unclassified candidate. Automated source and artifact checks SHALL fail when generated output does not match the catalog or when a tracked override no longer resolves to a selected core/enabled-plugin image source.

#### Scenario: Generated output is stale

- **WHEN** a catalog asset or record changes without regenerating its outputs
- **THEN** the icon generation verification SHALL fail
- **AND** it SHALL identify that generated icon output must be refreshed

#### Scenario: An inventory target disappears upstream

- **WHEN** a core or enabled product plugin no longer contributes a title classified as `override`
- **THEN** source-boundary verification SHALL fail
- **AND** the stale inventory target SHALL be identified for review

### Requirement: Every operational target has an explicit semantic icon

The catalog SHALL NOT use a generic visual fallback for an operational core or enabled-plugin target. Every non-excluded inventory target MUST name a catalog semantic icon. If two targets intentionally share an icon, the secondary target MUST declare its primary target and a specific semantic reason.

#### Scenario: A newly discovered system image is not yet mapped

- **WHEN** an operational candidate has no explicit catalog target
- **THEN** catalog verification SHALL fail
- **AND** the generated Wiki SHALL NOT substitute a generic tool glyph

#### Scenario: Action or state variants are represented

- **WHEN** controls differ by action or state, including lock/unlock, preview open/closed, timestamp on/off, or single/all/other folding
- **THEN** their assigned icon geometry SHALL remain visually distinguishable
- **AND** they SHALL NOT be declared aliases merely to reduce the asset count

### Requirement: Generated line icons remain unfilled in interaction states

The shared Wiki stylesheet SHALL ensure that generated line-icon SVG roots and descendants remain `fill: none` when inherited or high-specificity control styles apply. Hover, active, selected, and sidebar hide/show states MAY change `currentColor` but SHALL NOT paint the glyph body.

#### Scenario: A compact sidebar control is hovered or activated

- **WHEN** a generated sidebar icon is rendered in an interaction state
- **THEN** its computed fill and the computed fill of its SVG descendants SHALL be `none`
- **AND** its stroke may inherit the state color

### Requirement: More-action menus retain semantic controls and aligned line-icon rows

The tiddler-toolbar More-action control SHALL use the catalog-backed menu glyph rather than repurposing the general down-arrow. Its core popup behavior SHALL remain intact. Sidebar and tiddler More-action menus SHALL render each operational item in a fixed line-icon column and a separately aligned text column. Their generated icon descendants SHALL remain unfilled.

#### Scenario: A reviewer opens the tiddler More-action menu

- **WHEN** the viewer opens a tiddler's More-action menu
- **THEN** the toolbar trigger SHALL render the catalog-backed `more` glyph
- **AND** genuine uses of the general `down-arrow` icon SHALL retain their own semantic glyph
- **AND** every visible action row SHALL align its icon and caption on a common grid

#### Scenario: A product button appears in the sidebar More-action menu

- **WHEN** an enabled product button, including the Markdown new-tiddler action, appears in the sidebar More-action menu
- **THEN** its image SHALL resolve through the generated catalog override
- **AND** it SHALL use the same line-icon column, text position, and unfilled rendering contract as core action rows

### Requirement: The review gallery exposes visual and provenance evidence

The generated gallery SHALL show every canonical icon with its preview, semantic identifier, category, source and license, current usage targets, and any declared aliases. It SHALL not be a default Wiki tiddler.

#### Scenario: A reviewer opens the gallery

- **WHEN** the review tiddler is opened
- **THEN** the reviewer SHALL be able to identify the upstream Feather icon or local provenance for each glyph
- **AND** inspect which controls consume it before approving a semantic reuse
