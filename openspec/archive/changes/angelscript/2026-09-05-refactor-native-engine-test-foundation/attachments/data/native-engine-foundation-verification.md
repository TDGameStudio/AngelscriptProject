# NativeEngine foundation verification

## Verified content

| Path | SHA-256 |
|---|---|
| `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs` | `0b32f2b77ba1df6ec9e85da50d553f57b7f5d3689a2a0ca63bef3f1fb9b0061d` |
| `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/NativeEngineTestSupport.h` | `6da642a6f4c0e3e45d107993dae9ebf4d2f340e2d49b8fba68190ad82d3b2b78` |
| `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/NativeEngineTestFoundationTests.cpp` | `4c0996e48882b796b8db5a84f54b8d13accda23cfe633f4b7f7f78466e7046e6` |

## TDD and build evidence

| Phase | Managed run | Outcome | Evidence |
|---|---|---|---|
| CQTest dependency RED | `99c5bff430e146f78ace045bfe653697` | Expected failure | `CQTest.h` was unavailable to the replacement test translation unit. |
| CQTest dependency GREEN | `7f8a14e018154327b370bde6d943c47d` | Build succeeded | Replacement CQTest compiled with the legacy gate still disabled. |
| Support-surface RED | `7741ac5d1eaf4c53bf5a9321b862fd0b` | Expected failure | The wished-for `NativeEngineTestSupport.h` was absent. |
| Final fresh build | `96b26c7ff9944f7bb37faf222ddc3ee2` | Build succeeded | The editor target compiled and linked from the verified content above. |

All commands used Harness `ue.build` for `AngelscriptProjectEditor`, `Win64`, `Development`, `BuildConcurrency = Auto`, and `ConcurrencyPolicy = Auto`. The final run retained its private UBT log under `Saved/Harness/Unreal/Runs/96b26c7ff9944f7bb37faf222ddc3ee2/`.

## Focused Automation evidence

- Command selection: `Angelscript.UnitTest.NativeEngine.Foundation`, `Fast = true`.
- Managed run: `6963d59f5b874c3396cc7fc0b9be079f`.
- Process exit: `0`.
- Automation outcome: `Passed`.
- Counts: `4 total`, `4 succeeded`, `0 failed`, `0 skipped`, `0 warnings`, `0 errors`.
- Report: `Saved/Harness/Unreal/Runs/6963d59f5b874c3396cc7fc0b9be079f/AutomationReport/index.json`.

The report contains exactly these selected paths:

1. `Angelscript.UnitTest.NativeEngine.Foundation.DiagnosticCapturePreservesOrderAndResets`
2. `Angelscript.UnitTest.NativeEngine.Foundation.LegacyGateRemainsDisabled`
3. `Angelscript.UnitTest.NativeEngine.Foundation.ReplacementGateProvidesCQTest`
4. `Angelscript.UnitTest.NativeEngine.Foundation.SourceInputOwnsUtf8Bytes`

Every selected path matches `Angelscript.UnitTest.NativeEngine.Foundation.<Scenario>`. No temporary `NewVersion` component or extra C++ class component appears.

## Scope

This proves the replacement CQTest dependency, compile gates, local source/diagnostic fixture behavior, exact public identity, managed report, and focused Fast process. It does not prove any later lexer, preprocessor, AST, Sema, reflection, Builder, VM, Standalone, legacy test, or full-suite behavior.
