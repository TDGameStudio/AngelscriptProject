# Worktree Lifecycle

## Inspect and Select

```powershell
Import-Module ./.agents/skills/hardness/scripts/Hardness.psd1

$context = New-HardnessContext -WorkspaceRoot $PWD
Invoke-Hardness -Command workspace.list -Context $context
Invoke-Hardness -Command workspace.status -Context $context
Invoke-Hardness -Command workspace.status -Context $context -Parameters @{ Detailed = $true }
Invoke-Hardness -Command workspace.activate -Context $context
```

The default status is intentionally fast: it returns Git-derived identity, branch, HEAD, registration, and configuration readiness without a dirty or recursive submodule scan. Request `Detailed` only when current file, gitlink, submodule, or ignored-payload diagnostics are needed.

## Create and Bootstrap

```powershell
Invoke-Hardness -Command workspace.new -Context $context -Parameters @{
  Name = 'feature-x'
}

Invoke-Hardness -Command workspace.bootstrap -Context $existingWorktree
Invoke-Hardness -Command workspace.verify -Context $existingWorktree
```

`workspace.new` creates `.worktrees/feature-x` on branch `feature-x` unless `Branch` or `StartPoint` is supplied explicitly. It initializes exact top-level gitlinks and projects the local configuration, but does not create an OpenSpec Change.

`workspace.bootstrap` accepts every worktree registered in the same Git common directory. It repairs the checkout in place; it does not move the root, rename its branch, commit, integrate, push, or select it for the current process.

## Remove Explicitly

```powershell
Invoke-Hardness -Command workspace.remove -Context $existingWorktree

# Only after inspecting the returned ignored-data inventory:
Invoke-Hardness -Command workspace.remove -Context $existingWorktree -Parameters @{
  DiscardIgnoredFiles = $true
}
```

Removal requires an exact, clean, registered linked worktree and preserves its branch. Ignored local data requires explicit discard intent. An unsafe reparse path, dirty parent, dirty or inexact submodule, uninitialized payload, or primary checkout is refused without deletion.

If bootstrap cannot obtain an exact gitlink, it preserves the workspace and reports the missing object or unsafe local state. Recover that exact object or repair the explicit submodule checkout; never substitute a nearby branch tip.
