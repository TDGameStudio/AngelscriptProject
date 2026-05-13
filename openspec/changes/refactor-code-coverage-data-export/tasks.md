## 1. Coverage Data Package

- [ ] 1.1 <!-- TDD --> Update `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptCodeCoverageTests.cpp` so coverage report tests assert parseable structured JSON fields instead of runtime-generated `index.html` and `*.as.html`; verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Core.CodeCoverage" -Label code-coverage-data-export-red -TimeoutMs 600000`.
- [ ] 1.2 <!-- TDD --> Refactor `Plugins/Angelscript/Source/AngelscriptRuntime/CodeCoverage/` so `StopRecordingAndWriteReport()` or its compatibility wrapper writes the complete `coverage_summary.json` package with schema metadata, summary, files, line hit data, tree aggregation, settings, capture capabilities, and extensions; verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Core.CodeCoverage" -Label code-coverage-data-export-json -TimeoutMs 600000`.
- [ ] 1.3 <!-- TDD --> Ensure generated-code pruning, zero-executable-line semantics, deterministic file ordering, deterministic line ordering, and exclude-pattern reporting are covered by JSON assertions; verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Core.CodeCoverage" -Label code-coverage-data-export-stability -TimeoutMs 600000`.

## 2. Runtime HTML Removal

- [ ] 2.1 <!-- TDD --> Remove or deprecate runtime C++ HTML output paths in `CoverageReportGenerator.cpp/.h`, including hardcoded HTML templates, CSS, JavaScript, directory `index.html`, and per-file `*.as.html`; expected behavior is that coverage correctness is represented by JSON, not runtime HTML; verify with the Core CodeCoverage test prefix.
- [ ] 2.2 <!-- Non-TDD --> Search for stale runtime HTML assumptions in runtime code, tests, and docs; expected result is no active requirement that `FAngelscriptCodeCoverage` writes runtime HTML pages; verify with `rg -n "index\\.html|\\.as\\.html|Write.*Html|runtime-generated HTML|class=\\\"covered\\\"|class=\\\"not-covered\\\"" Plugins/Angelscript/Source Documents openspec/changes/refactor-code-coverage-data-export`.

## 3. External Static Visualization

- [ ] 3.1 <!-- Non-TDD --> Decide and document the external generator implementation location and language after checking existing `Tools/` conventions; expected change is a short decision note in this change or implementation docs before tool code is added; verify by inspecting the updated design/task notes.
- [ ] 3.2 <!-- TDD --> Add an external static HTML generator that consumes `coverage_summary.json` and recreates the current visual workflow: total summary, directory navigation, file pages, source display, covered/not-covered highlighting, and hit count details; verify with tool-level fixture tests selected for the implementation language.
- [ ] 3.3 <!-- TDD --> Add an integration fixture path from a real or generated coverage JSON package to the external generator; expected output is a static site that can be opened from disk without Unreal runtime HTML generation; verify with the tool tests and a focused Core CodeCoverage fixture run.

## 4. Diagnostics And Performance Exploration

- [ ] 4.1 <!-- Non-TDD --> Inventory currently available runtime observation data for future exports, including line callback function/module/line data, AS VM `Execute()`, `CallScriptFunction()`, StaticJIT paths, `UASFunction::RuntimeCall*`, and existing UE stats scopes; verify with `rg -n "AngelscriptLineCallback|CallScriptFunction|RuntimeCallFunction|RuntimeCallEvent|STAT_AngelscriptRuntimeCall|AS_PERF_SCOPE" Plugins/Angelscript/Source/AngelscriptRuntime`.
- [ ] 4.2 <!-- Non-TDD --> Document which performance fields are not collected in this change and what would be required for function timing, call counts, inclusive time, and exclusive time; verify that `capture_capabilities` JSON tests assert function timing is marked as not collected.
- [ ] 4.3 <!-- TDD --> Add JSON metadata coverage for `capture_capabilities` and `extensions` so future diagnostics sections can be added without changing the coverage exporter into an HTML renderer; verify with the Core CodeCoverage test prefix.

## 5. Documentation And Final Verification

- [ ] 5.1 <!-- Non-TDD --> Update current coverage documentation and test catalog entries that describe HTML as the primary artifact; expected workflow points users to JSON data export plus the external HTML generator; verify with `rg -n "CodeCoverage|coverage_summary|index\\.html|\\.as\\.html|HTML" Documents/Guides Plugins/Angelscript/AGENTS.md`.
- [ ] 5.2 <!-- Non-TDD --> Run a standard build after runtime/tool changes; verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label code-coverage-data-export-build -TimeoutMs 180000`.
- [ ] 5.3 <!-- Non-TDD --> Run focused coverage tests and any external generator tests selected during implementation; verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Core.CodeCoverage" -Label code-coverage-data-export-final -TimeoutMs 600000`.
- [ ] 5.4 <!-- Non-TDD --> Validate the OpenSpec change before apply completion or archive; verify with `openspec validate "refactor-code-coverage-data-export" --strict --json`.
