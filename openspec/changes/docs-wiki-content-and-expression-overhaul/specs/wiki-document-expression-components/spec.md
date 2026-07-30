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
