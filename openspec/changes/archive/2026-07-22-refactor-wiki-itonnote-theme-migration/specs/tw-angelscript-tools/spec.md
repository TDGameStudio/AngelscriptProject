## ADDED Requirements

### Requirement: AngelScript code card colors align with Highlight.js presentation

The `as-code` widget SHALL map its existing semantic token classes to a Highlight.js-compatible, Notion-light color presentation without requiring Highlight.js to parse AngelScript.

#### Scenario: Render AngelScript beside a generic highlighted block

- **WHEN** a reader views an `as-code` AngelScript card and a generic code block highlighted by the official TiddlyWiki Highlight plugin
- **THEN** both code surfaces SHALL use compatible readable foreground, background, keyword, type, string, number, comment, and function color roles
- **AND** the AngelScript card SHALL retain its own semantic token classes

## MODIFIED Requirements

### Requirement: AngelScript code receives semantic browser highlighting

The Wiki plugin SHALL render AngelScript source with escaped text and stable semantic token classes for keywords, types, macros, strings, numbers, comments, functions, and operators. The widget SHALL use its own AngelScript tokenizer and SHALL visually map those classes to Highlight.js-compatible roles.

#### Scenario: Highlight a representative AngelScript snippet

- **WHEN** a tiddler renders an `as-code` widget containing a class, type, macro, string, number, comment, and function call
- **THEN** the code surface SHALL preserve the original source text
- **AND** the matching semantic spans SHALL expose stable `as-code-token--*` classes with Highlight.js-compatible styling

#### Scenario: Source contains HTML-sensitive characters

- **WHEN** AngelScript source contains `<`, `>`, `&`, or quotes
- **THEN** the rendered code SHALL display those characters as text
- **AND** it SHALL NOT create executable or structural HTML from the source

### Requirement: The Wiki exposes an accessible as-code widget

The plugin SHALL expose an `as-code` widget that supports a title, optional line numbers, and a copy action without requiring a live Unreal or LSP connection.

#### Scenario: Render a titled code card

- **WHEN** an author writes `<$as-code language="angelscript" title="Example">` with source children
- **THEN** the Wiki SHALL render a code card with the title and highlighted source
- **AND** the card SHALL expose a meaningful code region to assistive technology

#### Scenario: Render line numbers

- **WHEN** the `lineNumbers` attribute is not `no`
- **THEN** the widget SHALL render one line-number element for each source line
- **AND** line numbers SHALL remain visually separate from copyable source text

#### Scenario: Copy source

- **WHEN** a reader activates the copy control
- **THEN** the widget SHALL attempt to copy the original unformatted source
- **AND** the control SHALL expose a visible or accessible copied/error state

### Requirement: Plugin behavior remains browser-only and additive

The first plugin version SHALL not require Node filesystem APIs, Unreal TCP access, or a running Language Server to render code.

#### Scenario: Wiki builds without Unreal services

- **WHEN** the Wiki build and dev server run without Unreal Editor or port `27099`
- **THEN** the plugin SHALL still build and render its example widget
