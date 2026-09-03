---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": ["1.1"]
    "2.2": ["1.1"]
    "3.1": ["2.1", "2.2"]
    "3.2": ["3.1"]
    "3.4": ["3.2"]
    "4.1": ["3.4"]
    "4.3": ["4.1"]
    "4.4": ["4.3"]
    "4.5": ["4.4"]
    "4.6": ["4.5"]
    "4.8": ["4.6"]
    "4.9": ["4.8"]
    "4.10": ["4.9"]
    "4.11": ["4.10"]
    "4.12": ["4.11"]
    "5.3": ["4.12"]
---

## 1. Recovery record

- [x] 1.1 Register the late Change and preserve the process deviation — verify: `strict validation reports hardness/restore-exploration-authoring-contracts valid with a canonical eight-node Task DAG`
  > Files: `openspec/changes/hardness/restore-exploration-authoring-contracts/change.yaml`, `openspec/changes/hardness/restore-exploration-authoring-contracts/proposal.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/design.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/specs/hardness/core/spec.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/tasks.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/INDEX.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/implementation/issue-20260903-111408-change-created-after-implementation-start.md`

  1. Create the canonical Hardness Change from the already accepted pre-creation handoff.
  2. Record the existing implementation chronology and recovery boundary without claiming prior compliance.
  3. Validate proposal, design, delta spec, attachment index, issue, and Task DAG structure.

## 2. Restore workflow contracts

- [x] 2.1 Restore strict pre-Change exploration and active registration routing — verify: `all five changed Skill directories pass quick_validate.py and the root README contains no stale workflow entry`
  > Files: `.agents/skills/openspec-explore/SKILL.md`, `.agents/skills/openspec-explore/references/deep-exploration.md`, `.agents/skills/openspec-explore/references/question-rounds.md`, `.agents/skills/hardness/SKILL.md`, `.agents/skills/hardness/references/routing.md`, `.agents/skills/openspec/SKILL.md`, `.agents/skills/openspec-continue-change/SKILL.md`, `.agents/skills/openspec-apply-change/SKILL.md`, `.agents/skills/README.md`, `openspec/README.md`, `AGENTS.md`, `README.md`

  1. Make Explore available only before creation of the target Change and define its decision-complete handoff.
  2. Keep Current/Goal task-local uncertainty in Apply and route invalid existing truth through update/replan.
  3. Require canonical active Change and Ready task resolution before Apply.
  4. Remove the tracked root README's incompatible `openspec-work` and stage-wall guidance without absorbing unrelated user hunks.

- [x] 2.2 Restore focused authoring and knowledge contracts — verify: `git diff --check reports no errors for the focused OpenSpec references, durable spec, and capability knowledge index`
  > Files: `.agents/skills/openspec/references/record-schema.md`, `.agents/skills/openspec/references/tasks.md`, `.agents/skills/openspec/references/attachments.md`, `.agents/skills/openspec/references/implementation-issues.md`, `.agents/skills/openspec/references/knowledge.md`, `openspec/specs/hardness/core/spec.md`, `openspec/specs/hardness/core/knowledges/INDEX.md`

  1. Restore zero-context Task DAG authoring quality and attachment event routing.
  2. Define the material issue threshold, root-cause grouping, lifecycle frontmatter, exact evidence, and proof limits.
  3. Define change-to-capability knowledge admission and add the missing Hardness capability INDEX without rewriting existing knowledge bodies.

## 3. Guard and dogfood the contracts

- [x] 3.1 Add executable protocol regression coverage — verify: `both OpenSpecSkill.Tests.ps1 and Protocol.Tests.ps1 exit 0 under pwsh.exe -NoProfile`
  > Files: `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`, `.agents/skills/hardness/tests/Protocol.Tests.ps1`

  1. Guard Explore references, pre-creation routing, task quality, issue schema, stale README entry points, and capability knowledge indexes.
  2. Validate valid and invalid active issue fixtures, including same-edit INDEX registration and status-specific evidence.
  3. Audit existing `closure-v1` archives only for immutable INDEX compatibility.

- [x] 3.2 Run the supported Skill-only gate — verify: `pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Quick reports 5 passed, 0 failed under PS7`
  > Files: `.agents/skills/hardness/scripts/Test-Hardness.ps1`, `.agents/skills/hardness/tests/Protocol.Tests.ps1`, `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`

  1. Run the complete PS7 Quick matrix after protocol repairs.
  2. Keep UE, StaticJIT, Performance, and Integration outside this Skill-only gate.
  3. Preserve exact results in the issue and final Review rather than creating a miscellaneous implementation summary.

