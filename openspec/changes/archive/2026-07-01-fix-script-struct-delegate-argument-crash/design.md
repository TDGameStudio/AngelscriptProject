## Context

AS-defined `USTRUCT` types are exposed to Unreal as `UScriptStruct` values, but their backing memory is also used by AngelScript value-object lifecycle code. Unreal delegate/event marshalling allocates argument storage in `FScriptCall::PushArgument`, calls `FAngelscriptTypeUsage::ConstructValue`, and reaches `UScriptStruct::InitializeStruct`.

The focused delegate regression proves the crash is not caused by missing argument storage: the generated function receives a non-null argument stack, and the AS by-value struct parameter is lowered to the reflected declaration `const FDelegateScriptStructPayload&`.

The stronger root cause is the UE 5.8 fake-vtable callback ABI used by `UScriptStruct::ICppStructOps`. UE calls the fake-vtable callbacks with signatures such as `void(void* Address)`, but `FASStructOps` currently registers callbacks that expect an extra leading `FASStructOps*` argument. Once Unreal calls `Construct`, the callback interprets destination memory as the ops pointer and reads the real destination from an undefined argument slot.

There is a second lifecycle correctness issue in the same path: script struct value memory must have a valid AngelScript object shell before AS constructor logic runs. The third-party bytecode allocation path already uses `ScriptObject_Construct(ScriptType, (asCScriptObject*)Mem)` before executing AS constructors. The `UASStruct` path should follow the same ordering after the callback ABI is fixed.

## Goals / Non-Goals

**Goals:**

- Make `FASStructOps` fake-vtable callbacks match Unreal's UE 5.8 `ICppStructOps` callback ABI.
- Make `UASStruct` construction through Unreal `UScriptStruct` ops produce initialized AngelScript struct value storage before AS constructor execution.
- Preserve copy, destruct, identical, and hash behavior for initialized AS struct values.
- Add a standalone regression test for AS `USTRUCT` delegate argument invocation.
- Keep the existing broader hot reload delegate parameter test as reload coverage after the runtime fix.

**Non-Goals:**

- Redesign AngelScript object storage or change the UObject-backed `asIScriptObject::GetObjectType()` override.
- Add special-case delegate/event marshalling for script structs.
- Change native `UScriptStruct` construction semantics.

## Evidence

Detailed investigation notes are stored in `notes.md`.

Key evidence:

- RED prefix: `Angelscript.TestModule.Delegate.ScriptStructArguments`.
- Diagnostic command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Delegate.ScriptStructArguments" -Label script-struct-delegate-argument-diagnostics3 -TimeoutMs 600000`.
- Diagnostic log: `Saved\Tests\script-struct-delegate-argument-diagnostics3\20260625_173346_373_4b1c006c\Automation.log`.
- `ArgStack` and argument `Data` are non-null when the crash occurs.
- The crash happens through `UScriptStruct::InitializeStruct` -> `FUStructType::SetArgument` -> `UASFunction_NotThreadSafe::RuntimeCallFunction`.
- UE 5.8 fake-vtable callback types do not pass the `ICppStructOps` pointer into construct/destruct/copy/identical/hash callbacks.

## Hazelight Audit

I checked the upstream Hazelight `UnrealEngine-Angelscript` history for an equivalent fix before recording this local change.

- Hazelight did already ship a `UASStruct` compatibility update for UE 5.7 in `d6d2f8d08dc02297a7cd4a536540bc75f29ceeaa` (`Update UASStruct to work with UE 5.7 changes to ICppStructOps`).
- That upstream implementation still follows the older fake-vtable shape that expects an `FASStructOps*` argument, and it does not include the AS struct value header / offset reservation introduced here.
- I did not find a later Hazelight follow-up that addresses the UE 5.8 fake-vtable ABI change behind this crash.
- The reason Hazelight does not hit this exact crash in their normal baseline is that their engine fork carries `CoreUObject` changes that still pass `ICppStructOps* this` into fake-vtable handlers. In the local Hazelight reference, `Engine/Source/Runtime/CoreUObject/Public/UObject/Class.h` has `AS FIX(LV): Angelscript support` call sites such as `Construct()(this, Dest)`, `Copy()(this, Dest, Src, ArrayDim)`, `Identical()(this, A, B, ...)`, and `GetStructTypeHash()(this, Src)`.
- Stock Epic UE 5.8 does not include that Hazelight engine-fork ABI extension. The installed UE 5.8 `Class.h` calls handlers as `Construct()(Dest)`, `Copy()(Dest, Src, ArrayDim)`, `Identical()(A, B, ...)`, and `GetStructTypeHash()(Src)`, so a standalone plugin cannot rely on the engine passing the ops pointer.
- Boundary conclusion: Hazelight already absorbed the UE 5.7 `ICppStructOps` transition and keeps the old `FASStructOps*` callback style working through their engine fork. This repo targets a standalone plugin on stock UE 5.8, so the compatibility fix belongs in `UASStruct` / `FASStructOps` rather than in an engine patch.

## Decisions

- Fix at `FASStructOps` / `UASStruct` lifecycle, not `FScriptCall::PushArgument`.
  - Rationale: delegate argument marshalling is only one caller. `UScriptStruct::InitializeStruct` can also be reached from reflected properties, Blueprint VM buffers, containers, and other Unreal value lifecycle paths.
  - Alternative considered: special-case `FUStructType::ConstructValue` or delegate argument push. That would leave other `UASStruct` construction paths with the same invalid raw-memory object.

- Store enough per-instance context for fake-vtable callbacks to recover the owning `FASStructOps`.
  - Rationale: UE does not pass the ops pointer into fake-vtable callbacks. Copy, destruct, identical, and hash only receive value memory, so the value needs a small owner/context header.
  - Alternative considered: use only TLS around `InitializeStruct`. This can help the first construction call, but does not solve later callbacks that receive only value memory.

- Shift AS script struct property offsets to leave room for the owner header.
  - Rationale: Unreal `FProperty` offsets and AngelScript field offsets must agree. Reserving a header without shifting AS property offsets would make script field access overlap the header.
  - Alternative considered: external side table keyed by value address. That is fragile for stack/event buffers, copies, arrays, and transient parameter memory.

- Use `ScriptObject_Construct(ScriptType, (asCScriptObject*)ValueMemory)` before executing the AS constructor.
  - Rationale: this matches the bytecode allocation path and keeps constructor behavior centralized in the AngelScript fork.
  - Alternative considered: directly calling placement-new for `asCScriptObject`. The helper is safer if the fork changes internal object shell construction later.

## Risks / Trade-offs

- Adding a per-instance header changes AS-defined struct value layout. The fix must ensure generated `UScriptStruct` size, `FProperty` offsets, AS type size, and AS field offsets remain aligned.
- Values constructed before the fix do not have the new header. The supported path is newly constructed values after compile/reload; hot reload coverage should verify that live reload creates usable new values.
- `asCScriptObject` remains lightweight in this fork. If a future fork adds stateful destructor behavior, `FASStructOps::Destruct` may need an explicit paired C++ destruction step in addition to `CallDestructor`.
- Constructor failure can leave destination memory partially initialized. The implementation should write the owner header before AS constructor execution and avoid clearing it afterward.

## Migration Plan

No data migration is required. The change is runtime behavior only and is validated through a focused delegate argument regression plus the broader hot reload delegate parameter prefix.
