---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": []
    "3.1": ["2.1"]
    "4.1": []
---

# Retarget Standalone host to AngelscriptLSP

## Goal

Point CMake, live guides, and tools at `AngelscriptLSP/` while keeping dormant Standalone product identity and the later JSON-RPC boundary.

## Architecture

`Plugins/Angelscript/AngelscriptLSP/` is the filesystem location of the dormant no-Unreal host. CMake `project(AngelscriptStandalone)`, CLI `as-standalone`, and contract `ue-as-standalone-v1` stay. The compile root is `Source/AngelscriptRuntime/angelscript` (prerequisite Change `angelscript/refactor-runtime-owned-sdk-layout`). JSON-RPC and `Extensions/AngelscriptVSCode/` stay out of this record. See `design.md`.

## Global constraints

- Coordinator prerequisite: `angelscript/refactor-runtime-owned-sdk-layout` for the SDK path string. The folder already exists; this is not a same-graph edge.
- Do not rename `as-standalone`, the CMake project, `AngelscriptStandalone.*` tests, or `ue-as-standalone-v1`.
- Do not implement JSON-RPC or add an AngelscriptLSP UE module.
- Do not search `Standalone/` and `AngelscriptLSP/` as dual live roots.
- Do not edit other Changes' `tasks.md`.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 Plugins/Angelscript/AngelscriptLSP/CMakeLists.txt  # · 1.1
 Plugins/Angelscript/AngelscriptLSP/README.md  # · 2.1
 Plugins/Angelscript/AngelscriptLSP/SUPPORT_MATRIX.md  # · 2.1
 Plugins/Angelscript/README.md  # · 3.1
 Documents/Guides/Build.md  # · 3.1
 Documents/Guides/AngelscriptStandaloneOfflineBundle.md  # · 3.1
 Tools/RunStandaloneExternalSmoke.ps1  # · 3.1
 Tools/Shared/TestSuiteDefinitions.ps1  # · 3.1
+openspec/changes/angelscript/refactor-standalone-lsp-layout/attachments/data/consumer-replan.md  # · 4.1
```

## Requirement coverage

| Requirement | Tasks |
|---|---|
| CMake fork root is `Source/AngelscriptRuntime/angelscript` | 1.1 |
| Directory is `AngelscriptLSP/`; product remains dormant Standalone | 2.1 |
| Plugin README, live Guides, smoke tool, and suite working directories use `AngelscriptLSP/` | 3.1 |
| `CheckRemovedAddons.py` invocation uses the new path as a source audit | 2.1, 3.1 |
| Sibling Changes that still Files `Standalone/` are listed, not rewritten | 4.1 |
| Acceptance: no live `Plugins/Angelscript/Standalone` in owned README/Guides/Tools | 2.1, 3.1 |
| Acceptance: no dual-path search | 3.1 |
| Acceptance: consumer-replan attachment | 4.1 |

Self-review 2026-09-11: coverage complete; no placeholder phrases; symbols match `design.md` (directory `AngelscriptLSP/`, product Standalone, no JSON-RPC). Record: `attachments/data/planning-validation.md`.

## [x] 1.1 Point CMake fork root at the first-party SDK

`AngelscriptLSP/CMakeLists.txt` still sets `ANGELSCRIPT_FORK_ROOT` to `${ANGELSCRIPT_RUNTIME_ROOT}/ThirdParty/angelscript/source`. SDK sources already live at `${ANGELSCRIPT_RUNTIME_ROOT}/angelscript`. After this task the fork root string matches that folder. `project(AngelscriptStandalone)` and the listed `as_*.cpp` names stay. This task does not run a full CMake/CTest package.

**Outcome**

`ANGELSCRIPT_FORK_ROOT` equals `${ANGELSCRIPT_RUNTIME_ROOT}/angelscript`. CMake still compiles the same host sources against that tree. Excluded: renaming the CMake project, certifying `as-standalone`, editing `AngelscriptRuntime.Build.cs`.

**Files**

```diff
 Plugins/Angelscript/AngelscriptLSP/CMakeLists.txt
