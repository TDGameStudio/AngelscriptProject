## MODIFIED Requirements

### Requirement: Harness-recognized Task Graph

`tasks.md` MUST be the change's only current execution state and DAG. A current file MUST declare one versioned YAML-frontmatter `task_graph.depends_on` map whose directly quoted stable `X.Y` keys exactly match its root checkbox IDs. Each checkbox MUST have a short title and four-space owned Markdown with exactly one direct **Files** path-list section and one direct **Verification** section containing one non-empty fenced proving command. A completed task MUST NOT return to incomplete, and an ID MUST NOT be reused or renumbered.

#### Scenario: Derive ready work through Harness

- **GIVEN** a valid graph has completed `1.1`, pending `1.2` depending on `1.1`, pending `1.3` depending on `1.2`, and independent pending `2.1`

    Every task owns its exact Files selection and proving command. Graph keys
    and body task IDs match; no dependency is inferred from display order.

- **WHEN** Harness reads the current task plan

- **THEN** `1.2` and `2.1` are Ready, `1.3` remains blocked, and completed `1.1` is not Ready

    The public projection retains `id / description / done / files / verify /
    after / ready / line`. Parallel execution additionally requires disjoint
    files, generated artifacts and resource leases.

- **BUT** any graph or task-card issue suppresses every Ready result

    An independent valid task is not schedulable while another card is
    malformed. Diagnostics retain the task identity and source location where
    applicable; validation does not rewrite the document.

#### Scenario: Keep presentation separate from execution

- **WHEN** Graph keys and task blocks are displayed in a different Markdown order

- **THEN** output uses natural numeric task-ID order and derives dependencies only from `depends_on`

    Nested headings, tables, quotations and fenced task examples remain content
    of their enclosing card. They do not create nodes or end the owning task.

#### Scenario: Read historical task records

- **GIVEN** a record still uses inline verification, blockquote Files or body After metadata

- **WHEN** the current parser is asked to inspect it

- **THEN** the parser reports explicit unsupported-format diagnostics and exposes no Ready work

    There is no old-format fallback, automatic conversion or dependency
    inference from retired After fields. The original record bytes remain
    unchanged; migration is a separately scoped action.

#### Scenario: Preserve exact metadata values

- **GIVEN** one task lists `src/a b.rs` and `tests/a,b.rs` as separate code-formatted Files items

    Its Verification fence contains a command spanning multiple lines. A
    quoted example elsewhere in the card also contains a Files label.

- **WHEN** the parser projects the task

- **THEN** it returns exactly the two paths and preserves internal command newlines

    Commas, spaces and Unicode inside a path are data, not delimiters. The
    quoted label supplies no metadata. Missing or duplicate direct sections,
    empty commands and multiple proving fences produce diagnostics.

### Requirement: Ready-to-execute Task authoring

Planning MUST map affected files, artifacts and exclusive resources, divide work into independently acceptable bounded outcomes, and map every requirement and acceptance condition to a node. Behavior tasks SHALL supply concrete inputs and independently expected results, missing-behavior RED, actual interface handoffs, relevant ownership/lifetime/failure-state decisions, implementation order and completion criteria before execution. Related tests, implementation, wiring and necessary documentation SHOULD stay with their outcome. Tasks MUST NOT be sized by fixed word, test, file, time or process-launch quotas.

The default reading order SHOULD be Outcome, Context and interfaces, Cases, Implementation, Files and Verification. Evidence MUST be added only after actual execution. Non-machine sections MAY be combined, renamed or expanded. Useful detail MAY be extensive and use ordinary Markdown; Files and Verification retain their exact direct-section contract.

#### Scenario: Execute a detailed task card

- **WHEN** a task has non-trivial interfaces, state transitions or failure behavior

- **THEN** its card supplies the actual signatures, literal cases and decisions needed to implement and judge completion

    Code examples, tables, nested headings, prose, lists, links and images stay
    within its four-space owner. Section presence or length alone does not
    establish planning completeness.

#### Scenario: Keep a simple task card small

- **WHEN** outcome, interfaces, cases, Files and Verification already settle all relevant decisions

- **THEN** the card may combine optional explanation and omit empty scaffolding

    Shortness is a consequence of a self-contained contract, not a target that
    permits missing acceptance conditions.

#### Scenario: Recognize an oversized task before continuing

- **WHEN** a pending task accumulates independently acceptable deliverables, hidden prerequisite interfaces or a proving command that cannot establish its whole outcome

- **THEN** the coordinator revises the invalid boundary through evidence-backed Replan

    Completed nodes and valid evidence remain intact. New outcomes receive new
    IDs. Shared files constrain scheduling without inventing semantic edges.
    A routine test failure or a long but bounded card alone does not require
    Replan.

#### Scenario: Plan a feature group before implementation

- **WHEN** an author prepares a behavior task for a zero-context implementer

- **THEN** the card identifies concrete missing-behavior cases and existing regression controls before grouped RED

    The task orders test preparation, observed RED, bounded implementation,
    grouped GREEN and relevant refactoring. One direct Verification command
    has an exact working context, nonempty case selection and completion
    criteria; shared proof retains task-specific case mapping.

- **AND** templates and lifecycle preflight judge information sufficiency rather than matching prescribed wording

### Requirement: Flexible Scenario Card authoring

Maintained behavioral specifications SHALL use real root Requirement and Scenario headings, with direct non-empty WHEN and THEN clauses. GIVEN, AND and BUT MAY add meaningful state or guarantees. Every authored clause SHALL carry the durable detail needed to make its case unambiguous; a self-contained clause MAY omit detail that adds no information. Direct content and wrapped clause continuations MUST use four spaces, with deeper Markdown owned by its immediate container. Detail MUST NOT drift into an unowned Scenario-wide tail.

Scenario content MAY include prose, headings, tables, code, lists, quotes, links, images and other Markdown without a fixed field matrix or length target. Specs MUST retain durable observable behavior and examples, not source-edit steps, Task state or transient execution evidence. Parsing and synchronization MUST preserve complete raw cards and their relative links; nested example headings MUST NOT create Requirement, Scenario or delta-operation structure. Both validation profiles SHALL check authored scenarios without requiring optional specifications to exist.

#### Scenario: Enrich individual behavior clauses

- **GIVEN** a durable case needs explicit identity, input, state or boundary information

- **WHEN** an author writes or modifies its behavior clauses

    Each useful detail is attached to the exact GIVEN, WHEN, THEN, AND or BUT
    that it qualifies. A wrapped behavior sentence itself uses at least four
    spaces on every continuation line.

- **THEN** the card retains enough concrete information to distinguish accepted and rejected behavior

    A table may map literal inputs to results; code may demonstrate a public
    call or input/output fixture; an ordered list may explain durable protocol
    precedence. None of these forms implies task execution.

- **AND** a same-name modified scenario replaces the complete named card during semantic synchronization

    Still-valid clause content is repeated in the replacement; unspecified
    scenarios remain unchanged. The CLI does not implement automatic merging.

#### Scenario: Keep a simple behavior scenario compact

- **WHEN** a self-contained trigger and result have no additional useful durable information

- **THEN** the card may remain a pair of clear clauses without boilerplate

#### Scenario: Reject detached or missing behavior

- **GIVEN** a card lacks a direct WHEN or THEN, or places its explanation outside every clause

- **WHEN** either validator profile examines the authored scenario

- **THEN** validation reports the structural defect without editing the document

    A WHEN/THEN shown only in a quote, nested list or code fence does not satisfy
    the direct clause requirement. Two-space or lazy unindented continuations
    are invalid even when a permissive Markdown renderer would display them.
