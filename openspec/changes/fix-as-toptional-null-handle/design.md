## Context

`TOptional<T>` is registered as an AngelScript value template. Its constructor, assignment, and `Set` overloads accept `const T&in if_handle_then_const`, then copy from the generic `void*` parameter into optional storage.

For ordinary pure-AS object handles, returned `nullptr` values already flow through a safe handle value path. The failing case comes from native bindings that declare a nullable C++ pointer return as an AngelScript reference, for example `UObject& GetValue()` while the native function returns `UObject*` and may return `nullptr`. In that ABI path, AngelScript can pass a null source address to `TOptional`'s generic value-copy entry point. Existing optional code assumes the source pointer is always addressable and dereferences it through `CopyValue` or `Memcpy`.

## Goals / Non-Goals

**Goals:**
- Make native-reference-returned null UObject handles safe for `TOptional<T>` construction, `Set`, and value assignment.
- Keep `TOptional<Object>(nullptr).IsSet()` true, with `GetValue()` returning a null object handle.
- Cover ordinary pure-AS null handles and the native nullable-pointer-as-reference path under the existing optional bindings test.

**Non-Goals:**
- Do not change empty optional semantics.
- Do not add broader optional support for nested containers or UFUNCTION parameter boundaries.
- Do not refactor the whole binding template system.

## Decisions

- Treat a null source pointer specially only when the optional subtype is an object pointer. This matches the ABI case that can legally represent a null handle without an address.
- Zero-initialize the destination object pointer storage for that case, then mark the optional set. This preserves current nullable-handle semantics without calling subtype copy on a null source.
- Route the special case through the shared optional operations path so constructor, `Set`, and assignment behave consistently.
- Use a test-only native global function declared as returning `UObject&` to reproduce the user-facing crash path. Pure AS cannot return `nullptr` from a `T&` function and correctly rejects that code at compile time.

## Risks / Trade-offs

- Object handle detection relies on `FAngelscriptTypeUsage::IsObjectPointer()`. If a future nullable-handle type is not reported as an object pointer, it will need its own typed handling.
- The regression includes a test-only native bind because pure AS cannot express the invalid null-reference return that native bindings can expose.
