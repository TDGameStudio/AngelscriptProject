## MODIFIED Requirements

### Requirement: Cooked bind-database BlueprintCallable fallback has complete signature types

BlueprintCallable binding SHALL populate reflection fallback signature type data in cooked `AS_USE_BIND_DB` builds when a generated function-table entry has no direct native pointer. The direct-bind fast path SHALL remain able to use bind-database declarations without eagerly initializing type arrays.

#### Scenario: Cooked stub entry falls back with valid types

- **WHEN** `AS_USE_BIND_DB` is enabled and a BlueprintCallable generated function-table entry has no direct native pointer
- **THEN** the binding path initializes `ArgumentTypes`, `ArgumentNames`, `ReturnType`, and `bAllTypesValid` from the `UFunction` before calling `BindBlueprintCallableReflectionFallback`
- **AND** a function with representable reflected parameter and return types can bind through reflection fallback

#### Scenario: Cooked direct-bind entry remains on the fast path

- **WHEN** `AS_USE_BIND_DB` is enabled and a BlueprintCallable generated function-table entry has a direct native pointer
- **THEN** the binding path does not require eager reflection type initialization before choosing the direct-bind branch
- **AND** existing direct-bind registration behavior is preserved

#### Scenario: Unsupported reflected type remains rejected

- **WHEN** the fallback type initialization sees a UFunction parameter or return property that cannot be represented as an Angelscript type
- **THEN** `bAllTypesValid` is false
- **AND** the reflection fallback rejects the function instead of registering an invalid call bridge
