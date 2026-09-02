# Hardness Core

## Purpose

This capability defines how the AngelscriptProject Skill harness selects a workspace, dispatches project commands, maintains a resumable execution plan, and performs autonomous Review and Replan without crossing user authority boundaries.

## Requirements

### Requirement: Progressive skill routing

Hardness SHALL be the single short entry for the project Skill system and SHALL load only the selected leaf Skill or reference from a static route. Default context MUST NOT bulk-load command documentation, attachments, Replan history, or script implementations.

#### Scenario: Route one project command
- **WHEN** an agent requests a registered command in a session that imported Hardness
- **THEN** the system loads only that command's leaf module and returns the common structured result

#### Scenario: Exclude an unfinished leaf
- **WHEN** a project command leaf is intentionally deferred to a separate change
- **THEN** Hardness does not publish placeholder routes or report that leaf as installed until its complete contract is independently verified

### Requirement: Explicit workspace modes

The system MUST support Goal and Current modes. Goal uses an isolated Git worktree by default, while Current remains in the current checkout. Neither mode may automatically merge, push, or remove the workspace after completion.

#### Scenario: Start a Goal task
- **WHEN** native Goal mode starts a change that requires implementation
- **THEN** the system creates an isolated branch below the ignored worktree root, restores exact submodule gitlinks, and safely copies machine-local configuration

#### Scenario: Work directly
- **WHEN** the user explicitly requests work in the current checkout
- **THEN** the system does not create or switch worktrees and preserves existing uncommitted changes

### Requirement: Retained Hardness performance evidence

Hardness SHALL expose one performance-test profile that measures fresh-process and persistent-session harness paths independently in Windows PowerShell 5.1 and PowerShell 7. Every sample MUST also validate the invoked behavior. Each run MUST write a unique structured summary and raw sample table without overwriting or automatically deleting prior runs, while the change record retains a privacy-trimmed aggregate baseline and hashes of its raw source artifacts.

#### Scenario: Record a two-host performance run
- **WHEN** the Performance profile runs for both supported PowerShell hosts
- **THEN** each host reports its own warmup count, measured samples, min/median/p95/max, behavior result, and broad catastrophe-budget result in one unique Saved run directory

#### Scenario: Preserve comparable evidence without a flaky machine gate
- **WHEN** one accepted run is registered as the current baseline
- **THEN** raw machine-specific samples remain ignored local data, a trimmed aggregate is indexed under change attachments, and a single prior-run regression ratio remains advisory until representative history establishes a portable threshold

### Requirement: Hardness-recognized Task Graph

`tasks.md` MUST be the change's only current execution state and DAG. A current-format file MUST declare one versioned YAML-frontmatter `task_graph.depends_on` map whose quoted stable `X.Y` keys exactly match the top-level Markdown checkbox IDs. The Markdown body MUST retain each task's checkbox state, `Files:`, and exact verification command. A completed task MUST NOT return to incomplete, and an ID MUST NOT be reused or renumbered.

#### Scenario: Derive ready work through Hardness
- **WHEN** Hardness reads a current `tasks.md` and all `depends_on` predecessors of an incomplete task are complete
- **THEN** the task is Ready through the Hardness task route and may run in parallel only when its files, artifacts, and resource leases are also disjoint

#### Scenario: Keep presentation separate from execution
- **WHEN** Graph keys and Markdown task blocks are displayed
- **THEN** they use natural numeric task-ID order while dependency edges and Ready state derive only from `depends_on`

#### Scenario: Read historical task records
- **WHEN** validation or archive audit encounters an older `After:`-only task record without Task Graph frontmatter
- **THEN** it remains readable, while a file that mixes both dependency dialects fails validation

### Requirement: Evidence-gated replan

A Review finding MUST NOT directly trigger Replan. Hardness may apply a Replan only after evidence proves that a requirement, design, acceptance condition, task boundary, dependency edge, or completion record is invalid, and it MUST preserve a lightweight immutable semantic-diff record.

#### Scenario: Fix within the current plan
- **WHEN** a finding exposes only an implementation defect inside the current task
- **THEN** the system fixes it in that task or an implementation issue without creating a Replan

#### Scenario: Replace an invalid plan branch
- **WHEN** verified evidence invalidates part of the existing Task DAG
- **THEN** the system records old-task dispositions, preserves valid work, updates current artifacts/tasks, and creates one `status: applied` Replan file

### Requirement: Review closure

Before completed archive, every review file MUST be `closed` or `superseded`; no Critical or Required finding may remain open or deferred; and every resolved finding MUST include resolution and evidence.

#### Scenario: External fixed-snapshot review
- **WHEN** an external reviewer is assigned a fixed commit or diff snapshot
- **THEN** the reviewer creates only its assigned review file while Hardness owns registration, triage, resolution, re-review, and closure

### Requirement: Deterministic OpenSpec package

