---
review_schema: review-v2
review_kind: external
requested_by: user
state: closed
assigned_at: 2026-09-17T19:58:48.500141+08:00
reviewed_at: 2026-09-17T20:03:26.812665+08:00
closed_at: 2026-09-17T20:03:44.456274+08:00
snapshot_ref: D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/review-20260917-195848-tmap-tset-optional-impl
snapshot_sha256: 15d60b51aa6942a2235721a2758e2b5f82baa02122d7caa95a7f45015a7d0418
verdict: APPROVE
---

# External Review — TMap TSet TOptional type-and-direction implementation

Change `angelscript/feature-tmap-tset-optional-type-direction`. Kind is External Review of the frozen implementation snapshot after tasks 1.1–5.1. Read-only against `snapshot_ref/files/` and `manifest.json`. Live workspace was not treated as reviewed content. Broad gates were not rerun.

## Snapshot verification

- `manifest.sha256` and the assignment digest both equal `15d60b51aa6942a2235721a2758e2b5f82baa02122d7caa95a7f45015a7d0418`.
- SHA-256 of `manifest.json` recomputed as the same digest (PowerShell `Get-FileHash`).
- Manifest lists 960 files. Every listed path exists under `files/` and matches the recorded `sha256` and `bytes` (0 mismatches).
- Manifest counts: TMap 436 `.as`, TSet 326 `.as`, TOptional 170 `.as`. Those counts match a recursive listing of the copied author trees.

Limitation (does not change the verdict): the snapshot copies only four representative Generated units, not the full `TestCode/Generated/Containers/{TMap,TSet,TOptional}` tree. Full projection sync is taken from coordinator 4.1 `codegen.py check` exit 0 after generate. TestSource-old Function piles are not in the snapshot, so the historical “12 / 9 / 7” subject names cannot be re-derived from old files here; completeness is judged from the Change records plus the copied author matrices.

## Scope and method

Requirements under review:

- Current spec `files/openspec/specs/angelscript/testing/host-api-fixtures/spec.md` requirement **TMap TSet TOptional Function type and direction observations** (lines 89–115).
- Matching Change delta `files/openspec/changes/angelscript/feature-tmap-tset-optional-type-direction/specs/angelscript/testing/host-api-fixtures/spec.md`.
- Task cards 1.1–5.1 and their Evidence in `files/openspec/changes/angelscript/feature-tmap-tset-optional-type-direction/tasks.md`.
- Glossary / design constraints: one observation per file; stem = `@begin` = entry; Pascal type suffixes; per-tree types (FName in; no float keys/elements); directions `Read` / `FillBy` / `Mutate`; keep admitted TMap `*In`; EmptyConstruction types-only; admission is parse / project / `Get`.

Inspection was not a count rubber-stamp. After reading the proving tests and task cards, every copied `.as` under the three trees was classified (identity, type suffix, direction / `*In`, EmptyConstruction, float, Advance/Negative/Reject, `@topic`, fail-dir stems). Direction parameter qualifiers and TMap key/value placement were checked on every non-fail author. Representative bodies, UObject dummies, the four Generated units, `HostApiFixtureCorpusTests.cpp`, and the copied HostApiFixtureCorpus Fast run were read directly.

Excluded as assigned: SoftObjectPath, pointer wrappers, TArray except `CorpusHasTArrayTypeAndDirection`, unrelated dirty paths, Unreal binaries, archive/commit, a new UE rerun.

## Findings

No open Critical or Required findings. No Advisory findings. Nothing in the snapshot invalidated the published requirement, the Task DAG, or the admission contract.

## Verified sound

### Planning and published contract

- Change delta and current host-api-fixtures spec text for this requirement match. Scenario FileTags are the six representatives plus keep-existing observes and `ContainsKeyIn`.
- Task 1.1–5.1 FileTags, proving commands, and Evidence line up with that scenario. 5.1 names `CorpusHasTMapTSetOptionalTypeAndDirection` as assumed at planning; the C++ method uses that name.
- Glossary decisions are applied: keep TMap `*In`; new directions are `Read` / `FillBy` / `Mutate`; type tables are per tree; corpus method is not split per tree.
- Talk `files/openspec/changes/angelscript/feature-tmap-tset-optional-type-direction/attachments/talks/talk-20260917-191900-names-and-approval.md` required mixed `ContainsKeyIn` + `FillByContainsKey` / `MutateContainsKey` and `ReadAddPairInsertsKeyValue` for new subjects. The author tree matches that picture. No `ReadContainsKey*`, `ReadNumCountsPairs*`, or `ReadIndexAccess*` files exist.

### Identity (all copied authors, including CompileFail / RuntimeFail)

- 932 `.as` files under the three trees. Each file has exactly one `@begin`, the header lists the stem, and the entry function name equals the stem (0 identity mismatches).
- Every file is `@version v1` and `@topic Containers` (1864 topic tags: file header plus `@begin` block). No foreign topic.
- No file stem is a bare method-alias from `test_container_observation_identity.py` `METHOD_ALIAS_STEMS` (no `AddPair.as`, no `IndexAccess.as`; int index observe stays `IndexAccessReadsStoredValue`).
- No Advance / Negative / Reject paths or stems. CompileFail / RuntimeFail names stay the existing fail inventory (TMap 20+6, TSet 16+2, TOptional 8+3).

