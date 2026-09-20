# Vocabulary

Translated from draft `designs/uclass-reload-join/glossary.md`. Approval R15.

| Term | Chosen | Rejected | Reason | Round |
|---|---|---|---|---|
| Change | `angelscript/feature-classgen-uclass-reload-join` | `feature-classgen-reload-call-join`, `feature-classgen-blueprint-reload-join` | N2=U | N2 |
| Test class | `ClassGenUClassReload` | `ClassGenReloadCall`, `ClassGenBlueprintReload` | Neighbours `ClassGenReload` / `ClassGenCall` | N1 |
| Test identity | `Angelscript.UnitTest.NativeEngine.Compile.ClassGenUClassReload` | none | Existing Compile layer | N1 |
| Soft actor | `ClassGenUClassReloadSoftActor` | reuse `ClassGenReloadSoftActor` | Avoid leftover `/Script/Angelscript` clash | Convention |
| Blueprint parent | `ClassGenUClassReloadBpParent` | `AHotReloadBlueprintChildSoftReloadParent` | New NativeEngine name, not Legacy | Convention |
