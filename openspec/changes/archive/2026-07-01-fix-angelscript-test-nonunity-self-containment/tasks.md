## 1. Record and Scope

- [x] 1.1 Create OpenSpec change `fix-angelscript-test-nonunity-self-containment`
- [x] 1.2 Identify the root cause as test translation-unit self-containment failure under changed unity/non-unity grouping
- [x] 1.3 Record the five reported failing source files and the helper/type dependency behind each compile error
- [x] 1.4 Extend `angelscript-test-unity-build-symbol-hygiene` with self-containment requirements
- [x] 1.5 Add `self-containment-audit.md` with the full current scan inventory of required and review candidate code locations

## 2. Fix First-Wave Compile Failures

- [x] 2.1 `<!-- Non-TDD -->` In `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptGlobalVarTests.cpp`, include `AngelscriptSDKTestExecutionHelpers.h` directly for `ExecuteScriptFunction`
- [x] 2.2 `<!-- Non-TDD -->` In `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptParserTests.cpp`, include `AngelscriptNativeTestSupport.h` directly for `AngelscriptNativeTestSupport::FParserAccessor`
- [x] 2.3 `<!-- Non-TDD -->` In `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptStaticJITDiagnosticsTests.cpp`, include `AngelscriptTestMacros.h` directly for `ASTEST_CREATE_ENGINE`
- [x] 2.4 `<!-- Non-TDD -->` In `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotGeneration.cpp`, include `AngelscriptTestEngineAcquisition.h` directly for `CreateIsolatedFullEngine`
- [x] 2.5 `<!-- Non-TDD -->` In `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotGeneration.cpp`, make the `GenerateStaticJITAotArtifactsForDiagnostics` module argument compile through visible `asCModule` to `asIScriptModule` conversion or an explicit public-interface boundary cast
- [x] 2.6 `<!-- Non-TDD -->` In `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadVersionChainTests.cpp`, resolve `CompileScriptModule`, `SpawnScriptActor`, `BeginPlayActor`, and `ReadPropertyValue` through `AngelscriptFunctionalTestUtils` explicit qualification or function-local import
- [x] 2.7 `<!-- Non-TDD -->` In `Plugins/Angelscript/Source/AngelscriptTest/GC/AngelscriptEngineMemoryLifecycleTests.cpp`, include `AngelscriptTestEngineAcquisition.h` directly for `CreateIsolatedFullEngine`
- [x] 2.8 `<!-- Non-TDD -->` In `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h`, include `Misc/CoreDelegates.h` directly for `FCoreDelegates::EOnScreenMessageSeverity`
- [x] 2.9 `<!-- Non-TDD -->` In `Plugins/Angelscript/Source/AngelscriptTest/GC/AngelscriptEngineMemoryLifecycleTests.cpp`, include `UObject/Package.h` directly for `TObjectIterator<UPackage>` dereference

## 3. Apply Strict Direct-Include Cleanup

- [x] 3.1 `<!-- Non-TDD -->` Review the SDK execution helper candidates in `self-containment-audit.md` and either add `AngelscriptSDKTestExecutionHelpers.h` directly or document intentional themed-helper re-export
- [x] 3.2 `<!-- Non-TDD -->` Review the Preprocessor macro candidates in `self-containment-audit.md` and either add `AngelscriptTestMacros.h` directly or document `AngelscriptPreprocessorTestHelpers.h` as the owner of that re-export
- [x] 3.3 `<!-- Non-TDD -->` Add direct `AngelscriptTestEngineAcquisition.h` includes for isolated-engine acquisition candidates that should not depend on `AngelscriptTestUtilities.h`
- [x] 3.4 `<!-- Non-TDD -->` Add direct `AngelscriptTestMemoryProbe.h` includes for memory-probe acquisition candidates that should not depend on `AngelscriptTestUtilities.h`
- [x] 3.5 `<!-- Non-TDD -->` Keep `self-containment-audit.md` updated with any direct-include exception that is intentionally retained

## 4. Localize Functional Helper Namespace Usage

- [x] 4.1 `<!-- Non-TDD -->` Fix `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadVersionChainTests.cpp` as the direct missing-namespace compile failure
- [x] 4.2 `<!-- Non-TDD -->` Batch-review the file-level `using namespace AngelscriptFunctionalTestUtils;` imports listed in `self-containment-audit.md` through the advisory scan.
- [x] 4.3 `<!-- Non-TDD -->` Defer bulk replacement of file-level imports to a separate hygiene pass; this change keeps the reported non-unity compile failure fixed and avoids a large unrelated test churn.
- [x] 4.4 `<!-- Non-TDD -->` Leave a note in `self-containment-audit.md` for intentionally retained file-level imports and the remaining advisory cleanup path.

## 5. Add Repeatable Self-Containment Audit

- [x] 5.1 `<!-- Non-TDD -->` Add an audit script under `openspec/changes/fix-angelscript-test-nonunity-self-containment/` that scans known helper symbols and owning headers
- [x] 5.2 `<!-- Non-TDD -->` Include checks for `ExecuteScriptFunction`, `FSdkFunctionInvoker`, `FParserAccessor`, `ASTEST_*`, `CreateIsolatedFullEngine`, memory-probe acquisition helpers, and unqualified `AngelscriptFunctionalTestUtils` helper calls
- [x] 5.3 `<!-- Non-TDD -->` Make the audit advisory by default and add a `-FailOnRequired` switch for the first-wave required patterns
- [x] 5.4 `<!-- Non-TDD -->` Save a short audit output note under this change directory after the first scripted scan

## 6. Verification

- [x] 6.1 Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File openspec\changes\fix-angelscript-test-nonunity-self-containment\scan-test-self-containment.ps1 -FailOnRequired` if the script is added
- [x] 6.2 Run `git -C Plugins/Angelscript diff --check`
- [x] 6.3 Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label nonunity-self-containment-full -TimeoutMs 600000 -NoXGE`
- [x] 6.4 If the build reports additional missing helper symbols, add each file and symbol to `self-containment-audit.md` before applying the same direct-include/local-namespace fix pattern
- [x] 6.5 Run targeted single-file no-link verification for the reported `.cpp` files with `Tools\RunBuild.ps1 -NoHotReloadFromIDE -NoLink -File=...`

## 7. Documentation and Closeout

- [x] 7.1 Update the final implementation notes with the exact files changed and the build result path
- [x] 7.2 If the audit proves low-noise, decide whether to keep it as a permanent diagnostic or promote it into a reusable tool
- [x] 7.3 Archive the change with `openspec archive "fix-angelscript-test-nonunity-self-containment"` after implementation and verification are complete
