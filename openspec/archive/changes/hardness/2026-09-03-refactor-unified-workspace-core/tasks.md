---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "1.3": ["1.1"]
    "2.1": ["1.2", "1.3"]
    "3.1": ["2.1"]
    "3.2": ["3.1"]
    "3.3": ["3.2"]
    "4.1": ["3.3"]
---

## 1. Unified workspace implementation

- [x] 1.1 Replace repository modes with Git-derived workspace lifecycle — verify: `pwsh.exe -NoProfile -Command "& '.agents/skills/workspace-lifecycle/tests/WorkspaceLifecycle.Tests.ps1'; & '.agents/skills/workspace-lifecycle/tests/WorkspaceLifecycle.Safety.Tests.ps1'"`
  > Files: `.agents/skills/workspace-lifecycle/scripts/WorkspaceLifecycle.psm1`, `.agents/skills/workspace-lifecycle/scripts/WorkspaceLifecycle.psd1`, `.agents/skills/workspace-lifecycle/tests/WorkspaceLifecycle.Tests.ps1`, `.agents/skills/workspace-lifecycle/tests/WorkspaceLifecycle.Safety.Tests.ps1`, `.agents/skills/workspace-lifecycle/SKILL.md`, `.agents/skills/workspace-lifecycle/references/agent-config.md`, `.agents/skills/workspace-lifecycle/references/worktrees.md`

  Context: This node establishes the interface consumed by both Hardness and Git operations.

  1. Write failing fixtures for heterogeneous registered worktrees, HarnessRoot versus WorkspaceRoot, fast/detailed status, list, cache refresh, Branch=Name creation, process-local selection, and AgentConfig v1-to-v2 migration.
  2. Remove Mode/GoalName APIs and environment state; implement the exact context fields and preserve existing gitlink, ignored-data, path-safety, and explicit-removal guards.
  3. Make bootstrap preserve user fields, rebind ProjectFile, and remove only the obsolete configured Hazelight path.

- [x] 1.2 Refactor Git operations around exact workspace roots and reviewed source HEADs — verify: `pwsh.exe -NoProfile -File .agents/skills/git-operations/tests/GitOperations.Tests.ps1`
  > Files: `.agents/skills/git-operations/scripts/GitOperations.psm1`, `.agents/skills/git-operations/scripts/GitOperations.psd1`, `.agents/skills/git-operations/tests/GitOperations.Tests.ps1`, `.agents/skills/git-operations/SKILL.md`, `.agents/skills/git-operations/references/commits.md`, `.agents/skills/git-operations/references/integration.md`

  Inputs: Task 1.1's registered-workspace identity and live safety checks.

  1. Replace Mode/GoalName commit inputs and `Merge-HardnessGitGoal` with exact WorkspaceRoot/SourceWorkspaceRoot contracts.
  2. Cover primary and arbitrary linked-worktree commits, explicit all-change preview, stale reviewed HEAD, disjoint dirty target data, resumable multi-repository integration, and ordered non-force push.
  3. Preserve the separation between commit, integration, push, and worktree removal.

- [x] 1.3 Rebuild the Hardness context, routes, observation, and maintenance surfaces — verify: `pwsh.exe -NoProfile -File .agents/skills/hardness/tests/Hardness.Tests.ps1`
  > Files: `.agents/skills/hardness/scripts/Hardness.psm1`, `.agents/skills/hardness/scripts/Hardness.psd1`, `.agents/skills/hardness/tests/Hardness.Tests.ps1`, `.agents/skills/hardness/tests/Hardness.Performance.Tests.ps1`, `.agents/skills/hardness/tests/Test-Hardness.Tests.ps1`

  Produces: one mode-free context/result contract plus `workspace.list`, fast/detailed workspace status, `hardness.status`, `hardness.observe`, `hardness.evolution.status`, and read-only `openspec.maintenance.status` routes.

  1. Start with failing route/context tests, including HarnessRoot distinct from WorkspaceRoot and no Goal/Current compatibility parameters.
  2. Keep raw observations bounded and ignored under `Saved/Hardness/`; report source/package maintenance facts without changing `Tools/openspec` or the packaged EXE.
  3. Update performance correctness probes to the new API while retaining PS7-only and hermetic TaskStatus behavior.

## 2. Cross-client workflow surface

