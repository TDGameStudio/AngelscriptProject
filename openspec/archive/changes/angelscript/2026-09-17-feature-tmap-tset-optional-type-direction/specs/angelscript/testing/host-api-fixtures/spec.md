## ADDED Requirements

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
