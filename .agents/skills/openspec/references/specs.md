# Specification and Scenario Card Contract

Read this reference when creating, modifying, synchronizing, or verifying durable specifications. A specification exists only when behavior is worth preserving beyond the current implementation task. Maintenance, documentation, and internal refactors that do not change durable behavior do not need a synthetic spec delta.

## Requirement ownership

A Requirement names one durable capability or invariant and states externally observable behavior with `SHALL`, `MUST`, or another intentional normative keyword. A Scenario demonstrates one specific observable case beneath its owning Requirement. Keep technical construction and one-off proof out of both.

```markdown
### Requirement: <durable behavior name>

The system SHALL <durable externally observable behavior>.

#### Scenario: <specific observable case>

- **GIVEN** <optional starting state>
    > Context: <optional durable context owned by this GIVEN>
- **WHEN** <required trigger or action>
    > Inputs: <optional relevant inputs owned by this WHEN>
    >
    > Details: <optional durable explanation owned by this WHEN>

    1. <optional durable protocol step or rule-precedence item>
    2. <delete the whole list when unused>
- **THEN** <required primary observable result>
    > Observables: <optional externally visible evidence owned by this THEN>

    - <optional durable result, example, or edge case>
- **AND** <optional additional result>
    > Verification: <optional stable oracle or test family owned by this AND>
- **BUT** <optional negative guarantee>
    > Boundaries: <optional exclusions or limits owned by this BUT>
```

## Scenario Card

Direct clause detail blocks use exactly **four spaces**, separated by blank lines. Deeper lists and examples indent beneath their immediate Markdown container. Paragraphs, headings, code fences, quotes, tables, links, images and other Markdown may all belong to a clause. A nested heading or a heading shown in code/quotes is an example, never another Requirement/Scenario/operation section. Keep the complete raw card: do not flatten its body into a sentence or a fixed data schema.

This includes a wrapped behavior sentence itself: every continuation line needs at least four spaces, even before the first blank line. Do not use the common two-space Markdown-list continuation. Prefer a self-contained clause line followed by a blank line and owned detail when a long sentence would hide this boundary.

Start with the durable information needed to make the observable case unambiguous. Detail can be extensive: include actual inputs, identities, state, lifetime, boundary values, literal errors and observable results when they distinguish correct behavior. A code example describes the public contract or an input/output fixture, not source-edit instructions. Do not optimize for shortness or defer important decisions to an unspecified implementation.


Every ordinary behavioral Scenario Card has one clear `WHEN` and one clear `THEN`. Add `GIVEN`, `AND`, or `BUT` only when the additional behavioral clause materially clarifies the case. For every behavior clause created or modified, actively evaluate whether a zero-context reader would benefit from more durable information than the clause line alone provides. Supply the useful combination of quoted notes, prose, ordered or unordered lists, examples, and tables in a clause-owned block immediately indented beneath the exact behavior-clause list item they qualify. This is the same readable composition shape by which one Task checkbox owns its supporting block. These forms are peers: a blockquote is not the only or automatically preferred way to enrich a card. The quoted labels are optional:

- `Context` gives durable background needed by a zero-context reader.
- `Inputs` bounds the values, identities, or state entering the behavior.
- `Observables` names externally visible results or evidence surfaces.
- `Boundaries` states exclusions, safety limits, or what the scenario does not guarantee.
- `Verification` identifies a stable invariant, test family, fixture, or acceptance route.
- `Details` introduces useful free-form Markdown when fixed labels alone would make the card harder to read.

These clauses, labels, paragraphs, lists, examples, and tables are ordinary Markdown authoring aids, not parser fields, IDs, checkboxes, dependency edges, Ready state, or execution state. Indentation binds optional content only to the immediately preceding `GIVEN`, `WHEN`, `THEN`, `AND`, or `BUT` item; do not detach clause-specific content into an ambiguous Scenario-wide tail. An ordered list may clarify durable behavior order, state progression, or rule precedence; it must not prescribe source edits or implementation execution. An unordered list may collect durable rules, examples, or edge cases. A table helps when repeated fields or comparisons would be harder to scan in prose. An example makes a boundary concrete without turning one observation into a universal requirement.

Every detail form remains optional. An author may omit, reorder, or combine forms, but should omit one only when it adds no durable information. Always delete unused optional lines and the entire unused block. Never add empty placeholders, repeat the clause in different words, or fill a rigid field matrix. A simple scenario or self-contained clause may remain one line after the active evaluation; compactness is the result of having nothing useful to add, not the starting instruction.

`Verification` does not mean a test ran. It names the durable oracle and never replaces task verification or retained run evidence.

