---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "1.3": ["1.7"]
    "1.4": ["1.2"]
    "1.5": ["1.4"]
    "1.6": ["1.5"]
    "1.7": ["1.6"]
    "2.1": ["1.1"]
    "2.2": ["2.1"]
    "2.3": ["2.1"]
    "2.4": ["2.7"]
    "2.5": ["2.2"]
    "2.6": ["1.6", "2.2"]
    "2.7": ["1.7", "2.5", "2.6"]
    "3.1": ["1.3", "2.6"]
    "3.2": ["2.4", "3.1"]
    "4.1": ["3.2"]
    "4.2": ["4.1"]
---

## 1. OpenSpec foundation

- [x] 1.1 Establish the change, project workflow, and validation baseline — verify: `pwsh.exe -NoProfile -Command '& ./.agents/skills/openspec/bin/openspec.exe doctor --json; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }'`
  > Files: `openspec/project.yaml`, `openspec/config.yaml`, `openspec/workflows/angelscript/**`, `openspec/domains/hardness/domain.yaml`, `openspec/changes/hardness/refactor-skill-system/**`

  1. Migrate the already initialized manifest repository from the primary checkout by explicit path.
  2. Create the domain and change identity through the CLI.
  3. Write the proposal, delta spec, design, Task DAG, and attachment INDEX.
  4. Run doctor, workflow validation, and strict change validation.

- [x] 1.2 [TDD] Publish reproducible OpenSpec 0.7.1 — verify: `pwsh.exe -NoProfile -Command "Push-Location Tools/openspec; try { cargo test --locked --all-targets } finally { Pop-Location }"`
  > Files: `Tools/openspec/Cargo.toml`, `Tools/openspec/src/**`, `Tools/openspec/tests/**`, `Tools/openspec/docs/commands/**`, `Tools/openspec/CHANGELOG.md`, `Tools/openspec/README.md`

  1. Import the OpenSpec WIP already present in the primary checkout and establish the RED/GREEN baseline with existing tests.
  2. Unify TaskPlan/DAG parsing, instruction write paths, workflow optional/required behavior, and validation exit semantics.
  3. Implement archive closure schema and historical audit.
  4. Verify the English command/group documents against the recursive Clap tree.
  5. Preserve failed annotated `v0.7.0`, run fmt, Clippy, locked tests, and Release build, then commit and create annotated `v0.7.1`.

- [x] 1.3 Run the high-risk Review Gate against the fixed OpenSpec 0.8.1 snapshot — verify: `Review file status is closed with no open/deferred Critical or Required finding`
  > Files: `openspec/changes/hardness/refactor-skill-system/attachments/reviews/review-*-openspec-*.md`, `openspec/changes/hardness/refactor-skill-system/attachments/INDEX.md`

  1. Fix the `Tools/openspec` commit, annotated tag, Release EXE hash, language scan, and parent package diff.
  2. Have an independent reviewer inspect correctness, readability, architecture, security, performance, and verification.
  3. Triage and resolve every Critical/Required finding, append evidence, and request re-review.
  4. Close or supersede all OpenSpec release reviews and register them in INDEX.

