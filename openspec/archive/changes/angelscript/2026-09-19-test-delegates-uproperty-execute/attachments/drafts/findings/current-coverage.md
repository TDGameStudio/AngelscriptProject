# Current delegate execute coverage

Source draft: `openspec/drafts/angelscript/delegates-property-coverage/findings/current-coverage.md` (Chinese original).

The archived Change `angelscript/2026-09-18-feature-delegates-ue-interop` proved the DECLARE macro table, CallPtr, native `TDelegate`, and dynamic AddDynamic. `FOnHealth Ev` was a script field, not a `UPROPERTY`.

Work written after archive, not yet in a Change:

- Product: isolated-host `ScriptDelegateType` / `ScriptMulticastDelegateType` via `SeedHostScriptDelegateTypes`. Without it, `UPROPERTY FOnHealth Ev` becomes `void`.
- Tests: `Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty`, run `c74cfc56c01045c3bdb81e8eb068ecd3`, 4/4 green.

| Case | Proved |
| --- | --- |
| `DynamicMulticastPropertyFires` | `UPROPERTY() FOnHealth Ev` → `FMulticastInlineDelegateProperty`; script AddDynamic + Broadcast(100, 75) |
| `DynamicSingleCastPropertyExecute` | `UPROPERTY() FPropertyAdd Handler` → `FDelegateProperty`; BindDynamic + Execute(41) → Result=42 |
| `NativeProcessUsingPublishedSignature` | Property `UDelegateFunction` drives a local `FMulticastScriptDelegate` BindUFunction + ProcessDelegate |
| `BlueprintAssignableDynamicAccepted` | Dynamic multicast `UPROPERTY(BlueprintAssignable)` carries the CPF flags |

Control: `DelegateReflection.OrdinaryBlueprintAssignableRejected` still rejects ordinary multicast BlueprintAssignable.

## Layout gap

Script DECLARE fields are pointer slots (CallPtr / BindPtr / AddPtr). `FMulticastInlineDelegateProperty` claims `FMulticastScriptDelegate` size at the same offset. Native `ProcessDelegate` on those bytes trips the access detector and can clobber neighboring `UPROPERTY`s.

```
Ev on the UObject
  ├─ script slot [asPWORD]          // AddDynamic / Broadcast
  └─ FProperty claimed size         // sizeof(FMulticastScriptDelegate), larger than a pointer
        └─ native ContainerPtrToValuePtr + ProcessDelegate  // unsafe; removed from the cases
```

## Still uncovered

- Overlay of property bytes onto `FMulticastScriptDelegate` (product)
- IsBound / Clear / Remove and script BindUFunction on a `UPROPERTY`
- More DECLARE families as `UPROPERTY` (RetVal, more arities)
- BindDynamic + Execute retval writeback (void side effect is green; retval assignment was 0)
- `Language/Delegate` execute (admission only)
- cook / PIE
