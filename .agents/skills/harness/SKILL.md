---
name: harness
description: "Read first for any AngelscriptProject task that touches code, tests, Skills, or OpenSpec records: the entry router that selects the workspace, decides brainstorming vs Change vs task work, and routes to the one leaf Skill needed. Also use to resume an unattended request, handle an evidence-gated replan or explicitly requested review, or invoke OpenSpec, workspace, Git, and observation routes."
---

# Harness

Harness is a small Skill router, not an agent runtime. The repository uses one Git-derived workspace model: the primary checkout and every registered linked worktree have the same contract. Harness derives identity from Git, keeps execution rooted in the selected workspace, and loads trusted Skill code from the derived harness root. There is no daemon, database, event store, custom loop, or repository workflow mode.

Codex `/goal` is an external continuation mechanism. It can keep an agent working, but it does not select a repository mode, prescribe a branch name, create a worktree, or become state in `AgentConfig.ini` or OpenSpec. It continues only approved Ready tasks; it never opens `brainstorming`, never asks the user, and parks any user-owned decision it uncovers through `openspec-update-change` replan. This is the single definition; other Skills say "unattended continuation" and refer here. The current workspace remains the default; create or select a linked worktree only when the user explicitly asks for it.

Workspace creation, integration, publication, and removal are separate explicit actions. Never infer permission to run `workspace.new`, `git.integrate`, `git.push`, or `workspace.remove`; push is non-force and cleanup preserves the branch.

## Load progressively

Start with `AGENTS.md`, this file, the current `tasks.md` when a Change exists, and that Change's `attachments/INDEX.md`. Then load exactly one applicable leaf Skill or focused reference. Do not bulk-load command documentation, attachments, history, or scripts.

Use [routing.md](references/routing.md) only when the route is unclear. Load a protocol only when its event occurs:

- [task-dag.md](references/task-dag.md) when planning or selecting Ready work.
- [replan.md](references/replan.md) only after evidence invalidates accepted planning truth.
- [review.md](references/review.md) only after the user or an external agent explicitly requests a Review, or when triaging an existing Review file.
- [closure.md](references/closure.md) only when closing or archiving work.

OpenSpec is opt-in: create or mutate a Change only when the user or accepted work explicitly selects it.

## Orient and pass the Brainstorm Gate

Before creating a Change, establish the authorized objective, selected workspace, and whether the intended behavior is decision-complete:

- Name a new Change `<domain>/<type>-<scope>-<outcome>` with an allowed type from the OpenSpec [record schema](../openspec/references/record-schema.md). Keep unrelated outcomes in separate Changes and never rename an immutable archive to repair historical style.
- A new feature, architecture refactor, or major behavior change without an accepted decision-complete handoff uses `brainstorming` in `design` mode before Change creation; `research` and `proposal` modes open a draft whenever a reply carries a proposal, a trade-off, or more than one diagram, independent of any Change. Every question to the user is a grill round that opens with a situation brief; every round is recorded under `openspec/drafts/<domain>/<topic>/`; the topic draft is the durable owner of the conversation. Related independent frontier questions may share a round; dependent questions wait. Topic mode follows the current focus, while each designs/<scope>/ owns its design and handoff state.
- A clear defect repair, mechanical documentation change, or accepted ready-to-execute plan may skip brainstorming only when no user-owned decision remains unconfirmed; state the one assumption that justifies skipping.
- A decision-complete exploration handoff is not an active Change. If OpenSpec owns the work, `openspec-create-change` creates the canonical Change from the selected approved `designs/<scope>/` handoff — exporting `design.md` and `handoff.md` in English into indexed `attachments/drafts/` and materializing the user-confirmed talks and knowledge candidates — and the `Ensure plan` step of `openspec-apply-change` builds its Ready Task DAG before implementation mutation. A draft may also end `parked` or `abandoned` with no Change.
- Use `harness.draft.create`, `harness.draft.status`, and `harness.draft.check` for one exact local topic and selected design; Harness does not inventory or scan all drafts. `harness.draft.archive` moves only an explicitly completed or abandoned topic into ignored `openspec/archive/drafts/`. Parked topics stay active; archived drafts are historical inputs and new discussion opens a linked topic.
- New Change creation uses `harness.change.create` with an approved draft scope or a direct-origin reason. For draft-backed Changes, finish the English attachment export and pass `harness.change.seed.verify` before Ensure plan; `openspec.instructions` planning requests enforce the same seed gate. Every new Change gets a root `design.md` with `## Call chains` and passes `harness.change.plan.verify` before `task.status` or `openspec.instructions apply` can expose Ready work. The exact pre-gate active IDs keep their accepted plan contract.
- After Change creation, do not reopen `design`-mode brainstorming for that Change's scope. Use lightweight investigation inside the Ready task to inspect code, reproduce behavior, compare bounded options, or run a focused experiment. Apply never asks the user: an unlisted new public name is derived from convention and recorded as `Naming assumed` in task Evidence; a user-owned decision that surfaces is planning-invalidating evidence for replan. Update the Change only when evidence invalidates a requirement, design boundary, verification contract, dependency edge, or required artifact.

