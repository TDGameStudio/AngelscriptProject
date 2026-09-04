# Fix Spec Clause Detail Blocks

## Why

The preceding Scenario Card upgrade attached one optional detail block to the Scenario as a whole. The user intended the existing Task Card composition model instead: an individual `GIVEN`, `WHEN`, `THEN`, `AND`, or `BUT` list item may own indented explanatory content and nested lists immediately below that item. The current template therefore demonstrates the wrong ownership and makes it unclear which behavior clause a detail qualifies.

## What Changes

- Make each Scenario behavior clause the owner of its own optional indented detail block.
- Show Task-like quoted notes and ordered or unordered lists nested beneath the exact clause they explain.
- Update OpenSpec authoring guidance, workflow prompts, lifecycle Skills, and focused contract tests to preserve clause ownership.
- Correct representative current Harness Scenario Cards in Core, Workspace, Git, and Unreal specifications.

## Boundaries

- `WHEN` and `THEN` remain the ordinary required behavioral spine; `GIVEN`, `AND`, and `BUT` remain optional.
- Nested detail remains ordinary Markdown with no parser field, checkbox, dependency edge, Ready state, or execution state.
- Simple clauses remain one line. Authors add detail only to the clause that needs it and never add empty placeholders.
- Ordered lists express durable behavior order, state progression, or rule precedence, not source-edit or test-execution steps.
- The portable `Tools/openspec` source and executable remain unchanged.

## Success

The central contract and project template visibly match Task Card nesting, focused tests prove details are indented beneath individual clauses, all representative current cards preserve that ownership, strict OpenSpec validation passes, and the Change closes through the normal Harness self-hosting lifecycle.
