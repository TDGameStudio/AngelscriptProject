# Verification

## Retained evidence

| Evidence | Result | Authority |
| --- | --- | --- |
| `Saved/Tests/as-native-sdk-constructor-parameter-bytecode-isolation-fix15b/20260723_224516_460_b31de318/Report/index.json` and log | Printed the two-word conversion and deliberately stopped with a focused red result before worker crash. | Historical red root-cause evidence. |
| `Saved/Build/as-native-sdk-float64-int64-bytecode-fix16/20260723_224913_762_81aa18d5/UBT.log` | Build succeeded with P091/P092. | Historical build evidence. |
| `Saved/Tests/as-native-sdk-float64-int64-parameter-fix16/20260723_224931_277_ee4b9a7c/` | Float64 conversion family completed without the prior access violation; unrelated old assertions remained red. | Historical repair characterization, not a passing owner. |
| `Saved/Tests/as-native-sdk-constructor-parameter-semantics-fix16f-rerun/20260723_231304_386_bf59758c/Report/index.json` | Constructor Parameters 1/1 after semantic-oracle repair. | Historical green support, not fresh final evidence. |

## Fresh evidence — 2026-07-27

| Gate | Artifact | Result |
| --- | --- | --- |
| Canonical AOT baseline build | `Saved/Build/fix-as-double-int64-bytecode-execution_01_baseline_build/20260727_202852_089_10e42f40/RunMetadata.json` and `UBT.log` | PASS: process/runner exit `0/0`, `TimedOut=false`, duration `15272 ms`. This is the baseline-build phase of the canonical AOT workflow. |
| Standalone coherent `-NoXGE` build | `Saved/Build/fix-as-double-int64-bytecode-execution-final/20260727_204731_528_a7a7da4a/RunMetadata.json` and `UBT.log` | PASS: the exact `AngelscriptProjectEditor Win64 Development -NoEngineChanges -NoXGE` invocation is up to date with zero actions; UBT reports `Result: Succeeded`. Process/runner exit is `0/0`, `TimedOut=false`, and duration is `1512 ms`. This closes task 3.1. |
| Canonical AOT generation | `Saved/StaticJIT/Preflight/Commandlet/fix-as-double-int64-bytecode-execution_02_generate/20260727_202908_402_984e4dd6/RunMetadata.json` and `Commandlet.log` | PASS under the dedicated StaticJIT generation contract: process/runner metadata records `1/1`, while the commandlet log explicitly reports commandlet result `0` and writes all four required matched artifacts (`ASStaticJITAotFixture.as.jit.hpp`, `AngelscriptJitCode_0.jit.cpp`, `AngelscriptJitInfo.jit.cpp`, and `StaticJITAotFixture.Cache`). `RunStaticJITTests.ps1` accepts this known post-generation project-startup exit only after those artifact checks succeed. |
| Canonical generated-source build | `Saved/Build/fix-as-double-int64-bytecode-execution_03_generated_build/20260727_202929_592_4249eac7/RunMetadata.json` and `UBT.log` | PASS: process/runner exit `0/0`, `TimedOut=false`, duration `14216 ms`; the regenerated conversion bodies and their VM/Parms/raw registrations compile. |
| Canonical AOT automation | `Saved/Tests/fix-as-double-int64-bytecode-execution_04_tests/20260727_202944_840_d76cfee4/Report/index.json`, `Summary.json`, `RunMetadata.json`, and `Automation.log` | PASS: `11/11`, zero failed/skipped/not-run/in-process, process/runner exit `0/0`, `TimedOut=false`, duration `38273 ms`. Exact owner `Angelscript.TestModule.StaticJIT.AOT.FAngelscriptStaticJITAotTests.DoubleInt64ConversionsMatchInterpreter` succeeds, prints the complete fixture source, proves interpreter no-JIT/opcodes and generated three-entry/count parity, then exits through normal `Win RequestExit` with no fatal error, crash, or timeout. |
| Primary constructor owner | `Saved/Tests/fix-as-double-int64-bytecode-execution-parameters/20260727_203151_605_0fd20e0c/Report/index.json`, `Summary.json`, `RunMetadata.json`, and `Automation.log` | PASS: `1/1`, exact `FConstructorParameterTests::ParameterTypesByArityAndSelection` success, zero failed/skipped/not-run/in-process, process/runner exit `0/0`, `TimedOut=false`, duration `28347 ms`, normal exit and no crash. The printed two-word conversion cells complete without operand-word misdispatch. |
| Numeric breadth owner | `Saved/Tests/fix-as-double-int64-bytecode-execution-conversions/20260727_203229_950_2e0e4480/Report/index.json`, `Summary.json`, `RunMetadata.json`, and `Automation.log` | PASS: `4/4`, including exact `FNumericConversionTests::SourceTargetFormAndValue`, zero failed/skipped/not-run/in-process, process/runner exit `0/0`, `TimedOut=false`, duration `37346 ms`, normal exit and no crash. Signed/unsigned source-target-form results remain exact. |
| Complete AngelScript SDK prefix | `Saved/Tests/fix-as-double-int64-bytecode-execution-sdk/20260727_203343_148_771283d0/Report/index.json`, `Summary.json`, `RunMetadata.json`, and `Automation.log` | PASS: `674/674`, zero warnings/failed/skipped/not-run/in-process, process/runner exit `0/0`, `TimedOut=false`, duration `346094 ms`. Automation shuts down with `GIsCriticalError=0` and normal `Win RequestExit`; no fatal error or crash is present. This is the requested `Angelscript.TestModule.AngelScriptSDK` gate only, not a NativeCore, whole-project full-suite, or Disabled-test claim. |
| Static record gates | `openspec validate fix-as-double-int64-bytecode-execution --strict`; `openspec validate test-as-native-sdk-comprehensive-coverage --strict`; `ValidatePlanningRecords.ps1 -ProjectRoot D:\Workspace\AngelscriptProject -OutputPath <temporary-file> -RequireClean`; scoped parent/plugin `git diff --check` plus literal edited-record whitespace/EOF scan | PASS: both OpenSpec changes valid, planning violations `0`, both scoped Git checks exit `0`, and the literal edited-record scan reports no trailing whitespace, missing final newline, or NUL bytes. Plugin Git reports only informational future LF-to-CRLF normalization warnings. |

