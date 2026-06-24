## 1. Record and Audit

- [x] 1.1 Create OpenSpec change `fix-angelscript-test-unity-symbol-scope`
- [x] 1.2 Record the first-pass rule: no file-level `using namespace` for test helper/support namespaces in test `.cpp` files
- [x] 1.3 Add a repeatable scan for file-level test helper/support namespace imports in `Plugins/Angelscript/Source/AngelscriptTest/**/*.cpp`
- [x] 1.4 Save scan results under this change directory before the broad refactor

## 2. Fix Observed Unity Failures

- [x] 2.1 Rename the soft-reference async `WaitUntil` helper to avoid the Binding unity chunk duplicate
- [x] 2.2 Remove `GameInstanceLocalPlayerTestHelpers` file-level import and qualify its helper uses
- [x] 2.3 Qualify the Subsystem binding `LocalPlayerControllerId` call site
- [x] 2.4 Rename the Docs test local `ScriptFilename` to `DocsScriptFilename`

## 3. Migrate File-Level Private Namespace Imports

- [x] 3.1 Convert AngelScriptSDK file-level support imports (`AngelscriptNativeTestSupport`, `AngelscriptSDKTestSupport`, `AngelscriptBuilderTestSupport`, related SDK helper namespaces) to CQTest method/hook-local imports or explicit qualification
- [x] 3.2 Convert file-level `_Private` namespace imports in Core tests to method-local imports or explicit qualification
- [x] 3.3 Convert file-level `*TestHelpers` imports in Bindings tests to method-local imports or explicit qualification
- [x] 3.4 Convert file-level private imports in Compiler and Preprocessor tests to method-local imports or explicit qualification
- [x] 3.5 Convert file-level private imports in Functional, Dump, Shared, and Template tests to method-local imports or explicit qualification
- [x] 3.6 Confirm no file-level imports remain for first-pass namespaces matching `*_Private`, `*TestHelpers`, or AngelScriptSDK support namespaces

## 4. Verification

- [x] 4.1 Run the static scan and confirm it reports no file-level test-private namespace imports
- [x] 4.2 Run `git -C Plugins/Angelscript diff --check` for modified plugin files
- [x] 4.3 Run `Tools\RunBuild.ps1 -Label unity-symbol-scope-fixes -TimeoutMs 600000 -NoXGE`
- [x] 4.4 Build was not blocked by Live Coding; no blocker log rerun was needed

## 5. Remove Private Namespace Using Directives

- [x] 5.1 Expand the OpenSpec rule to ban all `using namespace *_Private;` directives, not just file-level imports
- [x] 5.2 Update the scan script so `-FailOnRequired` fails on any `using namespace *_Private;` in test `.cpp` files
- [x] 5.3 Convert `_Private` helper usages in Bindings, Core, ClassGenerator, and Compiler tests to explicit namespace qualification
- [x] 5.4 Convert `_Private` helper usages in Debugger, Dump, Editor, FileSystem, and Functional tests to explicit namespace qualification
- [x] 5.5 Convert `_Private` helper usages in GC, HotReload, Memory, Performance, Shared, StaticJIT, and UHTTool tests to explicit namespace qualification
- [x] 5.6 Confirm no `using namespace *_Private;` directives remain under `Plugins/Angelscript/Source/AngelscriptTest/**/*.cpp`

## 6. Final Verification

- [x] 6.1 Run the expanded static scan with `-FailOnRequired`
- [x] 6.2 Run `git -C Plugins/Angelscript diff --check`
- [x] 6.3 Run `Tools\RunBuild.ps1 -Label unity-symbol-scope-fixes -TimeoutMs 600000 -NoXGE`

## 7. Remove File-Level Private Helper Namespaces

- [x] 7.1 Expand the OpenSpec rule to prefer removing test `.cpp` `_Private` namespace definitions entirely
- [x] 7.2 Update the scan script so `-FailOnRequired` reports file-level `_Private` namespace definitions
- [x] 7.3 Move simple single-CQTest `_Private` helper blocks into the owning `TEST_CLASS_WITH_FLAGS` class
- [x] 7.4 Move or explicitly justify complex multi-class/non-CQTest `_Private` helper blocks
- [x] 7.5 Confirm no removable `_Private` helper namespace definitions remain under `Plugins/Angelscript/Source/AngelscriptTest/**/*.cpp`
