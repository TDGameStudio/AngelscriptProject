# as-property-access-uniform Specification

## Purpose

Specifies that AngelScript user code accesses UPROPERTY data and UFunction behaviour through the same syntactic surface as C++: direct field reads for raw fields, explicit method calls for everything else. The compiler-driven `obj.X` ↔ `GetX()` / `SetX()` rewriting and the AS-side virtual-property syntax are removed so the access path is unambiguous from the call site alone.

## ADDED Requirements

### Requirement: Property accessor mode is permanently disabled

The AngelScript engine SHALL be initialized with `asEP_PROPERTY_ACCESSOR_MODE` equal to `0` and SHALL NOT expose a build-time or runtime knob for re-enabling other accessor modes.

#### Scenario: Engine initialization sets mode to zero

- **WHEN** `FAngelscriptEngine` initializes the underlying `asIScriptEngine`
- **THEN** `Engine->SetEngineProperty(asEP_PROPERTY_ACCESSOR_MODE, 0)` SHALL be the value applied
- **AND** the `AS_PROPERTY_ACCESSOR_MODE` macro SHALL no longer exist as an overridable preprocessor symbol

#### Scenario: FindPropertyAccessor never resolves a match

- **WHEN** the AS compiler encounters `obj.X` where `X` is not a bound member field
- **THEN** `asCCompiler::FindPropertyAccessor` SHALL early-return without searching for `GetX` / `SetX`
- **AND** the access SHALL fail with the standard "no matching member" diagnostic, not a property-accessor-resolution error

### Requirement: Bound C++ methods are not implicitly tagged as property accessors

The fork SHALL NOT automatically promote bound C++ methods whose names begin with `Get` or `Set` to property accessor candidates.

#### Scenario: OnBind hook does not set asTRAIT_PROPERTY

- **WHEN** any C++ method or global function is bound through `FAngelscriptBinds::Method` / `BindGlobalFunction`
- **THEN** the resulting `asCScriptFunction` SHALL NOT have `asTRAIT_PROPERTY` set as a side effect of binding

#### Scenario: bAllowImplicitPropertyAccessors setting is removed

- **WHEN** `UAngelscriptSettings` is inspected
- **THEN** the `bAllowImplicitPropertyAccessors` UPROPERTY SHALL NOT exist on the settings class
- **AND** `Get-Content Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSettings.h | Select-String 'bAllowImplicitPropertyAccessors'` SHALL return zero matches

### Requirement: BindProperties does not synthesize getter/setter methods

The UPROPERTY-to-AngelScript binding pipeline SHALL expose UPROPERTYs as direct field reads only, and SHALL NOT generate synthetic `GetX` / `SetX` methods to wrap missing accessors.

#### Scenario: Plain UPROPERTY surfaces as a field

- **WHEN** a class declares `UPROPERTY(BlueprintReadWrite) float Health;`
- **AND** `BindProperties` runs for that class
- **THEN** AngelScript script code SHALL access the property via `obj.Health` and `obj.Health = 0`
- **AND** no `GetHealth()` or `SetHealth(float)` method SHALL be visible on the AngelScript type unless one is hand-bound

#### Scenario: BlueprintGetter UFunction is reachable as an ordinary method

- **WHEN** a UPROPERTY declares `UPROPERTY(BlueprintGetter=GetMyValue) float MyValue;`
- **AND** the UFunction `GetMyValue` is bound through standard UFunction binding
- **THEN** AngelScript script code SHALL call it explicitly as `obj.GetMyValue()`
- **AND** the syntax `obj.MyValue` SHALL read the underlying field directly without invoking the BlueprintGetter

### Requirement: Virtual property syntax and property decorator are parse errors

AngelScript source-level virtual-property syntax (`int X { get; set; }`) and the `property` function decorator (`void GetX() property { }`) SHALL be rejected at parse time with a guidance error.

#### Scenario: Virtual property block is rejected

- **WHEN** a script declares `int Health { get { return _Health; } set { _Health = value; } }`
- **THEN** the parser SHALL emit an error referencing the removal of virtual-property syntax
- **AND** the error message SHALL direct the author to declare explicit `GetHealth()` and `SetHealth(int)` methods

#### Scenario: property decorator on a function is rejected

- **WHEN** a script declares `int GetHealth() property { return _Health; }`
- **THEN** the parser SHALL emit an error referencing the removal of the `property` decorator
- **AND** the error message SHALL direct the author to drop the decorator

### Requirement: In-repo scripts and inline AS literals use explicit method syntax

All `.as` source files under `Script/` and inline AS string literals under `Plugins/Angelscript/Source/AngelscriptTest/` SHALL use explicit method syntax for any access that previously routed through a property accessor.

#### Scenario: No property-style call to BlueprintGetter remains

- **WHEN** the repository is searched for `\bBlueprintGetter=` in C++ followed by property-style script access to the same property name
- **THEN** zero matches SHALL exist after this change

#### Scenario: No virtual-property block remains in repository

- **WHEN** `rg -n '\{\s*get\s*\{' Script Plugins/Angelscript/Source/AngelscriptTest` runs
- **THEN** zero matches SHALL be returned

#### Scenario: Functional baseline holds after migration

- **WHEN** `Tools\RunTests.ps1 -Suite Functional` runs after this change is applied
- **THEN** the catalogued 275/275 baseline SHALL pass without newly disabled tests
