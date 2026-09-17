# Planning validation

Change: `angelscript/feature-tmap-tset-optional-type-direction`
Date: 2026-09-17

## Requirement coverage

The host-api-fixtures delta adds one requirement (TMap TSet TOptional Function type and direction observations) with one scenario (Query typed observe and FillBy on each tree). Task 1.1 authors TMap remaining siblings including `AddPairInsertsKeyValueFString` and `FillByAddPairInsertsKeyValue`. Task 2.1 authors TSet. Task 3.1 authors TOptional. 4.1 projects them. 5.1 publishes the six `Get`s while keeping TArray controls and `ContainsKeyIn`. Pointer wrappers and SoftObjectPath are exclusions on the author cards and the spec BUT clause.

## Placeholder scan

No `TBD`, `TODO`, `implement later`, `fill in details`, or empty Interfaces fences.

## Symbol consistency

Representative FileTags match [glossary.md](../drafts/glossary.md): `AddPairInsertsKeyValueFString`, `FillByAddPairInsertsKeyValue`, `AddElementIsContainedFString`, `SetValueFString`. TMap `*In` stays. Consumed `parse_source_file`, `discover_sources`, and `FAngelscriptTestCode::Get` cite inspected files. New corpus method `CorpusHasTMapTSetOptionalTypeAndDirection` is listed on 5.1 and the glossary.
