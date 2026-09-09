# Task 6.5 — reflected UFunction execution

## Outcome

The serial reflected snapshot now records each owned `UFunction` with its native owner, eligibility, generated-versus-reflective dispatch, typed parameters, directions, defaults, and retained reflection identities. Recording converts those descriptions into detached generic method members. Installation resolves inherited methods through the installed parent chain and retains each native `UFunction` as auxiliary callable state.

The typed invocation adapter validates the receiver, argument count, parameter direction, and UObject argument compatibility. It initializes the native parameter frame, copies input values with `FProperty`, invokes `ProcessEvent`, copies out/inout and return values into caller-owned storage, and destroys the temporary native frame. UE implicit-handle classes use their canonical spelling without an explicit `@`.

## Behavioral RED

Run `92826eb0d5ee4fa5b163871d8abd2bfa` executed the exact seven-case selector with only the typed invocation adapter deliberately unavailable. Five behavioral cases failed and two installation/accounting controls succeeded:

- `GeneratedMethodIsSelectedOverReflectiveFallback`
- `InheritedFunctionUsesChildReceiverAndParentOwner`
- `InvalidReceiverObjectAndDirectionAreDiagnosed`
- `OutAndInOutWriteBackSevenAndEight`
- `StringAndStructReturnsOwnIndependentLifetime`

This is behavioral RED: the snapshot, declarations, callable image, generic `Add` callable, and eligible-method accounting remained valid while direct typed execution was absent. Earlier runs that failed provider sealing or final image creation were fixture/setup failures and are not used as RED evidence.

## GREEN

- Build `13bd7363c70a4bc3b4efe915d3337113`: `AngelscriptProjectEditor` succeeded.
- Exact run `4d9c612db1314400815d01c347934e19`: all 7 `Angelscript.UnitTest.RuntimeBindings.Reflection.Functions.` cases succeeded, with zero warnings, errors, skipped, not-run, or incomplete cases.

Exact cases:

- `AllEligibleMethodsAndDefaultsAreAccounted`
- `GeneratedMethodIsSelectedOverReflectiveFallback`
- `InheritedFunctionUsesChildReceiverAndParentOwner`
- `InvalidReceiverObjectAndDirectionAreDiagnosed`
- `OutAndInOutWriteBackSevenAndEight`
- `ReflectedAddExecutesThroughInstalledGenericCallable`
- `StringAndStructReturnsOwnIndependentLifetime`

## Identities

Final SHA-256 identities:

- `AngelscriptTypeBindInfoReflection.h`: `49296C5585657538FD1C03A5B55D19FBD5359F7580AE75B2F362075D5E744DD7`
- `AngelscriptTypeBindInfoReflection.cpp`: `3CB1ABB1D4098CE51A8B24D3577CE145E6084621B9FDD7C94B0F0F4980728203`
- `AngelscriptTypeBindInfoApply.h`: `D17E0F95E297EC2F7B485339E44CEB7964751043DCC06C017B15FE614F04BE5C`
- `AngelscriptTypeBindInfoApply.cpp`: `7899DB68E1F99AB80FA43CA90E2681F77EB4B57192078387F795EC851FBA6585`
- `RuntimeBindingFunctionTestTypes.h`: `C58CD9B076ED978FF3215F1C8A5D34BACCB11A51A42E8AB4FBEA5106B987DF64`
- `RuntimeBindingFunctionsTests.cpp`: `9152400C67B2357C1AFF81FC207299F4127D07F970983CBA0A0140EA1D28FE42`
- `UnrealEditor-AngelscriptRuntime.dll`: `3A0B1082ED43B41B2CE3D597B7ADBC782A71AE5B07CE386D1F8D86D1347E01E5`
- `UnrealEditor-AngelscriptTest.dll`: `018EA1BB3ED53AF830BA5BAB263A995856725DB2233A2294F955CD1E1B64F367`

No expanded RuntimeBindings, NativeEngine, baseline, packaging, performance, JIT, or legacy suite was run. The exact seven-case task selection proves the newly introduced reflection-function capture, installation, dispatch, argument, lifetime, inheritance, diagnostic, and accounting contracts. The next shared expansion belongs to the later task that changes or consumes this surface, while final NativeEngine and baseline gates remain owned by tasks 8.4 and 8.3.
