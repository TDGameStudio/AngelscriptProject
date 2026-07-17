## Context

The target-module binding path has three responsibilities that were previously given one `CrossModule` prefix:

1. UHT selects modules that do not link `AngelscriptRuntime` and emits callable wrapper code into those modules' UHT output directories.
2. The generated target module publishes a POD feature payload through `IModularFeatures`.
3. `AngelscriptRuntime` receives that feature and registers generic callable targets into `ClassFunctionBindings`.

The path crosses a module boundary, but “cross-module” is not the public capability. The protocol is a module-provided binding feature, while `ModuleLocal` correctly describes where generated code is compiled and remains the name of the opt-in build gate.

## Goals / Non-Goals

**Goals:**

- Use `ModuleBinding` as the canonical ABI, Runtime bridge, generator, artifact, and focused-test vocabulary.
- Keep `ModuleLocal` only for compile policy and target-module generation location.
- Move the stable Runtime protocol header from `Public/UHT` to `Public/Bindings`.
- Preserve exact POD field order, sizes, flags, Modular Feature lifetime, function-call marshalling, and layout token value.
- Rename generated diagnostic fields and binding-specific reason strings so production output has one vocabulary.
- Preserve the no-engine-dependency boundary: target-module generated shards remain self-contained and do not include `AngelscriptRuntime`.

**Non-Goals:**

- Do not add compatibility aliases for old symbols or feature keys.
- Do not change direct-bind safety classification, profile module membership, source-engine validation, or default-off behavior.
- Do not rename unrelated uses of “cross-module” in the AngelScript compiler's dependency graph tests.
- Do not change the generated payload layout or bump the numeric layout token.

## Decisions

### 1. Canonical protocol names

Use the following names:

| Current | Canonical |
|---|---|
| `AngelscriptCrossModuleFunctionBindings.h` | `AngelscriptModuleBindingProtocol.h` |
| `FAngelscriptCrossModuleCallFrame` | `FAngelscriptModuleBindingCallFrame` |
| `FAngelscriptCrossModuleBinding` | `FAngelscriptModuleBinding` |
| `FAngelscriptCrossModuleBindingFeatureReader` | `FAngelscriptModuleBindingFeatureView` |
| `FAngelscriptCrossModuleFunctionBindings` | `FAngelscriptModuleBindingProtocol` |
| `AngelscriptCrossModuleFunctionBindings` | `AngelscriptModuleBindingFeature` |

`FeatureView` is used because the Runtime type is a layout view over the `IModularFeature` payload, not an active reader object.

### 2. Runtime bridge names

Rename `Bind_CrossModuleDirect.cpp` to `Bind_ModuleBinding.cpp` and use `ResolveModuleBindingClass`, `InjectModuleBindingFeature`, `RegisterExistingModuleBindingFeatures`, and `GAngelscriptModuleBindingGenericHook`. Internal state uses `GModuleBindingFeatureRegisteredHandle`, `GModuleBindingPreExitHandle`, and `bModuleBindingShuttingDown`.

### 3. Generator and artifact names

The UHT generator uses `AngelscriptModuleBinding` records and `ModuleBinding` helper names. Target-module shards use `AS_FunctionTable_<Module>_ModuleBinding_<NNN>.cpp`; the Engine probe uses `AS_FunctionTable_Engine_ModuleBinding_LinkProbe.cpp`. UHT-owned files become `module-binding-generation-modules.json` and `module-binding-layout-version.txt`.

The compile gate remains `bCompileAngelscriptModuleLocalBindings` and generated normal runtime shards remain `AS_FunctionTable_<Module>_<NNN>.gen.cpp`, because those names describe a separate same-module/runtime-linked path.

### 4. Diagnostic schema migration

Rename only fields and values owned by this binding path:

- `totalCrossModuleEntries` → `totalModuleBindingEntries`
- `crossModuleRate` → `moduleBindingRate`
- `crossModuleEntries` → `moduleBindingEntries`
- `crossModuleGeneration*` → `moduleBindingGeneration*`
- `crossModuleConfiguredModules` / `crossModuleEffectiveModules` → `moduleBindingConfiguredModules` / `moduleBindingEffectiveModules`
- `EntryKind=CrossModule` → `EntryKind=ModuleBinding`
- `cross-module-*` binding protocol reasons → `module-binding-*`

CSV headers and tests migrate together. The layout token remains `0xA5C0DE02` because the ABI bytes do not change.

### 5. Header ownership

The stable Runtime-side protocol header moves to `Public/Bindings`. Generated target-module shards continue to duplicate the minimal ABI structs locally because they cannot introduce an `AngelscriptRuntime` dependency into arbitrary Unreal modules. This change names both copies consistently; eliminating the duplicate definitions is a separate dependency-boundary change.

## Risks / Trade-offs

- [Risk] External source consumers include the old header or symbols. → Treat the migration as source-breaking and require regeneration/rebuild of generated shards.
- [Risk] Diagnostic consumers parse old JSON/CSV fields. → Document the artifact schema rename and update repository tests and maintained docs in the same change.
- [Risk] A broad textual replacement changes unrelated compiler terminology. → Restrict code migration to the UHT module-binding path and explicitly retain unrelated builder dependency strings.
- [Risk] Local generated artifacts remain stale. → Delete stale old-name outputs through the generator's renamed cleanup glob and run a clean/default UHT build check.

## Migration Plan

1. Rename the public protocol and Runtime bridge files/symbols.
2. Rename UHT generator internals, config/layout files, generated paths, and diagnostics.
3. Rename focused test files, automation prefixes, source scans, and expected artifacts.
4. Update maintained docs and the new OpenSpec capability record.
5. Run `Tools\\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver"`, generated-table tests, editor settings tests, and `Tools\\RunBuild.ps1`.

Rollback is a source-level revert of the plugin commit and parent gitlink/OpenSpec commit. No runtime data migration is required.
