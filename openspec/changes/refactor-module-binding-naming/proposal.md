## Why

The UHT module-local binding bridge is currently named `CrossModule` across its ABI, Runtime bridge, UHT generator, generated files, configuration, and diagnostics. That term describes an implementation boundary rather than the capability: a target Unreal module compiles callable thunks and publishes a module binding feature that `AngelscriptRuntime` consumes.

The previous binding-registry refactor established `FunctionBinding` terminology but left this second vocabulary inconsistent. This follow-up makes `ModuleBinding` the canonical protocol and preserves `ModuleLocal` only for the compile-time location and opt-in gate.

## What Changes

- **BREAKING** Rename the public cross-module ABI header, POD types, namespace, feature key, Runtime bridge symbols, UHT generator symbols, and focused test names to `ModuleBinding` terminology.
- **BREAKING** Rename target-module generated shard files from `*_CrossModule_*.cpp` to `*_ModuleBinding_*.cpp`.
- **BREAKING** Rename UHT-owned profile and layout-version files to `module-binding-generation-modules.json` and `module-binding-layout-version.txt`.
- **BREAKING** Rename generated summary/CSV fields, entry-kind values, and binding-specific diagnostic reason strings to `ModuleBinding` terminology.
- Keep `bCompileAngelscriptModuleLocalBindings` and `WITH_ANGELSCRIPT_MODULE_LOCAL_BINDINGS` because they describe compilation location and build policy, not the ABI protocol.
- Preserve the payload layout, flags, layout token value, Modular Feature lifetime, registration precedence, safety filters, and Runtime/UHT dependency boundary.
- Do not rename unrelated AngelScript builder test terminology that uses “cross-module” for script dependency semantics.

## Capabilities

### New Capabilities

- `as-module-binding-naming`: Canonical naming and artifact contracts for target-module binding features consumed by `AngelscriptRuntime`.

### Modified Capabilities

No runtime behavior requirements change; this is a source and generated-artifact naming migration with an unchanged ABI layout.

## Impact

- `Plugins/Angelscript/Source/AngelscriptRuntime`: public protocol header, Runtime feature bridge, and related tests.
- `Plugins/Angelscript/Source/AngelscriptUHTTool`: generator records, helper methods, configuration discovery, output paths, diagnostics, and layout-version source.
- `Plugins/Angelscript/Source/AngelscriptTest`: UHT resolver, generated-table, and module-binding source scans.
- Maintained UHT/build architecture documentation and OpenSpec capability records.
- Existing generated intermediate outputs must be deleted and regenerated; no serialized asset migration is required.
