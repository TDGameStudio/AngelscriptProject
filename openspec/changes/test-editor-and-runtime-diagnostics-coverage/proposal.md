## Why

The current `Editor`, `Networking`, `Dump`, `Performance`, `Memory`, `GC`, and `Validation` surfaces are thin compared with the rest of the test module. Some of them have only one or two files, which makes them easy to overlook even when they cover important diagnostics or runtime behaviors. This change creates a single place to expand those underrepresented areas without mixing them into the larger bindings or functional runtime work.

## What Changes

- Add first-wave coverage to the `Editor`, `Networking`, and `Dump` themes so the most visible editor and diagnostics paths are represented by explicit tests.
- Extend the thin diagnostics-adjacent runtime themes (`Performance`, `Memory`, `GC`, and `Validation`) with more intentional coverage boundaries instead of leaving them as almost-empty buckets.
- Preserve the existing themed discovery layout and keep these cases under the current `Angelscript.TestModule.*` family.
- Sync the test catalog and test guide so the thin-theme coverage map is visible to future contributors.

## Capabilities

### New Capabilities
- `editor-diagnostics-coverage`: Covers the first-wave editor and runtime diagnostics expansion for the thin test themes.

### Modified Capabilities
- None.

## Impact

- `Plugins/Angelscript/Source/AngelscriptTest/Editor/AngelscriptSourceNavigationTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Networking/AngelscriptNetworkRPCTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Dump/AngelscriptDumpTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Performance/AngelscriptRuntimeMicrobenchmarkTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Performance/AngelscriptReflectiveFallbackBenchmarkTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Memory/GlobalContainerCycleBoundedTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Memory/BindFreeEvidenceTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/GC/AngelscriptGCTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/GC/AngelscriptEngineMemoryLifecycleTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Validation/AngelscriptMacroValidationTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Validation/AngelscriptCompilerMacroValidationTests.cpp`
- `Documents/Guides/TestCatalog.md` and `Documents/Guides/Test.md`
