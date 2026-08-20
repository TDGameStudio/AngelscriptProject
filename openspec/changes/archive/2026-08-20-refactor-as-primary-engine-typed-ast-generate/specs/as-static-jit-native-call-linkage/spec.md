## ADDED Requirements

### Requirement: Native-form recipes live in a process-global catalog

Reviewed native-form recipes and native-call descriptors SHALL be recorded in a process-lifetime catalog keyed by stable declaration identity and bind-surface/target profile. The catalog SHALL be filled as a side effect of sealed Bind replay into an Engine, not at static-init and not instead of per-Engine registration. Generate and matching-profile TypedASTJIT lookup SHALL use that catalog. `bCollectStaticJITCompatibilityBinds` MAY still attach per-Engine forms for compatibility. A matching-profile primary Engine MUST NOT require a sibling generation Engine solely to collect binds.

#### Scenario: Catalog fills on bind replay, not instead of it

- **WHEN** an Engine executes the sealed Bind collection
- **THEN** each lambda still registers types and functions into that Engine's `asIScriptEngine`
- **AND** reviewed native-call recipes observed during that replay are upserted into the catalog by declaration identity plus bind-surface
- **AND** a later Engine in the same process still replays the lambdas to obtain its own registrations

#### Scenario: Matching-profile Generate uses catalog without collect flag

- **WHEN** the primary Editor Engine has `bCollectStaticJITCompatibilityBinds=false` but the catalog contains a reviewed HeaderInline descriptor for a reachable call on that bind-surface
- **THEN** TypedASTJIT may emit the reviewed direct form
- **AND** missing catalog entries still degrade to bridge or typed fallback

#### Scenario: Display name is still not DLL-linkable

- **WHEN** a catalog entry has a native-form display name but no reviewed linkage contract
- **THEN** emit MUST NOT treat the display name as a cross-DLL symbol
- **AND** the existing HeaderInline versus module-exported distinction remains in force

#### Scenario: Headers are stored on the recipe

- **WHEN** bind replay observes `.NativeFunctionHeader` or a reviewed descriptor with `Include`
- **THEN** the catalog stores that header path with the declaration key and bind-surface
- **AND** Generate emits the include only for recipes that actually lower to a direct call
- **AND** `.NativeFunction` without a header or Include does not invent an `#include`
