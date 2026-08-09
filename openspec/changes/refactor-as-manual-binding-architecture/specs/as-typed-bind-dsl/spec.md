## MODIFIED Requirements

### Requirement: Typed class binding facade targets an explicit engine

The system SHALL provide `FAngelscriptBinds` as a typed hand-written binding facade constructed for one explicit `FAngelscriptEngine`. Class, struct, enum, global, and namespace helpers SHALL register immediately against that target and its engine-owned stores. Completed binding code SHALL NOT choose a mutation target through `FAngelscriptEngine::GetCurrent()` or an unpartitioned fallback.

#### Scenario: Direct member method registration

- **WHEN** a provider callback receives `FAngelscriptBinds& Binds`, obtains a typed class view, and calls `Method("float64 Size() const", &FVector::Size)`
- **THEN** the method is immediately registered on the explicit target engine
- **AND** the returned `FAngelscriptBoundFunction` identifies that exact result

#### Scenario: Class namespace static function

- **WHEN** a typed class view binds a supported free function as a class namespace function
- **THEN** the complete AngelScript declaration and namespace target are registered on the same explicit engine
- **AND** no process-global current-engine selection occurs

#### Scenario: Direct property registration

- **WHEN** a typed class view binds a member offset or supported property form
- **THEN** the property is immediately registered for that class on the explicit engine
- **AND** the returned `FAngelscriptBoundProperty` identifies that exact property result

### Requirement: Semi-typed declarations and callable forms are preserved

The typed DSL SHALL retain an explicit complete AngelScript declaration and SHALL support the C++ callable forms accepted by the existing binding API. Direct registration SHALL pass the selected callable payload, native caller, call convention, user data, and native/StaticJIT form to the explicit engine without requiring automatic full declaration generation or a separate declaration parser.

#### Scenario: Declaration remains explicit

- **WHEN** a provider binds an overloaded or script-specific signature
- **THEN** the author supplies the complete AngelScript declaration string
- **AND** that declaration remains the semantic input to AngelScript registration

#### Scenario: Existing macro and direct forms remain valid

- **WHEN** a provider uses a supported raw pointer, `METHOD`, `METHODPR`, `FUNC`, trivial/native macro, direct form, or generic form
- **THEN** the direct facade accepts the same callable shape
- **AND** equivalent ASAutoCaller/native metadata reaches the target engine

#### Scenario: Supported inner lambda remains valid

- **WHEN** `FVector_.Method`, a constructor, or a global function uses a currently supported non-capturing lambda
- **THEN** the direct facade converts and registers the callable as before
- **AND** the requirement that the outer `FAngelscriptBind` callback is non-capturing does not remove inner binding-lambda support

#### Scenario: Supported capturing auxiliary callable remains valid

- **WHEN** an existing type-finder or other explicitly owning auxiliary API accepts a capturing TFunction-like value
- **THEN** the value is owned by the explicit engine's auxiliary store according to that API's lifetime contract
- **AND** it is not placed in the process callback record

### Requirement: Explicit overload support remains available

The typed DSL SHALL support overloaded C++ functions through an explicit typed overload helper, `METHODPR`-style wrapper, or equivalent typed cast API. The chosen callable SHALL be registered immediately against the explicit engine while preserving its complete AngelScript declaration.

#### Scenario: Overloaded method is selected explicitly

- **WHEN** a provider selects one overload with an exact member-function type or `METHODPR`
- **THEN** that overload is registered
- **AND** no runtime overload inference or deferred callable selection occurs

### Requirement: Direct registrations expose chainable exact results

Function-like calls SHALL return `FAngelscriptBoundFunction`, and property-like calls SHALL return `FAngelscriptBoundProperty`. Applicable fluent options SHALL mutate the exact newly registered result on the explicit engine. Discarding either return value SHALL remain valid.

#### Scenario: No-discard method option

- **WHEN** an author writes `FVector_.Method(...).NoDiscard()`
- **THEN** `NoDiscard` is applied to the function returned by that `Method` call
- **AND** no previous-function id is read

#### Scenario: Property option

- **WHEN** an author writes `FType_.Property(...).PureConstant(Value)`
- **THEN** the option targets the property returned by that `Property` call
- **AND** no previous-global-property id is read

