## ADDED Requirements

### Requirement: Tools own stable left-sidebar interaction

The tools plugin SHALL own desktop left-sidebar resizing and mobile navigation behavior while leaving sidebar appearance to the theme and defaults to the configuration plugin.

#### Scenario: Reader resizes the desktop sidebar

- **WHEN** the reader drags the resize rail
- **THEN** the live width SHALL update at most once per animation frame without writing the Wiki store on every pointer move
- **AND** the final width SHALL be persisted once when the interaction ends
- **AND** the width SHALL remain between 240px and `min(40vw, 520px)`

#### Scenario: Resize interaction is interrupted

- **WHEN** pointer capture is lost, the pointer is cancelled, or the browser loses focus
- **THEN** the interaction SHALL end safely and persist a valid final width
- **AND** it SHALL not hide the sidebar

#### Scenario: Reader uses a narrow screen

- **WHEN** the page is narrower than the configured sidebar breakpoint
- **THEN** the existing top-left overlay toggle and close-after-navigation behavior SHALL remain available
- **AND** desktop resize behavior SHALL not create horizontal overflow

## MODIFIED Requirements

### Requirement: Plugin behavior remains browser-only and additive

The tools plugin SHALL not require Node filesystem APIs, Unreal TCP access, a running Language Server, or an external service to render code or operate Wiki navigation.

#### Scenario: Wiki runs without Unreal or network services

- **WHEN** the Wiki build and browser runtime run without Unreal Editor, port `27099`, or off-origin services
- **THEN** the plugin SHALL still render code and operate the left-sidebar interactions

