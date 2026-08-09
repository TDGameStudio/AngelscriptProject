## ADDED Requirements

### Requirement: Compact bind callable implementations are colocated with their registrar

For the fixed compact-provider inventory, non-template `FAngelscript<Name>Binds` callable definitions SHALL live in the same `Bind_<Name>.cpp` file as their `FAngelscriptBind` registrar, after that file's final registrar definition. The migration SHALL preserve the callable owner name, declaration string, C++ signature, registration order, bind phase, and native/trivial classification.

#### Scenario: A selected compact provider is migrated

- **WHEN** a provider appears in the compact-provider inventory
- **THEN** its `_Functions.cpp` file SHALL be removed and its existing named callable definitions SHALL appear after the final `FAngelscriptBind` definition in `Bind_<Name>.cpp`

#### Scenario: A provider has a sibling type implementation

- **WHEN** `Bind_<Name>_Type.cpp` consumes the callable owner declaration
- **THEN** `Bind_<Name>.h` SHALL remain the declaration owner while the callable bodies move into `Bind_<Name>.cpp`

### Requirement: High-complexity geometry callable companions remain separate

The designated vector, integer-vector, quaternion, rotator, and transform families SHALL retain their existing `_Functions.cpp` and canonical header organization in this change, regardless of their current implementation line count.

#### Scenario: A short vector companion is encountered

- **WHEN** a designated high-complexity geometry family has a `_Functions.cpp` shorter than 100 lines
- **THEN** the change SHALL retain its companion file and SHALL NOT move its definitions into the registrar cpp

### Requirement: Physical source layout is not tested through UE Automation

The plugin SHALL NOT retain a UE Automation test whose contract is the physical placement of bind callable definitions, provider lambda spelling, canonical header naming, or fluent-chain line wrapping. Bind behavior SHALL continue to be validated by behavior-owning test suites.

#### Scenario: The compact-provider refactor is verified

- **WHEN** implementation is ready for validation
- **THEN** validation SHALL use the plugin build, existing Binding CQTests, and StaticJIT AOT coverage without adding a replacement source-layout automation test
