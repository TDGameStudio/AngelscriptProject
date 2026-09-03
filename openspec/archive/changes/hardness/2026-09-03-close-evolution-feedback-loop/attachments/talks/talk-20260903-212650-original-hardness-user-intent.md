# Original Hardness User Intent Baseline

## Provenance and Source Limits

- **Captured:** 2026-09-03T21:26:50+08:00.
- **Record type:** A selective reconstruction created after the user asked whether the earliest Hardness requirements had actually been preserved and completed.
- **Conversation boundary:** The current session supplied the original request sequence and later corrections. That conversation is not a repository artifact and is not claimed as independently replayable evidence.
- **Durable boundary:** The immutable Change records listed under Sources corroborate architecture decisions and chronology, but none is a contemporaneous single baseline for the whole original request.
- **Authority:** Current proposal, specifications, design, and tasks remain canonical. This talk preserves cross-capability rationale, corrections, and source mapping; it is not task, issue, Review, or capability state.

## Selective Carryover Boundary

This talk exists because the original request was an extended user-led refactor spanning Hardness, OpenSpec, Workspace, Git, Review, exploration, Unreal execution, hooks, performance, and migration boundaries. Several later corrections reversed architectural interpretations. Distributing only the resulting requirements across artifacts made it difficult to distinguish intentional deferral from accidental omission.

Future work should create one intent talk only when a similarly major decision cluster contains multiple interacting constraints, meaningful corrections, rejected interpretations, or non-obvious rationale that canonical artifacts would flatten and future agents would otherwise re-decide. A clear defect, mechanical documentation edit, one-step request, routine task-local choice, or decision already explained completely by canonical artifacts creates no intent talk and no not-required placeholder.

The talk must not copy chat transcripts, question-round navigation, implementation progress, task checklists, test logs, Git status, or canonical requirement prose. One accepted decision cluster should normally produce at most one selective baseline.

## Settled User Intent

### Hardness core

- 📌 **Pinned intent:** Hardness is the lightweight Skill-system entry for this AngelScript plugin project, not a custom agent runtime, daemon, database, event store, or repository-specific replacement for Codex `/goal`.
- 📌 **Pinned intent:** The primary checkout and linked worktrees use one Git-derived workspace model. `/goal` is external unattended continuation, not a `Goal` repository mode or branch convention.
- 📌 **Pinned intent:** Focused Skills own their PowerShell functions, scripts, tests, and detailed guidance. Hardness progressively routes one selected operation without bulk-loading every leaf or historical attachment.
- 📌 **Pinned intent:** PowerShell 7 is the only supported host. A long-running agent may keep one PS7 session, import Hardness once, and repeatedly invoke exact workspace routes.
- 📌 **Pinned intent:** Ordinary technical uncertainty should be resolved autonomously. User interruption is reserved for real authority boundaries such as destructive data loss, credentials, integration, push, publication, or explicit workspace removal.
- 📌 **Pinned intent:** Harness performance and elapsed workflow stages should be measured and retained, while workflow quality and decision latency remain more important than micro-optimizing every command.

### OpenSpec and planning

- ✅ **Settled:** Deep `openspec-explore` belongs before a new feature, major behavior change, or architecture Change is created. After creation, implementation uses continue, update, apply, or evidence-gated Replan with task-local investigation.
- ✅ **Settled:** Maintained Skills, OpenSpec records, templates, and command guidance use accurate English. `_ZH` was a temporary localization exception for separate cleanup.
- ✅ **Settled:** The portable OpenSpec executable lives at `.agents/skills/openspec/bin/openspec.exe`; concise command guidance is split by command, and candidate executables do not repeatedly enter parent Git history.
- ✅ **Settled:** OpenSpec retains validation and locally configurable instruction/template injection. Source/package drift or a CLI defect must have a visible maintenance entry and be repaired only through an explicit fork-maintenance Change.
- ✅ **Settled:** `tasks.md` exposes one versioned YAML-frontmatter DAG recognized through Hardness. Dependencies derive from graph edges, not Markdown order or repeated `After:` prose.
- ✅ **Settled:** Task Cards may include useful context, constraints, inputs, outputs, hazards, and evidence, but those details must not become a rigid verbose schema.
- ✅ **Settled:** User, agent, subagent, implementation, verification, or Review evidence may initiate Replan triage, but Replan applies only after evidence invalidates accepted planning truth. Each applied record preserves semantic task, edge, artifact, Git, and preserved-work changes.

