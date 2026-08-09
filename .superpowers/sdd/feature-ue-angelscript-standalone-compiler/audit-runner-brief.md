# Runner integration audit brief

Read-only task. Do not edit files, commit, run long UE tests, or change OpenSpec checkboxes.

Inspect `Tools/RunTestSuite.ps1`, `Tools/Shared/TestSuiteDefinitions.ps1`, related self-tests, and current report/shard/parallel abstractions.

Report:

1. the exact data model currently used for suite entries;
2. every location that assumes an Unreal Automation prefix;
3. the minimum safe change that adds a CMake/CTest `Standalone` entry without putting it in `All`;
4. the appropriate test-first location and exact red tests for entry-kind dispatch, timeout, exit propagation, and isolated reports;
5. exact standard verification commands allowed by repository guidance;
6. any conflict with OpenSpec tasks 0.8, 1.2, 6.16.

Write the detailed report to `.superpowers/sdd/feature-ue-angelscript-standalone-compiler/audit-runner-report.md`. Return only status plus a one-line summary and concerns.
