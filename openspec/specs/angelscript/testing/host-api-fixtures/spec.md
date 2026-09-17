# Host API fixtures

## Purpose

Provide hand-authored host-API source fixtures (UE parameterized containers and remaining Bindings type folders) through the existing code database, separate from core Language and from the Unreal first-batch UClass+World inventory.

## Requirements

### Requirement: Admitted Containers inventory

The corpus SHALL expose accepted container FileTags under prefix `Containers/`, as observation paths `Containers/<Type>/<Observation>` including CompileFail and RuntimeFail subdirectories when those polarities exist, with complete versions and valid author metadata. A FileTag SHALL NOT be required to contain a version named `root`. Flat FileTags `Containers/TArray`, `Containers/TArrayCompileFail`, and `Containers/TArrayRuntimeFail` SHALL NOT be required.

#### Scenario: Query TArray AddAndOrder and a RuntimeFail sibling

- **WHEN** the admitted catalog is queried for FileTag `Containers/TArray/AddAndOrder` version `AddAndOrder` and FileTag `Containers/TArray/RuntimeFail/IndexOutOfBounds` version `IndexOutOfBounds`

    > Inputs: prefixes under `Containers/TArray/`. The retired flat tags were `Containers/TArray` and `Containers/TArrayRuntimeFail`.

- **THEN** each FileTag returns a complete parentless program whose version tag equals the file stem

    > Observables: `FAngelscriptTestCode::Get` succeeds. `FindFiles` with topic Containers lists at least one tag prefixed `Containers/TArray/`.

- **AND** Bindings leftover `TArray/Behavior_01.as` is not an admitted source
- **AND** no Containers query requires VersionTag `root`
- **AND** `Get` of flat `Containers/TArray` is unsuccessful

    > Boundaries: Language FileTags stay under `Language/`. Unreal first-batch UClass+World FileTags stay under the unreal-fixtures inventory. Math Function tags stay on `Unreal/<Type>`.

### Requirement: Remaining Bindings types land under Unreal type folders

The corpus SHALL expose the remaining Bindings leftover types under `Unreal/<Type>` FileTags, merged when they collide with an already admitted Unreal first-batch theme.

#### Scenario: Query FMath after merge

- **WHEN** the admitted catalog is queried for `Unreal/FMath`
- **THEN** at least one parentless version is retrievable
- **AND** `FindFiles` with topic Language does not return that Tag
- **BUT** `Unreal/Casting` from the Unreal first batch remains owned by unreal-fixtures and is not rewritten here

### Requirement: Two source piles merge

Container FileTags SHALL absorb both Bindings axis Observe entries and Pending/Containers Fail, thicken, and pointer-type programs. Math type FileTags SHALL also absorb every Pending/Math program, including Function parameter and return programs.

#### Scenario: TArray fail polarity comes from Pending

- **WHEN** `Containers/TArray/RuntimeFail/IndexOutOfBounds` is requested
- **THEN** the FileTag returns a parentless index-out-of-bounds program that existed under `Pending/Containers/TArray/Exception`
- **AND** TSet files whose summary states they are not TSet API are not stored on a TSet FileTag

#### Scenario: Query a Pending/Math Function case

- **WHEN** `Unreal/FVector` version `function-parameters-in` is requested

    > Inputs: FileTag `Unreal/FVector`, VersionTag `function-parameters-in`. The leftover Pending stem was `FunctionParametersIn`.

- **THEN** the database returns a complete parentless program whose body accepts an `FVector` by `&in`

    > Observables: `FAngelscriptTestCode::Get` succeeds and the reconstructed bytes contain `&in`.

- **AND** the same FileTag still exposes the earlier Bindings and Pending/Math construction cases
- **AND** `Pending/Math/FVector/FunctionParametersIn.as` is not an admitted source

    > Observables: FQuat has no leftover Function* files. FVector2D, FTransform, FRotator, and FLinearColor receive the same Function stem tags on their own FileTags.

### Requirement: TArray Function type and direction observations

The admitted TArray inventory SHALL expose parentless FileTags under `Containers/TArray/` for the TestSource-old Function type-axis and UFUNCTION directions, in addition to the existing int32 local observes.

