## 1. Coverage

- [x] 1.1 Inspect existing delegate hot reload parameter and runtime coverage
- [x] 1.2 Add object/class/soft-reference delegate parameter reload test
- [x] 1.3 Run targeted `ReloadDelegates.Parameters` automation test

## 2. Record

- [x] 2.1 Record proposal and design notes
- [x] 2.2 Update task verification result after test run

## Verification

- 2026-06-25: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.ReloadDelegates.Parameters" -Label hotreload-delegate-parameters -TimeoutMs 600000` -> `total=5 passed=5 failed=0 skipped=0`.
- 2026-06-25: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.ReloadDelegates" -Label hotreload-reload-delegates -TimeoutMs 600000` -> `total=8 passed=8 failed=0 skipped=0`.
- 2026-06-25: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.Delegate.Runtime" -Label hotreload-delegate-runtime -TimeoutMs 600000` -> `total=3 passed=3 failed=0 skipped=0`.
