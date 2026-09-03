# Local Agent Configuration

`AgentConfig.ini` is ignored, machine-local, and owned by Hardness at each workspace root. It is configuration, not a credential store or global agent database.

## Managed Identity

```ini
[Hardness]
SchemaVersion=1
WorkspaceKind=Primary
PrimaryRoot=D:\Workspace\AngelscriptProject
WorkspaceRoot=D:\Workspace\AngelscriptProject
GitCommonDir=D:\Workspace\AngelscriptProject\.git
GoalName=
```

Hardness owns every `[Hardness]` key and `[Paths] ProjectFile`. Branch and HEAD remain live Git facts and are never persisted.

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

## Execution Binding

`workspace.activate` binds the selected context to the current PowerShell process. Child build/test processes inherit that identity. Command startup rejects a requested project root that differs from the selected session, the managed INI identity, the registered Git worktree, or the configured root `.uproject`.

The binding is process-local. Separate agents may activate separate Goal worktrees concurrently. Read-only UBT process discovery remains able to enumerate all registered worktrees.