- [x] 1.4 [TDD] Publish the English-only OpenSpec 0.7.2 snapshot — verify: `pwsh.exe -NoProfile -File .agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
  > Files: `Tools/openspec/**`, `.agents/skills/openspec/**`, `.agents/skills/openspec-*/**`, `openspec/**`

  1. Add a failing maintained-surface language scan whose only exception is a filename containing `_ZH`.
  2. Translate every other OpenSpec source document, Skill, workflow/template, manifest, spec, active record, and attachment to English.
  3. Preserve immutable `v0.7.1`; bump, test, commit, and create annotated `v0.7.2`.
  4. Transactionally republish the EXE, canonical command docs, and release manifest; pass package tests in PowerShell 5.1 and 7.

- [x] 1.5 [TDD] Repair and publish the reviewed OpenSpec 0.7.4 snapshot — verify: `pwsh.exe -NoProfile -File .agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
  > Files: `Tools/openspec/**`, `.agents/skills/README.md`, `.agents/skills/openspec/**`, `.agents/skills/openspec-*/**`, `openspec/**`

  1. Reproduce the 0.7.2 fixed-snapshot findings with failing repository-root, intermediate-path, workflow list/which, English-surface, Unicode, and publisher-root fixtures.
  2. Centralize physical containment and reparse rejection for every OpenSpec repository read/write path and make project workflow discovery propagate security errors.
  3. Enforce the complete maintained English surface and preflight/revalidate the Skill root, stage, backup, swap, rollback, and cleanup boundaries before mutation.
  4. Preserve immutable `v0.7.2` and containment-repaired but non-reproducible `v0.7.3`; publish annotated `v0.7.4` with deterministic MSVC linking, a byte-identical isolated rebuild gate, transactional republish, and package tests in PowerShell 5.1 and 7.

- [x] 1.6 [TDD] Publish OpenSpec 0.8.0 with the frontmatter Task Graph contract — verify: `pwsh.exe -NoProfile -File .agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
  > Files: `Tools/openspec/**`, `.agents/skills/openspec/**`, `.agents/skills/openspec-*/**`, `openspec/workflows/**`

  1. Add failing Rust contract tests for strict frontmatter boundaries, quoted IDs, exact node parity, cycles, mixed syntax, stable JSON, natural ordering, and early-archive failure safety.
  2. Implement the versioned `task_graph.depends_on` reader while retaining the legacy `After:` reader for historical records and rejecting any mixed current file.
  3. Switch embedded and project workflow templates to frontmatter without adding a second graph, status store, or archive migration.
  4. Preserve immutable `v0.7.4`; publish annotated deterministic `v0.8.0`, republish the Skill package transactionally, and pass Rust plus package tests in PowerShell 5.1 and 7.

- [x] 1.7 [TDD] Repair the reviewed Task Graph parser boundaries and publish OpenSpec 0.8.1 — verify: `pwsh.exe -NoProfile -File .agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
  > Files: `Tools/openspec/**`, `.agents/skills/openspec/**`, `openspec/changes/hardness/refactor-skill-system/attachments/reviews/review-*-openspec-*.md`

  1. Reproduce the fixed-snapshot UTF-8 BOM and explicit YAML `!!str` quoted-ID bypass findings with failing parser and CLI tests.
  2. Recognize one leading UTF-8 BOM without weakening the strict top-of-file boundary, and enforce lexical quoting for every Graph key and dependency ID.
  3. Reconcile archive-preflight architecture text with the deterministic closure/disposition checks already implemented by the CLI.
  4. Preserve immutable `v0.8.0`; commit and tag deterministic `v0.8.1`, transactionally republish the package, and pass Rust plus PowerShell 5.1/7 package tests.

## 2. Harness implementation

- [x] 2.1 [TDD] Implement lightweight Hardness routing and safe workspace lifecycle — verify: `pwsh -NoProfile -File .agents/skills/hardness/tests/Hardness.Tests.ps1`
  > Files: `.agents/skills/hardness/**`, `.agents/skills/git-workflow/**`, `.agents/skills/systematic-debugging/**`

  1. Write and observe failures for module import, result contract, static routes, and persistent-session behavior.
  2. Implement the four public Hardness functions with on-demand leaf loading.
  3. Implement safety behavior and tests for workspace status/new/bootstrap/verify/finish/remove.
  4. Compress Skill entry points into concise English progressive routes without a custom loop.

- [x] 2.2 [TDD] Establish Task DAG, Review, Implementation, and Replan protocols — verify: `pwsh -NoProfile -File .agents/skills/hardness/tests/Protocol.Tests.ps1`
  > Files: `.agents/skills/hardness/references/task-dag.md`, `.agents/skills/hardness/references/replan.md`, `.agents/skills/hardness/references/review.md`, `.agents/skills/hardness/references/closure.md`, `.agents/skills/code-review/**`, `openspec/changes/hardness/refactor-skill-system/attachments/knowledges/**`

  1. Verify DAG readiness/cycles, Review Gates, and Replan dispositions with behavior fixtures.
  2. Define applied-only Replans, compact diff snapshots, and optional patch-sidecar rules.
  3. Define fixed-snapshot review, finding/issue states, and archive closure gates.
  4. Remove duplicate requesting/receiving review Skills and duplicate language mirrors.
  5. Record dogfooding evidence flow and progressive harness-knowledge promotion without adding a runtime store.

- [x] 2.3 Prototype the unified UE leaf before the delivery scope split — verify: `git cat-file -e a5c22b287fff34e9af1bf07e1d28c73e97862a31`
  > Files: `openspec/changes/hardness/refactor-skill-system/attachments/reviews/review-20260902-harness-ue-final.md`, `openspec/changes/hardness/refactor-skill-system/attachments/implementation/deferred-unreal-engine-develop-wip.md`

  1. Preserve the completed historical UE prototype and its mixed fixed-snapshot review without rewriting earlier evidence.
  2. Record that the later project-wide refactor invalidated UE delivery as part of this change.
  3. Save the complete UE Skill, tests, public wrapper migration, and dependent guides in one named path-specific Git stash.
  4. Exclude that WIP from this delivery; a later dedicated change owns its recovery, design, implementation, and verification.

- [x] 2.4 Run the high-risk Review Gate for the Hardness/Workspace core — verify: `Review file status is closed with no open/deferred Critical or Required finding`
  > Files: `openspec/changes/hardness/refactor-skill-system/attachments/reviews/review-*-hardness-core-*.md`, `openspec/changes/hardness/refactor-skill-system/attachments/INDEX.md`

  1. Fix a snapshot of Hardness, Workspace, Task Graph routing, retained performance evidence, and protocol tests while excluding the deferred UE WIP.
  2. Independently inspect route ownership, authority boundaries, Task Graph selection, performance measurement/retention, and workspace safety.
  3. Resolve and verify every Critical/Required finding, then obtain independent confirmation of the evidence.
  4. Close the core review, supersede the mixed review for this delivery only, and register both dispositions in INDEX.

- [x] 2.5 [TDD] Decouple the Hardness core from the deferred Unreal leaf — verify: `pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Quick -PowerShellHosts Both`
  > Files: `.agents/skills/hardness/**`, `.agents/skills/git-workflow/**`, `openspec/changes/hardness/refactor-skill-system/attachments/implementation/deferred-unreal-engine-develop-wip.md`, `openspec/changes/hardness/refactor-skill-system/attachments/replans/replan-20260903-005449-defer-unreal-leaf-and-limit-binary-history.md`

  1. Keep native Goal/Current Workspace and OpenSpec routes bound to the selected workspace and preserve the caller location.
  2. Remove every unfinished UE route and UE required-leaf health claim from the current Hardness snapshot.
  3. Preserve the complete UE prototype in the named recoverable stash and restore all affected delivery paths to their pre-change baseline.
  4. Scope Workspace completion to Git facts and leave integration authority with Hardness/OpenSpec closure.
  5. Pass the Hardness, Protocol, Workspace, and OpenSpec package matrix in PowerShell 5.1 and 7 without invoking UE.

- [x] 2.6 [TDD] Make Hardness recognize and schedule frontmatter Task Graphs — verify: `pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Quick -PowerShellHosts Both`
  > Files: `.agents/skills/hardness/**`, `.agents/skills/openspec-apply-change/SKILL.md`, `.agents/skills/openspec/references/tasks.md`, `openspec/changes/hardness/refactor-skill-system/**`

  1. Add failing Hardness behavior tests for the task route, Goal/Current workspace selection, Ready/Blocked output, invalid-graph failure, and natural numeric task presentation.
  2. Add the smallest static Hardness task route over the deterministic OpenSpec primitive; keep scheduling, Review, and Replan policy in Hardness without duplicating a YAML parser or runtime store.
  3. Update concise Skill references and migrate the active `tasks.md` to one frontmatter Graph, removing every current `After:` line.
  4. Sort Graph keys and Markdown task blocks by natural stable ID while proving that dependencies and Ready nodes remain semantically unchanged.
  5. Pass Hardness/Protocol tests in PowerShell 5.1 and 7 plus strict OpenSpec validation.

- [x] 2.7 [TDD] Add retained Hardness performance evidence — verify: `pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Performance -PowerShellHosts Both -WarmupRuns 3 -MeasurementRuns 15`
  > Files: `.agents/skills/hardness/scripts/Test-Hardness.ps1`, `.agents/skills/hardness/tests/Hardness.Performance.Tests.ps1`, `.agents/skills/hardness/tests/Test-Hardness.Tests.ps1`, `.agents/skills/hardness/SKILL.md`, `openspec/changes/hardness/refactor-skill-system/attachments/data/**`, `openspec/changes/hardness/refactor-skill-system/attachments/INDEX.md`

  1. Add failing two-host contracts for the Performance profile, sample correctness, unique run directories, atomic JSON/CSV artifacts, stable schemas, and non-overwriting retention.
  2. Measure fresh import/API, persistent route/context batches, and real `task.status` with warmups and per-host min/median/p95/max while validating every result.
  3. Apply only broad catastrophe budgets as hard gates; record prior-baseline regression ratios as warnings until representative history supports a portable threshold.
  4. Retain raw artifacts under the ignored Saved tree, create one privacy-trimmed aggregate baseline with source hashes under attachments/data, register it in INDEX, and prove final Integration includes the Performance profile.

## 3. Skill and package integration

- [x] 3.1 Publish OpenSpec lifecycle Skills, command docs, and EXE manifest — verify: `pwsh.exe -NoProfile -File .agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
  > Files: `.agents/skills/openspec/**`, `.agents/skills/openspec-*/**`, `.gitignore`, `openspec/README.md`, `openspec/workflows/**`

  1. Add `openspec-update-change` and `openspec-verify-change` and narrow the other lifecycle Skills.
  2. Move schema guidance into `openspec/references/` and remove the registered `openspec-schema` Skill.
  3. Bundle the 0.8.1 Release EXE and canonical command docs and generate the release manifest.
  4. Verify version, hashes, docs digest, annotated tag, release gates, lifecycle links, English-only policy, and all related Skills.

- [x] 3.2 Integrate core project entry points and batch commit boundaries — verify: `git diff --check`
  > Files: `.agents/skills/README.md`, `AGENTS.md`, `AGENTS_ZH.md`, `Documents/Guides/SubmoduleWorktreeWorkflow.md`, `openspec/changes/hardness/refactor-skill-system/**`

  1. Update the project entry points for Hardness, Goal/Current Workspace, OpenSpec, Task DAG, Review, and Replan without advertising the deferred UE leaf.
  2. Document submodule commit order, explicit integration authority, the UE scope split, and the single-final-EXE parent-history rule.
  3. Review staged diffs and commit by submodule, Hardness/workspace, protocols, OpenSpec package, and documentation/records ownership.

## 4. Verification and closure

- [ ] 4.1 Run layered validation and independent final Review — verify: `pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Integration`
  > Files: `Saved/Harness/Hardness/**`, `openspec/changes/hardness/refactor-skill-system/attachments/reviews/**`, `openspec/changes/hardness/refactor-skill-system/attachments/implementation/**`, `openspec/changes/hardness/refactor-skill-system/attachments/INDEX.md`

  1. Run the Hardness/Protocol/Workspace/OpenSpec two-host matrix, retained Performance profile, package checks, and strict change validation.
  2. Reuse the already fixed and independently approved OpenSpec 0.8.1 source/package evidence instead of recommitting or republishing candidate binaries.
  3. Explicitly record that no UE implementation or validation belongs to this scope; Editor, Automation, Smoke, Standalone, complete All, and StaticJIT All are not run.
  4. Have an independent reviewer inspect the core fixed snapshot across all dimensions, resolve every Critical/Required finding, and close the re-review.

- [ ] 4.2 Synchronize durable specs and prepare the completed closure — verify: `pwsh.exe -NoProfile -Command '$ErrorActionPreference = "Stop"; Import-Module ./.agents/skills/hardness/scripts/Hardness.psd1; $context = New-HardnessContext -Mode Current; $result = Invoke-Hardness -Command openspec.validate -Context $context -ArgumentList @("hardness/refactor-skill-system","--strict","--json"); if ($result.status -ne "Succeeded") { throw $result.error.message }'`
  > Files: `openspec/specs/hardness/core/**`, `openspec/changes/hardness/refactor-skill-system/**`

  1. Merge the delta spec idempotently into the current spec and record sync evidence.
  2. Confirm every task, review, implementation issue, knowledge decision, and closure condition is closed.
  3. Validate the active completed record, mark this final DAG node complete, and create completed closure metadata.
  4. After all tasks are complete, archive and audit the record; then audit primary-checkout overlap and integrate the reviewed commits as explicitly requested, without push or worktree removal.
