# Verification Notes

## 2026-06-30

### Build Baseline

- Command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label coverage-goal-build-1 -TimeoutMs 1800000`
- Result: passed, exit code `0`.
- Log: `Saved\Build\coverage-goal-build-1\20260630_004529_194_119943fb\UBT.log`.
- Notes: target was up to date.

### Full Coverage Run

- Command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage" -Label coverage-goal-tests-1 -TimeoutMs 1800000`
- Result: failed, runner exit code `1`, editor process exit code `3`.
- Summary: `Saved\Tests\coverage-goal-tests-1\20260630_004544_881_e9d5d3e7\Summary.json`.
- Log: `Saved\Tests\coverage-goal-tests-1\20260630_004544_881_e9d5d3e7\Automation.log`.
- Report: `Saved\Tests\coverage-goal-tests-1\20260630_004544_881_e9d5d3e7\Report`.
- First observed failure groups:
  - `Coverage.Animation.AnimInstance`: positive module calls `UCoverageAnimInstance::GetCurveValueWithDefault` with a mismatched AS signature.
  - `Coverage.AssetLoading`: positive `LoadObject` calls use an unsupported AS signature.
  - `Coverage.ClassFeatures`, `Coverage.ClassLifecycle`, `Coverage.Component`, `Coverage.Delegate`, `Coverage.DynamicDelegate`, `Coverage.Event`: multiple positive modules still reference APIs or override surfaces not bound on the current fork, or boundary tests expect outdated diagnostic fragments.
  - `Coverage.FLinearColorExpression`: `Desaturate` is not bound; the failed positive module then crashed by constructing `FASGlobalFunctionInvoker` with a null module.

### FLinearColorExpression Fix

- Root cause: `FLinearColor.Desaturate` is not part of the current AS binding surface (`Bind_FLinearColor.cpp` binds `ToFColor`, `GetClamped`, `Equals`, `IsAlmostBlack`, `GetMin`, `GetMax`, `GetLuminance`, HSV conversion, and namespace helpers, but not `Desaturate`). The positive module failed to compile and then dereferenced the null module. Float-return assertions also read AS `float` as C++ `float`, while this fork uses double-backed AS `float`.
- Resolution:
  - Kept existing positive method coverage for bound APIs.
  - Converted `Desaturate` into an explicit negative compile-boundary test instead of deleting it.
  - Added module null guards before invoking compiled functions.
  - Read AS `float` returns as `double` in this file's helper.
- Build command after patch: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label coverage-flinearcolor-build-1 -TimeoutMs 1800000`
- Build result: passed, exit code `0`; log `Saved\Build\coverage-flinearcolor-build-1\20260630_005120_002_bd796c53\UBT.log`.
- Narrow test command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.FLinearColorExpression" -Label coverage-flinearcolor-2 -TimeoutMs 600000`
- Narrow test result: passed, `7/7`; summary `Saved\Tests\coverage-flinearcolor-2\20260630_005142_646_fffc437c\Summary.json`.

### Build And Coverage Rerun

- Build command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label coverage-goal-build-2 -TimeoutMs 1800000`
- Build result: passed, exit code `0`; log `Saved\Build\coverage-goal-build-2\20260630_010301_828_18485151\UBT.log`.
- Full Coverage command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage" -Label coverage-goal-tests-3 -TimeoutMs 1800000`
- Full Coverage result: failed/crashed, runner exit code `1`, editor exit code `3`; summary `Saved\Tests\coverage-goal-tests-3\20260630_010315_507_5b80421c\Summary.json`; log `Saved\Tests\coverage-goal-tests-3\20260630_010315_507_5b80421c\Automation.log`.
- First crash root: `Coverage.FRotatorExpression.RotatorStaticMethods` compiled a positive module containing unsupported `FRotator::Lerp`, then dereferenced a null module through `FASGlobalFunctionInvoker`.

### FRotatorExpression Fix

- Root causes:
  - `FRotator::Lerp` is not bound on the current AS surface; only `MakeFromEuler`, axis helpers, conversion methods, and math/library interpolation helpers are available.
  - `FRotator.Clamp()` clamps with native `FRotator::Clamp()` semantics, not a pitch-only `[-90, 90]` assertion.
  - AS `float` returns must be read as `double` on this fork.
  - `public:` inside a plain script class is rejected by current AS syntax; plain script class local values also execute as the known null-reference boundary already covered by inheritance tests.
  - Unary negation diagnostic text is `Function 'opNeg()' not found`, not the older `No matching signatures` form.
