---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
---

## 1. Align and guard the baseline

- [x] 1.1 Select the integrated AngelScript main tip and prove it builds — verify: `Plugins/Angelscript HEAD and refs/heads/main equal 5472045b6408e0144ece63b4c05e67056a3d2907; Harness UE run d50aef11af7c4c589cccd7c1403c42b6 is Succeeded with 206/206 UBT actions`
  > Files: `Plugins/Angelscript` gitlink, `Saved/Harness/Unreal/Runs/d50aef11af7c4c589cccd7c1403c42b6/**` (ignored evidence)

  1. Fetch the plugin `origin/main` explicitly and compare the current gitlink, local main, and remote-tracking commit graph.
  2. Select the clean descendant local `main` containing the complete CanonicalAST integration.
  3. Run the real UE 5.8 Editor Development build through Harness and retain the exact run evidence.

- [x] 1.2 Add a fail-closed primary-main baseline guard through TDD — verify: `pwsh -NoLogo -NoProfile -File .agents/skills/workspace-lifecycle/tests/WorkspaceLifecycle.Tests.ps1`
  > Files: `.agents/skills/workspace-lifecycle/scripts/WorkspaceLifecycle.psm1`, `.agents/skills/workspace-lifecycle/tests/WorkspaceLifecycle.Tests.ps1`, `.agents/skills/workspace-lifecycle/references/agent-config.md`

  1. Add fixture coverage for aligned local-main, detached-at-tip, stale HEAD, remote-ahead, missing refs, and non-main exemption; observe failure because no baseline status/guard exists.
  2. Implement the smallest deterministic Git-ref comparison in detailed status and workspace-sensitive execution.
  3. Keep fast status network-free and free of recursive submodule inspection, then rerun workspace and Harness fixture gates.

## 2. Synchronize and close

- [x] 2.1 Sync the durable workspace contract, rerun the guarded build, archive, and commit exact paths — verify: `Harness Quick and Integration pass; an incremental guarded ue.build succeeds; strict all and archived validation pass; exact submodule-first and parent commits contain no unrelated changes`
  > Files: `openspec/specs/harness/workspace/spec.md`, `openspec/changes/harness/enforce-angelscript-main-baseline/**`, `Plugins/Angelscript` gitlink, exact Harness workspace files

  1. Merge the verified delta requirement into the current workspace specification.
  2. Run Quick, Integration, strict OpenSpec validation, and one incremental build through the new execution guard.
  3. Record terminal workflow evidence, archive the completed Change, commit exact submodule/parent scopes, and do not push.
