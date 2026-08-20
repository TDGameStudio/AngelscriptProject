## ADDED Requirements

### Requirement: Compiled Runtime functions are named by owning handles

The coordinator SHALL expose each successful Runtime compile as a copyable `FAngelscriptRuntimeJITFunctionHandle`. The handle SHALL carry pointer-free identity (BackendId, EngineNamespace, PublicationOrdinal, FunctionKey, FunctionRevision, EntryAbiHash) and SHALL keep the executable-code lease and backend session alive while any copy remains. Host APIs for cache lookup, dispatch, compare, and events SHALL take or return handles. They SHALL NOT return a raw `asJITFunction` for callers to store. A handle SHALL NOT be a UObject, SHALL NOT be a `UPROPERTY` / Blueprint type, and SHALL NOT be stored in ini.

#### Scenario: Two warm compiles produce two handles

- **WHEN** `fake-alpha` and `fake-beta` both compile the same function revision
- **THEN** the coordinator holds two valid handles that share FunctionKey and PublicationOrdinal but differ in BackendId
- **AND** dropping the cache entry for one handle does not invalidate the other

#### Scenario: Dispatch uses a handle

- **WHEN** a valid `fake-beta` handle exists for the current function revision
- **THEN** switching dispatch attaches that handle’s Binding
- **AND** the previous `fake-alpha` handle remains valid if it is still warm or held by a Binding reader

#### Scenario: Retired handle keeps executing readers alive

- **WHEN** a function is replaced and its old handles are removed from the warm cache
- **THEN** a Binding still executing on the old handle remains callable until that reader exits
- **AND** a later lookup of that FunctionKey plus old PublicationOrdinal does not return a new valid handle

#### Scenario: Invalid handle cannot dispatch

- **WHEN** a handle’s artifact has been fully released
- **THEN** `IsValid()` is false
- **AND** dispatch refuses that handle and leaves the current Binding unchanged
