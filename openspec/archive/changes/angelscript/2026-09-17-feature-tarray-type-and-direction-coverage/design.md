# TArray type-axis and direction leaves

Direct-origin Change. Skipped-draft assumption is recorded in `attachments/data/harness-origin.json` and `proposal.md`. Names: [attachments/glossary.md](attachments/glossary.md). Gap: [attachments/findings/testsource-old-gap.md](attachments/findings/testsource-old-gap.md).

## Context

Directory rewrite admitted `Containers/TArray/<Observation>` with one parentless `@begin` per file. That packing is kept. Coverage is thin because the rewrite authored one int32 local observe per API instead of splitting the old Function type-axis and UFUNCTION directions.

## Goals / Non-Goals

**Goals:** port TestSource-old Function type suffixes and `const&in` / `&out` / `&inout` into new TArray observation files; project them; query a typed observe and an `&out` FileTag.

**Non-Goals:** other containers; Advance compose boxes; Negative/Reject/Exception piles already represented; script converters; AngelScript execute as admission.

## Decisions

- Compare `TestSource-old/Containers/TArray/Function`, not Pending dumps.
- Keep existing int32 observe files. Add siblings; do not fold types back into `AddAndOrder.as`.
- One observation per file. Stem = `@begin` = entry. Header lists the stem.
- Type suffix is Pascal (`FString`, not `_FString`).
- AddAndOrder direction names are the old verbs: `ReadAddOrder`, `FillByAdd`, `AppendWithAdd`.
- Other subjects use `Read<Stem>`, `FillBy<Stem>`, `Mutate<Stem>` unless the old file already has a more precise observation verb.
- Sort has no FVector/UObject. EmptyConstruction has type Key observes only.
- Author clusters are parallel. Generate and corpus join after all authors.
- Hand-write every `.as`. No Python/batch converters.

## Call chains

hand-written `AngelscriptTestCode/Containers/TArray/AddAndOrderFString.as`
→ `discover_sources` (`discovery.py:46`)
→ `parse_source_file` (`container_parser.py:243`)
→ `codegen.py generate` writes `TestCode/Generated/Containers/TArray/AddAndOrderFString.generated.cpp`
→ `FAngelscriptTestCode::Get` (`AngelscriptTestCode.h:26`)
→ `HostApiFixtureCorpus` (`HostApiFixtureCorpusTests.cpp:12`)

`FillByAdd` is a UFUNCTION `&out` entry; CodeGen still projects a parentless version tagged `FillByAdd`. Corpus `Get(Containers/TArray/FillByAdd, FillByAdd)` must succeed.

Measured at: 9ec12a73

dirty: yes; parent tree still carries uncommitted Language, Unreal, host-api, container-directory, and Pending leftover authors from earlier Changes.

## Risks / Trade-offs

- File count grows: AddAndOrder alone adds 23 leaves. That is the cost of one-begin-per-file plus the old type/direction matrix.
- UObject observes need a per-file dummy `UCLASS`. Keep names unique.
- Admission remains parse/project/Get, not AngelScript execute.
