# Route Map

Select the route first, then read only the owning leaf Skill. Every route operates on the workspace carried by the Hardness context; the primary checkout and registered linked worktrees share one contract.

| Need | Leaf | Route or dispatch |
|---|---|---|
| Fast workspace/harness orientation | `hardness/SKILL.md` | `hardness.status` |
| List registered workspaces | `workspace-lifecycle/SKILL.md` | `workspace.list` |
| Workspace identity, bootstrap, selection, verification, or explicit cleanup | `workspace-lifecycle/SKILL.md` | `workspace.*` |
| Exact commits, reviewed workspace integration, or explicit non-force push | `git-operations/SKILL.md` | `git.*` |
| Bounded local workflow observation | `hardness/SKILL.md` | `hardness.observe` |
| Aggregated self-evolution status | `hardness/SKILL.md` | `hardness.evolution.status` |
| Portable OpenSpec source/package alignment | `openspec/SKILL.md` | `openspec.maintenance.status` |
| OpenSpec command or CLI maintenance | `openspec/SKILL.md` | `openspec.*` |
| Deep discovery before a new feature, architecture refactor, or major behavior Change | `openspec-explore/SKILL.md` | Agent-driven before creating that Change |
| Lightweight investigation inside a Ready task | Stay in `openspec-apply-change/SKILL.md`; add `systematic-debugging/SKILL.md` only for unexplained failure | Agent-driven inside the task |
| Create the next missing planning artifact | `openspec-continue-change/SKILL.md` | Agent-driven |
| Revise accepted planning truth or apply an evidence-gated Replan | `openspec-update-change/SKILL.md` | Agent-driven |
| Implement a Change | `openspec-apply-change/SKILL.md` | Agent-driven |
| Verify a Change for completion or an explicitly requested fixed-snapshot Review | `openspec-verify-change/SKILL.md` | Agent-driven |
| Sync durable specs or archive | `openspec-sync-specs/SKILL.md`, `openspec-archive-change/SKILL.md` | Agent-driven |
| Visualize multiple relationships, a sequence, or state transitions | `visual-explain/SKILL.md` | Agent-driven when a visual materially reduces ambiguity |
| AngelScript C++ automation tests | `angelscript-test-guide/SKILL.md` | Agent-driven |
| Behavior implementation | `test-driven-development/SKILL.md` | Agent-driven |
| Unexpected or repeated failure | `systematic-debugging/SKILL.md` | Agent-driven |
| Review explicitly requested by the user or an external agent | `code-review/code-reviewer/SKILL.md` | Fixed snapshot; inline or asynchronous when useful |
| Hazelight update audit | `hazelight-update-audit/SKILL.md` | Agent-driven |

Inspect the executable table without loading leaf documentation:

```powershell
Get-HardnessCommand
Get-HardnessCommand workspace.activate
Get-HardnessCommand hardness.status
Get-HardnessCommand git.integrate
```

Current public route families are:

```text
workspace.list/status/new/bootstrap/verify/remove/activate/config.status/config.get/config.set
git.status/commit/integrate/push
hardness.status/observe/evolution.status
openspec.init/doctor/status/instructions/validate/domain/spec/change/workflow/completion
openspec.maintenance.status
task.status
```

The Unreal command leaf is deliberately outside this core snapshot. Do not publish placeholder `ue.*` routes until the separately planned `unreal-engine-develop` Change supplies and verifies the complete contract.
