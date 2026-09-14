---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": ["1.1"]
---

# Replace Test Code Resources with Generated C++

## Goal

Replace the Windows RCDATA test-code carrier with a deterministic, manually synchronized, per-source generated C++ carrier while retaining the existing database and handwritten registration path.

## Architecture

A thin Python CLI delegates to a modular package whose shared synchronization plan drives read-only checking and bounded generation. Each checked-in projection statically registers one deferred parser factory with the existing C++ code database; see [design.md](design.md).

## Global constraints

- `.as` is the only authored semantic truth; Python does not parse container metadata, annotations, versions, diagnostics, or reload behavior.
- Ordinary UBT compiles checked-in projections and never invokes Python or scans `AngelscriptTestCode/`.
- New Automation identities remain under `Angelscript.UnitTest.Framework`; `WITH_ANGELSCRIPT_TESTS` remains the only replacement-test gate.
- The older planning-only unified-framework Change and all unrelated dirty paths remain untouched.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## Requirement coverage

| Requirement or acceptance condition | Tasks |
|---|---|
| Checked-in generated original file delivery | 1.1, 2.1 |
| Modular CLI and one shared sync plan | 1.1 |
| Deterministic one-source mapping and raw bytes | 1.1 |
| Read-only check, no-op stability, safe generation and stale cleanup | 1.1 |
| Existing registration/parser activation and authored origins | 2.1 |
| Handwritten provider compatibility | 2.1 |
| Complete removal of RCDATA and UBT generation | 2.1 |
| Python, build, Automation, drift, and guidance proof | 1.1, 2.1 |

Self-review 2026-09-14: coverage complete; placeholders none; symbols consistent with `design.md` and the exported glossary. Record: `attachments/data/planning-validation.md`.

## [x] 1.1 Deliver the modular deterministic projection tool

Add the explicit Python authoring tool and its standard-library tests. It owns path discovery, deterministic raw-byte rendering, a shared synchronization plan, read-only drift reporting, and bounded atomic application; it does not interpret AngelScript or run from UBT.

**Outcome**

From any current working directory, `codegen.py check` reports exact missing/changed/stale state without mutation and `codegen.py generate` synchronizes one mirrored signed C++ file per authored `.as`. Equal outputs keep their modification time, unsafe extras are retained and reported, and every input failure occurs before output mutation. Excluded are C++ compilation, `.as` semantic parsing, Git hooks, and build-system invocation.

**Interfaces**

Consumes (existing authored fixture and approved filesystem contract):

```text
AngelscriptTestCode/Language/Counter.as
author root: AngelscriptTestCode/
tool exclusion: AngelscriptTestCode/CodeGenTool/**
generated root: Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/
```

Produces (settled in `attachments/drafts/glossary.md`):

```text
python AngelscriptTestCode/CodeGenTool/codegen.py generate
python AngelscriptTestCode/CodeGenTool/codegen.py check
angelscript_test_codegen.sync.build_sync_plan(author_root, generated_root) -> SyncPlan
Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Counter.generated.cpp
```

`SyncPlan` is an internal immutable value exposed only as the result shape of the settled `build_sync_plan()` seam; it is not a new runtime or cross-module API.

**Cases**

1. **Mirrored paths and reserved subtree** — new RED · example-table
   Template: Given author-relative `<input>` When discovery and mapping run Then `<result>` is observed.

   | input | result |
   |---|---|
   | `Language/Counter.as` | FileTag `Language/Counter`; output `Language/Counter.generated.cpp` |
   | `Reload/Actor.as` | FileTag `Reload/Actor`; output `Reload/Actor.generated.cpp` |
   | `CodeGenTool/tests/fixtures/Hidden.as` | excluded |
   | `Language/Notes.txt` | excluded |
2. **Normalized collision rejects the whole plan** — new RED
   Given `Folder/Case.as` and `folder/case.as` When `build_sync_plan()` runs Then it fails with both colliding relative paths and no output file or directory is created.
3. **Raw-byte deterministic renderer** — new RED
   Given source bytes `00 0A FF 22` at `Binary/Exact.as` When rendered in two processes and caller directories Then both UTF-8/LF outputs are byte-identical, include length `4`, the SHA-256 of those four bytes, FileTag `Binary/Exact`, and a `uint8` initializer containing exactly `0x00, 0x0a, 0xff, 0x22`; no absolute path or timestamp occurs.
