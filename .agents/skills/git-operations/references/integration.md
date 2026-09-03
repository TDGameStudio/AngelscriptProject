# Local Integration

Run integration only with the canonical primary workspace selected and only after the exact linked source snapshot is reviewed.

```powershell
$parameters = @{
  SourceWorkspaceRoot = 'D:\Workspace\refactor-example'
  ExpectedSourceHead = '<reviewed-parent-commit>'
  TargetBranches = @{
    '.' = 'main'
    'Plugins/Angelscript' = 'main'
  }
  CommitMessage = '[Hardness] Refactor: integrate refactor-example'
}

Invoke-Hardness -Command git.integrate -Context $primary -Parameters ($parameters + @{ WhatIf = $true })
Invoke-Hardness -Command git.integrate -Context $primary -Parameters $parameters
```

Target branches are explicit because a detached submodule may intentionally target a branch other than its remote default.

The source must be an exact registered linked worktree in the same Git common directory as the primary target. Integration rejects source snapshot drift, dirty source repositories, any target staged content, local/incoming path overlap, ambiguous branches, and ordinary merge conflicts. Disjoint unstaged or untracked target work is preserved. Submodules integrate before the parent, using fast-forward where possible and `--no-ff` merge for diverged histories. If a later repository conflicts, a rerun recognizes earlier repositories that already contain both source and target history.

Integration never pushes, deletes a source branch, removes a source worktree, or claims OpenSpec closure. Those are separate explicit operations.

## Explicit Push

Only invoke this route after the user explicitly requests push/publication:

```powershell
Invoke-Hardness -Command git.push -Context $primary -Parameters @{
  RepositoryBranches = @{
    'Plugins/Angelscript' = 'main'
    '.' = 'main'
  }
  Remote = 'origin'
  WhatIf = $true
}
```

The real invocation uses the same parameters without `WhatIf`. Submodules push before the parent. If a parent branch references a submodule commit not known reachable from the selected remote, that submodule branch must be included explicitly. The route never force-pushes.
