# Discussions, Gates and execution continuation

## Ownership and public routes

- Context selects canonical OpenSpecRoot and local runtime WorkspaceRoot. Drafts hold candidate design and key decisions; Change planning talks hold concise impact/provenance/return state. Optional explicit recording retains original frames separately. Queries never claim, repair or resume work.

| Route | Inputs / behavior |
| --- | --- |
| `harness.talk.create` | Change, SessionId, Kind=grill/talk, Theme, Summary, actual SourceRef; optional Questions, ResumeTask. Normal Purpose is planning. |
| `harness.talk.update` | Exact Change/TalkId/SessionId, ExpectedRevision; Summary, Questions, Status, Disposition, ResumeTask, Arrangements as relevant; ReplacementTalkId for supersession, ResolutionSource for rejecting unresolved questions or deciding no change. |
| `harness.talk.status` | Exact Change, optional TalkId; record metadata, blockers and malformed/unindexed issues. |
| `harness.change.create` | Exact target/origin/source and SessionId; PlanOnly returns HandoffRevision; mutation requires exact Gate. |
| `harness.replan.apply` | Change/TalkId/SessionId, ExpectedRevision, ReplanId, Candidates, ExpectedHashes, ResumeTask; optional DraftId/Scope or direct HandoffText, PlanOnly, Gate. |
| `harness.replan.status` | Exact Change; discussions, applied records, recovery and handoff state. |
| `harness.execution.start` | SessionId, Scope=Change/Queue, actual authorization SourceRef; exact Change for single-item selection. |
| `harness.execution.input` | SessionId, InputId, SourceRef, Summary, Kind=feedback/pause. Exact retries are idempotent; conflicting reuse of InputId fails. |
| `harness.execution.checkpoint` | SessionId, ExpectedRevision; Phase, ResumeTask, actual ProgressRef, AcknowledgeInputs, State/Reason and resolving SourceRef as relevant. |
| `harness.execution.status` | SessionId; derived state, authorized range, pending input, handoff, current work and implementation eligibility. |
| `harness.conversation.record` | Explicit opt-in bind/sync/status/unbind for exact session and DraftId or Change/TalkId. Legacy draft.record remains an alias. |

## Preview and first Gate

- Only user-led convergence enters preparation. Read [the handoff Gate explanation](handoff-gate.md) for the full beginner-readable account, exact visible boundary and actual question delivery. Present background, current/proposed architecture, concrete changes, reasons, proof, carryover and execution impact before asking create/apply, continue discussion or park. A short summary, file link or read-only preview is not an explanation or decision.
- The Gate object is `ConvergenceSource`, `DecisionSource`, `Decision=create|replan`, `TargetChange`, `HandoffRevision`. Source fields cite actual messages; do not manufacture approval provenance. A direct-origin formal operation follows the same exact-scope rule without creating a draft.
- Fingerprints include material selected design/handoff, relevant local references, formal Create Title and Goal and candidate/baseline map; current revision and target must match. `harness.draft.check` returns the draft-only `DraftRevision`; the Create preview returns this plus its complete `HandoffRevision`. Only that complete revision can approve creation. Navigation, progress and CONTEXT edits do not become artificial approval invalidators.
- New origins use schema 3; applied Replans carry a handoff receipt. Historical schemas remain accepted. Successful retry uses the persisted receipt even after the source draft evolves or archives; it does not fabricate a fresh approval.
- Creation persists a private consumed intent before the native call, then an owned manifest UID/hash checkpoint before publishing its origin. An exact retry can complete a missing marker/followup with the original receipt; preview never repairs. An existing unmarked directory without that ownership checkpoint, or a changed manifest/request, reports CreationRecoveryRequired instead of being claimed. Replan's receipt and followup share its existing journal transaction. Missing/corrupt/unindexed expected followups block execution rather than appearing as an empty decision list.
- New creation receipts preserve an export digest schema and per-export preservation contract. Non-Markdown exports retain their accepted SHA256; seed verification checks destination bytes using the receipt/origin map even after draft evolution or archive. Markdown may be translated or have links rewritten and retains semantic/link validation. Historical origins without export digests keep their accepted schema contract.

## Post-handoff Gate and arrangements

