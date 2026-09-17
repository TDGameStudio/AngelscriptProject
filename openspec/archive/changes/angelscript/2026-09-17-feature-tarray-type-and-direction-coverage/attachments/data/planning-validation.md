# Planning validation

Change: `angelscript/feature-tarray-type-and-direction-coverage`
Date: 2026-09-17

## Requirement coverage

The host-api-fixtures delta adds one requirement (TArray Function type and direction observations) with one scenario (Query AddAndOrder FString and FillByAdd). Task 1.1 authors the cited AddAndOrder siblings. Tasks 2.1–6.1 author the remaining TestSource-old Function type and direction leaves. 7.1 projects them. 8.1 publishes `Get` for `AddAndOrderFString` and `FillByAdd` while keeping `AddAndOrder`. Other-containers-unchanged is an exclusion on the author cards and the spec BUT clause.

## Placeholder scan

No `TBD`, `TODO`, `implement later`, `fill in details`, or empty Interfaces fences.

## Symbol consistency

AddAndOrder names match [glossary.md](../glossary.md): `AddAndOrderFString`, `ReadAddOrder`, `FillByAdd`, `AppendWithAdd`. Return-value names match the same glossary. Consumed `parse_source_file`, `discover_sources`, and `FAngelscriptTestCode::Get` cite inspected files. New corpus method `CorpusHasTArrayTypeAndDirection` is listed on 8.1.