```

**Verification**

```powershell
$cmake = Get-Content -LiteralPath 'Plugins/Angelscript/AngelscriptLSP/CMakeLists.txt' -Raw
if ($cmake -notmatch '(?m)^set\(ANGELSCRIPT_FORK_ROOT "\$\{ANGELSCRIPT_RUNTIME_ROOT\}/angelscript"\)') { throw 'ANGELSCRIPT_FORK_ROOT is not Source/AngelscriptRuntime/angelscript' }
if ($cmake -match 'ThirdParty/angelscript') { throw 'CMake still names ThirdParty/angelscript' }
if ($cmake -notmatch 'project\(AngelscriptStandalone') { throw 'CMake project name must remain AngelscriptStandalone' }
```

Working directory: repository root. Completion: the three assertions pass. Intentionally omit CMake configure/build/CTest and UE Automation: the host remains dormant.

**Evidence**

2026-09-11: `ANGELSCRIPT_FORK_ROOT` is `${ANGELSCRIPT_RUNTIME_ROOT}/angelscript`. CMakeLists has no `ThirdParty/angelscript`. `project(AngelscriptStandalone)` remains.

## [x] 2.1 State directory identity without renaming the Standalone product

`AngelscriptLSP/README.md` still titles the tree as Standalone-only and still runs `python Plugins/Angelscript/Standalone/Tests/CheckRemovedAddons.py`. `SUPPORT_MATRIX.md` does not say the directory was renamed. After this task both files contain one explicit sentence: the directory is `AngelscriptLSP` and the product remains dormant Standalone (`as-standalone`, CMake `AngelscriptStandalone`, `ue-as-standalone-v1`). Invocation paths use `Plugins/Angelscript/AngelscriptLSP/`. JSON-RPC is not introduced.

**Outcome**

README and SUPPORT_MATRIX state the directory-versus-product rule. `CheckRemovedAddons.py` is documented at `Plugins/Angelscript/AngelscriptLSP/Tests/CheckRemovedAddons.py` as a source audit, not a binary certification. Product names `as-standalone`, `AngelscriptStandalone`, and `ue-as-standalone-v1` remain. Excluded: implementing a language-server protocol; rewriting the audit script's policy.

**Files**

```diff
 Plugins/Angelscript/AngelscriptLSP/README.md
 Plugins/Angelscript/AngelscriptLSP/SUPPORT_MATRIX.md
```

**Verification**

```powershell
$readme = Get-Content -LiteralPath 'Plugins/Angelscript/AngelscriptLSP/README.md' -Raw
$matrix = Get-Content -LiteralPath 'Plugins/Angelscript/AngelscriptLSP/SUPPORT_MATRIX.md' -Raw
foreach ($text in @($readme, $matrix)) {
  if ($text -notmatch 'AngelscriptLSP') { throw 'identity sentence missing AngelscriptLSP' }
  if ($text -notmatch 'Standalone') { throw 'product name Standalone missing' }
}
if ($readme -match 'Plugins/Angelscript/Standalone') { throw 'README still routes to Standalone/' }
if ($readme -notmatch 'Plugins/Angelscript/AngelscriptLSP/Tests/CheckRemovedAddons.py') { throw 'CheckRemovedAddons invocation path not retargeted' }
python Plugins/Angelscript/AngelscriptLSP/Tests/CheckRemovedAddons.py
if ($LASTEXITCODE -ne 0) { throw "CheckRemovedAddons.py failed with $LASTEXITCODE" }
```

Working directory: repository root. Completion: identity assertions pass and the Python audit exits 0. Intentionally omit `--self-test` as a substitute for the real audit; do not treat a passing audit as host-binary certification.

**Evidence**

2026-09-11: README and SUPPORT_MATRIX name `AngelscriptLSP` and Standalone. README invocation is `Plugins/Angelscript/AngelscriptLSP/Tests/CheckRemovedAddons.py`. `python Plugins/Angelscript/AngelscriptLSP/Tests/CheckRemovedAddons.py` exited 0: `Removed add-ons audit: PASS; 192 text files inspected; 0 violations`. Not a binary certification.

## [x] 3.1 Retarget plugin README, Guides, and Tools off Standalone/

Plugin `README.md` contents still list `Standalone/`. `Documents/Guides/Build.md` and `AngelscriptStandaloneOfflineBundle.md` still route to `Plugins/Angelscript/Standalone/`. `Tools/RunStandaloneExternalSmoke.ps1` still looks for `Plugins\Angelscript\Standalone\out\...`. `Tools/Shared/TestSuiteDefinitions.ps1` still uses WorkingDirectory `Plugins\Angelscript\Standalone` (three entries). After this task those live paths are `AngelscriptLSP`. Parent README does not currently list the host as a plugin child; do not add a layout row unless a current contents/layout block is already naming the host directory. Product name Standalone in prose may stay. Scripts must not fall back to the old folder.

**Outcome**

Owned live path instructions resolve under `Plugins/Angelscript/AngelscriptLSP/`. Suite WorkingDirectory values and the default smoke zip path use that directory. A missing `Standalone/` path fails rather than searching both names. Excluded: reviving `RunTestSuite.ps1` as the Harness `ue.*` route; certifying StandaloneRelease; adding an AngelscriptLSP `.uplugin` module.

**Files**

```diff
 Plugins/Angelscript/README.md
 Documents/Guides/Build.md
 Documents/Guides/AngelscriptStandaloneOfflineBundle.md
 Tools/RunStandaloneExternalSmoke.ps1
 Tools/Shared/TestSuiteDefinitions.ps1