- [x] 2.1 Align authoring, routing, optional Codex hooks, and protocol guards — verify: `pwsh.exe -NoProfile -Command "& '.agents/skills/hardness/tests/Protocol.Tests.ps1'; & '.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1'"`
  > Files: `.agents/skills/hardness/SKILL.md`, `.agents/skills/hardness/references/routing.md`, `.agents/skills/hardness/references/task-dag.md`, `.agents/skills/hardness/references/review.md`, `.agents/skills/hardness/references/closure.md`, `.agents/skills/hardness/scripts/Invoke-HardnessCodexHook.ps1`, `.agents/skills/hardness/tests/Protocol.Tests.ps1`, `.agents/skills/openspec/SKILL.md`, `.agents/skills/openspec/references/tasks.md`, `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`, `.agents/skills/openspec-explore/SKILL.md`, `.agents/skills/openspec-explore/references/deep-exploration.md`, `.agents/skills/openspec-explore/references/question-rounds.md`, `.agents/skills/openspec-continue-change/SKILL.md`, `.agents/skills/openspec-update-change/SKILL.md`, `.agents/skills/openspec-apply-change/SKILL.md`, `.agents/skills/visual-explain/SKILL.md`, `.agents/skills/unreal-engine-develop/SKILL.md`, `.agents/skills/README.md`, `.codex/hooks.json`, `.gitignore`, `openspec/config.yaml`, `openspec/README.md`, `AGENTS.md`, `README.md`

  Constraints: Preserve the top-level temporary Skill-disable instruction until the user explicitly lifts it, and stage only this Change's AGENTS.md hunks. Do not inspect or migrate old loop tools.

  1. Remove live Goal/Current repository wording and document explicit pre-Change Explore and multi-relationship visual triggers.
  2. Permit useful optional Task Card prose without adding parser fields or changing OpenSpec source/binary.
  3. Add bounded, non-mutating `SessionStart` and `SubagentStart` adapters to fast status only; keep Cursor and Grok independent and omit Stop/PostToolUse hooks.
  4. Guard English maintained content, route names, hook bounds, Review timing, and the OpenSpec maintenance boundary.

## 3. Evidence and durable synchronization

- [x] 3.1 Run focused and complete PS7 core gates — verify: `pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Quick`
  > Files: `.agents/skills/hardness/scripts/Test-Hardness.ps1`, `.agents/skills/hardness/tests/Test-Hardness.Tests.ps1`, `openspec/changes/hardness/refactor-unified-workspace-core/attachments/INDEX.md`

  1. Run the focused scripts from Tasks 1.1-2.1, then the complete Quick profile once after their repair cycles.
  2. Record exact durations and any excluded UE/product gates without creating routine implementation issues.

- [x] 3.2 Measure the new paths and retain one compact workflow evaluation — verify: `pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Performance -WarmupRuns 1 -MeasurementRuns 5 -BatchSize 500 -TaskChange hardness/refactor-unified-workspace-core -PerformanceRunId workspace-core-final-20260903`
  > Files: `.agents/skills/hardness/tests/Hardness.Performance.Tests.ps1`, `.agents/skills/hardness/scripts/Test-Hardness.ps1`, `.agents/skills/hardness/tests/Test-Hardness.Tests.ps1`, `openspec/changes/hardness/refactor-unified-workspace-core/attachments/data/workflow-evaluation.md`, `openspec/changes/hardness/refactor-unified-workspace-core/attachments/INDEX.md`

  1. Measure fresh import/context, persistent dispatch, task status, fast workspace/status, detailed status, and observation overhead with behavior assertions.
  2. Compare with the 130.9-second pre-implementation Quick baseline and available prior status samples without creating a flaky machine gate.
  3. Track one privacy-trimmed evaluation of lifecycle elapsed time, friction, corrections, deferrals, and hashes/paths of ignored raw evidence; index it in the same edit.

