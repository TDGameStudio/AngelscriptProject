# Vocabulary

Translated from draft `designs/classgen-ufunction-join/glossary.md`. Approval R5.

| Term | Chosen | Rejected | Reason | Round |
|---|---|---|---|---|
| Change | `angelscript/feature-classgen-ufunction-join` | `feature-classgen-call-join`, `feature-classgen-processevent-join` | Matches Q1=U | N2 |
| Test class | `ClassGenCall` | `ClassGenProcessEvent`, `ClassGenUFunction` | Neighbours `ClassGenMaterialization` / `ClassGenReload` | N1 |
| Test method | `InitialProcessEventReturnsValue` | `InitialCallsUFunction` | Initial plus ProcessEvent return | Convention |
| Test identity | `Angelscript.UnitTest.NativeEngine.Compile.ClassGenCall` | none | Existing Compile layer | N1 |
| Actor type | `ClassGenCallActor` | `ClassGenJoinActor` | Avoid leftover `/Script/Angelscript` name clash | Convention |
