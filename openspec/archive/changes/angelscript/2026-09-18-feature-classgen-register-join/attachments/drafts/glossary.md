# Vocabulary

Source: local draft `angelscript/classgen-register-join` scope `register-classgen-join` `glossary.md`. Approval: R3 names, R4 package. Translated from the approved Chinese glossary; identifiers unchanged.

| Term | Chosen | Rejected | Reason | Source |
|---|---|---|---|---|
| Change | `angelscript/feature-classgen-register-join` | `angelscript/feature-compile-modules-builder-join` | Outcome is ClassGen materialization; CompileModules is the hook | N2 |
| Test class | `ClassGenMaterialization` | `CompileModulesBuilderJoin` | Prior Change R4 used this name; layer stays `NativeEngine.Compile` | N1 |
| Test identity | `Angelscript.UnitTest.NativeEngine.Compile.ClassGenMaterialization` | New layer `NativeEngine.ClassGen` | Do not open a new layer | N1 / prior R4 |
| Host entry | `FAngelscriptEngine::CompileModules` | `BindRegisteredTypesForClassGeneration` | Do not restore the withdrawn helper; Initial uses the Builder skip | Q1+C |
