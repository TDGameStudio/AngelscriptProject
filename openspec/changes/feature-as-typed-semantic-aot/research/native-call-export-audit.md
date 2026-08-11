# Preliminary native-call export audit

## Question

Can the new Semantic AOT backend directly replace an AngelScript call with the corresponding C++ function call after the FBind refactor removed or reduced many callable lambdas?

## Current evidence

- `FScriptFunctionNativeForm` is declared with `ANGELSCRIPTRUNTIME_API`, but the concrete native-function/native-method forms currently retain only generated C++ spelling, optional header text, and triviality/call behavior. They do not prove that the named callee has external linkage, an importable declaration, an owning module, or a DLL-exported symbol.
- `FAngelscriptBoundFunction::NativeFunction`, `NativeMethod`, and `NativeFunctionHeader` therefore describe how legacy StaticJIT should spell a call, not whether a separately compiled `<ProjectName>AngelscriptStaticJIT` module can link it.
- `Binds/Bind_FMath.h` declares `FAngelscriptFMathBinds` without `ANGELSCRIPTRUNTIME_API`. Non-inline members implemented by `AngelscriptRuntime` cannot be assumed linkable from an external project DLL merely because the header is reachable.
- `Binds/Bind_FApp.cpp` declares `FAngelscriptFAppBinds` locally in the `.cpp`; `GetProjectName` has neither an importable declaration nor an export macro. Moving a binding registrar to an inline lambda did not change that callable symbol's cross-module linkage.
- Many remaining lambdas in `Bind_*.cpp` are `FAngelscriptBind` registration callbacks. They execute while installing bindings and are not the C++ target invoked by generated script code. Their presence or removal is not direct-call eligibility evidence.
- `AngelscriptRuntime.Build.cs` currently exposes broad include paths, but header visibility and DLL symbol export are independent. A public declaration without the owning module's `_API` macro can still fail with an unresolved external when the generated consumer is another DLL.

This is a preliminary architecture audit, not the implementation-time exhaustive inventory requested by `tasks.md`. The inventory must classify every native form and every direct-pointer FBind registration before migration.

## Linkage classes

| Class | Direct from generated project module? | Required proof |
|---|---:|---|
| `ExportedSymbol` | Yes | Externally linked declaration, owning module, public/legal header, owning module `_API` import/export, supported typed ABI, safe routing |
| `HeaderInline` | Yes | Complete inline/template definition in a legal header, all dependencies available to the consumer, supported typed ABI, safe routing |
| `ExportedRuntimeThunk` | Yes | Public Runtime thunk declaration marked `ANGELSCRIPTRUNTIME_API`; thunk owns any call into provider-private implementation |
| `ProviderPrivate` | No | Use the scalar call bridge or make the root ineligible; do not name the private FBind symbol in generated code |
| `UnknownLegacyNativeForm` | No | Existing native call spelling may remain valid for legacy/co-located generation, but external Semantic AOT must not guess linkage |

Engine functions already exported by their owning Engine module do not need `ANGELSCRIPTRUNTIME_API`; their existing module API declaration and public header are the proof. Conversely, adding `ANGELSCRIPTRUNTIME_API` only to a `.cpp` definition is insufficient when the generated consumer has no matching includable declaration.

## Migration rule

1. Keep existing `.NativeFunction()`/`.NativeMethod()` behavior for Legacy compatibility.
2. Add a separate explicit external-call descriptor carrying linkage class, exact symbol, header, owning module, typed ABI/signature identity, and route-safety flags. Absence defaults to non-direct.
3. For a reviewed Runtime-owned scalar subset, either move a narrow declaration to an AOT-callable public header and mark it `ANGELSCRIPTRUNTIME_API`, or add an exported thin thunk while keeping `FAngelscript*Binds` private.
4. Never export binding registrar lambdas. Do not export a whole provider class merely because one member is useful to AOT.
5. Compile and link a consumer in a different UE module. A same-module unit test or generated-text golden test cannot detect a missing DLL export.
