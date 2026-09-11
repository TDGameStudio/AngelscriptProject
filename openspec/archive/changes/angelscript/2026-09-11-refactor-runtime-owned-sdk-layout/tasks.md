---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": []
    "3.1": []
    "4.1": []
---

# Retarget first-party SDK layout

## Goal

Point UBT, current specs, and live fork-strategy guidance at `Source/AngelscriptRuntime/angelscript` after the ThirdParty tree was removed.

## Architecture

The reconstructed SDK is first-party Runtime source at `Source/AngelscriptRuntime/angelscript/` (`as_*.{h,cpp}` beside `frontend/`). UBT adds that folder as the include root; `Core/angelscript.h` stays. Specs keep `BEGIN_AS_NAMESPACE` and only update the example organization path. See `design.md`.

## Global constraints

- Do not restore `ThirdParty/angelscript` or a nested `source/` directory.
- Do not move `Core/angelscript.h` or change public C API / Automation identities.
- Do not edit other Changes' `tasks.md`.
- `angelscript/refactor-standalone-lsp-layout` owns host CMake.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs  # · 1.1
 Plugins/Angelscript/LICENSE.md  # · 3.1
 README.md  # · 3.1
 Documents/Guides/AngelscriptForkStrategy.md  # · 3.1
 Documents/Guides/ASBindFreeCompletenessVerification.md  # · 3.1
 openspec/specs/angelscript/language/ast/core/spec.md  # · 2.1
 openspec/specs/angelscript/language/ast/core/knowledges/clang-typed-ast-shape-and-lifetime.md  # · 2.1
 openspec/specs/angelscript/language/frontend/reflection-dependencies/spec.md  # · 2.1
 openspec/specs/angelscript/language/frontend/lexing/knowledges/clang-lexer-hot-path.md  # · 2.1
 openspec/specs/angelscript/language/types/stable-identity/knowledges/stable-type-identity-witnesses.md  # · 2.1
+openspec/changes/angelscript/refactor-runtime-owned-sdk-layout/attachments/data/consumer-replan.md  # · 4.1
```

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Include reconstructed language headers from `angelscript/frontend/` without a C++ `frontend` namespace | 1.1, 2.1 |
| Fork-internal frontend leaves live under `Source/AngelscriptRuntime/angelscript/frontend/` | 1.1, 2.1 |
| Editor Development build compiles the moved SDK | 1.1 |
| Live ForkStrategy / license / parent README name the first-party root | 3.1 |
| Sibling Changes that still Files `ThirdParty/angelscript` are listed, not rewritten | 4.1 |
| Acceptance: no live `ThirdParty/angelscript` include root in Build.cs | 1.1 |
| Acceptance: current spec/knowledge path language | 2.1 |
| Acceptance: consumer-replan attachment | 4.1 |

Self-review 2026-09-11: coverage complete; no placeholder phrases; symbols match `design.md` (SDK root, `Core/angelscript.h`, no new module). Record: `attachments/data/planning-validation.md`.

## [x] 1.1 Point AngelscriptRuntime include roots at the first-party SDK

`AngelscriptRuntime.Build.cs` still adds `ModuleDirectory/ThirdParty/angelscript` and `.../source`. The sources already live at `ModuleDirectory/angelscript`. After this task UBT compiles that flattened tree. Commented `PluginPath + "/ThirdParty/..."` lines stay commented. No new module, namespace, or header name.

**Outcome**

`PublicIncludePaths` contains `ModuleDirectory/angelscript` and does not contain `ThirdParty/angelscript`. `ModuleDirectory` and `ModuleDirectory/Core` remain. `#include "angelscript.h"` and `#include "frontend/as_parser.h"` resolve. Excluded: moving sources, restoring a nested `source/` folder, changing `Core/angelscript.h`.

**Interfaces**

Consumes (existing, `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs:120-129`):

```csharp
PublicIncludePaths.Add(ModuleDirectory);
PublicIncludePaths.Add(Path.Combine(ModuleDirectory, "Core"));
var AngelscriptThirdPartyPath = Path.Combine(ModuleDirectory, "ThirdParty", "angelscript");
PublicIncludePaths.Add(Path.Combine(AngelscriptThirdPartyPath, "source"));
PublicIncludePaths.Add(AngelscriptThirdPartyPath);
```

Produces: no new public names. The include root string is `Path.Combine(ModuleDirectory, "angelscript")` from `attachments/drafts/glossary.md` (SDK root).

**Cases**

1. **EditorBuildUsesFirstPartyRoot** — new RED
   Given `AngelscriptRuntime.Build.cs` still adds `ThirdParty/angelscript` and that directory is absent When Harness `ue.build` runs `AngelscriptProjectEditor` Win64 Development Then the build fails (missing `frontend/as_parser.h` / `as_scriptengine.h`). After the include-root edit the same command succeeds (exit 0) and compiles Runtime TUs that include `"frontend/…"` and `"angelscript.h"`.
2. **PublicCHeaderStillCore** — existing control
   Given `Source/AngelscriptRuntime/Core/angelscript.h` is unchanged When a Runtime TU includes `"angelscript.h"` Then that include still resolves through `ModuleDirectory/Core`, not from the SDK folder.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs
```

**Verification**

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
Invoke-Harness -Command ue.build -Context $context -Parameters @{
    Target = 'AngelscriptProjectEditor'
    Platform = 'Win64'
    Configuration = 'Development'
    BuildConcurrency = 'Auto'
    ConcurrencyPolicy = 'Auto'
    TimeoutMs = 3600000
}
```

Working directory: repository root. Completion: Harness status `Succeeded`, exit code 0. Observe case 1 red on the current Build.cs, then that case green after the include-root edit. Case 2 stays green (Core header path). Intentionally omit Automation suites, Quick, Performance, Integration, and CMake host package: no SDK behavior changed.

**Evidence**

2026-09-11 RED: Harness `ue.build` `AngelscriptProjectEditor` Win64 Development RunId `09a518d2884e4f1bb0318b2acc32f47b` Failed exit 6. After Build.cs pointed at `ModuleDirectory/angelscript`, live TUs still `#include "source/as_*.h"` (old ThirdParty parent include). C1083 examples: `Bind_Helpers.h` `source/as_generic.h`, `Helper_FunctionSignature.h` `source/as_scriptfunction.h`, `LearningTraceExporter.cpp` `source/as_scriptengine.h`.

Repair in this task: rewrite 826 `#include "source/as_*"` lines in 273 plugin files to `"as_*.h"` or `"frontend/as_*.h"` when that leaf exists on disk. Left 153 Legacy includes of deleted headers (`as_scriptnode.h`, `as_scriptcode.h`, `as_compiler.h`, …) untouched; `WITH_ANGELSCRIPT_UNITTESTS` stays off.

GREEN: RunId `f0fb5e1625a24ed88dc39b916347bd05` Succeeded exit 0, 153430 ms, progress 100% WriteMetadata AngelscriptProjectEditor.target. `Core/angelscript.h` unchanged. Intentionally omitted Automation, Quick, Performance, Integration, CMake host package.

**Notes**

Do not uncomment the historical `PluginPath + "/ThirdParty/include"` lines around Build.cs:195.

## [x] 2.1 Retarget current spec and knowledge SDK paths

Current `angelscript/language/ast/core` and `language/frontend/reflection-dependencies` still say headers may remain under `ThirdParty/angelscript/source/frontend/`. Matching knowledges still list `.../ThirdParty/angelscript/source/...` as current source locations. After this task those live records name `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/` and place frontend leaves under `frontend/`. Namespace rules in the Change delta specs stay. Archives are not edited.

**Outcome**

The two current specs match this Change's delta: directory organization is `Source/AngelscriptRuntime/angelscript/frontend/`, still independent of C++ scope. Knowledges that cited the old tree as current authority point at files that exist under the new root (`frontend/as_decl.h`, `frontend/as_stmt.h`, `frontend/as_expr.h`, `frontend/as_tokenizer.h` / tokenizer implementation, `as_runtime_type_binding.h` at the SDK root). `as_ast_type.h` is retargeted to the current typed-type header that exists on disk (`frontend/as_type.h`) rather than a deleted basename. Excluded: archive records, ZH dumps, sibling Change Files.

**Files**

```diff
 openspec/specs/angelscript/language/ast/core/spec.md
 openspec/specs/angelscript/language/ast/core/knowledges/clang-typed-ast-shape-and-lifetime.md
 openspec/specs/angelscript/language/frontend/reflection-dependencies/spec.md
 openspec/specs/angelscript/language/frontend/lexing/knowledges/clang-lexer-hot-path.md
 openspec/specs/angelscript/language/types/stable-identity/knowledges/stable-type-identity-witnesses.md
```

**Verification**

```powershell
$files = @(
  'openspec/specs/angelscript/language/ast/core/spec.md',
  'openspec/specs/angelscript/language/ast/core/knowledges/clang-typed-ast-shape-and-lifetime.md',
  'openspec/specs/angelscript/language/frontend/reflection-dependencies/spec.md',
  'openspec/specs/angelscript/language/frontend/lexing/knowledges/clang-lexer-hot-path.md',
  'openspec/specs/angelscript/language/types/stable-identity/knowledges/stable-type-identity-witnesses.md'
)
$hits = Select-String -Path $files -Pattern 'ThirdParty/angelscript' -SimpleMatch
if ($hits) { $hits | ForEach-Object { '{0}:{1}:{2}' -f $_.Path, $_.LineNumber, $_.Line }; throw 'stale ThirdParty/angelscript remains in owned current specs/knowledges' }
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-runtime-owned-sdk-layout', '--type', 'change', '--strict', '--json')
```

Working directory: repository root. Completion: the Select-String check throws on any hit; Harness `openspec.validate` status `Succeeded`. Intentionally omit `ue.build` here (owned by 1.1) and omit archive/ZH greps.

**Evidence**

