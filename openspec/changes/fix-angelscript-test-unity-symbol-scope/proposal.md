## Why

Unreal unity builds include many Angelscript test `.cpp` files into a single generated translation unit. File-level `using namespace <test-private-namespace>;` and generic anonymous-namespace helper names can leak symbols across included tests, producing non-local compile failures such as duplicate helper definitions, ambiguous identifiers, and `/w4459` shadowing errors.

This is happening now in `AngelscriptTest` unity chunks, especially around Bindings/Core tests, and must be fixed as a test-source hygiene rule rather than as isolated one-off renames.

## What Changes

- Introduce a test-source rule that forbids file-level `using namespace` in `AngelscriptTest` `.cpp` files for test helper/support namespaces.
- Allow local `using namespace <helper-namespace>;` inside `TEST_METHOD`, `BEFORE_*`, `AFTER_*`, or other narrow function scopes when that matches existing CQTest style.
- Convert existing file-level private helper `using namespace` declarations to method-local using declarations or explicit qualification.
- Include SDK test support namespaces in the first pass, especially `AngelscriptNativeTestSupport`, `AngelscriptSDKTestSupport`, and related AngelScriptSDK helper namespaces.
- Keep broad functional utility namespace imports such as `AngelscriptFunctionalTestUtils` for a later pass unless they cause a concrete conflict.
- Fix already observed unity failures:
  - duplicate anonymous `WaitUntil` in Binding async tests,
  - ambiguous `LocalPlayerControllerId` across GameInstance/Subsystem binding tests,
  - `/w4459` on `ScriptFilename` in docs tests.
- Add a repeatable static scan so future broad edits can identify remaining file-level private namespace imports before running the full UBT build.

## Capabilities

### New Capabilities

- `angelscript-test-unity-build-symbol-hygiene`: Defines unity-build-safe symbol-scope rules for Angelscript C++ automation tests.

### Modified Capabilities

- None.

## Impact

- Primary code area: `Plugins/Angelscript/Source/AngelscriptTest/**/*.cpp`.
- Initial touched files are expected under `Bindings/`, `Core/`, `Compiler/`, `Functional/`, `Preprocessor/`, `Dump/`, `Shared/`, and `Template/` only where file-level private helper namespace imports exist.
- No runtime script behavior, public plugin API, or generated UHT binding contract changes are intended.
- Verification uses `Tools\RunBuild.ps1`; current local builds may be blocked until Unreal Live Coding is disabled.