- [x] 3.4 Register recovery verification evidence without premature promotion — verify: `the open recovery issue records strict validation, protocol tests, and PS7 Quick 5/5 without claiming review or knowledge admission`
  > Files: `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/implementation/issue-20260903-111408-change-created-after-implementation-start.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/INDEX.md`

  1. Append exact recovery, strict-validation, protocol-test, and Quick evidence to the still-open material issue.
  2. State explicitly that independent Review and knowledge admission remain pending.
  3. Re-run the active-issue protocol check without closing the issue.

## 4. Review and close

- [x] 4.1 Complete an independent fixed-snapshot Review — verify: `the assigned review file is closed with no open or deferred Critical or Required finding`
  > Files: `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/reviews/review-20260903-113000-exploration-authoring-independent.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/INDEX.md`

  1. Bind the Review to the exact working-tree diff and untracked new-file hashes.
  2. Triage any finding; fix locally unless evidence invalidates the plan boundary.
  3. Obtain independent re-review when required and close or supersede the Review record.

- [x] 4.3 Resolve the recovery issue and promote its reusable checkpoint — verify: `OpenSpec Skill and Protocol tests accept the resolved issue and index every Hardness capability knowledge file exactly once after Review`
  > Files: `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/implementation/issue-20260903-111408-change-created-after-implementation-start.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/INDEX.md`, `openspec/specs/hardness/core/knowledges/change-registration-checkpoint.md`, `openspec/specs/hardness/core/knowledges/INDEX.md`

  1. Append the closed Review as final recovery evidence and resolve the issue.
  2. Promote the concise active-Change checkpoint, not the incident chronology, into capability knowledge.
  3. Re-run the knowledge and active-issue protocol checks after promotion.

- [x] 4.4 Restore visual markers and exploration carryover — verify: `the focused references define one reviewed marker vocabulary and route accepted pre-Change carryover without treating emoji or transcripts as execution state`
  > Files: `.agents/skills/openspec-explore/SKILL.md`, `.agents/skills/openspec-explore/references/deep-exploration.md`, `.agents/skills/openspec-explore/references/question-rounds.md`, `.agents/skills/openspec-explore/references/markers.md`, `.agents/skills/openspec-continue-change/SKILL.md`, `.agents/skills/openspec/references/attachments.md`, `.agents/skills/openspec/references/knowledge.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/proposal.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/design.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/specs/hardness/core/spec.md`, `openspec/specs/hardness/core/spec.md`

  1. Recover and rationalize the prior marker vocabulary into a small core set plus optional contextual markers with plain-text labels.
  2. Add an `Exploration Carryover` handoff that classifies canonical truth, non-obvious decisions/visuals, reusable insights, and discarded transient material.
  3. Materialize accepted carryover only after Change creation, with exact talks/knowledges routing and same-edit INDEX registration.

- [x] 4.5 Dogfood and guard marker carryover — verify: `OpenSpecSkill.Tests.ps1 and Protocol.Tests.ps1 pass with one indexed talk and one indexed change-local knowledge record`
  > Files: `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`, `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/talks/talk-20260903-115455-exploration-marker-carryover.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/knowledges/exploration-marker-carryover.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/INDEX.md`

  1. Record the user's settled marker/carryover decision as a concise talk with the smallest useful visualization.
  2. Preserve the reusable carryover rule as change-local knowledge while keeping canonical requirements in specs/design.
  3. Add semantic regression assertions for marker meanings, accessibility, post-creation capture, attachment routing, and transcript rejection.

- [x] 4.6 Review the expanded fixed snapshot — verify: `the assigned marker-carryover Review is closed with no open or deferred Critical or Required finding`
  > Files: `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/reviews/review-20260903-120000-marker-carryover-independent.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/INDEX.md`

  1. Bind a new independent Review to the expanded task-owned snapshot without rewriting the earlier closed Review.
  2. Triage marker ambiguity, durable-routing, context-growth, accessibility, and INDEX findings against the accepted contracts.
  3. Fix and re-review any required finding before promotion.

