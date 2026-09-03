# Worktree Lifecycle

## Commands

```powershell
Import-Module ./.agents/skills/hardness/scripts/Hardness.psd1

$goal = New-HardnessContext -Mode Goal -ProjectRoot $PWD -GoalName refactor-example
Invoke-Hardness -Command workspace.new -Context $goal
Invoke-Hardness -Command workspace.status -Context $goal
Invoke-Hardness -Command workspace.verify -Context $goal
Invoke-Hardness -Command workspace.activate -Context $goal
```

Removal is separate and explicit:

```powershell
Invoke-Hardness -Command workspace.remove -Context $goal

# Only after inspecting the returned ignored-data inventory:
Invoke-Hardness -Command workspace.remove -Context $goal -Parameters @{
  DiscardIgnoredFiles = $true
}
```

## Lifecycle Boundaries

- `workspace.new` creates `.worktrees/<goal>` on `goal/<goal>` from the requested start commit.
- `workspace.bootstrap` repairs configuration identity and initializes exact top-level gitlinks.
- `workspace.verify` checks registration, gitlinks, submodule dirtiness, configuration identity, and optional cleanliness.
- `workspace.remove` never deletes the Goal branch and never serves as Git integration.
- Worktree creation does not create `openspec/changes/<goal>`; OpenSpec registration is a separate workflow checkpoint.

If bootstrap cannot obtain an exact gitlink, it preserves the workspace and reports the missing object or unsafe local state. Recover that exact object or repair the explicit submodule checkout; never substitute a nearby branch tip.
