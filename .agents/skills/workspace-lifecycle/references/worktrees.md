# Workspace lifecycle

## Inspect and select

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot $PWD
Invoke-Harness workspace.list -Context $context
Invoke-Harness workspace.status -Context $context
Invoke-Harness workspace.status -Context $context -Parameters @{Detailed=$true}
Invoke-Harness workspace.activate -Context $context
```

- Fast status returns identity and configuration readiness without a dirty scan. Detailed status checks source hashes and plugin repositories.
- Primary identity comes from Git. Replica identity comes from `.harness/workspace.json` plus the matching primary `Saved/Harness/Workspaces/` registration. Moving/copying a descriptor does not register another workspace.
- A replica has no root branch/HEAD. Its repositories carry individual baselines/heads; `GitCommonDir` identifies the control repository only. Nested directories resolve to the containing replica before Git lookup.

## Create and prepare approved plugins

```powershell
Invoke-Harness workspace.new -Context $context -Parameters @{
    Name='feature-x'
    EditablePlugins=@('Angelscript')
    RequiredPlugins=@()
    HostFiles=@('Config/DefaultEngine.ini')
}
$child = New-HarnessContext -WorkspaceRoot (Join-Path $context.PrimaryRoot '.workspaces/feature-x')
Invoke-Harness workspace.prepare -Context $child -Parameters @{EditablePlugins=@('AdditionalPlugin')}
Invoke-Harness workspace.bootstrap -Context $child
Invoke-Harness workspace.verify -Context $child
```

- Creation generates the minimal `.uproject`, Game/Editor targets, host module, project-local UBT configuration and a short AGENTS pointer. `HostFiles` adds exact necessary `Source/Config/Content/Script` files; no broad directory copy.
- Host files come from current primary working files with recorded SHA-256. Plugins use each source repository's committed HEAD, pinned at creation; enabled project-plugin dependencies are included transitively. Required unmodified plugins are plain file snapshots with independent build outputs.
- Editable plugin branches default to `Name`; `Branch` overrides the plugin branch name. Parent `StartPoint` is inapplicable. New plugin worktrees and snapshots never contain source uncommitted edits.
- `prepare` adds only approved plugins, or upgrades an unchanged snapshot to an editable worktree. It preserves generated build outputs and a backup snapshot under local `Saved/Harness/WorkspaceSnapshots/`. Changed source/project descriptors stop preparation before overwriting them.
- Creation preserves partial payload on failure. Diagnose the exact state and resume `prepare`/`bootstrap`; no automatic deletion or branch reset. Explicit bootstrap repairs local AgentConfig, not host snapshots.
- Parent Skills/OpenSpec are shared through explicit roots, not copied. A new workspace starts with no queue; route membership/execution to `change-queue`.

## Remove explicitly

```powershell
Invoke-Harness workspace.remove -Context $child -Parameters @{WhatIf=$true;DiscardIgnoredFiles=$true}
# Execute only when workspace removal and local-output discard are authorized.
Invoke-Harness workspace.remove -Context $child -Parameters @{DiscardIgnoredFiles=$true}
```

- Removal refuses primary, dirty/changed source, mismatched identity, unsafe paths, active controllers and pending queue members. Plugin branches survive removal.
- Runtime output is local data. Inspect it before passing `DiscardIgnoredFiles`; unknown source payload is preserved even when runtime discard is requested.
- Existing parent Git worktrees retain the legacy exact-gitlink bootstrap/removal contract. They are never migrated or attached to a queue automatically.