4. **Unity-safe per-source symbols** — new RED
   Given `A/Same.as` and `B/Same.as` with equal payload bytes When rendered Then their internal source, factory, and registration identifiers have different stable digest suffixes while both use `FAngelscriptTestCodeRegistration` and defer to `FAngelscriptTestSourceParser::Parse`.
5. **Shared drift plan** — new RED · sequence
   1. Expected `A.as` is absent and signed `Old.generated.cpp` is extra → plan reports one missing and one stale output; `check` returns non-zero without changing either root.
   2. After `generate` → `A.generated.cpp` exists and the signed stale file is removed.
   3. After authored bytes change → plan reports only `A.generated.cpp` as changed.
   4. After a second `generate` with no input changes → output bytes and modification time remain unchanged and `check` returns zero.
6. **Unsafe extra survives generation** — new RED
   Given unsigned `Manual.generated.cpp` and unrelated `Keep.txt` beneath the generated root When `generate` runs Then neither is deleted, the tool returns failure naming the unsafe extra, and desired signed outputs are still synchronized.
7. **All inputs validate before mutation** — new RED
   Given one valid source plus one path collision and an existing signed projection When `generate` runs Then it returns failure and the pre-existing projection bytes and modification time are unchanged.
8. **Thin CLI reports stable exit meaning** — new RED
   Given injected temporary roots When `check` sees drift Then exit code is `1` with relative path categories; when inputs are synchronized exit code is `0`; invalid input returns `2`. Importing `codegen.py` or the package performs no generation.

**Files**

```diff
+AngelscriptTestCode/CodeGenTool/codegen.py
+AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/__init__.py
+AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/cli.py
+AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/model.py
+AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/paths.py
+AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/discovery.py
+AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/cpp_renderer.py
+AngelscriptTestCode/CodeGenTool/angelscript_test_codegen/sync.py
+AngelscriptTestCode/CodeGenTool/tests/test_cli.py
+AngelscriptTestCode/CodeGenTool/tests/test_paths.py
+AngelscriptTestCode/CodeGenTool/tests/test_discovery.py
+AngelscriptTestCode/CodeGenTool/tests/test_cpp_renderer.py
+AngelscriptTestCode/CodeGenTool/tests/test_sync.py
+Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/Language/Counter.generated.cpp
```

Test-created `.as` fixtures live only in temporary directories or `CodeGenTool/tests/fixtures/`, which discovery excludes from the real author root.

**Verification**

Run from the repository root in PowerShell 7.

```powershell
python -m unittest discover AngelscriptTestCode/CodeGenTool/tests -p "test_*.py"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
python AngelscriptTestCode/CodeGenTool/codegen.py check
exit $LASTEXITCODE
```

Every named case executes and passes; the real `Counter` projection is synchronized and the final `check` is read-only and clean.

**Evidence**

- RED, 2026-09-14: `python -m unittest discover AngelscriptTestCode/CodeGenTool/tests -p "test_*.py"` executed 12 tests against importable interface skeletons; 11 behavior assertions failed across CLI, discovery, mapping, rendering, collisions, synchronization, no-op, and unsafe-extra cases, while the root-derivation control passed.
- GREEN, 2026-09-14: the exact Verification command executed 12/12 tests successfully and the real-repository read-only `check` returned `0` with `Test-code generated projections are synchronized.`
- Additional syntax proof: `python -m compileall -q AngelscriptTestCode/CodeGenTool` returned `0`.
- Generated result: `Language/Counter.as` produced one signed `Language/Counter.generated.cpp` containing 420 raw bytes and SHA-256 `28d6fc3cba07a13cf12c6ced5146377bf7d85bcbef71ff1a55d9fb0762f465d9`.

## [x] 2.1 Replace resource delivery with compiled registration

Migrate the `AngelscriptTest` module from RCDATA to the checked-in generated translation unit, remove the resource-only implementation and probes, retain one central activation call, and update the focused guide. Public database and handwritten-provider contracts stay unchanged.

**Outcome**

