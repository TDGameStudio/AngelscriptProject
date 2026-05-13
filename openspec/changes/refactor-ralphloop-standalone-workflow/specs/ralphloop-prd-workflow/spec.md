## ADDED Requirements

### Requirement: Read-only PRD story selection
RalphLoop SHALL support a PRD workflow that reads a Ralph-style PRD file, selects the first incomplete user story by ascending priority and file order, and does not mutate the PRD file.

#### Scenario: Select next incomplete story
- **WHEN** the PRD contains multiple user stories with `passes` not equal to true
- **THEN** RalphLoop selects the incomplete story with the lowest numeric priority and preserves file order for ties

#### Scenario: No incomplete stories remain
- **WHEN** the PRD contains no incomplete user stories
- **THEN** RalphLoop exits successfully and records a `prd-complete` final state

### Requirement: PRD prompt context
RalphLoop SHALL inject selected PRD story context and progress text into the rendered iteration prompt.

#### Scenario: Story context appears in prompt
- **WHEN** RalphLoop runs in PRD workflow with a selected story
- **THEN** the rendered prompt includes the selected story id, title, description, acceptance criteria, notes, PRD metadata, and progress text

#### Scenario: PRD audit artifacts are written
- **WHEN** RalphLoop runs in PRD workflow with a selected story
- **THEN** each iteration writes the selected story and progress context artifacts for auditability
