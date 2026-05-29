# Tasks: refactor-as-runtime-global-state

> 主线是 runtime 去全局化；`FString::Format` / `FText::Format` 是第一条可复现验收链。验证命令只使用 `Tools\RunBuild.ps1`、`Tools\RunTests.ps1`、`Tools\RunTestSuite.ps1`。

## 1. Establish Global-State Boundaries

- [ ] 1.1 <!-- Non-TDD --> Build a concrete inventory of runtime static / legacy / TLS state that can touch AngelScript runtime objects. File scope: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/`. Classify each item as `global metadata`, `engine-owned`, `engine-keyed`, `lifecycle-cleared`, or `needs proof`. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label deglobalize-1.1-inventory-compile -TimeoutMs 900000 -NoXGE`

- [ ] 1.2 <!-- Non-TDD --> Define the local migration rule near the first touched helper: no process-wide storage may hold `asITypeInfo*`, `asIScriptFunction*`, `asIScriptObject*`, or `asCContext*` unless it is scoped by engine or cleared by engine lifecycle. File scope: `Helper_GetTypeInfo.h` and the smallest necessary runtime header/source location. Verify with 2.2 build.

## 2. Deglobalize Static TypeInfo

- [ ] 2.1 <!-- Non-TDD --> Refactor `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_GetTypeInfo.h` so `TGetStaticTypeInfo<T>` stores type info per engine instead of one process-wide pointer. Keep call sites mechanical by exposing current-engine set/get/clear operations.

- [ ] 2.2 <!-- Non-TDD --> Add engine teardown cleanup so static TypeInfo entries for the outgoing engine are removed before the underlying AS engine is released. File scope: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.*` and `Helper_GetTypeInfo.h`. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label deglobalize-2.2-typeinfo-build -TimeoutMs 900000 -NoXGE`

- [ ] 2.3 <!-- Non-TDD --> Migrate `Bind_FString.cpp` and `Bind_FText.cpp` to write/read current-engine TypeInfo via the new helper instead of `TGetStaticTypeInfo<T>::TypeInfo`. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label deglobalize-2.3-format-callsite-build -TimeoutMs 900000 -NoXGE`

## 3. Use Formatting as Regression Acceptance

- [ ] 3.1 <!-- TDD --> Add or update focused coverage proving `FString::Format("{0}", "Hello")` still returns `Hello` after a previous engine has populated `FString` static TypeInfo. Prefer a small new `Angelscript...` test file if the existing FString binding fixture is too broad. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.FString" -Label deglobalize-3.1-fstring-format -TimeoutMs 900000`

- [ ] 3.2 <!-- TDD --> Add equivalent `FText` coverage or a shared TypeInfo-cache regression that proves `TGetStaticTypeInfo<FText>` cannot leak across engines. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings" -Label deglobalize-3.2-ftext-format -TimeoutMs 900000`

## 4. Deglobalize P1 Similar State

- [ ] 4.1 <!-- Non-TDD --> Move or engine-key `Bind_UEnum.cpp::GScriptEnumTypeLookupByName`, or prove it cannot be queried under a different engine than the last bind pass. If it remains global, document the proof in code-adjacent comments or tests. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings" -Label deglobalize-4.1-enum-lookup -TimeoutMs 900000`

- [ ] 4.2 <!-- Non-TDD --> Fence `Bind_FString.cpp::LegacyToStringList` so it cannot retain `FToStringType::TypeInfo` from one engine and expose it to another. Prefer current-engine `ToStringList`; keep legacy fallback metadata-only if still required. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.FString" -Label deglobalize-4.2-tostring-list -TimeoutMs 900000`

## 5. Audit P2 Legacy and TLS State

- [ ] 5.1 <!-- Non-TDD --> Audit `AngelscriptType.cpp::LegacyDatabase`, `AngelscriptBinds.cpp::LegacyBindState`, and `AngelscriptBindDatabase.cpp::LegacyBindDatabase`. Keep pure metadata; guard or migrate any path that stores AS runtime objects or current-engine-derived mutable state. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label deglobalize-5.1-legacy-fallbacks -TimeoutMs 900000 -NoXGE`

- [ ] 5.2 <!-- Non-TDD --> Audit `GAngelscriptContextPool` teardown coverage. Confirm contexts are selected by requested `asIScriptEngine` and released for destroyed engines; add a targeted lifecycle test only if existing coverage is insufficient. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine" -Label deglobalize-5.2-context-pool -TimeoutMs 1200000`

## 6. Final Verification

- [ ] 6.1 <!-- Non-TDD --> Run targeted bindings coverage after all P0/P1 changes. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings" -Label deglobalize-6.1-bindings -TimeoutMs 1200000`

- [ ] 6.2 <!-- Non-TDD --> Run engine lifecycle coverage after TypeInfo cleanup and context-pool audit. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine" -Label deglobalize-6.2-engine -TimeoutMs 1200000`

- [ ] 6.3 <!-- Non-TDD --> Run a full build and smoke/runtime/bindings suites. Verify: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label deglobalize-6.3-build -TimeoutMs 1800000`; then `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Smoke,RuntimeCpp,Bindings -Label deglobalize-6.3-suite -TimeoutMs 2400000`

- [ ] 6.4 <!-- Non-TDD --> Validate the OpenSpec change when the CLI is available. Verify: `openspec validate refactor-as-runtime-global-state --strict --json`