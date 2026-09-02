# Debugger TestSource planning matrix

This matrix is generated from `inventory/current-test-methods.csv`, `current-script-references.csv`, and `planned-theme-sources.csv`. It records planning only; no target `.as` file is materialized by this change.

| Leaf theme | Methods | References | Planned handwritten `.as` | Host-only | Generated later | Blocked |
|---|---:|---:|---:|---:|---:|---:|
| `Debugger` | 38 | 9 | 3 | 0 | 0 | 0 |

## Planned source tasks

| Task | Target | Reference | Scope |
|---|---|---|---|
| `TS-DBG-0001` | `TestSource/Debugger/GetterPropertyTracking/Test_Block_01.as` | `REF-AS-02126` | Extract the exact block for GetterPropertyTracking (UCLASS()); preserve all declarations and the scenario represented by raw block 1 of 1. |
| `TS-DBG-0002` | `TestSource/Debugger/FunctionEvaluationGuards/Test_Block_01.as` | `REF-AS-02127` | Extract the exact block for FunctionEvaluationGuards (UCLASS()); preserve all declarations and the scenario represented by raw block 1 of 1. |
| `TS-DBG-0003` | `TestSource/Debugger/InheritedGetterTracksBasePropertyAddress/Test_Block_01.as` | `REF-AS-02128` | Extract the exact block for InheritedGetterTracksBasePropertyAddress (UCLASS()); preserve all declarations and the scenario represented by raw block 1 of 1. |
