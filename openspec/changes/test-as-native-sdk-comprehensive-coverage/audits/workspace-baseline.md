# Workspace Baseline

Captured before implementation on 2026-07-23.

## Repository identity

| Repository | Branch | HEAD | Role |
| --- | --- | --- | --- |
| `D:/Workspace/AngelscriptProject` | `main` | `7cb9de9fa10d34311847bcaa0d94df0d76dd0220` | Parent OpenSpec, documentation, configuration, plugin gitlink |
| `Plugins/Angelscript` | `main` | `4e2e23ca16ae9f1786258fb96b09b268259b1aad` | Native SDK test implementation and any narrowly required runtime exports |

The active checkout is the primary workspace. No additional worktree is used. The user explicitly authorized implementation after completing this OpenSpec.

## Parent changes that predate this implementation

The following are user/other-task state and must not be reset, overwritten, staged, or committed as part of this change unless a later scoped diff proves this change intentionally modified the same path:

- `.agents/skills/hazelight-update-audit/references/audit-log.md`
- `.agents/skills/hazelight-update-audit/references/audit-state.json`
- `AngelscriptProject.uproject`
- `Config/DefaultEngine.ini`
- deleted historical full-coverage planning document under `Documents/`
- `Documents/Guides/AngelscriptRefactorRoadmap.md`
- `Documents/Knowledges/ZH/Arch_Overview.md`
- `Documents/Knowledges/ZH/Note_InterfaceBinding.md`
- `Documents/Knowledges/ZH/RT_HotReload.md`
- deleted legacy example files beneath `Documents/Plans/Plan_ScriptExamplesExpansion/Coverage/`
- dirty `Plugins/AngelscriptGAS` submodule
- `Reference/README.md`
- `Source/AngelscriptProject.Target.cs`
- `Tools/PullReference/PullReference.bat`
- `Wiki` submodule/worktree state
- deleted active `openspec/changes/fix-hazelight-actor-null-guards/` files and its untracked archive copy
- modified `openspec/changes/refactor-uht-plugin-hardening/` artifacts
- modified `openspec/changes/test-coverage/` artifacts
- untracked `.agents/skills/archify/` and `.agents/skills/ui-ux-pro-max/`
- `Config/DefaultEditorPerProjectUserSettings.ini`
- untracked `Docs/Screenshots/` and `Docs/superpowers/plans/` files
- `Documents/Guides/VSCodeAngelscript.md`
- `Documents/Hazelight/DelegateShadowTypeSemantics.md`
- untracked `Extensions/`
- untracked `openspec/changes/feature-wiki-notion-cover-icon/`
- untracked `openspec/specs/actor-attached-actor-query/`
- `vs2026error.png`

This change owns the new parent directory `openspec/changes/test-as-native-sdk-comprehensive-coverage/`. Later documentation/configuration edits must be reviewed against this baseline before being attributed to the change.

## Plugin changes that predate this implementation

- `Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`
- `Source/AngelscriptTest/Coverage/AngelscriptCoverageInputTests.cpp`
- `Source/AngelscriptTest/Coverage/AngelscriptCoverageLoopTests.cpp`
- `Source/AngelscriptTest/Coverage/AngelscriptCoverageUStructTests.cpp`
- `Source/AngelscriptTest/Coverage/AngelscriptCoverageWidgetTests.cpp`
- `Source/AngelscriptTest/Debugger/AngelscriptDebuggerDatabaseTests.cpp`
- `Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotGeneration.cpp`

The planned native test additions use `Source/AngelscriptTest/AngelScriptSDK/` and do not require these dirty test paths. If a runtime change becomes necessary and overlaps `AngelscriptEngine.cpp`, implementation must stop on that path, inspect the existing diff, and either avoid it or obtain user coordination.

## Commit and staging guard

1. Stage plugin paths explicitly; never stage the entire submodule.
2. Confirm the seven pre-existing plugin modifications remain unstaged and byte-for-byte outside this change's diff.
3. Commit plugin-native changes first.
4. Stage the parent change directory, intentional documentation/configuration files, and the plugin gitlink explicitly.
5. Re-run status/diff checks before each commit.
