# Package one Change and settle names

## Context

P requires changing Initial from one definition set for every `.as` to one set per file. The remaining user-owned acts were packaging and public names.

## Evidence

AskQuestion C1=1, N1=`ClassGenReload`, N2=`angelscript/feature-classgen-reload-join`. Draft log R9. Neighbour test `ClassGenMaterialization`.

## Options

- C1 1: one Change, per-file sets then reload skip.
- C1 2: two Changes, ownership first, reload second.
- N1 `ClassGenReload` vs extend `ClassGenMaterialization`.
- N2 `feature-classgen-reload-join` vs `feature-register-per-file-reload`.

## Settled Decision

One Change `angelscript/feature-classgen-reload-join`. Test class `ClassGenReload` on `Angelscript.UnitTest.NativeEngine.Compile`.

## Consequences

`ClassGenMaterialization.ReloadKeepsLegacyStageError` cannot remain a required Stage1-death oracle after this Change.

## Flip Condition

Split into two Changes only if per-file Register cannot be proven in the same Task DAG as the reload skip.

## Sources

[glossary](../drafts/glossary.md). Provenance: draft log R9.
