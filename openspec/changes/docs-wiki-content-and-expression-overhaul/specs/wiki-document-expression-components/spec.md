## ADDED Requirements

### Requirement: Reusable document expression components have a declared form and boundary

Recurring document presentation patterns (capability comparison tables, API signature tables, collapsible source-entry/deep-dive blocks, status badges, icon callout cards, showcase reference blocks, and similar) SHALL be implemented as the smallest sufficient reusable form and SHALL respect the repository expression boundaries. Each reusable component SHALL be recorded with its name, implementation form, purpose, boundary justification, build/test state, and an example page in the change's `components-catalog.md`.

The implementation form SHALL follow this priority: in-content WikiText/transclusion first, then a `\procedure` (reusable rendering/control flow) or `\function` (pure value/filter computation), and only then a minimal `src/<plugin>/` widget when the behavior cannot live in content or configuration. A new global macro SHALL NOT be introduced when a procedure or function is sufficient, and a widget SHALL NOT be added when one page can express the behavior as content.

#### Scenario: A presentation pattern recurs across documents

- **WHEN** a maintainer needs a presentation pattern in more than one document
- **THEN** the pattern SHALL be authored as a `\procedure`/`\function` or a minimal `src/<plugin>/` module rather than copied inline into each page
- **AND** it SHALL be recorded in `components-catalog.md` with its form, purpose, and boundary justification
- **AND** a new global macro SHALL NOT be created when a procedure or function suffices

#### Scenario: A single page can express the behavior

- **WHEN** a presentation is used by only one page
- **THEN** it SHALL remain in-content WikiText/transclusion
- **AND** no widget or global macro SHALL be introduced for it

### Requirement: Static HTML and external embeds in documents stay within trusted-content limits

Raw HTML used in documents SHALL be limited to trusted static content authored in the repository and SHALL NOT interpolate unescaped user input, tiddler fields, or external data. An iframe or external embed SHALL require an explicit allowlist entry, a network/security explanation, and an offline fallback. Embedded AngelScript code SHALL use `<$codeblock language="angelscript">` for ordinary blocks and `<$angelscript-code>` for line numbers, custom display start, highlighted lines, or 1-based inclusive source slicing, and SHALL NOT reintroduce a hand-written tokenizer.

#### Scenario: A document embeds an external service

- **WHEN** a document needs an iframe or external embed
- **THEN** the embed SHALL be covered by an explicit allowlist with a network/security explanation
- **AND** the document SHALL provide an offline fallback
- **AND** unescaped external or user data SHALL NOT be interpolated into raw HTML

#### Scenario: A document presents AngelScript source

- **WHEN** a document shows AngelScript code
- **THEN** it SHALL use `<$codeblock language="angelscript">` for an ordinary block or `<$angelscript-code>` when line numbers, custom start, highlights, or source slicing are needed
- **AND** it SHALL NOT reintroduce a hand-written tokenizer

### Requirement: Reusable document expression components are testable

A reusable component that carries browser behavior SHALL have a minimal test tiddler and a Playwright scenario in its owning product domain before it is marked built in `components-catalog.md`. Its recorded state SHALL be one of `planned`, `built`, or `tested`, and `tested` SHALL require the associated `test:feature` scenario to exist.

#### Scenario: A component with browser behavior is marked tested

- **WHEN** a reusable component with interactive behavior is recorded as `tested`
- **THEN** a minimal test tiddler and a Playwright scenario in its owning domain SHALL exist
- **AND** the component SHALL be verifiable through `pnpm run test:feature -- <domain>`

### Requirement: Source explanation experiments preserve source continuity and history

Standalone source-explanation experiments SHALL use append-only numbered artifacts until a maintainer explicitly selects a production form. A later experiment MUST NOT delete, overwrite, or silently rewrite an earlier numbered artifact. The source root of a source-preserving experiment SHALL contain only source lines in their original order; annotations, details, and connector geometry SHALL live outside that root and SHALL NOT move or resize source lines when their state changes.

External references used to inform these experiments SHALL be recorded as attributed research evidence rather than runtime dependencies. A local reference gallery SHALL load without fetching third-party assets, and an experiment SHALL NOT be marked as a production Wiki component solely because its standalone validation passes.

