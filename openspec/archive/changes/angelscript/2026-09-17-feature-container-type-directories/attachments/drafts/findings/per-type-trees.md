# How each type tree is shaped

Source: draft finding (Chinese original; approval R6).

Shared principle: directory = type, leaf = lengthened observation, one begin per file.  
Trees are not shared: do not copy `AddAndOrder` / `LastValidIndex` onto types that do not bind them. Counts need not match TArray.

```
TArray     index, order, slice, capacity
TMap       key/value, missing-key Throw, GetKeys, proceed-before-get
TSet       unique members, no index
TOptional  set / unset, not container CRUD
pointers   target, lifetime, hierarchy, path
SoftObjectPath  path string and Resolve, not TSoftObjectPtr
```

Each tree is the quality rename/split plus that type's coverage begins.

## TMap (pairs, not an array)

Split giant `contains-contains` / `index-access` / `num-num` by key/value type and call shape. No Swap, Last, or Insert.

```
Containers/TMap/
  EmptyConstruction.as CopyAssign.as AddPair.as AddOverwrite.as
  ContainsKey.as ContainsMissing.as FindValue.as FindMissing.as
  FindOrAdd.as FindOrAddInserts.as IndexAccess.as SetValue.as
  GetKey.as GetValue.as GetKeys.as GetValues.as
  RemoveKey.as RemoveAndCopyValue.as RemoveCurrent.as RemoveMissing.as
  EmptyClearsNum.as ResetClearsNum.as NumCountsPairs.as IsEmpty.as
  EqualityComparesPairs.as ForEachPair.as IteratorWalk.as IteratorProceed.as
  MutableIteratorPopulated.as ConstIteratorPopulated.as
  EmptyMutableIteratorCannotProceed.as
  CopyConstructedMutableIterator.as CopyConstructedConstIterator.as
  StructsContainingArrays.as ObjectProperty.as UObjectReferences.as
  EmptyVersusReset.as
  IteratorGetKeyWithoutProceed.as IteratorSetValueWithoutProceed.as
  IteratorRemoveCurrentWithoutProceed.as
  CompileFail/
    NestedLocal.as NestedLocalDeep.as NestedParam.as
    NestedProperty.as NestedPropertyDeep.as NestedReturn.as
    OfArraysLocal.as OfArraysProperty.as OfSetsLocal.as OfSetsProperty.as
    AddWrongKeyType.as AddWrongValueType.as ByValueMutation.as
    ForEachPairUnsupported.as IndexWrongKeyType.as MissingTypeArgs.as
    OneTypeArg.as UnknownType.as UnsupportedApiAliases.as VoidValueType.as
  RuntimeFail/
    IndexMissingKey.as IndexMissingKeyWrite.as IteratorOutOfBounds.as
```

Existing FName/FString/`&in` observations become their own files (`ContainsKeyFString.as`). Do not invent a type axis the dump never had.

## TSet (unique members)

No `[]`, no Last, no keys. A duplicate Add is ignored, not appended.

```
Containers/TSet/
  EmptyConstruction.as EmptyConstructionFName.as CopyAssign.as
  AddElement.as AddAndContains.as AddDuplicateIgnored.as AppendOtherSet.as
  RemoveElement.as RemoveMissing.as ContainsValue.as ContainsMissing.as
  EmptyClearsNum.as ResetClearsNum.as NumCountsElements.as IsEmpty.as
  EqualityComparesElements.as ForEachElement.as
  IteratorWalk.as IteratorProceed.as IteratorProduced.as ConstIteratorProduced.as
  EmptyIteratorCannotProceed.as
  CopyConstructedIteratorPreserves.as CopyConstructedConstIterator.as
  StructsContainingArrays.as ObjectProperty.as UObjectReferences.as
  EmptyReservedSlack.as
  CompileFail/
    NestedLocal.as NestedLocalDeep.as NestedParam.as
    NestedProperty.as NestedPropertyDeep.as NestedReturn.as
    OfArraysLocal.as OfArraysProperty.as OfMapsLocal.as OfMapsProperty.as
    AddWrongElementType.as ByValueMutation.as MissingTypeArgs.as
    UnknownElementType.as UnsupportedApiAliases.as VoidType.as
  RuntimeFail/
    IteratorOutOfBounds.as IteratorProceedPastEnd.as
```

Pending files that say they are not TSet API (InputSettings, PhysicsConstraint, …) stay out.

## TOptional (one optional value)

Not an array. Storing `0` is set.

```
Containers/TOptional/
  EmptyConstruction.as CopyAssign.as SetValue.as Overwrite.as
  ResetClears.as AssignUnset.as IsSet.as Get.as GetValue.as GetUnset.as
  EqualityComparesValue.as ImplicitConstructFromValue.as StoredZeroIsSet.as
  ObjectProperty.as PropertySetAndReset.as PropertyPerInstance.as
  CompileFail/
    OfArrayLocal.as OfArrayProperty.as OfMapLocal.as OfOptionalLocal.as
    AssignWrongElementType.as MissingTypeArgs.as UnknownElementType.as VoidType.as
  RuntimeFail/
    GetValueUnset.as GetValueAfterReset.as GetValueAfterAssignUnset.as
```

Do not write Add/Num/Contains.

## TSoftObjectPtr (soft ref + three states)

Repair SYNTAX first. Move misplaced `t-soft-class-path-load` to SoftObjectPath.

