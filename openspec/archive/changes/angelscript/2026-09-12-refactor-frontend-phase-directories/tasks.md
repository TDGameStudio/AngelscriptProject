---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
---

# Split reconstructed frontend sources into phase directories

## Goal

Move reconstructed language sources into `frontend/{Basic,Lexer,Parser,AST,Sema,Compile}/`, align implementation filenames with headers, rewrite includes, and retarget live path citations, without changing language behavior or C++ namespaces.

## Architecture

Headers stay beside cpp. Includes remain on the `angelscript/` root as `#include "frontend/<Phase>/as_*.h"`. `asCBuilder` stays at the SDK root because `RunThrough` includes bytecode. See `design.md`.

## Global constraints

- Do not start 1.1 while `angelscript/test-lexer-isolated-coverage` or `angelscript/refactor-bindings-two-stage-pipeline` still mutate the same frontend files, unless the user sequences this after them.
- Do not add `frontend/` or a phase folder as a UBT include root.
- Do not rename `as_frontend_options.h`. Do not move `as_builder.h` or bytecode emit into `frontend/`.
- Do not create `frontend/Frontend/`. Prefer `git mv`.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
-Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder_frontend.cpp  # · 1.1
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.cpp  # · 1.1
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.h  # · 1.1
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/  # · 1.1
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Lexer/  # · 1.1
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/  # · 1.1
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/AST/  # · 1.1
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/  # · 1.1
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/  # · 1.1
 openspec/changes/angelscript/refactor-frontend-phase-directories/specs/angelscript/language/ast/core/spec.md  # · 1.2
 openspec/specs/angelscript/language/ast/core/knowledges/first-party-sdk-root.md  # · 1.2
```

Leaf assignment is `attachments/drafts/findings/folder-map.md`. Every current `frontend/` leaf moves into exactly one phase folder.

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Headers live under `frontend/<Phase>/`; include `"frontend/<Phase>/as_*.h"` | 1.1, 1.2 |
| Impl stems match headers except `as_frontend_options.h` | 1.1 |
| `as_builder.cpp` at SDK root; `as_builder.h` unmoved | 1.1 |
| Host trio in `Compile/`; preprocessor in `Lexer/` | 1.1 |
| No include/lib split; no `frontend/Frontend/` | 1.1 |
| ast/core include scenario names the six phases | 1.2 |
| first-party-sdk-root cites phased includes | 1.2 |
| Acceptance: `ue.build` succeeds | 1.1 |
| Acceptance: `frontend/` root has only the six phase directories | 1.1 |

Self-review 2026-09-12: coverage complete; no placeholder phrases; symbols match `design.md` and `attachments/drafts/glossary.md`. Record: `attachments/data/planning-validation.md`.

## 1. Source move

## [x] 1.1 Relocate frontend sources into six phase folders and rewrite includes

`frontend/` is a flat bag of 107 files. After this task those leaves live under `Basic/`, `Lexer/`, `Parser/`, `AST/`, `Sema/`, and `Compile/` per `attachments/drafts/findings/folder-map.md`, implementation files match header stems except `as_frontend_options.h`, `as_builder_frontend.cpp` is `as_builder.cpp` at the SDK root, and every live `#include "frontend/as_*.h"` becomes `#include "frontend/<Phase>/as_*.h"`.

**Outcome**

The live AngelscriptRuntime and AngelscriptTest build sees only phased frontend paths. `asCParser`, `asCSema`, `asCTokenizer`, `asCASTContext`, and `asCCompilationSession` keep those C++ names in `BEGIN_AS_NAMESPACE`. Excluded: spec/knowledge prose (1.2); bytecode emit move; renaming `as_frontend_options.h`; adding UBT include roots.

**Interfaces**

Consumes (existing):

```cpp
// AngelscriptRuntime.Build.cs:127
PublicIncludePaths.Add(Path.Combine(ModuleDirectory, "angelscript"));

// as_builder.h:4
#include "frontend/as_builder_stages.h"

// as_tokenizer.h:7-10
#include "frontend/as_character_stream.h"
#include "frontend/as_diagnostics.h"
#include "frontend/as_frontend_options.h"
#include "frontend/as_identifier_table.h"

// as_parser.h:4-5
#include "frontend/as_preprocessor.h"
#include "frontend/as_sema.h"
```

Produces (`attachments/drafts/glossary.md`):

