## Investigation Notes

This file records the exploration trail for the AS-defined `USTRUCT` delegate argument crash. It is intentionally more chronological than `design.md`.

## Original Symptom

- While expanding delegate hot reload coverage, a script delegate that passes an AS-defined `USTRUCT` value crashes during the first execution.
- The crash happens before reload assertions run, so the problem is in the base runtime value-marshalling path rather than in reload state migration.
- Focused regression prefix:
  - `Angelscript.TestModule.Delegate.ScriptStructArguments`
- Focused RED command:
  - `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Delegate.ScriptStructArguments" -Label script-struct-delegate-argument-red -TimeoutMs 600000`

## Reproduction

The focused test compiles a script payload with:

- `USTRUCT() FDelegateScriptStructPayload`
- two integer `UPROPERTY()` fields
- `delegate int FDelegateScriptStructSignal(FDelegateScriptStructPayload Payload)`
- a `UFUNCTION()` receiver method taking the same struct value
- a global function that binds the delegate and executes it

Expected result is `42`; the current runtime crashes while constructing the delegate argument buffer.

## Evidence Collected

Latest diagnostic run:

```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Delegate.ScriptStructArguments" -Label script-struct-delegate-argument-diagnostics3 -TimeoutMs 600000
```

Log:

```text
Saved\Tests\script-struct-delegate-argument-diagnostics3\20260625_173346_373_4b1c006c\Automation.log
```

Important observations:

- `Data.StackPtr` is not null when the crash occurs.
- AS source by-value parameter is represented in the generated/reflected function signature as `const FDelegateScriptStructPayload&`.
- The crashing path is:
  - delegate execution
  - `UASFunction_NotThreadSafe::RuntimeCallFunction`
  - `FUStructType::SetArgument`
  - `UScriptStruct::InitializeStruct`
  - `FASStructOps::Construct`
- Latest crash snapshot:
  - `Saved\Angelscript\CrashSnapshots\51612_20260625_173430_215`

Diagnostic lines from the latest run:

```text
[TempArgFinalize] Function=/Script/Angelscript.UDelegateScriptStructReceiver:HandlePayload Arg=Payload Size=8 Align=8 IsRef=1 IsConst=1 IsPrimitive=0 IsObject=0 Prop=StructProperty Decl=const FDelegateScriptStructPayload&
[TempArgRuntime] ArgStackSize=8 ArgStack=<non-null> Offset=0 Data=<non-null> ValueBytes=8 Behavior=4
```

Crash:

```text
Unhandled Exception: EXCEPTION_ACCESS_VIOLATION writing address 0x0000000000000000
UScriptStruct::InitializeStruct()
FUStructType::SetArgument()
UASFunction_NotThreadSafe::RuntimeCallFunction()
```

## Hypotheses Considered

### Hypothesis 1: Null delegate/event argument buffer

Rejected.

The diagnostics prove `ArgStack` and computed argument `Data` are non-null. The crash is not caused by missing parameter storage.

### Hypothesis 2: Missing `asCScriptObject` shell construction

Partially true, but incomplete.

`FASStructOps::Construct` currently executes AS construction logic while treating the destination memory as an `asCScriptObject`. The bytecode allocation path uses `ScriptObject_Construct(ScriptType, (asCScriptObject*)Mem)` before constructor execution, so the `UASStruct` path is missing a matching initialization step.

However, adding this alone does not explain why `Dest` can be invalid in the UE callback.

### Hypothesis 3: UE 5.8 fake-vtable callback ABI mismatch

Confirmed as the stronger root cause.

In UE 5.8, `UScriptStruct::ICppStructOps::Construct(void* Dest)` dispatches the fake-vtable callback as:

```cpp
void(void* Address)
```

The current AS struct callbacks are shaped as if the ops pointer is passed as an extra first argument:

```cpp
static void Construct(FASStructOps* Ops, void* Dest);
static void Destruct(FASStructOps* Ops, void* Dest);
static bool Copy(FASStructOps* Ops, void* Dest, void const* Src, int32 ArrayDim);
static bool Identical(FASStructOps* Ops, const void* A, const void* B, uint32 PortFlags, bool& bOutResult);
static uint32 GetStructTypeHash(FASStructOps* Ops, const void* Src);
```