The editor target compiles the generated `Counter` translation unit into `AngelscriptTest`, activation queries both generated `Language/Counter` and handwritten `Fixture/Secondary`, and authored source bytes and origin identity remain intact. Build.cs no longer discovers fixtures or creates RC/index inputs, no embedded-source symbol remains, and ordinary UBT succeeds without running the generator. Excluded are changes to parser grammar, database admission/query behavior, diagnostics, reload, LSP/DAP, and the handwritten JIT provider.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs
 Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTestModule.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/AngelscriptTestCode.h
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/AngelscriptTestCodeRegistration.h
-Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/AngelscriptTestEmbeddedSources.h
-Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Catalog/AngelscriptTestEmbeddedSources.cpp
-Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Framework/Resources/AngelscriptTestCode.rc
-Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/ResourcesTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/ResourceProbeTests.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/GeneratedSourcesTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/FrameworkTests/AdoptionTests.cpp
-Plugins/Angelscript/Tests/Tools/TestCode/TestCodeResourceIncremental.ps1
 .agents/skills/angelscript-test/references/test-code-database.md
```

The existing generated file from Task 1.1 is consumed but not rewritten in this task; the existing `AngelscriptTestJIT/NewVersion/TestCodeProviderRegistration.cpp` is an unchanged compatibility control.

**Verification**

Run from the repository root in PowerShell 7 with the selected workspace activated.

```powershell
python AngelscriptTestCode/CodeGenTool/codegen.py check
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$legacy = rg -n "ConfigureTestCodeResources|AS_TEST_INDEX|AngelscriptTestEmbeddedSources|TestCodeResourceIncremental" Plugins/Angelscript/Source/AngelscriptTest Plugins/Angelscript/Tests/Tools/TestCode
if ($LASTEXITCODE -eq 0) { $legacy; throw "Legacy test-code resource carrier remains." }
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
Invoke-Harness -Command workspace.activate -Context $context | Out-Null
$build = Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }
if ($build.status -ne 'Succeeded') { throw "Editor build failed." }
$tests = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Framework'; Fast = $true; TimeoutMs = 600000 }
if ($tests.status -ne 'Succeeded') { throw "Framework Automation failed." }
```

The drift and absence checks pass, the editor build succeeds on the current generated source set, and the Framework report identifies every selected Automation test as passed, including generated `Counter` lookup/origin assertions and cross-module handwritten adoption.

**Evidence**

- Setup repair, 2026-09-14: Harness build `5a71149cce834f748d1aedaf09a28a4e` exposed two test-fixture compile errors before behavioral execution: borrowed accessors were called on temporary Source values and `CounterRoot` collided under Unity. The test now retains Source values and uses a unique fixture symbol; Harness build `4199ff9d43cd44fe8c44c873f15bec9b` then compiled successfully. This setup failure is not counted as RED.
- RED, 2026-09-14: with generated registration compiled while the old RCDATA provider still registered, Harness Automation run `af5eaa613b334f748d1aedaf09a28a4e` executed exactly `Angelscript.UnitTest.Framework.GeneratedSources.GeneratedFixture` and failed 0/1. The report recorded two `FileTagConflict` errors for `Language/Counter`, sourced from `AngelscriptTestCode/Language/Counter.as:1` and `AS_TEST_INDEX:0`, proving the dual-carrier conflict.
- GREEN build, 2026-09-14: after removing the Build.cs/RC/Win32 loader/private-batch path, Harness build `9c740ce844d94726b8d829ca21249fa3` succeeded; the final exact Verification rerun build `ecf6c0345661413e9c4bca5090ede1bd` also succeeded.
- GREEN Automation, 2026-09-14: Harness run `3a1e42d51bfc48df919442ff6323a9e5` selected `Angelscript.UnitTest.Framework` and completed 27/27 passed, 0 failed, 0 skipped, 0 warnings, and 0 errors. This includes generated `Counter` byte/origin lookup and existing cross-module handwritten JIT adoption.
- Removal and drift proof: the exact Verification command reported a clean generated projection and `rg` found no `ConfigureTestCodeResources`, `AS_TEST_INDEX`, `AngelscriptTestEmbeddedSources`, or `TestCodeResourceIncremental` under the owned product/tool roots.
- Removed material was resource-specific and is recoverable from version control or this working Change: the RC wrapper, embedded loader/header, two resource-only Automation files, and the obsolete incremental resource script. Database, parser, static registration, activation, and JIT provider files remain.
