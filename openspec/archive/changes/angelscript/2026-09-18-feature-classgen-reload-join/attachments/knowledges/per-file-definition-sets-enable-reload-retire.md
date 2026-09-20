# Per-file definition sets enable reload retire

Disposition: candidate

## Reusable Insight

A per-file `asCModule` shell is not enough for hot reload. If every script type still lives in one Initial `asCDefinitions`, the engine name/key index cannot accept a second Register, and `RetireExternalDefinitions` cannot drop one file. Reload needs one compile definition set per `.as` so that file and its dependents can be retired without tearing down the host graph.

## Evidence

- `asCBuilder::TakeDefinitions` returns one graph for every source given to that Builder.
- Initial join Registers that one graph. `Register(Sets, Output)` then `NameConflict`s when `GetModule(name)` or `TypesByName` is occupied.
- `RetireExternalDefinitions` moves all `definitionSets` and admitted host graphs.

## Boundaries

Does not authorize replace-by-key inside a monolithic set. Does not authorize a shadow engine. Does not restore `ALWAYS_CREATE` / `Build`. ClassGen Soft/Full stays after a successful compile.

## Application

Builder+Register once per preprocessor `ModuleDesc`, with Dependencies = host graph + already attached script sets. On reload, retire only those compile sets, then Register again.

## Sources

[reload-join](../drafts/findings/reload-join.md), [design](../drafts/design.md).
