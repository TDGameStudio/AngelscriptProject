## MODIFIED Requirements

### Requirement: Canonical workspace lifecycle ownership

`workspace-lifecycle` SHALL exclusively own registered-worktree creation, bootstrap, listing, topology/status, strict verification, local configuration projection, process-local selection, and explicit safe removal. These operations MUST preserve exact parent gitlinks and local data and MUST NOT create commits, merge branches, push, scaffold OpenSpec records, run product validation, or infer authority from Codex `/goal`. New worktrees default to `.worktrees/<name>` on branch `<name>`, while existing registered worktrees are never moved or renamed merely to become managed.

#### Scenario: Remove a registered worktree
- **GIVEN** Git registration, the canonical physical root, and every initialized top-level submodule still match the workspace selected for removal
- **WHEN** the user explicitly requests removal of an exact clean registered linked worktree
- **THEN** ignored data is inventoried, explicit discard intent is required when such data exists, and its branch remains preserved
- **BUT** removal fails without deleting local payload when the target container resolves through a changed reparse point, a submodule is at the wrong commit, or a deinitialized submodule path still contains data

> Inputs: The exact linked-worktree root, its canonical parent repository, and explicit ignored-payload discard intent when required.
>
> Observables: The operation either removes only the verified linked worktree or reports the exact registration, physical-path, cleanliness, submodule, or payload precondition that prevented removal.
>
> Boundaries: The primary checkout, the retained branch, an outside physical target, and data not proven safe to discard are never removal side effects.
>
> Verification: Workspace lifecycle safety fixtures cover post-registration junction replacement, an exact-clean submodule at the wrong HEAD, and payload beneath a deinitialized submodule path.

### Requirement: Harness-managed local configuration

Each workspace SHALL use one ignored root `AgentConfig.ini`. Schema v3 SHALL reserve `[Harness] SchemaVersion`, `WorkspaceRoot`, `PrimaryRoot`, and `GitCommonDir` plus `[Paths] ProjectFile`; `WorkspaceKind` and `GoalName` MUST NOT be written or accepted as v3 identity. Topology, WorktreeName, Branch, Head, engine classification, and run state remain runtime facts. Explicit bootstrap SHALL copy machine-shared values only from the canonical primary workspace, preserve other non-managed local fields and comments, bind the target's unique root `.uproject`, and remove the obsolete `[References] HazelightAngelscriptEngineRoot` key. Configuration status MUST reject that obsolete key when it remains. Generic mutation MUST reject managed fields and malformed multiline data. A trusted leaf MAY request a bounded batch of exact keys after one live status or execution-guard check, but that projection MUST NOT cache safety facts or become a bulk-value Harness route.

#### Scenario: Migrate an earlier schema in place
- **GIVEN** the target is a registered workspace with one uniquely resolved root `.uproject`
- **WHEN** explicit bootstrap finds a valid schema v1 AgentConfig or a legacy `[Hardness]` schema-v2 AgentConfig in a registered workspace
- **THEN** it atomically writes `[Harness]` schema v3, removes legacy identity and obsolete Hazelight fields, rebinds ProjectFile, and preserves other user-controlled content
- **AND** the resulting managed identity records the exact WorkspaceRoot, PrimaryRoot, GitCommonDir, and target-local ProjectFile
- **BUT** ordinary status, read, and execution routes reject legacy-only state and do not migrate or rewrite it implicitly

> Inputs: The target workspace's existing `AgentConfig.ini`, its live Git-derived identity, its unique root project file, and machine-shared values from the canonical primary configuration when available.
>
> Observables: The current `[Harness]` section reports schema version 3, removed keys are absent, the ProjectFile points into the selected root, and unrelated sections, values, and comments remain.
>
> Boundaries: Bootstrap is the only migration writer; it does not move the worktree, change its branch or HEAD, or manufacture missing consumer configuration.
>
> Verification: Workspace configuration fixtures cover legacy-only rejection, v1 and `[Hardness]` v2 migration, removed identity and Hazelight keys, ProjectFile rebinding, preserved custom content, and absence of the old section.

