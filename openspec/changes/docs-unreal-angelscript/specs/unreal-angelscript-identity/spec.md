## ADDED Requirements

### Requirement: Product Identity Uses Unreal AngelScript
User-facing documentation MUST use `Unreal AngelScript` as the primary identity for the UE AngelScript plugin and language integration.

#### Scenario: User-facing overview describes the plugin
- **WHEN** documentation introduces the project, plugin, or integration to users
- **THEN** it uses `Unreal AngelScript` instead of presenting the runtime as plain `AS 2.33`

### Requirement: Runtime Version Uses Owned UEAS Label
Documentation that needs a runtime or fork version MUST use an owned `UEAS Runtime` label instead of using an upstream AngelScript version as the current runtime identity.

#### Scenario: Runtime version is documented
- **WHEN** documentation identifies the current fork/runtime version
- **THEN** it uses a `UEAS Runtime` label and does not claim the runtime is vanilla AngelScript 2.33 or 2.38

### Requirement: Upstream Lineage Remains Explicit
Technical documentation MUST preserve upstream provenance by describing the source lineage as `AngelScript 2.33-WIP lineage + selective 2.38 backports` or an equivalent wording that clearly separates lineage from current runtime identity.

#### Scenario: Fork strategy explains source provenance
- **WHEN** documentation discusses fork strategy, backports, or compatibility with upstream AngelScript
- **THEN** it preserves the 2.33 lineage and selective 2.38 backport context as technical metadata

### Requirement: Naming Change Does Not Rename Runtime Artifacts
The naming update MUST NOT rename plugin directories, Unreal modules, public APIs, automation test prefixes, serialization formats, generated asset paths, or config keys.

#### Scenario: Implementation applies naming documentation updates
- **WHEN** the change is implemented
- **THEN** only documentation and naming guidance are updated unless a later explicit OpenSpec change expands the scope

### Requirement: Documentation Validation Covers Legacy Labels
The implementation MUST include a grep-based documentation validation pass that identifies remaining `AS 2.33` and `AngelScript 2.33` wording and classifies each remaining occurrence as intentional lineage metadata or a follow-up cleanup item.

#### Scenario: Validation runs after documentation updates
- **WHEN** the documentation pass is complete
- **THEN** remaining legacy-version references are either replaced, justified as lineage metadata, or recorded for follow-up
