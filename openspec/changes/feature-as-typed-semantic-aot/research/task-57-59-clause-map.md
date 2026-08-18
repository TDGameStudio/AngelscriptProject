# Tasks 5.7 and 5.9 clause map

This is the close-out evidence for the two remaining group-5
umbrellas. Later sibling tasks (5.8, 5.9a, 5.9b, 5.10–5.14, 4.16)
implemented most clauses in capability-owned files. The 2026-08-15 note
that production still rejects a script/internal-helper closure is stale:
`ProductionTypedASTBackendEmitsDirectScriptHelperInOwningModule` and the
checked TestJIT recursion fixture both emit `ASJIT_Helper_*` raw calls.

5.10 superseded 5.7's "invoke the imported DLL symbol" wording for
non-inline exports. Those now use `CurrentNativeBinding` /
`InvokeBoundNative`. `HeaderInline` remains a literal symbol invoke.

## 5.7

| Clause | Owner |
| --- | --- |
| Reverse ordinary-call evaluation then formal-order call | `TypedASTJITGeneratedOutputTests.NativeCallArgumentsPreserveEvaluationAndFormalOrder`, `DirectScriptHelperCallsThreadExecutionAndCheckFailureImmediately` |
| Direct concrete script / non-UFUNCTION helper raw call | `GenerationEngineTests.ProductionTypedASTBackendEmitsDirectScriptHelperInOwningModule`; baked `ASStaticJITTypedRecursionFixture*.jit.cpp`; `NativeBridge.PublishedGoldens.PublishedRecursionFixtureKeepsDirectScriptHelperRawCall` |
| `ExportedSymbol` / current native slot | `GeneratedOutputTests.ExportedBindUsesTheCurrentEngineNativeSlot`; baked DaysInMonth `InvokeBoundNative` |
| `HeaderInline` literal symbol | `GenerationEngineTests` IsRunningCommandlet cases; `NativeBridge.PublishedGoldens.PublishedCoreFixtureKeepsHeaderInlineDirectSymbol` |
| `ExportedRuntimeCallable` / Print | AOT Print fixture + 5.5/5.12 |
| Provider-private native form | `GeneratedOutputTests.ProviderPrivateCallNamesItsBridgeTargetAndThreadsExecution`; private-bridge fixture |
| Scalar return conversion | `TypedASTJITNativeBridgeTests.ScalarKindsPreserveTheirExactAngelScriptABI` |
| Immediate exception check after formal temporaries | helper/bridge generated-output tests; published recursion/bridge goldens |
| Root/helper/bridge frame restoration | `AOT.RuntimeRoutes.FrameRecursion` |
| Golden bridge row: declaration, callee, Runtime core, slot | baked private-bridge fixture; `NativeBridge.PublishedGoldens.PublishedBridgeFixtureKeepsNamedInvokeBoundRow` |
| `InvokeBound<Return, Args...>(Execution, CallSiteRow, ...)` | same |
| No `FAngelscriptJITExecutionContext`, pointer literal, FunctionId, guessed extern | published goldens + generated-output negatives |
| Slot identity ignores diagnostic strings | `TypedASTJITNativeBridgeTests.DiagnosticStringsCannotRedirectTheResolvedSlot` |
| Rebind/unbind/Engine replacement | `TypedASTJITNativeBridgeTests` + 5.12 AOT private-bridge runtime |

## 5.9

| Clause | Owner |
| --- | --- |
| Header `InvokeBound<Return, Args...>` + exported `InvokeBoundViaVM` | `AngelscriptTypedASTJITCallBridge.h/.cpp`; `SeparateTestJITModuleImportsTheFixedRuntimeCore` |
| Separate VM-bridge ABI vs native scalar ABI | 5.9b + `TypedASTJITBridgeABI` |
| Immutable `FAngelscriptTypedASTJITBoundCallSite` row in `.jit.cpp` | published bridge golden |
| `bRequiresExecutionState` only on bridge/helper closures | generated-output direct-only vs bridge tests |
| Slot load, Prepare/SetArg*/Execute, scalar result | `ScalarArgumentsAndResultUseTheCurrentEngineBoundSlot` |
| Unexported system function enters `Execute -> CallSystemFunction` | same; generic representative `NestedVMExceptionStopsTheTypedCallerAndReturnsNoValue` (`asCALL_GENERIC`) |
| First nested VM exception adopted exactly once | that method plus 4.16 `asSJITFailureRecord` |
| Inspection/dump `AS declaration -> InvokeBound -> InvokeBoundViaVM -> slot -> target` | `AngelscriptStaticJITDiagnosticsTests` + AOT call diagnostics |
| Rebind/unbind/Engine replacement without baked pointer/FunctionId | 5.9a/5.10/5.12 |

Do not mark either umbrella `[x]` from this file alone. Mark only after
the official `Angelscript.TestModule.StaticJIT.NativeBridge` prefix is
GREEN on the published-golden methods.
