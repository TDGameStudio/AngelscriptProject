---
name: harness
description: "Project entry for AngelscriptProject code, tests, Skills and OpenSpec: select the workspace, route the discussion/execution double loop, or invoke a peripheral tool directly. Owns handoff Gates, queue continuation, feedback and visible updates; load one relevant method or tool leaf."
---

# Harness

## Enter once and choose the work

- Read `AGENTS.md`; resolve the selected Context and state `WorkspaceId`, `WorkspaceRoot` and `OpenSpecRoot` at entry, resume or explicit workspace switch. Implementation belongs to WorkspaceRoot; canonical records belong to OpenSpecRoot; trusted code belongs to HarnessRoot.
- Keep the current workspace. Creating/switching a workspace requires the user's request. The primary workspace is both control center and full execution workspace. Minimal replicas contain plugin worktrees/snapshots; retained parent worktrees remain readable and parked outside the queue workflow.
- Read an existing Change's `tasks.md` and `attachments/INDEX.md` first, then only the relevant leaf/reference. Never bulk-load all histories, attachments or command docs.
- Select one of three routes from intent: discussion, authorized Change execution, or a direct edit/tool/query. A request to directly fix a bounded problem can stay direct. OpenSpec is opt-in; do not fabricate a draft, Change, queue or Gate for a trivial explanation or authorized direct maintenance.
- Check the active conversation before routing a new message in isolation. During an existing Grill, a partial answer, side question, correction or tool return belongs to that discussion unless the user changes or pauses it. Answer it, restore the current relevant view and continue Grill's next ready choice; a factual subquestion does not close the parent discussion.
- Query `harness.status` at entry/resume. Show its update revision and relevant summary once in the conversation, again only if the revision changes. Report `UpdatesIssue` briefly if present; do not invent a version, maintain a seen database, hash the Skill tree or install a watcher.

## The two loops

```text
observation / user or external intent
  -> explain the evidence and intended outcome
  -> discussion loop
     -> automatic local draft                 // capture a substantial unresolved topic
     -> research -> explaining-work -> grill  // explain first, then ask
     -> user answer -> current architecture   // redraw the complete relevant view each round
     -> repeat until the USER says ready      // never propose Change creation proactively
     -> exact-version Create / Replan Gate
     -> successful handoff -> arrangement Gate
  -> execution loop
     -> authorized queue range -> Ready task -> implement -> verify
     -> explain result -> user feedback / requested review / observation
     -> local repair, or linked draft for an invalidated design
     -> verified closure -> next authorized item

peripheral tools: UE / Git / workspace / OpenSpec / status / observation
  -> callable at the point of need, without manufacturing a lifecycle
```

- Explanation is part of the feedback mechanism. Use [explaining-work](../explaining-work/SKILL.md) for architecture, relevant classes, callers/callees, key logic, ownership/lifecycle, data relationships and meaningful flags. Preserve concise ASCII diagrams and faithful code excerpts or explicitly simplified code with embedded explanations.
- After each Grill answer, explain the updated current scope, architecture, terms, impact and unresolved choices again. Link the answer to the changed design; do not substitute a delta list or "recorded" for an intelligible current view.
- Keep an active Grill moving without a separate user "continue" request: actually submit the next ready question after that explanation. A pending answer keeps discussion open; a missing form requires a concrete visible question, not a promise or completion reply. Grill's [rounds](../grill/references/rounds.md) and [host interaction](../grill/references/hosts.md) own the exact continuation behavior.
- User feedback may be a correction, query, pause or new objective. Inspect its meaning before routing. A status question or routine local failure does not force a new design loop. Review starts only when the user or an external agent explicitly requests it.

## Discussion and the two handoff Gates

- [brainstorming](../brainstorming/SKILL.md) owns automatic topic creation and current design; [grill](../grill/SKILL.md) owns explained questions. New drafts use `README.md`, key-decision `CONTEXT.md`, optional `research/` and indexed `attachments/`, and `designs/<scope>/design.md`. Prepare `handoff.md` only after user-led convergence. The full contract is in [drafts](../brainstorming/references/drafts.md).
- Do not mirror every reply, diagram or answer into draft files. Keep consequential decisions, reasons, corrections and provenance in CONTEXT; update the design when its substance changes. Old logs/findings remain readable in place; no automatic migration. Transcript recording is an explicit opt-in tool.
- When naming is being decided, include **“Provide more names”** in the conversation language; expand candidates with usage examples and tradeoffs in `research/naming-<subject>.md`, then explain and ask again. Follow [naming](../brainstorming/references/naming.md).
- While Grill is active, keep explaining and asking until the user proactively signals readiness. A fully answered frontier is not a signal to suggest creation. Once the user signals readiness, read [the handoff Gate explanation](references/handoff-gate.md): fully explain background, current and proposed architecture, concrete changes, reasons, proof and handoff impact for a reader unfamiliar with the system before a visibly marked exact-version question. A few summary sentences or a file link do not satisfy this Gate.
- Handoff Gate choices are: **create this Change / apply this Replan**, **continue explaining and discussing**, or **park**. Bind the actual decision and convergence sources to the presented revision. `PlanOnly` previews are read-only and do not approve anything. A material edit or changed target requires a fresh preview and decision; navigation/CONTEXT progress alone does not.
- For new Create, prepare the complete proposal, design, Task DAG, applicable delta specs and exports before the preview. Create and Replan include an explicit scoped GitPlan and persist accepted formal planning before the arrangement Gate. Replan never adds a checkpoint of the old implementation. New code normally waits for the explained final close, rather than a default commit after each task.
- After successful Create/Replan, always present the arrangement Gate: **archive or keep the draft**, and **execute/continue now or leave waiting**. Show unresolved sibling scopes before archiving; preserve their states. Without a source draft, disposition is `not-applicable` and ask only the real execution question.
- Record the arrangement in the handoff's purpose-specific talk. A generic closed discussion, old queue authorization or input acknowledgement cannot bypass it. Missing/corrupt expected records block execution. The concrete public protocol is [discussions](references/discussions.md).
- Explicit direct edits bypass these handoff operations. An explicitly requested formal Change without a draft still uses the direct-origin preview and exact Gate; never manufacture draft approval. Historical origins retain their accepted contracts.

