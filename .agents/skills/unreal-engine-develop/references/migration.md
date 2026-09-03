# Unreal Runner Migration

Load this reference only when translating an old command or deciding whether a missing workflow belongs in the new Harness surface.

## Public replacements

| Removed Skill-local entry | Harness route |
|---|---|
| `Get-EngineInstallations.ps1` | `ue.engine.list` |
| `Get-UbtProcess.ps1` | `ue.process.list` |
| `RunBuild.ps1` | `ue.build` |
| `RunTests.ps1` | `ue.test` |
| `RunCommandlet.ps1` | `ue.commandlet` |
| `RunTestSuite.ps1` | `ue.suite.list`, `ue.suite.plan`, `ue.suite.run` |
| `RunTestSuiteFast.ps1` | Choose the tracked suite and launch profile through `ue.suite.*`; no separate fast wrapper. |
| `RunTestSuiteParallel.ps1` | No replacement: one workspace suite is deliberately sequential. Use distinct workspaces only where the operation contract permits overlap. |
| `RunTestSuiteEntry.ps1` | Internal suite execution owned by the Unreal module; never a public command. |

The old `scripts/Shared/*.ps1` copies were implementation details. Their maintained behavior now lives in `UnrealEngineDevelop.psm1`, `Private/`, and tracked `data/`; those internals are not direct entrypoints.

## No fallback boundary

Root `Tools` PowerShell entrypoints are legacy deletion candidates, not a compatibility layer. Do not call them when a `ue.*` route is unavailable. `Tools/openspec` is a separate tracked-source exception and is unrelated to Unreal execution.

The current suite catalog is UE Automation only. The following capabilities remain explicit future work and are not emulated by legacy wrappers:

- Standalone Debug and Standalone Release/ZIP gates;
- package and external-package smoke workflows;
- CachePackage;
- coverage collection;
- release orchestration; and
- the full StaticJIT pipeline outside the Automation prefix retained by `All`.

A future scoped Change must define each capability, safety boundary, result contract, and verification before publishing a route.

## Configuration and host

Use only PowerShell 7 and one Harness-selected `WorkspaceRoot`. `AgentConfig.ini` owns local paths; `workspace.bootstrap` creates or repairs managed identity and `workspace.config.set` changes exact non-managed values. The obsolete `References.HazelightAngelscriptEngineRoot` key is invalid and must not be recreated.
