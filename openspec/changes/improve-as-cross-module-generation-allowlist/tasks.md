# Tasks - improve-as-cross-module-generation-allowlist

> `tasks.md` is the implementation plan. Update checkboxes only after the matching verification passes.

## 1. Policy and diagnostics tests

- [x] 1.1 <!-- TDD --> Add UHTTool resolver tests under `Plugins/Angelscript/Source/AngelscriptTest/UHTTool/` that require an AngelscriptUHTTool-owned cross-module generation allowlist file, verify pilot modules are absent from `AngelscriptRuntime.Build.cs`, and verify generated CSV rows for allowlisted modules are `CrossModule` / `FrameWrapper` only. Verification: `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver.CrossModuleGenerationAllowlist" -Label crossmodule-allowlist-red -TimeoutMs 900000`.

## 2. Generator policy split

- [x] 2.1 <!-- TDD --> Replace the single Build.cs-derived supported-module set in `AngelscriptFunctionTableCodeGenerator.cs` with separate runtime-linked and cross-module-only module sets loaded from Build.cs plus a new AngelscriptUHTTool allowlist file. Verification: rerun the test from 1.1.
- [x] 2.2 <!-- TDD --> Change generation so runtime-linked modules keep normal Direct/Stub shards, while cross-module-only modules emit only target-module wrapper shards and CSV summary rows for realized cross-module entries. Verification: rerun the test from 1.1.
- [x] 2.3 <!-- TDD --> Update `AngelscriptFunctionTableExporter.cs` skipped diagnostics so allowlisted modules are no longer classified as `disabled-safe-cross-module` when their safe entries are realized. Verification: rerun the test from 1.1.

## 3. Verification

- [x] 3.1 <!-- Non-TDD --> Run `Tools\RunBuild.ps1 -Label crossmodule-allowlist-build -TimeoutMs 900000 -SerializeByEngine -NoXGE` and record the resulting generated totals.
- [x] 3.2 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver" -Label crossmodule-allowlist-uhttool -TimeoutMs 900000`.
- [x] 3.3 <!-- Non-TDD --> Run `openspec validate "improve-as-cross-module-generation-allowlist" --strict --json`.
