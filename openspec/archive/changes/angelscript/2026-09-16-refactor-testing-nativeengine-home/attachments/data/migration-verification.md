# Phase-1 migration verification

Frozen before 3.x coverage additions. Parser is expected empty.

## Runs

| Tenant | RunId | Proof | Count |
|---|---|---|---|
| NativeEngine | `356ad9871c6240188455d2432fc93c48` | `ue.test` Succeeded | 1206 Success |
| Framework | `5da033651c144f0e8af679066643c196` | `ue.test` Succeeded | 45 Success |
| Baseline | `1f26ddfac40e49bd8a079368fc72b2e0` | `ue.test` Succeeded | 3 Success |
| Bindings isolation | `3a0290908a634c17b7c45663fbdd5ff1` | `ue.test` Succeeded | 2 Success |
| RuntimeBindings | `69679c5984aa4296bf971ac1d3bcf749` | Found-list + crash | 312 discovered; 16 Success, 4 Fail, 292 NotRun |

Pre-move baseline: log `47d5bd5dd8024815bad75d26eb932ff9`, `attachments/data/pre-move-identities.json` (1526 discovered). Editor rebuild after relocation: `4afaa3eed2ca4c5da4fa7ff2bc0864eb` (`-NoUBTMakefiles`). BuilderStages observation fix rebuild: `45b694e52d054f57ac033d889e6ca8a7`.

## Conservation

`Test-Phase1MigrationConservation.ps1` passed. `NewVersion/` is absent. Mapped destinations match. NativeEngine `Parser` is empty. `Naming assumed: BuilderStages` — CQTest class rename to avoid Framework `Builder` collision.

## Pre-existing Bindings defect

`Angelscript.UnitTest.RuntimeBindings.Containers.Array.Array.AppendRemoveAndIterationYieldTwoThenFive` still AVs in `asCModuleDefinitionSet::Create` (`AngelscriptTypeBindInfoDraft.cpp:403`). Same stack as the pre-move run. Not a relocation identity loss. Production bind materialization is out of this Change.

## Phase-1 NativeEngine identity freeze

1206 identities under `Angelscript.UnitTest.NativeEngine.<Layer>.<Class>.<Method>`. No flat `NativeEngine.<Class>` leftovers in the after report. Additional Parser and matrix methods after this freeze are 3.x additions, not conservation losses.
