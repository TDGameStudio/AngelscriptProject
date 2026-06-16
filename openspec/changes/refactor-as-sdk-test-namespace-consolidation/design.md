# Design: bare-engine coverage boundary

## Context

`AngelScriptSDK/` tests run on the **bare native engine** (`CreateNativeEngine` / `CreateBareSdkEngine`) — a raw `asIScriptEngine`/`asCScriptEngine` with no UE integration layer registered. This is intentional: these are white-box tests of the fork's compiler core (`as_*.cpp`), below the `FAngelscriptEngine` wrapper.

## Verified bare-engine capability boundary (2026-06)

Evidence: `AngelscriptNativeReferenceScriptClassTests.cpp` already encodes this as asserted, expected behavior (`TestIsolatedScriptClassInstantiationRaisesNullPointer`, lines 149-156): instantiating a **script reference-class** on the bare engine raises `asEXECUTION_EXCEPTION` with text `"Null pointer access"`. The fork's script-class factory/GC behavior depends on registrations the UE layer supplies; the bare engine lacks them, so `Foo f;` yields a null instance.

This is a fork design reality, NOT something fixable at the SDK test layer. Tests must match the boundary:

**Executable on the bare engine (write real execute+assert coverage):**
- primitive type matrix (int8/16/32/64, uint*, float, double, bool), overflow/wrap edges
- enums, typedefs, numeric/explicit conversions
- built-in operators (arithmetic, comparison, logical, bitwise, assignment, ternary, pow, precedence, short-circuit)
- global functions over primitives; `&in`/`&out`/`&inout` primitive refs; overloads; default args
- variable scope; module create/discard/sections; global vars/properties (primitive)
- runtime control that doesn't need script-class instances: exceptions (divide-by-zero, etc.), suspend/resume of free functions, abort, callbacks
- native registration / calling conventions over primitives & registered C++ value types
- bytecode / parser / scriptnode / tokenizer white-box (already strong)

**NOT executable on the bare engine — cover by compile+resolve+metadata, or assert the documented exception:**
- instantiating a **script reference-class** (`class C {} ... C c;`) at runtime
- therefore: script-class `opCall`/`opIndex`/`opAdd`/`opCmp`/`opEquals`, polymorphism dispatch, mixin behavior, object lifetime of script classes
- For these: verify the class **compiles**, the type **metadata** is correct (`GetTypeInfoByDecl`, behaviours, properties, methods), and `GetNativeFunctionByDecl` resolves the entry — OR assert the `asEXECUTION_EXCEPTION` "Null pointer access" like the reference tests do. Both are legitimate behavioral coverage.

**Not available on the bare engine at all:**
- `FString` and other UE types (compile error "Identifier 'FString' is not a data type"); string runtime is blocked on the `RegisterStringFactory` 2.33↔2.38 API gap (`AngelscriptStringUtilTests.cpp` is `#if 0`).

## Decision

Raise SDK coverage toward the TArray-bindings density **within this boundary**: maximize real execute+assert coverage for everything the bare engine supports (type matrix, operators, conversions, functions, globals, runtime exceptions, calling conventions), and for script-class semantics use metadata/compile + documented-exception assertions rather than forcing runtime instantiation. Do not migrate SDK white-box tests to the UE-wrapper engine as part of this change — that would change their layer/intent; if runtime script-class dispatch coverage is wanted, it belongs in a separate UE-wrapper test theme.

See project memory: [[angelscript-sdk-bare-engine-limits]], [[angelscript-test-unity-build-constraint]].
