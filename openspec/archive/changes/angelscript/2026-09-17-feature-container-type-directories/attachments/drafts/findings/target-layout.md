# Destination layout (one directory per type)

Source: draft finding (Chinese original; approval R4–R6).

FileTag is the path without `.as`.

```
Get(Containers/TArray/AddAndOrder, AddAndOrder)
Get(Containers/TArray/RuntimeFail/InsertIndexPastNum, InsertIndexPastNum)
```

Corpus: `FindFiles({Containers})` contains a tag prefixed `Containers/TArray/`. The join task owns that assertion.

```
now (flat host-api)
  Containers/TArray.as
  Containers/TArrayCompileFail.as
  Containers/TArrayRuntimeFail.as

Pending
  Pending/Containers/TArray/TArrayAddAndOrder.as

Language neighbor
  Language/Casting/ClassHandleCast.as

admitted destination
  Containers/TArray/AddAndOrder.as
  Containers/TArray/EmptyConstruction.as
  Containers/TArray/CompileFail/NestedLocal.as
  Containers/TArray/RuntimeFail/IndexOutOfBounds.as
```

Polarity directories are only `CompileFail/` and `RuntimeFail/`. UPROPERTY cases live on the type root. One `@begin` per file; the tag equals the Pascal stem.

Nine roots: `TArray` `TMap` `TSet` `TOptional` `TSoftObjectPtr` `TWeakObjectPtr` `TSubclassOf` `TObjectPtr` `SoftObjectPath`.

Generated: `Generated/Containers/TArray/AddAndOrder.generated.cpp`.

## TArray (full sample)

```
Containers/TArray/
  EmptyConstruction.as
  SwapElements.as
  LastValidIndex.as
  CopyRange.as
  ForEachElement.as
  EmptyIteratorCannotProceed.as
  EmptyConstIteratorCannotProceed.as
  CopyAssign.as
  IteratorAssign.as
  MoveAssignFrom.as
  IsValidIndex.as
  FindIndex.as
  IteratorWalk.as
  IteratorProceed.as
  ConstIteratorWalk.as
  AddAndOrder.as
  AppendOtherArray.as
  ShufflePreservesMembership.as
  InsertShiftsFollowing.as
  AddUniqueRejectsDuplicate.as
  EmptyClearsNum.as
  ResetClearsNum.as
  ReserveGrowsSlack.as
  SetNum.as
  SetNumZeroed.as
  RemoveSinglePreservesOrder.as
  RemoveAllMatches.as
  RemoveSingleSwap.as
  RemoveSwap.as
  RemoveAtIndex.as
  RemoveAtSwap.as
  SortAscending.as
  ShrinkReleasesSlack.as
  IndexAccess.as
  EqualityComparesElements.as
  ContainsValue.as
  NumCountsElements.as
  MaxAllocatedCount.as
  GetAllocatedSize.as
  IsEmpty.as
  GetSlack.as
  AddFromTemporary.as
  Capacity.as
  CapacityResize.as
  CopySlice.as
  FloatIndexTruncation.as
  SetNumZeroedPrimitive.as
  StructsContainingArrays.as
  ObjectProperty.as
  UObjectReferences.as
  ReserveClampsBelowNum.as
  RemoveSingleSwapReorders.as
  FloatIndexLast.as
  CompileFail/
    NestedLocal.as NestedLocalDeep.as NestedParam.as
    NestedProperty.as NestedPropertyDeep.as NestedReturn.as
    OfMapsLocal.as OfMapsProperty.as OfSetsLocal.as OfSetsProperty.as
    AddWrongElementType.as AssignWrongElementType.as
    MissingTypeArgs.as StringIndexAccess.as UnknownElementType.as
    UnsupportedAlgorithms.as UnsupportedApiAliases.as VoidType.as
  RuntimeFail/
    IndexOutOfBounds.as EmptyIndex.as WritePastEnd.as
    NegativeIndex.as WriteNegativeIndex.as AddAliasedElement.as
    CopyNegativeCount.as CopySelf.as
    CopySourceOutOfBounds.as CopySourceOutOfBoundsEmptyIndex.as
    CopyTargetOutOfBounds.as CopyTargetOutOfBoundsEmptyIndex.as
    InsertAliasedElement.as InsertOutOfBounds.as InsertIndexPastNum.as
    IteratorOutOfBounds.as IteratorProceedPastEnd.as
    LastOutOfBounds.as LastIndexFromEndOutOfBounds.as
    MoveAssignSelf.as RemoveAtOutOfBounds.as RemoveAtSwapOutOfBounds.as
    SetNumNegative.as SetNumZeroedNegative.as SetNumZeroedNonPrimitive.as
    SwapOutOfBounds.as SwapSecondIndexOutOfBounds.as
```

FString / UObject variants are `AddAndOrderFString.as` / `AddAndOrderUObject.as`.

The other eight types share the principle, not this leaf list. See [per-type-trees.md](per-type-trees.md).

## One Change, no inter-type edges

Each type task owns only `Containers/<Type>/**` and that type's Generated units. Shared spec/corpus sit on the join. Do not dump Pending, paste Bindings axis files, run converters, add inter-type `depends_on`, or use short leaf names.
