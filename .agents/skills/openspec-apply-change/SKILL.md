---
name: openspec-apply-change
description: Take an active OpenSpec Change from created to implemented - write any missing planning artifacts from the seeded handoff (Ensure plan), then implement ready nodes from tasks.md with TDD, exact verification, evidence, and Harness-controlled review/replan. Use when a Change exists and must be planned, implemented, or resumed.
---

# Apply a Change

## Enter with the current execution authority

- Select the explicit Change or resolve the canonical active Change in the selected workspace. Read its `tasks.md` and `attachments/INDEX.md` first. An accepted exploration handoff is not an active Change or Ready Task DAG.
- Inspect `harness.execution.status` before planning or implementation mutation. For an explicit Change execution request that is unbound, use `harness.execution.start` with `Scope=Change` and the actual request source.
  - Reuse a caller's existing Queue binding. Scope=Change is a bounded adapter over the same queue core; never replace/reorder a configured queue or silently start earlier/later members.
  - A newly created/applied handoff must complete its purpose-specific arrangement Gate before Ensure plan or implementation; an older binding is insufficient. A current wait choice permits state inspection, not planning or execution under an earlier request.
  - Query again at task/closure boundaries and after long calls; triage input before mutation and pause implementation for unresolved Change decisions.
- Keep planning and implementation responsibilities distinct.
  - New Create/Replan already committed its complete accepted planning before the execution arrangement. Ensure plan validates that plan; historical missing artifacts retain their accepted recovery path. A pending formal-record commit blocks implementation even if other arrangement answers exist.
  - Ensure plan stops and reports when the handoff lacks a user-owned decision or a public name that neither recorded vocabulary nor convention settles. Route that planning issue through Update.
  - Implementation does not ask the user directly. Derive omitted implementation names from convention and record `Naming assumed`; route a newly surfaced user-owned decision through Update and its explained Grill.

## Ensure plan

- Call `openspec.status --change <id> --json`.
  - For a draft-backed new Change created by `openspec-create-change`, pass `harness.change.seed.verify` before planning.
  - Read the selected English handoff/design and actually exported evidence through `attachments/INDEX.md`; settled names come from design terminology or a legacy optional glossary.
  - For a direct-origin Change, use its recorded skipped-draft reason and state the assumption in the proposal.
- For each missing artifact, call `openspec.instructions <artifact> --change <id> --json` and follow its rules as constraints.
  - Write proposal, durable specs delta where needed ([Scenario Cards](../openspec/references/specs.md)), `tasks.md` ([task contract](../openspec/references/tasks.md)), and **a root `design.md` for every new Change**.
  - The new design's `## Call chains` shows the real code path and `Measured at` revision/dirty note, or `none` with a reason for a non-code change.
  - Keep Files, Cases and Verification in the Task Cards. Existing unmarked Changes retain their accepted design requirement.
- Preserve seeded decisions; do not recreate their talks/knowledge or copy the draft transcript.
  - A newly surfaced user-owned decision routes through Update to a linked draft and its Change-owned planning talk ([attachments](../openspec/references/attachments.md)); explain/Grill it and obtain the real handoff Gates before changing accepted truth.
  - A public name that neither glossary nor convention settles stops planning; it is not an implementation-time `Naming assumed`.
- Run the plan-acceptance moment of the [Task authoring preflight](../openspec/references/tasks.md), record and index `attachments/data/planning-validation.md`, pass `harness.change.plan.verify`, then validate strictly.
  - Repair failures while the plan is still unaccepted. Corrections to an accepted plan go through `openspec-update-change`.
  - During unattended continuation, settle in-scope technical choices; report a missing user-owned decision.

## Read and select Ready task cards

