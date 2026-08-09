## MODIFIED Requirements

### Requirement: Direct registration calls return chainable bound results

Function-like binding calls SHALL return a copyable short-lived `FAngelscriptBoundFunction` identifying the explicit engine and exact registered function. Property-like binding calls SHALL return a copyable short-lived `FAngelscriptBoundProperty` identifying the explicit engine and exact registered property. Neither value SHALL act as a process provider handle or extend the lifetime of its target engine. Discarding the value SHALL remain valid.

#### Scenario: Method registration returns a function result

- **WHEN** a typed class view directly registers a method
- **THEN** the returned `FAngelscriptBoundFunction` identifies that method's engine and registration result
- **AND** it does not consult an engine-wide previous-function slot

#### Scenario: Property registration returns a property result

- **WHEN** a typed class view directly registers a property
- **THEN** the returned `FAngelscriptBoundProperty` identifies that property's engine and registration result
- **AND** it does not consult a previous-global-property slot

#### Scenario: Return value is discarded

- **WHEN** an author does not need traits or metadata and ignores the returned value
- **THEN** registration remains complete and valid

### Requirement: Chainable options mutate the exact direct result

`FAngelscriptBoundFunction` SHALL expose applicable function traits formerly supplied by PreviousBind helpers, documentation helpers, and native-form helpers. `FAngelscriptBoundProperty` SHALL expose applicable property metadata and pure-constant behavior. Each fluent method SHALL mutate only its stored direct result and SHALL return the same result value for further chaining.

Applicable behavior includes editor-only, deprecation, property accessor, no-discard, world context, callable/generated accessor, implicit constructor, compile-out forms, forced-const arguments, output-type selection, script-function/object first-parameter behavior, documentation, native/trivial metadata, and pure-constant property data.

#### Scenario: Single chained trait

- **WHEN** an author writes `FVector_.Method(...).NoDiscard()`
- **THEN** only the newly registered method receives the no-discard trait

#### Scenario: Multiple traits and documentation

- **WHEN** an author chains `.EditorOnly().Deprecated(...).Documentation(...)`
- **THEN** all options apply to the same function result in source order
- **AND** an intervening registration elsewhere cannot redirect them

#### Scenario: Property pure constant

- **WHEN** an author chains `.PureConstant(Value)` from a direct property registration
- **THEN** only that property's engine-owned metadata receives the encoded constant

#### Scenario: Interleaved engines

- **WHEN** two engines register equivalent functions and their bound-result values coexist temporarily
- **THEN** each fluent call mutates only the engine stored by its own value

### Requirement: Invalid direct results preserve fail-closed initialization

When direct registration fails, the returned bound-result value SHALL be invalid and SHALL retain access to the binding context's first failure. Fluent calls on that value SHALL NOT fall back to another function/property or create a second error that hides the original failure.

#### Scenario: Registration fails before a trait

- **WHEN** AngelScript rejects a declaration and the provider chains `.NoDiscard()`
- **THEN** the original declaration error remains the active failure
- **AND** no other registered function receives the trait
- **AND** engine publication is rejected

### Requirement: Direct trait semantics preserve baseline behavior

For the same provider source and engine inputs, the completed direct API SHALL preserve script-visible declarations, callable behavior, compiler traits, deprecation messages, documentation, native/StaticJIT forms, global-property constant values, and `Binds.Cache` behavior. Raw AS registration ids and obsolete callback/order observation formats are not required to be identical.

#### Scenario: Type and function surface is unchanged

- **WHEN** pre/post engine-state observations are compared after migration
- **THEN** declarations and applicable function/property traits match except for explicitly documented architecture-only observation changes

#### Scenario: Binds cache contract is unchanged

- **WHEN** direct callbacks read or write `Binds.Cache` through the explicit engine database
- **THEN** its schema and reflected binding behavior remain compatible

## REMOVED Requirements

### Requirement: Legacy free-function PreviousBind setters remain functional

**Reason**: PreviousBind APIs target an implicit most-recent registration and are unnecessary once direct calls return exact engine-bound results.

**Migration**: Chain the equivalent option directly from `Method`, constructor, behaviour, global-function, or property calls returning `FAngelscriptBoundFunction` or `FAngelscriptBoundProperty`.

#### Scenario: Completed migration has no PreviousBind state

- **WHEN** production migration is complete
- **THEN** source contains no `PreviouslyBoundFunction`, `PreviouslyBoundGlobalProperty`, `GetPreviousBind*`, `SetPreviousBind*`, `DeprecatePreviousBind`, or `CompileOutPreviousBind*` dependency
- **AND** tests target direct bound-result behavior
