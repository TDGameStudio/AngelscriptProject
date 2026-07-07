## 1. Source Update

- [ ] 1.1 Add a `FAngelscriptFunctionSignature` helper that populates argument and return type data from a `UFunction`.
- [ ] 1.2 Refactor or share the existing `InitFromDB(..., bInitTypes=true)` type population logic to avoid semantic drift.
- [ ] 1.3 Call the helper only under `AS_USE_BIND_DB` in the no-direct-pointer branch before `BindBlueprintCallableReflectionFallback(...)`.
- [ ] 1.4 Confirm the direct-native-pointer branch remains unchanged.

## 2. Regression Coverage

- [ ] 2.1 Identify an existing generated function-table stub or reflective fallback candidate with representable types.
- [ ] 2.2 Add focused coverage that proves the fallback path receives valid signature type data.
- [ ] 2.3 Add or update a negative assertion for unsupported reflected types if an adjacent test already covers fallback rejection.

## 3. Validation

- [ ] 3.1 Run `Tools\RunBuild.ps1 -Label cooked-reflection-fallback-build -TimeoutMs 1800000 -NoXGE`.
- [ ] 3.2 Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Core" -Label cooked-reflection-fallback-core -TimeoutMs 900000`.
- [ ] 3.3 Run `Tools\RunBuild.ps1 -Label cooked-reflection-fallback-shipping -Configuration Shipping -TimeoutMs 1800000 -NoXGE` before closing the cooked-runtime fix.
- [ ] 3.4 Run package/cooked validation if local tooling exposes a supported package entry point.
- [ ] 3.5 Run `openspec validate fix-as-cooked-reflection-fallback-signature-types --strict --json`.
