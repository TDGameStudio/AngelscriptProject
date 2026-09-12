# Route Map

Select the route first, then read only the owning leaf Skill. Every route operates on the workspace carried by the Harness context; the primary checkout and registered linked worktrees share one contract.

| Need | Leaf | Route or dispatch |
|---|---|---|
| Fast workspace/harness orientation | `harness/SKILL.md` | `harness.status` |
| List registered workspaces | `workspace-lifecycle/SKILL.md` | `workspace.list` |
| Workspace identity, bootstrap, selection, verification, or explicit cleanup | `workspace-lifecycle/SKILL.md` | `workspace.*` |
| Exact commits, reviewed workspace integration, or explicit non-force push | `git-operations/SKILL.md` | `git.*` |
| Bounded local workflow observation | `harness/SKILL.md` | `harness.observe` |
| Aggregated self-evolution status | `harness/SKILL.md` | `harness.evolution.status` |
| UE readiness, engines, targets, processes, or UBT capabilities | `unreal-engine-develop/SKILL.md` | `ue.status`, `ue.engine.list`, `ue.target.list`, `ue.process.list`, `ue.ubt.capabilities` |
| UE build, test, commandlet, suite, or managed-run lifecycle | `unreal-engine-develop/SKILL.md` | `ue.build`, `ue.test`, `ue.commandlet`, `ue.suite.*`, `ue.run.*`; use `ue.ubt.invoke` only for a declared generic capability |
| Portable OpenSpec source/package alignment | `openspec/SKILL.md` | `openspec.maintenance.status` |
| OpenSpec command or CLI maintenance | `openspec/SKILL.md` | `openspec.*` |
| Brainstorming before a new feature, architecture refactor, or major behavior Change, or when a user-owned decision is unconfirmed | `brainstorming/SKILL.md` | Agent-driven before creating that Change; records rounds under `openspec/drafts/` |
| Creating a Change from one selected approved design and seeding English attachments (design/handoff, confirmed talks and knowledge, INDEX) | `openspec-create-change/SKILL.md` | Once per scoped handoff; resume an existing target before `openspec-apply-change` |
| Naming a new public type, module, file, or function | `brainstorming/references/naming.md` | Grilled during brainstorming and task authoring; apply derives an unlisted name from convention and records `Naming assumed` |
| Lightweight investigation inside a Ready task | Stay in `openspec-apply-change/SKILL.md`; add `systematic-debugging/SKILL.md` only for unexplained failure | Agent-driven inside the task |
| Revise accepted planning truth or apply an evidence-gated Replan | `openspec-update-change/SKILL.md` | Agent-driven |
| Implement a Change | `openspec-apply-change/SKILL.md` | Agent-driven |
| Verify a Change for completion or an explicitly requested fixed-snapshot Review | `openspec-verify-change/SKILL.md` | Agent-driven |
| Sync durable specs or archive | `openspec-sync-specs/SKILL.md`, `openspec-archive-change/SKILL.md` | Agent-driven |
| Visualize multiple relationships, a sequence, or state transitions | `visual-explain/SKILL.md` | Agent-driven when a visual materially reduces ambiguity |
| AngelScript C++ automation tests | `angelscript-test-guide/SKILL.md` | Agent-driven |
| Behavior implementation | `test-driven-development/SKILL.md` | Agent-driven |
| Unexpected or repeated failure | `systematic-debugging/SKILL.md` | Agent-driven |
| Review explicitly requested by the user or an external agent | `code-review/SKILL.md` | Fixed snapshot; inline or asynchronous when useful; coordinator triage in `review.md` |
| Hazelight update audit | `hazelight-update-audit/SKILL.md` | Agent-driven |

Inspect the executable table without loading leaf documentation:

```powershell
Get-HarnessCommand
Get-HarnessCommand workspace.activate
Get-HarnessCommand harness.status
Get-HarnessCommand git.integrate
```

Current public route families are:

```text
workspace.list/status/new/bootstrap/verify/remove/activate/config.status/config.get/config.set
git.status/commit/integrate/push
harness.status/observe/evolution.status
openspec.init/doctor/status/instructions/validate/domain/spec/change/workflow/completion
openspec.maintenance.status
task.status
ue.status/engine.list/target.list/process.list/ubt.capabilities/ubt.invoke
ue.build/test/commandlet/suite.list/suite.plan/suite.run/run.status/run.cancel
```

All `ue.*` routes receive the exact selected `WorkspaceRoot` from the Harness context and lazy-load one maintained leaf module. A caller-supplied workspace mismatch is rejected. Root `Tools` wrappers are not fallback routes.
