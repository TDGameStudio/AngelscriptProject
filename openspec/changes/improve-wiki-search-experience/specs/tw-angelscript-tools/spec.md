## ADDED Requirements

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
