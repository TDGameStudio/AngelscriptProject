# UFUNCTION → ProcessEvent join points

Translated from draft `findings/ufunction-join.md`. Date 2026-09-18. Q1=U.

## The call chain exists; the descriptor table is empty

```
Preprocessor UFUNCTION()
└─[writes] ClassDesc.Methods                    // FunctionName / ScriptFunctionName / specifiers
      │
CompileModules Builder+Register
└─[writes] ScriptModule + TypeInfo.methods      // bytecode already Linked
      │
ClassGen.Analyze
└─[looks up] FunctionMap[ScriptFunctionName]
   └─[writes] FunctionDesc.ScriptFunction       // missing name → "Could not find function"
      │
ClassGen.Generation
└─[creates] UASFunction
   └─[member] ScriptFunction                    // ProcessEvent reads this pointer
      │
UObject::ProcessEvent / RuntimeCallEvent
└─[calls] AngelscriptCallFromParms
   └─[calls] Prepare + Execute                  // interpreter DWORD stream
```

ClassGen still reads host `ModuleDesc.Methods`, not Builder `CompileOutput`. `DescriptorConsumer` projects only members with `UFUNCTION`. The host does not copy that projection back.

The production path already fills Methods in the preprocessor. The previous ClassGen tests hand-filled Class/Enum and omitted Methods, so Analyze never bound functions.

## What a thin join proves

Source has one `UFUNCTION()` BlueprintCallable instance method (`int32 GetValue() { return 7; }`). `ClassDesc.Methods` has a matching row. Builder emits the method on TypeInfo. Analyze binds `ScriptFunction`. Generation creates `UASFunction`. After `NewObject`, ProcessEvent returns 7.

Out of this cut: replacing the preprocessor with Builder projections; Language corpus execute; BlueprintEvent wrappers / `_Implementation` rename; `beh.construct`.
