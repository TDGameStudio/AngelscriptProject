## MODIFIED Requirements

### Requirement: Harness-recognized Task Graph

`tasks.md` MUST be the change's only current execution state and DAG. A current file MUST declare one versioned YAML-frontmatter `task_graph.depends_on` map whose directly quoted stable `X.Y` keys exactly match its task-node IDs. A task node MUST be a level-2 heading whose text starts with `[ ] ` or `[x] `, then the `X.Y` ID, then a short title; its body MUST be every Markdown block until the next level-1 or level-2 heading, written without indentation. Each node MUST contain exactly one direct **Files** paragraph followed by one fenced `diff` tree and one direct **Verification** paragraph followed by one non-empty fenced proving command. In the Files tree a line beginning `+` creates, `-` deletes, and a leading space modifies; a path ending in `/` prefixes the deeper-indented lines beneath it; text after ` # ` is a comment; the literal `none` alone denotes file-free work. The projection MUST keep `files` as plain paths and MUST add `file_roles` with each path's role. Level-2 headings without a checkbox are group headings and MUST NOT own Files or Verification. Root-level checkbox list items, inline verification, blockquote Files and body After metadata MUST all be reported as `unsupported-task-format` with no Ready work. A completed task MUST NOT return to incomplete, and an ID MUST NOT be reused or renumbered.

#### Scenario: Derive ready work through Harness

- **GIVEN** a valid graph has completed `1.1`, pending `1.2` depending on `1.1`, pending `1.3` depending on `1.2`, and independent pending `2.1`

    Every task owns its exact Files tree and proving command. Graph keys
    and body task IDs match; no dependency is inferred from display order.

- **WHEN** Harness reads the current task plan

- **THEN** `1.2` and `2.1` are Ready, `1.3` remains blocked, and completed `1.1` is not Ready

    The public projection retains `id / description / done / files / verify /
    after / ready / line` and adds `file_roles`. Parallel execution
    additionally requires disjoint files, generated artifacts and resource
    leases.

- **BUT** any graph or task-card issue suppresses every Ready result

    An independent valid task is not schedulable while another card is
    malformed. Diagnostics retain the task identity and source location where
    applicable; validation does not rewrite the document.

#### Scenario: Keep presentation separate from execution

- **WHEN** Graph keys and task blocks are displayed in a different Markdown order

- **THEN** output uses natural numeric task-ID order and derives dependencies only from `depends_on`

    Group headings, nested headings of level 3 or deeper, tables, quotations
    and fenced task examples remain content of their enclosing card or group.
    They do not create nodes; only a level-2 heading ends the owning task.

#### Scenario: Read historical task records

- **GIVEN** a record still uses root-level checkbox list nodes, inline verification, blockquote Files or body After metadata

- **WHEN** the current parser is asked to inspect it

- **THEN** the parser reports explicit `unsupported-task-format` diagnostics naming the heading-node form and exposes no Ready work

    There is no old-format fallback, automatic conversion or dependency
    inference from retired fields. The original record bytes remain
    unchanged; migration is a separately scoped action.

#### Scenario: Preserve exact metadata values

- **GIVEN** one task's Files tree lists `src/a b.rs` as a created file and `tests/a,b.rs` as a modified file under a `/`-terminated directory line with a ` # ` comment

    Its Verification fence contains a command spanning multiple lines. A
    quoted example elsewhere in the card also contains a Files label.

- **WHEN** the parser projects the task

- **THEN** it returns exactly the two resolved paths in `files`, their roles in `file_roles`, and preserves internal command newlines

    Commas, spaces and Unicode inside a path are data, not delimiters; the
    comment is not part of the path. The quoted label supplies no metadata.
    Missing or duplicate direct sections, empty commands, a malformed tree
    line and multiple proving fences produce diagnostics.

### Requirement: Ready-to-execute Task authoring

