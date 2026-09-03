# Local Agent Configuration

`AgentConfig.ini` is ignored, machine-local, and owned by Hardness at each workspace root. It is configuration, not a credential store, shared database, or source of Git topology.

## Managed Identity

```ini
[Hardness]
SchemaVersion=2
WorkspaceRoot=D:\Workspace\AngelscriptProject
PrimaryRoot=D:\Workspace\AngelscriptProject
GitCommonDir=D:\Workspace\AngelscriptProject\.git
```

Hardness owns these four keys and `[Paths] ProjectFile`. `Topology`, `WorktreeName`, `Branch`, and `Head` are live Git facts and are never persisted. `HarnessRoot` is the checkout supplying the loaded Hardness module and may differ from the selected `WorkspaceRoot`.

Explicit bootstrap migrates schema v1 in place. It removes the former workspace-kind and goal-name identity keys plus `[References] HazelightAngelscriptEngineRoot`, rebinds `ProjectFile`, and preserves unrelated values, sections, comments, and newline style. When a new linked workspace has no local file, machine-shared values are copied from the canonical primary checkout before its managed fields are rebound.

`[References] HazelightAngelscriptEngineRoot` is forbidden after migration. Its presence makes workspace identity invalid, blocks execution, and cannot be recreated through `workspace.config.set`; run `workspace.bootstrap` to remove it without disturbing unrelated local settings.

## Configuration Routes

```powershell
Invoke-Hardness -Command workspace.config.status -Context $context

Invoke-Hardness -Command workspace.config.get -Context $context -Parameters @{
  Section = 'Paths'
  Key = 'EngineRoot'
}

Invoke-Hardness -Command workspace.config.set -Context $context -Parameters @{
  Section = 'Paths'
  Key = 'EngineRoot'
  Value = 'J:\UnrealEngine\UERelease'
}
```

`status` reports identity and key availability without dumping values. `get` reads one exact key. `set` updates one non-managed, single-line value atomically while preserving unrelated local content.

Trusted leaf modules may call the exported `Get-HardnessWorkspaceConfigValues` function to read up to 64 named entries after one live status or execution-guard check. This batch boundary avoids repeating Git identity validation for every key; it does not cache configuration bytes, authorization, or mutation preconditions, and it is not an additional Hardness route.

## Process-local Selection

`workspace.activate` writes only these process environment variables for child commands:

```text
HARDNESS_WORKSPACE_ROOT
HARDNESS_PRIMARY_ROOT
HARDNESS_GIT_COMMON_DIR
```

A later explicit selection replaces all three. No repository mode or workflow name is stored. Separate PowerShell 7 processes can therefore select different registered worktrees without modifying each other's local configuration.

Before a workspace-sensitive command launches an external process, the execution guard compares the requested root, Git registration and common directory, schema-v2 identity, root `.uproject`, optional process selection, and caller location. Read-only listing remains available across all registered worktrees.