#### Scenario: Query AddAndOrder FString and FillByAdd

- **WHEN** the admitted catalog is queried for FileTag `Containers/TArray/AddAndOrderFString` version `AddAndOrderFString` and FileTag `Containers/TArray/FillByAdd` version `FillByAdd`

    > Inputs: observation paths under `Containers/TArray/`. `AddAndOrderFString` is the FString Observe sibling of `AddAndOrder`. `FillByAdd` is the int32 `&out` sibling.

- **THEN** each FileTag returns a complete parentless program whose version tag equals the file stem

    > Observables: `FAngelscriptTestCode::Get` succeeds. The FString observe source constructs `TArray<FString>` and calls `Add`. The `&out` source declares `TArray<int32>&out`.

- **AND** `Get(Containers/TArray/AddAndOrder, AddAndOrder)` remains successful

    > Observables: the original int32 local observe is not deleted or folded into a typed sibling.

- **AND** `FindFiles` with topic Containers still lists tags prefixed `Containers/TArray/`

- **BUT** other container type directories are not required to gain type-axis or direction siblings in this requirement

    > Boundaries: TMap, TSet, and pointer containers stay as the directory-rewrite inventory. TestSource-old Advance compose boxes, Negative nested containers, and Reject aliases are not admitted by this requirement. CompileFail and RuntimeFail siblings already on TArray stay in place.

### Requirement: TMap TSet TOptional Function type and direction observations

The admitted TMap, TSet, and TOptional inventories SHALL expose parentless FileTags under `Containers/<Type>/` for the TestSource-old Function type-axis and UFUNCTION directions, in addition to the existing local observes and any already admitted TMap `*In` FileTags.

#### Scenario: Query typed observe and FillBy on each tree

- **WHEN** the admitted catalog is queried for FileTag `Containers/TMap/AddPairInsertsKeyValueFString` version `AddPairInsertsKeyValueFString`, FileTag `Containers/TMap/FillByAddPairInsertsKeyValue` version `FillByAddPairInsertsKeyValue`, FileTag `Containers/TSet/AddElementIsContainedFString` version `AddElementIsContainedFString`, FileTag `Containers/TSet/FillByAddElementIsContained` version `FillByAddElementIsContained`, FileTag `Containers/TOptional/SetValueFString` version `SetValueFString`, and FileTag `Containers/TOptional/FillBySetValue` version `FillBySetValue`

    > Inputs: observation paths under `Containers/TMap/`, `Containers/TSet/`, and `Containers/TOptional/`. The FString leaves are typed Observe siblings. The `FillBy*` leaves are int `&out` siblings.

- **THEN** each FileTag returns a complete parentless program whose version tag equals the file stem

    > Observables: `FAngelscriptTestCode::Get` succeeds. The TMap FString observe constructs `TMap<FString, int>` and calls `Add`. The TSet FString observe constructs `TSet<FString>` and calls `Add`. The TOptional FString observe constructs `TOptional<FString>` and calls `Set`. Each `&out` source declares the matching int container as `&out`.

- **AND** `Get(Containers/TMap/AddPairInsertsKeyValue, AddPairInsertsKeyValue)`, `Get(Containers/TSet/AddElementIsContained, AddElementIsContained)`, and `Get(Containers/TOptional/SetValue, SetValue)` remain successful

    > Observables: the original local observes are not deleted or folded into a typed sibling.

- **AND** `Get(Containers/TMap/ContainsKeyIn, ContainsKeyIn)` remains successful

    > Observables: admitted TMap `*In` FileTags are not renamed to `Read*`.

- **AND** `FindFiles` with topic Containers still lists tags prefixed `Containers/TMap/`, `Containers/TSet/`, and `Containers/TOptional/`

- **BUT** pointer wrappers and SoftObjectPath are not required to gain type-axis or direction siblings in this requirement

    > Boundaries: TObjectPtr, TSoftObjectPtr, TWeakObjectPtr, TSubclassOf, and SoftObjectPath stay as the directory-rewrite inventory. TestSource-old Advance compose boxes, Negative nested containers, Reject aliases, and misplaced TSet Function files are not admitted by this requirement. CompileFail and RuntimeFail siblings already on these trees stay in place.
