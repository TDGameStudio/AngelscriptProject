## Purpose

Provide hand-authored host-API source fixtures (UE parameterized containers and remaining Bindings type folders) through the existing code database, separate from core Language and from the Unreal first-batch UClass+World inventory.

## ADDED Requirements

### Requirement: Admitted Containers inventory

The corpus SHALL expose accepted container FileTags under prefix `Containers/`, including TArray, TMap, TSet, TOptional, TSoftObjectPtr, TWeakObjectPtr, TSubclassOf, TObjectPtr, and SoftObjectPath, with CompileFail and RuntimeFail siblings when those polarities exist, complete versions, and valid author metadata. A FileTag SHALL NOT be required to contain a version named `root`.

#### Scenario: Query TArray positive and fail siblings

- **WHEN** the admitted catalog is queried for `Containers/TArray`, `Containers/TArrayCompileFail`, and `Containers/TArrayRuntimeFail`
- **THEN** each FileTag that exists returns at least one parentless version
- **AND** Bindings leftover `TArray/Behavior_01.as` is not an admitted source
- **AND** no Containers query requires VersionTag `root`

    > Boundaries: Language FileTags stay under `Language/`. Unreal first-batch UClass+World FileTags stay under the unreal-fixtures inventory.

### Requirement: Remaining Bindings types land under Unreal type folders

The corpus SHALL expose the remaining Bindings leftover types under `Unreal/<Type>` FileTags, merged when they collide with an already admitted Unreal first-batch theme.

#### Scenario: Query FMath after merge

- **WHEN** the admitted catalog is queried for `Unreal/FMath`
- **THEN** at least one parentless version is retrievable
- **AND** `FindFiles` with topic Language does not return that Tag
- **BUT** `Unreal/Casting` from the Unreal first batch remains owned by unreal-fixtures and is not rewritten here

### Requirement: Two source piles merge

Container FileTags SHALL absorb both Bindings axis Observe entries and Pending/Containers Fail, thicken, and pointer-type programs.

#### Scenario: TArray fail polarity comes from Pending

- **WHEN** `Containers/TArrayRuntimeFail` is requested
- **THEN** at least one version carries an index-out-of-bounds or copy-bounds program that existed under `Pending/Containers/TArray/Exception`
- **AND** TSet files whose summary states they are not TSet API are not stored on a TSet FileTag
