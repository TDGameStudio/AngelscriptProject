## Purpose

Provide a local workbench for understanding OpenSpec records and task relationships while editing project Markdown without losing workflow syntax or concurrent changes.

## Requirements

### Requirement: Workspace-scoped local access

Harness Web SHALL bind one selected Git workspace to a loopback web service. Its product adapter MAY invoke only fixed read-only commands of the packaged OpenSpec executable in that workspace; normal agent calls remain Harness-owned. File access MUST reject paths outside permitted project content, including symbolic-link and junction escapes.

#### Scenario: Browse current project records
- **WHEN** a user opens the workbench
- **THEN** it shows the selected workspace's domains, specifications, active changes, archives and project Markdown with search and deep links
- **AND** missing records and unavailable CLI data have explicit empty or error states

#### Scenario: Reject filesystem escape
- **WHEN** a request addresses an external real path or an excluded dependency directory
- **THEN** the server rejects the request without reading or modifying that content

#### Scenario: Continue browsing during external archival
- **WHEN** an external OpenSpec workflow archives a Change while the workbench is running
- **THEN** the workbench's file listener does not prevent the directory move
- **AND** subsequent record and document refreshes reflect the moved archive

### Requirement: Authoritative task projections

Task lists, boards, dependency graphs and metrics SHALL use portable OpenSpec task-plan results. Artifact completeness SHALL be distinct from task completion. No view SHALL create execution state or mutate tasks through dragging or checkbox interaction.

#### Scenario: Inspect dependencies
- **WHEN** a task is selected in a board or graph
- **THEN** its details expose prerequisites, file scope, verification command and source location
- **AND** changing view preserves the selected task

#### Scenario: Display incomplete and invalid plans
- **WHEN** required artifacts exist but tasks remain incomplete
- **THEN** the interface reports artifact readiness separately from task progress
- **AND** absent tasks show planning status and invalid plans display diagnostics instead of trustworthy readiness

### Requirement: Protected rich Markdown editing

Editable Markdown SHALL offer visual body editing while preserving frontmatter, machine task syntax and unsupported source blocks. No-edit sessions SHALL preserve original bytes. Archive records, applied replans and hash-bound evidence SHALL remain read-only. Ordinary Markdown may normalize formatting after body edits while retaining semantic nesting, newline style and BOM.

#### Scenario: Edit prose beside protected syntax
- **WHEN** a user edits a body paragraph beside task metadata or an unsupported block
- **THEN** saving changes the prose while retaining protected source content
- **AND** nested Scenario Card lists, quotes and tables remain owned by their original clause

#### Scenario: Preserve a concurrent edit
- **GIVEN** the browser has unsaved edits and another process changes the same file
- **WHEN** the browser attempts to save its previous content revision
- **THEN** saving reports a conflict and preserves the browser draft and external file

### Requirement: Accessible factual exploration

The interface SHALL provide light and dark themes, keyboard navigation, factual charts and document/task/search navigation. Charts SHALL derive counts and dates from actual records, provide textual alternatives, and never fabricate task history.

#### Scenario: Filter and inspect a chart
- **WHEN** a user chooses a domain or task-state chart value
- **THEN** the matching records or tasks become available with the selected filter

#### Scenario: Use a narrow screen
- **WHEN** the viewport cannot accommodate the desktop panels
- **THEN** navigation and details remain reachable without covering document controls

#### Scenario: Select documents within a Change
- **WHEN** a user opens a Change containing planning documents, specification deltas and evidence
- **THEN** a vertical searchable document explorer identifies the selected file beside the reading pane
  - Nested paths remain distinguishable and long filenames remain discoverable.
  - Switching files preserves the selected record and its browsing filters.
- **AND** the desktop detail uses available workspace width without retaining a competing record-list rail
- **AND** narrow screens retain access to both file selection and document content without horizontal page overflow
