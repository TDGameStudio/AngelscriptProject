## Purpose

Publish process IDs against UE BindInfo class records before Engine TypeInfo exists, materialize unique TypeInfo per receiving Engine, and expose host class-info queries without granting Engine admission.

## ADDED Requirements

### Requirement: Script compile transfers TypeInfo through a definition set

The SDK SHALL create script TypeInfo during engine-free compile on `asCModuleDefinitionSet`, and SHALL transfer unique ownership to one receiving Engine only through `asCEngineCompileRegistration`.

#### Scenario: Install a compiled set into one Engine

- **GIVEN** a Taken `asCModuleDefinitionSet` whose script TypeInfo report null Engine and TypeId -1
- **WHEN** `asCEngineCompileRegistration` Registers that UniquePtr list on Engine A
- **THEN** those TypeInfo pointers are the same objects, now reporting Engine A and a TypeId greater than `asTYPEID_LAST_PRIMITIVE`

    The UniquePtr list is consumed. The set is no longer the unique owner.

- **BUT** Engine B cannot obtain A's TypeInfo pointers from its queries

#### Scenario: Reject a partial batch

- **GIVEN** two Taken sets where the second set's identities conflict with types already on the Engine
- **WHEN** Registration is asked to Install+Link both in one call
- **THEN** the call fails and no script function from that submitted list is callable

    Engine types that existed before the call remain. The failed list does not leave a subset of its functions Prepare-able.

- **AND** Install and Link are not separately observable public operations
