# Explained Harness lifecycle with scoped Git closure

## Context and ownership

Harness owns workspace identity, lifecycle decisions and execution. Brainstorming owns ignored topic drafts; Grill owns continuing explained design questions; explaining-work owns causal explanations. GitOperations owns real candidate indexes, hooks and commits. The portable OpenSpec CLI owns record identity and deterministic moves. Current read-only status and historical records retain their contracts.

## Call chains

Preparation measured at: 7e1bc05a0810ba6a967b9e237981c09931dc622f; dirty: no changes in inspected Harness, Git, workflow Skills or harness specifications at preparation. The following Current/Proposed comparison preserves that accepted preparation snapshot.

Measured at: 2afe4b9090a3fc849545ee6301b2b83839fa8f84; dirty: this Change's Harness/Git modules, owning Skills/tests, AGENTS and harness/core + harness/git specifications/knowledge. Exact paths and source hashes are retained in final verification evidence. Unrelated Reference/scratch/image files and plugin changes are excluded.

Implemented creation: New-HarnessChange -> handoff.validate_creation_plan -> read-only complete candidate/link/Git preflight -> consume_gate -> owned native creation -> seed/plan/strict verification -> Complete-HarnessCreatedPlan -> Complete-HarnessGitCommit -> separate handoff arrangement.

Implemented Replan: Invoke-HarnessReplan -> replans.validate_candidate + planning_git -> exact planning journal/application -> Complete-HarnessReplanGit -> normal scoped Git commit -> separate arrangement. Implementation files remain outside that planning commit.

Implemented close: Close-HarnessChange -> terminal + strict + exact Git previews -> actual close Gate -> Complete-ClosureGitStep -> optional verified Complete-ClosureWithdrawal -> source checkpoint and indexed receipt/evaluation -> guarded native archive -> exact archived-item validation -> canonical record commit -> closure_status.inspect_closure -> change_queue/execution closing or advanceable state. Withdrawal checks use closure_withdrawal.py with a named baseline and explicit carryover.

Implemented feedback: Add-HarnessObservation -> Add-HarnessDraftFeedback -> existing topic README/CONTEXT/scoped design; Get-HarnessFeedbackInbox combines that view with historical read-only observations, and scoped triage updates the active owner. explaining-work reads source/spec/owning INDEX/entry, explains and captures the actual signal, then returns to the original work.

Current creation: user convergence -> Harness -> New-HarnessChange -> Invoke-HarnessChangeCreateCore -> handoff.preview/consume_gate -> native create -> origin and followup -> seed export/verify -> execution arrangement -> Ensure plan -> task.status.

Current planning revision: Update -> harness.replan.apply -> replans.py -> candidate staging/strict validation -> journal writes -> applied receipt and followup -> execution.py arrangement.

Current closure: verify/spec sync -> Complete-HarnessGitCommit(PluginsOnly) -> terminal evaluation -> Invoke-Harness archive boundary -> native archive -> strict archived validation -> change_queue.inspect_record.

Current feedback: Add-HarnessObservation -> Saved raw occurrence -> Feedback.psm1 derived inbox/triage. Current Git: Complete-HarnessGitCommit -> Resolve-GitCommitScopes -> Invoke-GitScopedCommitAttempt -> isolated candidate index -> hooks -> commit -> outside-index verification.

Proposed creation: user convergence -> complete candidate preparation -> isolated validation and Git preview -> exact Create Gate -> materialize owned Change -> seed/plan/strict checks -> scoped planning commit -> arrangement Gate.

Proposed closure: explained close preview -> actual scoped decision -> Close-HarnessChange -> owned implementation commit -> terminal evidence -> native archive boundary -> archived validation -> canonical-record commit -> completed operation receipt -> queue continuation.

## Decisions

Create includes the complete initial proposal/design/tasks/spec candidates. Replan commits formal planning only. Implementation normally commits at final closure; no old-implementation checkpoint is added for Replan. Abandoned/superseded closure retains an explicitly incomplete checkpoint. Abandoned closure also withdraws the shown owned implementation and proves/commits that withdrawal. Superseded closure follows the accepted replacement's carryover rather than deleting all implementation. Incomplete deltas are not promoted as completed current specifications.

Each of Create, Replan and closure displays the current system, accepted/candidate/final design relationships, task/verification consequences, exact Git selection, known limits and recovery state. Understanding feedback enters the explanation-driven improvement loop below; ambiguous questions use contextual Grill. A material candidate change requires a new preview. Understanding does not itself approve an operation. After the explanation, actually invoke the available selectable popup whose host contract permits approval; do not replace it with a numbered prose list. Use a concrete text fallback only if the eligible form is unavailable, fails or is reported invisible, explaining that limit. Pending, cancelled or preselected forms never count as decisions.

## Proposed public contracts

