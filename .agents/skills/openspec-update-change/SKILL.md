---
name: openspec-update-change
description: Reconsider invalid accepted Change requirements, architecture, task boundaries or verification through a linked draft and explained Grill, preview the exact candidates, then apply a user-approved Replan and its post-handoff arrangement. Does not implement code.
---

# Update a Change

## Establish the invalidated boundary

- Read the exact Change's tasks and INDEX, current proposal/spec/design and actual triggering evidence. Ordinary local defects stay inside Apply; use Replan when evidence invalidates requirement/design, task outcome/edge, verification contract or required artifact, or exposes a user-owned choice.
- Capture the current task/return position and pending input through Harness. Necessary unresolved decisions pause the current Change; do not skip to another queue member. Preserve accepted planning files and valid implementation while discussing.
- Open/reuse an automatically created linked draft for the changed design. Link it to the owning Change and a `harness.talk.create` planning record; the draft contains current candidate design and key decisions, while the Change talk contains concise provenance/impact/return state. No full transcript mirroring.
- Inspect and explain the affected code and architecture before asking. Use [grill](../grill/SKILL.md); after each answer re-display the complete relevant updated view, classes/terms/change and unresolved frontier. Only the user initiates convergence; do not propose applying a Replan to end a round.

## Build and present the candidate

- After user-led convergence, prepare complete candidate artifacts in semantic order: proposal/scope, durable specs, design, tasks. Preserve permanent task IDs and checked completed work; give newly required work new IDs. Do not pretend earlier proof covers changed behavior.
- For modified requirements/scenarios, follow [Scenario Cards](../openspec/references/specs.md), actively evaluate every changed clause and retain useful clause-owned detail. A same-name scenario replacement includes its complete still-valid card, including code/tables/lists/links/images. No word-count quota.
- `Candidates` maps Change-relative allowed planning paths to complete UTF-8 text. `ExpectedHashes` supplies their current SHA-256 values (null for new files) plus current tasks.md. Capture canonical base commit and affected execution identities; see [Replan protocol](../harness/references/replan.md).
- Add explicit `GitPlan` with canonical `RepositoryScopes=@{'.'=@('openspec/changes/<exact-id>')}` and a concrete `CommitMessage`. The preview binds selected candidate paths, generated provenance and canonical baseline/branch. It does not select unfinished implementation or add a checkpoint of the old code.
- Use `harness.replan.apply` with `PlanOnly=$true`, Change/TalkId/SessionId/ExpectedRevision/ReplanId, candidate/hash maps, ResumeTask and DraftId/Scope (or explicit direct HandoffText). Before asking, read [the handoff Gate explanation](../harness/references/handoff-gate.md) and present its full account for a reader unfamiliar with the system, including accepted plan versus implemented work versus proposed revision, trigger/evidence, architecture/call paths, actual task/artifact changes, preserved work, invalidated proof and return position. A short delta or linked candidate is insufficient.
- Finish the explanation with a visibly marked Gate naming the exact target/revision and immediate effect, then actually ask apply this version, continue explanation/discussion, or park. Only the actual apply answer supplies Gate ConvergenceSource, DecisionSource, Decision=`replan`, TargetChange and HandoffRevision. A settled talk or fully answered frontier is insufficient; the later arrangement separately authorizes execution continuation.

## Apply and arrange the return

- Apply with the same inputs/approved Gate including GitPlan. Harness validates, journals bounded formal writes, preserves completed IDs, records the immutable applied revision and followup, then commits exactly those candidate/provenance paths through normal hooks. A failed commit leaves planning-applied/commit-pending and blocks execution. Reuse the same ReplanId and actual decision for recovery; do not duplicate the receipt or checkpoint implementation. Show its successful planning commit before the arrangement.
- Design/spec-only changes also receive an applied record. Keep detailed investigation in focused attachments; the applied record states trigger/evidence, decision, affected tasks/edges/artifacts, preserved work and proof.
- Successful application always asks the post-handoff arrangement Gate: archive/retain linked draft and continue now/queue/wait. Apply those choices and close the purpose-specific talk via [discussion operations](../harness/references/discussions.md). Acknowledging feedback does not authorize the design; an older execution source does not override a new wait decision.
- Return to the validated Ready task or verification/closure only when the current arrangement authorizes it. This can happen in the same session without creating a new chat. Unattended execution records necessary questions and waits for actual answers; it does not invent convergence or approval.
- Do not edit implementation inside Update. Do not alter existing accepted planning merely to make a failing test pass.
