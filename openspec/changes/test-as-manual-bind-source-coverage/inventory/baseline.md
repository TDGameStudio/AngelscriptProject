# Baseline

## Snapshot

- Planning date: 2026-08-21 (Asia/Shanghai)
- Parent repository commit: `94e9efaf74d0d60d79c289fa2affc3c107926db7`
- `Plugins/Angelscript` commit: `ed22fbdf0fc1a3793b006bb703aeb62a7500b25a`
- Workspace: main checkout at `D:/Workspace/AngelscriptProject`
- `TestSource/`: present and empty before this record
- Physical `AngelscriptRuntime/Binds/Bind_*.cpp`: 204
- Logical Bind units after removing `_Type` / `_Functions`: 127
- Logical main files with AS usage table: 125
- Fixed `FunctionLibraryMixins` supplemental registrations: 8
- Fixed-script-surface infrastructure unit without owned signatures: `BlueprintCallable`
- Recorded AS-facing surface rows: 3,015
- Planned Bind `.as` files: 576
- Planned TestFramework `.as` files: 38
- Total planned `.as` files: 614
- Current C++/AS reference records: 820
- `AngelscriptTest` `.cpp` files scanned: 1,020
- `AngelscriptTest` `TEST_METHOD` definitions scanned: 4,379
- Runtime script-test-framework C++ files: 7
- Runtime script-test-framework `TEST_METHOD` definitions: 55

## Full-theme planning snapshot

- Core real `TEST_METHOD` definitions after excluding a quoted `"TEST_METHOD("` sentinel: 4,378
- GameplayTags Test `.cpp` / methods: 7 / 15
- GAS Test `.cpp` / methods: 26 / 252
- Total current methods assigned a disposition: 4,645
- Candidate C++ raw-string blocks with arbitrary delimiters: 3,672
- Independent `.as` references: 651 (37 `Script/**` + 614 materialized `TestSource/**`)
- Total stable script/reference rows: 4,323
- Newly planned handwritten theme sources: 2,427
- Existing materialized Bindings/TestFramework sources: 614
- Total TestSource source tasks after theme expansion: 3,041
- Generation-owned candidates: 54 source references (51 Language + 3 Definitions)
- Blocked `Gameplay.FMath` candidates: 50 source references
- New sources materialized / source-semantically accepted: 0 / 0

Reproduce these counts with `scripts/BuildTestSourceThemeInventory.ps1`; its `-Check` mode performs a read-only drift check.

## Initial implementation review snapshot (historical)

- Review date: 2026-08-21 (Asia/Shanghai)
- Planned `.as` paths present: 614 / 614
- Files with all planned namespace/callable symbols present: 614 / 614
- Bind sources reviewed: 576
- Bind `Observe_*` functions: 2,420
- Bind `Observe_*` functions with non-void results: 0
- Bind `Observe_*` functions with parameters: 0
- Bind `Observe_*` functions that are void and no-argument: 2,420
- Bind files with detected discarded local observation values: 552
- Bind files with detected tautology or permissive fixture-null success: 67
- Direct Bind actor spawn calls / actor destruction calls: 34 / 0
- High-impact host side-effect call sites: 17 across 5 files
- TestFramework sources: 38, containing 103 reflected test methods and 221 detected assertion calls
- TestFramework sources naming the future C++ oracle: 38 / 38
- Source-semantically accepted Bind files: 0 / 576
- Externally accepted TestFramework files: 0 / 38

The earlier `TestSource/: present and empty before this record` line and the void/no-argument counts above remain historical planning/review evidence. They no longer describe the current materialized sources and are intentionally not regenerated.

## Current implementation recheck

- Planned paths / symbols present: 614 / 614
- Bind `Observe_*`: 2,420
- Non-void `Observe_*`: 2,420
- `Observe_*` with runner inputs: 284
- Void/no-argument `Observe_*`: 0
- Discarded observation locals: 0
- Tautologies / permissive fixture passes: 0 / 0
- SpawnActor / DestroyActor calls: 16 / 26
- Bind files with no current automated structural issue: 571
- Unsafe-for-default-execution Bind files: 5, containing 19 high-impact calls
- TestFramework files pending external oracle: 38
- Source-semantically accepted Bind / externally accepted framework files: 0 / 0

Reproduce the current counts with `scripts/AuditTestSourceImplementation.ps1 -Check`. `StructurallyComplete` means the automated shape checks no longer report the original issue; it is not compilation, execution, external-oracle verification, or per-file manual semantic acceptance.

## Reference scope

The original Bind inventory selected 820 representative references for 127 manual Bind units and framework tasks. The full-theme extension now assigns every one of the 4,645 real core/GameplayTags/GAS test methods a disposition and records every candidate raw-string block. A disposition is not a promise to create source: Native SDK, host-only, generated-later, blocked, teaching, duplicate, and no-reusable-AS rows remain visible without manufacturing `.as` tasks.

Three logical units have no representative current `TEST_METHOD` selected by exact logical-name or owned-type search:

- `MB-003 AssetBundleData`
- `MB-004 AssetManagerScriptMixins`
- `MB-016 Deprecations`

Their Bind source is recorded as the authoritative reference and the missing representative test remains visible as `NoCurrentTest`.

## Count clarification

The root AGENTS overview still mentions 121 `Bind_*.cpp` files as an older high-level figure. The current source contains 204 physical shards and 127 normalized logical units. This OpenSpec uses the live source scan and keeps physical and logical counts separate.

## Evidence precedence

1. Current manual registration/source and its AS usage documentation.
2. Current relevant C++ test body.
3. `openspec/changes/test-coverage/**`.
4. `Documents/Guides/TestCatalog.md`.
5. `Documents/Guides/BindGapAuditMatrix.md` as historical evidence.
6. Old script-corpus change as non-authoritative research.

## Exclusions

- `Tools/AngelscriptCodeGen/**`
- generated/UHT binding shards
- GameplayTags and GAS implementation changes (their test evidence is planned under `Optional`)
- StaticJIT/AOT and Standalone
- `Script/**` migration
- build, runner, suite, release, and C++ inline-export integration
- old worktree cleanup or old OpenSpec archive