#### Scenario: A new source explanation experiment is added

- **WHEN** a maintainer adds another numbered source-explanation experiment
- **THEN** every previously delivered numbered experiment SHALL remain present and unchanged
- **AND** the new source root SHALL contain only continuous source lines
- **AND** opening, pinning, hiding, or restoring a note SHALL NOT change any source line position or size

#### Scenario: External presentation references are reviewed

- **WHEN** a maintainer captures external presentation references for source-explanation research
- **THEN** each selected reference SHALL record its direct source, access date, observed strengths, limitations, and adoption decision
- **AND** the local gallery SHALL use attributed, necessary research captures without loading third-party assets at view time
- **AND** the captures SHALL remain OpenSpec research material rather than Wiki or plugin runtime content

### Requirement: Dependency-backed source explanation experiments remain offline and attributable

A standalone source-explanation experiment MAY use a JavaScript dependency when it isolates and evaluates a declared responsibility that the dependency actually owns. The artifact SHALL pin and expose the dependency name, version, license, upstream source, and inline runtime byte count. The dependency runtime SHALL be embedded in that experiment's single HTML file, and opening the file SHALL NOT require or initiate an external network request.

Source measurement, note placement, connector routing, and expanded-detail positioning SHALL remain separable responsibilities. Introducing a dependency for one responsibility SHALL NOT grant it ownership of the other layers. A passing experiment SHALL remain research evidence until a maintainer explicitly selects a production form and records its Wiki implementation boundary and tests.

#### Scenario: A dependency is evaluated in a standalone experiment

- **WHEN** a maintainer adds a dependency-backed numbered HTML experiment
- **THEN** the HTML SHALL embed the pinned runtime rather than load a CDN or other external asset
- **AND** its audit surface SHALL report the dependency name, version, license, direct HTTPS upstream, and inline byte count
- **AND** loading and exercising the experiment SHALL produce no external request
- **AND** cleanup SHALL release any connector, observer, listener, or automatic-positioning lifecycle owned by the dependency

#### Scenario: A dependency-backed experiment is considered for the Wiki plugin

- **WHEN** a maintainer decides to move an experimental dependency into the AngelScript Wiki plugin
- **THEN** the production change SHALL declare which single responsibility the dependency owns
- **AND** the source DOM SHALL remain continuous and free of note or connector nodes
- **AND** the implementation SHALL add a minimal test tiddler plus desktop, contained narrow-screen, keyboard, reduced-motion, offline, license/version, geometry-stability, and teardown coverage before the component is marked `tested`
- **AND** unrelated experimental libraries SHALL NOT be bundled merely because they appeared in comparison artifacts

### Requirement: Production annotated source exposes a stable language-generic author contract

The Wiki SHALL expose a language-generic `<$annotated-code>` widget, a backward-compatible `<$angelscript-code>` widget fixed to the `angelscript` language, and a `<$code-note>` widget accepted as a direct child of either code surface. Both code surfaces SHALL preserve the shared `code`, `title`, `lineNumbers`, `highlightLines`, `fromLine`, `toLine`, `startLine`, `maxVisibleLines`, `copy`, and `noteStyle` attributes. `lineNumbers="yes"` SHALL be an explicit opt-in and the omitted default SHALL hide the gutter. `noteStyle` SHALL accept the Wiki-matched `comment`, `muted`, and `ink` treatments and default to `comment`. The `code` attribute SHALL remain the only source input; the body SHALL contain only note definitions, and non-note body children SHALL remain ignored for compatibility.

Each `<$code-note>` SHALL require a positive displayed `line` and a non-empty, always-visible `label`. It SHALL accept an inclusive displayed `toLine` defaulting to `line`, an optional exact `match` inside that displayed range, an optional positive 1-based `occurrence` defaulting to `1`, an optional `title` defaulting to `label`, optional WikiText body detail, and an optional `detailTiddler`. An existing `detailTiddler` SHALL be transcluded as the primary detail and linked to its standalone Wiki page; a missing target SHALL render a diagnostic and preserve the inline body as fallback. A note without either detail source SHALL remain a non-expanding short note. Notes SHALL be sorted by displayed source line while preserving author order for ties, and widget instances SHALL generate their own IDs rather than accepting author-supplied identifiers.

