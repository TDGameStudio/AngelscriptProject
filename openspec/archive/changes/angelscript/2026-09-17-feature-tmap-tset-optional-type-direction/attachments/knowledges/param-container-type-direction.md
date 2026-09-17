# Knowledge candidate: parameterized container type and direction leaves

Disposition: candidate

## Reusable Insight

For TMap, TSet, and TOptional, type-axis and UFUNCTION-direction coverage is one observation per file. Direction stems are `Read` / `FillBy` / `Mutate` unless an older verb is already an observation. Type suffixes are per tree (FName in, float keys/elements out for TMap/TSet). Already admitted TMap `*In` FileTags stay; do not rename them to `Read*` as a cleanup.

## Evidence

Old Function Coverage required L2 three-direction and L3 suffixes on each Subject. The archived TArray Change split packed UFUNCTIONs into parentless leaves. Current TMap already admitted `ContainsKeyIn` and siblings. TSet and TOptional still lack those axes.

## Boundaries

Applies to admitted `AngelscriptTestCode/Containers/{TMap,TSet,TOptional}` authors. Does not invent an element-type axis for SoftObjectPath. Does not set pointer-wrapper L3 (UObject / UClass). Does not authorize Advance compose, Negative nesting, Reject aliases, or generating `.as` from scripts.

## Application

New leaves keep the existing int observe. Add `<Stem><Type>` and the three direction families. Empty construction gets typed observes only. Corpus `Get`s a typed observe and an `&out` per tree.

## Sources

[glossary.md](../drafts/glossary.md), [old-function-gap.md](../drafts/findings/old-function-gap.md). Draft rounds R1–R3.
