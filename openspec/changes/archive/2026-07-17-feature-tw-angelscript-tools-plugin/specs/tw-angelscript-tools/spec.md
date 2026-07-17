## ADDED Requirements

### Requirement: AngelScript code receives semantic browser highlighting

The Wiki plugin SHALL render AngelScript source with escaped text and stable semantic token classes for keywords, types, macros, strings, numbers, comments, functions, and operators.

#### Scenario: Highlight a representative AngelScript snippet

- **WHEN** a tiddler renders an `as-code` widget containing a class, type, macro, string, number, comment, and function call
- **THEN** the code surface SHALL preserve the original source text
- **AND** the matching semantic spans SHALL expose stable `as-code-token--*` classes

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
