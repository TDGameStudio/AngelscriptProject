## ADDED Requirements

### Requirement: Fresh standalone UnrealEvent repository

The system SHALL provide a standalone `UnrealEventPlugin` git repository initialized from the GMP source snapshot without importing the upstream GMP git history.

#### Scenario: Repository is initialized from GMP snapshot

- **WHEN** the standalone repository is inspected
- **THEN** it contains the GMP-derived plugin source snapshot under the UnrealEvent repository identity
- **AND** its git history starts from a fresh UnrealEvent initial commit rather than the upstream GMP commit graph

### Requirement: GMP attribution and license preservation

The standalone repository SHALL preserve Apache 2.0 license obligations for GMP-derived source.

#### Scenario: License metadata is present

- **WHEN** the standalone repository is inspected
- **THEN** it includes the Apache 2.0 license text
- **AND** it includes notice text identifying GenericMessagePlugin/GMP as the source of derived portions

### Requirement: Host project consumes UnrealEvent as submodule

`AngelscriptProject` SHALL consume the standalone UnrealEvent repository as a plugin submodule at `Plugins/UnrealEvent`.

#### Scenario: Submodule is configured

- **WHEN** the host repository submodule metadata is inspected
- **THEN** `.gitmodules` maps `Plugins/UnrealEvent` to `git@github.com:TDGameStudio/UnrealEventPlugin.git`
- **AND** the host worktree contains a pinned `Plugins/UnrealEvent` submodule checkout

### Requirement: Bootstrap excludes runtime pruning

The bootstrap SHALL avoid implementing GMP feature pruning or UnrealEvent runtime behavior changes.

#### Scenario: Bootstrap scope is checked

- **WHEN** the change is reviewed
- **THEN** it only establishes repository, license, plugin identity, submodule, and setup documentation boundaries
- **AND** runtime API redesign, Blueprint/editor/script integration, serializer removal, MessageTags removal, and AngelScript bindings remain deferred
