# Accepted: UPROPERTY delegate execute completion

Status: designed. Source draft remains local; this file is the English export.

## Problem

`DelegateProperty` has seven green int/void cases. Script bind, broadcast, clear, and remove already use the pointer-sized CallPtr slot. Missing product behavior: `Ev.IsBound()`, BindDynamic+Execute return writeback, non-int arguments, unbound `ExecuteIfBound`, `AddDynamic(this, FunctionName)`, convert-and-fire from CallPtr, and SoftReload copy of the eight-byte slot.

The `UPROPERTY` bytes are not an `FMulticastScriptDelegate`. `ContainerPtrToValuePtr(Ev)` remains illegal.

## Accepted direction

- Change: `angelscript/feature-delegates-uproperty-execute`
- Prove NativeEngine only. Keep the existing `DelegateProperty` class.
- CallPtr stays the script source of truth. Do not overlay native storage on the property bytes.
- Native fire builds a temporary `FScriptDelegate` / `FMulticastScriptDelegate` from CallPtr.
- Representative map, not a 60-row `UPROPERTY` execute matrix.
- UCLASS methods accept `BindDynamic` / `AddDynamic(this, FunctionName)`.

## Contract

```
UPROPERTY Ev                         // still an 8-byte tagged CallPtr
  ├─ AddDynamic / BindUFunction / Broadcast / Clear / Remove
  │     existing BindPtr / AddPtr / CallPtr / ClearPtr
  ├─ AddDynamic(this, FunctionName)
  │     parser/Sema treat this as the object, not ActOnDeclReference("this")
  ├─ Ev.IsBound()
  │     new Sema operation on the same slot
  ├─ Execute / ExecuteIfBound
  │     CallPtr → asCallBoundUFunction
  │     write back ReturnParm; FName args; unbound ExecuteIfBound does not throw
  └─ native fire
        Convert(CallPtr) → temporary native delegate → ProcessDelegate
        do not ContainerPtrToValuePtr(Ev)
```

Do not change callable size, tags, or BindPtr / AddPtr / RemovePtr / ClearPtr / ClonePtr. SoftReload copies the eight-byte CallPtr, not native sizeof.

## Names

| Role | Chosen | Rejected |
| --- | --- | --- |
| Change | `angelscript/feature-delegates-uproperty-execute` | `feature-delegates-property-storage`; `feature-delegates-callptr-ufunction` |
| Test class | `DelegateProperty` | `DelegateUProperty` |
| Script source | CallPtr | property-byte overlay |
| Native fire | convert API (name assumed at apply) | `ContainerPtrToValuePtr(Ev)` |

## Verification

`ue.test` prefix `Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty`, `Fast=true`. Observe new representative cases RED, then GREEN the prefix. Also observe adjacent Compile prefixes touched by Sema/VM edits. Omit Language execute, cook, and PIE.