- [x] 3.3 Sync durable specs and pass the complete semantic verification gate — verify: `pwsh.exe -NoProfile -Command "& '.agents/skills/openspec/bin/openspec.exe' validate 'hardness/refactor-unified-workspace-core' --strict --json; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; & '.agents/skills/hardness/scripts/Test-Hardness.ps1' -Profile Quick"`
  > Files: `openspec/specs/hardness/core/spec.md`, `openspec/specs/hardness/core/spec.yaml`, `openspec/specs/hardness/workspace/spec.md`, `openspec/specs/hardness/workspace/spec.yaml`, `openspec/specs/hardness/git/spec.md`, `openspec/specs/hardness/core/knowledges/change-registration-checkpoint.md`, `openspec/specs/hardness/core/knowledges/harness-evolution.md`, `openspec/specs/hardness/core/knowledges/INDEX.md`, `openspec/changes/hardness/refactor-unified-workspace-core/tasks.md`, `openspec/changes/hardness/refactor-unified-workspace-core/attachments/INDEX.md`

  1. Merge the complete deltas into current specs and update concise reusable evolution guidance before Review.
  2. Confirm no live mode terminology, Hazelight config key, placeholder Unreal route, parser/EXE change, plugin change, integration, push, or removal entered scope.
  3. Record exact verification, spec-sync, exclusions, timing, and closure inputs before the final policy/closure node.

## 4. Direct closure policy

- [x] 4.1 Remove automatic Review gating and prove direct completed closure — verify: `pwsh.exe -NoProfile -Command "& '.agents/skills/hardness/tests/Protocol.Tests.ps1'; if (-not $?) { exit 1 }; & '.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1'; if (-not $?) { exit 1 }; & '.agents/skills/openspec/bin/openspec.exe' validate 'hardness/refactor-unified-workspace-core' --strict --json; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; & '.agents/skills/openspec/bin/openspec.exe' validate --specs --strict --json"`
  > Files: `.agents/skills/hardness/SKILL.md`, `.agents/skills/hardness/references/review.md`, `.agents/skills/hardness/references/closure.md`, `.agents/skills/hardness/references/routing.md`, `.agents/skills/hardness/references/task-dag.md`, `.agents/skills/hardness/tests/Protocol.Tests.ps1`, `.agents/skills/code-review/code-reviewer/SKILL.md`, `.agents/skills/openspec-archive-change/SKILL.md`, `.agents/skills/openspec-verify-change/SKILL.md`, `.agents/skills/openspec/references/attachments.md`, `.agents/skills/openspec/references/knowledge.md`, `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`, `.agents/skills/README.md`, `AGENTS.md`, `openspec/config.yaml`, `openspec/specs/hardness/core/spec.md`, `openspec/specs/hardness/core/spec.yaml`, `openspec/specs/hardness/core/knowledges/INDEX.md`, `openspec/specs/hardness/core/knowledges/change-registration-checkpoint.md`, `openspec/specs/hardness/core/knowledges/harness-evolution.md`, `openspec/specs/hardness/core/knowledges/review-gate-scheduling.md`, `openspec/changes/hardness/refactor-unified-workspace-core/proposal.md`, `openspec/changes/hardness/refactor-unified-workspace-core/design.md`, `openspec/changes/hardness/refactor-unified-workspace-core/specs/hardness/core/spec.md`, `openspec/changes/hardness/refactor-unified-workspace-core/tasks.md`, `openspec/changes/hardness/refactor-unified-workspace-core/attachments/INDEX.md`, `openspec/changes/hardness/refactor-unified-workspace-core/attachments/data/workflow-evaluation.md`, `openspec/changes/hardness/refactor-unified-workspace-core/attachments/replans/replan-20260903-175249-remove-automatic-final-review.md`

  Context: The user explicitly replaced automatic Incident/Final Review scheduling while the former Review snapshot was being prepared; no Review file or snapshot ref was created.

  1. Make Review explicit-only across every live workflow, archive, attachment, knowledge, and regression surface; retain detailed fixed-snapshot review-v2 records only for user/external-agent requests.
  2. Route discovered local defects to repair and planning-invalidating evidence to replan, then allow verified work with no explicit Review to close/archive directly without impact classification or placeholder files.
  3. Update this Change's canonical truth, durable specification, capability knowledge, evaluation, and closure inputs; prove both live policy and strict OpenSpec structure.

After Task 4.1 passes, create the completed closure input, archive deterministically, validate the archived record strictly, run the smallest non-destructive lifecycle gate, and commit the exact archived Change. Archive is outside the Task DAG because completed closure requires every DAG node already complete. Do not integrate, push, or remove a workspace.