```cpp
#include "frontend/Basic/as_diagnostics.h"
#include "frontend/Lexer/as_tokenizer.h"
#include "frontend/Lexer/as_frontend_options.h"
#include "frontend/Parser/as_parser.h"
#include "frontend/AST/as_ast_context.h"
#include "frontend/Sema/as_sema.h"
#include "frontend/Compile/as_compilation_session.h"
#include "frontend/Compile/as_builder_stages.h"
#include "as_builder.h"
```

Public names: folders `Basic`, `Lexer`, `Parser`, `AST`, `Sema`, `Compile` (glossary Q2 A); file `as_builder.cpp` (glossary Q6 A); header `as_frontend_options.h` kept (glossary Q5 C).

**Cases**

1. **PhasedIncludeStrings** — new RED
   Given the live AngelscriptRuntime and AngelscriptTest trees When searching for `#include "frontend/as_` Then no live build TU still uses a flat `frontend/as_*.h` include, and `as_tokenizer.h` includes `"frontend/Basic/as_character_stream.h"` and `"frontend/Lexer/as_frontend_options.h"`.

2. **ParserSemaStems** — new RED
   Given `attachments/drafts/findings/as-frontend-prefix.md` When the move finishes Then `frontend/Parser/as_parser.cpp` and `frontend/Sema/as_sema.cpp` exist and `as_frontend_parser.cpp` / `as_frontend_sema.cpp` do not exist anywhere under `angelscript/`.

3. **OptionsHeaderKept** — new RED
   Given the Lexer folder When listing headers Then `frontend/Lexer/as_frontend_options.h` exists and `as_lex_options.h` / `as_options.h` do not exist under `frontend/`.

4. **BuilderStaysAtRoot** — new RED
   Given the SDK root When listing Builder files Then `angelscript/as_builder.h` and `angelscript/as_builder.cpp` exist, `as_builder_frontend.cpp` does not exist, and `as_builder.h` still uses `#include "as_builder.h"` from consumers (not `frontend/Compile/as_builder.h`).

5. **SixFoldersOnly** — new RED
   Given `angelscript/frontend/` When listing immediate children Then the only directories are `Basic`, `Lexer`, `Parser`, `AST`, `Sema`, and `Compile`, and there is no `Frontend/` directory and no leftover flat `as_*.h` / `as_*.cpp` beside those folders.

6. **TypeNamesUnchanged** — existing control
   Given `as_parser.h` and `as_sema.h` after the move When compiling a TU that names `asCParser` and `asCSema` Then those identifiers still resolve inside `BEGIN_AS_NAMESPACE` as they do today (`as_parser.h:17`, `as_sema.h:42`).

**Files**

```diff
-Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder_frontend.cpp
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.h
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Basic/
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Lexer/
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/AST/
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoDraft.h
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bytecode/as_bytecode_image_builder.cpp
 Plugins/Angelscript/Source/AngelscriptTest/
```

Every current `frontend/` leaf is removed from the flat folder by `git mv` into exactly one phase directory per `attachments/drafts/findings/folder-map.md`. Every live `#include "frontend/as_*.h"` under AngelscriptRuntime and AngelscriptTest is rewritten. Dormant Legacy TUs that are not in the live build are left unless they break the selected `ue.build`.

**Verification**

Working directory: selected workspace root. Import Harness and bind `$context` first. Completion: Harness `status` is `Succeeded`; cases 1–5 hold on the tree; the Editor target that currently compiles AngelscriptRuntime and AngelscriptTest links.

```powershell
Invoke-Harness -Command ue.build -Context $context -Parameters @{ TimeoutMs = 1800000 }
```

Intentionally omit `ue.test`, Quick, Performance, and Integration: this task changes include paths, not language behavior. Omit lexer-behavior prefixes owned by `angelscript/test-lexer-isolated-coverage`.

**Notes**

If either named in-flight Change still edits the same frontend files, stop and report rather than merging the moves. Use `git mv`.

**Evidence**

2026-09-12: `ue.build` Succeeded. Harness runId `99d6533fea014e37802c5be891f7d588`; Unreal RunId `196f9e5ffcc74c4fa21bfb1e0c2495e1`; ExitCode 0; DurationMs 124202; Label `AngelscriptProjectEditor`.