### Evidence, Review, and knowledge

- ✅ **Settled:** Material technical problems use detailed indexed `attachments/implementation/` issues. Non-obvious major decisions and decision-critical visuals use indexed talks. Reusable evidence-backed insights begin as change-local knowledge and are promoted deliberately.
- ✅ **Settled:** Review is explicit and exceptional, not routine task cadence. It may run asynchronously against an immutable snapshot while the coordinator continues only disjoint work.
- ✅ **Settled:** Review reports may retain detailed findings. Every registered finding needs triage, resolution evidence, and re-review history; report length itself is not a defect.
- ✅ **Settled:** Verified work may archive without Final Review when no user or external agent requested one. Local implementation defects are repaired directly; only invalid planning truth triggers Replan.
- ❗ **Required invariant:** A material dogfooding problem must never remain only in chat, ignored observations, or a final summary. Once admitted, the existing material-issue lifecycle must resolve it, reject it with evidence, or supersede it with an exact issue owner before archive.

### Workspace and Git

- ✅ **Settled:** `AgentConfig.ini` is ignored machine-local Hardness data. It binds exact workspace, primary root, Git common directory, `.uproject`, and engine configuration so a worktree operation cannot silently target main.
- ✅ **Settled:** Workspace discovery, bootstrap, activation, status, and explicit removal belong to workspace lifecycle. Commit, local integration, and explicit non-force push belong to Git operations.
- ✅ **Settled:** Worktree creation and removal happen only when requested. Integration, push, and cleanup are separate authority decisions; one successful stage never authorizes the next.
- ✅ **Settled:** Exact scoped commits preserve unrelated dirty state. Conservative rejection remains the default; current dogfooding requires an explicit, auditable path-only option for preserving scope-external staged entries rather than a manual Git fallback.

### Unreal development

- 📌 **Pinned intent:** `unreal-engine-develop` is a focused leaf integrated through Hardness. Required PowerShell functions, declarative data, tests, and references live in the Skill system rather than depending on old root `Tools` wrappers.
- ✅ **Settled:** The Unreal surface covers target and engine discovery, build, Automation, suite, commandlet, active process observation, trusted progress, cancellation, and UBT-aware coordination for the exact selected workspace.
- ✅ **Settled:** Distinct worktrees may build concurrently when their resource policy permits it. The agent can inspect active work and credible progress, then use typed wait, fail, parallel, or serialized behavior without treating raw `-NoMutex` as inherently unsafe.
- ✅ **Settled:** Expensive real UE validation may use an authorized isolated worktree. During a large product refactor, fixture, read-only, and plan-only verification may close the Skill layer while real UE evidence remains separately owned.

### Optional adapters and explanation

- 📌 **Pinned intent:** Codex hooks should improve orientation without becoming a correctness dependency or coupling Cursor, Grok, or terminal clients to Codex. Only bounded, read-only, fail-open startup/subagent context is appropriate for the initial adapter.
- 📌 **Pinned intent:** Compact `visual-explain` output should be used proactively for architecture, ownership, Task DAGs, concurrency, or multi-state workflows when it reduces ambiguity. Trivial edits and single facts should remain prose-first.

## Architecture-Changing Corrections

