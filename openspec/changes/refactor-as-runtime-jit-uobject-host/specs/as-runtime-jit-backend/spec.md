## MODIFIED Requirements

### Requirement: Runtime backends register current-revision factories

`AngelscriptRuntime` SHALL discover Runtime JIT factories from the `UAngelscriptRuntimeJIT` catalog. Runtime SHALL copy and validate stable BackendId, ABI revision, platform/configuration support, and compile-concurrency metadata before it creates an Engine-local session. `IModularFeatures` `IAngelscriptRuntimeJITBackendFactory` MAY remain as a temporary lookup fallback until in-tree tests use UObject fakes; the coordinator MUST NOT require it once a matching UObject backend exists.

#### Scenario: Compatible backend is selected

- **WHEN** one cataloged UObject backend exactly matches the requested BackendId, current ABI revision, platform, and configuration, and `IsAvailable()` is true
- **THEN** the coordinator creates one backend session for that Engine
- **AND** it does not retain a transient factory metadata view after validation

#### Scenario: Backend ABI is incompatible

- **WHEN** the selected factory reports an unknown ABI revision or invalid capability metadata
- **THEN** Runtime rejects it before requesting compilation
- **AND** execution remains available through Static AOT or VM

#### Scenario: UObject catalog wins over modular feature

- **WHEN** the same BackendId is advertised by a `UAngelscriptRuntimeJIT` subclass and by an `IModularFeatures` factory
- **THEN** the coordinator uses the UObject `CreateSession` path
- **AND** it does not create a second session from the modular feature
