## Why

Hand-written Angelscript bindings currently depend on raw AS declaration strings plus low-level `FAngelscriptBinds` calls spread across `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*.cpp`. This keeps the runtime backend flexible, but the authoring surface is weak:

- AS signatures and C++ function pointers can drift independently.
- Overload disambiguation still relies on noisy `METHODPR_*` / `FUNCPR_*` macros.
- Binding traits such as trivial/native metadata, `no_discard`, editor-only, and deprecation remain scattered around the registration call.
- Namespace, class method, static function, constructor, and property binding patterns are inconsistent across files.
- Future binding audits or migrations must parse free-form strings instead of consuming structured binding intent.

UnrealCSharp's builder-style binding model shows the useful direction: register bindings through typed C++ entry points that carry function pointer information. Angelscript should borrow that authoring ergonomics without copying UnrealCSharp's C# wrapper/runtime bridge architecture. Our existing backend already has `ASAutoCaller`, StaticJIT metadata, generated function tables, cross-module direct bind, and reflective fallback; this change only improves the hand-written binding layer above it.

## What Changes

- Add a typed hand-written binding facade, centered on `FAngelscriptBindClass<T>`, for class methods, static/class namespace functions, properties, constructors, and implicit constructors.
- Keep `FAngelscriptBinds` as the only runtime registration backend. The typed DSL delegates to existing `FAngelscriptBinds::ExistingClass`, `Method`, `BindGlobalFunction`, `Property`, `Constructor`, and related paths.
- Use a conservative v1 "semi-typed" API: binding calls still accept explicit AS declaration strings, but require C++ function pointers or member pointers so the DSL can capture function traits and later validate signature drift.
- Add explicit overload helpers so new callsites can avoid the current macro-heavy overload spelling.
- Add chainable binding options/traits on the typed facade, bridging to `FBoundFunction` / `FBoundProperty` if `refactor-as-bind-eliminate-previously-bound-function` is available, or to the current previous-bind compatibility API if it is not.
- Migrate only a small representative set of hand-written bindings first, with `Bind_FColor.cpp` as the primary proving ground.

## Not Changing

- No changes to `AngelscriptUHTTool` generated function table emission.
- No changes to `Bind_BlueprintCallable.cpp`, cross-module direct bind, or reflective fallback behavior.
- No removal of existing `FAngelscriptBinds` APIs.
- No full automatic AS declaration generation in v1.
- No full migration of all `Bind_*.cpp` files in this change.

## Impact

- **Affected module**: `AngelscriptRuntime` for the new typed binding facade and representative binding migration.
- **Affected tests**: `AngelscriptTest` core/native tests for function traits and facade registration behavior, plus binding integration coverage for migrated `FColor` calls.
- **Compatibility**: Existing hand-written bindings and downstream plugin bindings continue compiling through `FAngelscriptBinds`.
- **Risk**: Low if v1 keeps explicit AS declaration strings and delegates to the existing backend; the main risk is introducing an API shape that is too narrow for complex binds, so this change deliberately validates only simple and representative cases first.
