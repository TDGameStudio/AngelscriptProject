## ADDED Requirements

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
