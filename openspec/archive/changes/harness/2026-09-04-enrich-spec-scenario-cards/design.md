## Context

The current workflow uses `record-v1`, where durable specs are optional and the parser validates record structure without imposing a required Requirement/Scenario dialect. Existing Harness specs nevertheless use a consistent Requirement plus Scenario convention. Every current Harness scenario has one `WHEN` and one `THEN`, which is intentionally lightweight but underspecifies complex cases.

The repository already uses flexible Task Cards: a small validated surface owns identity, dependency, files, and verification, while ordinary Markdown adds only useful context. Scenario authoring can use the same progressive-detail principle without borrowing task state or making prose machine-readable.

## Goals / Non-Goals

**Goals:**

- Give authors one discoverable, central convention for compact and detailed behavioral scenarios.
- Preserve the existing parser, current specs, and `record-v1` workflow compatibility.
- Make delta-to-current synchronization semantics explicit enough to preserve optional detail.
- Demonstrate the convention selectively in real Harness contracts.
- Keep behavioral truth, design rationale, implementation work, and run evidence in their existing owners.

**Non-Goals:**

- A new parser grammar, validation profile, scenario identifier, or task-like execution graph.
- A mandatory field matrix or mechanical expansion of all scenarios.
- Changes to OpenSpec Rust source, the packaged executable, plugin code, Unreal routes, or test execution.

## Decisions

### 1. Scenario Card is progressive ordinary Markdown

The normative behavioral shape is:

```markdown
### Requirement: <durable behavior name>
The system SHALL <durable externally observable behavior>.

#### Scenario: <specific observable case>
- **GIVEN** <optional starting state>
- **WHEN** <required trigger or action>
- **THEN** <required primary observable result>
- **AND** <optional additional result>
- **BUT** <optional negative guarantee>

> Context: <optional authoring context>
> Inputs: <optional bounded inputs>
> Observables: <optional externally visible evidence>
> Boundaries: <optional exclusions or safety limits>
> Verification: <optional stable oracle or test family>
```

Only `WHEN` and `THEN` remain expected in an ordinary behavioral scenario. `GIVEN`, `AND`, `BUT`, and every quoted detail line are optional. Authors delete unused lines rather than retaining empty boilerplate. The labels are authoring aids; OpenSpec does not parse, count, order, or require them.

This mirrors Flexible Task Cards only at the authoring principle. A Scenario Card never gains task IDs, checkboxes, dependencies, Ready state, file ownership, or execution commands.

### 2. Content ownership stays explicit

- Specs own durable, externally observable behavior and stable behavioral boundaries.
- Design owns implementation choices, alternatives, compatibility, and technical rationale.
- Tasks own file paths, implementation steps, dependency edges, and exact execution commands.
- Attachments own one-off observations, run output, investigation history, and closure evidence.

`Verification` names a stable oracle, test family, invariant, or acceptance route. It does not embed transient output or turn the scenario into a task.

### 3. Delta synchronization preserves the whole named card

- `ADDED` requirements carry complete new Scenario Cards.
- Under `MODIFIED`, a same-named scenario replaces that scenario's complete card; a new scenario name appends a card.
- Existing scenarios and optional detail not named by a delta remain unchanged.
- The requirement body changes only when the delta explicitly supplies a replacement body.
- Synchronization removes delta section headers while retaining all Scenario Card detail as ordinary Markdown.

These rules are documented authoring policy, not a new CLI merge implementation. The `openspec-sync-specs` Skill continues to perform the semantic merge and validates the result.

Scenario reparenting is not introduced as a generic delta operation. The four workspace discovery/status scenarios are a confirmed current-spec ownership defect, so this Change treats their move as one explicit structural correction during synchronization: each named card is removed from the wrong requirement, inserted under the named owning requirement, and verified to occur exactly once. The delta shows their intended owner; it does not establish an implicit rule that any repeated scenario name means move.

### 4. Keep `record-v1`

`record-v1` is the correct project profile because this repository intentionally allows Changes without durable spec deltas. `requirements-v1` would require at least one delta spec for every Change and would alter the general lifecycle for maintenance, documentation, and pure refactors. The names identify validation profiles, not successive content formats; Scenario Card richness is orthogonal to both.

### 5. Enrich representative scenarios, not the catalog

The change adds two self-hosting Core scenarios and enriches 27 existing scenarios selected for meaningful state, safety, integration, or evidence boundaries. All remaining simple scenarios retain their current compact `WHEN` / `THEN` form.

The Unreal concurrency card explicitly limits automated evidence to policy, lane, argument, and path-isolation fixtures. It does not claim two real UBT processes were executed end to end. The long-worktree scenario remains compact because current evidence does not prove its full live acceptance boundary.

## Risks / Trade-offs

- Rich detail can drift into design or task content. The ownership rules and lifecycle Skill guidance provide a reviewable boundary.
- A quoted label may look machine-readable. The central reference and tests explicitly state that labels are optional ordinary Markdown.
- Manual semantic synchronization can accidentally drop detail. The sync Skill guidance, representative delta specs, current-spec assertions, and strict validation cover this failure mode without modifying the CLI.
- Existing consumers that count headings and scenarios remain compatible because requirement and scenario headings are unchanged.

## Rollback

The change is documentation- and Markdown-only. Reverting the parent commit restores the prior authoring guidance and compact specs; no data migration, binary rollback, submodule operation, or UE cleanup is required.
