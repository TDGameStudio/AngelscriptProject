# as-hotreload-property-coverage Specification

## Purpose
TBD - created by archiving change test-hotreload-property-coverage-expansion. Update Purpose after archive.
## Requirements
### Requirement: Property Hot Reload Tests Cover Soft And Full Reload Behavior

Property hot reload coverage SHALL verify externally observable behavior for both soft reload and full reload paths, not only compile success.

#### Scenario: Soft reload updates executable behavior without replacing class layout

- **GIVEN** an AS class with a generated `UClass` and executable member/global functions
- **WHEN** the module is recompiled through a soft reload with only function body changes
- **THEN** the generated `UClass` remains the same object
- **AND** existing and newly created objects execute the updated function body
- **AND** unrelated modules remain callable with their original behavior

#### Scenario: Full reload replaces reflected property layout

- **GIVEN** an AS class compiled with reflected properties and defaults
- **WHEN** the module is recompiled through a full reload after property layout, type, enum, or specifier changes
- **THEN** the replacement class exposes the new reflected layout
- **AND** old classes retain their old reflected layout
- **AND** newly created objects use the updated defaults

#### Scenario: Failed full reload does not publish rejected layout

- **GIVEN** a successfully compiled AS class
- **WHEN** a later full reload fails to compile
- **THEN** the previously active generated class remains active
- **AND** rejected properties/defaults are not visible on the active class

#### Scenario: Parent and child AS classes reload together

- **GIVEN** an AS class hierarchy where both parent and child classes are replaced during the same full reload
- **WHEN** the parent property layout changes
- **THEN** the reloaded child derives from the reloaded parent
- **AND** the child inherits added parent properties
- **AND** the child CDO and newly created child instances keep child defaults.

