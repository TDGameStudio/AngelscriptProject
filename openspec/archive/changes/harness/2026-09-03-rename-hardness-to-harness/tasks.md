---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
    "2.2": ["2.1"]
    "3.1": ["2.2"]
    "3.2": ["3.1"]
---

## 1. Establish the cutover boundary

- [x] 1.1 Add hard-cutover and persisted-migration RED coverage, record the old-name allowlist, and isolate unrelated README work — verify: `renamed fresh-process import/absence, AgentConfig migration, environment cleanup, PlanOnly registry immutability, real registry migration/conflict, and live-name audit fixtures fail only on the unrenamed implementation`
  > Files: `.agents/skills/hardness/tests/**`, `.agents/skills/workspace-lifecycle/tests/**`, `.agents/skills/git-operations/tests/**`, `.agents/skills/unreal-engine-develop/tests/**`, `.agents/skills/openspec/tests/**`, `README.md`, exact temporary Git stash containing only the pre-existing README patch

  1. Preserve the exact pre-existing README patch separately so the rename can commit only its own README hunks.
  2. Add positive Harness import/route/schema tests and negative tests proving old public imports, symbols, routes, and environment selection are absent.
  3. Add workspace bootstrap migration and Unreal registry PlanOnly/real/conflict fixtures before changing implementation.
  4. Define an explicit audit allowlist limited to immutable archives, pinned source/history, Documents/Reference, legacy-read constants, and negative fixtures.

- [x] 1.2 Move the live OpenSpec namespace through the portable CLI and verify aliases/archives — verify: `openspec domain show harness --json; openspec spec list --json; openspec change show harness/rename-hardness-to-harness --json; old hardness IDs resolve only as aliases; git diff -- openspec/archive/changes/hardness shows no historical rewrites`
  > Files: `openspec/domains/hardness/**`, `openspec/domains/harness/**`, `openspec/specs/hardness/**`, `openspec/specs/harness/**`, `openspec/changes/hardness/rename-hardness-to-harness/**`, `openspec/changes/harness/rename-hardness-to-harness/**`

  1. Invoke `openspec domain move hardness --to harness` through the existing framework route.
  2. Confirm canonical IDs, retained aliases, cascaded current specs/active Change, and unchanged immutable archives.

## 2. Rename the maintained framework and migrate persisted state

- [x] 2.1 Rename the complete live module/API/route/schema/documentation surface to Harness with no public aliases — verify: `fresh pwsh imports .agents/skills/harness/scripts/Harness.psd1; Get-Command and Get-HarnessCommand expose Harness only; core, Git, workspace, OpenSpec, Unreal, hook, and helper fixture tests pass`
  > Files: `.agents/skills/hardness/**`, `.agents/skills/harness/**`, `.agents/skills/workspace-lifecycle/**`, `.agents/skills/git-operations/**`, `.agents/skills/unreal-engine-develop/**`, `.agents/skills/openspec*/**`, `.codex/hooks/**`, `.agents/skills/README.md`, `AGENTS.md`, `openspec/config.yaml`, `openspec/README.md`, `README.md`, `Tools/Shared/UnrealCommandUtils.ps1`, `Tools/Diagnostics/powershell/ResolveAgentCommandTemplates.ps1`

  1. Rename directories/files, PowerShell symbols/types, three framework routes, environment/schema/state identifiers, hooks, tests, references, and maintained live prose.
  2. Advance breaking PowerShell module manifests to `3.0.0` without changing GUIDs.
  3. Update only the two retained root helpers that directly call shared renamed symbols; do not expand into root Tools cleanup.
  4. Retain old-name text only where an explicit migration/history-read or negative-test fixture requires it.

- [x] 2.2 Implement and verify bounded AgentConfig, Saved evidence, evaluation, and Unreal registry compatibility — verify: `pwsh.exe -NoLogo -NoProfile -File .agents/skills/harness/scripts/Test-Harness.ps1 -Profile Quick`
  > Files: `.agents/skills/workspace-lifecycle/scripts/**`, `.agents/skills/workspace-lifecycle/tests/**`, `.agents/skills/harness/scripts/**`, `.agents/skills/harness/tests/**`, `.agents/skills/unreal-engine-develop/scripts/**`, `.agents/skills/unreal-engine-develop/tests/**`, `AgentConfig.ini`, `%LOCALAPPDATA%/TDGameStudio/{Hardness,Harness}/Unreal/DriveAssignments.json`

  1. Make bootstrap the only `[Hardness]` v2 to `[Harness]` v3 writer and make ordinary reads reject legacy-only configuration.
  2. Set `HARNESS_*` and remove inherited `HARDNESS_*` during process activation.
  3. Write only new Harness Saved/evaluation schemas while retaining read-only access to historical Hardness evidence.
  4. Keep Unreal `PlanOnly` side-effect free; migrate a lone old registry under lock on a real operation and fail closed on conflicting dual registries.
  5. Bootstrap the actual ignored workspace configuration after fixtures prove migration.

## 3. Verify, synchronize, and close in the same round

- [x] 3.1 Synchronize Harness specs, run complete static/fixture/real-UE acceptance, and create terminal evolution evidence — verify: `isolated tests plus Quick and Integration pass; one real AngelscriptSmoke run succeeds; old-name audit matches only the explicit allowlist; openspec doctor and strict specs/all/archived validation pass; harness.evolution.status reports ClosureReady=true`
  > Files: `openspec/specs/harness/**`, `openspec/changes/harness/rename-hardness-to-harness/attachments/**`, exact maintained live rename paths and verification outputs

  1. Merge the four verified delta requirements into current Harness specs without overwriting unrelated requirements.
  2. Run isolated module suites, Quick, Integration, OpenSpec doctor/strict validation, and the explicit old-name audit.
  3. Run one real `AngelscriptSmoke` suite through Harness without starting a build.
  4. Record `harness-workflow-evaluation-v1`, exact verification/provenance, no deferred owners, and terminal evolution status.

- [x] 3.2 Archive the completed Change, run post-move gates, create one exact parent commit, and restore unrelated README work — verify: `strict archived validation and smallest post-move Harness gate pass; commit paths/message/head are exact; pre-existing README patch and every other unrelated workspace change remain outside the commit; no push occurs`
  > Files: `openspec/changes/harness/rename-hardness-to-harness/**`, `openspec/archive/changes/harness/**`, all exact Change-owned parent paths, temporary README stash

  1. Archive with completed closure only after every task and terminal gate passes.
  2. Run strict archived validation plus the smallest archive-stable Harness gate.
  3. Commit exact owned paths as `[Harness] Refactor: rename Hardness framework to Harness` without push.
  4. Reapply and drop only the temporary README stash, verify its pre-existing additions remain uncommitted, and audit final workspace/submodule state.
