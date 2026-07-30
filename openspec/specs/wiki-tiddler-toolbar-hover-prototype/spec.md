# wiki-tiddler-toolbar-hover-prototype Specification

## Purpose
TBD - created by archiving change improve-wiki-tiddler-toolbar-hover-layout. Update Purpose after archive.
## Requirements
### Requirement: Standalone prototype compares inherited and compact toolbar geometry

The repository SHALL provide a self-contained HTML comparison artifact for the desktop tiddler titlebar. It SHALL render the current and proposed toolbars side by side at desktop width, with the same More, Edit, Close, and New Diagram action order and equivalent no-fill line icon styling.

#### Scenario: Reviewer inspects the desktop comparison

- **WHEN** the reviewer opens `tiddler-toolbar-hover-layout.html` at a desktop viewport
- **THEN** the artifact SHALL show a labelled current sample with 32×39.48px contiguous controls and 24px icons
- **AND** it SHALL show a labelled proposed sample with 32×32px controls, 20px icons, 2px gaps, and 5px rounded hover surfaces
- **AND** it SHALL explain that the current height is inherited from the titlebar line-height and becomes approximately 48×59px at 150% display scale

### Requirement: Prototype states are accessible and geometrically stable

The comparison artifact SHALL use native buttons with accessible action names. Hover, pressed, and keyboard focus feedback SHALL preserve each button's layout bounds and SHALL use a colour-only transition no longer than 140ms.

#### Scenario: Reviewer hovers or focuses a proposed action

- **WHEN** the reviewer hovers, presses, or tabs to a proposed toolbar action
- **THEN** only the targeted action SHALL receive its state treatment
- **AND** its width, height, position, and neighbouring control geometry SHALL remain unchanged
- **AND** keyboard focus SHALL remain visibly distinguishable without relying on colour alone

### Requirement: Prototype remains reviewable on a narrow viewport

The standalone artifact SHALL remain usable at a 390px viewport without horizontal overflow.

#### Scenario: Reviewer opens the comparison on a narrow screen

- **WHEN** the viewport width is 390px
- **THEN** the current and proposed samples SHALL stack vertically
- **AND** each toolbar SHALL remain fully visible and keyboard reachable
- **AND** the document SHALL have no horizontal scroll extent

### Requirement: Approved desktop titlebar uses compact direct controls

After the prototype is approved, the live Angelscript Wiki desktop titlebar SHALL render direct tiddler actions as a compact group. The theme SHALL use 32×32px direct controls with 20px no-fill line icons, 2px group gaps, 5px rounded hover surfaces, and 140ms colour-only feedback. It SHALL preserve action behavior, popup/menu markup, generated icon assets, and the mobile navigation behavior.

#### Scenario: Reader hovers a desktop tiddler action

- **WHEN** a reader hovers a direct titlebar action at a desktop viewport
- **THEN** the action SHALL be a 32×32px control with a 20px no-fill line icon
- **AND** neighboring direct actions SHALL be separated by 2px and SHALL not move during the 140ms colour feedback
- **AND** the More popup menu rows SHALL retain their existing grid layout, 30px height, 16px icons, and icon/text vertical alignment

#### Scenario: Reader opens the same tiddler on a narrow viewport

- **WHEN** the viewport is below the desktop sidebar breakpoint
- **THEN** the desktop compact-group rule SHALL NOT apply
- **AND** the existing mobile titlebar and navigation behavior SHALL remain unchanged
