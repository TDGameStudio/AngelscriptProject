# tw-angelscript-tools Specification

## Purpose
TBD - created by archiving change feature-tw-angelscript-tools-plugin. Update Purpose after archive.
## Requirements
### Requirement: AngelScript code receives semantic browser highlighting

The Wiki plugin SHALL register a repository-maintained UE AngelScript language definition with the bundled TiddlyWiki Highlight plugin. The definition SHALL preserve source text and emit standard Highlight.js semantic classes for standard AngelScript plus Unreal macros, specifiers, fork keywords, f-strings, asset syntax, UE types, strings, numbers, comments, functions, operators, preprocessor directives, handles, and generics. It SHALL use `angelscript` as the primary language name, `as` as an alias, and map `text/x-angelscript` to the primary name.

#### Scenario: Highlight a representative UE AngelScript snippet

- **WHEN** a core codeblock declares the `angelscript`, `as`, or mapped MIME language and contains representative standard and Unreal syntax
- **THEN** the official Highlight pipeline SHALL preserve the original source text
- **AND** matching spans SHALL expose standard `hljs-*` semantic classes
- **AND** no private `as-code-token--*` class or independent tokenizer SHALL be required

#### Scenario: Source contains HTML-sensitive characters

- **WHEN** UE AngelScript source contains `<`, `>`, `&`, quotes, or text resembling an HTML element
- **THEN** the rendered code SHALL display those characters as source text
- **AND** it SHALL NOT create executable or structural HTML from the source

### Requirement: Plugin behavior remains browser-only and additive

The plugin SHALL render and highlight code without Node filesystem APIs, Unreal TCP access, a running Language Server, or runtime access to the parent repository's VS Code grammar. It SHALL use the bundled Highlight.js library and SHALL not introduce another highlighting runtime dependency.

#### Scenario: Wiki builds without Unreal services

- **WHEN** the Wiki build, dev server, offline publish, or browser test runs without Unreal Editor, port `27099`, or a Language Server
- **THEN** UE AngelScript highlighting, `angelscript-code`, line presentation, and copy controls SHALL still build and render

### Requirement: Authors can present focused code ranges with a generic widget

The Wiki plugin SHALL expose an `angelscript-code` widget that accepts the core-compatible `code` attribute plus author-controlled line numbers, highlighted displayed lines, inclusive source bounds, and an optional first displayed line number. The widget SHALL always select the project's `angelscript` grammar. Attribute values SHALL use normal TiddlyWiki widget-attribute semantics, and widget body content SHALL not be treated as source.

#### Scenario: Render a sliced and highlighted source range

- **WHEN** an author supplies source with `lineNumbers="yes"`, valid `fromLine`, `toLine`, `startLine`, and `highlightLines` attributes
- **THEN** the widget SHALL render only the inclusive selected source lines through the official code-block highlighter
- **AND** the gutter SHALL show the requested displayed labels separately from copyable source
- **AND** the requested displayed line numbers SHALL receive a readable row emphasis without fading other code

#### Scenario: Use native TiddlyWiki source expressions

- **WHEN** `code` is supplied as a literal, triple-quoted literal, tiddler or field transclusion, variable, or filtered attribute value
- **THEN** the widget SHALL render the resolved attribute text as source
- **AND** HTML-sensitive source characters SHALL remain text

#### Scenario: Invalid line controls degrade safely

- **WHEN** source bounds or highlight range entries are malformed, reversed, or outside the visible range
- **THEN** invalid highlight entries SHALL be ignored
- **AND** invalid source bounds SHALL fall back to the full source while legal out-of-bounds values are clamped

### Requirement: Core code blocks expose one accessible copy action

The browser Wiki SHALL add one shared copy action to ordinary core code blocks and `angelscript-code` output after the existing Highlight post-render has run. The action SHALL copy only the rendered source text and SHALL expose localized success or error feedback.

#### Scenario: Copy an ordinary core codeblock

- **WHEN** a reader activates the copy action on a highlighted core codeblock
- **THEN** the action SHALL copy the code element's unformatted source text
- **AND** the button SHALL expose a visible or assistive copied/error state

#### Scenario: Copy a selected angelscript-code range

- **WHEN** a reader activates the copy action on a sliced `angelscript-code`
- **THEN** the action SHALL copy only the visible selected source range
- **AND** it SHALL exclude gutter labels, highlight presentation, and control text

### Requirement: AngelScript source tiddlers render through the shared highlighter

The Wiki plugin SHALL register `text/x-angelscript` as UTF-8 AngelScript source with the `.as` extension and SHALL provide a parser that renders this content type through the core code-block widget. Directly opening such a source tiddler SHALL therefore use the repository-maintained `angelscript` Highlight.js grammar, Tomorrow Light presentation, escaped source text, and shared copy behavior without requiring an author wrapper tiddler.

#### Scenario: Reader opens an AngelScript source tiddler directly

- **WHEN** a reader opens a tiddler whose type is `text/x-angelscript`
- **THEN** its text SHALL render in a core highlighted code block using the `angelscript` language mapping
- **AND** standard and UE AngelScript syntax SHALL expose the same `hljs-*` classes and Tomorrow Light colors as an explicit `$codeblock language="angelscript"`
- **AND** HTML-looking source text SHALL remain escaped and non-executable

#### Scenario: AngelScript content type is inspected

