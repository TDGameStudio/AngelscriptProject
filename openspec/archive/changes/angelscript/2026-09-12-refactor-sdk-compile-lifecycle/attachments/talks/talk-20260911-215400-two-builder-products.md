# Two Builder products: CompileOutput vs DefinitionSet

## Context

ClassGen needs UE descriptions. The type graph must remain takeable for the next unit and for Registration. One bag cannot do both without becoming Image again.

## Evidence

- `asECompileOutType` already means elide native calls; the bag is `asCCompileOutput`.
- User: CompileOutput is external-only (UE info, diagnostics).
- Round 9: `TakeModuleDefinitionSet` plus `Get/TakeCompileOutput`; payload reuses `FAngelscriptModuleDesc` / `ClassDesc`.

## Options

| Option | Result |
| --- | --- |
| A. Parallel Get/Take of both | Descriptions stay off the type graph |
| B. CompileOutput owns the set | TypeInfo in the external bag |
| C. ClassGen walks TypeInfo | Rejects DefinitionCompileOutput |

## Settled Decision

Option A. `asCDefinitionCompileOutput` reuses existing `FAngelscript*` structs. `ScriptType` / UClass slots stay empty until host ClassGen.

## Consequences and Flip Condition

Do not fill `ScriptType` with pending TypeInfo during engine-free compile. Flip if ClassGen in this Change must consume Engine TypeInfo.

## Sources

- attachments/drafts/design.md
- attachments/drafts/glossary.md
- draft log.md Round 9 Q22–Q24
