# Discussions and execution continuation

- Use the selected Context: Change records live at OpenSpecRoot; session bindings and journals live in ignored Harness output lanes. Queries never start, claim, repair or resume work.
- `grill` is the questioning method. `talks/grill-<time>-<theme>.md` keeps interactive decisions and full originals; `talks/talk-<time>-<theme>.md` keeps technical analysis. One discussion owns one file; keep its prefix after settlement. Legacy talks need no migration.

## Public routes

| Route | Input | Result |
| --- | --- | --- |
| `harness.talk.create` | `Change`, `SessionId`, `Kind=grill|talk`, kebab-case `Theme`, `Summary`, actual `SourceRef`; optional `Questions`, `ResumeTask` | Indexed record, `talk_id`, `revision` |
| `harness.talk.update` | Exact Change/Talk/Session, `ExpectedRevision`; changed `Summary`, `Questions`, `Status`, `Disposition` or `ResumeTask` | Current view updated, originals and prior decisions preserved |
| `harness.talk.status` | Exact `Change`; optional `TalkId` | Records, blockers and malformed-record issues; no transcript bodies |
| `harness.conversation.record` | `Action=bind|sync|status|unbind`, `SessionId`; bind adds source, explicit start line, either `DraftId` or exact `Change` plus `TalkId` | Shared source coverage; old `harness.draft.record` remains compatible |
| `harness.replan.status` | Exact `Change` | Applied IDs, pending discussions and recovery state |
| `harness.replan.apply` | Change/Talk/Session, `ExpectedRevision`, `ReplanId`, `Candidates`, `ExpectedHashes`, `ResumeTask` | Validated immutable applied record or recoverable failure |
| `harness.execution.start` | `SessionId`, `Scope=Change|Queue`, actual authorization `SourceRef`; Change scope adds `Change` | Explicit local execution binding; Queue scope claims the configured queue |
| `harness.execution.checkpoint` | Session, `ExpectedRevision`; optional `Phase`, `ResumeTask`, actual `ProgressRef`, `AcknowledgeInputs`, `State`, `Reason`, resolving `SourceRef` | Current position without replacing scope |
| `harness.execution.status` | Exact `SessionId` | Derived state, Change, next action and implementation eligibility |

## Decision lifecycle

- `harness-talk-v1` frontmatter stores identity, revision, source, scope, questions and return task. Each question has `id`, `question`, `answer`, `source`; unanswered values are null. Prior current views remain in history; Conversation is append-only.
- `open` means investigation or questioning is incomplete. `settled` requires actual answers and provenance for necessary questions; implementation remains blocked until application or explicit disposition.
- `closed` records `applied`, `no-change`, `deferred` or `rejected`. Only successful Replan writes `applied`. `deferred` requires `Scope=followup`; current Change decisions cannot bypass execution. `superseded` names its replacement in the disposition. Closed decisions receive linked follow-ups.
- Before substantive plan changes, expand affected decisions. Unattended findings stay open without a question round. An attended session runs Grill immediately and returns to Update without a new draft or another session.
- Recognized original source frames retain the conversation language. Current summaries and final Change planning artifacts use English. Do not translate or trim originals for a language gate.
- Update INDEX with creation and state changes. Malformed records or incomplete indexing block execution/closure. Ordinary local defects need no discussion record.

## Replan application

- `Candidates` maps Change-relative `proposal.md`, `design.md`, `tasks.md` or `specs/**/*.md` to complete UTF-8 text. `ExpectedHashes` includes every candidate's SHA-256 (null for a new file) and current `tasks.md`. Reuse one `ReplanId` across retries.
- Validate a staged copy through the packaged CLI, recheck baselines, preserve task IDs/completed tasks, journal bounded writes, validate the result and finalize the applied record. Status never repairs a journal; retrying apply reconciles owned writes and refuses external conflicts.
- A design/spec-only update still produces an applied record. Preserve valid implementation and evidence; changed behavior needs fresh proof. Return to the new Ready task or the appropriate verification/closure step.

## Continuous execution and hooks

- Start binds only the authorized Change or configured queue. Recording, research and queries do not grant execution authority. Replacing an occupied session binding needs explicit `PreviousSessionId` and `PreviousSessionStopped`; occupied queue controllers still require explicit queue takeover.
- `waiting-input` pauses the whole current Change. Settled discussion returns to Replan automatically. Explicit `paused`/`blocked` need a reason; resume requires its resolving `SourceRef`. Completion derives from completed archives, never a checkpoint assertion.
- At entry, before tasks/closure and after long tools, inspect execution and queue state. Triage `pendingInputs`, retain unrelated ideas as follow-ups and acknowledge exact IDs. Acknowledgement records handling, not approval.
- `UserPromptSubmit` registers input without interpreting it. `Stop` continues a bound running request; its generated prompt is not a new decision. `Interrupt` preserves user pause. Plan mode, waiting, pause, genuine blockers and completion allow stopping. Repeated continuation without observable progress reports a recovery blocker, never completion.
- Keep `ProgressRef` tied to actual work/proof. A controller token does not prove liveness. Hooks never create chats, switch workspaces, take over another session or implement Replans.
- Synchronize and unbind Change recording before final evaluation/archive. Archived originals are immutable; new feedback needs an active owner. Configuration alone does not prove native activation; validate native trust and actual event coverage separately.
