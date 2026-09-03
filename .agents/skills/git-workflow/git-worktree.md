# Worktree Commands

## Through Hardness

```powershell
Import-Module ./.agents/skills/hardness/scripts/Hardness.psd1
$goal = New-HardnessContext -Mode Goal -ProjectRoot $PWD -GoalName refactor-example

Invoke-Hardness -Command workspace.new -Context $goal
Invoke-Hardness -Command workspace.status -Context $goal
Invoke-Hardness -Command workspace.verify -Context $goal
Invoke-Hardness -Command workspace.finish -Context $goal -Parameters @{
  CommitMessage = '[Harness] Refactor: complete example goal'
}
```

Finish leaves only the branch and worktree Git state committed, clean, and exact. It does not establish Goal-level integration readiness, merge, push, or remove.

## Compatibility scripts

```powershell
.agents/skills/git-workflow/scripts/NewWorktree.ps1 -Name refactor-example -Verify
.agents/skills/git-workflow/scripts/BootstrapWorktree.ps1 -ProjectRoot .worktrees/refactor-example
.agents/skills/git-workflow/scripts/VerifyWorktree.ps1 -ProjectRoot .worktrees/refactor-example
.agents/skills/git-workflow/scripts/FinishWorktree.ps1 -ProjectRoot .worktrees/refactor-example
.agents/skills/git-workflow/scripts/RemoveWorktree.ps1 -WorktreeRoot .worktrees/refactor-example
# After reviewing ignored local files that the clean-worktree removal reports:
.agents/skills/git-workflow/scripts/RemoveWorktree.ps1 -WorktreeRoot .worktrees/refactor-example -DiscardIgnoredFiles
```

`NewWorktree.ps1` accepts the former `-EngineRoot`, `-NoOpenSpec`, and `-NoPrewarm` switches for one compatibility cycle, but they no longer change behavior. `-Force` is rejected.

If bootstrap cannot obtain an exact gitlink, it preserves the workspace and reports the missing commit or unsafe local state. Recover the commit or repair the explicit submodule; do not replace it with a nearby branch tip.

`workspace.finish` is Goal-only: it rejects the primary checkout, commits dirty submodules only on the dedicated Goal branch, and reports `GitStateComplete` solely as a Git fact. Hardness/OpenSpec decides Goal-level integration readiness only after tasks, verification, review, and closure evidence are complete. `workspace.remove` treats ignored files as user data; inspect the reported list before opting into their deletion. If Git unregisters a worktree but Windows leaves its now-empty canonical root behind, rerun the same remove route with explicit discard intent; nonempty or nested unregistered directories remain protected.
