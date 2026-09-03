## ADDED Requirements

### Requirement: Harness configuration schema migration

New and repaired workspace configuration SHALL use a single `[Harness]` section with `SchemaVersion=3`. `workspace.bootstrap` SHALL be the only operation that migrates a valid legacy `[Hardness]` `SchemaVersion=2` section: it MUST preserve managed values, comments, paths, and unrelated sections, write the new section, and remove the legacy section. Normal workspace and execution operations MUST reject a legacy-only configuration until bootstrap repairs it.

Workspace activation SHALL set only `HARNESS_WORKSPACE_ROOT`, `HARNESS_PRIMARY_ROOT`, and `HARNESS_GIT_COMMON_DIR` for the selected process and SHALL clear the corresponding `HARDNESS_*` variables so stale process state cannot select the workspace.

#### Scenario: Bootstrap a legacy workspace
- **WHEN** bootstrap encounters a valid `[Hardness]` schema-v2 configuration for the selected workspace
- **THEN** it atomically produces the equivalent `[Harness]` schema-v3 configuration, preserves non-managed content, and removes the old section

#### Scenario: Reject legacy state before repair
- **WHEN** a normal workspace or execution route encounters a legacy-only `[Hardness]` section
- **THEN** it fails with an explicit bootstrap-required diagnostic and does not rewrite the file

#### Scenario: Activate the renamed workspace environment
- **WHEN** the caller activates a valid Harness workspace
- **THEN** current `HARNESS_*` values identify it and any inherited `HARDNESS_*` workspace variables are removed