```

**Verification**

```powershell
$files = @(
  'Plugins/Angelscript/README.md',
  'Documents/Guides/Build.md',
  'Documents/Guides/AngelscriptStandaloneOfflineBundle.md',
  'Tools/RunStandaloneExternalSmoke.ps1',
  'Tools/Shared/TestSuiteDefinitions.ps1'
)
$hits = Select-String -Path $files -Pattern 'Plugins[/\\]Angelscript[/\\]Standalone' 
if ($hits) { $hits | ForEach-Object { '{0}:{1}:{2}' -f $_.Path, $_.LineNumber, $_.Line }; throw 'stale Plugins/Angelscript/Standalone path remains in owned live docs/tools' }
$defs = Get-Content -LiteralPath 'Tools/Shared/TestSuiteDefinitions.ps1' -Raw
if (($defs | Select-String -Pattern "WorkingDirectory = 'Plugins\\Angelscript\\AngelscriptLSP'" -AllMatches).Matches.Count -lt 3) { throw 'TestSuiteDefinitions must retarget all three Standalone WorkingDirectory values' }
```

Working directory: repository root. Completion: no `Plugins/Angelscript/Standalone` hits in the five files; three WorkingDirectory assignments name `AngelscriptLSP`. Intentionally omit running Standalone CMake/CTest and `RunStandaloneExternalSmoke.ps1` (dormant binary; needs a Release zip this Change does not produce).

**Evidence**

2026-09-11: Select-String found no `Plugins/Angelscript/Standalone` in the five owned files. `TestSuiteDefinitions.ps1` has three `WorkingDirectory = 'Plugins\Angelscript\AngelscriptLSP'` assignments. Smoke default zip path and Build.md `Set-Location` use `AngelscriptLSP`.

## [x] 4.1 Record sibling Changes that still Files Standalone/

`angelscript/refactor-sdk-drop-native-gc` still lists `Plugins/Angelscript/Standalone/Tests/...` and `Standalone/Source/...`. This Change lists that consumer for its own replan and does not rewrite its Task DAG. Scan other active Changes for `Plugins/Angelscript/Standalone/` and include any additional hits.

**Outcome**

`attachments/data/consumer-replan.md` lists every active Change whose Files still name `Plugins/Angelscript/Standalone/`, including at least `angelscript/refactor-sdk-drop-native-gc`, and is indexed once. Excluded: editing those Changes' `tasks.md`.

**Files**

```diff
+openspec/changes/angelscript/refactor-standalone-lsp-layout/attachments/data/consumer-replan.md
 openspec/changes/angelscript/refactor-standalone-lsp-layout/attachments/INDEX.md
```

**Verification**

```powershell
$path = 'openspec/changes/angelscript/refactor-standalone-lsp-layout/attachments/data/consumer-replan.md'
$text = Get-Content -LiteralPath $path -Raw
if ($text -notlike '*angelscript/refactor-sdk-drop-native-gc*') { throw 'consumer list missing refactor-sdk-drop-native-gc' }
$index = Get-Content -LiteralPath 'openspec/changes/angelscript/refactor-standalone-lsp-layout/attachments/INDEX.md' -Raw
if ($index -notlike '*data/consumer-replan.md*') { throw 'INDEX does not list consumer-replan.md' }
$ownTasks = Get-Content -LiteralPath 'openspec/changes/angelscript/refactor-standalone-lsp-layout/tasks.md' -Raw
if ($ownTasks -match '(?m)^[ +-]openspec/changes/angelscript/refactor-sdk-drop-native-gc/tasks.md\s*$') { throw 'this Change must not Files sibling tasks.md' }
```

Working directory: repository root. Completion: the attachment names drop-native-gc, INDEX lists it, and this Change does not Files that sibling `tasks.md`.

**Evidence**

2026-09-11: `attachments/data/consumer-replan.md` lists `angelscript/refactor-sdk-drop-native-gc` as the only active Change Files `Plugins/Angelscript/Standalone/`. INDEX indexes the file once. Files fences do not include sibling `tasks.md`.
