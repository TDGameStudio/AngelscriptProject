# ClassGen reads host Methods, not Builder projections

Disposition: candidate

## Reusable Insight

ClassGen Analyze binds `UFUNCTION`s from the host `FAngelscriptModuleDesc.Methods` table. A successful Builder+Register that emits methods on TypeInfo is not enough. If Methods is empty, Analyze never writes `FunctionDesc.ScriptFunction`, Generation never creates a callable `UASFunction`, and ProcessEvent cannot run the new frontend body.

## Evidence

- `AngelscriptClassGenerator_Analyze.cpp` iterates `ClassData.NewClass->Methods` and looks up `FunctionDesc->ScriptFunctionName` in a TypeInfo/module FunctionMap.
- `as_descriptor_consumer.cpp` projects only members with a `UFUNCTION` attribute onto CompileOutput.
- Host Initial join copies `ScriptModule` onto the preprocessor/host ModuleDesc and does not merge CompileOutput Methods.
- Production preprocessor already appends Methods when it sees `UFUNCTION()`.

## Boundaries

Does not authorize replacing the preprocessor with Builder projections. Does not require Language corpus execute. Does not join script construct or method-body reload.

## Application

Keep production Methods on the preprocessor. Tests that skip the preprocessor must hand-fill Methods the same way they hand-fill SuperClass. Prove the join with ProcessEvent, not UserData alone.

## Sources

[ufunction-join](../drafts/findings/ufunction-join.md), [design](../drafts/design.md).
