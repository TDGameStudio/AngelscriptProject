## Context

The repository already has a usable OpenSpec manifest model and multiple project Skills, but control responsibilities overlap. Legacy Hardness depends on an external loop; OpenSpec Skills combine primitives, policy, and schema; and Review findings can be mistaken for Replan events. The primary checkout and its Unreal runner surface are undergoing a large refactor, so this change must isolate the stable Hardness core and preserve parent-repository and submodule ownership boundaries.

## Goals / Non-Goals

**Goals:**

- Build a progressively disclosed Skill system from short entry points and on-demand leaves/references.
- Let Goal mode investigate, replan, implement, verify, and re-review autonomously while preserving real authority boundaries.
- Keep the current Task DAG and historical evidence in Markdown instead of creating a second execution database.
- Make PowerShell commands repeatable in one 5.1 or 7 session with stable structured results.
- Make the portable OpenSpec executable, source commit, command documentation, and release manifest reproducible and traceable.
- Keep all maintained OpenSpec material in English, except explicitly named `*_ZH` localization files retained temporarily at the user's request.

**Non-Goals:**

- No daemon, Event Store, execution database, generic asynchronous runtime, or custom Goal loop.
- No automatic merge, push, publication of the parent repository, or worktree removal; no plugin feature refactor.
- No reading or migration of the old `Tools` loop/RalphLoop content.
- No `unreal-engine-develop` implementation, UE route publication, or public `Tools/Run*.ps1` compatibility migration; those require a separate change after the project refactor stabilizes.
- No StaticJIT All or complete All-suite execution as an acceptance requirement for this change.

## Decisions

### 1. Hardness is only a static router

`Hardness.psm1` exports `New-HardnessContext`, `Get-HardnessCommand`, `Invoke-Hardness`, and `Test-HardnessInstallation`. The route table is static and a leaf module loads only when selected. A `task.*` route makes Task Graph recognition a Hardness entry while delegating deterministic Markdown/YAML parsing to the portable OpenSpec primitive. The common result contains only `schemaVersion`, `command`, `runId`, `status`, `exitCode`, `durationMs`, `artifacts`, `data`, and `error`. This snapshot registers only the validated Workspace, OpenSpec, and Task Graph leaves.

### 2. Native Goal and Current modes are distinct

Goal mode creates `.worktrees/<change>` and initializes the exact parent-recorded gitlinks. If a remote object is unavailable, fallback is allowed only from a verified local submodule object store. Current mode remains in the current workspace. Neither mode automatically merges, pushes, or removes the workspace. `AgentConfig.ini` is copied only after its ignored status is proven.

### 3. `tasks.md` is the only current DAG

The file begins with a strict `task_graph.version: 1` YAML frontmatter whose `depends_on` map is the only current dependency source. Every quoted `X.Y` key names one top-level Markdown checkbox, roots use `[]`, and the Graph key set must equal the checkbox ID set. Checkbox state, description, `Files:`, exact verification, and ordered execution steps remain in the Markdown body. Hardness enters through `task.*`; OpenSpec normalizes the Graph to the stable `TaskNode.after/ready` JSON contract. New/current records use frontmatter, while old `After:`-only records remain readable and Graph/After mixing is invalid.

Task blocks and Graph keys use natural numeric ID presentation order (`1.9` before `1.10`). Presentation order never creates an edge; Ready/Blocked derives only from `depends_on`, while parallel work additionally requires disjoint files, artifacts, and resource leases. Task IDs are never reused or renumbered, and completed tasks are never unchecked.

### 4. Replan records semantic change instead of copying Git

Create `attachments/replans/replan-YYYYMMDD-HHmmss-<theme>.md` only when a requirement, design, acceptance condition, task boundary, DAG edge, or prior evidence becomes false. Record the base commit, before/after task hashes, path status, diff stat, Task/DAG/artifact semantics, dispositions, and preserved work. The record remains `status: applied` and immutable after application. A small patch sidecar is allowed only for uncommitted text that Git cannot recover.

### 5. Review can lead to Replan only after triage

Review files use `open|closed|superseded`; findings use `open|resolved|rejected|deferred`. Severity gates completion but never directly decides Replan. A material non-obvious issue flows through an implementation issue, an optional talk, current design/spec, Replan, and tasks as needed. An external reviewer writes only its assigned review against a fixed snapshot and cannot edit code, tasks, design, INDEX, implementation records, replans, or earlier reviews.

### 6. OpenSpec remains a deterministic primitive

The Rust CLI owns object identity, workflow/status/instructions, validation, closure metadata, and a pure archive move. It does not make AI decisions, merge specs, update Skills, or schedule workspaces. Hardness and lifecycle Skills own close policy, spec synchronization, Review Gates, and autonomous Replan. Glob instructions distinguish the pattern, existing concrete paths, and a writable path.

