# Planning validation

Date: 2026-09-18. Change: angelscript/feature-classgen-reload-join.

## Coverage

Every requirement and acceptance condition maps to a task:

| Requirement or acceptance | Tasks |
|---|---|
| Initial compile materializes Unreal reflection from preprocessor descriptors | 1.1 |
| Initial compile materializes class, struct, and enum | 1.1 |
| Types from different preprocessor modules belong to different `asCDefinitions` | 1.1 |
| Frontend Resolved pointers stay null | 1.1 |
| Hot reload rematerializes Unreal reflection from preprocessor descriptors | 1.2 |
| FullReload updates class, struct, and enum UserData | 1.2 |
| SoftReloadOnly updates UserData without the dead Stage path | 1.2 |
| Failed reload keeps the last generation | 1.2 |

## Placeholder scan

`tasks.md`, `proposal.md`, root `design.md`, and the class-generation spec delta contain none of: TBD, TODO, implement later, fill in details, add appropriate error handling, add validation, handle edge cases, write tests for the above, similar to Task, known values, existing fixtures.

## Symbol consistency

`CompileModules`, `ECompileType::Initial` / `FullReload` / `SoftReloadOnly`, `ClassGenReload`, `Angelscript.UnitTest.NativeEngine.Compile`, `RetireDefinitionSets`, and `asCEngineCompileRegistration` match [glossary.md](../drafts/glossary.md) and root `design.md`.