- [x] 4.8 Define event-driven asynchronous Review — verify: `the focused Skills, references, design, and specifications consistently expose Incident, impact-gated Final, and External Review without a routine task-cadence gate`
  > Files: `.agents/skills/hardness/SKILL.md`, `.agents/skills/hardness/references/review.md`, `.agents/skills/hardness/references/routing.md`, `.agents/skills/hardness/references/closure.md`, `.agents/skills/code-review/code-reviewer/SKILL.md`, `.agents/skills/openspec-verify-change/SKILL.md`, `.agents/skills/openspec-archive-change/SKILL.md`, `.agents/skills/openspec/references/attachments.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/change.yaml`, `openspec/changes/hardness/restore-exploration-authoring-contracts/proposal.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/design.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/specs/hardness/core/spec.md`, `openspec/specs/hardness/core/spec.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/talks/talk-20260903-122738-review-gate-scheduling.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/knowledges/review-gate-scheduling.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/INDEX.md`

  1. Define Incident Review only for demonstrated major problems and Final Review only for scope-frozen broad-impact work; let verified small low-impact changes record `not required` without a Review file.
  2. Admit user/agent-started External Reviews without making a report or severity an automatic Replan.
  3. Bind asynchronous reviewer subagents to immutable snapshots while the main thread continues disjoint work and preserve detailed Review files without a line cap.
  4. Record the elapsed-time dogfood decision and reusable scheduling rule in one indexed talk and one change-local knowledge candidate.

- [x] 4.9 Guard the Review routes and lifecycle metadata — verify: `OpenSpecSkill.Tests.ps1 and Protocol.Tests.ps1 both exit 0 under pwsh.exe -NoProfile with review-v2 positive and negative fixtures`
  > Files: `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`, `.agents/skills/hardness/tests/Protocol.Tests.ps1`

  1. Assert exact trigger, impact-skip, scope-freeze, asynchronous snapshot, external-intake, and no-line-limit contracts.
  2. Keep legacy Review records readable while requiring new `review-v2` records to carry truthful lifecycle and immutable snapshot metadata.
  3. Reject a closed Final Review with missing metadata or non-approving verdict without changing historical Review files.

- [x] 4.10 Reach broad-impact Final Review readiness — verify: `strict active validation and the PS7 Quick Skill-only gate pass, exact task-owned scope is frozen, and task.status derives 4.11 Ready`
  > Files: `openspec/changes/hardness/restore-exploration-authoring-contracts/tasks.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/INDEX.md`

  1. Classify this Hardness protocol change as broad impact because it changes cross-capability Review and closure behavior.
  2. Absorb all accepted user changes, run focused and Quick verification, and stage only exact task-owned paths and root README hunks.
  3. Stop before dispatch so the Final Review receives one stable snapshot rather than a sequence of small moving increments.

- [ ] 4.11 Run the asynchronous Final Review — verify: `one review-v2 Final Review is closed with APPROVE against the scope-frozen final snapshot and no open or deferred Critical or Required finding`
  > Files: `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/reviews/review-*-hardness-workflow-subagent.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/INDEX.md`

  1. Materialize an immutable snapshot reference, allocate one unique Review file, and dispatch a reviewer subagent asynchronously.
  2. Continue only disjoint work while Review runs; if task-owned scope changes, batch it and run one incremental Final Review after re-freeze.
  3. Triage findings, append resolution and re-review evidence, and let the coordinator record actual closure time and final state.

- [ ] 4.12 Promote reviewed exploration and Review scheduling knowledge — verify: `the Hardness capability knowledge INDEX covers both promoted rules exactly once and focused protocol tests still pass`
  > Files: `openspec/specs/hardness/core/knowledges/exploration-carryover.md`, `openspec/specs/hardness/core/knowledges/review-gate-scheduling.md`, `openspec/specs/hardness/core/knowledges/INDEX.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/INDEX.md`

  1. Promote only the reusable marker/carryover and Review scheduling decisions after the Final Review.
  2. Keep timing details, option history, marker assessment, and snapshot-specific evidence in the Change attachments.
  3. Re-run focused knowledge, attachment, and strict active validation gates.

## 5. Closure

- [ ] 5.3 Prepare completed closure and exact commit scope — verify: `strict active validation passes, every task is complete, attachment INDEX is exact, and cached diff contains only reviewed paths and hunks`
  > Files: `openspec/changes/hardness/restore-exploration-authoring-contracts/change.yaml`, `openspec/changes/hardness/restore-exploration-authoring-contracts/tasks.md`, `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/INDEX.md`

  1. Confirm current `hardness/core` already contains the reviewed delta and record the sync disposition.
  2. Complete all task checkboxes without unchecking or renumbering any node.
  3. Archive with completed closure, run strict archived validation and Quick, then stage only reviewed exact paths and root README hunks.