```text
unclear feature or architecture -> brainstorming (drafts/) -> approved design + confirmed carryover -> openspec-create-change -> openspec-apply-change (Ensure plan, then Ready nodes)
                                                            -> parked / abandoned draft (no Change)
Ready task uncertainty          -> lightweight investigation -> implement or evidence-gated replan
unlisted public name in a task  -> convention-derived name + `Naming assumed` in Evidence -> reviewed at verify
user-owned decision in a task   -> planning-invalidating evidence -> update-change replan -> next attended grill round
```

## Execute the work

1. Resolve the selected workspace and, when a Change exists, call `task.status` to choose a node whose derived `ready` field is true.
2. Read only the task's linked context. Confirm its bounded feature outcome and executable test cases, then use grouped RED/GREEN from the verification policy. Implement the smallest complete slice and retain exact task-to-case evidence, including any valid shared proving run.
3. Mark the task complete only after verification passes. Never uncheck completed work; add a follow-up node when new work is required.
4. After verification, Replan autonomously only when evidence invalidates accepted planning truth. Ordinary implementation uncertainty and local defects stay inside the task.
5. Otherwise proceed directly to closure or archive. Harness never starts an Incident or Final Review on its own and completion needs no Review classification.
6. When the user or an external agent explicitly requests a Review, follow [review.md](references/review.md). Any Review file that exists must reach a valid closed or superseded state before archive.
7. Integration, push, and workspace removal remain separate user-directed operations.

Investigate technical uncertainty and choose the strongest evidence-backed in-scope implementation without interrupting the user. Stop only when progress requires new authority: a product-goal change, destructive or external action outside scope, unavailable credentials, or irreconcilable user decisions.

## Explain relationships visually

Use `visual-explain` when a compact diagram materially clarifies multiple relationships, a sequence, or state transitions—for example workspace ownership, Task DAG readiness, Replan propagation, Review lifecycle, or cross-module execution. Prefer a small text diagram during conversation and a durable artifact only when future work benefits from it. Do not generate visuals for a single fact, a trivial edit, or information already clearer as one short list.

## Handle an explicit Review

An explicitly requested Review may run inline or as an asynchronous subagent. Asynchronous execution is an optimization, not a lifecycle default. In either case, assign an immutable snapshot and one unique Review file. While an asynchronous reviewer runs, continue only disjoint work; a moving workspace never redefines the assigned snapshot.

## PowerShell entry

PowerShell 7.0 or later (`Core`) is the only supported harness host. In the current PowerShell 7 session, import once:

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
Get-HarnessCommand
Invoke-Harness -Command harness.status -Context $context
Invoke-Harness -Command workspace.list -Context $context
Invoke-Harness -Command workspace.status -Context $context
Invoke-Harness -Command task.status -Context $context -Parameters @{ Change = 'domain/change' }
Invoke-Harness -Command ue.status -Context $context
```

Once imported, ordinary Harness routes execute directly in that current process; `Invoke-Harness` does not launch another PowerShell host for dispatch. Intentional child `pwsh` processes are reserved for isolated test hosts, Git hooks or native fixtures, and Harness-managed Unreal workers whose process lifetime is part of the route contract.

The selected Context is the dispatcher authority. Do not pass a different repository root or replacement Context through route parameters; matching explicit roots are only idempotent aliases, and `git.integrate` uses `SourceWorkspaceRoot` as its sole authorized different workspace.

Every invocation returns the same small result envelope. `task.status` returns OpenSpec TaskPlan JSON in `data`; OpenSpec validates the frontmatter graph while Harness owns workspace selection and scheduling. Task Card detail below the machine-readable surface remains ordinary Markdown for agents and people.

Unreal execution uses the same context and lazy-loads `unreal-engine-develop` only on the first `ue.*` route. Prefer `PlanOnly` before committing resources, `NoWait` when the caller wants an asynchronous `RunId`, `ue.run.status` for one managed run, and `ue.process.list` for a bounded machine view. Same-workspace operations remain exclusive; eligible Installed Engine builds may share an Engine lane across distinct worktrees. Load the leaf's [concurrency reference](../unreal-engine-develop/references/concurrency.md) only when selecting `Auto`, `Parallel`, or `Serialize`, choosing `Auto`, `Wait`, or `Fail`, or interpreting unknown progress.

The optional project Codex hooks run only fast, read-only `harness.status` at `SessionStart` (`startup|resume`) and `SubagentStart`. They add bounded orientation context when the repository hooks are trusted. Hook failure is never a correctness dependency; Cursor, Grok, and ordinary terminal use continue to call the same public routes directly.

Choose task, completion, and post-archive checks through the [impact-scoped verification policy](references/verification.md). Focused owner tests are the default; `Quick`, `Performance`, `Integration`, and real Unreal operations remain available only when their documented scope matches the demonstrated impact or an explicit user request.

The public runner itself starts fresh bounded `pwsh` hosts for individual gates so module state cannot leak between tests; that is an intentional test-isolation boundary.

Performance runs validate every timed sample. Raw `Summary.json` and `Samples.csv` remain below ignored `Saved/Harness/Performance/`; durable Change evidence keeps only a privacy-trimmed aggregate and its hashes. The default TaskStatus measurement uses an isolated temporary graph. Register accepted aggregates in the current Change and its attachment index before archive; ignored raw data alone is not durable evidence.

New agent-created scratch goes under `Saved/AgentTemp/<topic>/`. Harness-managed runtime outputs keep their documented `Saved/Harness/` lanes; existing Saved content stays in place unless a separate task explicitly owns cleanup.
