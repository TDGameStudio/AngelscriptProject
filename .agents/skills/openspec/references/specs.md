# Specification and Scenario Card Contract

Read this reference when creating, modifying, synchronizing, or verifying durable specifications. A specification exists only when behavior is worth preserving beyond the current implementation task. Maintenance, documentation, and internal refactors that do not change durable behavior do not need a synthetic spec delta.

## Requirement ownership

A Requirement names one durable capability or invariant and states externally observable behavior with `SHALL`, `MUST`, or another intentional normative keyword. A Scenario demonstrates one specific observable case beneath its owning Requirement. Keep technical construction and one-off proof out of both.

```markdown
### Requirement: <durable behavior name>

The system SHALL <durable externally observable behavior>.

#### Scenario: <specific observable case>
- **GIVEN** <optional starting state>
- **WHEN** <required trigger or action>
- **THEN** <required primary observable result>
- **AND** <optional additional result>
- **BUT** <optional negative guarantee>

> Context: <optional durable context>
> Inputs: <optional relevant inputs>
> Observables: <optional externally visible evidence>
> Boundaries: <optional exclusions or limits>
> Verification: <optional stable oracle or test family>
>
> Details: <optional durable explanation, behavior order, rules, or examples>
>
> 1. <optional durable protocol step or rule-precedence item>
> 2. <delete the whole list when unused>
>
> - <optional durable example, edge case, or boundary>
```

## Scenario Card

Every ordinary behavioral Scenario Card has one clear `WHEN` and one clear `THEN`. Add `GIVEN`, `AND`, or `BUT` only when the additional behavioral clause materially clarifies the case. The Scenario heading owns one optional progressive detail block after its behavioral clauses. That block may combine labeled blockquotes with short prose, ordered or unordered lists, examples, and tables. The quoted labels are optional:

- `Context` gives durable background needed by a zero-context reader.
- `Inputs` bounds the values, identities, or state entering the behavior.
- `Observables` names externally visible results or evidence surfaces.
- `Boundaries` states exclusions, safety limits, or what the scenario does not guarantee.
- `Verification` identifies a stable invariant, test family, fixture, or acceptance route.
- `Details` introduces useful free-form Markdown when fixed labels alone would make the card harder to read.

These clauses, labels, paragraphs, lists, examples, and tables are ordinary Markdown authoring aids, not parser fields, IDs, checkboxes, dependency edges, Ready state, or execution state. An ordered list may clarify durable behavior order, state progression, or rule precedence; it must not prescribe source edits or implementation execution. An unordered list may collect durable rules, examples, or edge cases. Authors may omit, reorder, or combine every optional form. Always delete unused lines and the entire unused detail block. A simple scenario that is complete with `WHEN` and `THEN` stays compact; do not fill it with empty or boilerplate fields.

`Verification` does not mean a test ran. It names the durable oracle and never replaces task verification or retained run evidence.

## Content boundaries

| Owner | Content |
|---|---|
| Specs | Durable externally observable behavior, protocol order, rule precedence, examples, stable boundaries, and stable proof expectations |
| Design | Technical choices, alternatives, compatibility, migration, and rationale |
| Tasks | Files, implementation steps, dependency edges, exact commands, and completion state |
| Attachments | One-off evidence, observations, implementation issues, Reviews, talks, replans, and closure data |

Do not disguise implementation steps as behavior, copy command output into a Scenario Card, or use a spec as a second task list. Promote only the durable conclusion from one-off evidence.

## Delta authoring and synchronization

Change-local delta specs use the established `ADDED`, `MODIFIED`, `REMOVED`, and `RENAMED` Requirement sections:

- `ADDED` carries the complete new Requirement and its complete Scenario Cards.
- In `MODIFIED`, a same-name scenario replaces that scenario's complete Scenario Card. The delta author must repeat every still-valid optional clause, label, paragraph, list, example, and table because omitted content is intentionally removed from that named card.
- In `MODIFIED`, a new scenario name appends that complete card to the named Requirement.
- Preserve unspecified scenarios and their detail exactly. Update the requirement body only when the delta explicitly supplies a replacement body.
- `REMOVED` deletes only the explicitly named Requirement block.
- `RENAMED` applies only the explicit `FROM` and `TO` mapping.
- After synchronization, remove delta-operation headers from the current spec and preserve every ordinary Markdown line and complete Scenario-owned detail block in the resulting Scenario Cards.

Scenario reparenting is not inferred from a repeated name and has no implicit `MOVED Scenario` dialect. A Change that repairs ownership must explicitly identify the current-spec structural correction and verify that the card exists exactly once under its intended Requirement.

Never overwrite a current spec with a delta file. Read the delta and current target together, perform a semantic merge, and validate the current specifications afterward.

## Validation profiles

`record-v1` and `requirements-v1` are validator profile identifiers, not content versions or migration stages. Scenario Cards are ordinary Markdown and work under either profile.

The project `angelscript` workflow uses `record-v1` because proposal and tasks are required while durable specs remain optional for maintenance, documentation, and internal refactors. A workflow chooses `requirements-v1` only when every Change must contain and validate Requirement deltas. It is not an upgrade from `record-v1`, and richer Scenario Cards do not require switching profiles.
