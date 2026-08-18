## ADDED Requirements

### Requirement: TypeInfo expand and apply are separately observable

When the runtime is built with `WITH_DEV_AUTOMATION_TESTS` or `AS_PRINT_STATS`, TypeInfo expansion and Engine TypeInfo apply SHALL record distinct observation passes. Expansion SHALL record per-provider duration and record pass (`Explicit`, `Generated`, `Reflection`, `PostReflection`, or unmigrated original phase). Apply SHALL record per-type duration using `FAngelscriptTypeBindInfo::AngelscriptTypeName`. Existing `CallBinds` / `ExecuteRegisteredBinds` observation SHALL remain for `ReplayOnly` providers.

#### Scenario: Expand pass is queryable after seal

- **WHEN** a `WITH_DEV_AUTOMATION_TESTS` build finishes TypeInfo expansion
- **THEN** observation exposes one expand entry per executed provider with name, record pass, and non-negative duration
- **AND** that collection is distinct from a later engine apply pass

#### Scenario: Apply pass is queryable after engine bind

- **WHEN** an engine applies sealed TypeInfo
- **THEN** observation exposes apply entries keyed by type name, not by bind-provider lambda name
- **AND** `ReplayOnly` providers still appear in the provider-replay observation

#### Scenario: Shipping without stats has no expand/apply timers

- **WHEN** the runtime is built without `WITH_DEV_AUTOMATION_TESTS` and without `AS_PRINT_STATS`
- **THEN** TypeInfo expand and apply do not allocate per-provider or per-type timing storage
