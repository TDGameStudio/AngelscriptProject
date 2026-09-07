## Why

Task authoring already asks for independently testable outcomes, but the common template and execution entry do not actively enforce that boundary. The active AS reconstruction has accumulated multiple independent deliverables inside task 4.1. Its user-authorized end-of-batch first-run exception also conflicts with shared per-test TDD language. The user now explicitly chooses detailed outcome-sized tasks and feature-group RED/GREEN, preserving existing work.

## What Changes

- Plan bounded feature groups with concrete fixtures, expected failures, interfaces and completion evidence before Ready execution.
- Batch related tests in RED, implement that group, and batch GREEN; distinguish proof selection from expensive process scheduling.
- Replan pending AS work into named outcomes and retain 4.1 as its original integrated Builder acceptance, without changing AS code or past evidence.
- Verify instruction behavior with a before/after independent read-only exercise, alongside owner structural/protocol checks.

## Capabilities

### Modified Capabilities

- `harness/core`: ready-to-execute task quality and impact-scoped verification, including grouped TDD and evidence mapping.

## Impact

Parent repository only: Harness/TDD/OpenSpec instructions, the project task workflow/template, owner tests, durable Harness specification, and active AS planning records. No portable CLI/parser fields, executor APIs, UE launch profiles, plugin code, worktrees, commits or publication. Existing dirty files and the plugin source snapshot remain unchanged. The Harness change closes independently; the AS change remains active.