The fake-vtable setup casts those functions to `void*`. Under the UE 5.8 callback ABI, Unreal only passes the destination address, so `Ops` receives the destination pointer and `Dest` becomes undefined. That explains the crash inside `UScriptStruct::InitializeStruct`.

## Important Correction

Earlier investigation over-weighted the missing placement construction. That finding is still relevant for correct object lifecycle, but the immediate crash is better explained by the fake-vtable callback ABI mismatch.

Also, in this AngelScript fork, `asIScriptObject` is not a normal virtual interface with a vtable stored in script struct value memory. `asCScriptObject` shell construction is still required for lifecycle consistency, but the crash is not simply a C++ vtable overwrite problem.

## Hazelight Audit

I checked the upstream Hazelight `UnrealEngine-Angelscript` history for this path to see whether the same problem had already been addressed there.

- Hazelight did ship a prior `UASStruct` compatibility update for UE 5.7 in `d6d2f8d08dc02297a7cd4a536540bc75f29ceeaa` (`Update UASStruct to work with UE 5.7 changes to ICppStructOps`).
- That upstream implementation still uses the old fake-vtable callback style that expects `FASStructOps*` as the first argument, and it does not include the AS struct value header / offset scheme introduced in this change.
- The newer Hazelight `ASStruct.cpp` history I audited does not show a later fix for the UE 5.8 fake-vtable ABI change that triggers this crash.

Follow-up comparison after checking why Hazelight does not normally reproduce this crash:

- In the local Hazelight reference (`K:\UnrealEngine\UEAS`), plugin `ASStruct.cpp` still declares callbacks as `Construct(FASStructOps* Ops, void* Dest)` and assigns them to the fake vtable through `reinterpret_cast<void*>`.
- Hazelight's engine fork also patches `Engine/Source/Runtime/CoreUObject/Public/UObject/Class.h` with `AS FIX(LV): Angelscript support` call sites that pass `this` into fake-vtable handlers:
  - `Construct()(this, Dest)`
  - `Destruct()(this, Dest)`
  - `Copy()(this, Dest, Src, ArrayDim)`
  - `Identical()(this, A, B, PortFlags, bOutResult)`
  - `GetStructTypeHash()(this, Src)`
- The stock installed UE 5.8 engine used by this repo does not pass that first `ICppStructOps*` parameter. Its equivalent calls are `Construct()(Dest)`, `Copy()(Dest, Src, ArrayDim)`, `Identical()(A, B, PortFlags, bOutResult)`, and `GetStructTypeHash()(Src)`.
- Therefore Hazelight avoids the crash because the engine fork preserves the ABI expected by its plugin. This repo's standalone-plugin target cannot assume that engine patch, so the fix must adapt `FASStructOps` to stock UE 5.8 and store the owning ops context in AS struct value memory.

Conclusion: Hazelight already handled the UE 5.7 `ICppStructOps` adjustment and keeps the old callback shape valid through engine-side Angelscript support. This UE 5.8 delegate crash is a stock-engine pluginization gap that still needs the local runtime fix recorded here.

## Fix Direction

The fix should make `FASStructOps` callbacks match Unreal's fake-vtable ABI and provide a way to recover the owning AS struct ops from value memory:

- reserve a small per-instance header for AS-defined `USTRUCT` values;
- shift script property offsets by that header using pre-class data during struct compilation;
- write the owning `FASStructOps` pointer into the header during construction;
- adapt fake-vtable callbacks to Unreal's expected signatures:
  - `Construct(void* Dest)`
  - `Destruct(void* Dest)`
  - `Copy(void* Dest, const void* Src, int32 ArrayDim)`
  - `Identical(const void* A, const void* B, uint32 PortFlags, bool& bOutResult)`
  - `GetStructTypeHash(const void* Src)`
- use scoped/TLS initialization context only where Unreal gives no callback context before the destination header has been written;
- remove temporary diagnostic logs from `ASClass.cpp` before final verification.

## Regression Rule

AS-defined `USTRUCT` delegate/UFUNCTION arguments need a real delegate execution test, not only a compile or hot reload metadata test. This path exercises:

- `FScriptCall::PushArgument`
- UE event argument storage
- `FFrame::StepCompiledInRef`
- `FUStructType::SetArgument`
- `UScriptStruct::InitializeStruct`
- `UASStruct` CppStructOps callbacks
