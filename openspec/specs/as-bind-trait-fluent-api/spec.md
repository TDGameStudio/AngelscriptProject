# as-bind-trait-fluent-api Specification

## Purpose
TBD - created by archiving change refactor-as-bind-eliminate-previously-bound-function. Update Purpose after archive.
## Requirements
### Requirement: Bind registration calls return a chainable handle

The `FAngelscriptBinds` registration entry points (`BindMethod`, `BindExternMethod`, `BindBehaviour`, `BindExternBehaviour`, `BindStaticBehaviour`, `BindGlobalFunction`, `BindGlobalFunctionDirect`, `BindGlobalGenericFunction`, `BindMethodDirect`, `GenericMethod`, plus the `Method()` / `Constructor()` / `Factory()` / `Destructor()` template wrappers) SHALL return an `FBoundFunction` value carrying the `int32` AngelScript function id of the just-registered function.

Property registration entry points (`BindProperty`, `BindGlobalVariable`) SHALL return an `FBoundProperty` value carrying the corresponding global-property id.

Both return types MUST remain copyable, movable, and trivially destructible.

#### Scenario: Method registration returns valid handle

- **WHEN** a bind lambda invokes `Foo.Method("void Bar()", METHOD(SomeClass, Bar))`
- **THEN** the returned `FBoundFunction` exposes a non-negative `FunctionId` matching `asIScriptEngine::GetFunctionByDecl("SomeClass::Bar()")->GetId()`

#### Scenario: Property registration returns valid handle

- **WHEN** a bind lambda invokes `FAngelscriptBinds::BindGlobalVariable("int32 GLevel", &GlobalLevel)`
- **THEN** the returned `FBoundProperty` exposes the global-property id matching `asIScriptEngine::GetGlobalPropertyIndexByName("GLevel")`

#### Scenario: Discarded return value compiles

- **WHEN** an existing callsite ignores the return value: `Foo.Method("void Bar()", METHOD(SomeClass, Bar));`
- **THEN** the code compiles without error and the bind is registered identically to before this change

### Requirement: Chainable trait setters mutate the just-bound function

`FBoundFunction` SHALL expose member methods `EditorOnly()`, `Deprecate(const ANSICHAR* Message)`, `PropertyAccessor(bool bIsProperty = true)`, `NoDiscard(bool bNoDiscard = true)`, `RequiresWorldContext(bool bRequiresWorldContext = true)`, `NotCallable()`, `GeneratedAccessor(bool bIsAccessor = true)`, `ImplicitConstructor()`, `CompileOut()`, `CompileOutAsMethodChain()`, `ForceConstArgumentExpressions(bool bForceConst = true)`, `ArgumentDeterminesOutputType(int ArgumentIndex)`, `PassScriptFunctionAsFirstParam()`, `PassScriptObjectTypeAsFirstParam()`. Each method SHALL set the corresponding `asCScriptFunction` trait/flag identically to the legacy `FAngelscriptBinds::SetPreviousBind*` / `DeprecatePreviousBind` / `MarkAsImplicitConstructor` / `CompileOutPreviousBind*` / `PreviousBindPassScript*` free functions, and SHALL return `*this` to allow further chaining.

`FBoundProperty` SHALL expose `PureConstant<T>(T Value)` mirroring the legacy `SetPreviousBoundGlobalVariablePureConstant`, returning `*this`.

#### Scenario: Single chained trait

- **WHEN** a bind site writes `Foo.Method("void Bar()", METHOD(SomeClass, Bar)).EditorOnly()`
- **THEN** the resulting `asCScriptFunction::traits` has `asTRAIT_EDITOR_ONLY` set, identical to the result of legacy `Foo.Method(...); FAngelscriptBinds::SetPreviousBindIsEditorOnly(true);`

#### Scenario: Multiple chained traits

- **WHEN** a bind site writes `Foo.Method("void Bar()", METHOD(SomeClass, Bar)).EditorOnly().Deprecate("Use NewBar")`
- **THEN** the resulting function has both `asTRAIT_EDITOR_ONLY` and `asTRAIT_DEPRECATED` set, with deprecation message `"Use NewBar"` (under `WITH_EDITOR`)

#### Scenario: Property pure-constant chain

- **WHEN** a bind site writes `FAngelscriptBinds::BindGlobalVariable("const int32 KMax", &Sentinel).PureConstant<int32>(42)`
- **THEN** the resulting `asCGlobalProperty::isPureConstant == true` and `asCGlobalProperty::storage` holds `42`, identical to legacy two-step bind + `SetPreviousBoundGlobalVariablePureConstant`

### Requirement: Legacy free-function trait setters remain functional with deprecation

The free functions `FAngelscriptBinds::SetPreviousBindIsEditorOnly`, `SetPreviousBindIsPropertyAccessor`, `SetPreviousBindIsCallable`, `SetPreviousBindNoDiscard`, `SetPreviousBindRequiresWorldContext`, `SetPreviousBindIsGeneratedAccessor`, `SetPreviousBindForceConstArgumentExpressions`, `SetPreviousBindArgumentDeterminesOutputType`, `PreviousBindPassScriptFunctionAsFirstParam`, `PreviousBindPassScriptObjectTypeAsFirstParam`, `DeprecatePreviousBind`, `MarkAsImplicitConstructor`, `CompileOutPreviousBind`, `CompileOutPreviousBindAsMethodChain`, `SetPreviousBoundGlobalVariablePureConstant` SHALL remain callable and produce the same observable trait write as before this change. They SHALL be marked `[[deprecated]]` so new uses produce a compiler warning. `OnBind()` SHALL continue to write `FAngelscriptBindState::PreviouslyBoundFunction` to keep the legacy read path correct.

#### Scenario: Mixed legacy and chained calls in the same bind lambda

- **WHEN** a bind lambda registers method A using legacy `Foo.Method(...); FAngelscriptBinds::SetPreviousBindIsEditorOnly(true);` and method B using chained `Foo.Method(...).EditorOnly()`
- **THEN** both functions have `asTRAIT_EDITOR_ONLY` set on their `asCScriptFunction::traits`

#### Scenario: Legacy free-function call produces deprecation warning

- **WHEN** the codebase is compiled with the legacy free-function call site present
- **THEN** the compiler emits a `[[deprecated]]` warning naming the legacy free-function

### Requirement: Trait-write semantics are byte-identical to baseline

For any sequence of bind operations, the resulting AS engine state — total registered object types, methods, behaviours, global functions, global properties; per-`asCScriptFunction` trait bits; serialized `Binds.Cache` content — SHALL be byte-identical between the pre-change implementation and the post-change implementation, when invoked with the same set of `Bind_*.cpp` files migrated to chained API.

#### Scenario: Type and function counts unchanged

- **WHEN** the editor starts up after this change
- **THEN** `asIScriptEngine::GetObjectTypeCount()`, the sum of `GetMethodCount()` over all object types, `GetGlobalFunctionCount()`, and `GetGlobalPropertyCount()` each match the values recorded on the immediately previous baseline build

#### Scenario: Binds.Cache binary diff is empty

- **WHEN** the cooked path with `AS_USE_BIND_DB=1` writes `Script/Binds.Cache`
- **THEN** the resulting file is bit-for-bit identical to the same path produced by the previous baseline build

