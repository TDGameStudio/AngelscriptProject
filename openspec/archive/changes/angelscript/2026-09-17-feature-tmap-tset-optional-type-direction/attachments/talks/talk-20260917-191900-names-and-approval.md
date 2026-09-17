# Talk: Change identity, TMap *In, design approval

## Context

Scope and packaging were settled. The design needed a Change id, a rule for already-admitted TMap `*In` FileTags, and explicit approval before creation.

## Evidence

Neighbor Change id: `angelscript/feature-tarray-type-and-direction-coverage`. Current corpus already projects `ContainsKeyIn`, `NumCountsPairsIn`, and `IndexAccessIn`. Renaming those would churn admitted FileTags.

## Options

- Change id: `feature-tmap-tset-optional-type-direction` vs `feature-container-type-and-direction-coverage` vs `feature-remaining-param-container-type-direction`
- Keep TMap `*In` vs rename to `Read*`
- Approve `designs/tmap-tset-optional` vs revise first

## Settled Decision

Change `angelscript/feature-tmap-tset-optional-type-direction`. Keep existing TMap `*In`. Approve the design and create the Change. Provenance: draft log R3.

## Consequences and Flip Condition

New TMap subjects use `Read` / `FillBy` / `Mutate`. Existing `*In` stays. Flip rename only if mixed `*In` / `Read*` names break generate or corpus. Do not rename during apply.

## Visual

```
ContainsKeyIn          // keep
FillByContainsKey      // new
MutateContainsKey      // new
ReadAddPairInsertsKeyValue  // new subject uses Read
```

## Sources

Draft log R3. [glossary.md](../drafts/glossary.md).