#### Scenario: A document annotates generic C++ source

- **WHEN** a document needs annotated C++ source
- **THEN** it SHALL use `<$annotated-code language="cpp" code="...">` with direct child `<$code-note>` definitions
- **AND** the language SHALL be forwarded through the existing TiddlyWiki Highlight pipeline

#### Scenario: An existing AngelScript code surface gains notes

- **WHEN** an existing `<$angelscript-code>` call is rendered with or without direct child notes
- **THEN** every existing line-control, slicing, highlighting, copy, and DOM behavior SHALL remain compatible
- **AND** a supplied `language` attribute MUST NOT change its fixed `angelscript` highlighting

#### Scenario: An author targets a displayed source relationship

- **WHEN** a direct child `<$code-note>` declares `line`, optional `toLine`, optional `match`, and optional `occurrence`
- **THEN** the relationship SHALL resolve in the same displayed-line coordinate system as `highlightLines`
- **AND** an absent `match` SHALL target the whole declared line range
- **AND** an exact `match` spanning line breaks SHALL expose every intersected source line to placement and source-mark selection
- **AND** each visible whole-line range mark SHALL be clipped to that line's first and last non-whitespace source characters
- **AND** indentation, trailing whitespace, and empty lines MUST NOT receive a visible underline or range fill
- **AND** the note body SHALL be interpreted as WikiText detail rather than source text

### Requirement: Production annotations preserve source DOM, geometry, and copy semantics

TiddlyWiki's Highlight pipeline SHALL remain the sole source highlighter. Highlighted source SHALL be the only content inside `<pre>/<code>`; notes, ports, range marks, SVG connectors, and expanded details SHALL remain sibling or overlay nodes outside the source elements. Annotation activation and disclosure MUST NOT change source text, order, wrapping, line position, or line size, and the copy action SHALL return only the selected source.

Invalid or unresolved anchors, including out-of-range lines, reversed ranges, invalid occurrences, or absent supplied matches, MUST NOT create a connector to substitute source. Their short content and detail SHALL remain visibly available in an after-code unresolved-author section.

#### Scenario: A reader interacts with a valid note

- **WHEN** a reader hovers, focuses, opens, or closes a valid source note
- **THEN** `<pre>/<code>` SHALL continue to contain only the same Highlight-produced source
- **AND** every source line rectangle SHALL remain unchanged
- **AND** copying SHALL return pure source without note, connector, port, or detail text

#### Scenario: A note anchor cannot be resolved exactly

- **WHEN** a note declares an invalid displayed range or its exact `match` and `occurrence` cannot be found
- **THEN** the note SHALL remain visibly marked as unresolved after the code
- **AND** an existing `detailTiddler` SHALL remain transcluded and linked, while a missing target SHALL retain its diagnostic and inline fallback
- **AND** it MUST NOT point at a nearby line, token, or fallback match
- **AND** it MUST NOT render a false relationship connector

### Requirement: Annotated source uses whitespace-aware progressive disclosure

An annotated block MUST NOT reserve, mask, or overlay a right-side annotation rail. Its source SHALL retain the natural width of the Highlight-owned source. The placement solver SHALL attempt each short note at the target line tail, then at a nearby genuinely blank source line, and SHALL place only notes without a collision-free candidate in a lightweight shelf above the code. Notes and source marks SHALL share source coordinates so horizontal scrolling moves them together. Every short note SHALL remain visible without changing the source DOM. Hover or focus SHALL activate only that note's exact range, micro-port, connector, and label. Click SHALL disclose its full WikiText detail; re-click, outside click, and `Escape` SHALL close it, and `aria-expanded`/`aria-controls` SHALL stay synchronized. Only one detail per code block SHALL be open at a time.

