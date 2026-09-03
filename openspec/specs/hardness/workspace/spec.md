# Hardness Workspace Lifecycle

## Purpose

This capability defines one Git-derived workspace model for the primary checkout and every registered worktree, including exact context identity, AgentConfig v2, process-local selection, tiered status, guarded execution, bounded discovery caching, and explicit safe cleanup.

## Requirements

### Requirement: Canonical workspace lifecycle ownership

`workspace-lifecycle` SHALL exclusively own registered-worktree creation, bootstrap, listing, topology/status, strict verification, local configuration projection, process-local selection, and explicit safe removal. These operations MUST preserve exact parent gitlinks and local data and MUST NOT create commits, merge branches, push, scaffold OpenSpec records, run product validation, or infer authority from Codex `/goal`. New worktrees default to `.worktrees/<name>` on branch `<name>`, while existing registered worktrees are never moved or renamed merely to become managed.

#### Scenario: Create a named workspace
- **WHEN** the user explicitly requests a new workspace named `feature-x` without a branch override
- **THEN** Hardness creates `.worktrees/feature-x` on branch `feature-x`, initializes exact top-level gitlinks, materializes target-local configuration, and performs no unrelated workflow side effect

#### Scenario: Bootstrap an existing registered worktree
- **WHEN** a registered worktree uses another path or branch naming convention
- **THEN** Hardness repairs its local configuration in place without moving the root, changing the branch, committing, integrating, or pushing

#### Scenario: Remove a registered worktree
- **WHEN** the user explicitly requests removal of an exact clean registered linked worktree
- **THEN** ignored data is inventoried, explicit discard intent is required when such data exists, and its branch remains preserved

### Requirement: Hardness-managed local configuration

Each workspace SHALL use one ignored root `AgentConfig.ini`. Schema v2 SHALL reserve `[Hardness] SchemaVersion`, `WorkspaceRoot`, `PrimaryRoot`, and `GitCommonDir` plus `[Paths] ProjectFile`; `WorkspaceKind` and `GoalName` MUST NOT be written or accepted as v2 identity. Topology, WorktreeName, Branch, Head, engine classification, and run state remain runtime facts. Explicit bootstrap SHALL copy machine-shared values only from the canonical primary workspace, preserve other non-managed local fields and comments, bind the target's unique root `.uproject`, and remove the obsolete `[References] HazelightAngelscriptEngineRoot` key. Configuration status MUST reject that obsolete key when it remains. Generic mutation MUST reject managed fields and malformed multiline data. A trusted leaf MAY request a bounded batch of exact keys after one live status or execution-guard check, but that projection MUST NOT cache safety facts or become a bulk-value Hardness route.

#### Scenario: Migrate schema v1 in place
- **WHEN** explicit bootstrap finds a valid schema v1 AgentConfig in a registered workspace
- **THEN** it atomically writes schema v2, removes `WorkspaceKind`, `GoalName`, and the obsolete Hazelight path, rebinds ProjectFile, and preserves other user-controlled content

#### Scenario: Bootstrap without a primary configuration
- **WHEN** the canonical primary workspace has no `AgentConfig.ini`
- **THEN** Hardness writes a minimal valid v2 identity/project binding and reports that consumer configuration is still required

#### Scenario: Query or update local configuration
- **WHEN** a caller uses configuration status/get/set
- **THEN** status avoids bulk value disclosure and reports stale managed or removed keys, get reads one exact key, set atomically updates one non-managed key, and unrelated content remains unchanged

#### Scenario: Project configuration for a trusted leaf
- **WHEN** a leaf needs several exact values for one operation
- **THEN** workspace lifecycle performs one fresh status or execution guard, returns at most 64 requested entries, and does not cache identity, configuration bytes, authorization, or mutation preconditions

### Requirement: Per-session workspace selection

Hardness MAY bind one exact registered WorkspaceRoot to the current PowerShell process but MUST NOT store a global active workspace shared by agents. The binding SHALL expose only WorkspaceRoot, PrimaryRoot, and GitCommonDir to child processes and SHALL be replaceable by a later explicit selection. Repository mode and Goal-name environment variables MUST NOT be created or consumed.

