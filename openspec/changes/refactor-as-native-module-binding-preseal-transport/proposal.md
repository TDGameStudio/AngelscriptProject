## Why

NativeModuleFunctionAddress shards compile into target Unreal modules that cannot depend on `AngelscriptRuntime` without forming a circular module dependency. The manual-binding architecture therefore has to retain its current POD/`IModularFeatures` arrival and unload bridge temporarily, leaving one binding transport outside the sealed direct-callback lifecycle.

## What Changes

- Design a Runtime-independent, compile/link-safe transport that makes target-module native function-address payloads available before the direct binding collection is sealed.
- Remove binding-specific NativeModuleFunctionAddress arrival, unload, pending-injection, and already-constructed-engine replay only after the replacement proves equivalent target coverage.
- Preserve the `FAngelscriptNativeModuleFunctionBinding` / view POD ABI unless an intentional layout revision is recorded and versioned across Runtime, UHT generation, and tests.
- Keep RPC/Net functions on `BlueprintCallableReflectiveFallback` and preserve the current signature eligibility and cross-module allowlist policy.

## Capabilities

### New Capabilities

- `as-native-module-binding-preseal-transport`: defines a circular-dependency-safe pre-seal transport and the lifecycle contract for generated native-module function-address payloads.

### Modified Capabilities

- `as-cross-module-generation-profiles`: changes the NativeModuleFunctionAddress delivery lifecycle without changing profile eligibility.

## Impact

- Affects the UHT NativeModuleFunctionAddress emitter, target-module generated shards, the Runtime consumer under `AngelscriptRuntime/FunctionBinding`, generated-profile tests, and startup/module-loading coordination.
- Does not belong to `refactor-as-manual-binding-architecture`; that change keeps the current POD/`IModularFeatures` bridge and layout version as a documented exception.
- Requires an explicit module-dependency proof before selecting an implementation, because target modules must remain independent of `AngelscriptRuntime`.
