---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": ["1.1"]
    "2.2": ["2.1"]
    "2.3": ["2.2"]
    "3.1": ["2.1"]
    "3.2": ["3.1"]
    "3.3": ["3.2"]
    "4.1": ["2.3", "3.3"]
    "4.2": ["4.1"]
    "4.3": ["4.2"]
    "5.1": ["4.3"]
    "5.2": ["5.1"]
    "5.3": ["5.2"]
---

## 1. Register the change

- [x] 1.1 Create the decision-complete Change and delta specifications — verify: `openspec.exe validate hardness/refactor-workspace-git-operations --type change --strict --json reports one valid change`
  > Files: `openspec/changes/hardness/refactor-workspace-git-operations/**`

## 2. Establish workspace lifecycle ownership

- [x] 2.1 Replace the ambiguous Git/worktree package with `workspace-lifecycle` while preserving all worktree safety invariants — verify: `WorkspaceLifecycle.psm1 parses and its manifest exports only lifecycle/configuration functions`
  > Files: `.agents/skills/git-workflow/**`, `.agents/skills/workspace-lifecycle/**`

- [x] 2.2 Make `AgentConfig.ini` a managed per-workspace local contract with controlled status/get/set/projection — verify: `configuration fixtures cover projection, repair, reserved fields, atomic edits, and missing primary configuration`
  > Files: `.agents/skills/workspace-lifecycle/scripts/WorkspaceLifecycle.psm1`, `.agents/skills/workspace-lifecycle/references/agent-config.md`, `.agents/skills/workspace-lifecycle/tests/WorkspaceLifecycle.Tests.ps1`

- [x] 2.3 Enforce selected-workspace identity before build/test/commandlet startup without restricting diagnostics — verify: `shared configuration fixtures reject cross-worktree execution and accept matching Goal/Current execution without launching UE`
  > Files: `.agents/skills/workspace-lifecycle/scripts/WorkspaceLifecycle.psm1`, `Tools/Shared/UnrealCommandUtils.ps1`, `.agents/skills/unreal-engine-develop/scripts/Shared/UnrealCommandUtils.ps1`

## 3. Establish Git operation ownership

- [x] 3.1 Add structured Git status and exact scoped multi-repository commit closure — verify: `GitOperations.Tests.ps1 proves Current scope isolation and Goal submodule-first commits`
  > Files: `.agents/skills/git-operations/**`

- [x] 3.2 Add explicit merge-based local integration with preview, dirty-overlap protection, and resumable submodule-first ordering — verify: `GitOperations.Tests.ps1 covers divergent merge, mismatch, conflict abort, disjoint dirtiness, and no remote/destructive side effects`
  > Files: `.agents/skills/git-operations/scripts/GitOperations.psm1`, `.agents/skills/git-operations/references/integration.md`, `.agents/skills/git-operations/tests/GitOperations.Tests.ps1`

- [x] 3.3 Add explicit non-force push while keeping worktree cleanup separate and user-triggered — verify: `GitOperations.Tests.ps1 proves preview is non-mutating, submodules precede the parent, missing gitlink publication is rejected, and the public route exposes no force option`
  > Files: `.agents/skills/git-operations/scripts/GitOperations.psm1`, `.agents/skills/git-operations/references/integration.md`, `.agents/skills/git-operations/tests/GitOperations.Tests.ps1`, `.agents/skills/workspace-lifecycle/references/worktrees.md`

## 4. Route and verify the refactor

- [x] 4.1 Rewire Hardness and every live non-historical reference, then remove `workspace.finish` and the old package — verify: `a live-tree scan excluding archives and Documents finds no git-workflow, using-git-worktrees, or workspace.finish reference`
  > Files: `.agents/skills/hardness/**`, `.agents/skills/README.md`, `.agents/skills/unreal-engine-develop/SKILL.md`, `AGENTS.md`, `AGENTS_ZH.md`, `README.md`, `Tools/**`

- [x] 4.2 Run the focused PowerShell 7 lifecycle, Git, Hardness, Protocol, and OpenSpec Skill tests — verify: `pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Quick reports 6 passed and 0 failed`
  > Files: `.agents/skills/workspace-lifecycle/tests/**`, `.agents/skills/git-operations/tests/**`, `.agents/skills/hardness/tests/**`, `.agents/skills/hardness/scripts/Test-Hardness.ps1`

- [x] 4.3 Measure the new read-only Hardness routes and retain accepted performance evidence — verify: `the PS7 Performance profile passes and its privacy-trimmed aggregate plus raw hashes are indexed under attachments/data`
  > Files: `.agents/skills/hardness/tests/Hardness.Performance.Tests.ps1`, `openspec/changes/hardness/refactor-workspace-git-operations/attachments/data/**`, `openspec/changes/hardness/refactor-workspace-git-operations/attachments/INDEX.md`

## 5. Synchronize and close

- [x] 5.1 Synchronize `hardness/core`, `hardness/workspace`, and `hardness/git` with capability knowledge — verify: `strict all-spec validation succeeds and capability knowledge indexes resolve every promoted record`
  > Files: `openspec/specs/hardness/**`, `openspec/changes/hardness/refactor-workspace-git-operations/specs/**`

- [x] 5.2 Complete one scope-frozen broad-impact Final Review after every semantic deliverable — verify: `one closed approving review-v2 record binds the final snapshot and has no open Critical or Required finding`
  > Files: `openspec/changes/hardness/refactor-workspace-git-operations/attachments/reviews/**`, `openspec/changes/hardness/refactor-workspace-git-operations/attachments/INDEX.md`

- [x] 5.3 Validate closure readiness and archive without changing remote state — verify: `strict active validation, doctor, archived validation, and the smallest archive-stable Hardness gate all pass; no push occurred`
  > Files: `openspec/changes/hardness/refactor-workspace-git-operations/**`, `openspec/archive/changes/hardness/**`