#### Scenario: Coordinate concurrent agents
- **WHEN** two agents select different registered worktrees in separate PowerShell 7 sessions
- **THEN** each process retains its own exact WorkspaceRoot and neither modifies the other's AgentConfig or session binding

#### Scenario: Replace a process-local selection
- **WHEN** a caller explicitly selects another registered workspace in the same session
- **THEN** the three workspace environment bindings are replaced together without retaining a mode or Goal name

### Requirement: Workspace-sensitive execution guard

Before a workspace-sensitive command starts, the requested project root, registered Git worktree, Git common directory, AgentConfig v2 identity, configured `.uproject`, optional Hardness session selection, and discoverable caller workspace MUST agree. A custom configuration path MUST NOT bypass the workspace-owned AgentConfig. A mismatch SHALL fail before launching an external tool. Read-only discovery across registered worktrees SHALL remain available.

#### Scenario: Refuse a cross-workspace launch
- **WHEN** a process selected for one WorkspaceRoot attempts to start work against another root
- **THEN** the guard reports both exact roots and launches no external build, test, or commandlet process

#### Scenario: Permit the selected workspace
- **WHEN** registration, config v2, project path, optional session binding, and requested root all agree
- **THEN** the guard returns the canonical context without adding a Goal/Current interpretation

### Requirement: Git-derived workspace discovery and status tiers

Workspace context MUST be derived from Git registration and SHALL expose `SchemaVersion`, `HarnessRoot`, `WorkspaceRoot`, `PrimaryRoot`, `GitCommonDir`, `Topology`, `WorktreeName`, `Branch`, `Head`, and `Managed`. `Topology` is only `Primary` or `Worktree`; `Managed` states whether exact AgentConfig v2 identity is present and MUST NOT decide whether a registered worktree is valid. `HarnessRoot` identifies the checkout supplying the loaded Hardness implementation, while `WorkspaceRoot` identifies the command target. `workspace.list` SHALL enumerate all worktrees registered in the same common directory. Default `workspace.status` SHALL return identity, registration, branch/HEAD, and configuration readiness without dirty or recursive submodule scans; explicit detailed status SHALL add current parent/submodule state.

#### Scenario: Target a workspace from another checkout
- **WHEN** Hardness is loaded from the primary checkout and a registered linked worktree is selected
- **THEN** HarnessRoot remains the primary checkout, WorkspaceRoot is the linked root, and all leaf defaults target WorkspaceRoot

#### Scenario: List heterogeneous worktrees
- **WHEN** registered worktrees exist outside `.worktrees/` or use branches without a standard prefix
- **THEN** `workspace.list` returns each actual root, topology, WorktreeName, branch, HEAD, and managed state without rejecting or renaming it

#### Scenario: Request fast status
- **WHEN** a caller or hook invokes default `workspace.status`
- **THEN** no `git status`, ignored-file inventory, or recursive submodule dirty scan runs

#### Scenario: Request detailed status
- **WHEN** a caller explicitly selects detailed status
- **THEN** current parent, gitlink, submodule, ignored-payload, and configuration diagnostics are returned and are labeled as the more expensive view

### Requirement: Bounded stable-fact caching

Workspace discovery MAY cache only process-local stable facts for a short documented lifetime and SHALL provide explicit refresh. Any workspace create, bootstrap, selection, or removal operation MUST invalidate affected cache entries. Registration, branch, HEAD, dirty state, ignored payload, config bytes, authorization, and mutation preconditions MUST be read live whenever they guard an operation.

#### Scenario: Reuse stable discovery
- **WHEN** repeated read-only context construction occurs in one PowerShell session
- **THEN** immutable module paths and safely bounded canonical-root facts may be reused without changing the returned workspace identity

#### Scenario: Guard a mutation
- **WHEN** a lifecycle or Git mutation is previewed or executed
- **THEN** every safety-sensitive fact is refreshed even if a prior status call populated the cache