The visual treatment SHALL inherit the Wiki's Notion/Tomorrow/Fira code system, using low-contrast relationships and comment-like short notes approximately one source line high. Short notes SHALL use no complete enclosing border, ordinal, or disclosure arrow; the default `comment` treatment SHALL use a shallow gray background and a restrained left rule. It MUST NOT introduce a second dominant content column, heavy short-note shadows, saturated note fills, or pill badges. Idle source ranges SHALL use only a nearly imperceptible fill and MUST NOT expose an underline; hover, keyboard focus, or an opened detail SHALL reveal the corresponding underline and stronger range treatment. Connectors SHALL remain below the Highlight-owned source in every interaction state. Geometric crossing is permitted, but a connector MUST NOT be elevated over source glyphs.

#### Scenario: A desktop reader scans annotations without interacting

- **WHEN** an annotated source block is rendered with available source whitespace
- **THEN** all short note labels SHALL be visible in source order
- **AND** notes SHALL expose `line-tail`, `blank-line`, or `top` placement without covering source ink or another note
- **AND** the source code SHALL remain the dominant visual layer
- **AND** inactive connectors and notes SHALL remain quieter than syntax highlighting
- **AND** connectors SHALL be painted beneath the Highlight-owned source ink

#### Scenario: A reader pins one source relationship

- **WHEN** click, Enter, or Space opens one relationship detail
- **THEN** that relationship's connector SHALL become visually stronger without changing its layer
- **AND** the active and inactive connectors MUST remain below the Highlight-owned source
- **AND** other connectors SHALL remain visually quiet
- **AND** closing or replacing the disclosure SHALL restore the idle relationship treatment

#### Scenario: A keyboard reader opens and closes detail

- **WHEN** a keyboard reader focuses a short note and activates it
- **THEN** the corresponding full WikiText detail SHALL open with synchronized accessible state
- **AND** focus or `Escape` interaction SHALL remain available without requiring pointer hover
- **AND** `Escape` SHALL close the detail and return focus to its short note
- **AND** activating another note in the same block SHALL close the previous detail

### Requirement: Native and fallback annotation capabilities are behaviorally equivalent

Production source measurement SHALL use native DOM `Range`, and relationship connectors SHALL use native SVG. Expanded detail SHALL use native Popover when available with adaptive fixed positioning, and a non-Popover fixed disclosure when Popover is unavailable. Detail surfaces SHALL classify compact, reading, and rich content; rich desktop detail SHALL grow up to approximately `48rem` and `70vh`, while narrow detail SHALL use a near-full viewport surface without a dedicated visual close icon. Re-activation, outside click, `Escape`, and activation of another note SHALL provide equivalent closure paths. These paths SHALL expose equivalent note ordering, source relationships, ARIA state, open/close behavior, and geometry invariants.

Production MAY use the exact `obstacle-router@0.1.2` dependency only through a separately attributable and replaceable TiddlyWiki library module. The dependency SHALL solve connector geometry only; it MUST NOT own source measurement, note placement, SVG rendering, disclosure state, or author-facing WikiText. It SHALL execute only when a code block has at least one relationship that cannot use a safe horizontal direct path, SHALL be bundled into the offline Wiki without runtime network access, and SHALL retain its LGPL-2.1 attribution and license.

When a note cannot fit beside source, including narrow contained layouts, it SHALL move to the above-code shelf rather than reserve a hidden rail or append a second explanation column. Horizontal source scrolling SHALL remain inside the code surface, with notes and marks in the same source coordinate system. Print SHALL hide interactive chrome and connectors and SHALL expose detail text statically. `prefers-reduced-motion` SHALL disable transitions.

#### Scenario: A native browser capability is unavailable

- **WHEN** Popover is unavailable
- **THEN** the corresponding manual fallback SHALL preserve the same note content, source target, keyboard semantics, and close behavior
- **AND** the fallback MUST NOT change source geometry or contaminate `<pre>/<code>`

### Requirement: Connector routing prefers exact straight relations and avoids source ink

