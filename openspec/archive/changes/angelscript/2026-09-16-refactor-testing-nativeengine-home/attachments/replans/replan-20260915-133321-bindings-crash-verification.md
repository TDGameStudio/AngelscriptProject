---
replan_id: replan-20260915-133321-bindings-crash-verification
status: applied
source: verification
source_ref: ue.test Angelscript.UnitTest.RuntimeBindings run 69679c5984aa4296bf971ac1d3bcf749; pre-move run 47d5bd5dd8024815bad75d26eb932ff9
scope: 2.3/2.6/4.1 proving commands cannot require a green full Bindings or Angelscript.UnitTest run
base_commit: acb127e8539638b0a2ff6392b894d976a81b5bdb
base_tasks_sha256: 58ffeb54905f6853df84b5098c3be932ee0e19fd9ec7e099dc969ab6a9c6b098
result_tasks_sha256: a69b32119efd25cae779cba5823de233d68663921cef3737a9f295fc3fbda95d
created_at: 2026-09-15T13:33:21+08:00
resume_task: 2.3
---

## Trigger and Evidence

Post-move `ue.test` `Angelscript.UnitTest.RuntimeBindings` (run `69679c5984aa4296bf971ac1d3bcf749`) discovered 312 identities, then native-exited 3 with no `index.json`. The crash is `EXCEPTION_ACCESS_VIOLATION` reading `0x4` in `asCModuleDefinitionSet::Create` via `FAngelscriptTypeBindInfoDraft::MaterializeTemplateDeclaration`, started by `Angelscript.UnitTest.RuntimeBindings.Containers.Array.Array.AppendRemoveAndIterationYieldTwoThenFive` (`Bindings/RuntimeBindingArrayTests.cpp:125`). The same identity, stack, and missing report occurred on the pre-move run `47d5bd5dd8024815bad75d26eb932ff9`. This Change forbids production frontend/VM repair; the AV is in runtime type-bind materialization.

NativeEngine (1206), Framework (45), Baseline (3), and Bindings isolation (2) prefixes succeeded after relocation. RuntimeBindings Found-list reconciliation against the frozen map passed (312/312).

## Decision

Keep the four-tenant homes and identity-conservation requirement. Replace proving commands that demanded a successful RuntimeBindings or whole `Angelscript.UnitTest` report with identity reconciliation against retained reports. Record the Array crash as a pre-existing product defect, not a relocation loss. Do not drop the RuntimeBindings axis or guess product semantics.

## Impact

- 2.3 proving command becomes RuntimeBindings identity comparison on the post-move Found-list report.
- 2.6 proving command becomes the phase-1 conservation script (NewVersion absent + five tenant maps).
- 4.1 proving command becomes the NativeEngine prefix (matrix plus relocated homes). Full `Angelscript.UnitTest` success remains blocked until the bind-materialization defect is owned elsewhere.
- Design/approval of homes and nested names is unchanged.

## Old Task Disposition

2.1, 2.2, and 2.4 keep their tenant `ue.test` commands. 2.3, 2.6, and 4.1 IDs stay; only their Verification fences and Notes change. Completed 1.1/1.2 stay checked. No node is removed or unchecked.

## Diff Snapshot

Affected status: dirty `AGENTS.md`, angelscript-test Skill, relocated `AngelscriptTest` tenants; untracked Change `tasks.md`.
Task ~: 2.3, 2.6, 4.1 Verification/Notes. Task +/-: none.
Edge +/-: none.
Artifact +: `data/post-move-runtimebindings-identities.json`, `scripts/Test-Phase1MigrationConservation.ps1`, this record. Artifact ~: INDEX.md, tasks.md.

## Preserved Work

Relocation, include rewrites, BuilderStages collision-rename, NativeEngine/Framework/Baseline/Bindings-isolation green runs, and the 1.1 comparator remain valid. Parser stays empty until 3.1.

## References and Result

Resume 2.3 with the identity-conservation proving command. Do not retry a green `Angelscript.UnitTest` or RuntimeBindings run as a completion gate in this Change.