These are proposed additions, named using existing Harness route and PascalCase parameter conventions; they are not existing callable capabilities.

- Extend harness.change.create / New-HarnessChange with Candidates (Change-relative UTF-8 planning bodies) and GitPlan. PlanOnly stages candidates outside canonical records, validates the full TaskPlan and references, and binds all candidate content plus the Git plan into HandoffRevision. Native identity and generated metadata remain tool-owned.
- Extend harness.replan.apply with GitPlan for the accepted formal-record changes, applied provenance and purpose-specific followup. Existing Candidates, ExpectedHashes and ReplanId remain the baseline and recovery identities.
- Extend git.commit / Complete-HarnessGitCommit with RepositoryPatches (per-repository explicit binary-safe Git patches) and ExpectedPlanRevision. WhatIf reports PlanRevision and exact included/excluded deltas. RepositoryScopes still bounds allowed paths. A repository may use full attributable paths or an explicit patch selection, not an ambiguous union. ExpectedPlanRevision is mandatory for lifecycle consumers; standalone authorized legacy calls remain supported.
- Add harness.change.close / Close-HarnessChange(Context, ChangeId, ClosureKind, SessionId, PlanOnly, Gate, GitPlan, Dispositions). ClosureKind is completed, abandoned or superseded. Gate carries the actual DecisionSource, Decision=close, TargetChange and HandoffRevision. Read-only preview/status cannot perform mutations or fabricate approval.
- Retain harness.observe as the feedback entry, with topic ownership using OwnerDraftId and proposed OwnerScope. New feedback writes canonical topic draft Markdown; evidence and actual SourceRef are retained. Existing historical observations remain readable, but no second new-upgrade ledger is written.

GitPlan identifies each repository/context, branch and relevant baseline, the owned selection, candidate content identity, commit intent and expected deterministic generated outputs. Full opaque workspace hashes are not ownership proof. Preserve outside paths and staged hunks; changed selected content/baseline invalidates the preview. Unrelated dirty paths do not silently enter a commit. If a mixed hunk cannot be proven or safely applied, report that exact blocked selection.

## Recovery and concurrency

Use existing scoped creation locks and journal patterns, extending only the operation state needed to distinguish prepared, materialized, verified, committed and complete stages. Record Git facts and immutable operation identity in Harness runtime records; this is operational recovery, not a feedback issue ledger. Persist enough before mutation to inspect uncertain success after interruption. Retry exact operations from their remaining stage, validate refs/content before consuming the old decision, and never invent a replacement Change UID.

Generated UID, timestamps, applied receipts, archive destination and resulting gitlinks are identified in the preview as deterministic outputs constrained by the approved content/operation. Recompute final candidate bytes and validate their declared derivation; do not treat arbitrary additional text or paths as metadata. Hooks may not expand the accepted semantic selection unnoticed.

For completed closure, commit owned editable plugins before final terminal evidence. Sync only validated durable contracts. Archive through the existing integrity gate, validate the immutable archive, then commit canonical records and explicitly authorized gitlinks. If any later stage fails, retain earlier successful commits/archives and pause queue completion. Do not rewrite the archive to record its own final parent commit SHA.

For incomplete closure, retain true unfinished task dispositions and evidence. Save the approved incomplete checkpoint; withdrawal is a separate exact patch against that checkpoint. Preserve unrelated live/staged changes, stop on ambiguity or dependencies and run impact-related checks. Normal hooks remain enforced; a rejected checkpoint is an explicit blocker, not permission to bypass hooks. Replacement references are checked for superseded closure.

Replicas can commit editable plugin repositories; canonical OpenSpec commits use the primary record context. Root publication, implicit integration, push and workspace removal remain separate. Global worktree cleanliness is not a completion requirement; accurate disposition of the current Change is.

## Discussion and feedback loop

An active discussion owns side questions, corrections and tool returns unless the user explicitly changes or pauses the objective. Address the message, re-explain the complete relevant current design, recompute earlier and new unresolved choices, investigate facts, and actually submit ready questions. After listed choices are exhausted, inspect relevant counterexamples and failure recovery. No fabricated questions, repeat approvals, forced transcript mirror or automatic convergence is permitted.

Concrete friction automatically enters the matching topic draft, deduplicated by issue meaning and actual source. An ordinary preference is first handled locally; uncertain causes stay hypotheses. A feedback-only draft neither creates a Change nor expands execution. User-initiated batch discussion reads multiple topic drafts and writes conclusions back to their owners. Harness's short entry and evolution reference coordinate this workflow; no separate harness-update Skill is introduced. Archived drafts preserve issue disposition and handoff links; handed-off does not mean repaired.

## Explanation-driven improvement and capability knowledge