### Type axis and directions

Direction / `*In` qualifiers on every non-fail author (0 mismatches):

| Family | Count | Parameter shape |
|---|---:|---|
| `Read*` | 186 | `const T…&in` only |
| `FillBy*` | 204 | `T…&out` only |
| `Mutate*` | 204 | `T…&inout` only |
| admitted TMap `*In` | 18 | `const TMap<…>&in` only |

- Type suffixes present on expanded subjects: FString, FName, Bool, FVector, UObject. No `float` / `TMap<float` / `TSet<float` / `TOptional<float` keys or elements. FVector bodies use component literals such as `1.0f`; that is not a float-key axis.
- TMap placement matches the glossary: FString and FName are keys (`TMap<FString, int>`, `TMap<FName, int>`); Bool, FVector, and UObject are values (`TMap<int, bool>`, `TMap<int, FVector>`, `TMap<int, UObject>`). Bool authors use `bool`, not a `Bool` type token.
- `EmptyConstruction` is types-only on all three trees (typed observes, no `Read` / `FillBy` / `Mutate` / `*In`). TSet `EmptyConstructionFName.as` remains.
- TMap subjects that already had `*In` (`ContainsKey`, `NumCountsPairs`, `IndexAccess`) gained `FillBy` / `Mutate` only. Int IndexAccess FillBy/Mutate keep the longer `IndexAccessReadsStoredValue` stem; typed IndexAccess FillBy/Mutate use the shorter `IndexAccess<Type>` stem to match existing `IndexAccess<Type>In`. That matches task 1.1 Naming assumed.
- Existing local observes named by the spec and tasks still exist and were not folded into typed siblings: `AddPairInsertsKeyValue.as` (still `TMap<FName, int32>`), `ContainsKeyIn.as` (`const TMap<int, int>&in`), `AddElementIsContained.as`, `SetValue.as`.
- TMap new int directions use `TMap<int, int>&out` / `&in` / `&inout` as allowed by 1.1. TSet / TOptional int directions use `int32`, matching 2.1 / 3.1 cases and the corpus needles.
- TOptional has seven subjects with a type-plus-direction (or types-only) set: `CopyAssign`, `EmptyConstruction`, `GetReturnsStoredValue`, `GetValueReturnsStoredInt`, `IsSetAfterSet`, `ResetClears`, `SetValue`. That matches the recorded seven old Function files. Typed siblings of `GetValueReturnsStoredInt` keep that existing stem and append the Pascal suffix (`GetValueReturnsStoredIntFString.as` stores `TOptional<FString>`). Awkward, but it is the keep-existing-stem rule, not a rename of the int observe.
- TMap / TSet expanded more existing local stems than the recorded 12 / 9 Function counts (Add / Remove / Find / Contains / Num / Index / Empty / Reset / Copy / ForEach / GetKeys / GetValues, plus TSet extras such as `AddDuplicateIgnored` and `AppendOtherSet`). Extra leaves are still one-observation parentless files with the same type and direction rules. Not a contract break.

### UObject dummy pattern

- Dummy `UCLASS` appears when the program calls `NewObject` (typed observes, FillBy/Mutate that construct handles). Class names are unique across the snapshot (113 `UCLASS` files, 0 duplicate class names), e.g. `UTMapAddPairInsertsKeyValueUObjectHost`, `UTSetAddElementIsContainedUObjectHost`, `UTOptionalSetValueUObjectHost`.
- `Read*` / admitted `*In` / mutate-empty UObject leaves take `UObject` handles on the parameter and do not declare a dummy. No `NewObject` without `UCLASS()`. This matches “keep names unique” for observes that actually construct, and does not invent a dummy on a const `&in` reader.

### Representative bodies (sampled, not only named)

- `AddPairInsertsKeyValueFString.as`: parentless `AddPairInsertsKeyValueFString()`, `TMap<FString, int>`, `.Add(`.
- `FillByAddPairInsertsKeyValue.as`: `void FillByAddPairInsertsKeyValue(TMap<int, int>&out Result)` and three `Result.Add`.
- `AddElementIsContainedFString.as`: `TSet<FString>` + `.Add(`.
- `FillByAddElementIsContained.as`: `TSet<int32>&out`.
- `SetValueFString.as`: `TOptional<FString>` + `.Set(`.
- `FillBySetValue.as`: `TOptional<int32>&out`.
- `ReadAddPairInsertsKeyValue.as` / `ReadAddElementIsContainedFString.as` / `ReadSetValue.as`: const `&in` membership/value checks; no write-back.
- `ReadFindOrAddInserts.as`: reports already-present keys; does not call `FindOrAdd` on the const map.
- `ReadCopyAssign.as` and typed siblings: `Set` is on a local `Expected`, not on the `&in` parameter.
- `FillByContainsKey.as` / `FillByGetKeysListsPresentKeys.as` / `FillByIndexAccessFString.as`: `&out` populate via `Add` (FillBy-as-setup for the subject). Every `FillBy*` has a write API on the out parameter.
- `ForEachPairFString.as` / `ReadForEachPairFString.as` / `FillByForEachPairFString.as` / `MutateForEachPairUObject.as`: range-for on the matching map; mutate UObject adds a third `NewObject` handle after the visit.
- `EmptyConstructionFString.as` (TMap) / `EmptyConstructionFName.as` (TSet) / `EmptyConstruction.as` (TOptional): types-only empty/unset observes.

