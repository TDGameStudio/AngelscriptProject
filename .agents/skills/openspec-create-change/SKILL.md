---
name: openspec-create-change
description: Create one exact Change only after user-led discussion convergence and a version-bound handoff Gate, export its accepted design and evidence, then ask and apply the post-handoff draft/execution arrangement. Resume an existing handoff without replaying creation.
---

# Create a Change

## Enter on actual user convergence

- Harness owns the [double loop and Gates](../harness/SKILL.md). Grill does not suggest creation; wait until the user proactively says the design is ready. “Ready” permits preparing the handoff, not silently creating it.
- Read the selected draft's README/CONTEXT and `designs/<scope>/design.md`. Old scope README/log/glossary layouts remain readable; do not migrate them. Confirm one exact scope and target `<domain>/<type>-<scope>-<outcome>`.
- Prepare `handoff.md` with scope, target, accepted names, exclusions, unresolved followups and carryover sources/targets/reasons. Prepare complete English `Candidates` for proposal.md, design.md (with Call chains), canonical tasks.md, applicable delta specs and required textual exports. Carry required binary exports by their accepted byte-preservation contract. The first Gate reviews this full plan, not an empty shell.
- Read [the handoff Gate explanation](../harness/references/handoff-gate.md) before presenting this operation. Use [explaining-work](../explaining-work/SKILL.md) to give the full background, current and proposed architecture, terms/classes/call paths, concrete changes, reasons, proof and carryover. Present it in the conversation for a reader unfamiliar with the system; a short summary or linked design is insufficient.

## Preview and create

- Call `harness.change.create` with `PlanOnly=$true`, exact ChangeId, Title, Goal, Origin, DraftId/Scope (or Direct Reason and HandoffText), SessionId, `Candidates` and `GitPlan`. GitPlan has `RepositoryScopes=@{'.'=@('openspec/changes/<exact-id>')}`, a concrete `CommitMessage`, and optional `PreserveOutsideStaged`. Strict isolated candidate validation precedes a `HandoffRevision` binding complete planning, exports, canonical baseline and Git intent without canonical mutation.
- Display the complete account for that preview, followed by a visibly marked Gate naming its exact target/revision and immediate effect. Only then actually ask create this version, continue explanation/discussion, or park through a host mechanism permitted to collect approval. Do not combine this with the later archive/execution arrangement.
- After the actual answer, repeat the same inputs with `Gate=@{ ConvergenceSource=<actual source>; DecisionSource=<actual source>; Decision='create'; TargetChange=<exact id>; HandoffRevision=<presented revision> }` and no PlanOnly.
- A changed material design, candidate, handoff/export source, target, canonical baseline or Git intent needs a new preview and user decision. CONTEXT/navigation progress alone does not invalidate it. Never fabricate source references or infer approval from a passing checker.
- The new origin persists the receipt and expected exports, and creates an indexed `handoff-followup` talk. A private consumed intent and native manifest ownership checkpoint permit exact retries without replacing approval; historical schemas keep their earlier contracts. Query the exact target before retrying after interruption. If ownership cannot be proven, retain the CreationRecoveryRequired issue and inspect actual evidence; do not manufacture a marker for an unrelated unmarked Change.
- Explicit direct maintenance need not create any Change. An explicitly requested formal direct-origin Change still presents its concrete scope and uses the same Gate with an actual direct-origin reason.
- The operation materializes and validates the complete plan, then commits only its formal record directory through normal Git hooks. A rejected commit leaves the verified plan with its Git commit pending and blocks execution independently of the arrangement. Retry the identical operation, preserving its UID, output ownership and actual decision. Show the successful planning commit before asking the arrangement Gate.

## Export an independently usable seed

- Export accepted design and handoff in English to `attachments/drafts/design.md` and `handoff.md`. Translate explanations and diagram labels faithfully, preserving real names and behavior. Keep local original wording in the draft; do not invent an unclear decision during translation.
- Copy actually required research below `attachments/drafts/research/` and source attachments below `attachments/drafts/attachments/`, preserving nested relative identity and binary bytes. Legacy findings/glossary sources keep their readable compatibility mapping. Follow needed local links transitively; exported files must not depend on ignored draft paths.
- Materialize exactly confirmed decision talks with Context, Evidence, Options, Settled Decision, Consequences/Flip Condition, useful visual and Sources. Materialize admitted knowledge with insight, proof, boundaries, application and provenance under the [knowledge contract](../openspec/references/knowledge.md). Resume existing outputs instead of duplicating them.
- Keep full CONTEXT, optional transcripts, unrelated research and sibling designs local. An export list is a user-owned boundary, not an instruction to copy the entire topic.
- Maintain [attachments/INDEX.md](../openspec/references/attachments.md) with one entry per attachment, source scope, hard conclusions, reading reason and relevant exclusions. Validate expected exports, local link closure and English meaning; a hash checker cannot judge translation quality.
- Pass `harness.change.seed.verify`, `harness.change.plan.verify`, strict Change validation and the attachment audit for the accepted candidates. The create operation performs these before its formal planning commit. Preserve unfinished sibling status when updating selected handoff navigation; a copy/hash check alone cannot judge English meaning.

## Ask the arrangement Gate and return

- Creation success always leads to the post-handoff Gate: show the created target and unresolved scopes, ask archive/retain draft and execute now/queue/wait. Without a draft, record `not-applicable` and ask only execution.
- Follow [discussion operations](../harness/references/discussions.md) to record actual answers, apply their arrangements and close the purpose-specific talk. Archive uses the safe directory move; retain leaves discussion available. No generic `closed` shortcut or implicit execution.
- Only the chosen execution arrangement permits [Ensure plan and Apply](../openspec-apply-change/SKILL.md), through the queue. If waiting, leave an accurate return position with planning already saved. Ensure plan verifies the complete new plan; filling genuinely missing artifacts remains a historical-contract recovery path, not the default for new creation.