The user's request to clarify an existing explanation is a sourced improvement signal, including ordinary module explanations outside lifecycle Gates. An initial question about an unfamiliar module first receives a normal explanation; neither unfamiliarity nor the words used prove that a Skill is defective. Explaining-work identifies the understanding goal, owning capability and original discussion return point, reads the relevant current specification and capability knowledges/INDEX.md plus needed entries, and checks the actual implementation. Grill resolves only genuine uncertainty about the user's question or consequential choices; it does not ask the user to diagnose prompts or take a mandatory comprehension quiz.

Trace: understanding feedback -> relevant source/specification/knowledge lookup -> focused clarification and complete causal explanation -> classify the gap with evidence -> create/reuse its topic draft -> selected improvement or retained candidate -> factual/index/behavior proof as applicable -> use the improved material in later explanations -> return to the original discussion. A side explanation must not silently end the ongoing design discussion.

- Method gap: available facts were not connected through prerequisites, terms, cause and effect or a concrete example. Improve explaining-work's reusable method; keep module facts out of the Skill.
- Specification gap: intended behavior, boundary or scenario is ambiguous. Propose the owning Requirement/Scenario or clause-owned detail. If accepted behavior changes, return to the actual design/Replan boundary; implementation alone cannot establish intended behavior.
- Knowledge gap: the capability lacks mechanisms, call/data relationships, examples, tradeoffs, common misconceptions or applicability limits. Distill source-backed content into its knowledges directory and index it exactly once with provenance and status.
- Retrieval gap: suitable knowledge already exists but was not found or used. Reuse it and improve the index/reading path rather than writing a duplicate article.
- Evidence gap: code, specification and knowledge conflict, or available evidence is insufficient. Retain sourced questions and hypotheses in the draft and investigate before publishing current guidance.

Drafts retain the improvement question, evidence, key decisions, intended destination and disposition. Capability knowledge retains the verified reusable result. These are process and output, not two issue ledgers; neither copies the conversation transcript. New feedback alone does not authorize arbitrary Skill/specification changes or open a formal Change.

Within already authorized maintenance, timely factual knowledge updates are allowed when the evidence and owning capability are clear and no accepted behavior changes. During brainstorming, retain the candidate in the draft. Other scope changes require actual scope selection, authorized direct maintenance or an accepted Change/Replan. The user selected this authority boundary through explanation_knowledge_persistence; recording that choice is not blanket permission to update every module.

Knowledge admission distinguishes verified repair learning from factual explanatory enrichment. Repair learning retains its real implementation and regression proof. Factual enrichment checks relevant source/contract, call or state relationships, examples and applicability; use an existing test or minimal observation when a claim needs it. Do not invent a code repair or mandatory RED for a documentation-only fact. Preserve explicit Review policy, progressive INDEX lookup and immutable archived sources. Later explanations must actually read and use the appropriate updated current entry.

This Change updates explaining-work's entry/method and a focused improvement reference, Harness evolution and OpenSpec knowledge admission/retrieval guidance. It aligns the existing harness/core knowledge about evolution and produces openspec/specs/harness/git/knowledges/lifecycle-checkpoints.md with its INDEX entry after implementation and verification. That concrete knowledge explains planning versus implementation commits, archive and partial-success recovery; it complements delivery-authorities.md and does not claim future tools already work. It does not pre-authorize filling arbitrary module knowledge bases.

## Compatibility and rollout

Keep historical schemas and immutable archives readable. New active close decisions are enforced at the public mutation boundary even when creation was historical. Preserve old direct Git calls while requiring the stronger candidate identity for lifecycle calls. Older incomplete plans keep a documented explicit Ensure plan compatibility path; new complete-candidate creations cannot silently regenerate a different accepted plan at execution time.

Default closure waits for the specific shown decision. Explicit prior authority is reusable only when it covers the exact target/range, operation and conditions; a generic instruction to run a queue does not authorize arbitrary unseen commits. This default is part of this proposed Gate version, not a fabricated earlier user answer.

This Change is bootstrapped through the current Create Gate. Approval of its shown candidates explicitly allows materializing and committing these planning records before the post-handoff execution choice. That bounded manual bridge does not claim the new automated workflow already exists.

## Proof and limitations

Tasks specify isolated Git/OpenSpec fixture commands and cases. Verify the complete create/replan/three-kind closure path, stale previews, outside staging, mixed files, interrupted hooks and partial multi-repository success. Test queue advancement against the real close outcome. Retain consumer traces for side questions, partial answers, user pause, inadequate explanations, real decision provenance and feedback-only drafts. Add ordinary-module cases for method/specification/knowledge/retrieval/evidence gaps, factual admission within authority and later reuse. Static protocol checks cannot prove understanding or live UI continuation.

The earlier three-case offline old/candidate rehearsal passed both versions and did not reproduce the observed omission. It provides no measured reliability improvement. Real implementation tests and multi-round consumers remain future execution work. Unreal builds and Automation are excluded because no Unreal product behavior is affected.
