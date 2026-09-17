# LANG-DTOR-PARTIAL

Author reference for `FDtorPartialGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Topology: `INDEPENDENT` | `NESTED_MEMBER` | `BASE_DERIVED` | `COPY_TRANSFER` | `ASSIGNMENT_TRANSFER` | `SELF_ASSIGNMENT` | `REFERENCE_ALIAS`
2. Boundary: `BEFORE_ROOT` | `ROOT_STARTED` | `FIRST_OWNED` | `MIDDLE_OWNED` | `ALL_OWNED` | `COMPLETE`
3. Exit: `NORMAL` | `EXCEPTION` | `ABORT` | `UNPREPARE`

Product ID prefix: `LANG-DTOR-PARTIAL`. Complete set: 7×6×4 = 168 cells. Enumeration nests Topology (outer), then Boundary, Exit (inner).

Normal-return aggregate = 126. Compile reject = 0. Runtime fault (`divide_by_zero`) = 42 (`EXCEPTION` × every topology × every boundary). OutCaseCount = 168.

Example: `LANG-DTOR-PARTIAL-INDEPENDENT-BEFORE_ROOT-NORMAL` → `int EntryLangDtorPartialIndependentBeforeRootNormal()`.

## Source branches

Shared types are emitted once per aggregate: `FPartialNestedOwner`, `FPartialBaseOwner`, `FPartialDerivedOwner`, `FPartialBundle`, `FPartialReferenceOwner`. Isolated modules emit only the topology's types. `int RunDestructorPartialRecovery()` is appended to every module.

Each entry walks construction stages and returns at the selected boundary when `ReachDestructorPartialBoundary(stage)` is true:

- stage 0 `BEFORE_ROOT`: return `0` (or `1 / Zero` on `EXCEPTION`)
- stage 1 `ROOT_STARTED`: start the root (`int RootStarted = 1` or construct the topology owner) and return `1`
- stage 2 `FIRST_OWNED`: assign `First = CreateNativeCaseReference(101)` and return `First.Value`
- stage 3 `MIDDLE_OWNED`: assign `Middle` (202) and return `First.Value + Middle.Value`
- stage 4 `ALL_OWNED`: assign `Last` (303) and return the three-field checksum
- stage 5 `COMPLETE`: finish transfer (`Target = Source`, `Target = Source` assignment, `Source = Source`, or `Alias = Source`) and return the complete expression

Independent locals are `First`/`Middle`/`Last`. Member/base/derived owners use `Root.*`. Transfer topologies use `Source.*` plus `Target` or `Alias` on complete. `EXCEPTION` replaces the boundary return with `return 1 / Zero`. `ABORT` and `UNPREPARE` share the normal-return source. Every early exit still has a dead `return -1`.

Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Boundary `ExpectedNormalResult`: `BEFORE_ROOT`=0, `ROOT_STARTED`=1, `FIRST_OWNED`=101, `MIDDLE_OWNED`=303, `ALL_OWNED`/`COMPLETE`=606. When `Boundary == COMPLETE` and topology is `COPY_TRANSFER`, `ASSIGNMENT_TRANSFER`, or `REFERENCE_ALIAS`, the observation is doubled.

`GetExpected` uses this formula for the 126 non-exception IDs. Fault IDs and unknown IDs return 0; that zero fallback is not membership proof. `INDEPENDENT-BEFORE_ROOT-NORMAL` is a real expected zero and keeps `ExpectedReturn` set.

Normal rows are `ReturnValue` + `RequiresHostSetup`. Fault rows are `RuntimeException` with exact text `Divide by zero` and no integer expectation. Host notes name `FNativeCaseReference`, `CreateNativeCaseReference`, and `ReachDestructorPartialBoundary`.
