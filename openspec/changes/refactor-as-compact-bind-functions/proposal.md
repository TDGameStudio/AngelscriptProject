## Why

Many manual bind families have a very small `Bind_<Name>_Functions.cpp` containing only a few named constructor or wrapper bodies. Keeping those bodies in a separate translation unit obscures the registrar-to-callable relationship without adding a useful boundary. At the same time, heavily supported geometry families benefit from retaining their dedicated implementation files.

## What Changes

- Colocate compact named callable implementations with the `FAngelscriptBind` registrar that registers them.
- Select the current compact-provider inventory using a strict source snapshot: `_Functions.cpp` files below 100 physical lines, excluding the designated high-complexity geometry families.
- Keep stable named callable owners, declaration strings, registration order, phases, native/trivial forms, and script-visible behavior unchanged.
- Retain canonical `Bind_<Name>.h` headers only where a sibling translation unit still consumes the callable owner; remove headers that become provider-private.
- Remove the source-text-only `AngelscriptBindSourceLayoutTests.cpp` suite and do not replace it with another repository-layout automation test.
- Reconcile the active manual-binding and reviewability OpenSpec records so they no longer require every ordinary callable body to live in a `_Functions.cpp` file.

## Capabilities

### New Capabilities

- `as-compact-bind-function-colocation`: Defines the compact-provider selection rule and preserves named callable behavior while colocating selected implementations with their registrars.

### Modified Capabilities

None.

## Impact

- Runtime source: selected families under `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/`.
- Tests: removal of `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptBindSourceLayoutTests.cpp`; existing behavior-owning Bindings and StaticJIT coverage remains.
- Records: this change and the two active binding OpenSpecs cited above.
- Public AngelScript APIs and module dependencies remain compatible.