2026-09-11: Select-String on the five owned files found no `ThirdParty/angelscript`. `openspec.validate angelscript/refactor-runtime-owned-sdk-layout --type change --strict` Succeeded. `as_ast_type.h` retargeted to `frontend/as_type.h`; tokenizer/parser sources to `frontend/as_frontend_tokenizer.cpp` / `as_frontend_parser.cpp`.

## [x] 3.1 Retarget live fork-strategy and kernel path docs

`Documents/Guides/AngelscriptForkStrategy.md` still instructs edits under `ThirdParty/angelscript/source`. Parent `README.md` still lists the kernel as `ThirdParty/angelscript/`. Plugin `LICENSE.md` still attributes AngelCode code to `ThirdParty/angelscript/`. `ASBindFreeCompletenessVerification.md` still cites `.../ThirdParty/angelscript/source/as_scriptfunction.{h,cpp}`. After this task those live instructions name `Source/AngelscriptRuntime/angelscript/`. Dated audit notes under `Documents/Guides/` that only record a 2026-06-30 snapshot stay historical.

**Outcome**

ForkStrategy's current-source row, `[UE++]` marking rule, and backport-edit instructions name `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/`. Parent README architecture table and license bullet, plugin LICENSE third-party section, and the BindFree completeness source citation use that root. Product version and `[UE++]` policy text stay. Excluded: dated `RuntimeArchitectureAudit_20260630.md`, `TechnicalDebtInventory.md` historical rows, ZH dumps.

**Files**

```diff
 Documents/Guides/AngelscriptForkStrategy.md
 Documents/Guides/ASBindFreeCompletenessVerification.md
 README.md
 Plugins/Angelscript/LICENSE.md
```

**Verification**

```powershell
$files = @(
  'Documents/Guides/AngelscriptForkStrategy.md',
  'Documents/Guides/ASBindFreeCompletenessVerification.md',
  'README.md',
  'Plugins/Angelscript/LICENSE.md'
)
$hits = Select-String -Path $files -Pattern 'ThirdParty/angelscript' -SimpleMatch
if ($hits) { $hits | ForEach-Object { '{0}:{1}:{2}' -f $_.Path, $_.LineNumber, $_.Line }; throw 'stale ThirdParty/angelscript remains in owned live docs' }
```

Working directory: repository root. Completion: no hits in the four files. Intentionally omit Automation and CMake. Remaining `ThirdParty/angelscript` in `openspec/archive/` and `Documents/Knowledges/ZH/` is historical.

**Evidence**

2026-09-11: Select-String on ForkStrategy, BindFree completeness, parent README, and plugin LICENSE found no `ThirdParty/angelscript`. Kernel row and zlib attribution now name `Source/AngelscriptRuntime/angelscript/`.

## [x] 4.1 Record sibling Changes that still Files the old SDK tree

Active Changes still name `ThirdParty/angelscript` in their Files. This Change lists them for their own replan and does not rewrite those Task DAGs.

**Outcome**

`attachments/data/consumer-replan.md` lists at least `angelscript/feature-frontend-diagnostics-tooling`, `angelscript/refactor-sdk-drop-native-gc`, and `angelscript/refactor-bindings-two-stage-pipeline`, states that they replan Files themselves, and is indexed once. Excluded: editing those Changes' `tasks.md`.

**Files**

```diff
+openspec/changes/angelscript/refactor-runtime-owned-sdk-layout/attachments/data/consumer-replan.md
 openspec/changes/angelscript/refactor-runtime-owned-sdk-layout/attachments/INDEX.md
```

**Verification**

```powershell
$path = 'openspec/changes/angelscript/refactor-runtime-owned-sdk-layout/attachments/data/consumer-replan.md'
$text = Get-Content -LiteralPath $path -Raw
foreach ($id in @(
  'angelscript/feature-frontend-diagnostics-tooling',
  'angelscript/refactor-sdk-drop-native-gc',
  'angelscript/refactor-bindings-two-stage-pipeline'
)) { if ($text -notlike "*$id*") { throw "consumer list missing $id" } }
$index = Get-Content -LiteralPath 'openspec/changes/angelscript/refactor-runtime-owned-sdk-layout/attachments/INDEX.md' -Raw
if ($index -notlike '*data/consumer-replan.md*') { throw 'INDEX does not list consumer-replan.md' }
$ownTasks = Get-Content -LiteralPath 'openspec/changes/angelscript/refactor-runtime-owned-sdk-layout/tasks.md' -Raw
if ($ownTasks -match '(?m)^[ +-]openspec/changes/angelscript/(feature-frontend-diagnostics-tooling|refactor-sdk-drop-native-gc|refactor-bindings-two-stage-pipeline)/tasks.md\s*$') { throw 'this Change must not Files sibling tasks.md' }
```

Working directory: repository root. Completion: the attachment names the three IDs, INDEX lists it, and this Change's `tasks.md` does not Files sibling `tasks.md` paths.

**Evidence**

2026-09-11: `attachments/data/consumer-replan.md` lists diagnostics-tooling, drop-native-gc, bindings-two-stage, and additionally `feature-delegates-ue-interop` from the tasks.md scan. INDEX indexes the file once. This Change's Files fences do not include sibling `tasks.md`.
