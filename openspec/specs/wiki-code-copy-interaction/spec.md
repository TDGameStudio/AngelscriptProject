# wiki-code-copy-interaction Specification

## Purpose
TBD - created by archiving change improve-wiki-code-copy-interaction. Update Purpose after archive.
## Requirements
### Requirement: Code blocks expose a recognizable accessible copy action

Ordinary core code blocks and AngelScript code cards that permit copying SHALL expose the same icon-only copy control with a recognizable, low-contrast outline clipboard-and-document glyph, localized `title` and `aria-label`, and an `aria-live` status region. The control SHALL retain the existing source-selection and clipboard behavior.

#### Scenario: Reader encounters an idle copy-enabled code block
- **WHEN** a core `$codeblock` or `$angelscript-code` block is rendered with copying enabled
- **THEN** it SHALL contain the shared `.code-copy-button` and `.code-copy-status` elements
- **AND** the idle button SHALL use the recognizable Copy icon and the localized copy label

#### Scenario: Reader completes or fails a copy action
- **WHEN** the current copy attempt resolves successfully or fails
- **THEN** the button SHALL expose the corresponding localized state through its icon, `aria-label`, and live status
- **AND** it SHALL restore the idle Copy icon, label, and empty live status after 1.5 seconds

### Requirement: Code-block copy visibility adapts without losing access

The shared copy control SHALL reduce visual noise on desktop fine-pointer devices while remaining operable by keyboard and discoverable on touch or no-hover devices.

#### Scenario: Desktop reader approaches a code block
- **WHEN** an idle copy-enabled code block is displayed on a device matching `(hover: hover) and (pointer: fine)`
- **THEN** its idle copy control SHALL be visually hidden and ignore pointer input
- **AND** it SHALL become visible when the code block is hovered, when the control is in the code block's focus chain, or while it shows a copied or error state

#### Scenario: Touch reader views a code block
- **WHEN** an idle copy-enabled code block is displayed on a no-hover or coarse-pointer device
- **THEN** its copy control SHALL remain visibly available with low visual emphasis
- **AND** the reader SHALL be able to activate it without a preceding hover interaction

### Requirement: Repeated copy attempts report the latest result

The shared copy control SHALL remain enabled for repeated activation, and only the most recently started copy attempt may update its feedback state.

#### Scenario: Reader copies twice before the first feedback window ends
- **WHEN** a reader activates a copy button again while a previous copy result is displayed
- **THEN** the second attempt SHALL remain actionable
- **AND** its result SHALL restart the 1.5-second feedback window
- **AND** a stale callback from an older attempt SHALL NOT replace the newer feedback state
