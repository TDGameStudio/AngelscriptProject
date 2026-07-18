# Function Binding Strategy Decision Log

This file records the confirmed design for `refactor-function-binding-strategy`.

## Confirmed

1. `FunctionBindingMethod` is one project-wide/global UE enum setting, not a per-module hybrid fallback selector.
2. `EAngelscriptFunctionBindingMethod` is serialized with semantic UE config tokens.
3. `None` disables all automatic UHT registrations, including fallback-only `ERASE_NO_FUNCTION()` records. Handwritten `Bind_*.cpp` files remain available.
4. `NativeRuntimeLinked` keeps the existing automatic `ReflectiveFallback` behavior for generated records without a usable native pointer.
5. `NativeModuleFunctionAddress` handles only the current safe target-module signature set. Unsupported signatures are skipped and do not fall back to API binding in this change.
6. The canonical UE module arrays are `NativeRuntimeLinkedModules` and `NativeModuleFunctionAddressModules`.
7. `NativeRuntimeLinkedModules` contains only modules that `AngelscriptRuntime` can legally depend on. Build.cs dynamically adds those dependencies and generates their Runtime wrappers.
8. `NativeModuleFunctionAddressModules` is an explicit allowlist in UE config. It may name Engine, plugin, or project modules present in the current UHT session; it is not a JSON profile and does not auto-scan modules.
9. `NativeRuntimeLinked` and `NativeModuleFunctionAddress` are mutually exclusive output categories for one function/module in one generation. UHT rejects ambiguous output before committing files.
10. The old `bCompileAngelscriptModuleBindings` key, `WITH_ANGELSCRIPT_MODULE_BINDINGS` gate, and JSON profile/policy files are removed from active configuration.
11. The default method is `NativeRuntimeLinked`.
12. The bridge header is source-owned under `Source/AngelscriptRuntime/FunctionBinding/`; UHT generates only target-module `.cpp` shards.
13. Legacy generated output is not emitted. Legacy patterns remain only in stale-output cleanup for one migration cycle.
14. Statistics use analyzed-function counts as the rate denominator and report shard counts separately.
15. `ThunkStyle` is removed from the final diagnostic vocabulary.
16. A configured target module that is absent from the current UHT session or has no eligible safe functions is warning-only and contributes to skipped/configuration-miss statistics.
17. Runtime-linked dependency resolution and dependency-cycle rejection remain UBT's module graph responsibility; `AngelscriptRuntime.Build.cs` adds configured modules as real dependencies so UBT reports the offending module and rejects the build before a successful target is produced.

## Configuration examples

### Runtime-linked method

```ini
[/Script/AngelscriptRuntime.AngelscriptCompileOptions]
FunctionBindingMethod=NativeRuntimeLinked
+NativeRuntimeLinkedModules=AIModule
+NativeRuntimeLinkedModules=Engine
+NativeRuntimeLinkedModules=UMG
```

Build.cs adds the configured legal dependencies and emits Runtime wrapper files. UHT generates Runtime-linked shards only for those modules.

### Target-module method

```ini
[/Script/AngelscriptRuntime.AngelscriptCompileOptions]
FunctionBindingMethod=NativeModuleFunctionAddress
+NativeModuleFunctionAddressModules=Engine
+NativeModuleFunctionAddressModules=MyGameplayPlugin
```

Build.cs does not add these modules as Runtime dependencies solely for binding. UHT generates target-module shards in the owning module output directories, subject to source-engine and signature-safety validation.

## Retired concepts

The previous module JSON profile was simultaneously an enable flag, a source/installed selector, and a module list. Those responsibilities now belong to:

- `FunctionBindingMethod` for enablement and global backend selection;
- `NativeRuntimeLinkedModules` for Runtime-linked automatic binding scope;
- `NativeModuleFunctionAddressModules` for target-module automatic binding scope;
- engine distribution classification for the source-built requirement.
