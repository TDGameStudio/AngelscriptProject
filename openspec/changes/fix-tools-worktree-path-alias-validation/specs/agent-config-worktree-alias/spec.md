# agent-config-worktree-alias Specification

## Purpose

Worktrees are commonly reached through a short path alias — a directory junction or a `subst` drive — because the full `.worktrees\<change-name>\` path exceeds what UnrealBuildTool tolerates at MAX_PATH. This capability defines how the shared tooling resolves `AgentConfig.ini` when a worktree therefore has more than one valid path, so that any name works for validation while the configured short path remains the one used for execution.

## ADDED Requirements

### Requirement: Alias-tolerant project file validation

Agent configuration resolution SHALL accept a configured `Paths.ProjectFile` that names the same directory as the entry path through a directory junction, a symbolic link, or a `subst` drive mapping.

#### Scenario: Worktree entered through its junction alias

- **WHEN** `AgentConfig.ini` sets `Paths.ProjectFile` to `D:\as-cta\AngelscriptProject.uproject`
- **AND** a maintainer runs a tooling entry point from `D:\as-cta`
- **THEN** configuration resolution succeeds

#### Scenario: Worktree entered through its full path

- **WHEN** `AgentConfig.ini` sets `Paths.ProjectFile` to a short alias of the worktree
- **AND** a maintainer runs a tooling entry point from the full `.worktrees\<name>` path that the alias targets
- **THEN** configuration resolution succeeds, because both names resolve to the same directory

#### Scenario: Worktree reached through a subst drive

- **WHEN** the worktree is mapped to a drive letter with `subst`
- **AND** either the drive-letter path or the target path is used as the entry point
- **THEN** configuration resolution succeeds for both

#### Scenario: Project file names a different directory

- **WHEN** `Paths.ProjectFile` resolves to a directory that is not the entry worktree by any alias
- **THEN** configuration resolution fails with a configuration error

#### Scenario: Path canonicalization is unavailable

- **WHEN** the canonical form of a path cannot be determined
- **THEN** resolution falls back to comparing normalized path strings rather than failing outright

### Requirement: Configured path is authoritative for execution

Resolved configuration SHALL report the project file exactly as configured, so that a worktree configured with a short alias continues to build through that alias regardless of which name the session entered by.

#### Scenario: Alias survives validation

- **WHEN** configuration resolution succeeds for a worktree configured with a short alias
- **THEN** the resolved project file is the configured alias path, not the canonical full path

#### Scenario: Build command uses the configured path

- **WHEN** a build is launched for a worktree configured with a short alias
- **AND** the session entered through the full `.worktrees\<name>` path
- **THEN** the build receives the short alias path
- **AND** the build does not fail from exceeding the maximum supported path length

### Requirement: Actionable mismatch diagnosis

A rejected configuration SHALL report enough detail to distinguish a genuine misconfiguration from an alias mismatch, and SHALL NOT recommend a remedy that discards a working configuration.

#### Scenario: Genuine misconfiguration is reported

- **WHEN** resolution fails because the configured project file belongs to a different directory
- **THEN** the error names the configured value, the entry root, and the resolved form of each

#### Scenario: Remedy does not destroy an alias configuration

- **WHEN** resolution fails for a worktree whose configuration points at a short alias
- **THEN** the error does not instruct the maintainer to re-run worktree bootstrap as the remedy

### Requirement: Idempotent worktree bootstrap

Re-running worktree bootstrap SHALL preserve an existing `Paths.ProjectFile` that already resolves to the worktree being bootstrapped.

#### Scenario: Re-bootstrap from the full path

- **WHEN** a worktree's `AgentConfig.ini` sets `Paths.ProjectFile` to a short alias
- **AND** bootstrap is re-run for that worktree using its full path
- **THEN** the existing alias value is preserved

#### Scenario: Stale project file is replaced

- **WHEN** an existing `Paths.ProjectFile` no longer resolves to the worktree being bootstrapped
- **THEN** bootstrap replaces it with a project file resolved from that worktree

#### Scenario: Missing project file is populated

- **WHEN** an existing configuration has no `Paths.ProjectFile`
- **THEN** bootstrap resolves and writes one for that worktree
