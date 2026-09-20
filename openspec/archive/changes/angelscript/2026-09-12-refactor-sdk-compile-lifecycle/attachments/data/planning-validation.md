# Planning validation

Change: `angelscript/refactor-sdk-compile-lifecycle`
Date: 2026-09-12

## Coverage

Every requirement and acceptance condition in `proposal.md` and the Change spec deltas maps to a task ID in `tasks.md` `## Requirement coverage`.

| Source | Task |
|---|---|
| Builder two products / Taken set null Engine | 1.1 |
| Later unit against Taken set | 1.1 |
| CompileOutput ScriptType empty | 2.1 |
| Default RunThrough Emit / Function stable bytecode | 3.1 |
| Batch Install+Link, Prepare, asNO_FUNCTION | 4.1 |
| Image-as-compile-product tests | 5.1 |
| Public ByteCodeImage / snapshot removal | 5.2 |
| MetadataImage is not a TypeInfo owner | 6.1, 6.2 |
| Delete asCMetadataImage / RegisterMetadataImage / metadataImages | 6.2 |
| Binding tests that fail because Image is gone are commented | 6.1 |

## Placeholders

Scanned `tasks.md` for TBD, TODO, "implement later", "fill in details", "existing fixtures", "preserve behavior". None in the task cards. Design.md mentions "unnamed TODO" only as a negative ("not deferred as an unnamed TODO").

## Symbols

Settled names match `attachments/drafts/glossary.md` and Change `design.md`:

- `asCModuleDefinitionSet`, `TakeModuleDefinitionSet`
- `asCCompileOutput`, `asCDefinitionCompileOutput` (not `asCCompileOut`)
- `asCEngineCompileRegistration`
- `asCByteCodeEmitter` stays public
- `asEBuilderStage::ByteCodeEmitted` from existing stage enum convention
- `GetDefinitionSet` replaces `GetMetadataImage` (6.1 Naming assumed)
- Draft `Set` replaces BindInfo `Image` (6.1 Naming assumed)
- Test identity `Angelscript.UnitTest.NativeEngine.CompileLifecycle`

No public name is invented without a glossary, design, inspected `file:line` source, or a 6.1 Evidence `Naming assumed` line.
