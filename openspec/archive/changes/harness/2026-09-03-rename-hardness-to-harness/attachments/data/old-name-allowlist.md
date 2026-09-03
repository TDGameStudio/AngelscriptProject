# Old-Name Audit Allowlist

The final live audit rejects old Hardness public paths, module/function names, route names, process-selection variables, current schema names, current Saved roots, current LocalAppData roots, and generated/default commit scopes. A surviving match is allowed only in one category below and only for the stated purpose.

| Path or boundary | Allowed old-name content | Reason |
|---|---|---|
| `openspec/archive/changes/hardness/**` | all historical paths/content | Immutable OpenSpec evidence; never rewritten by this Change. |
| `Documents/**`, `Reference/**` | historical prose and paths | Explicitly outside this fast Change and scheduled for separate removal/migration. |
| `Tools/openspec/**` | pinned source, tests, release notes, changelog | Independent clean submodule; no update/tag/release is authorized. |
| `openspec/changes/harness/rename-hardness-to-harness/**` | description of old identity and explicit migration inputs | This Change must record what is being replaced; old text is not a public alias. |
| `.agents/skills/harness/tests/HarnessCutover.Tests.ps1` | negative old module/function/route checks | Proves the old public API is absent. |
| `.agents/skills/workspace-lifecycle/scripts/WorkspaceLifecycle.psm1` | `[Hardness]` and `HARDNESS_*` read/clear constants | Bootstrap-only config migration and stale process-environment cleanup. |
| `.agents/skills/workspace-lifecycle/references/agent-config.md` | `[Hardness]` migration input | Maintained operator documentation for the bootstrap-only schema migration. |
| `.agents/skills/workspace-lifecycle/tests/**` | legacy config/environment fixtures | Behavioral proof of rejection, migration, and cleanup. |
| `.agents/skills/harness/scripts/Harness.psm1` | `Saved/Hardness` and `hardness-workflow-evaluation-v1` read constants | Read-only discovery of ignored/immutable historical evidence. |
| `.agents/skills/harness/tests/**` | legacy evidence and negative route fixtures | Compatibility/absence proof; new expected writes remain Harness. |
| `.agents/skills/unreal-engine-develop/scripts/Private/WindowsPath.ps1` | legacy LocalAppData path and drive-schema read constant | Real-operation-only registry migration and old-payload compatibility. |
| `.agents/skills/unreal-engine-develop/tests/**` | legacy registry/schema fixtures | Behavioral proof of PlanOnly immutability, migration, and conflict failure. |
| `openspec/domains/harness/domain.yaml`, `openspec/specs/harness/*/spec.yaml` | old domain/spec IDs under `aliases` only | Stable OpenSpec identity aliases created by the portable domain-move operation. |
| `openspec/specs/harness/{core,workspace,git,unreal}/spec.md` | explicit legacy migration/history-read/absence names | Durable compatibility boundary, not callable API. |

No other maintained live path is allowed to contain an old public identifier. In particular, filenames/directories containing `hardness`, exported or internal `*-Hardness*` symbols, `hardness.status|observe|evolution.status`, default `[Hardness]` commit scopes, and current `hardness-*` schemas fail the audit outside these rows.