The standalone `-NoXGE` build is included above. Together with the focused
interpreter, canonical generated AOT, complete SDK, and static record gates,
all tasks in this linked change now have terminal passing evidence.

## Required fresh gates

1. Build:

   `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label fix-as-double-int64-bytecode-execution-final -TimeoutMs 1800000 -NoXGE`

2. Primary constructor owner:

   `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Language.Constructors.Parameters" -Label fix-as-double-int64-bytecode-execution-parameters -TimeoutMs 600000`

3. Numeric breadth owner:

   `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Language.Conversions.Numeric" -Label fix-as-double-int64-bytecode-execution-conversions -TimeoutMs 600000`

4. StaticJIT generated-execution parity implementation and owner:

   `FAngelscriptStaticJITAotTests::DoubleInt64ConversionsMatchInterpreter` is
   implemented under the exact prefix
   `Angelscript.TestModule.StaticJIT.AOT.FAngelscriptStaticJITAotTests.DoubleInt64ConversionsMatchInterpreter`.
   It prints the complete fixture source; proves the interpreter functions have
   `asBC_dTOi64`/`asBC_dTOu64` with no JIT entries; proves the loaded functions
   have `jitFunction`, `jitFunction_Raw`, and `jitFunction_ParmsEntry`; and
   requires exact results, cross-mode equality, entry count `1`, and cleanup.
   The fresh canonical workflow below completed on 2026-07-27; its artifacts
   and results are retained in the table above.

5. Run the new exact StaticJIT owner after implementation:

   Run the canonical generation/build/AOT sequence:

   `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunStaticJITTests.ps1 -AotOnly -LabelPrefix fix-as-double-int64-bytecode-execution -BuildTimeoutMs 1800000 -CommandletTimeoutMs 600000 -TestTimeoutMs 600000`

   Confirm the AOT report includes the exact automation method:
   `Angelscript.TestModule.StaticJIT.AOT.FAngelscriptStaticJITAotTests.DoubleInt64ConversionsMatchInterpreter`.

   Do not substitute the existing
   `Angelscript.TestModule.StaticJIT.PrimitiveConversions.BitCastAndNumericParity`
   method: it converts `int`/`asDWORD` to `double` through a helper and does
   not execute generated code.

6. Complete SDK:

   `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -Label fix-as-double-int64-bytecode-execution-sdk -TimeoutMs 600000`

Require terminal passing reports, exact signed/unsigned interpreter and
generated StaticJIT results, printed two-word bytecode/source evidence, a
retained generated-code artifact, normal cleanup/shutdown, exit/process exit
0, and no timeout/crash. Then run
`openspec validate fix-as-double-int64-bytecode-execution --strict` and scoped
whitespace checks.

The initial source implementation and static record correction deliberately
left execution to the centralized root workflow. That workflow subsequently
completed the focused interpreter and canonical AOT gates recorded above.
The standalone task-3.1 `-NoXGE` build subsequently passed and is retained in
the fresh-evidence table above. The linked change is complete. The complete SDK
result remains scoped to `Angelscript.TestModule.AngelScriptSDK`; it must not
be promoted into a NativeCore, whole-project full-suite, or Disabled-test
claim.
