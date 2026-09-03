# Scoped Commits

## Inspect

```powershell
Invoke-Hardness -Command git.status -Context $context
```

The result reports parent and initialized top-level submodule heads, branches, and staged/unstaged/untracked paths.

## Commit Exact Current Paths

```powershell
Invoke-Hardness -Command git.commit -Context $current -Parameters @{
  RepositoryScopes = @{
    '.' = @(
      '.agents/skills/workspace-lifecycle'
      '.agents/skills/git-operations'
    )
  }
  CommitMessage = '[Hardness] Refactor: split workspace and Git operations'
}
```

Map `.` to parent-repository paths and a top-level submodule path to paths relative to that submodule. Current mode rejects an omitted scope and any pre-staged path outside it.

## Commit an Isolated Goal

Use exact scopes when possible. `AllChanges` is available only in Goal mode and remains explicit:

```powershell
Invoke-Hardness -Command git.commit -Context $goal -Parameters @{
  AllChanges = $true
  CommitMessage = '[Hardness] Refactor: complete workspace and Git operation split'
  TargetBranches = @{
    'Plugins/Angelscript' = 'goal/refactor-workspace-git-operations'
  }
}
```

Dirty submodules commit first. The parent then commits its selected paths plus the resulting gitlinks. The result reports Git facts only; verification, Review, and closure remain separate gates.