### 7. Unreal command routing is deferred as one whole leaf

The current repository-wide refactor makes the UE runner and compatibility surface unstable. Hardness therefore does not publish placeholder `ue.*`, execution, JIT, Coverage, Standalone, engine, or toolchain routes in this snapshot, and installation health does not claim that an unreviewed UE leaf is available. Existing prototype work is preserved recoverably outside the delivery. A later dedicated change must own the complete `unreal-engine-develop` module, public wrapper transition, behavior tests, and route registration together.

### 8. Commits follow ownership and review boundaries

Annotated `v0.7.0` remains the immutable failed first review candidate. Annotated `v0.7.1` remains the technically validated release that predates the confirmed English-only requirement. Annotated `v0.7.2` remains the snapshot whose independent review exposed incomplete physical-root and publisher containment. Annotated `v0.7.3` preserves the functional containment repair, but its independent-target rebuild exposed varying MSVC PE timestamps and PDB GUIDs. Annotated `v0.7.4` preserves deterministic MSVC linking, complete containment, and a publisher-enforced byte-identical isolated rebuild. Annotated `v0.8.0` preserves the first Task Graph input contract and its review evidence; `v0.8.1` repairs BOM-safe frontmatter recognition, enforces source-level quoted IDs, and reconciles archive-preflight documentation. No prior tag moves. The parent records only the final 0.8.1 Release EXE once; candidate EXEs never receive separate parent commits. Parent commits are separated into Hardness/workspace, Task DAG/Review, OpenSpec Skills/package, and documentation/records. Every staged diff is reviewed before commit.

### 9. The project workflow and strict requirements profile are separate

The project `angelscript` workflow is a lightweight record flow using `record-v1`: required artifacts must exist and the Task DAG must be valid, but an unrelated current spec is not forced into Requirement/Scenario form. `requirements-v1` remains a fully tested explicit strict profile for workflows that intentionally use delta requirements.

### 10. Maintained OpenSpec material is English

English is required for the portable source documentation, distributed Skills and command references, project README/config/workflows/templates, manifests, current specs, active changes, attachments, and newly created archive records. The package test scans paths and supported text files for Han characters. A filename containing `_ZH` is the sole temporary exception explicitly requested by the user; the exception does not apply to ordinary files or directories.

### 11. Integration remains explicit

The successful Goal state is committed, verified, reviewed, and ready to integrate. Merge into the primary branch is a separate action and occurs only after an explicit user request plus a read-only overlap audit of the dirty primary checkout. This change has received that explicit request, but integration still waits for all planned gates and commits.

### 12. Hardness performance evidence is retained but machine-aware

`Test-Hardness.ps1 -Profile Performance` is the single public benchmark entry. A private test implementation measures fresh-process import/API cost, persistent-session route/context batches, and the real `task.status` path independently in Windows PowerShell 5.1 and PowerShell 7. Each timed sample must also satisfy the behavior contract. Quick remains a functional gate; final Integration includes Quick and Performance.

Every run writes unique `Summary.json` and `Samples.csv` artifacts below `Saved/Harness/Hardness/Performance/<RunId>/` and never overwrites or automatically removes earlier runs. Raw samples and machine-specific paths remain ignored local evidence. One accepted aggregate baseline is copied into `attachments/data/` without machine/user names, absolute paths, or per-sample arrays; it records environment class, min/median/p95/max, broad catastrophe budgets, the relative Saved path, and source artifact hashes. Initial absolute budgets catch hangs or order-of-magnitude regressions; comparison with one prior machine-specific baseline is advisory until representative history justifies a hard regression ratio.

## Risks / Trade-offs

- PowerShell 5.1 and 7 differ in process, JSON, and module behavior; both hosts receive AST/import and behavior coverage.
- Deferring the Unreal leaf means this Hardness snapshot cannot dispatch UE work; the missing surface is explicit rather than represented by routes that may fail at runtime.
- A Markdown DAG has no database lock; the coordinator checks file, artifact, and lease intersections before parallel dispatch.
- OpenSpec validation and closure changes affect history; explicit legacy provenance protects known records while current closure remains strict.
- Dual-read/single-write Task Graph migration retains old `After:` archives but increases parser surface; mixed syntax and malformed frontmatter fail closed.
- Wall-clock harness samples vary by machine and process startup state; host-local statistics and broad catastrophe caps are hard evidence while single-baseline deltas remain warnings.
- Translating prior applied records weakens byte-level immutability once, but the user-directed migration preserves all semantic identity and evidence and is itself recorded by Replan.
- No UE implementation is delivered by this change, so UE build, Editor, Automation, Smoke, Standalone, complete All, and StaticJIT All are outside its verification scope rather than unrun acceptance gates.