## Execute and return to feedback

- All Change execution uses [change-queue](../change-queue/SKILL.md). `Scope=Change` is a thin single-item adapter; it cannot overwrite an existing queue, skip its head or start its following member. A queue controller retains the authorized ordered UIDs and request source; changes outside that range need new authority.
- Bind execution with `harness.execution.start`; inspect status before task/closure mutation and after long calls. Process actual incoming feedback with `harness.execution.input` and acknowledge exact IDs after triage. Pending input blocks implementation. Pause records intent; cancellation of a UE worker is a separate explicit tool action.
- Apply uses a seeded handoff, `harness.change.seed.verify`, Ensure plan, then `harness.change.plan.verify` and native `task.status` Ready nodes. Each task owns a bounded outcome, interfaces, cases, files and exact proof. Use grouped RED/GREEN for behavior; do not uncheck completed tasks.
- Fix ordinary implementation failures within the current task. Replan when evidence invalidates a requirement, design boundary, task boundary/edge, verification contract or required artifact, or exposes a user-owned decision. Read [replan](references/replan.md), pause the current Change and open/reuse a linked draft; preserve accepted artifacts until the actual Replan Gate is applied.
- Unattended continuation executes only already authorized work. Record unresolved user-owned decisions and wait; do not fabricate an answer or convergence. Attended discussion can resume in the same session through both Gates. A new handoff's “wait” choice supersedes earlier execution authority.
- Finish authorized work through verification, applicable spec synchronization and [closure](references/closure.md). Continue the remaining authorized range; stop on user pause, genuine blocker, required unanswered decision or exhausted scope. No automatic Review or successor Change.
- Before closing, explain accepted design versus implemented result, proof/limits, exact remaining Git changes and their disposition. Actually submit the specific close choice through an approval-capable selectable form; generic queue authority is not approval of unseen commit content. `harness.change.close` owns the approved commits, native archive and recovery. `close-pending` / `closing` cannot advance the queue.

## Peripheral tools and workflow improvement

- Use [routing](references/routing.md) to choose a leaf and `Get-HarnessCommand` as the executable route inventory. It reports route metadata, not parameter schemas; inspect the owning leaf for arguments. [queries](references/queries.md) selects read-only status without claiming or repairing work.
- UE uses `ue.*` and the selected workspace; builds/tests/commandlets/suites retain their worker leases, result semantics and explicit cancellation. Git/workspace/OpenSpec tools keep their own bounded authority. Integration, push, workspace creation/removal remain separately user-directed.
- Automatically capture sourced improvement signals through `harness.observe` into the existing topic draft (`OwnerDraftId`, `OwnerScope`); use a Harness-upgrade topic when that is its subject, not a new draft type or separate harness-update Skill. [Evolution](references/evolution.md) owns batch scope and evidence. “I did not understand” enters explaining-work's improvement loop without declaring a proven prompt defect. Capture may remain draft-only; the current authorized task continues at its preserved return point.
- Select proof through [verification](references/verification.md). Quick/Performance/Integration/full UE runs are conditional on impact, not daily defaults. Review protocol is [review](references/review.md); DAG details are [task-dag](references/task-dag.md).

## PowerShell and storage boundaries

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
Get-HarnessCommand
Invoke-Harness -Command harness.status -Context $context
```

- PowerShell 7 Core is required. Ordinary dispatch stays in the current process; bounded child `pwsh` is reserved for isolated tests, Git hooks/native fixtures and Harness-managed UE workers. No repository Codex project hooks, daemon or automatic new chat.
- Context is authoritative. Replacement roots/Context in route arguments are rejected; matching roots are idempotent aliases. `git.integrate` names its separately authorized SourceWorkspaceRoot.
- All routes retain the common result envelope. TaskPlan is native JSON, not a second Markdown parser. UE execution failure fails the envelope; a successful status query about a failed run remains a successful query.
- New scratch belongs under `Saved/AgentTemp/<topic>/`; runtime output retains existing `Saved/Harness/` lanes. Keep earlier Saved data. Accepted performance evidence must include a privacy-trimmed durable aggregate and raw hashes before closure; raw ignored files alone are not durable proof.