- The created `purpose: handoff-followup` talk belongs to the exact handoff. Never feed it to Replan or treat generic discussion closure as equivalent.
- It has two stable question IDs: `draft-disposition` accepts `archive|retain|not-applicable`; `execution-disposition` accepts `now|queue|later`. Each actual answer has its source. `not-applicable` is only valid without a draft, with source `not-applicable:no-draft`.
- Present the result and unresolved scopes before asking. Archive is a deliberate move preserving unresolved state; retaining a draft does not invalidate the completed export. `queue` means configured for later, not immediate implementation. `later` leaves execution waiting/paused.
- Update the talk with the answered questions first. Apply the requested draft move/retention and execution arrangement using actual routes. Execution start/checkpoint can establish the requested binding while the followup is still blocking implementation; queue disposition needs actual membership and no running binding that contradicts waiting.
- Close only after both arrangements took effect, using Status=`closed`, Disposition=`no-change`, and `Arrangements` with `draft`/`execution` objects. Each records `status='applied'`, `source` and `decision` matching its question. Archive additionally supplies the actual archive `path`; the validator derives the exact handoff and session binding rather than trusting a free-form receipt.
- Tool validation checks the actual archive/retained draft and queue/execution state. Generic close, missing answers, deferred/superseded disposition and acknowledgement cannot bypass it. Inspect the exact returned issue rather than adding a fake “applied” marker.

## Planning talk and transactional Replan

- `harness-talk-v1` stores identity/revision/source/scope/questions/return task. Each question uses id/question/answer/source. `open` is unresolved; `settled` requires actual answered necessary questions but remains unapplied. History preserves prior states; transcript capture is optional.
- Normal planning talks close with applied/no-change/deferred/rejected. Only successful Replan writes applied; deferred is for followup scope, not an unresolved current Change. Closing unanswered current-Change decisions as no-change/rejected requires an actual `ResolutionSource`; keep the explanation in Summary. This records existing resolution evidence and does not create another approval step.
- Supersession requires `ReplacementTalkId` naming an indexed, active planning talk of the same Change, scope and workspace. Self-reference, cycles, terminal targets and conflicting question identities fail before record or INDEX mutation. Pending questions transfer to the replacement with the source talk, revision, source reference and return task. The replacement revision advances, so reload it before updating. A replacement cannot silently drop inherited pending questions; answer them or retain actual resolution evidence. Queries follow the replacement chain and fail closed on missing ownership, provenance or records. Legacy unstructured talks remain historical.
- Candidates map allowed planning paths to full UTF-8 text; ExpectedHashes includes every candidate and tasks.md. Staged CLI validation and baseline checks precede bounded journal writes. Reuse ReplanId for recovery; status never repairs. Preserve permanent/completed task IDs, proof and unrelated work.
- Formal outputs use English; optional recognized original transcript frames preserve their original language. INDEX changes accompany record creation/state changes. Ordinary local failures need no new talk.

## Queue continuation and interruption

- Every Change execution binds the queue core. The single-item adapter keeps an existing queue intact and rejects a non-head request. Controller authorization stores exact ordered UIDs and source; completion of one authorized item never marks the next started beyond the range. Added tail items remain unauthorized.
- Input capture is public in every host. Pending feedback blocks mutation; acknowledge only after triage. Classify local repair/query, substantial design feedback, pause or independent followup without silently changing scope. Pause does not cancel a running UE worker.
- Necessary user choices wait. A successful applied Replan still waits for the current arrangement Gate; only an actual fresh execution choice can authorize its handoff. After “later”, old start sources cannot restart it. An explicit later request can resume the already chosen design without replaying the first Gate.
- Inspect at entry, before tasks/closure and after long tools. Querying cannot repair journals or take over controllers. Replacing occupied bindings/taking over queues needs explicit prior-session-stopped authority; a token is not liveness evidence.
- An explicit request to cancel or replace an unfinished execution scope can checkpoint State=`released` with actual SourceRef and Reason. Only that session's controller is released; history is retained and completion is never fabricated. A subsequent start binds the new authorized scope.
- No project Codex hooks, daemon or automatic chat. Plan mode, real blockers, unanswered necessary choices, explicit pause and completed authorized range permit stopping. Save actual ProgressRef and exact return position; lack of progress is never completion.
- If recording was enabled, reconcile/unbind its active sink before terminal evaluation/archive. Archived originals remain immutable. No mandatory chat/draft mirror exists.