- Resolution:
  - Kept positive coverage for bound construction, arithmetic, comparison, members, normalization, conversion, `MakeFromEuler`, and confirmed helpers.
  - Converted unsupported `FRotator::Lerp` into an explicit negative compile-boundary test.
  - Added a null module guard before static-method invocation.
  - Changed plain script class member access to an explicit runtime exception boundary instead of deleting the case.
  - Adjusted `Clamp`, `IsNearlyZero`, float-return reads, and unary-negation diagnostic expectations to current behavior.
- Build command after patch: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label coverage-frotator-build-3 -TimeoutMs 1800000`
- Build result: passed, exit code `0`; log `Saved\Build\coverage-frotator-build-3\20260630_011103_931_03ca2e91\UBT.log`.
- Narrow test command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.FRotatorExpression" -Label coverage-frotator-3 -TimeoutMs 600000`
- Narrow test result: passed, `10/10`; summary `Saved\Tests\coverage-frotator-3\20260630_011122_157_4e751014\Summary.json`.

### FStringExpression Fix

- Full Coverage rerun before this fix:
  - Command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage" -Label coverage-goal-tests-4 -TimeoutMs 1800000`
  - Result: failed/crashed, runner exit code `1`, editor exit code `3`; summary `Saved\Tests\coverage-goal-tests-4\20260630_011248_592_71210c01\Summary.json`; log `Saved\Tests\coverage-goal-tests-4\20260630_011248_592_71210c01\Automation.log`.
  - Crash root: `Coverage.FStringExpression.StringConversions` compiled a positive module containing unsupported `FCString::Atoi` / `FCString::Atof`; compile diagnostics reported `Namespace 'FCString' doesn't exist`, then the test dereferenced a null module through `FASGlobalFunctionInvoker`.
- Additional narrow-run failures found while fixing:
  - Plain script-class `FString` / `FName` / `FText` members compile but execute as the same null-reference boundary already recorded for primitive and `FRotator` expression coverage.
  - `FText::IdenticalTo` follows UE identity semantics for separate `FText::FromString` values, so equal display text is not identical.
  - `FName.GetPlainNameString()` strips numbered suffixes such as `_17`; `ToString()` remains the path for preserving that suffix.
  - `FString::Format("{0}", 2.5f)` is covered in method tests; expression conversion now uses `FString::SanitizeFloat(2.5)` for current float-to-string behavior.
- Resolution:
  - Kept supported `FString`/`FName`/`FText` conversion coverage positive.
  - Converted `FCString::Atoi` and `FCString::Atof` into explicit negative compile-boundary cases.
  - Converted plain script-class string-family member access to explicit runtime exception boundaries.
  - Adjusted `FText::IdenticalTo`, `GetPlainNameString`, and float string conversion expectations to current UE/AS behavior.
- Build command after patch: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label coverage-fstring-build-2 -TimeoutMs 1800000`
- Build result: passed, exit code `0`; log `Saved\Build\coverage-fstring-build-2\20260630_012522_731_ceb5b905\UBT.log`.
- Narrow test command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.FStringExpression" -Label coverage-fstring-3 -TimeoutMs 600000`
- Narrow test result: passed, `9/9`; summary `Saved\Tests\coverage-fstring-3\20260630_012542_346_69e3c6c9\Summary.json`; report `Saved\Tests\coverage-fstring-3\20260630_012542_346_69e3c6c9\Report\index.json`.

### FTransformExpression / FTransformFunction Progress

- Full Coverage rerun before this fix:
  - Command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage" -Label coverage-goal-tests-5 -TimeoutMs 1800000`
  - Result: failed/crashed, runner exit code `1`, editor exit code `3`; summary `Saved\Tests\coverage-goal-tests-5\20260630_093028_809_fcaf2930\Summary.json`; log `Saved\Tests\coverage-goal-tests-5\20260630_093028_809_fcaf2930\Automation.log`.
  - Crash root: `Coverage.FTransformFunction.FunctionParametersIn` dereferenced a null module after the positive module failed to compile because direct `FTransform.Location` member access is not bound.
- Root causes:
  - `FTransform.Location`, `FTransform.Scale3D`, and `FTransform.Rotation` are not exposed as direct AS members; the current binding surface exposes accessor and mutator methods such as `GetLocation`, `GetScale3D`, `SetLocation`, `SetScale3D`, `SetRotation`, and `AddToTranslation`.
  - `Math::Lerp(FTransform, FTransform, float)` is not bound; `FTransform::Blend` is available.
  - Raw AS `float` return handling in these tests must read as `double` because this fork uses `asEP_FLOAT_IS_FLOAT64=1`.