#### Scenario: Return is ignored

- **WHEN** an author calls `Method`, constructor, behaviour, global function, or property without chaining an option
- **THEN** the call compiles and the direct registration remains valid

### Requirement: Representative migration preserves behavior

All in-tree manual providers SHALL migrate to file-static `FAngelscriptBind` callbacks using the explicit `FAngelscriptBinds` facade and one required phase per callback. Script-visible behavior SHALL be preserved, and completed production source SHALL no longer depend on legacy nested `FBind`, integer order, implicit PreviousBind state, or module-startup submission.

#### Scenario: FColor migration parity

- **WHEN** `Bind_FColor.cpp` is migrated
- **THEN** its type, constructors, properties, methods, namespace functions, traits, and callable behavior match the baseline
- **AND** declarations and methods are split into appropriate phase callbacks where required

#### Scenario: FVector named production entries and callable forms remain available

- **WHEN** `Bind_FVector.cpp` is migrated
- **THEN** its project-owned runtime callables use stable named `FAngelscriptFVectorBinds` entries while existing pointer, macro, overload, type-adapter/finder, ToString, documentation, and native metadata behavior remains covered
- **AND** a separate focused fixture proves the supported method/global/constructor lambda overloads remain available
- **AND** no expanded registration cache is introduced

#### Scenario: Legacy registrar is gone

- **WHEN** migration is complete
- **THEN** production source contains no legacy `FAngelscriptBinds::FBind`, `RegisterBinds`, integer `EOrder`, or binding submission from `StartupModule()`
- **AND** all engines execute the same sealed direct callbacks

## ADDED Requirements

### Requirement: Production hand-written callables have named bind-owned entries

Every project-owned C++ function directly registered as an AngelScript method, constructor, implicit constructor, factory, destructor, behaviour, template callback, global function, or global generic function by a production hand-written bind SHALL have a stable named entry owned by that bind. This source-organization requirement SHALL NOT remove supported lambda overloads from the typed DSL, add a function-level runtime metadata cache, or change the callable's ASAutoCaller, call convention, user data, native form, or trivial classification.

#### Scenario: Bind owns custom non-template callables

- **WHEN** `Bind_FVector.cpp` owns project-defined runtime callable implementations
- **THEN** registration remains in `Bind_FVector.cpp`, one primary `FAngelscriptFVectorBinds` type owns the callable entries, and its high-complexity companion layout remains separate
- **AND** one primary `FAngelscriptFVectorBinds` type owns those callable entries

#### Scenario: Bind forwards only existing pointers

- **WHEN** a hand-written bind registers only existing UE member/free pointers and owns no custom callable implementation
- **THEN** it is not required to create empty `_Functions.h/.cpp` companion files

#### Scenario: Existing named wrapper is migrated

- **WHEN** a project-owned direct AS entry is currently a file-local free function, namespace function, static wrapper, or non-capturing lambda
- **THEN** it moves to the bind's named callable owner regardless of its former C++ syntax
- **AND** registration identifies it through a stable function address

#### Scenario: Template callable requires visible definition

- **WHEN** a callable template must be visible at its instantiation point
- **THEN** its definition remains in the canonical `Bind_<Name>.h` or another required header-visible owner
- **AND** ordinary non-template body placement is governed by the compatible compact-provider policy when that bind family is selected

#### Scenario: Former ordinary lambda remains non-native

- **WHEN** a production lambda without StaticJIT native metadata becomes a named function
- **THEN** it is registered through an ordinary `&FAngelscript<Name>Binds::Function` pointer
- **AND** the migration does not assign `FUNC`, trivial, template-native, or custom-native metadata merely because the function now has a name

#### Scenario: Existing native form moves

- **WHEN** a callable already registered with `FUNC`, `FUNC_TRIVIAL`, custom-native, or templated native metadata moves to a companion owner
- **THEN** its native/trivial classification, generated C++ spelling, include reachability, and required link visibility remain valid

#### Scenario: Auxiliary lambda is not a direct AS entry

- **WHEN** a bind uses a capturing type finder, local algorithm lambda, or UE delegate/async callback that is not directly supplied to an AngelScript callable registration API
- **THEN** the production named-entry rule does not require that lambda to become an AS callable-owner function
