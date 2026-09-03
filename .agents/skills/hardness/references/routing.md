# Route Map

Read one leaf only after the route is selected.

| Need | Leaf | Hardness route family |
|---|---|---|
| Workspace lifecycle | `git-workflow/SKILL.md` | `workspace.*` |
| OpenSpec command or CLI maintenance | `openspec/SKILL.md` | `openspec.*` |
| Deep discovery for a new feature, architecture refactor, or major behavior change | `openspec-explore/SKILL.md` | Agent-driven before creating the target Change only |
| Task-local technical uncertainty inside a Ready node | Stay in `openspec-apply-change/SKILL.md`; load `systematic-debugging/SKILL.md` only for an unexplained failure | Agent-driven inside the current task |
| Create the next change artifact | `openspec-continue-change/SKILL.md` | Agent-driven |
| Revise existing change artifacts | `openspec-update-change/SKILL.md` | Agent-driven |
| Implement a change | `openspec-apply-change/SKILL.md` | Agent-driven |
| Verify a change | `openspec-verify-change/SKILL.md` | Agent-driven |
| Sync or archive | `openspec-sync-specs/SKILL.md`, `openspec-archive-change/SKILL.md` | Agent-driven |
| AngelScript C++ automation tests | `angelscript-test-guide/SKILL.md` | Agent-driven |
| Behavior implementation | `test-driven-development/SKILL.md` | Agent-driven |
| Unexpected or repeated failure | `systematic-debugging/SKILL.md` | Agent-driven |
| Demonstrated major Incident Review, impact-gated scope-frozen Final Review, or External Review intake | `code-review/code-reviewer/SKILL.md` | Agent-driven, asynchronous when a reviewer subagent is available |
| Hazelight update audit | `hazelight-update-audit/SKILL.md` | Agent-driven |

Inspect the executable table without loading leaves:

```powershell
Get-HardnessCommand
Get-HardnessCommand workspace.finish
```

The public route families are:

```text
workspace.status/new/bootstrap/verify/finish/remove
openspec.init/doctor/status/instructions/validate/domain/spec/change/workflow/completion
task.status
```

The Unreal command leaf is intentionally outside this snapshot. Do not publish placeholder `ue.*` or related routes until the separate `unreal-engine-develop` change supplies and verifies the complete leaf contract.
