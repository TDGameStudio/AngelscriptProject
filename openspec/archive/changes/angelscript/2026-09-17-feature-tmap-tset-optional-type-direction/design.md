# TMap TSet TOptional type-axis and direction leaves

Draft-origin Change from `angelscript/remaining-container-type-direction` scope `tmap-tset-optional`. Names: [attachments/drafts/glossary.md](attachments/drafts/glossary.md). Gap: [attachments/drafts/findings/old-function-gap.md](attachments/drafts/findings/old-function-gap.md).

## Context

Directory rewrite admitted `Containers/<Type>/<Observation>` with one parentless `@begin` per file. That packing is kept. TArray already ported old Function L2/L3. TMap / TSet / TOptional did not. TMap already admitted some typed `*In` leaves.

## Goals / Non-Goals

**Goals:** port TestSource-old Function type suffixes and `const&in` / `&out` / `&inout` into new TMap, TSet, and TOptional observation files; project them; query a typed observe and an `&out` FileTag on each tree.

**Non-Goals:** pointer wrappers; SoftObjectPath; Advance compose boxes; Negative/Reject piles; renaming TMap `*In`; script converters; AngelScript execute as admission.

## Decisions

- Compare `TestSource-old/Containers/{TMap,TSet,TOptional}/Function`, not Pending dumps.
- Keep existing local observes. Keep admitted TMap `*In`.
- One observation per file. Stem = `@begin` = entry. Header lists the stem.
- Type suffix is Pascal. Tables are per tree (FName yes; float keys/elements no).
- New directions are `Read<Stem>`, `FillBy<Stem>`, `Mutate<Stem>` unless the old file already names a more precise verb.
- `EmptyConstruction` has typed observes only.
- Three author groups are parallel. Generate and corpus join after all authors.
- Hand-write every `.as`. No Python/batch converters.

## Call chains

hand-written `AngelscriptTestCode/Containers/TMap/AddPairInsertsKeyValueFString.as`
→ `discover_sources` (`discovery.py:46`)
→ `parse_source_file` (`container_parser.py:243`)
→ `codegen.py generate` writes `TestCode/Generated/Containers/TMap/AddPairInsertsKeyValueFString.generated.cpp`
→ `FAngelscriptTestCode::Get` (`AngelscriptTestCode.h:26`)
→ `HostApiFixtureCorpus` (`HostApiFixtureCorpusTests.cpp`)

The same chain holds for `Containers/TSet/AddElementIsContainedFString.as` and `Containers/TOptional/SetValueFString.as`. `FillByAddPairInsertsKeyValue` is a UFUNCTION `&out` entry; CodeGen still projects a parentless version tagged `FillByAddPairInsertsKeyValue`.

Measured at: c7d0675d

dirty: yes; parent tree still carries uncommitted TArray type-direction authors, Generated TArray units, host-api corpus edits, Language, Unreal, and earlier container leftover authors.

## Risks / Trade-offs

- One bundled Change is several hundred new leaves. Author groups stay disjoint so a failed type does not block the others' parse proof.
- Mixed TMap `*In` and new `Read*` names are intentional. Do not rename during apply.
- UObject observes need a per-file dummy `UCLASS`. Keep names unique.
- Admission remains parse/project/Get, not AngelScript execute.