### Proving tests (read; coordinator GREEN accepted)

- `test_tmap_type_direction.py`: four cases match 1.1 (FString parse, FillBy `&out`, existing AddPair, `ContainsKeyIn` still `&in`).
- `test_tset_type_direction.py`: three cases match 2.1 (`TSet<FString>` + `Add`, `TSet<int32>&out`, existing AddElement).
- `test_toptional_type_direction.py`: three cases match 3.1 (`TOptional<FString>` + `Set`, `TOptional<int32>&out`, existing SetValue).
- `test_container_observation_identity.py`: stem = header = single parentless version = entry (or class-only). Coordinator 4.1: 2/2 OK after generate.
- These parse tests pin the spec representatives, not the full typed-direction matrix. The matrix was checked on the snapshot authors as described above. That is plan-aligned: admission is parse / project / `Get`, not AngelScript execute.

### Generated representatives

Each of the four copied units is format v2, FileTag and version equal the stem, `AS_TEST_SOURCE` contains that entry, `Topics = {TEXT("Containers")}`, and the header `source=` / `length=` / `sha256=` matches the copied author bytes:

| Generated unit | Author sha256 |
|---|---|
| `…/TMap/AddPairInsertsKeyValueFString.generated.cpp` | `8d27623a22cf99871297cc29aa340685b51f7060ad9380144467c5f76f7ae03d` |
| `…/TMap/FillByAddPairInsertsKeyValue.generated.cpp` | `4d0d8e0d8282b6e7c7268c559eac402ca51194538cc07eb9a2a230fc11874c6e` |
| `…/TSet/AddElementIsContainedFString.generated.cpp` | `9e003a2d9492fd8152042ffa8947731a07277d708365ac8f245842eccd0991ca` |
| `…/TOptional/SetValueFString.generated.cpp` | `201259de16b8e60b71162a1f20027ed8e71ff4e911bbd268876d19a91af644d9` |

### Corpus method and coordinator UE evidence

- `HostApiFixtureCorpusTests.cpp` `CorpusHasTMapTSetOptionalTypeAndDirection` (from line 118) `Get`s the six spec FileTags and asserts the spec source needles (`TMap<FString, int>` + `.Add(`, `TMap<int, int>&out`, `TSet<FString>` + `.Add(`, `TSet<int32>&out`, `TOptional<FString>` + `.Set(`, `TOptional<int32>&out`). It also `Get`s the three existing observes, `ContainsKeyIn`, and the TArray control `AddAndOrderFString`.
- `CorpusHasTArrayTypeAndDirection` remains as the assigned TArray control.
- Copied run `files/Saved/Harness/Unreal/Runs/db6568d4a4a142469626c515ddb2d828/`: `Summary.json` Outcome Passed, 6/6. `AutomationReport/index.json` lists `CorpusHasTMapTSetOptionalTypeAndDirection` Success together with the five pre-existing HostApiFixtureCorpus methods.
- Spec AND “`FindFiles` topic Containers still lists `Containers/TMap|TSet|TOptional/`” is not a separate assert in the new method. `CorpusHasTArrayPrefix` already `FindFiles`s topic Containers. Every copied author is `@topic Containers`, and the four Generated units project `Topics = {TEXT("Containers")}`. Combined with successful `Get` of prefixed FileTags, that AND is held by the snapshot content. Not filed as a test-gap finding.
- Build run `f7f40ec404f84d64b76e4c64fc3cf6f4` is coordinator-only (Succeeded; `Summary.json` not in this snapshot). No focused reproduction was required.

## Verification story

Coordinator already ran the Change proving selectors: TMap 4/4, TSet after typed-direction backfill, TOptional 3/3, 4.1 RED check exit 1 then GREEN identity 2/2 + check 0, HostApiFixtureCorpus Fast 6/6, `openspec.validate` change + spec `--strict` valid. This Review checked the frozen authors, tests, representative projections, corpus method, published spec, and the copied 6/6 report against those contracts. No open Critical or Required defect.

## Verdict

**APPROVE**

## Coordinator triage

Verified against the assigned snapshot: `manifest.sha256` recomputes to `15d60b51aa6942a2235721a2758e2b5f82baa02122d7caa95a7f45015a7d0418`; 18 TMap `*In` files remain including `ContainsKeyIn.as`; no `TMap<float` / `TSet<float` / `TOptional<float` axis. No findings to reproduce, reject, or repair. Closed APPROVE.
