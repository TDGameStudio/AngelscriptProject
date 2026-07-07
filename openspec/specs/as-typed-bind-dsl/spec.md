# as-typed-bind-dsl Specification

## Purpose
TBD - created by archiving change refactor-as-typed-bind-dsl. Update Purpose after archive.
## Requirements
### Requirement: Typed class binding facade

The system SHALL provide a typed hand-written binding facade for C++ classes and structs that delegates to the existing `FAngelscriptBinds` backend.

#### Scenario: Binding a member method through the facade

- **GIVEN** a registered Angelscript type such as `FColor`
- **WHEN** a bind file calls `FAngelscriptBindClass<FColor>("FColor").Method("FString ToHex() const", &FColor::ToHex)`
- **THEN** the resulting script-visible method SHALL be registered through the same backend path as `FAngelscriptBinds::ExistingClass("FColor").Method("FString ToHex() const", &FColor::ToHex)`
- **AND** existing script code calling `FColor.ToHex()` SHALL continue to compile and run unchanged.

#### Scenario: Binding a class namespace static function

- **GIVEN** a C++ static or free function that should appear under an Angelscript class namespace
- **WHEN** a bind file calls `.StaticFunction("FColor FromHex(const FString& HexString) no_discard", &FColor::FromHex)` on `FAngelscriptBindClass<FColor>("FColor")`
- **THEN** the function SHALL be registered in the `FColor` namespace through the existing `FAngelscriptBinds::FNamespace` and `BindGlobalFunction` backend.

#### Scenario: Binding a property through the facade

- **GIVEN** a C++ data member or explicit offset
- **WHEN** a bind file calls `.Property("uint DWColor", &FColor::DWColor)` or the equivalent offset overload
- **THEN** the property SHALL be registered through the existing `FAngelscriptBinds::Property` backend.

### Requirement: Semi-typed declaration model

The typed DSL SHALL require C++ function/member pointers for typed registration while allowing explicit AS declaration strings in v1.

#### Scenario: Declaration string remains explicit

- **GIVEN** an AS declaration that contains parameter names, default values, or AS-only modifiers
- **WHEN** the typed DSL registers it
- **THEN** the DSL SHALL preserve the explicit declaration string rather than attempting full automatic declaration generation.

#### Scenario: Function traits identify callable shape

- **GIVEN** a free function, non-const member function, const member function, or supported captureless lambda
- **WHEN** `TAngelscriptFunctionTraits` is instantiated for that callable
- **THEN** tests SHALL be able to observe the expected callable category, return type, argument count, and const-member status.

### Requirement: Explicit overload support

The typed DSL SHALL support overloaded C++ functions through an explicit typed overload helper or equivalent typed cast API.

#### Scenario: Overloaded method binding is explicit

- **GIVEN** an overloaded C++ member function or operator
- **WHEN** a bind file registers one overload through the typed DSL
- **THEN** the callsite SHALL explicitly identify the desired C++ signature
- **AND** the DSL SHALL NOT choose an overload based only on the AS declaration string.

### Requirement: Chainable bind options

The typed DSL SHALL expose chainable options for common bind traits while preserving existing backend semantics.

#### Scenario: No-discard option

- **GIVEN** a function registration through the typed DSL
- **WHEN** the callsite applies `.NoDiscard()`
- **THEN** the resulting script function SHALL have the same no-discard behavior as the existing `FAngelscriptBinds::SetPreviousBindNoDiscard(true)` path or the newer `FBoundFunction::NoDiscard()` path.

#### Scenario: Trivial native option

- **GIVEN** a method or constructor registration through the typed DSL
- **WHEN** the callsite applies the DSL trivial/native option
- **THEN** StaticJIT/native metadata SHALL be equivalent to the existing `SCRIPT_NATIVE_*` / `SCRIPT_TRIVIAL_NATIVE_*` usage for that binding.

### Requirement: Representative migration parity

At least one representative hand-written binding file SHALL be migrated to the typed DSL with script-visible behavior preserved.

#### Scenario: FColor migration parity

- **GIVEN** the migrated `FColor` bindings
- **WHEN** automation tests compile and execute AS code using `FColor` constructors, `DWColor`, `ToHex`, `FromRGBE`, `ReinterpretAsLinear`, and `FColor::FromHex`
- **THEN** the calls SHALL compile and behave as they did before migration.

#### Scenario: Existing raw binding API remains valid

- **GIVEN** hand-written bindings that still use `FAngelscriptBinds` directly
- **WHEN** the plugin builds after this change
- **THEN** those existing callsites SHALL continue to compile without requiring migration.

