# Delegates And Events Coverage Matrix

> **This matrix is the design specification header for delegate/event tests**: each row is a concrete verifiable scenario guiding the four test files. ⬜ means pending, ✅ identifies the covering `TEST_METHOD`, and 🚫 means fork unsupported.
>
> - Test files: `Delegate`(13) / `MulticastDelegate`(11) / `DynamicDelegate`(12) / `Event`(16) Tests.cpp
> - Automation prefix: `Angelscript.TestModule.Coverage.<Delegate|MulticastDelegate|DynamicDelegate|Event>`
> - See `../coverage-matrix.md` for the legend; delegate boundaries are in `../coverage-gaps.md §2.4`.

## 1. Single-Cast Delegates, DelegateTests 13

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Basic declaration / bind / execute | ✅ | `DelegateBasics` |
| Parameters / parameter types / return value | ✅ | `DelegateParameters` `DelegateParameterTypes` `DelegateReturnValue` |
| ExecuteIfBound | ✅ | `DelegateExecuteIfBound` |
| Signature matrix | ✅ | `DelegateSignatureMatrix` |
| Object and enum return values | ✅ | `DelegateObjectAndEnumReturnValues` |
| Rebinding / member runtime clear | ✅ | `DelegateRebinding` `DelegateMemberRuntimeClearBoundary` |
| Member and parameter reflection | ✅ | `DelegateMemberAndParameterReflection` |
| Script struct UFUNCTION parameter / script struct parameter execution | ✅ | `DelegateScriptStructUFunctionParameterExecutes` `DelegateScriptStructParameterExecutes` |
| Lambda syntax binding unsupported | 🚫 | `DelegateLambdaSyntaxIsUnsupported` |

## 2. Multicast Delegates, MulticastDelegateTests 11

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Basic Add/Broadcast | ✅ | `MulticastBasics` |
| Multiple listeners | ✅ | `MulticastMultipleListeners` |
| Handle management / Clear / RemoveAll | ✅ | `MulticastHandleManagement` `MulticastClear` `MulticastRemoveAll` |
| Parameters / parameter type matrix | ✅ | `MulticastParameters` `MulticastEventParameterTypeMatrix` |
| Mixed UFUNCTION listeners | ✅ | `MulticastMixedUFunctionListeners` |
| Object unbinding removes target listeners | ✅ | `MulticastUnbindObjectRemovesTargetListeners` |
| Event declaration metadata | ✅ | `MulticastEventDeclarationMetadata` |
| Lambda syntax unsupported | 🚫 | `MulticastLambdaSyntaxIsUnsupported` |

## 3. Dynamic Delegates, DynamicDelegateTests 12

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Dynamic delegate basics / dynamic multicast | ✅ | `DynamicDelegateBasics` `DynamicMulticastDelegate` |
| Parameters / complex parameters / return value | ✅ | `DynamicDelegateParameters` `DynamicDelegateComplexParameters` `DynamicDelegateReturnValue` |
| BlueprintAssignable/Callable metadata | ✅ | `DynamicDelegateBlueprintAssignableAndCallableMetadata` |
| Serialization round trip | ✅ | `DynamicDelegateSerializationRoundTrip` |
| Clear | ✅ | `DynamicDelegateClear` |
| Struct payload property execution / declared single-cast runtime / declaration metadata | ✅ | `DynamicDelegateStructPayloadPropertyExecutes` `DynamicDelegateDeclaredSingleCastRuntime` `DynamicDelegateDeclarationMetadata` |
| Dynamic macro names are not script APIs | 🚫 | `DynamicMacroNamesAreNotScriptAPIs` |

## 4. Events, EventTests 16

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Bind and trigger / lifecycle / unbinding | ✅ | `EventBindAndTrigger` `EventLifecycle` `EventUnbinding` |
| Declaration metadata / BlueprintEvent metadata and execution | ✅ | `EventDeclarationMetadata` `EventBlueprintEventMetadataAndExecution` |
| Multiple handlers / collision / chaining | ✅ | `EventMultipleHandlers` `EventCollision` `EventChaining` |
| Built-in Actor/component instances / Widget event instances / Timer events | ✅ | `EventBuiltInActorAndComponentInstances` `EventWidgetEventInstances` `EventTimer` |
| Custom game events | ✅ | `EventCustomGameEvents` |
| RepNotify triggers state changes | ✅ | `EventRepNotifyExecutesStateChange` |
| Non-script-facing boundaries | 🚫 | `EventNonScriptFacingBoundaries` |
| Lambda syntax unsupported | 🚫 | `EventLambdaSyntaxIsUnsupported` |

---

## Summary

| File | Methods |
|------|------|
| Delegate | 13 |
| MulticastDelegate | 11 |
| DynamicDelegate | 12 |
| Event | 16 |
| **Total** | **52** |

**Pending (⬜)**: no hard gaps currently. Lambda binding, `BindStatic`, and multicast return values are fork-not-applicable items, documented in `../coverage-gaps.md §2.4` and guarded by `*LambdaSyntaxIsUnsupported` and related boundaries.
