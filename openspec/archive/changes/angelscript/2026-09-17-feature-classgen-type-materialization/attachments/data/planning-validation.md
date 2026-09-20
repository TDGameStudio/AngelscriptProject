# Planning validation

Date: 2026-09-17. Change: angelscript/feature-classgen-type-materialization.
Replan: replan-20260917-203847-classgen-withdraw.

## Coverage

Every requirement and acceptance condition maps to a task:

| Requirement or acceptance | Tasks |
|---|---|
| Resolved SuperClass / ImplementedInterfaces from GetResolvedBases | 1.1 |
| CodeSuperClass and UObject pointers null at Resolved | 1.1 |
| CompileOutput keeps Project after DefinitionsFrozen / ByteCodeEmitted | 2.1 |
| Builder ScriptType remains null | 2.1 |
| ClassGen UserData withdrawn; bind helper and ClassGenMaterialization tests removed | 3.1 |

ClassGen UserData is not an acceptance surface of this Change.

Spec sync: `angelscript/language/frontend/builder` accepted the Projected-CompileOutput scenario and stays strict-valid. `angelscript/language/frontend/reflection-dependencies` accepted authored-inheritance; preserved scenarios still fail the four-space clause rule (baseline, not reformatted). No `class-generation` current capability was created.

## Placeholder scan

`tasks.md`, `proposal.md`, root `design.md`, and the remaining spec deltas contain none of: TBD, TODO, implement later, fill in details, add appropriate error handling, add validation, handle edge cases, write tests for the above, similar to Task, known values, existing fixtures.

## Symbol consistency

`ReflectionDescriptors`, `CompileLifecycle`, TestDir `Angelscript.UnitTest.NativeEngine.Compile`, `Resolved`, `asType`, `SuperClass`, `CodeSuperClass`, `ImplementedInterfaces`, and `asCEngineCompileRegistration` match [glossary.md](../drafts/glossary.md) and root `design.md`. `ClassGenMaterialization` is withdrawn.
