# Handoff: join UFUNCTION to ProcessEvent

Translated from draft `designs/classgen-ufunction-join/handoff.md`. Approval R5.

## OpenSpec Handoff

- Scope: classgen-ufunction-join
- Target Change: angelscript/feature-classgen-ufunction-join

## Problem

`CompileModules(Initial)` already Builder+Registers and materializes class/struct/enum UserData. ClassGen tests have no Methods. ProcessEvent needs Analyze to bind `FunctionDesc.ScriptFunction` onto a TypeInfo method and Generation to create `UASFunction`. That call is unproven on the host path.

## Success

- One hand-filled BlueprintCallable `GetValue` on `ClassDesc.Methods`, source annotated `UFUNCTION()`.
- After `CompileModules(Initial)` and existing ClassGen, `UASFunction::ScriptFunction` is non-null.
- `NewObject` then ProcessEvent returns 7.
- Test: `Angelscript.UnitTest.NativeEngine.Compile.ClassGenCall.InitialProcessEventReturnsValue`.

## Evidence

- [ufunction-join.md](findings/ufunction-join.md): Analyze reads host Methods, not Builder projections.
- [design.md](design.md): thin host plus ProcessEvent.
- [glossary.md](glossary.md): public names.

## Scope

Do: one Change. Join one Initial `UFUNCTION` through ProcessEvent.

Do not: Language corpus execute; real preprocessor; copy Builder Methods; construct; reload the method body; rewrite ClassGen; frontend UObject; `ALWAYS_CREATE` / `Build`; CacheV2.

## Constraints

- ClassGen still reads `FAngelscriptEngine::Get().Engine` and the host `ModuleDesc`.
- Production Methods still come from the preprocessor; this Change's test hand-fills them.
- No `UCLASS()` / `: UObject` on the class; SuperClass / CodeSuperClass are hand-filled.
- Entry remains `CompileModules(Initial)`.

## Approach

1. Build a `ClassGenCall` fixture like `ClassGenMaterialization`, with a hand-filled Actor and Methods.
2. Source: `UFUNCTION() int GetValue() { return 7; }`.
3. After Initial compile, assert `UASFunction` and the ProcessEvent return.
4. Fix only the host/Analyze join that blocks this proof. Do not change ClassGen architecture.

## Alternatives and flip conditions

- Q1=H (bare Context.Prepare): flip if acceptance must be a UE reflection call. Rejected.
- Q2=B (copy Builder Methods): flip if hand-filled names cannot match TypeInfo and the test descriptors cannot change. Rejected.
- Q3=F (include reload): flip if a method-body reload must be proven in this Change. Rejected.

## Failures

- Empty Methods: Analyze does not bind ScriptFunction; ProcessEvent has no UASFunction.
- ScriptFunctionName mismatch: Analyze reports the function missing.
- UserData-only assertion: repeats the previous Change and does not prove a call.

## Verification

- `ue.test` prefix `Angelscript.UnitTest.NativeEngine.Compile.ClassGenCall`, `Fast=$true`.
- Do not run the Language corpus or editor file-watch.

## Exploration Carryover

| Source | Target | Reason |
| --- | --- | --- |
| design.md | attachments/drafts/design.md | Accepted scoped design |
| handoff.md | attachments/drafts/handoff.md | Accepted handoff |
| glossary.md | attachments/drafts/glossary.md | Confirmed public names |
| ../../findings/ufunction-join.md | attachments/drafts/findings/ufunction-join.md | Analyze reads host Methods |
| ../../log.md#r2 | attachments/talks/talk-20260918-140500-ufunction-layer.md | Q1=U |
| ../../log.md#r3 | attachments/talks/talk-20260918-140600-descriptor-and-proof.md | Q2=P Q3=E |
| ../../log.md#r4 | attachments/talks/talk-20260918-140700-source-and-names.md | Q4=A and names |
| ../../log.md#r5 | attachments/talks/talk-20260918-140800-approval.md | Package approval |
| ../../findings/ufunction-join.md | attachments/knowledges/classgen-reads-host-methods.md | Reusable: ClassGen does not read Builder projections |