The distributed OpenSpec executable MUST be located at `.agents/skills/openspec/bin/openspec.exe` and MUST be reproducible from the parent-recorded `Tools/openspec` commit, immutable 0.8.1 tag layered after preserved 0.8.0 and 0.7.4 snapshots, locked build commands, byte-identical isolated rebuild gate, and release manifest. Existing candidate tags MUST NOT be moved to impersonate a repaired snapshot. The parent repository MUST commit only the final accepted package once per release and MUST NOT commit intermediate or candidate executable builds.

#### Scenario: Validate a packaged release
- **WHEN** installation health checks validate the OpenSpec package
- **THEN** the executable version, SHA-256, source commit, annotated tag object/target, command-document set, release gates, and manifest agree

#### Scenario: Preserve parent binary history
- **WHEN** an OpenSpec release is iterated before final acceptance
- **THEN** candidate executables remain outside parent history and the final accepted package enters the parent repository in exactly one release commit

### Requirement: English OpenSpec maintenance surface

All maintained OpenSpec source documentation, Skills, command references, project workflows/templates, manifests, current specs, active changes, attachments, and new archive records MUST use English. Files explicitly named with `_ZH` MAY remain temporarily and MUST be the only localization exception.

#### Scenario: Reject a non-English maintained record
- **WHEN** package validation scans an ordinary maintained OpenSpec path or supported text file containing a Han character
- **THEN** validation fails and reports the exact relative file and line

#### Scenario: Preserve an explicit localization file
- **WHEN** the same scan encounters a file whose name contains `_ZH`
- **THEN** that file is excluded without exempting sibling files or parent directories

### Requirement: Harness dogfooding feedback

Hardness SHALL support self-hosted evolution in which Hardness and OpenSpec changes are executed through the same harness being developed. Every discovered problem MUST be classified from evidence before it changes durable policy: a local implementation defect remains in the current task or an implementation issue, an invalid planning boundary creates Replan, and a recurring reusable invariant may be promoted to capability knowledge.

#### Scenario: Dogfooding exposes a local defect
- **WHEN** a self-hosted run finds behavior that violates an existing requirement without invalidating the plan
- **THEN** the coordinator records reproducible evidence, adds a regression test, repairs the current task, and does not create Replan

#### Scenario: Dogfooding invalidates the plan
- **WHEN** self-hosted evidence proves that a requirement, acceptance contract, task boundary, or dependency edge is false
- **THEN** the coordinator applies the Replan protocol, preserves valid work, and resumes without asking the user for an in-scope technical decision

### Requirement: Progressive harness knowledge promotion

Reusable harness knowledge MUST be loaded progressively and promoted explicitly. Change attachments own current evidence; capability-side `knowledges/` owns stable reusable guidance; project instructions own only cross-capability invariants. Archive MUST NOT promote knowledge implicitly.

#### Scenario: Promote a stable learning
- **WHEN** a finding is evidence-backed, remains valid after repair and re-review, applies beyond one task, and changes future agent decisions
- **THEN** closure copies a concise generalized record into the Hardness capability knowledge and indexes it without copying transient logs, hashes, or incident chronology

#### Scenario: Retain one-off evidence locally
- **WHEN** an observation is specific to one failure, machine, snapshot, or temporary workaround
- **THEN** it remains in the change Review/implementation/data attachment and is not loaded as durable harness knowledge

### Requirement: Reusable PowerShell entry

Hardness SHALL support repeated Workspace and OpenSpec invocations in one Windows PowerShell 5.1 or PowerShell 7 session without polluting the caller environment. Every invocation SHALL return an independent run ID and the common result envelope.

#### Scenario: Reuse one PowerShell session
- **WHEN** Hardness invokes Workspace or OpenSpec commands repeatedly in one supported PowerShell session
- **THEN** modules remain reusable, the caller location is restored, and each invocation returns an independent run ID and result

### Requirement: Autonomous Goal execution within authority

Goal mode SHALL autonomously investigate, choose in-scope technical solutions, replan, implement, verify, and re-review without interrupting the user for ordinary technical choices or Review findings. It MUST stop when progress requires new authority, risks destructive user-data changes, requires merge/push/publication without authorization, lacks external credentials, or faces irreconcilable explicit instructions.

#### Scenario: Reviewer finds a required defect
- **WHEN** a Required finding can be resolved within the existing goal and authority
- **THEN** Hardness completes triage, repair, verification, and re-review without requesting an ordinary technical decision

### Requirement: Ready-to-integrate finish state

A successful Goal MUST reach committed, verified, reviewed, and ready-to-integrate while preserving its branch and worktree for inspection. Integration MAY occur only as a later explicitly authorized action.

#### Scenario: Finish a successful Goal
- **WHEN** all tasks, verification, and Review Gates are closed
- **THEN** the system reports commits, evidence, non-gating tests not run, and integration commands without automatically merging, pushing, or removing the worktree

#### Scenario: Integrate after explicit authorization
- **WHEN** the user explicitly requests integration after all gates pass
- **THEN** the coordinator first audits overlap with the primary checkout, preserves its unrelated dirty changes, and then applies only the reviewed commits without pushing
