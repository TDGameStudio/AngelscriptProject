## MODIFIED Requirements

### Requirement: Exploration markers and durable carryover

Pre-Change brainstorming MAY use the project marker vocabulary and compact Markdown visualizations to make facts, decisions, risks, boundaries, and knowledge candidates easy to scan. Every marker MUST retain a plain-text label and MUST NOT be the sole machine-readable state. The final brainstorming round MUST present every carryover candidate with its draft source, target (talk or knowledge), and reason, and the user MUST confirm the list before it enters the decision-complete handoff. `openspec-create-change` MUST be the only Skill that creates the target Change from a designed draft; in the same step it MUST copy the approved draft `design.md`, `handoff.md` and `glossary.md` into indexed `attachments/drafts/`, MUST copy every draft finding that the design or a confirmed talk or knowledge cites into indexed `attachments/drafts/findings/`, and MUST materialize exactly the confirmed candidates — non-obvious decisions and their useful visuals into indexed talks, reusable evidence-backed insights or visuals into indexed change-local knowledge — with provenance naming the draft round or the copied finding. Because drafts are local and git-ignored, no Change file MAY reference an `openspec/drafts/` path. Afterwards canonical truth MUST enter proposal/spec/design/tasks through the `Ensure plan` step of `openspec-apply-change`, which MUST write every missing required artifact from the seeded handoff in one pass, MUST NOT recreate the seeded carryover, MUST NOT reopen design-mode brainstorming, and MUST stop and report — never invent — when the handoff lacks a user-owned decision or a settled public name.

When an extended user-led exploration establishes multiple interacting cross-capability constraints, meaningful corrections, rejected interpretations, or non-obvious rationale that canonical artifacts would flatten and future agents would otherwise re-decide, planning MUST preserve one selective indexed intent talk. The talk MUST retain provenance, capture date, source limits, architecture-changing corrections, exclusions, and canonical mappings. It MUST NOT impersonate an earlier record when reconstructed later. Clear defects, mechanical documentation changes, one-step requests, routine task-local choices, and decisions fully represented by canonical artifacts MUST NOT create a required talk or a not-required placeholder. Transient navigation state, task state, and progress evidence MUST NOT be copied into the Change; the full round log stays in the draft, which is the durable owner of the conversation.

#### Scenario: Carry accepted exploration into a new Change

- **GIVEN** the target Change exists and the decision-complete handoff has classified its accepted carryover

- **WHEN** an accepted handoff contains a non-obvious decision and a reusable insight after the target Change is created

- **THEN** `openspec-create-change` copies the approved draft `design.md`, `handoff.md` and `glossary.md` and the cited findings into `attachments/drafts/`, indexes each once, materializes the confirmed decision and its visualization as one talk and the confirmed insight as change-local knowledge, and `openspec-apply-change` step `Ensure plan` then copies settled current truth into the canonical planning artifacts

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

### Requirement: Ready-to-execute Task authoring

Planning MUST map affected files, artifacts and exclusive resources, divide work into stage-level independently acceptable outcomes, and map every requirement and acceptance condition to a node. A plan MUST open with `## Goal`, `## Architecture`, `## Global constraints` and `## Requirement coverage` sections and MAY add `## File map`; Harness execution policy MUST be linked from `.agents/skills/harness/references/execution-conventions.md`, not repeated. A behavior task MUST supply, in order, a brief paragraph, **Outcome** with explicit exclusions, **Interfaces** with consumed and produced signatures in code fences and every new public name with its source whenever any symbol is produced or consumed, **Cases**, **Files**, **Verification**, and MAY add **Notes**; a document or migration task MAY omit Interfaces and Cases. Each case MUST open with one header line `N. **Name** — <role>` optionally followed by ` · <kind>`, and its body MUST carry the literal input, the independently derived expected result and, when a count or invariant is asserted, the oracle. Standard roles are `new RED`, `existing control`, `boundary` and `deferred RED until X.Y`; standard kinds are those in the task case catalog. Any other role or kind word MUST be defined once in a `Roles:` or `Kinds:` paragraph of the same Cases block — a role definition states how RED/GREEN treats the case, a kind definition states what the body carries and what its oracle is. The block MAY open with one `Setup:` paragraph that cases reference, and a case MAY carry a `Replaces:` line naming the case it retires. Tables MUST appear only inside an `example-table` case as rows under one clause template. Sequence steps MUST be observations (`action → observation`) under one role and one oracle. Cards MUST NOT contain step-level test-driven-development scripts; the TDD Skill derives grouped RED/GREEN from Cases by role and shapes tests by kind. A `deferred RED until X.Y` case MUST be observed red in its own task, MUST be excluded from that task's GREEN set, and task `X.Y` MUST exist in `task_graph` and cite the case turning green. Evidence MUST be added only after actual execution. Cards MUST NOT contain the forbidden placeholder phrases listed in the task authoring reference. Before a plan is accepted, a three-item self-review — requirement coverage, placeholder scan, cross-task symbol consistency — MUST be recorded in `attachments/data/planning-validation.md`. The task authoring reference MUST hold the single preflight text, and `openspec-apply-change` MUST apply it at two moments without restating it: at plan acceptance inside its `Ensure plan` step, where a failing plan is repaired before any node is selected, and at task start, where preflight MUST refuse to start a task whose mandatory labels are missing, whose Cases lack a `new RED` case or a valid header line, that uses an undefined role or kind word, whose `deferred RED` target is absent from the graph, or whose Interfaces lack a fence when a symbol is named. Tasks MUST NOT be sized by fixed word, test, file, time or process-launch quotas; mandatory labels are information requirements, not size targets.

#### Scenario: Plan a created Change inside apply

- **GIVEN** a Change created by `openspec-create-change` whose `openspec.status` reports proposal and tasks missing, and whose `attachments/drafts/handoff.md` names every requirement change, owned file and task boundary

- **WHEN** `openspec-apply-change` runs

- **THEN** its `Ensure plan` step writes proposal, any durable-behavior specs delta, design when a non-obvious decision exists, and `tasks.md`, runs the plan-acceptance preflight from the task authoring reference, records `planning-validation.md`, validates strictly, and only then selects Ready nodes

    Names come from the copied `glossary.md`; a new non-obvious decision
    becomes one indexed talk in the same edit; the draft `log.md` is never
    pasted.

- **BUT** when the handoff lacks a user-owned decision or a public name that no glossary or convention settles, the step stops and reports instead of deriving it; `Naming assumed` belongs to implementation steps only
