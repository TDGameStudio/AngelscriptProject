# hotreload-test-coverage Specification

## Purpose
TBD - created by archiving change test-hotreload-coverage-expansion. Update Purpose after archive.
## Requirements
### Requirement: HotReload decision changes are covered by automation
The test suite SHALL include HotReload automation cases for representative non-UPROPERTY edit categories that influence soft/full reload decisions.

#### Scenario: Non-UPROPERTY edit category changes
- **WHEN** a script module is recompiled with changes to function defaults, function metadata, function flags, function additions, default statements, class metadata, or class flags
- **THEN** automation reports the expected reload decision and whether a full reload is suggested or required

### Requirement: Blueprint child soft reload safety is covered by automation
The test suite SHALL include a HotReload regression where a Blueprint-generated child of an AngelScript class survives a parent soft reload.

#### Scenario: Blueprint child of script parent is soft reloaded
- **WHEN** a Blueprint child and actor instance exist before a body-only soft reload of the AngelScript parent
- **THEN** the reload completes without treating the Blueprint generated class as a `UASClass`, and the existing actor can execute the updated parent function

