## ADDED Requirements

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
