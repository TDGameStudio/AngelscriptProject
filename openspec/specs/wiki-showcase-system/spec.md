# wiki-showcase-system Specification

## Purpose
TBD - created by archiving change docs-wiki-content-foundation. Update Purpose after archive.
## Requirements
### Requirement: Showcase content has three explicit stability tiers

The Wiki SHALL organize documentation presentation examples under `ASWiki/Showcase` with child tiers `ASWiki/Showcase/Base`, `ASWiki/Showcase/Pattern`, and `ASWiki/Showcase/Lab`. Each showcase page SHALL declare exactly one tier tag, a unique `as-showcase-id`, an `as-showcase-tier` field matching that tag, and a nonempty `as-showcase-purpose`.

#### Scenario: Reader opens the Showcase directory

- **WHEN** the Showcase directory renders
- **THEN** Base, Pattern, and Lab SHALL be independently discoverable
- **AND** each tier SHALL explain its stability and intended use

#### Scenario: Showcase has no documentation purpose

- **WHEN** a proposed Base or Pattern page is only decorative and does not exercise or teach a documentation expression
- **THEN** it SHALL NOT be admitted to Base or Pattern

#### Scenario: Showcase field and tag disagree

- **WHEN** a Showcase page's `as-showcase-tier` does not match its one tier tag
- **THEN** content-contract validation SHALL fail with its title, field value, and tags

### Requirement: Base catalog covers stable rendering and interaction surfaces

The Base catalog SHALL record fifteen surface groups covering: basic Markdown; extended Markdown; Markdown More; WikiText formatting, links, and tables; transclusion/filter/procedure behavior; common widgets and temporary state; AngelScript highlighting and line controls; multilingual and long-line code; images/SVG/media/file links; long prose/wide tables/overflow; Chinese-English mixed text and search; keyboard/narrow-screen/print/reduced-motion behavior; TiddlyWiki variables/procedures/functions/legacy macros; trusted WikiText HTML and widget composition; and embedded local/external web content.

#### Scenario: Theme or document layout changes

- **WHEN** a change affects typography, code, tables, links, media, overflow, responsive behavior, focus, or motion
- **THEN** the relevant Base surface SHALL provide a stable review target
- **AND** focused browser coverage SHALL protect its agreed behavior

#### Scenario: Existing syntax pages are mapped

- **WHEN** the foundation inventories current Markdown, Markdown More, WikiText, or AngelScript examples
- **THEN** each reader-facing page or internal fixture SHALL be mapped to a Base surface, Pattern, hidden test fixture, or retirement candidate
- **AND** the implementation SHALL NOT duplicate it without a distinct purpose

#### Scenario: Author reviews a TiddlyWiki-native expression

- **WHEN** the author opens the procedure/function/macro Base surface
- **THEN** it SHALL demonstrate parameters, defaults, quoting, scoping, nested invocation, filter functions, transclusion invocation, and one labelled legacy `\define` compatibility case
- **AND** it SHALL distinguish current recommended forms from compatibility syntax

#### Scenario: Author writes HTML in WikiText

- **WHEN** the author opens the trusted HTML Base surface
- **THEN** it SHALL demonstrate semantic HTML containing WikiText widgets and HTML emitted from a procedure
- **AND** live scripts and inline event handlers SHALL be excluded
- **AND** unsafe forms SHALL appear only as escaped source with an explanation that repository-authored HTML is trusted product content, not an untrusted-content sandbox

#### Scenario: Author embeds a page

- **WHEN** the author opens the embedded-web Base surface
- **THEN** it SHALL demonstrate a deterministic product-owned/local case plus an optional external case
- **AND** every iframe SHALL have a title, lazy-loading behavior, minimal sandbox, referrer policy, responsive containment, and visible link/text fallback
- **AND** offline or frame-denied behavior SHALL remain useful without a third-party network request

### Requirement: Pattern catalog covers reusable technical-document compositions

The Pattern catalog SHALL record sixteen composition groups: minimal runnable example; code with line-by-line explanation; code with key-path annotations; AS/C++ comparison; AS/Blueprint mapping; API signatures and parameter tables; lifecycle timeline; state transition; call sequence; compilation/binding/execution data flow; module architecture and dependencies; decision trees and limitation lists; version/source/test evidence; placeholder/draft/migration presentation; parameterized WikiText documentation components; and embedded interactive companions with static fallback.

