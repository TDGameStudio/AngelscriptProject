## Context

`chore-angelscript-compile-settings` defines the build-facing setting and macro:

```ini
[/Script/AngelscriptRuntime.AngelscriptCompileOptions]
bCompileAngelscriptUnitTests=false
```

```cpp
#if WITH_ANGELSCRIPT_UNITTESTS
```

This refactor is the source-layout follow-up. Its purpose is to make the macro actually control Angelscript C++ unit-test registration across the existing `AngelscriptTest` module.

Current implementation scan summary:

- `Plugins/Angelscript/Source/AngelscriptTest`: 549 `.cpp` files.
- 527 `.cpp` files contain CQTest or Unreal automation registration patterns.
- 22 `.cpp` files do not contain those registration patterns and need explicit classification.

## Goals / Non-Goals

**Goals:**

- Gate every Angelscript unit-test registration translation unit with `WITH_ANGELSCRIPT_UNITTESTS`.
- Keep support code build-correct when `WITH_ANGELSCRIPT_UNITTESTS=0`.
- Make the refactor auditable with scan commands that list gated, ungated, and intentionally exempt files.
- Avoid changing test behavior when `WITH_ANGELSCRIPT_UNITTESTS=1`.

**Non-Goals:**

- Do not introduce a second macro name.
- Do not remove `AngelscriptTest` from the module graph.
- Do not hand-refactor test logic, assertions, fixtures, or naming while applying the gate.
- Do not change `AngelscriptEditor/Tests` in this refactor unless a later decision expands the setting beyond `AngelscriptTest`.
- Do not gate runtime/editor production code.

## Strategy

### Candidate classification

Classify files into three buckets:

1. **Registration units:** `.cpp` files containing `TEST_CLASS_WITH_FLAGS`, `TEST_METHOD`, `IMPLEMENT_SIMPLE_AUTOMATION_TEST`, `IMPLEMENT_COMPLEX_AUTOMATION_TEST`, `DEFINE_SPEC`, or `BEGIN_DEFINE_SPEC`. These should be wrapped.
2. **Support units:** helper implementations, UObject test types, debugger fixtures, AOT fixture support, and commandlet code that do not directly register tests. These should remain compiled unless they fail when unit tests are disabled.
3. **Generated or special units:** AOT generated `.jit.cpp` files and commandlets. These need case-by-case treatment because they may be consumed by specific static JIT tests rather than acting as general unit-test registration files.

Initial non-registration files from the scan:

```text
Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/Generated/AngelscriptJitInfo.jit.cpp
Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/Generated/AngelscriptJitCode_0.jit.cpp
Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotTestCommandlet.cpp
Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotGeneration.cpp
Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotFixture.cpp
Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngineHelper.cpp
Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngine.cpp
Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptNativeScriptTestObject.cpp
Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptNativeInterfaceTestTypes.cpp
Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptMockDebugServer.cpp
Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerTestSession.cpp
Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerTestMonitor.cpp
Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerTestClient.cpp
Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptDebuggerScriptFixture.cpp
Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptConstructionContextProbe.cpp
Plugins/Angelscript/Source/AngelscriptTest/Performance/AngelscriptPerformanceTestTypes.cpp
Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptContainerBindingsTests.cpp
Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptUhtCoverageTestTypes.cpp
Plugins/Angelscript/Source/AngelscriptTest/Compiler/AngelscriptCompilerInterfaceTests.cpp
Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/AngelscriptStructCppOpsTestTypes.cpp
Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageGCTestHelpers.cpp
Plugins/Angelscript/Source/AngelscriptTest/Validation/AngelscriptCompileSettingsValidation.cpp
```

`AngelscriptContainerBindingsTests.cpp` and `AngelscriptCompilerInterfaceTests.cpp` need manual inspection because their names imply tests but the scan did not find the usual macros. They may use alternate registration style or only support adjacent test files.

### Wrapping rule

For registration units, prefer whole-file wrapping after includes:

```cpp
#include "..."

#if WITH_ANGELSCRIPT_UNITTESTS

TEST_CLASS_WITH_FLAGS(...)
{
	...
};

#endif
```

This keeps includes available to the compiler and avoids changing IWYU/self-containment behavior more than necessary. The unit-test macro is the total switch for these registration units; do not add or preserve `WITH_DEV_AUTOMATION_TESTS` as an additional outer condition when applying this refactor. If a file has file-scope test-only native bind registration that must exist for the test class, keep it inside the same gate. If a file has production-like helper declarations needed by other files, split or leave those helpers outside the gate only when references require it.

Do not wrap the include block by default. Headers stay visible so include self-containment, generated-header ordering, and ordinary tooling behavior remain stable. Only gate a header or include when that header itself performs test registration, depends on unit-test-only macro side effects, or is proven to break the `WITH_ANGELSCRIPT_UNITTESTS=0` build.

