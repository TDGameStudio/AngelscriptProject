## Current State

`FAngelscriptBinds` currently mixes several responsibilities:

- Low-level AngelScript engine registration.
- Function caller selection through `ASAutoCaller`.
- StaticJIT/native metadata markers.
- Namespace and class binding helpers.
- Previous-bind trait mutation APIs.
- Generated function table and skip-bind support.

That makes it the correct backend, but not the best public authoring interface for new hand-written binds. Files such as `Bind_FColor.cpp` show the common problem clearly: the AS declaration string, C++ function pointer, namespace scope, native metadata, and trait mutation are expressed as separate pieces of code.

## Target Architecture

The typed DSL is a thin facade:

```text
Bind_*.cpp
  -> FAngelscriptBindClass<T> / FAngelscriptBindGlobal
    -> FAngelscriptBinds
      -> ASAutoCaller / AngelScript engine / StaticJIT / docs / traits
```

The facade must not become a second binding runtime. It should only:

- Capture C++ function/member/property types at compile time.
- Provide a clearer chained authoring API.
- Normalize common trait/options spelling.
- Delegate final registration to existing `FAngelscriptBinds`.

## API Shape

The v1 API remains explicit about AS declarations:

```cpp
FAngelscriptBindClass<FColor>("FColor")
	.Constructor("void f(uint8 R, uint8 G, uint8 B, uint8 A = 255)", [](FColor* Address, uint8 R, uint8 G, uint8 B, uint8 A)
	{
		new(Address) FColor(R, G, B, A);
	}).NoDiscard().TrivialNativeConstructor("FColor")
	.Property("uint DWColor", &FColor::DWColor)
	.Method("FString ToHex() const", &FColor::ToHex).Trivial()
	.Method("FLinearColor FromRGBE() const", &FColor::FromRGBE).Trivial()
	.StaticFunction("FColor FromHex(const FString& HexString) no_discard", &FColor::FromHex);
```

The shorter future form is intentionally deferred:

```cpp
FAngelscriptBindClass<FColor>("FColor")
	.Method("ToHex", &FColor::ToHex);
```

Full declaration generation requires stable mapping for parameter names, default values, AS-only modifiers, `?&`, `handle_only`, operator aliases, and template-specific syntax. Doing that first would make this change much larger and riskier than necessary.

## Function Traits

Add internal traits such as `TAngelscriptFunctionTraits<T>` for:

- Free functions.
- Non-const member functions.
- Const member functions.
- `const&` qualified member functions already supported by `FAngelscriptBinds::Method`.
- Captureless lambdas that can decay to function pointers, matching the existing `TLambdaFuncPtr` pattern.

Traits are used initially for compile-time classification and future validation hooks. v1 does not need to reject every possible declaration mismatch, but tests must prove traits distinguish member/free/const forms correctly.

## Overloads

Overloaded functions need an explicit typed cast helper so callsites do not keep spelling raw `METHODPR_*` / `FUNCPR_*` macros forever. The design should support a form equivalent to:

```cpp
.Method("bool opEquals(const FColor& ColorB) const",
	AngelscriptOverload<bool(const FColor&) const>(&FColor::operator==))
```

Exact helper naming can be chosen during implementation, but the implementer must preserve explicitness for overloads and avoid guessing based only on an AS declaration string.

## Trait Chaining

The facade should return a small bind-result wrapper from `.Method`, `.StaticFunction`, `.Constructor`, `.ImplicitConstructor`, and `.Property`.

If `refactor-as-bind-eliminate-previously-bound-function` has already landed, the wrapper delegates to `FBoundFunction` / `FBoundProperty`. If not, it may delegate to the current previous-bind APIs so this change remains implementable independently. The public typed DSL shape should not depend on which backend bridge is active.

Representative traits:

- `.Trivial()`
- `.NoDiscard()`
- `.EditorOnly()`
- `.Deprecated(const ANSICHAR* Message)`
- `.ImplicitConstructor()`
- `.TrivialNativeConstructor(const ANSICHAR* NativeName)`
- `.TrivialNativeMethod(const ANSICHAR* NativeName)`

## Migration Strategy

This change should prove the API with a small number of bindings, not rewrite the whole plugin.

Primary target:

- `Bind_FColor.cpp`: covers constructor, property, method, operator overload, class namespace static functions, and global variables.

Optional secondary target if the API remains clean:

- A small subset of `Bind_AssetRegistry.cpp` or another simple value/object type with ordinary methods.

Do not migrate complex callsites in this change:

- Generic `?&` methods.
- Runtime type-id helpers.
- Dynamic declaration generation.
- Large math/global function tables such as full `Bind_FMath.cpp`.

## Relationship To Other Bind Refactors

`refactor-as-bind-eliminate-previously-bound-function` is related but separate. That change cleans up implicit previous-bind state and introduces fluent handles. This typed DSL change improves the hand-written binding authoring surface. Either can land first if the typed DSL keeps a compatibility bridge.