Planning MUST map affected files, artifacts and exclusive resources, divide work into stage-level independently acceptable outcomes, and map every requirement and acceptance condition to a node. A plan MUST open with `## Goal`, `## Architecture`, `## Global constraints` and `## Requirement coverage` sections and MAY add `## File map`; Harness execution policy MUST be linked from `.agents/skills/harness/references/execution-conventions.md`, not repeated. A behavior task MUST supply, in order, a brief paragraph, **Outcome** with explicit exclusions, **Interfaces** with consumed and produced signatures in code fences and every new public name with its source whenever any symbol is produced or consumed, **Cases** as named cases each tagged new RED, existing control or boundary and carrying the literal input and independently derived expected result in Given / When / Then clauses or one-line clauses, **Files**, **Verification**, and MAY add **Notes**; a document or migration task MAY omit Interfaces and Cases. Cards MUST NOT contain step-level test-driven-development scripts; the TDD Skill derives grouped RED/GREEN from Cases. Evidence MUST be added only after actual execution. Cards MUST NOT contain the forbidden placeholder phrases listed in the task authoring reference. Before a plan is accepted, a three-item self-review — requirement coverage, placeholder scan, cross-task symbol consistency — MUST be recorded in `attachments/data/planning-validation.md`. Skill-side preflight MUST refuse to start a task whose mandatory labels, RED case or interface fence are missing. Tasks MUST NOT be sized by fixed word, test, file, time or process-launch quotas; mandatory labels are information requirements, not size targets.

#### Scenario: Execute a detailed task card

- **WHEN** a task has non-trivial interfaces, state transitions or failure behavior

- **THEN** its card supplies the actual signatures, named literal cases and decisions needed to implement and judge completion

    Code fences, lists, links and images stay in the unindented body under
    the task heading. Label presence alone does not establish planning
    completeness; the preflight checks presence, the reviewer checks content.

#### Scenario: Keep a simple task card small

- **WHEN** a document or migration task's outcome, Files and Verification already settle all relevant decisions

- **THEN** the card omits Interfaces and Cases and adds no empty scaffolding

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

- **THEN** the card names concrete missing-behavior cases tagged new RED and existing regression controls, and the TDD Skill orders test preparation, observed RED, bounded implementation and grouped GREEN from them

    One direct Verification command has an exact working context, nonempty
    case selection and completion criteria; shared proof retains task-specific
    case mapping.

- **AND** templates and lifecycle preflight judge information sufficiency rather than matching prescribed wording beyond the mandatory labels

#### Scenario: Block a thin card at apply time

- **GIVEN** a migrated plan whose card lacks an Interfaces fence or any new RED case

- **WHEN** `openspec-apply-change` selects that task

- **THEN** preflight refuses to start it and names the missing element; the owning Change repairs the card through `openspec-update-change`

    Syntax migration never fills in interfaces or cases on another Change's
    behalf.

### Requirement: Exploration markers and durable carryover

Pre-Change brainstorming MAY use the project marker vocabulary and compact Markdown visualizations to make facts, decisions, risks, boundaries, and knowledge candidates easy to scan. Every marker MUST retain a plain-text label and MUST NOT be the sole machine-readable state. The final brainstorming round MUST present every carryover candidate with its draft source, target (talk or knowledge), and reason, and the user MUST confirm the list before it enters the decision-complete handoff. `openspec-create-change` MUST be the only Skill that creates the target Change from a designed draft; in the same step it MUST copy the approved draft `design.md`, `handoff.md` and `glossary.md` into indexed `attachments/drafts/`, MUST copy every draft finding that the design or a confirmed talk or knowledge cites into indexed `attachments/drafts/findings/`, and MUST materialize exactly the confirmed candidates — non-obvious decisions and their useful visuals into indexed talks, reusable evidence-backed insights or visuals into indexed change-local knowledge — with provenance naming the draft round or the copied finding. Because drafts are local and git-ignored, no Change file MAY reference an `openspec/drafts/` path. Afterwards canonical truth MUST enter proposal/spec/design/tasks through `openspec-continue-change`, which MUST NOT recreate the seeded carryover.

When an extended user-led exploration establishes multiple interacting cross-capability constraints, meaningful corrections, rejected interpretations, or non-obvious rationale that canonical artifacts would flatten and future agents would otherwise re-decide, planning MUST preserve one selective indexed intent talk. The talk MUST retain provenance, capture date, source limits, architecture-changing corrections, exclusions, and canonical mappings. It MUST NOT impersonate an earlier record when reconstructed later. Clear defects, mechanical documentation changes, one-step requests, routine task-local choices, and decisions fully represented by canonical artifacts MUST NOT create a required talk or a not-required placeholder. Transient navigation state, task state, and progress evidence MUST NOT be copied into the Change; the full round log stays in the draft, which is the durable owner of the conversation.