- Resolution:
  - Replaced direct positive member access with bound `FTransform` accessor/mutator APIs.
  - Converted direct member access and `Math::Lerp(FTransform)` into explicit negative compile-boundary coverage.
  - Added null module guards before invoking FTransform function modules.
  - Changed default-parameter verification to execute through a script wrapper instead of resolving an omitted-argument raw invoker signature.
  - Kept `FTransform&inout` mutation as positive coverage. The intermediate `coverage-ftransform-function-5` run proved `SetScale3D` writes back to caller storage after the test module was rebuilt, so it is not a negative boundary.
- Build command after patch: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label coverage-ftransform-build-2 -TimeoutMs 1800000`
- Build result: passed, exit code `0`.
- Narrow test command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.FTransformFunction" -Label coverage-ftransform-function-3 -TimeoutMs 600000`
- Narrow test result: failed, `7/8`; summary `Saved\Tests\coverage-ftransform-function-3\20260630_094021_281_9e8e67f4\Summary.json`; log `Saved\Tests\coverage-ftransform-function-3\20260630_094021_281_9e8e67f4\Automation.log`.
- Intermediate build command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label coverage-ftransform-build-3 -TimeoutMs 1800000`
- Intermediate build result: passed, exit code `0`; log `Saved\Build\coverage-ftransform-build-3\20260630_095042_249_9ae58d01\UBT.log`.
- Intermediate narrow test command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.FTransformFunction" -Label coverage-ftransform-function-5 -TimeoutMs 600000`
- Intermediate narrow test result: failed, `7/8`; summary `Saved\Tests\coverage-ftransform-function-5\20260630_095107_809_cdc3738b\Summary.json`. The failure was the intentionally inverted boundary assertion for `SetScale3D`, which showed the mutator actually writes back.
- Final build command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label coverage-ftransform-build-4 -TimeoutMs 1800000`
- Final build result: passed, exit code `0`; log `Saved\Build\coverage-ftransform-build-4\20260630_095211_984_e5986256\UBT.log`.
- Final FTransformFunction narrow test command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.FTransformFunction" -Label coverage-ftransform-function-6 -TimeoutMs 600000`
- Final FTransformFunction narrow test result: passed, `8/8`; summary `Saved\Tests\coverage-ftransform-function-6\20260630_095230_124_23f04847\Summary.json`; report `Saved\Tests\coverage-ftransform-function-6\20260630_095230_124_23f04847\Report\index.json`.
- FTransformExpression narrow test command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.FTransformExpression" -Label coverage-ftransform-expression-1 -TimeoutMs 600000`
- FTransformExpression narrow test result: passed, `8/8`; summary `Saved\Tests\coverage-ftransform-expression-1\20260630_095311_062_86e14b55\Summary.json`; report `Saved\Tests\coverage-ftransform-expression-1\20260630_095311_062_86e14b55\Report\index.json`.

### FVector2DExpression Fix

- Full Coverage rerun before this fix:
  - Command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage" -Label coverage-goal-tests-6 -TimeoutMs 900000`
  - Result: failed/crashed, runner exit code `1`, editor exit code `3`; summary `Saved\Tests\coverage-goal-tests-6\20260630_095430_582_3b54cc6e\Summary.json`; log `Saved\Tests\coverage-goal-tests-6\20260630_095430_582_3b54cc6e\Automation.log`.
  - Crash root: `Coverage.FVector2DExpression.Vector2DConstruction` compiled a positive module containing unsupported `FVector2D(5.0)`, `FVector2D::One`, `FVector2D::UnitX`, and `FVector2D::UnitY`, then dereferenced a null module through `ExpectGlobalReturn`.
- Root causes:
  - The current `FVector2D` AS binding surface exposes `FVector2D()`, `FVector2D(X, Y)`, `ZeroVector`, and `UnitVector`, but not the single-value constructor or `One` / `UnitX` / `UnitY` constants.
  - `FVector2D.DotProduct` is bound as a method, but the `A | B` operator is not exposed for `FVector2D`.
  - Raw AS `float` return handling in this file must read through `double` because this fork uses `asEP_FLOAT_IS_FLOAT64=1`.
