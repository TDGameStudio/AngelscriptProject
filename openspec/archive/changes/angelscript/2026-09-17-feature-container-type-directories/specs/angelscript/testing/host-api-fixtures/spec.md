## Purpose

Keep host-API container FileTags queryable after flat type pockets become observation directories.

## MODIFIED Requirements

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
