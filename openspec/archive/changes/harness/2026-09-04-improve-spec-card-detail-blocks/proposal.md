## Why

The existing Scenario Card upgrade permits five optional quoted labels after a Scenario, but its visible template stops there and current specifications use the richer form only selectively. User feedback correctly identified that this does not yet feel like a Task Card, where one node can own quoted metadata plus useful ordered or unordered Markdown beneath it. Authors cannot see whether a Scenario may carry a free detail block, list, example, or table without inferring that permission from prose.

## What Changes

- Define the Scenario heading as the owner of one progressive detail block after its behavioral clauses.
- Permit useful blockquotes, prose, ordered or unordered lists, examples, and tables as ordinary Markdown within that block.
- Keep `WHEN` and `THEN` as the required behavioral spine; an ordered list may explain durable protocol order or rule precedence but must not become implementation steps or task state.
- Make the project template and lifecycle Skills visibly demonstrate the flexible form.
- Enrich one representative Scenario in each current Harness capability so the convention is easy to discover in real specifications.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `harness/core`: Broaden progressive Scenario Card authoring from fixed optional labels to a visible free-form detail block.
- `harness/workspace`: Demonstrate Scenario-owned unordered detail for per-session isolation.
- `harness/git`: Demonstrate an ordered durable result sequence for resumable partial commits.
- `harness/unreal`: Demonstrate an ordered terminal timeout contract.

## Impact

This parent-repository authoring Change updates project-local OpenSpec references, template/prompts, lifecycle Skills/tests, and four current Harness specs. It does not change the portable parser, validator profiles, `Tools/openspec`, packaged executable, runtime implementation, UE code, or Task DAG semantics.

## Non-Goals

- Do not require details on every Scenario or create empty placeholders.
- Do not nest a second schema under each individual `WHEN` or `THEN` clause.
- Do not turn spec lists into implementation instructions, checkboxes, dependency edges, Ready state, or execution evidence.
- Do not bulk-fill all compact scenarios with boilerplate.
