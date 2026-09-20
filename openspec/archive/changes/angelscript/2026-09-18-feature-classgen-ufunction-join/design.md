# Join UFUNCTION ProcessEvent after ClassGen

Seeded from [attachments/drafts/design.md](attachments/drafts/design.md). Approval R5.

Host `ModuleDesc.Methods` stay the ClassGen input. Initial compile already Builder+Registers. This Change proves one hand-filled `UFUNCTION` is callable through ProcessEvent.

## Goals / Non-Goals

**Goals:** After `CompileModules(Initial)` and existing ClassGen, `ClassGenCallActor.GetValue` ProcessEvent returns 7 and `UASFunction::ScriptFunction` is non-null.

**Non-Goals:** Language corpus execute; real preprocessor; copying Builder Methods; construct; method-body reload; ClassGen rewrite; frontend UObject; `ALWAYS_CREATE` / `Build`; CacheV2.

## Decisions

- Q1=U: acceptance is ProcessEvent, not bare Context.Prepare.
- Q2=P: test hand-fills Methods; production preprocessor is unchanged.
- Q3=E: Initial only.
- Q4=A: source writes `UFUNCTION()` on the method; no `UCLASS()` / `: UObject`.
- Names from [attachments/drafts/glossary.md](attachments/drafts/glossary.md).

## Call chains

```
FAngelscriptEngine::CompileModules(Initial)
→ asCBuilder.RunThrough(ByteCodeEmitted)
→ asCEngineCompileRegistration.Register
→ FAngelscriptClassGenerator.Analyze
   Methods[i].ScriptFunctionName → TypeInfo method → FunctionDesc.ScriptFunction
→ Generation → UASFunction
→ NewObject + UObject::ProcessEvent → 7
```

Measured at: `38e1b7a4fe9bbc540106f28d7858ccd5d899868f`

dirty: yes; parent tree already has Language fixtures, container authors, and other in-flight Changes. This Change owns `ClassGenCall` tests and any host/Analyze join listed in `tasks.md`.

## Failures

- Empty Methods: Analyze never binds ScriptFunction.
- Name mismatch: Analyze reports the function missing.
- UserData-only assertion: repeats ClassGenMaterialization and does not prove a call.
