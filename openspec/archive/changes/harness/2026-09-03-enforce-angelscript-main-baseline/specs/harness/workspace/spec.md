## ADDED Requirements

### Requirement: Primary-main AngelScript baseline alignment

For a selected parent workspace whose checked-out branch is exactly `main`, Harness SHALL resolve the initialized `Plugins/Angelscript` checkout and its latest known main baseline before workspace-sensitive execution. The baseline SHALL be the local `refs/heads/main` tip when present, otherwise the fetched `refs/remotes/origin/main` tip. The plugin HEAD MUST equal that baseline, and when both refs exist the local main MUST contain the fetched origin/main tip. A mismatch SHALL fail before Unreal or another external workspace-sensitive process launches.

Harness MUST NOT fetch, checkout, merge, reset, commit, or push as a status or execution-guard side effect. Detailed workspace status SHALL expose the compared refs and alignment result. Parent branches other than `main`, including registered feature worktrees, SHALL remain exempt so they can deliberately build plugin feature commits.

#### Scenario: Execute the integrated main baseline
- **WHEN** the selected parent branch is `main`, the plugin HEAD equals local main, and fetched origin/main is an ancestor of local main
- **THEN** Harness reports the AngelScript baseline aligned and permits workspace-sensitive execution

#### Scenario: Reject an intermediate plugin commit
- **WHEN** the selected parent branch is `main` but `Plugins/Angelscript` HEAD is behind the latest known main baseline
- **THEN** Harness reports both commits and rejects execution before launching Unreal

#### Scenario: Reject a local main behind the fetched remote
- **WHEN** both main refs exist and fetched origin/main is not contained by local main
- **THEN** Harness reports the divergent refs and rejects execution without mutating either repository

#### Scenario: Preserve feature-worktree development
- **WHEN** the selected parent branch is not `main`
- **THEN** Harness does not impose the primary-main plugin baseline gate and existing exact workspace and submodule policies continue to apply
