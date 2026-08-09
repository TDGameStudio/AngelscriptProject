## ADDED Requirements

### Requirement: Runtime FunctionLibrary functions have an explicit exposure disposition

Every UFunction declared by a class in `AngelscriptRuntime/FunctionLibraries` SHALL be script-exposed, explicitly hidden with the supported opt-out metadata, or removed. A bare reflected UFunction that is neither eligible for AS exposure nor explicitly hidden SHALL be rejected by the FunctionLibrary contract.

#### Scenario: Callable function enters the AS surface

- **WHEN** a Runtime FunctionLibrary function is BlueprintCallable, BlueprintPure, or `ScriptCallable` and is not opted out
- **THEN** the final initialized AS engine SHALL contain its expected namespace or receiver declaration exactly once

#### Scenario: Explicitly hidden function stays absent

- **WHEN** a Runtime FunctionLibrary function carries `NotInAngelscript` or the current supported explicit opt-out metadata
- **THEN** the final AS surface SHALL NOT contain a declaration for that function

#### Scenario: Bare UFUNCTION is not ambiguous

- **WHEN** a Runtime FunctionLibrary class declares a UFunction without callable eligibility or explicit opt-out metadata
- **THEN** contract validation SHALL fail and identify the owner class and UFunction rather than treating the wrapper as an undocumented AS API

### Requirement: ScriptMixin receiver intent is validated

When a reflected static function is owned by a class with `ScriptMixin`, or carries function-level `ScriptMethod`, its first reflected parameter SHALL resolve to one declared mixin target before the function can be registered as an AS instance method. Invalid mixin intent SHALL NOT fall back to the ordinary library namespace.

#### Scenario: Compatible first parameter becomes the receiver

- **WHEN** the first parameter's resolved AS type matches one target in the class `ScriptMixin` list
- **THEN** that parameter SHALL be removed from the public argument list and the function SHALL be registered as an instance method on the matching type

#### Scenario: Multiple targets select the exact receiver

- **WHEN** a class lists multiple space-separated mixin targets and the first parameter matches one of them
- **THEN** the method SHALL be placed only on the matching receiver type

#### Scenario: Missing or incompatible receiver fails initialization

- **WHEN** mixin intent exists but the first parameter is missing, unresolved, or incompatible with every target
- **THEN** registration SHALL fail with a diagnostic containing the owner class, UFunction, target list, and first-parameter type
- **AND** the function SHALL NOT appear as a static namespace function
- **AND** the partial engine SHALL NOT be published

### Requirement: FunctionLibrary declaration identity is exact

The FunctionLibrary binding path SHALL identify a script method by its receiver or namespace plus complete AS declaration. A name-only match SHALL NOT suppress a valid overload or conceal an incompatible duplicate.

#### Scenario: Same-name overloads coexist

- **WHEN** two eligible functions have the same ScriptName but different valid AS parameter declarations
- **THEN** both overloads SHALL be registered on the intended receiver or namespace

#### Scenario: Exact reflected declaration suppresses a supplement duplicate

- **WHEN** post-reflection supplement code finds the exact declaration already registered by reflection
- **THEN** it SHALL skip only that duplicate and leave every other overload unchanged

#### Scenario: Failed supplement is reported

- **WHEN** a required post-reflection supplement cannot register its exact declaration
- **THEN** the existing binding failure path SHALL retain the first diagnostic and prevent publication of a partial surface

### Requirement: FunctionLibrary metadata is preserved in the final declaration

The final AS declaration SHALL preserve the current registered-type namespace rule and supported function metadata, including function-level `ScriptName`, static versus receiver placement, const/reference shape, hidden WorldContext, DeterminesOutputType, deprecation, no-discard, allow-discard, and trivial traits.

#### Scenario: Metadata-derived declaration matches the final engine

- **WHEN** contract automation constructs the expected signature for an exposed Runtime FunctionLibrary UFunction
- **THEN** the final AS engine declaration and script-function traits SHALL match the expected metadata-derived values

#### Scenario: Invalid WorldContext metadata is rejected

- **WHEN** a function names a WorldContext parameter that does not exist in its reflected arguments
- **THEN** contract validation SHALL fail with the owner and missing parameter name rather than assigning a hidden argument index

### Requirement: Editor FunctionLibraries are outside the Runtime contract

The Runtime FunctionLibrary contract SHALL NOT claim or test Editor FunctionLibrary methods until an Editor-owned binding lifecycle exposes them.

#### Scenario: Current Editor types do not create Runtime expectations

- **WHEN** Editor FunctionLibrary UClasses are present in an editor process but have no bound AS methods
- **THEN** the Runtime census and `Angelscript.TestModule.FunctionLibraries.*` tests SHALL ignore those classes
- **AND** no `FunctionLibraries/Editor` test directory or Runtime-owned Editor supplement SHALL be introduced