- ❌ **Dropped interpretation:** `hardness-harness` as the durable domain name. The project-level domain is `hardness`.
- ❌ **Dropped interpretation:** Repository `Goal` and `Current` modes. That model confused Codex continuation with Git topology and was replaced by one exact WorkspaceRoot contract.
- ❌ **Dropped interpretation:** Repeated task `After:` metadata or compact chain syntax as canonical dependency truth. YAML `task_graph.depends_on` owns the DAG.
- ❌ **Dropped interpretation:** Automatic or impact-inferred Final Review. New Review requires an explicit user or external-agent request.
- ❌ **Dropped interpretation:** Windows PowerShell 5.1 compatibility and duplicate PS5/PS7 gates. Only PowerShell 7 remains supported.
- 🚫 **Excluded architecture:** Automatic push, automatic worktree removal, destructive rollback of partial multi-repository delivery, a mandatory Codex-hook dependency, a central database/event store, or inspection/refactoring of the abandoned root `Tools` loop experiment.

## Snapshot Boundaries

At capture time, the accepted first Unreal integration covered the PowerShell/Hardness surface through hermetic process fixtures plus actual-workspace read-only and `PlanOnly` checks. Standalone, package, coverage, release orchestration, CachePackage, full StaticJIT flow, and real UE/UBT end-to-end evidence retained separate ownership. Remaining root `Tools` capabilities were deletion candidates only after a replacement owner and tests existed. Automatic OpenSpec fork upgrade remained a separate explicit Change. These statements record the capture boundary and do not replace current specifications or issue status.

## Canonical Mapping

| Intent cluster | Canonical current owner |
|---|---|
| Static router, autonomy, Task DAG, Explore, Replan, Review, dogfooding, PS7, hooks, visuals | `openspec/specs/hardness/core/spec.md`; `.agents/skills/hardness/SKILL.md`; `.agents/skills/hardness/references/` |
| Workspace identity, AgentConfig, selection, lifecycle, execution guard | `openspec/specs/hardness/workspace/spec.md`; `.agents/skills/workspace-lifecycle/` |
| Exact commit, local integration, explicit push | `openspec/specs/hardness/git/spec.md`; `.agents/skills/git-operations/` |
| Unreal/UBT operations, progress, concurrency, suite boundaries | `openspec/specs/hardness/unreal/spec.md`; `.agents/skills/unreal-engine-develop/` |
| Portable CLI, validation, instructions, command docs, package maintenance | `.agents/skills/openspec/SKILL.md`; `.agents/skills/openspec/commands/`; `.agents/skills/openspec/references/` |
| This reconstruction and its unresolved process/Git repairs | `openspec/changes/hardness/close-evolution-feedback-loop/` |

## Sources

- `openspec/archive/changes/hardness/2026-09-03-refactor-skill-system/proposal.md`
- `openspec/archive/changes/hardness/2026-09-03-refactor-skill-system/design.md`
- `openspec/archive/changes/hardness/2026-09-03-refactor-skill-system/tasks.md`
- `openspec/archive/changes/hardness/2026-09-03-restore-exploration-authoring-contracts/proposal.md`
- `openspec/archive/changes/hardness/2026-09-03-restore-exploration-authoring-contracts/design.md`
- `openspec/archive/changes/hardness/2026-09-03-restore-exploration-authoring-contracts/attachments/talks/`
- `openspec/archive/changes/hardness/2026-09-03-refactor-unified-workspace-core/proposal.md`
- `openspec/archive/changes/hardness/2026-09-03-refactor-unified-workspace-core/design.md`
- `openspec/archive/changes/hardness/2026-09-03-refactor-workspace-git-operations/proposal.md`
- `openspec/archive/changes/hardness/2026-09-03-refactor-workspace-git-operations/design.md`
- `openspec/archive/changes/hardness/2026-09-03-integrate-unreal-development/proposal.md`
- `openspec/archive/changes/hardness/2026-09-03-integrate-unreal-development/design.md`
- `openspec/archive/changes/hardness/2026-09-03-integrate-unreal-development/tasks.md`
