## 1. Diagnostics Tests

- [x] 1.1 <!-- TDD --> Update UHTTool skipped-statistics tests to require `disabled-safe-cross-module` and prefixed disabled protocol reasons in generated CSV diagnostics.
- [x] 1.2 <!-- TDD --> Verify the diagnostic-only change does not increase `CrossModule` entry count or emit wrapper thunks for disabled modules.

## 2. Exporter Classification

- [x] 2.1 <!-- TDD --> Change `AngelscriptFunctionTableExporter` so disabled modules reuse cross-module classification before reporting skipped reasons.
- [x] 2.2 <!-- TDD --> Keep `target-module-disabled` only as a fallback for unclassifiable disabled candidates.

## 3. Verification

- [x] 3.1 <!-- Non-TDD --> Run `Tools\RunBuild.ps1 -Label disabled-cross-module-diagnostics-build -TimeoutMs 900000 -SerializeByEngine -NoXGE`.
- [x] 3.2 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.CrossModuleDirectBind.SkippedStatisticsClassifyCrossModuleOutcomes" -Label disabled-cross-module-diagnostics -TimeoutMs 900000`.
- [x] 3.3 <!-- Non-TDD --> Run `openspec validate "improve-as-disabled-cross-module-diagnostics" --strict --json`.
