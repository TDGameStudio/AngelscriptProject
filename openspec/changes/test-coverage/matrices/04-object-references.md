# Object References And GC Coverage Matrix

> **This matrix is the design specification header for object reference / GC tests**: each row is a concrete verifiable scenario guiding five test files. ⬜ means pending, ✅ identifies the covering `TEST_METHOD`, and 🚫 means fork unsupported.
>
> - Test files: `Handle`(16) / `Handles`(10) / `WeakReference`(10) / `SoftReference`(11) / `GC`(12) Tests.cpp
> - Automation prefix: `Angelscript.TestModule.Coverage.<Handle|Handles|WeakReference|SoftReference|GC>`
> - See `../coverage-matrix.md` for the legend; interface reference boundaries are in `../coverage-gaps.md §2.3`.

## 1. UObject Handle Basics And Operations, HandleTests

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Basic handle declaration/assignment | ✅ | `HandleBasics` |
| Handle comparison, == / != / null | ✅ | `HandleComparison` |
| Cast and type conversion | ✅ | `HandleCast` |
| Handle operations, GetClass/GetName and related APIs | ✅ | `HandleOperations` |
| Handle as property | ✅ | `HandleAsProperty` |
| Handle as parameter | ✅ | `HandleAsParameter` |
| Handle in containers, arrays / Set | ✅ | `HandleInContainers` `HandleSetContainer` |
| Member object / Actor / component references | ✅ | `MemberObjectActorComponentReferences` |
| NewObject and handle | ✅ | `UObjectHandleAndNewObject` `UObjectHandleAssignmentAndActorOuter` |
| UObject flag mutation and transient state | ✅ | `UObjectFlagMutationAndTransientState` |
| UObject outer chain and path matrix | ✅ | `UObjectOuterChainAndPathMatrix` |
| Destroyed Actor invalidates reference | ✅ | `HandleDestroyActorInvalidatesReference` |

## 2. TObjectPtr Routing And Explicit Properties

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| TObjectPtr routing, transparent script-side handling | ✅ | `HandleTests::TObjectPtrRouting` |
| NewObject + TObjectPtr + Subclass references | ✅ | `HandlesTests::UObjectNewObjectTObjectPtrAndSubclassReferences` |

## 3. Weak References, TWeakObjectPtr, WeakReferenceTests + HandlesTests

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Weak reference basics | ✅ | `WeakObjectPtrBasics` |
| Invalidation detection | ✅ | `WeakObjectPtrInvalidation` |
| As property | ✅ | `WeakObjectPtrAsProperty` |
| Null comparison and reassignment | ✅ | `WeakObjectPtrNullComparisonAndReassignment` |
| Break back-reference cycles | ✅ | `WeakObjectPtrBreaksBackReferenceCycle` |
| Weak reference array container, including reassignment | ✅ | `WeakObjectPtrArrayContainer` `HandlesTests::WeakObjectPtrArrayContainerAndReassignment` |

## 4. TSubclassOf, WeakReference + Handle + Handles

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Basics and as property | ✅ | `TSubclassOfBasics` `TSubclassOfAsProperty` |
| Spawn / NewObject | ✅ | `TSubclassOfSpawn` `HandleTests::TSubclassOfParameterAndNewObject` |
| Type check | ✅ | `TSubclassOfTypeCheck` |
| Comprehensive usage | ✅ | `HandlesTests::TSubclassOfUsage` |

## 5. Soft References, TSoftObjectPtr / TSoftClassPtr, SoftReferenceTests + Handles

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| SoftObjectPtr basics / null checks / path | ✅ | `SoftObjectPtrBasics` `SoftObjectPtrNullChecks` `SoftObjectPtrPath` |
| SoftObjectPtr as property / in containers | ✅ | `SoftObjectPtrAsProperty` `SoftObjectPtrInContainers` |
| SoftObjectPtr path construction and pending / async load | ✅ | `SoftObjectPtrPathConstructionAndPending` `SoftObjectPtrAsyncLoad` |
| SoftClassPtr basics / path / as property / configured path | ✅ | `SoftClassPtrBasics` `SoftClassPtrPath` `SoftClassPtrAsProperty` `SoftClassPtrConfiguredPath` |
| Comprehensive soft reference usage, Handles | ✅ | `HandlesTests::SoftReferenceUsage` `SoftReferencePathConstructionAndPendingBoundary` |

## 6. Garbage Collection, GCTests

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Basic reclaim | ✅ | `GCBasicReclaim` |
| UPROPERTY protection prevents collection | ✅ | `GCUPropertyProtection` |
| Weak pointer invalidation | ✅ | `GCWeakPtrInvalidation` |
| Container protection | ✅ | `GCContainerProtection` |
| Cross-frame hold | ✅ | `GCCrossFrameHold` |
| Local variables do not protect | ✅ | `GCLocalVariableNoProtection` |
| Collection methods / IsValid checks | ✅ | `GCCollectionMethods` `GCIsValidCheck` |
| NewObject Outer and collection | ✅ | `GCNewObjectOuterAndCollection` |
| Root reachability / UPROPERTY reachability chain | ✅ | `GCRootReachability` `GCUPropertyReachabilityChain` |
| Strong cycle reference reclaim | ✅ | `GCStrongCycleReclaim` |

## 7. Reference Validity And Native Interface Handles

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Reference validity checks | ✅ | `HandlesTests::ReferenceValidityChecks` |
| Native interface reference handles | ✅ | `HandlesTests::NativeInterfaceReferenceHandles` |
| GC reachability and weak invalidation boundary, Handles | ✅ | `HandlesTests::GCReachabilityAndWeakInvalidationBoundary` |

## 8. Boundaries, Fork Unsupported

| Scenario | Status | Notes |
|------|------|------|
| Script-level `TScriptInterface<I>` references | 🚫 | See `07-macros-enum-function-interface.md` and `../coverage-gaps.md §2.3` |

---

## Summary

| File | Methods | Notes |
|------|------|------|
| Handle | 16 | handle basics / operations / containers / TObjectPtr routing / UObject flag and outer-path matrices |
| Handles | 10 | references as properties/parameters plus TObjectPtr / weak arrays / soft reference aggregate coverage |
| WeakReference | 10 | TWeakObjectPtr + TSubclassOf |
| SoftReference | 11 | TSoftObjectPtr / TSoftClassPtr |
| GC | 12 | reclaim / protection / reachability / cycles |
| **Total** | **59** | |

**Pending (⬜)**: audit confirmed that `TObjectPtr` routing/properties (§2) and weak reference arrays (§3) are covered. Original `coverage-gaps.md` G3/G4 were corrected from pending to covered, with optional deeper assertions if needed. No hard gaps currently remain.