```
Containers/TSoftObjectPtr/
  DefaultPendingOrNull.as TSoftClassPtrAActorNull.as PathObjectCopyConstructors.as
  CopyAssign.as AssignCopyIndependent.as ToSoftObjectPath.as ToString.as Reset.as
  Get.as IsValid.as IsPending.as IsNull.as EqualityComparesPath.as
  GetLongPackageName.as GetAssetName.as
  LoadAsync.as LoadAsyncPathUnchanged.as LoadAsyncMissingPackage.as
  EditorOnlyLoadSynchronous.as ObjectProperty.as PropertyPerInstance.as
  CompileFail/
    NestedLocal.as MissingTypeArgs.as
  RuntimeFail/                        // only with Bind-forbidden paths
    LoadAsyncActorForbidden.as AssignClassNotSubtype.as
```

## TWeakObjectPtr (weak lifetime)

Pascalize already-long names. The hole is `IsStale` after GC.

```
Containers/TWeakObjectPtr/
  DefaultConstructionIsNull.as
  DefaultConstructionIsExplicitlyNullNotStale.as
  DefaultConstructionCopyIndependence.as
  AssignObjectMakesValid.as AssignPointerCopiesTarget.as
  ImplicitConversionReturnsTarget.as ReassignReplacesTarget.as
  ReadAssignedTarget.as LiveTargetIsValidNotStale.as
  AssigningNullptrIsExplicitlyNull.as
  ClearingLiveTargetReturnsToExplicitNull.as
  HandClearedIsExplicitlyNull.as ReleasedTargetBecomesInvalid.as
  InvalidatedIsNotExplicitlyNull.as InvalidatedIsStaleNotExplicitlyNull.as
  WeakReferenceDoesNotKeepTargetAlive.as
  PointersToSameTargetAreEqualAndIndependent.as
  CopyConstructFromPointer.as
  WeakPropertiesStartNull.as WeakPropertyKeepsTarget.as
  WeakPropertiesArePerInstance.as BackReferenceBreaksCycle.as
  ClearingWeakPropertyMakesItExplicitlyNull.as
  CompileFail/
    NestedLocal.as MissingTypeArgs.as OfPrimitive.as OfStruct.as
```

No RuntimeFail unless a Bind Throw appears later.

## TSubclassOf (hierarchy + CDO)

```
Containers/TSubclassOf/
  DefaultConstructionIsNull.as DefaultConstructionCopyIndependence.as
  AssignClassMakesValid.as AssignDerivedClassIntoBaseHolder.as
  SetStoresClass.as AssignNullptrClearsHolder.as
  ImplicitConversionReturnsClass.as
  AssignHolderCopiesClassAndStaysIndependent.as
  ReadAssignedClass.as NullIsChildOfNothing.as NullGetDefaultObjectIsNull.as
  DerivedIsChildOfBase.as ClassIsChildOfItself.as
  UnrelatedClassIsNotChildOfBase.as IsChildOfNullptrIsFalse.as
  GetDefaultObjectReturnsStableCdo.as GetDefaultObjectIsOfHeldClass.as
  CopyConstructFromHolder.as
  SubclassPropertiesStartNull.as SubclassPropertyKeepsClassAndHierarchy.as
  SubclassPropertyActsAsFactory.as SubclassPropertiesArePerInstance.as
  ActorClassPropertyAssign.as ClearingSubclassPropertyInvalidatesHierarchy.as
  CompileFail/
    NestedLocal.as MissingTypeArgs.as OfStruct.as
  RuntimeFail/
    ClassNotChild.as AssignUnrelatedViaOpAssign.as ImplicitConstructUnrelated.as
```

## TObjectPtr (strong pointer)

```
Containers/TObjectPtr/
  DefaultConstructionIsNull.as AssignObjectStoresTarget.as
  ImplicitConversionReturnsTarget.as
  AssignPointerCopiesTargetAndStaysIndependent.as
  AssignNullptrClearsTarget.as ReassignReplacesTarget.as
  ReadAssignedTarget.as GetReturnsTheAssignedObject.as
  PointersToSameTargetAreEqualAndIndependent.as
  PointerEqualsHeldObjectOnlyWhenSet.as
  PointersToDifferentTargetsAreUnequal.as
  CopyConstructFromPointer.as NullEqualsNull.as
  ObjectPropertiesStartNull.as ObjectPropertyKeepsTarget.as
  ObjectPropertiesArePerInstance.as StrongPropertyKeepsTargetAlive.as
  PropertyActorAssign.as ClearingObjectPropertyReturnsToNull.as
  FillWithNewObject.as ReplaceTarget.as
  CompileFail/
    NestedLocal.as MissingTypeArgs.as OfStruct.as
```

## SoftObjectPath (path value)

No object-lifetime story. Rename `Queries_02-*` to ClassPath observations. Fail directories only if Bind still diagnoses `::::`.

```
Containers/SoftObjectPath/
  TryLoad.as TryLoadClass.as ResolveObject.as ResolveClass.as
  ResolveClassMissingPath.as EqualityComparesPath.as
  GetLongPackageName.as GetAssetName.as GetAssetPath.as
  IsValid.as IsNull.as IsAsset.as IsSubobject.as
  ClassPathIsValid.as ClassPathIsNull.as ClassPathIsAsset.as
  ClassPathIsSubobject.as ToStringLiveCdo.as
```

Do not keep empty names such as `AsFacingApi`.
