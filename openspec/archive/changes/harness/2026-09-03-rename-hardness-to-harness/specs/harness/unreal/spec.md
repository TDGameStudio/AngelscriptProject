## ADDED Requirements

### Requirement: Harness Unreal API and registry migration

The Unreal development module SHALL expose Harness-named PowerShell symbols and use `%LOCALAPPDATA%/TDGameStudio/Harness/Unreal/DriveAssignments.json` as the only current drive-assignment registry. `PlanOnly` operations MUST NOT create, move, or rewrite either current or legacy registry data. Before the first real registry-dependent Unreal operation, the module SHALL migrate a lone legacy `%LOCALAPPDATA%/TDGameStudio/Hardness/Unreal/DriveAssignments.json` under the normal registry lock. It MUST preserve the file contents and fail without overwrite when old and new registries conflict.

The current registry filename SHALL remain the stable unsuffixed `DriveAssignments.json`; implementation or record schema revisions MUST NOT leak into `v1` or `v2` filenames.

#### Scenario: Keep planning side-effect free
- **WHEN** an Unreal route runs with `PlanOnly`
- **THEN** neither the legacy nor current LocalAppData registry is moved, created, or rewritten

#### Scenario: Migrate a lone legacy registry
- **WHEN** the first real Unreal operation finds only the legacy Hardness registry
- **THEN** it moves the preserved registry to the Harness root under lock before using it

#### Scenario: Refuse a registry conflict
- **WHEN** both legacy and current registries exist with conflicting state
- **THEN** the real operation fails with both paths and does not overwrite or merge either file

#### Scenario: Keep the registry name stable
- **WHEN** registry payload or implementation schema revisions advance
- **THEN** the machine-local file remains `DriveAssignments.json` without a version suffix
