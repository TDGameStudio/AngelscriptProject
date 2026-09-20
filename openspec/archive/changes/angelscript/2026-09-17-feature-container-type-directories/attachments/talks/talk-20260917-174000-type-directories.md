# Talk: type directories and one parallel Change

## Context

The user asked to see the organized container shape, remembered Pending as one directory per type, and wanted one Change with no inter-type task edges so later work can run in parallel.

## Evidence

Admitted authors were flat `Containers/TArray.as` plus Fail siblings. Pending already used `Pending/Containers/TArray/TArrayAddAndOrder.as`. CodeGen FileTag is the path without `.as`.

## Options

- Keep one FileTag `Containers/TArray` with many `@begin` cases.
- Split to `Containers/TArray/<Observation>` and Fail subdirectories.
- One Change versus quality/coverage split; inter-type `depends_on` versus none.

## Settled Decision

One directory per type. FileTag `Containers/<Type>/<Observation>`. One Change. Nine type tasks have no edges. Provenance: draft log R4.

## Consequences and Flip Condition

Corpus exact-match `Containers/TArray` must become a prefix. Shared spec/cpp belong on one join or the TArray card. Flip if a single generated unit hits C4883 even after the split — stop and discuss; do not flatten again.

## Visual

```
Containers/TArray.as
        ->
Containers/TArray/AddAndOrder.as
Containers/TArray/CompileFail/NestedLocal.as
Containers/TArray/RuntimeFail/IndexOutOfBounds.as
```

## Sources

Draft log R4. Destination trees in [target-layout.md](../drafts/findings/target-layout.md).