- **WHEN** the Wiki runtime inspects its registered content types and file extensions
- **THEN** `text/x-angelscript` SHALL use UTF-8 encoding and the `.as` extension
- **AND** `.as` SHALL map back to `text/x-angelscript`

### Requirement: AngelScript examples cover representative SDK syntax families

The Wiki SHALL provide a grouped AngelScript syntax gallery derived from valid project examples rather than invented pseudo-syntax. The gallery SHALL cover reflection and lifecycle declarations, structs and enums, control flow, containers and references, delegates and events, object-model extensions, strings and preprocessing, assets, and networking declarations. Each group SHALL use the enhanced code widget so line numbers, emphasis, shared highlighting, and copy behavior remain demonstrable together.

#### Scenario: Author reviews the AngelScript example gallery

- **WHEN** an author opens `AngelscriptCodeExamples`
- **THEN** seven concise topic groups SHALL represent the major language and Unreal dialect families
- **AND** every group SHALL be sourced from a `text/x-angelscript` tiddler
- **AND** every group SHALL render through the enhanced AngelScript code widget with a line-number gutter and copy control
- **AND** the existing focused-range and no-gutter examples SHALL remain available as authoring references

### Requirement: Tomorrow Light preserves semantic color without incidental bold text

The shared AngelScript highlighting pipeline SHALL follow the reference Wiki's classic Tomorrow Light semantic roles. UE reflection macros SHALL render cyan, preprocessor directives brown, class declaration titles yellow, function titles blue, keywords and types purple, numbers/attributes/symbols orange, strings green, comments muted gray, and operators plus format-string substitutions in the base foreground. Normal semantic source tokens SHALL use the code surface's regular weight; only content explicitly classified as `strong` MAY be bold.

#### Scenario: Reader views representative Unreal AngelScript

- **WHEN** a reader opens an AngelScript example containing reflection macros, a class declaration, a lifecycle function, control flow, types, strings, numbers, operators, format substitutions, a preprocessor branch, a symbol, and a comment
- **THEN** the rendered `hljs-*` scopes SHALL expose the reference Tomorrow Light color roles
- **AND** keywords, class titles, function titles, types, and built-ins SHALL compute to regular font weight
- **AND** the code surface SHALL continue to use the bundled Fira Code variable font

#### Scenario: Call-shaped control flow is highlighted

- **WHEN** AngelScript source contains `if (...)`, `for (...)`, `while (...)`, `switch (...)`, or `catch (...)`
- **THEN** the control-flow word SHALL use the `keyword` scope
- **AND** it SHALL NOT use the `title.function` scope

#### Scenario: UE macro and preprocessor roles differ

- **WHEN** source contains `UCLASS`, `UPROPERTY`, or `UFUNCTION` and also contains `#if` or `#endif`
- **THEN** the UE macro name SHALL use the cyan `built_in` role
- **AND** the preprocessor directive SHALL use the brown `meta` role

### Requirement: Code-copy result is icon-confirmed and localized

The AngelScript code card copy action SHALL use a language-neutral visible icon, SHALL expose localized accessible labels and live status from the active TiddlyWiki language pack, and SHALL restore its normal icon after a short interval.

#### Scenario: Reader copies an AngelScript example

- **WHEN** the original source is copied successfully
- **THEN** the copy control SHALL visibly switch from the copy icon to a success icon without placing text inside the button
- **AND** localized `title`, `aria-label`, and live status SHALL identify the result
- **AND** the normal copy icon SHALL return automatically without requiring another interaction

### Requirement: Authors can bound a long AngelScript source viewport

The AngelScript code-card widget SHALL accept an optional `maxVisibleLines` author attribute that bounds only the visible vertical viewport while preserving the complete source range selected by `fromLine` and `toLine`, the displayed numbering selected by `startLine`, and the displayed emphasis selected by `highlightLines`.

#### Scenario: Reader scrolls a long focused source range

- **WHEN** an author selects more source lines than the configured `maxVisibleLines`
- **THEN** the code surface SHALL have vertical overflow that the reader can scroll with the mouse wheel or scrollbar
- **AND** lines outside the initial viewport SHALL remain rendered and reachable

#### Scenario: Reader copies from a bounded viewport

- **WHEN** the reader copies a code card whose selected source range is longer than its visible viewport
- **THEN** the copy result SHALL contain the complete selected source range
- **AND** viewport scrolling SHALL NOT change copied content, displayed line numbers, or highlighted-line semantics

#### Scenario: Author omits or exceeds the viewport bound

- **WHEN** `maxVisibleLines` is omitted
- **THEN** the code card SHALL retain its existing unconstrained vertical behavior
- **AND WHEN** an author supplies an out-of-range numeric value
- **THEN** the widget SHALL clamp it to the documented 3–80 line range

### Requirement: Code scrollbars remain visually subordinate

Every AngelScript code scroll surface SHALL use the same thin scrollbar geometry and low-contrast neutral color, while a bounded vertically overflowing viewport SHALL additionally remain mouse-wheel scrollable without adding a second heavy panel border.

#### Scenario: Reader points at an overflowing code viewport

- **WHEN** an AngelScript code viewport has horizontal or vertical overflow and the reader points within it
- **THEN** its scrollbar thumb SHALL become easier to perceive without changing scrollbar width
- **AND** the code card layout SHALL NOT shift
