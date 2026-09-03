## ADDED Requirements

### Requirement: Canonical workspace lifecycle ownership

`workspace-lifecycle` SHALL exclusively own canonical worktree creation, bootstrap, topology/status, strict verification, local configuration projection, session selection, and explicit safe removal. These operations MUST preserve exact parent gitlinks and local data and MUST NOT create commits, merge branches, push, scaffold OpenSpec records, or run product validation.

#### Scenario: Create a Goal workspace
- **WHEN** Hardness creates a named Goal workspace
- **THEN** it creates `.worktrees/<goal>` on `goal/<goal>`, initializes exact top-level gitlinks, materializes target-local configuration, and performs no unrelated workflow side effect

#### Scenario: Remove a Goal workspace
- **WHEN** explicit removal targets a clean exact registered Goal workspace
- **THEN** ignored data is inventoried and removal requires explicit discard intent while the Goal branch remains preserved

### Requirement: Hardness-managed local configuration

Each workspace SHALL use one ignored root `AgentConfig.ini`. Hardness SHALL own a versioned `[Hardness]` identity section and `Paths.ProjectFile`, SHALL copy machine-shared values only from the canonical primary workspace, and SHALL preserve non-managed local fields. Generic mutation MUST reject managed fields and malformed multiline data.

#### Scenario: Project configuration into a Goal
- **WHEN** a Goal workspace is created or bootstrapped
- **THEN** shared values are preserved while workspace identity and the unique root `.uproject` are rebound to the Goal root

#### Scenario: Bootstrap without a primary configuration
- **WHEN** the canonical primary workspace has no `AgentConfig.ini`
- **THEN** Hardness writes a minimal valid identity/project binding and reports that consumer configuration is still required

#### Scenario: Query or update local configuration
- **WHEN** a caller uses configuration status/get/set
- **THEN** status avoids bulk value disclosure, get reads one exact key, set atomically updates one non-managed key, and unrelated content remains unchanged

### Requirement: Per-session workspace selection

Hardness MAY activate one workspace for the current process but MUST NOT store one global active workspace shared by agents. Activation SHALL expose the selected workspace, primary root, mode, and Goal name to child processes and SHALL be replaceable by a later explicit activation in the same session.

#### Scenario: Coordinate concurrent agents
- **WHEN** two agents activate different registered Goal worktrees in separate PowerShell sessions
- **THEN** each process retains its own selection and neither modifies the other's AgentConfig or session binding

### Requirement: Workspace-sensitive execution guard

Before build, test, or commandlet startup, the requested project root, registered Git worktree, AgentConfig identity, configured `.uproject`, optional Hardness session selection, and discoverable caller workspace MUST agree. A custom configuration path MUST NOT bypass the workspace-owned AgentConfig. A mismatch SHALL fail before invoking Unreal tools. Read-only process discovery across registered worktrees SHALL remain available.

#### Scenario: Refuse primary execution from a Goal session
- **WHEN** a Goal-bound process attempts to start a primary-workspace build or test
- **THEN** the guard reports the selected and requested roots and launches no UBT, Editor, or test process

#### Scenario: Preserve multi-worktree operation
- **WHEN** different correctly bound worktrees build concurrently or a caller queries all UBT processes
- **THEN** existing per-worktree mutex/output/slot isolation and cross-worktree discovery remain unchanged