#### Scenario: Scan a grilling round without changing semantics

- **WHEN** interactive pre-Change brainstorming uses markers for a decision frontier

- **THEN** each marked line remains understandable without emoji and durable task/review/issue state continues to come from its canonical schema

#### Scenario: Carry accepted exploration into a new Change

- **GIVEN** the target Change exists and the decision-complete handoff has classified its accepted carryover

- **WHEN** an accepted handoff contains a non-obvious decision and a reusable insight after the target Change is created

- **THEN** `openspec-create-change` copies the approved draft `design.md`, `handoff.md` and `glossary.md` and the cited findings into `attachments/drafts/`, indexes each once, materializes the confirmed decision and its visualization as one talk and the confirmed insight as change-local knowledge, and `openspec-continue-change` then copies settled current truth into the canonical planning artifacts

    The draft README records `status: handed-off` and `target_change` in the
    same step so the source discussion and the Change point at each other.
    Each talk and knowledge cites the copied finding by its Change-relative
    path in English; the original wording stays in the draft `log.md`.

- **AND** only the round log and uncited findings remain in the draft; the Change is self-contained once the draft directory disappears

- **BUT** a talk is retained only when its rationale prevents likely re-decision, and knowledge is retained only when the insight is reusable beyond the originating task

    > Inputs: The accepted handoff, its evidence and provenance, the non-obvious decision, the reusable insight, and the settled canonical behavior.
    >
    > Observables: Proposal, specification, design, or tasks contain current truth; the attachment index names the draft copies, the copied findings, the talk, and the knowledge candidate; the capability knowledge index changes only after explicit promotion.
    >
    > Boundaries: The draft owns the conversation, the talk owns decision rationale, the knowledge candidate owns reusable guidance, and none becomes a parallel source of current requirements or task state.

### Requirement: Naming confirmation before implementation

New public names — types, modules, files, and key functions — MUST be confirmed by the user before code is written. `brainstorming` MUST grill each new public name after inspecting neighbouring conventions and record the choice in the draft `glossary.md` and the design's vocabulary section. Task authoring MUST list every new public name the task introduces in its **Interfaces** section with its source. Apply MUST NOT ask the user for a name: when implementation requires a new public name that the task does not list, Apply MUST choose the convention-derived name and record `Naming assumed: <name>` in the task's Evidence, and verification MUST surface every assumed name for user review before the task closes.

#### Scenario: Grill a name during planning

- **WHEN** the design introduces a new public type

- **THEN** the round presents the recommended name, alternatives, and the neighbouring convention evidence, and the settled name is written to `glossary.md` and later to the task's Interfaces

#### Scenario: Continue past an unplanned name in Apply

- **WHEN** a Ready task requires a new public class or file whose name is not in its **Interfaces**

- **THEN** the agent proceeds with the convention-derived name and records `Naming assumed: <name> — <reason>` in the task Evidence

    Attended and unattended runs behave identically; Apply has no interactive
    stop. Verification lists every `Naming assumed` entry so the user can
    rename before commit.

- **BUT** repeated assumed names indicate that task authoring skipped the naming round, which is corrected in planning rather than by asking during Apply

### Requirement: Deterministic OpenSpec package

The distributed OpenSpec executable MUST be located at `.agents/skills/openspec/bin/openspec.exe` and MUST be reproducible from the parent-recorded `Tools/openspec` commit, immutable `v0.10.0` tag layered after the preserved `v0.9.0` and earlier snapshots, locked build commands, byte-identical isolated rebuild gate, and release manifest. Existing candidate tags MUST NOT be moved to impersonate a repaired snapshot. The parent repository MUST commit only the final accepted package once per release and MUST NOT commit intermediate or candidate executable builds.

#### Scenario: Validate a packaged release

- **WHEN** installation health checks validate the OpenSpec package

- **THEN** the executable version, SHA-256, source commit, annotated tag object/target, command-document set, release gates, and manifest agree

#### Scenario: Preserve parent binary history

- **WHEN** an OpenSpec release is iterated before final acceptance

- **THEN** candidate executables remain outside parent history and the final accepted package enters the parent repository in exactly one release commit