- Call `Invoke-Harness -Command task.status -Context $context -Parameters @{ Change = '<id>' }` before implementation mutation. Select nodes whose OpenSpec-derived `ready` field is true.
- Read proposal, relevant specs/design, `tasks.md`, and `attachments/INDEX.md`. Load only attachments linked by the current task.
- Read the task as one complete heading-node card: `## [ ] X.Y Title`, brief paragraph, Outcome, Interfaces, named Cases, Files diff tree, Verification and Notes.
  - Execute the direct Verification command with its stated conditions; do not extract commands from titles or examples.
  - Keep completion evidence inside the owning task or its linked attachment.
  - An unsupported old-format diagnostic requires a separately authorized record migration, not a fallback parser.
- Before editing, check the node's goal, `Files`, prerequisites, linked context, exact verification, and design assumptions for local coherence.
- Run the task-start moment of the [Task authoring preflight](../openspec/references/tasks.md) before starting a card.
  - Preflight refuses to start a card that fails it, names the missing element in the report, and routes the repair to `openspec-update-change`.
  - It never fills interfaces or cases on the plan's behalf. Replan a demonstrated oversized or unprovable task boundary before implementation; do not keep appending independent work to its tail.
- Parallelize only nodes with disjoint Files, artifacts, and resource leases; never infer an edge from display order or parse the YAML again.

## Implement and prove the bounded outcome

- Select and expand task checks through the Harness [impact-scoped verification policy](../harness/references/verification.md), beginning with the smallest direct proof.
- For behavior changes, prepare one bounded feature group's cases, observe their expected RED together, implement the group, then verify GREEN.
  - A `deferred RED until X.Y` case is observed red in this card and recorded in its Evidence but excluded from this card's GREEN requirement; when `X.Y` is applied, its Evidence cites that case turning green.
  - Run the exact proving command or a documented shared run that maps its cases to the same source/binary identity, then change `[ ]` to `[x]`.
  - No passing evidence means no completed checkbox; an aggregate count or successful dispatch is not case-level proof.
- When implementation needs a new public type, module, file, or key function name that the task's **Interfaces** does not list, derive it from the neighbouring convention per [naming.md](../brainstorming/references/naming.md).
  - Record `Naming assumed: <name> — <one-line reason>` in the task's **Evidence**, and continue. Verification reviews every assumed name before the task closes.
  - Product scope or behavior the design never settled is a user-owned decision and planning-invalidating evidence; record the finding and route it to `openspec-update-change` rather than deciding it as an assumed name.
- Use lightweight task-local investigation for routine Ready-task work. Fix in-scope technical failures autonomously; never weaken specified behavior to make a task pass.
  - Triage a finding before Replan. Use Update only when evidence invalidates accepted design or another plan boundary, or surfaces a user-owned decision.
  - A real authorization boundary can stop implementation; ordinary ambiguity, test failure or review feedback alone does not end the authorized work.
- If investigation crosses the [material implementation issue](../openspec/references/implementation-issues.md) threshold, record one root-cause lifecycle and update INDEX in the same edit.
  - Keep ordinary RED/GREEN cycles and immediate corrections out of attachments.
  - Record a non-obvious decision in talk/current design and reusable knowledge only when it passes the admission test.

## Return to the authorized loop

- Run strict validation and report completed/total plus the next Ready nodes.
- Preserve code changes for the normal final explained close; do not default to a commit after each task or checkpoint old code during Replan. Use Harness [closure](../harness/references/closure.md) for the full result comparison, exact Git scope and actual selectable approval before commits/archive.
- Apply never asks the user questions inside implementation. Hand planning-invalidating decisions to Update, which may open/reuse a linked design draft and calls independent `grill`; implementation waits for the actual Replan and arrangement Gates.
- Preserve valid work and the exact task return position. After the approved Replan and current execution arrangement, return to that position in the authorized loop. This handoff does not end the execution request or expand its scope.

```text
execution authority + current arrangement
  -> openspec.status -> Ensure plan (missing artifacts, plan-acceptance preflight)
  -> task.status -> read current truth -> choose Ready feature group
  -> grouped RED -> implement -> grouped GREEN -> check proven task
  -> report and continue within the authorized range
```