Do not use nested `#if` blocks around every `TEST_METHOD`; gate the translation unit once unless a file contains both registration and non-registration implementation that must stay compiled.

### UnitTest.md rule update

Update `Documents/UnitTest/UnitTest.md` with a new rule near the CQTest structure guidance:

- New or refactored Angelscript C++ unit-test registration files under `Plugins/Angelscript/Source/AngelscriptTest` must be gated by `WITH_ANGELSCRIPT_UNITTESTS`.
- The preferred shape is include block first, then one whole-file `#if WITH_ANGELSCRIPT_UNITTESTS` around `TEST_CLASS_WITH_FLAGS` and file-scope test-only registration objects. Do not keep `WITH_DEV_AUTOMATION_TESTS` in this wrapper; any future automation/developer-build policy should flow through how `WITH_ANGELSCRIPT_UNITTESTS` is defined.
- Headers and include blocks should remain outside the gate unless a specific header performs registration or cannot compile when unit tests are disabled.
- Files that only implement shared helpers or generated/AOT support should not be wrapped blindly; they need an explicit exemption reason when touched by this refactor.
- Do not use the obsolete or broader `WITH_ANGELSCRIPT_TESTS` spelling.

Suggested documentation snippet:

```cpp
#include "Shared/AngelscriptTestMacros.h"

#if WITH_ANGELSCRIPT_UNITTESTS

TEST_CLASS_WITH_FLAGS(FExampleTest,
	"Angelscript.TestModule.Example",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(Scenario)
	{
	}
};

#endif
```

### Macro availability

`WITH_ANGELSCRIPT_UNITTESTS` must have a defensive default in a shared test header or module-local build definition path so IntelliSense, generated files, or unusual include order do not fail:

```cpp
#ifndef WITH_ANGELSCRIPT_UNITTESTS
#define WITH_ANGELSCRIPT_UNITTESTS 0
#endif
```

The fallback default should be conservative when `AngelscriptTest.Build.cs` has not supplied the value. Normal builds must still use the Build.cs definition from `chore-angelscript-compile-settings`.

`AngelscriptTest.Build.cs` must publish `WITH_ANGELSCRIPT_UNITTESTS` as a public compile definition. Optional extension test modules such as `AngelscriptGameplayTagsTest` and `AngelscriptGASTest` include `AngelscriptTest` shared helper headers and depend on helper types like `FScopedAngelscriptModule` and `ExpectGlobalInt`. If the macro remains private to `AngelscriptTest`, those dependent modules compile without the macro and either trigger `C4668` in shared headers or compile their own registrations while the helper surface is hidden.

When extension test modules depend on `AngelscriptTest` helpers, their outer test registration gates should use the same `WITH_ANGELSCRIPT_UNITTESTS` total switch. This keeps disabled-mode behavior coherent across the Angelscript test surface without reintroducing `WITH_DEV_AUTOMATION_TESTS` as a second policy gate.

### Exemptions

Maintain an explicit exemption list in the OpenSpec implementation notes or a small repo-local verification note. A file may be exempt if:

- it contains only helper code referenced by gated registration units;
- it defines test-only UObject types needed for compilation of gated code but harmless when compiled;
- it is generated AOT fixture code with a separate build purpose;
- it is module startup/shutdown infrastructure required for the module to load cleanly.

Exemptions should not include files that register automation tests.

## Risks / Trade-offs

- **Risk: broad mechanical edits may break formatting or include assumptions.** Mitigation: use a scripted mechanical pass with reviewable diff chunks, then run targeted scans.
- **Risk: some files contain both registration and support code.** Mitigation: inspect mixed files and gate only the registration/test-only sections when whole-file wrapping would break references.
- **Risk: disabling tests still compiles helper code.** Mitigation: acceptable for this refactor; the macro controls registration and test-only code paths, not full module source exclusion.
- **Risk: generated AOT files may need special handling.** Mitigation: classify them separately and validate static JIT/AOT build behavior before applying gates.

## Verification Plan

Use project entry points only:

```powershell
Tools\RunBuild.ps1 -ExtraArgs -NoHotReloadFromIDE -TimeoutMs 1800000
```

Expected with `bCompileAngelscriptUnitTests=false`: editor build succeeds and Angelscript unit-test registration code is omitted.

```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -TimeoutMs 600000
```

Expected with `bCompileAngelscriptUnitTests=true`: AngelScriptSDK tests remain discoverable and pass.

Also run scan checks:

```powershell
rg -l "TEST_CLASS_WITH_FLAGS|TEST_METHOD|IMPLEMENT_SIMPLE_AUTOMATION_TEST|IMPLEMENT_COMPLEX_AUTOMATION_TEST|DEFINE_SPEC|BEGIN_DEFINE_SPEC" Plugins\Angelscript\Source\AngelscriptTest --glob "*.cpp"
```

For each result, verify the file contains `WITH_ANGELSCRIPT_UNITTESTS`.
