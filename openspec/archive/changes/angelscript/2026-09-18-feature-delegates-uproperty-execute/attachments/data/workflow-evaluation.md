---
record: harness-workflow-evaluation-v1
result: passed
change: angelscript/feature-delegates-uproperty-execute
closure_kind: completed
input_sha256: 2c88536f1f47d2d242a159aa9e5e0a29f42e54469b94e4cc743c1f39ef7680c3
captured_at: 2026-09-19T03:10:00+08:00
---

# Completed lifecycle evaluation

Ensure plan accepted, then 1.1, 2.1, and 3.1. CallPtr remains the script source of truth. Sema admits `IsBound` and bare-target `this`; `ExecuteIfBound` is quiet when the slot is unbound; `asCallBoundUFunction` writes `CPF_ReturnParm` and Address-passed `FName`; native fire uses `FAngelscriptDelegateOperations::ProcessCallPtr` on a temporary multicast; SoftReload copies the pointer-sized slot through `FCallPtrSlotType`.

Shared proof: `ue.test` `c01796b177fd4b2fbb6b473d8daaed42` (inner `ca9fbbb10799451280a0bb60503b786e`) prefix `Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty` 17/17 Success — `AddDynamicThisFires`, `BindMissingUFunctionRejected`, `BlueprintAssignableDynamicAccepted`, `ConvertCallPtrFires`, `DynamicMulticastOneParamFires`, `DynamicMulticastPropertyFires`, `DynamicSingleCastPropertyExecute`, `ExecuteIfBoundUnboundQuiet`, `FNameParamFires`, `NativeProcessUsingPublishedSignature`, `PropertyIsBoundClearRemove`, `PropertyIsBoundReports`, `RemoveAllStopsBroadcast`, `RetValWriteback`, `ScriptBindUFunctionFires`, `SoftReloadCopiesCallPtrSlot`, `ZeroParamFires`. Grouped RED: 1.1 `618d2637798c43d590af2b90a0995a4a`; 2.1 `36b824dcaf3d473c9237b5512b0f14c7`; 3.1 `28a5928c5974488e938a64d64b24b676` and `b1de41e6b35647aca10fe4f184aed910`. Naming assumed: `FAngelscriptDelegateOperations::ProcessCallPtr`. TaskPlan is 3/3 complete.

Spec sync merged ADDED CallPtr execute requirements and the MODIFIED `Dynamic UPROPERTY members execute on the script CallPtr slot` / isolated-host seed cards into current `angelscript/runtime/delegates` and `angelscript/bindings/delegates`. Both current specs and the Change are strict-valid. Doctor succeeded. Knowledge stays change-local; no capability promotion.

Exact evolution inspection found no issues and no Review records. No Review was requested. This Change ID is not a reusable Harness gate default fixture. No accepted performance aggregates.

Omitted Language-folder execute, full cook, and PIE because Q2 limits the proving surface to NativeEngine. Overlay storage remains `angelscript/feature-delegates-property-storage`.

The input digest was obtained from ordinary exact evolution status after INDEX and completed closure YAML; this evaluation file is the only excluded input by contract.
