## MODIFIED Requirements

### Requirement: Ready-to-execute Task authoring

Planning MUST map affected files, artifacts and exclusive resources, divide work into stage-level independently acceptable outcomes, and map every requirement and acceptance condition to a node. A plan MUST open with `## Goal`, `## Architecture`, `## Global constraints` and `## Requirement coverage` sections and MAY add `## File map`; Harness execution policy MUST be linked from `.agents/skills/harness/references/execution-conventions.md`, not repeated. A behavior task MUST supply, in order, a brief paragraph, **Outcome** with explicit exclusions, **Interfaces** with consumed and produced signatures in code fences and every new public name with its source whenever any symbol is produced or consumed, **Cases**, **Files**, **Verification**, and MAY add **Notes**; a document or migration task MAY omit Interfaces and Cases. Each case MUST open with one header line `N. **Name** — <role>` optionally followed by ` · <kind>`, and its body MUST carry the literal input, the independently derived expected result and, when a count or invariant is asserted, the oracle. Standard roles are `new RED`, `existing control`, `boundary` and `deferred RED until X.Y`; standard kinds are those in the task case catalog. Any other role or kind word MUST be defined once in a `Roles:` or `Kinds:` paragraph of the same Cases block — a role definition states how RED/GREEN treats the case, a kind definition states what the body carries and what its oracle is. The block MAY open with one `Setup:` paragraph that cases reference, and a case MAY carry a `Replaces:` line naming the case it retires. Tables MUST appear only inside an `example-table` case as rows under one clause template. Sequence steps MUST be observations (`action → observation`) under one role and one oracle. Cards MUST NOT contain step-level test-driven-development scripts; the TDD Skill derives grouped RED/GREEN from Cases by role and shapes tests by kind. A `deferred RED until X.Y` case MUST be observed red in its own task, MUST be excluded from that task's GREEN set, and task `X.Y` MUST exist in `task_graph` and cite the case turning green. Evidence MUST be added only after actual execution. Cards MUST NOT contain the forbidden placeholder phrases listed in the task authoring reference. Before a plan is accepted, a three-item self-review — requirement coverage, placeholder scan, cross-task symbol consistency — MUST be recorded in `attachments/data/planning-validation.md`. Skill-side preflight MUST refuse to start a task whose mandatory labels are missing, whose Cases lack a `new RED` case or a valid header line, that uses an undefined role or kind word, whose `deferred RED` target is absent from the graph, or whose Interfaces lack a fence when a symbol is named. Tasks MUST NOT be sized by fixed word, test, file, time or process-launch quotas; mandatory labels are information requirements, not size targets.

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
    case mapping. Kind decides the test's inner shape: a sequence is one test
    with several assertions, an example-table is normally one parameterized
    test whose rows red and green together, a measurement is normally a
    boundary compared to a checked-in baseline.

- **AND** templates and lifecycle preflight judge information sufficiency rather than matching prescribed wording beyond the mandatory labels and the case header line

#### Scenario: Block a thin card at apply time

- **GIVEN** a migrated plan whose card lacks an Interfaces fence or any new RED case

- **WHEN** `openspec-apply-change` selects that task

- **THEN** preflight refuses to start it and names the missing element; the owning Change repairs the card through `openspec-update-change`

    Syntax migration never fills in interfaces or cases on another Change's
    behalf.

#### Scenario: Express a lifetime, a matrix and a bound in one Cases block

- **GIVEN** a behavior card whose Cases block opens with `Setup:` and lists a `new RED · sequence` case of three `action → observation` steps, a `boundary · example-table` case with a clause template and five homogeneous rows, and a `boundary · measurement` case with Corpus, Metric, Bound and Baseline

- **WHEN** plan-acceptance preflight runs

- **THEN** the card is accepted: every header matches the grammar, one case is `new RED`, no word needs a definition

    The Rust parser projects the same `files`, `fileRoles`, `after` and
    `ready` as for a Form 2 card; Cases content is never machine-read.

- **BUT** the same block with a table outside an `example-table` case, or a sequence whose steps carry their own role tags, is rejected by preflight naming the case

#### Scenario: Define a custom role or kind in the card

- **GIVEN** a Cases block containing `Roles:` with `` `quarantined` — runs and is recorded; neither red nor green counts toward this card; re-enabled by 3.2`` and `Kinds:` with `` `protocol` — message round-trip table; oracle is the checked-in .trace file``

- **WHEN** a case header reads `2. **Handshake** — quarantined · protocol`

- **THEN** preflight accepts the case and the TDD Skill treats it as the definition states

    Standard roles and catalog kinds never need a definition; the definition
    travels with the card so a zero-context implementer needs no other file.

- **BUT** a header `3. **Retry** — flaky` with no `Roles:` entry for `flaky` fails preflight with the undefined word named

#### Scenario: Defer a red case to a later task

- **GIVEN** task `1.1` lists `4. **ShutdownDestroysLeftovers** — deferred RED until 2.1` and `2.1` exists in `task_graph`

- **WHEN** `1.1` is applied and later `2.1` is applied

- **THEN** `1.1` records the case observed red and completes with its other `new RED` cases green; `2.1` Evidence cites `ShutdownDestroysLeftovers` turning green

    A deferred case that never turns green is a planning defect of the plan,
    not of `1.1`.

- **BUT** `deferred RED until 9.9` with no `9.9` in the graph fails plan-acceptance preflight
