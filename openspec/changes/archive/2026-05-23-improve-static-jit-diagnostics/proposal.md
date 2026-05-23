## Why

StaticJIT AOT tests currently depend on `FAngelscriptEngine` APIs named for testing to load precompiled cache data, compile it, and resolve StaticJIT function ids. Those APIs leak test-only vocabulary and AOT fixture lifecycle operations into the runtime engine surface.

## What Changes

- Replace StaticJIT-specific `FAngelscriptEngine::*ForTesting` cache load, cache compile, and function-id lookup APIs with a non-Shipping StaticJIT diagnostics surface.
- Add a developer-facing StaticJIT diagnostics console command so the runtime surface is useful for real troubleshooting, not only automation.
- Rename StaticJIT generation helpers away from `ForTesting` where they are part of the diagnostics/AOT verification workflow.
- Update StaticJIT AOT tests to use the diagnostics surface instead of Engine test APIs.
- Keep this change scoped to StaticJIT AOT diagnostics cleanup; broader runtime `Test` naming cleanup is out of scope.

## Capabilities

### New Capabilities

- `static-jit-diagnostics`: Non-Shipping StaticJIT diagnostics and AOT verification cleanup.

### Modified Capabilities

- None.

## Impact

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.*`: remove StaticJIT-specific `ForTesting` methods for precompiled cache load/compile and function-id lookup.
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/`: add or rename diagnostics APIs, generated-entry marker support, and console command support under a non-Shipping diagnostic guard.
- `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/`: migrate AOT tests and fixtures to the new diagnostics surface.
- `openspec/changes/refactor-as-static-jit-test/`: remains historical context; this change supersedes its test-support decisions for StaticJIT AOT diagnostics.