- Resolution:
  - Kept supported construction and dot-product behavior as positive coverage.
  - Converted the single-value constructor, unbound constants, and `A | B` dot operator into explicit negative compile-boundary coverage.
  - Added module null guards before invoking FVector2D expression globals.
  - Read AS `float` returns through `double` in the helper.
- First build command after patch: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label coverage-fvector2dexpr-build-1 -TimeoutMs 1800000`
- First build result: passed, exit code `0`; log `Saved\Build\coverage-fvector2dexpr-build-1\20260630_095731_772_0d5ecab1\UBT.log`.
- First narrow test command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.FVector2DExpression" -Label coverage-fvector2dexpr-1 -TimeoutMs 600000`
- First narrow test result: failed, `4/5`; summary `Saved\Tests\coverage-fvector2dexpr-1\20260630_095757_581_e9697da3\Summary.json`. Remaining failure was `Vector2DDotProduct`, where the `A | B` operator is not exposed for `FVector2D`.
- Final build command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label coverage-fvector2dexpr-build-2 -TimeoutMs 1800000`
- Final build result: passed, exit code `0`; log `Saved\Build\coverage-fvector2dexpr-build-2\20260630_100302_857_20791217\UBT.log`.
- Final narrow test command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.FVector2DExpression" -Label coverage-fvector2dexpr-2 -TimeoutMs 600000`
- Final narrow test result: passed, `5/5`; summary `Saved\Tests\coverage-fvector2dexpr-2\20260630_100344_276_fc943945\Summary.json`; report `Saved\Tests\coverage-fvector2dexpr-2\20260630_100344_276_fc943945\Report\index.json`.

### FVector2DFunction Fix

- Full Coverage rerun before this fix:
  - Command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage" -Label coverage-goal-tests-7 -TimeoutMs 900000`
  - Result: failed/crashed, runner exit code `1`, editor exit code `3`; summary `Saved\Tests\coverage-goal-tests-7\20260630_100529_188_6628e14b\Summary.json`; log `Saved\Tests\coverage-goal-tests-7\20260630_100529_188_6628e14b\Automation.log`.
  - Crash root: `Coverage.FVector2DFunction.FunctionParametersIn` compiled a positive module containing unsupported `FVector2D.Length()`, then dereferenced a null module through `FASGlobalFunctionInvoker`.
- Root causes:
  - `FVector2D` binds `Size()` and `SizeSquared()`, not `Length()`.
  - `FVector2D.Distance` is bound as a member method, not as static `FVector2D::Distance(A, B)`.
  - Raw AS `float` return and scalar argument handling in this file needs double-backed reads/writes where the current fork exposes `float64` behavior.
  - Omitted default arguments are not reliably invokable by resolving a shortened raw global signature; the default path should execute through a script wrapper that calls the defaulted function.
- Resolution:
  - Kept value, `&in`, `&out`, `&inout`, return, default, and UFUNCTION paths as positive coverage using the current binding surface.
  - Converted unsupported `FVector2D.Length()` and static `FVector2D::Distance(A, B)` into explicit compile-boundary tests.
  - Added module null guards before invoking compiled modules.
  - Changed default-parameter verification to execute through `AddUsingDefault`.
- First build command after patch: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label coverage-fvector2dfunc-build-1 -TimeoutMs 1800000`
- First build result: passed, exit code `0`; log `Saved\Build\coverage-fvector2dfunc-build-1\20260630_100916_603_6444f79c\UBT.log`.
- First narrow test command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.FVector2DFunction" -Label coverage-fvector2dfunc-1 -TimeoutMs 600000`
- First narrow test result: failed, `5/7`; summary `Saved\Tests\coverage-fvector2dfunc-1\20260630_100944_620_a013b199\Summary.json`. Remaining failures were `FunctionParametersValue` for static `FVector2D::Distance(A, B)` and `FunctionParametersInOut` for the scalar argument path.
- Final build command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label coverage-fvector2dfunc-build-2 -TimeoutMs 1800000`
- Final build result: passed, exit code `0`; log `Saved\Build\coverage-fvector2dfunc-build-2\20260630_101210_437_c247c411\UBT.log`.
- Final narrow test command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.FVector2DFunction" -Label coverage-fvector2dfunc-2 -TimeoutMs 600000`
- Final narrow test result: passed, `7/7`; summary `Saved\Tests\coverage-fvector2dfunc-2\20260630_101237_807_14bd826b\Summary.json`; report `Saved\Tests\coverage-fvector2dfunc-2\20260630_101237_807_14bd826b\Report\index.json`.
