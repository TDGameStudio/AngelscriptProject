## MODIFIED Requirements

### Requirement: Offline publish produces complete HTML

The Wiki product build SHALL return success only after the configured HTML output exists, is non-empty, contains a complete closing `</html>` tag, and satisfies product artifact validation.

#### Scenario: Successful offline product build

- **WHEN** a maintainer runs `pnpm run build:wiki` in `Wiki/`
- **THEN** the command SHALL exit with code 0
- **AND** `Wiki/dist/index.html` SHALL be complete and within the checked size budget
- **AND** no plugin library or standalone plugin JSON packages SHALL remain in `dist/`

#### Scenario: Incomplete output is not accepted

- **WHEN** the renderer creates an empty or truncated output file
- **THEN** the builder SHALL continue waiting until the completion condition is met or the timeout expires
- **AND** it SHALL not report success for the incomplete file

### Requirement: Existing offline publish contents remain included

The product-level builder SHALL preserve Wiki tiddlers, approved source plugins, the Angelscript theme, and configuration without generating or retaining an intermediate plugin library.

#### Scenario: Theme and configuration are included

- **WHEN** the offline product build completes
- **THEN** the generated Wiki SHALL include the approved theme, tools, configuration, and document integrations
- **AND** the default theme selection SHALL remain available
- **AND** `dist/library` SHALL be absent

