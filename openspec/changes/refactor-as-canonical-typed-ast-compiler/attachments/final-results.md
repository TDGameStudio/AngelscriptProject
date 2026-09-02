# Section 12 final verification

Worktree: `D:\as-cta`

## 12.1 Build

`Tools\RunBuild.ps1 -Label canonical-ast-final -TimeoutMs 1800000 -NoXGE` — exit 0, target up to date.

Reconfirmed 2026-08-21 after Generator `@` fixture fix: `Tools\RunBuild.ps1 -Label canonical-ast-worktree-build -TimeoutMs 1800000 -NoXGE` — `ProcessExitCode 0`, `FinalExitCode 0`, `Target is up to date`, duration 1301ms. ProjectFile=`D:\as-cta\AngelscriptProject.uproject`.

## 12.2 Focused prefixes

Source: All-suite `canonical-ast-final-all2` (`2026-08-21`, `ContinueOnFail=False`, suite exit 0). AngelScriptSDK sub-counts come from `canonical-ast-final-all2_06_AngelScriptSDK` `Report/index.json`. These are **legacy-compatible regression counts**, not proof that sealed AST is the production Bytecode/Sema authority (`reviews/implementation-review-2026-08-21.md`).

| Prefix | Result | Source |
| --- | --- | --- |
| AngelScriptSDK (whole) | **821/821** fail=0 skip=0 | all2_06 |
| Frontend | **209/209** | SDK `fullTestPath` group |
| Compiler | **203/203** | SDK group |
| Runtime | **45/45** | SDK group |
| Module | **56/56** | SDK group |
| TypeSystem | **45/45** | SDK group |
| Language | **163/163** | SDK group |
| Embedding | **36/36** | SDK group |
| Conformance | **4/4** | SDK group |
| Cache | **556/556** fail=0 skip=0 | all2_09 |
| HotReload | **127/127** fail=0 skip=0 | all2_24 |
| StaticJIT | **431/431** fail=0 skip=0 | all2_33 |
| Debugger | **39/39** fail=0 skip=0 | all2_14 |
| CodeCoverage | **not in All suite** | `Tools/Shared/TestSuiteDefinitions.ps1` All entries have no `Angelscript.TestModule.CodeCoverage` prefix |

SDK group remainder inside 821: Engine 48, Support 10, NativeDebug 2.

## 12.3 Standalone

See `attachments/standalone-results.md`: Debug **21/21**, Release **21/21**. All-suite entry 37 reconfirmed Debug **21/21** (`canonical-ast-final-all2_37_Standalone`, CTest exit 0).

## 12.4 All suite

`Tools\RunTestSuite.ps1 -Suite All -LabelPrefix canonical-ast-final-all2 -TimeoutMs 3600000`

- Suite `FinalExitCode` **0**, duration **5493.5s**
- 36 Unreal prefixes: **3632/3632** passed, fail=0 skip=0
- 37th entry Standalone CTest Debug: **21/21**
- Previous `canonical-ast-final-all` run stopped at Generator 93/94 (`@` handle fixture); fixture was changed to implicit handle, then this rerun included Generator **94/94**

| # | Prefix | Result |
| --- | --- | --- |
| 01 | Editor | 85/85 |
| 02 | GAS | 252/252 |
| 03 | GameplayTags | 15/15 |
| 04 | Template | 32/32 |
| 05 | Actor | 52/52 |
| 06 | AngelScriptSDK | 821/821 |
| 07 | Bindings | 282/282 |
| 08 | Blueprint | 11/11 |
| 09 | Cache | 556/556 |
| 10 | Generator | 94/94 |
| 11 | Compiler | 81/81 |
| 12 | Component | 20/20 |
| 13 | Core | 53/53 |
| 14 | Debugger | 39/39 |
| 15 | Delegate | 13/13 |
| 16 | Dump | 14/14 |
| 17 | TestModuleEditor | 12/12 |
| 18 | Engine | 131/131 |
| 19 | FileSystem | 22/22 |
| 20 | Functional | 128/128 |
| 21 | FunctionLibraries | 56/56 |
| 22 | GameInstanceSubsystem | 1/1 |
| 23 | GC | 11/11 |
| 24 | HotReload | 127/127 |
| 25 | Inheritance | 3/3 |
| 26 | Interface | 11/11 |
| 27 | Memory | 7/7 |
| 28 | Networking | 6/6 |
| 29 | Parity | 15/15 |
| 30 | Performance | 4/4 |
| 31 | Preprocessor | 63/63 |
| 32 | Shared | 33/33 |
| 33 | StaticJIT | 431/431 |
| 34 | Syntax | 141/141 |
| 35 | Validation | 7/7 |
| 36 | WorldSubsystem | 3/3 |
| 37 | Standalone CTest | 21/21 |

Numeric All gate is green. It does **not** retire R01–R10 in `reviews/implementation-review-2026-08-21.md`.

## 12.5 Record checks

- `openspec validate "refactor-as-canonical-typed-ast-compiler"` — valid
- `git diff --check` — clean
- Forbidden-symbol scan is locked by Cutover 5/5
- Do not archive unless the user requests closure
- Specs were not overturned. False-complete production tasks reopened in `tasks.md` sections 10 and 13. Mapping: `attachments/record-reconciliation.md`.
