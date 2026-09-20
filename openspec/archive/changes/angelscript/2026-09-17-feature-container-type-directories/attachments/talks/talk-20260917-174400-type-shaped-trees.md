# Talk: type-shaped trees

## Context

The user asked that the other containers get the same extended testing, then said to stay flexible — do not clone the TArray tree.

## Evidence

TArray binds index/order/slice/capacity. TMap binds keys and throws on a missing `[]`. TSet has no index. TOptional is a single optional value. Pointer types follow object lifetime. SoftObjectPath is a path value, not a pointer.

## Options

- Copy TArray leaves onto every type.
- Same naming principle, trees follow each MethodSurface.

## Settled Decision

Thicken all nine types. Share observation-lengthened names. Do not share leaf lists. Provenance: draft log R6.

## Consequences and Flip Condition

TMap must not grow `LastValidIndex`. TSet must not grow index access. Pointer types keep long names and Pascalize them. Fail directories exist only with Bind evidence. Flip if a bind later adds an API that the tree omitted — add that observation, do not import another type's list.

## Visual

```
TArray     Last / Insert / Swap / slice
TMap       ContainsKey / FindOrAdd / IndexMissingKey
TSet       AddDuplicateIgnored
TOptional  StoredZeroIsSet
pointers   target / stale / CDO
path       ClassPathIsValid
```

## Sources

Draft log R6. Trees in [per-type-trees.md](../drafts/findings/per-type-trees.md).
