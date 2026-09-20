# Knowledge candidate: container observation FileTags

Disposition: candidate

## Reusable Insight

A container author FileTag is the path under `AngelscriptTestCode/` without `.as`. After this grain, that path is `Containers/<Type>/<Observation>` (plus `CompileFail/` or `RuntimeFail/` when polarity exists). The leaf is a lengthened Pascal observation, not the type name and not a method alias. One file holds one parentless `@begin` whose tag equals the stem.

## Evidence

Language already uses lengthened Pascal leaves (`ClassHandleCast`, planned `InferFromLiteral`). Pending Containers used `TArrayAddAndOrder`. Flat `Containers/TArray` hid 51 observations and mismatched tags such as `array`. TMap `[]` missing a key throws; that is a RuntimeFail observation, not a default insert.

## Boundaries

Applies to admitted `AngelscriptTestCode/Containers/` authors. Does not rename Language or Unreal FileTags. Does not authorize dumping Pending or generating `.as` from scripts. Fail directories are not required for every type.

## Application

New container cases add a file named for the observation. Type-axis variants get their own file (`AddAndOrderFString`). Corpus tests assert a prefix `Containers/<Type>/`, not exact equality to `Containers/<Type>`.

## Sources

[extended-names.md](../drafts/findings/extended-names.md), [authoring-standard.md](../drafts/findings/authoring-standard.md). Draft rounds R4–R6.
