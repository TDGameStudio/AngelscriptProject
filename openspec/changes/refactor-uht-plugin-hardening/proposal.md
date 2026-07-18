## Why

The UHT function-binding pipeline now has a coherent public vocabulary and a selectable binding method, but the implementation still combines configuration loading, UHT traversal, C++ declaration parsing, code emission, diagnostics, and stale-output cleanup in one generator. The default Runtime-linked build passes, while the optional source-engine target-module path still has lifecycle hazards, parser false-positive risks, configuration drift, and unnecessary generated compile work.

This change hardens the UHT plugin before the target-module method is used broadly and establishes a maintainable boundary for future binding backends.

## What Changes

- Make target-module feature registration and unregistration lifecycle-safe, including deferred GameThread work and module unload/reload.
- Preserve pending target-module descriptors until their UClass is available instead of dropping unresolved classes permanently.
- Remove target-module binding records and stale user-data pointers when a source module unregisters.
- Define one effective FunctionBinding configuration contract shared by Editor, UBT, and UHT, including UE array operations and source/installed/unknown engine classification.
- Make C++ declaration analysis conservative and preprocessor-aware; unknown, ambiguous, or visibility-uncertain declarations must use the safe fallback path.
- Replace string-based UHT flag checks and hard-coded per-function exceptions with typed flags and explicit, testable policy rules.
- Clean all current and retired generated artifacts, including the NativeModuleFunctionAddress bridge probe.
- Reduce generated wrapper translation units and avoid repeating the complete module include set in every shard.
- Emit per-function failure reasons for both generated fallback and skipped target-module functions, with statistics that reconcile exactly with diagnostics.
- Split the 1300-line generator into responsibility-oriented configuration, analysis, emission, artifact, and cleanup components.
- Add source-engine end-to-end validation for target-module generation, registration, late loading, unload, and reload.

## Capabilities

### New Capabilities

- `uht-function-binding-hardening`: Defines safe lifecycle, conservative analysis, canonical configuration, efficient output, and verifiable diagnostics for UHT-generated function bindings.

### Modified Capabilities

- `as-function-binding-strategy`: Strengthens target-module lifecycle, configuration validation, diagnostics, and source-engine verification requirements.

## Impact

- `Plugins/Angelscript/Source/AngelscriptUHTTool/` configuration, analysis, declaration resolution, emitters, diagnostics, and output cleanup.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_NativeModuleFunctionBinding.cpp` and the native-module binding registry.
- `Plugins/Angelscript/Source/AngelscriptRuntime/FunctionBinding/NativeModuleFunctionBindingBridge.h` and generated target-module ABI payloads.
- `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs` generated wrapper strategy and dependency validation.
- UHT, Runtime, Editor, and source-engine automation tests.
- OpenSpec and build documentation for FunctionBinding diagnostics, source-engine requirements, and generated artifacts.
