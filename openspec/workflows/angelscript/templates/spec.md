## Purpose
<!-- New capabilities only: one or two sentences (50+ characters) on what this capability is for. Delete this section for an existing capability. -->

<!-- Follow .agents/skills/openspec/references/specs.md. Actively evaluate every new or modified behavior clause. Prefer the smallest useful combination of quoted notes, prose, ordered or unordered lists, examples, and tables beneath its exact owner; omit a form when it adds no durable information and delete every unused optional line. -->

## ADDED Requirements

### Requirement: <!-- requirement name -->
The system SHALL <!-- durable externally observable behavior -->.

#### Scenario: <!-- scenario name -->
- **GIVEN** <!-- optional starting state; delete when unused -->
  > Context: <!-- optional durable context for this GIVEN; delete when unused -->
- **WHEN** <!-- required trigger or action -->
  > Inputs: <!-- optional relevant inputs for this WHEN; delete when unused -->
  >
  > Details: <!-- optional durable explanation for this WHEN; delete when unused -->

  <!-- Optional clause-owned prose; explain only durable information not already clear above. -->

  1. <!-- optional durable behavior order or rule precedence; not implementation steps -->
  2. <!-- optional next durable result; delete the list when unused -->
- **THEN** <!-- required primary observable result -->
  > Observables: <!-- optional externally visible evidence for this THEN; delete when unused -->

  - Example: <!-- optional durable example; delete when unused -->
  - <!-- optional durable result or edge case; delete the list when unused -->

  | <!-- optional comparison field --> | <!-- durable interpretation --> |
  |---|---|
  | <!-- optional value --> | <!-- optional result or boundary; delete the table when unused --> |
- **AND** <!-- optional additional result; delete when unused -->
  > Verification: <!-- optional stable oracle or test family for this AND; delete when unused -->
- **BUT** <!-- optional negative guarantee; delete when unused -->
  > Boundaries: <!-- optional exclusion or limit for this BUT; delete when unused -->

<!-- Each clause-owned detail block is indented beneath its exact behavior item. Actively evaluate it and retain the smallest useful combination; omit every form that adds no durable information. The complete palette is quoted notes, prose, ordered or unordered lists, examples, and tables, all with no Task state. -->