## Filled example: branch ancestry and integrity

This example describes durable behavior. The code is an input fixture, not a plan
to edit files or run a one-off test.

````markdown
### Requirement: Immutable source ancestry

The resolver SHALL reconstruct a version from its recorded parent and publish
an immutable Source only after lineage and payload integrity checks succeed.

#### Scenario: Resolve a sibling after another sibling

- **GIVEN** one source identity with a root and two children

    | SourceId | VersionTag | Parent | Complete logical text |
    | --- | --- | --- | --- |
    | 7 | root | none | `int Value=1;` |
    | 7 | left | root | `int Value=2;` |
    | 7 | right | root | `int Value=3;` |

    Both children retain root as their parent. Resolving left does not change
    right's ancestry. A VersionTag from a different SourceId is a different
    identity even when its spelling matches.

- **WHEN** the consumer resolves right after successfully resolving left

    The lookup uses the exact pair `SourceRef{SourceId(7), VersionTag("right")}`;
    neither “latest version” nor the last resolved sibling supplies a baseline.

- **THEN** the returned Source contains exactly `int Value=3;`

    The Source owns its bytes and remains valid after input storage is released.
    Previously returned root and left Sources remain unchanged.

- **BUT** a parent-hash or child-hash mismatch rejects the resolution

    No Source is published for the failed request. Existing Sources and the
    registered lineage remain unchanged; partial reconstructed bytes are not
    observable as successful output.
````

## Content boundaries

| Owner | Content |
|---|---|
| Specs | Durable externally observable behavior, protocol order, rule precedence, examples, stable boundaries, and stable proof expectations |
| Design | Technical choices, alternatives, compatibility, migration, and rationale |
| Tasks | Files, implementation steps, dependency edges, exact commands, and completion state |
| Attachments | One-off evidence, observations, implementation issues, Reviews, talks, replans, and closure data |

Do not disguise implementation steps as behavior, copy command output into a Scenario Card, or use a spec as a second task list. Promote only the durable conclusion from one-off evidence.

Understanding feedback does not automatically require a spec delta. Explain current source and the accepted contract, then distinguish ambiguous intended behavior from missing explanatory knowledge or missed retrieval. An intended behavior choice returns through explained Grill and applicable Create/Replan authority; a verified factual explanation belongs in the owning capability knowledge under [knowledge admission](knowledge.md). Do not silently change the contract to make an explanation easier.

## Delta authoring and synchronization

Change-local delta specs use the established `ADDED`, `MODIFIED`, `REMOVED`, and `RENAMED` Requirement sections:

- `ADDED` carries the complete new Requirement and its complete Scenario Cards.
- In `MODIFIED`, a same-name scenario replaces that scenario's complete Scenario Card. The delta author must repeat every still-valid behavior clause and its owned labels, paragraphs, lists, examples, and tables because omitted content is intentionally removed from that named card.
- In `MODIFIED`, a new scenario name appends that complete card to the named Requirement.
- Preserve unspecified scenarios and every clause-owned detail block exactly. An explicitly authorized formatting-only correction may repair ownership indentation in named affected records while preserving clause text, content and parentage; it is not permission to rewrite behavior or migrate other records. Update the requirement body only when the delta explicitly supplies a replacement body.
- `REMOVED` deletes only the explicitly named Requirement block.
- `RENAMED` applies only the explicit `FROM` and `TO` mapping.
- After synchronization, remove delta-operation headers from the current spec and preserve every ordinary Markdown line under its exact owning behavior clause in the resulting Scenario Cards.

Scenario reparenting is not inferred from a repeated name and has no implicit `MOVED Scenario` dialect. A Change that repairs ownership must explicitly identify the current-spec structural correction and verify that the card exists exactly once under its intended Requirement.

Never overwrite a current spec with a delta file. Read the delta and current target together, perform a semantic merge, and validate the current specifications afterward.

Validate existing affected targets before synchronization as well as afterward. If a preserved scenario fails the current format rules, record that baseline and settle its exact authorized disposition in the plan; do not discover it only at closure or assume a valid delta replaces unspecified scenarios. Follow the sync Skill and impact-scoped verification policy for exact capability selection.

## Validation profiles

`record-v1` and `requirements-v1` are validator profile identifiers, not content versions or migration stages. Scenario Cards are ordinary Markdown and work under either profile.

The project `angelscript` workflow uses `record-v1` because proposal and tasks are required while durable specs remain optional for maintenance, documentation, and internal refactors. A workflow chooses `requirements-v1` only when every Change must contain and validate Requirement deltas. It is not an upgrade from `record-v1`, and richer Scenario Cards do not require switching profiles.