#### Scenario: Query or update local configuration
- **GIVEN** the caller identifies one exact registered workspace and its workspace-owned root `AgentConfig.ini`
- **WHEN** a caller uses configuration status/get/set
- **THEN** status avoids bulk value disclosure and reports stale managed or removed keys, get reads one exact key, set atomically updates one non-managed key, and unrelated content remains unchanged
- **BUT** an attempt to overwrite managed identity, recreate an obsolete key, or inject multiline or NUL data fails before the configuration bytes are changed

> Inputs: The exact workspace root and, for get or set, one explicit section and key plus one single-line value when writing.
>
> Observables: Status reports readiness and exact diagnostics without returning all values; get reports only the selected key; a successful set changes only the selected non-managed value.
>
> Boundaries: A custom path cannot bypass workspace ownership, and generic mutation cannot alter SchemaVersion, WorkspaceRoot, PrimaryRoot, GitCommonDir, or ProjectFile.
>
> Verification: Workspace configuration fixtures compare requested values and preserved content and exercise managed-field, obsolete-key, and malformed-value rejection.

#### Scenario: Project configuration for a trusted leaf
- **GIVEN** a trusted leaf supplies an explicit bounded list of section and key pairs for one selected workspace operation
- **WHEN** a leaf needs several exact values for one operation
- **THEN** workspace lifecycle performs one fresh status or execution guard, returns at most 64 requested entries, and does not cache identity, configuration bytes, authorization, or mutation preconditions
- **BUT** the projection does not return unrequested values or become a generic bulk-configuration Harness route

> Inputs: The exact WorkspaceRoot, no more than 64 requested section/key pairs, and the operation's choice of fresh status or strict execution guard.
>
> Observables: The result contains the freshly validated workspace identity and one result for each requested key, including explicit missing-value state where applicable.
>
> Boundaries: Only immutable module paths and safely bounded discovery facts may be reused; configuration bytes and every safety-sensitive decision are read live for the operation.
>
> Verification: Workspace configuration-projection fixtures compare the returned identity and exact requested values against the selected workspace.

### Requirement: Workspace-sensitive execution guard

Before a workspace-sensitive command starts, the requested project root, registered Git worktree, Git common directory, AgentConfig v3 identity, configured `.uproject`, optional Harness session selection, and discoverable caller workspace MUST agree. A custom configuration path MUST NOT bypass the workspace-owned AgentConfig. A mismatch SHALL fail before launching an external tool. Read-only discovery across registered worktrees SHALL remain available.

#### Scenario: Refuse a cross-workspace launch
- **GIVEN** the process-local Harness selection identifies one registered physical WorkspaceRoot
- **WHEN** a process selected for one WorkspaceRoot attempts to start work against another root
- **THEN** the guard reports both exact roots and launches no external build, test, or commandlet process
- **BUT** the mismatch does not prevent read-only discovery of other worktrees registered in the same Git common directory

> Inputs: The requested project root, Git registration and common directory, workspace-owned AgentConfig v3 identity, configured ProjectFile, optional process selection, and discoverable caller root.
>
> Observables: Failure identifies the selected and requested physical roots and returns before control reaches the external operation.
>
> Boundaries: An alternate configuration path, mapped alias, inferred Goal, or caller location cannot override a conflicting registered physical identity.
>
> Verification: Workspace lifecycle fixtures select a linked worktree, attempt to target the primary checkout, and assert the exact execution guard fails before launch.

### Requirement: Git-derived workspace discovery and status tiers

Workspace context MUST be derived from Git registration and SHALL expose `SchemaVersion`, `HarnessRoot`, `WorkspaceRoot`, `PrimaryRoot`, `GitCommonDir`, `Topology`, `WorktreeName`, `Branch`, `Head`, and `Managed`. `Topology` is only `Primary` or `Worktree`; `Managed` states whether exact AgentConfig v3 identity is present and MUST NOT decide whether a registered worktree is valid. `HarnessRoot` identifies the checkout supplying the loaded Harness implementation, while `WorkspaceRoot` identifies the command target. `workspace.list` SHALL enumerate all worktrees registered in the same common directory. Default `workspace.status` SHALL return identity, registration, branch/HEAD, and configuration readiness without dirty or recursive submodule scans; explicit detailed status SHALL add current parent/submodule state.

