## ADDED Requirements

### Requirement: Desktop controls expose coherent interaction states

The Angelscript Wiki theme SHALL render interactive desktop controls with stable hit targets and visually distinguish default, hover, pressed, selected, and keyboard-focus states while retaining the accepted light Notion palette.

#### Scenario: Reader points and presses a desktop control

- **WHEN** a desktop reader hovers and presses a sidebar, toolbar, tab, or document control
- **THEN** the control SHALL retain its geometry without movement
- **AND** hover and pressed states SHALL be visually distinguishable from each other and from the default state

#### Scenario: Reader navigates by keyboard

- **WHEN** keyboard navigation places focus on an interactive control or document link
- **THEN** the focused element SHALL expose a visible focus indicator with sufficient contrast
- **AND** focus SHALL NOT depend on hover to become visible

### Requirement: SDK prose remains readable without constraining technical surfaces

The Angelscript Wiki theme SHALL constrain ordinary long-form prose to a readable desktop measure while allowing code cards, preformatted blocks, tables, and explicitly wide technical surfaces to use the document width.

#### Scenario: Reader opens a long SDK page

- **WHEN** a desktop reader opens a long SDK documentation tiddler
- **THEN** ordinary paragraphs and lists SHALL use a bounded readable line length
- **AND** code and table surfaces SHALL remain wide enough for technical content

### Requirement: Document links and title actions remain calm and discoverable

Document links SHALL use text emphasis appropriate for prose rather than blanket bold styling, and title actions SHALL reveal quickly on pointer or keyboard interaction without a long opacity delay.

#### Scenario: Reader interacts with a document link and title toolbar

- **WHEN** a reader hovers a body link or focuses a title action
- **THEN** the link and action SHALL visibly respond without substantially darkening the page
- **AND** title actions SHALL complete their reveal within 160 milliseconds

### Requirement: Sidebar metadata actions remain legible in the light palette

The theme SHALL render the core untagged action as quiet secondary metadata with readable foreground/background contrast and SHALL NOT apply the ordinary dark tag surface to that action.

#### Scenario: Reader opens the Tags section under More

- **WHEN** the reader views the localized untagged action
- **THEN** the action SHALL use `#eef2f7` background, `#5d6b7b` foreground, and a subtle neutral border
- **AND** hover SHALL reuse the existing light blue interaction treatment
- **AND** ordinary tagged-title colors SHALL remain unchanged
