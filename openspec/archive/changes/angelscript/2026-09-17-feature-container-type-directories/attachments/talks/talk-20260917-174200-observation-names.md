# Talk: lengthened observation names

## Context

The user had already said Language `.as` names were too simple (`ClassCast` became `ClassHandleCast`). They asked again: `TArray.as` is too simple; a TArray file must say what it tests; the whole design must use extended names.

## Evidence

Pending used `TArrayAddAndOrder.as` and `TArrayEmptyConstruction.as`. Current `@begin array` summarizes `Last() is 40` but asserts empty construction. An earlier draft leaf `add.as` repeated the same thinness.

## Options

- Short kebab: `add.as`.
- Pending prefix: `TArrayAddAndOrder.as`.
- Language-style observation Pascal without repeating the type: `AddAndOrder.as`.

## Settled Decision

Leaves are lengthened Pascal that state the observation. The directory already names the type, so do not prefix `TArray`. User chose `AddAndOrder.as`. Provenance: draft log R5.

## Consequences and Flip Condition

`Get(Containers/TArray/AddAndOrder, AddAndOrder)`. Nine types share this grain. Flip if a leaf cannot be distinguished without repeating the type name.

## Visual

```
TArray.as              // type only
add.as                 // method only
TArrayAddAndOrder.as   // type twice
AddAndOrder.as         // directory = type, leaf = observation
```

## Sources

Draft log R5. Mapping in [extended-names.md](../drafts/findings/extended-names.md).
