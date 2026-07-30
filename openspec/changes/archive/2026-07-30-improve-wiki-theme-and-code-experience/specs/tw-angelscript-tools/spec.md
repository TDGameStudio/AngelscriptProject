## ADDED Requirements

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

## MODIFIED Requirements

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

## REMOVED Requirements

### Requirement: AngelScript code card colors align with Highlight.js presentation

**Reason**: The separate `as-code` renderer and its private semantic classes are replaced by the official Highlight.js pipeline, so visual alignment is now inherent rather than a compatibility mapping.

**Migration**: Use a standard `<$codeblock code=... language="angelscript"/>` for ordinary source or `<$angelscript-code code=.../>` when line presentation is needed.

### Requirement: The Wiki exposes an accessible as-code widget

**Reason**: The AngelScript-specific card duplicates the generic rendering engine and does not support the author-controlled source ranges required by SDK documentation.

**Migration**: Replace `$as-code` with `$angelscript-code` and supply source through its core-compatible `code` attribute.
