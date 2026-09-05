# Source diagnostics verification

## TDD sequence

- Task `1.1` RED `d0c43c28bcf94934980039daa4cb6ec3`: `frontend/as_source_location.h` was absent.
- UBT planning failure `8d50869f797a421ebf421d793298f080`: duplicate `as_source_manager.cpp` basenames were rejected and drove the indexed Replan.
- Task `1.1` GREEN build `8d3971ef5122438d8409aca77938eda1`: 7/7 actions, exit 0.
- Task `1.1` GREEN test `079f0c1fe393414e83067c9bf8b8e1d5`: 4/4 exact SourceDiagnostics scenarios passed.
- Task `1.2` RED `da205e15ecdf48cabbc10dd23d7ff3cc`: `frontend/as_source_provenance.h` was absent.
- Task `1.2` GREEN build `3e05841f43664a28858d3794cab893e1`: 7/7 actions, exit 0.
- Task `1.2` GREEN test `7f5b72c4340c4b32af4871f087e78085`: 8/8 exact SourceDiagnostics scenarios passed.
- Task `2.1` RED `01a6bcdd41d54a18a9d0a1f2c46522b7`: `frontend/as_diagnostics.h` was absent.
- Final GREEN build `a13d244bdb6f48e09e4fecd19eaf7e9f`: 7/7 actions, `Data.State: Succeeded`, exit 0.
- Final GREEN test `1c6cad52becb4c528a8f1970ac3d5033`: 11/11 passed, 0 failed, 0 skipped, 0 warnings, and 0 errors.

The final Automation report is `Saved/Harness/Unreal/Runs/1c6cad52becb4c528a8f1970ac3d5033/AutomationReport/index.json`; its complete public scope is `Angelscript.UnitTest.NativeEngine.SourceDiagnostics.*`.

## Final content identity

| File | SHA-256 |
|---|---|
| `frontend/as_source_location.h` | `b6b34dd2a51a6779f6c32a0190ce1d3593d5d03ec5edbf2bbe1cc2cb8a4f2263` |
| `frontend/as_source_snapshot.h` | `000fdf32c06ecc488edba2a14653b5476a362e529caea4e56f24567bf9e54309` |
| `frontend/as_source_snapshot.cpp` | `9fdd7234828fbf488b4a4269f15c87f504d87f8a7d7bfeb57d03c35022143cf7` |
| `frontend/as_source_manager.h` | `8c5faa2edc52a21c907f3cbfd0648316feff7e5c234a0f1872014a44288f47f8` |
| `frontend/as_frontend_source_manager.cpp` | `7afdc66ecac28e1ab87f4a489502310f6992f1a9858cde87dac98ad7ed58e92a` |
| `frontend/as_source_provenance.h` | `cea224e244447d22d9d7b4187f7c11710651e535f652f6d726a6c6ad8171b9dd` |
| `frontend/as_source_provenance.cpp` | `9395834390dfd37d500e6c2a56ebe0d927b7c15a57921802ff15463becb10020` |
| `frontend/as_diagnostics.h` | `f8d4a97bee9b9d415e7035fee8cf34828345121a6a4758b155ede3c5e38bf7b4` |
| `frontend/as_diagnostics.cpp` | `87f0b8f91cacfa5cdceadb61f82f7de5dc0d4dd849de1e596e9a18e17173923a` |
| `SourceDiagnosticsTests.cpp` | `b992a6133245c2c8a4449b9d005c9d1194f45583dc2a2640b1c6dc99a2327dab` |

## Impact boundary

The new API is compiled and tested but has no production Parser, Builder, Engine, Standalone, VM, or reflection consumer. Aggregate Harness profiles, full UE suites, Standalone, and upper Runtime tests were intentionally omitted because the exact editor build and complete SourceDiagnostics prefix directly prove the isolated source/diagnostic boundary.
