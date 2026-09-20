# Vocabulary

Source: draft glossary for `angelscript/class-generation-handoff`. Approval: R4.

| Term | Meaning | Source |
|---|---|---|
| Resolved | Frontend descriptor lifecycle. No UObject and no asType UserData. | reflection-dependencies spec |
| Materialized | After ClassGen, asType holds the reflection object. | Topic R1 |
| asType | `asITypeInfo` / `asCObjectType` | User wording |

## Confirmed public names

| Use | Chosen | Rejected | Reason | Round |
|---|---|---|---|---|
| Change | `angelscript/feature-classgen-type-materialization` | `feature-frontend-classgen-handoff` | R4 | R4 |
| Materialization TestDir | `Angelscript.UnitTest.NativeEngine.Compile` | new layer `...NativeEngine.ClassGen` | Same story as CompileOutput / SuperClass | R4 |
| Materialization test class | `ClassGenMaterialization` | `TypeMaterialization` | Names the ClassGen attach | R4 |