For every rendered relationship, the connector solver SHALL first test a collision-free horizontal corridor from the selected source edge to a compatible point on the note edge. A safe same-row relationship SHALL use endpoints with exactly the same Y coordinate and a straight SVG line. Eligible non-direct relationships SHALL be solved with all eligible complex relationships in the same code block as one obstacle-routing transaction, using non-whitespace source ink and other short notes as obstacles, then converted into a bounded smooth SVG path owned by the Wiki. Endpoint exits SHALL be kept outside buffered obstacles. A top-shelf relationship, an invalid route, or a route that leaves the endpoint bounding box SHALL retain the below-source fallback rather than accepting a visually excessive detour.

Routing SHALL be cached by quantized geometry rather than interaction state. Hover, focus, disclosure, and repeated unchanged layout notifications MUST NOT invoke the obstacle router again. If routing fails or returns invalid geometry, the connector SHALL use a below-source outer fallback and MUST NOT be elevated across source glyphs.

#### Scenario: A line-tail note is vertically compatible with its source

- **WHEN** the note edge covers the source anchor Y and the intervening corridor contains no source ink or other note
- **THEN** the connector SHALL be one mathematically horizontal path with identical endpoint Y values
- **AND** it SHALL reach both terminals without a visible gap

#### Scenario: An eligible displaced connector cannot safely travel straight

- **WHEN** a blank-line or displaced inline relationship would intersect source ink or another note and remains eligible for bounded routing
- **THEN** the relation SHALL use the shared obstacle-routing transaction
- **AND** the final smoothed path SHALL retain its source and note terminals while avoiding the registered obstacles

#### Scenario: Bounded routing cannot improve a relationship

- **WHEN** a relation is on the top shelf, routing fails, or a returned path leaves the endpoint bounding box
- **THEN** the relation SHALL retain the low-layer fallback path
- **AND** the obstacle module MUST NOT block source rendering or elevate the connector over source ink

### Requirement: Source notes distinguish inline detail from standalone Wiki detail

A note with inline body only SHALL disclose that body without a standalone-page affordance. A note naming an existing `detailTiddler` SHALL expose a subdued textual `Wiki` marker before activation, label its disclosure as a Wiki detail preview, transclude the target as the primary body, and provide a standard TiddlyWiki internal link labelled “在 Wiki 中打开完整解释”. The marker SHALL have an equivalent accessible name and MUST NOT be rendered as an ordinal, pill badge, or disclosure arrow.

#### Scenario: P04 exposes both detail modes

- **WHEN** a reader scans and activates the notes in P04
- **THEN** ordinary lifecycle notes SHALL open compact inline explanations without a standalone link
- **AND** the current-VM guard note SHALL advertise, preview, and navigate to `AS/Showcase/Detail/P04-CurrentVmGuard`

#### Scenario: An annotated block is narrow, printed, or reduced-motion

- **WHEN** an annotated block has no collision-free inline position, is printed, or is rendered under `prefers-reduced-motion`
- **THEN** its mode-specific presentation SHALL preserve all source and note content
- **AND** narrow presentation SHALL contain horizontal source scrolling within the code surface
- **AND** print SHALL expose detail statically
- **AND** reduced-motion presentation SHALL use no transitions

### Requirement: Annotated source instances isolate and tear down browser state

Each annotated code instance SHALL own unique identifiers, anchor names, disclosure state, listeners, observers, and scheduled layout work. Multiple instances on one tiddler MUST NOT share active state or target each other's notes. TiddlyWiki refresh and widget destruction SHALL close owned disclosures, cancel scheduled animation frames, disconnect observers, and remove owned listeners.

#### Scenario: Multiple blocks refresh and one is destroyed

- **WHEN** a tiddler contains multiple annotated blocks and TiddlyWiki refreshes or destroys one instance
- **THEN** the remaining instances SHALL retain independent IDs, source targets, and disclosure state
- **AND** the destroyed instance SHALL leave no active Popover, observer, listener, or scheduled layout work

### Requirement: Production evidence pages remain mapped and source-revisioned

P02, P03, and P04 SHALL be production reader pages in the Pattern Showcase and SHALL be recorded as mapped catalog entries. Their rendered source SHALL come from reader-support snapshots that retain the repository source path, source revision, and displayed start line needed to verify the selected source range. P04 SHALL preserve a single reading column with AngelScript before C++ rather than presenting the two languages as textual or one-to-one equivalents.