#### Scenario: Target a workspace from another checkout
- **WHEN** Harness is loaded from the primary checkout and a registered linked worktree is selected
- **THEN** HarnessRoot remains the primary checkout, WorkspaceRoot is the linked root, and all leaf defaults target WorkspaceRoot

#### Scenario: List heterogeneous worktrees
- **WHEN** registered worktrees exist outside `.worktrees/` or use branches without a standard prefix
- **THEN** `workspace.list` returns each actual root, topology, WorktreeName, branch, HEAD, and managed state without rejecting or renaming it

#### Scenario: Request fast status
- **GIVEN** the target is an exact Git-registered workspace and the caller has not explicitly requested detailed status
- **WHEN** a caller or hook invokes default `workspace.status`
- **THEN** no `git status`, ignored-file inventory, or recursive submodule dirty scan runs
- **AND** the result still reports identity, registration, topology, branch, HEAD, managed configuration readiness, and `DetailLevel` as `Fast`
- **BUT** the result does not expose dirty, change, ignored-file, or submodule fields as though those expensive facts had been inspected

> Context: Fast status is suitable for repeated Harness entry, session, and optional hook feedback.
>
> Observables: The response identifies its `Fast` cost tier and contains only the bounded identity and readiness surface.
>
> Boundaries: Fast status neither guesses expensive state nor silently upgrades itself to a detailed scan.
>
> Verification: Workspace status fixtures inspect Git trace output and assert that default status invokes neither `git status` nor recursive submodule inspection.

#### Scenario: Request detailed status
- **GIVEN** the caller explicitly accepts the more expensive live repository inspection
- **WHEN** a caller explicitly selects detailed status
- **THEN** current parent, gitlink, submodule, ignored-payload, and configuration diagnostics are returned and are labeled as the more expensive view
- **AND** malformed submodule configuration is reported explicitly instead of being treated as a clean or absent submodule state

> Inputs: One exact registered WorkspaceRoot and the explicit detailed-status selection.
>
> Observables: The response identifies `DetailLevel` as `Detailed` and reports current parent changes, initialized top-level submodule state, ignored workspace payload, configuration diagnostics, and applicable baseline information.
>
> Boundaries: These values are a current live diagnostic snapshot and do not become cached authorization or mutation preconditions.
>
> Verification: Detailed-status fixtures cover dirty parent content, top-level submodule diagnostics, ignored payload, and malformed `.gitmodules` data.

### Requirement: Primary-main AngelScript baseline alignment

For a selected parent workspace whose checked-out branch is exactly `main`, Harness SHALL resolve the initialized `Plugins/Angelscript` checkout and its latest known main baseline before workspace-sensitive execution. The baseline SHALL be the local `refs/heads/main` tip when present, otherwise the fetched `refs/remotes/origin/main` tip. The plugin HEAD MUST equal that baseline, and when both refs exist the local main MUST contain the fetched origin/main tip. A mismatch SHALL fail before Unreal or another external workspace-sensitive process launches.

Harness MUST NOT fetch, checkout, merge, reset, commit, or push as a status or execution-guard side effect. Detailed workspace status SHALL expose the compared refs and alignment result. Parent branches other than `main`, including registered feature worktrees, SHALL remain exempt so they can deliberately build plugin feature commits.

#### Scenario: Reject a local main behind the fetched remote
- **GIVEN** the selected parent workspace is on `main` and its initialized AngelScript checkout has both local-main and fetched-origin-main references
- **WHEN** both main refs exist and fetched origin/main is not contained by local main
- **THEN** Harness reports the divergent refs and rejects execution without mutating either repository
- **AND** detailed status exposes the compared plugin HEAD, local main, fetched origin/main, selected baseline source, and failed alignment result
- **BUT** the guard does not fetch, checkout, merge, reset, commit, or push in an attempt to repair the mismatch

> Inputs: The selected parent branch, initialized plugin HEAD, `refs/heads/main`, and the already fetched `refs/remotes/origin/main`.
>
> Observables: Alignment is false, both divergent references are reported, and workspace-sensitive execution stops before Unreal or another external process is launched.
>
> Boundaries: The result is based only on existing local and fetched references; network refresh and repository repair require separate explicit authority.
>
> Verification: Baseline fixtures advance fetched origin/main beyond local main and assert that detailed status reports misalignment and the execution guard rejects launch without repository mutation.