- **PhasedIncludeStrings** — no live `#include "frontend/as_"` under AngelscriptRuntime or AngelscriptTest C++ TUs. `as_tokenizer.h` includes `"frontend/Basic/as_character_stream.h"` and `"frontend/Lexer/as_frontend_options.h"`. The one leftover snippet in `Test-CanonicalNamespace.ps1` was rewritten to `"frontend/Parser/as_parser.h"` / `"frontend/Lexer/as_tokenizer.h"` (include lines are stripped before the retired-namespace scan).
- **ParserSemaStems** — `frontend/Parser/as_parser.cpp` and `frontend/Sema/as_sema.cpp` exist; `as_frontend_parser.cpp` / `as_frontend_sema.cpp` are absent under `angelscript/`.
- **OptionsHeaderKept** — `frontend/Lexer/as_frontend_options.h` exists; `as_lex_options.h` / `as_options.h` are absent under `frontend/`.
- **BuilderStaysAtRoot** — `angelscript/as_builder.h` and `angelscript/as_builder.cpp` exist; `as_builder_frontend.cpp` is gone; `as_builder.h` includes `"frontend/Compile/as_builder_stages.h"`; consumers still `#include "as_builder.h"`.
- **SixFoldersOnly** — immediate children of `angelscript/frontend/` are only `AST`, `Basic`, `Compile`, `Lexer`, `Parser`, `Sema`; no `Frontend/` and no leftover flat `as_*.h` / `as_*.cpp`.
- **TypeNamesUnchanged** — `asCParser` remains at `as_parser.h:17`; `asCSema` remains at `as_sema.h:42` inside `BEGIN_AS_NAMESPACE`. The succeeding Editor build is the compile control.

Naming assumed: `frontend/Compile/as_dependency_graph.h` / `as_dependency_graph.cpp` — session-owned module dependency graph; `as_preprocess_result.h` includes it. Not listed in the original folder-map.

Intentionally omitted `ue.test`, Quick, Performance, and Integration: include-path change only.

## [x] 1.2 Retarget live spec and knowledge path citations

After the sources have moved, live records still say headers live in a flat `frontend/` and that consumers include `"frontend/as_*.h"`. This task updates those sentences to the phased paths. The Change-local ast/core delta is already authored; this task keeps it aligned with the moved tree and updates `first-party-sdk-root`.

**Outcome**

Live ast/core knowledge and the Change-local ast/core delta name `frontend/<Phase>/` and `#include "frontend/<Phase>/as_*.h"`. Immutable `openspec/archive/` is untouched. Excluded: a new parsing capability; rewriting draft `log.md`.

**Files**

```diff
 openspec/changes/angelscript/refactor-frontend-phase-directories/specs/angelscript/language/ast/core/spec.md
 openspec/specs/angelscript/language/ast/core/knowledges/first-party-sdk-root.md
 openspec/specs/angelscript/language/ast/core/knowledges/INDEX.md
```

Scan other live specs under `openspec/specs/angelscript/` for leftover flat `frontend/as_*.h` citations and retarget any that remain. Do not edit `openspec/archive/`.

**Verification**

Working directory: selected workspace root. Completion: Harness `status` is `Succeeded`; `first-party-sdk-root.md` shows `#include "frontend/<Phase>/as_*.h"` and does not instruct `"frontend/as_*.h"` as the live contract; the Change-local ast/core delta still names the six phases.

```powershell
Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-frontend-phase-directories', '--type', 'change', '--strict', '--json')
```

**Evidence**

2026-09-12: `openspec.validate angelscript/refactor-frontend-phase-directories --type change --strict --json` Succeeded. Harness runId `06bfdf05739443e69502e531669ecdd8`; item valid, issues empty.

- `first-party-sdk-root.md` instructs `#include "frontend/<Phase>/as_*.h"` and names the six phases; the flat `"frontend/as_*.h"` form is only listed as a rejected live instruction.
- Change-local `specs/angelscript/language/ast/core/spec.md` still names `Basic`, `Lexer`, `Parser`, `AST`, `Sema`, and `Compile`.
- Scan of `openspec/specs/angelscript/` also retargeted `clang-typed-ast-shape-and-lifetime.md`, `clang-lexer-hot-path.md`, and `stable-type-identity-witnesses.md`. `openspec/archive/` was not edited.
- First validate attempt failed with 11 `OS-UNREGISTERED-DOMAIN` errors from an empty untracked leftover tree `openspec/changes/angelscript/test-lexer-isolated-coverage-candidate` (0 files). Removed that empty tree so `load_strict` could run; it is not part of this Change.