#### Scenario: Author needs to explain a runtime mechanism

- **WHEN** an author needs a lifecycle, state, call-sequence, data-flow, or architecture expression
- **THEN** the Pattern directory SHALL identify a reusable presentation and its accessibility/responsive constraints

#### Scenario: Author needs to compare languages or tools

- **WHEN** an author compares AS with C++ or Blueprint
- **THEN** the Pattern SHALL preserve semantic labels, reading order, narrow-screen containment, and code-copy boundaries

#### Scenario: Author reuses a native WikiText component

- **WHEN** an author turns a procedure/function/transclusion composition into a repeated document component
- **THEN** the Pattern SHALL define its purpose, parameters, defaults, escaping, nested-content behavior, empty/error state, markup semantics, and source-level tests

#### Scenario: Author links an interactive companion

- **WHEN** an article benefits from a packaged mini-page or allowed external tool
- **THEN** the Pattern SHALL keep prose authoritative and provide a static/offline/print fallback
- **AND** origin, network behavior, sandbox permissions, artifact cost, and failure behavior SHALL be visible

### Requirement: Lab catalog isolates disposable experiments

The Lab catalog SHALL record eleven experimental groups: AST/source linkage; bytecode/VM execution; hot-reload state comparison; reflection-object generation; DebugServer/call-stack flows; test matrices and coverage; tag/navigation/search layouts; code folding/focus/annotation; SVG/Draw.io/HTML/Canvas comparisons; future test-framework concept interfaces; and web-embed security/packaging policy.

#### Scenario: Experimental presentation changes substantially

- **WHEN** a Lab experiment is rewritten, replaced, or removed
- **THEN** the change SHALL NOT be treated as a Base or Pattern compatibility break
- **AND** ordinary product navigation SHALL continue to identify Lab as experimental

#### Scenario: Lab experiment adds a heavy runtime

- **WHEN** an experiment uses Canvas, WebGL, WASM, or another large dependency
- **THEN** it SHALL be explicitly lazy-loaded or kept outside the product runtime
- **AND** it SHALL NOT enter the initial Wiki page path without a separate reviewed capability

#### Scenario: Lab evaluates web embedding

- **WHEN** an experiment compares `srcdoc`, packaged pages, sandboxed external iframes, or new-window links
- **THEN** it SHALL use synthetic or product-owned targets and SHALL NOT access credentials or require cross-origin messaging
- **AND** it SHALL remain Lab until CSP, offline artifact, accessibility, privacy, and threat review are complete

### Requirement: Verification strength follows Showcase stability

Base SHALL receive focused browser regression for its agreed output and interactions. Pattern SHALL receive discoverability, render, accessibility, and containment coverage without promising exact internal DOM. Lab SHALL receive load-safety, source-boundary, and experimental-label coverage unless a separate change graduates the experiment.

#### Scenario: Base interaction regresses

- **WHEN** a stable Base code, link, table, widget, responsive, or focus behavior changes unexpectedly
- **THEN** product verification SHALL fail

#### Scenario: Pattern implementation is refactored compatibly

- **WHEN** a Pattern retains its author-facing behavior, reading order, accessibility, and containment but changes internal markup
- **THEN** verification SHALL allow the refactor

#### Scenario: Lab graduates to a stable tier

- **WHEN** a Lab experiment is selected for repeated documentation use
- **THEN** a reviewed change SHALL move it to Pattern or Base
- **AND** that change SHALL define its authoring interface and stronger tests

### Requirement: Foundation records the full catalog without creating empty pages

The documentation foundation SHALL create tier indexes and a complete 42-item catalog covering B01–B15, P01–P16, and L01–L11, but SHALL create individual showcase pages only when their content and acceptance behavior are ready for the corresponding implementation batch.

#### Scenario: Foundation tranche is implemented

- **WHEN** the first content-foundation implementation completes
- **THEN** Base, Pattern, and Lab indexes plus the catalog SHALL exist
- **AND** dozens of empty showcase tiddlers SHALL NOT be created merely to match the catalog count
