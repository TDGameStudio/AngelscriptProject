# wiki-left-sidebar-layout Specification

## Purpose
TBD - created by archiving change feature-wiki-syntax-showcase. Update Purpose after archive.
## Requirements
### Requirement: Desktop navigation is a left-side fluid-fixed sidebar
The Wiki SHALL render its desktop `fluid-fixed` sidebar at the left edge and the story river to its right. The repository default sidebar width SHALL be `280px`; a user drag SHALL write the existing sidebar-width metric from the pointer's horizontal position without applying the former 320–600px bounds, auto-hiding the sidebar, or assigning double-click collapse behavior.

#### Scenario: A desktop reader resizes the sidebar
- **WHEN** the reader drags the local left-edge resize rail to a valid viewport x-coordinate
- **THEN** the sidebar width SHALL follow that coordinate, the sidebar state SHALL remain unchanged, and the story river SHALL begin to the right of the resized sidebar

### Requirement: Sidebar controls retain compact accessible behavior at the page top-left
The Wiki SHALL keep the existing `$:/state/sidebar` show/hide behavior and render its control in the fixed page top-left location in either state. On desktop the control SHALL become visually visible on pointer hover or keyboard focus while remaining interactable; on narrow screens it SHALL remain visibly available and SHALL NOT become a full-height vertical bar.

#### Scenario: A reader hides and restores the desktop sidebar
- **WHEN** the reader activates the left-top hide control and then the left-top show control
- **THEN** the sidebar SHALL hide and restore through `$:/state/sidebar`, while the story river expands to full desktop width when hidden

### Requirement: Narrow-screen navigation opens as a left overlay drawer
The Wiki SHALL keep the narrow-screen sidebar as a left-anchored overlay drawer. Opening it SHALL NOT move the story river or place the control on the right edge.

#### Scenario: A narrow-screen reader opens navigation
- **WHEN** a reader activates the visible left-top show control on a narrow screen
- **THEN** the sidebar drawer SHALL open from the left and the story river's horizontal position SHALL remain unchanged
