## MODIFIED Requirements

### Requirement: Per-session workspace selection

Harness MAY bind one exact registered WorkspaceRoot to the current PowerShell process but MUST NOT store a global active workspace shared by agents. The binding SHALL expose only WorkspaceRoot, PrimaryRoot, and GitCommonDir to child processes and SHALL be replaceable by a later explicit selection. Repository mode and Goal-name environment variables MUST NOT be created or consumed.

#### Scenario: Coordinate concurrent agents

- **WHEN** two agents select different registered worktrees in separate PowerShell 7 sessions
- **THEN** each process retains its own exact WorkspaceRoot and neither modifies the other's AgentConfig or session binding

> Details:
>
> - Each session exposes only its own `WorkspaceRoot`, `PrimaryRoot`, and `GitCommonDir` to its child processes.
> - Replacing one session's selection does not alter another session's binding or either workspace's managed identity.
> - No machine-global active-workspace state mediates the two selections.