#### Scenario: A reader opens a production evidence page

- **WHEN** a reader navigates from the Pattern Showcase catalog to P02, P03, or P04
- **THEN** the mapped page SHALL render its annotated source through the production widget contract
- **AND** it SHALL expose source path and revision evidence for each source snapshot

### Requirement: Source-centered explanation widgets expose typed author contracts

The Wiki SHALL expose `<$lifecycle-flow>`/`<$lifecycle-event>`, `<$state-flow>`/`<$state-node>`/`<$state-transition>`, `<$call-sequence>`/`<$sequence-participant>`/`<$sequence-message>`, and `<$data-flow>`/`<$data-node>`/`<$data-edge>` widget families. Each outer widget SHALL accept the production code-surface attributes, render one continuous Highlight-owned source surface before its explanatory structure, and translate line-bearing direct children into the same exact source relationships and disclosures used by `<$code-note>`.

Relations SHALL use an instance-local `key`, a non-empty `label`, the existing displayed `line`/`toLine`/`match`/`occurrence` locator contract, an optional title, and optional WikiText detail. Mode-specific fields SHALL remain textual and explicit: lifecycle ownership/phase/condition/re-entry, state endpoints/trigger/guard/outcome, sequence participants/message kind, and data ownership/artifact/edge kind.

#### Scenario: A reader explores a typed explanation flow

- **WHEN** the reader hovers or focuses a valid relationship
- **THEN** only that flow item, short note, source range, ports, and connector SHALL preview as active
- **AND** click, Enter, or Space SHALL pin and disclose that relationship
- **AND** Escape, outside click, or selecting another relationship SHALL clear or replace the single pinned state without moving source geometry

#### Scenario: A typed relationship is invalid

- **WHEN** a child has a duplicate key, missing endpoint, invalid locator, or unsupported kind
- **THEN** source SHALL continue to render
- **AND** the relation and detail SHALL remain available in an author-facing text fallback rather than disappearing

### Requirement: AST and VM labs use revisioned fidelity-labelled data

The Wiki SHALL expose `<$source-ast>` and `<$vm-trace>` widgets whose `data` attribute names an `application/json` tiddler with `schemaVersion: 1`, source path/title/revision/start-line evidence, a declared fidelity, stable node or step IDs, and source locators compatible with production annotations. Invalid JSON, unsupported schema versions, duplicate IDs, unresolved references, or stale evidence MUST render an inline data warning while leaving source and surrounding document content available.

The first AST fixture SHALL identify itself as `simplified`; the first VM fixture SHALL identify itself as `recorded-source-level`. Raw AngelScript AST nodes or bytecode opcodes MUST NOT be shown as captured facts unless their fixture provenance is independently verifiable.

#### Scenario: A reader selects an AST node or VM step

- **WHEN** the reader selects a valid node or step
- **THEN** the corresponding source relationship SHALL activate through the shared interaction model
- **AND** AST structure or VM frame/local/branch/return facts SHALL remain available as ordered text without SVG or script

#### Scenario: Structured explanation data is unavailable

- **WHEN** the named data tiddler is missing, invalid, unsupported, or stale
- **THEN** the widget SHALL identify the failed data title and reason
- **AND** it SHALL NOT throw away the continuous source or imply that the Wiki compiled or executed AngelScript

### Requirement: The expanded Showcase batch remains provenance-backed

P07 through P10 SHALL be mapped Pattern pages backed by pinned repository source snapshots. L01 and L02 SHALL be navigable Lab pages and SHALL remain catalogued as experiments with visible fidelity disclosure. The batch SHALL cover subsystem lifecycle, hot-reload state, RPC call sequence, compilation/binding/execution data flow, simplified source-to-AST linkage, and recorded source-level VM execution.

#### Scenario: A reader opens an expanded explanation example

- **WHEN** the reader opens P07, P08, P09, P10, L01, or L02 from the Showcase
- **THEN** the page SHALL render the declared specialized widget and its continuous source
- **AND** it SHALL expose source path, revision, fidelity where applicable, and a useful narrow/print text fallback
- **AND** the catalog and reader page SHALL agree on the stable page title
