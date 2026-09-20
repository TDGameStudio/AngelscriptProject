# Coverage wave: named new begins

Source: draft finding (Chinese original; approval R3/R6). Write these after the quality list. Each is a new file. Do not merge them into old dump blocks.

## TArray

Quality renames: `EmptyConstruction`, `CopyAssign` / `IteratorAssign`.  
New: `ReserveClampsBelowNum`, `RemoveSinglePreservesOrder`, `RemoveSingleSwapReorders`, `FloatIndexLast`.  
RuntimeFail: `InsertIndexPastNum`, `SwapSecondIndexOutOfBounds`, `LastIndexFromEndOutOfBounds`, `IteratorProceedPastEnd`, `RemoveAtSwapOutOfBounds`. Start incomparable-type cases only when a struct without `opEquals` exists.

## TMap

New (beyond dump splits): `IteratorGetKeyWithoutProceed`, `IteratorSetValueWithoutProceed`, `IteratorRemoveCurrentWithoutProceed`, `EmptyVersusReset` (IsEmpty/Num only).  
RuntimeFail: `IndexMissingKeyWrite`.  
Do not dump Pending Advance.

## TSet

`IteratorProceedPastEnd`. `EmptyReservedSlack` only if Max/capacity is observable.

## TOptional

`ImplicitConstructFromValue`, `StoredZeroIsSet`, `PropertySetAndReset`, `PropertyPerInstance`.  
RuntimeFail: `GetValueAfterReset`, `GetValueAfterAssignUnset`.

## TSoftObjectPtr

Repair SYNTAX first. Then `LoadAsyncMissingPackage`, `LoadAsyncPathUnchanged`, `AssignCopyIndependent`, `PropertyPerInstance`.  
RuntimeFail directory only with evidence: `LoadAsyncActorForbidden`, `AssignClassNotSubtype`.  
Move `t-soft-class-path-load` to SoftObjectPath.

## TWeakObjectPtr

`InvalidatedIsStaleNotExplicitlyNull`, `CopyConstructFromPointer`.

## TSubclassOf

`CopyConstructFromHolder`, `ActorClassPropertyAssign`.  
RuntimeFail: `AssignUnrelatedViaOpAssign`, `ImplicitConstructUnrelated`.

## TObjectPtr

`CopyConstructFromPointer`, `NullEqualsNull`, `PropertyActorAssign`.  
RoundTrip samples: `FillWithNewObject`, `ReplaceTarget`.

## SoftObjectPath

`ResolveClassMissingPath`, `ToStringLiveCdo`. Quality renames Queries_02 to `ClassPathIsValid` and siblings. Fail directories only if malformed `::::` still diagnoses.
