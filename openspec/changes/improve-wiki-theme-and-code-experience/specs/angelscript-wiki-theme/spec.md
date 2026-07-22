## MODIFIED Requirements

### Requirement: Angelscript visual theme

The local Angelscript theme SHALL preserve its itonnote-derived, fixed Notion-light document layout while providing readable text, visible keyboard focus, document-oriented sidebar and tiddler presentation, and one classic Tomorrow presentation for generic and UE AngelScript code. Desktop refinements SHALL retain the existing right sidebar, zoomed story view, content structure, and fixed-light behavior.

#### Scenario: Refined document theme is active on desktop

- **WHEN** the development Wiki selects `$:/themes/angelscript` at a desktop viewport
- **THEN** page, story river, tiddlers, sidebar, controls, links, code blocks, and editors SHALL retain the migrated document structure
- **AND** keyboard-focus indicators SHALL be visible
- **AND** muted UI text and interactive accents SHALL remain readable on the Notion-light surface
- **AND** the existing sidebar segments SHALL remain available in the 320px right sidebar

#### Scenario: Code is rendered beside the fixed-light document theme

- **WHEN** a generic or UE AngelScript code block is displayed under either a light or dark operating-system preference
- **THEN** it SHALL use the same classic Tomorrow token roles, Fira Code typography, restrained light surface, border, spacing, and copy-control presentation
- **AND** the Wiki SHALL remain on the configured Notion-light palette

#### Scenario: Narrow-screen regression

- **WHEN** the same document is viewed at a narrow viewport
- **THEN** the page SHALL avoid document-level horizontal overflow
- **AND** long code SHALL scroll within its own code surface
- **AND** existing mobile sidebar-close and bottom-control behavior SHALL remain usable
