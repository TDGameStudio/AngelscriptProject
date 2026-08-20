# Test Direction Map Implementation Plan

> **For agentic workers:** This change is **docs + suite discoverability only**. Do not move `Syntax/` / `Coverage/` / `Bindings/` tests. REQUIRED: follow `openspec/changes/docs-as-test-direction-map/design.md` and `specs/as-test-direction-map/spec.md`.

**Goal:** Authors pick a **subject** (AS library slot: USTRUCT, UCLASS, Actor, …) and a **question** (what to prove); Coverage becomes a named suite; legacy overlap is labeled stop-feeding.

**Architecture:** Two-axis overlay. Subject tree under `Fixtures/` is the code library. Eight question ids choose the C++/COMPLEX driver. Shared TestCorpus is lookup, not a ninth suite.

**Tech Stack:** Markdown guides, `Tools/Shared/TestSuiteDefinitions.ps1`.

**Spec:** `openspec/changes/docs-as-test-direction-map/specs/as-test-direction-map/spec.md`

## Global Constraints

- Direction question ids are exactly: `native-fork`, `surface-form`, `bind-contract`, `behavior-matrix`, `world-story`, `reload-generation`, `same-as-profile`, `host-machinery`.
- Subject ids are the closed list in `research/subject-ladder.md` (Language nested leaves; then Definitions, Containers, Feature, World, Gameplay, Optional, Host).
- New tests name **both** a subject id and a question id.
- CQTest incubates; once a feature is stable, graduate onto the COMPLEX session (catalog and/or `Session.World()` / `Session.Blueprint()`). Do not leave a CQTest driver as the house of record (`research/framework-lanes.md`).
- Do not cartesian every subject against every question.
- Do not rename test directories in this change.
- Do not delete Syntax packed execute or Coverage language rows in this change.
- Verify only via `Tools\RunBuild.ps1`, `Tools\RunTests.ps1`, `Tools\RunTestSuite.ps1`. For this change, `RunTestSuite.ps1 -ListSuites` is the suite proof; do not require a full Coverage run to mark docs tasks done.
- Chinese-first for `AGENTS_ZH.md` and `Documents/Knowledges/ZH/Test_Layering.md`.
- Dual-repo: parent OpenSpec + parent docs/tools only. Submodule `TESTING_GUIDE.md` is a plugin-docs edit (commit submodule then gitlink if that file is touched).
- **Math is blocked:** do not extract `Fixtures/Gameplay/FMath` or `FVector`…, do not teach `Math::` in apply docs, and do not use leftover id `Gameplay.Math`, until `improve-as-library-namespace-canonicalization` is archived. Math FunctionLibrary behavior stays `improve-as-runtime-function-libraries`.

---

## File map

| Path | Role |
|---|---|
| `Documents/Guides/TestConventions.md` | Insert direction table **above** the existing layer matrix; keep the matrix as storage |
| `Documents/UnitTest/UnitTest.md` | Add a “pick a direction” section before Bindings-vs-Coverage |
| `Documents/Guides/Test.md` | Name `Coverage` suite next to Bindings / NativeCore |
| `Documents/Knowledges/ZH/Test_Layering.md` | Chinese routing table + pointer to this change |
| `Plugins/Angelscript/Source/AngelscriptTest/TESTING_GUIDE.md` | Step 0: direction id |
| `AGENTS_ZH.md` / `AGENTS.md` | One-paragraph pointer if the test-layering summary is there |
| `Tools/Shared/TestSuiteDefinitions.ps1` | Named `Coverage` suite + `All` prefix |
| `openspec/changes/test-as-data-driven-engine-harness/research/current-test-layers.md` | Pointer to this map |
| `openspec/changes/docs-as-test-direction-map/research/subject-ladder.md` | Closed subject id list |
| `openspec/changes/docs-as-test-direction-map/research/subject-catalog.md` | Expanded map: Syntax/Coverage/Functional cheat sheet, misfiled dirs, fill order; copy summary into guides |
| `openspec/changes/docs-as-test-direction-map/research/overlap-and-gaps.md` | Already recorded; do not treat as apply work |

Copy this eight-row table into the guides (Chinese in ZH files):

| Id | Question | Owner folder | Driver |
|---|---|---|---|
| `native-fork` | Fork without UE types? | `AngelScriptSDK/` + Standalone CTest | Native / CMake |
| `surface-form` | Does this spelling compile/fail on `FAngelscriptEngine`? | `Syntax/` + `Compiler/` + `Preprocessor/` | CQTest helpers |
| `bind-contract` | Is this bind/UHT/mixin entry wired? | `Bindings/` + `FunctionLibraries/` + `UHTTool/` | CQTest smoke |
| `behavior-matrix` | Type/API values, edges, combinations? | `Coverage/` | CQTest matrix / later generate |
| `world-story` | UObject/World/Actor lifecycle? | `Functional/` + `Script/Tests/` | World / `UAngelscriptTestSuite` |
| `reload-generation` | Script shape change / generated UClass? | `HotReload/` + `Generator/` + Editor recovery | CQTest + HotReload corpus |
| `same-as-profile` | Same program on VM/Cache/JIT? | `Fixtures/` + DataDriven COMPLEX | COMPLEX `profiles[]` |
| `host-machinery` | Cache codec, JIT ABI, dump, DAP, engine lifecycle? | `Cache/` store, `StaticJIT/` packager, `RuntimeJIT/` factory, `Core/`, `Dump/`, `Debugger/`, `FileSystem/` | CQTest |

Stop-feeding line to include in every guide that lists Syntax: do not add new Syntax packed `ExpectGlobalInts` that duplicate Coverage int/control-flow.

---

## 1. Author-facing routing (docs)

- [ ] 1.1 <!-- Non-TDD --> In `Documents/Guides/TestConventions.md`, insert a new section **before** `### 1. 测试层级矩阵` titled `### 0. 测试方向（题材 × 问题）`. Paste: (a) the band table from `research/subject-ladder.md`; (b) the eight-question table from `design.md`; (c) a pointer to `research/subject-catalog.md` for Syntax/Functional cheat sheet; (d) the graduation rule (CQTest incubates, DataDriven is the house of record). State: new tests name one subject id and one question id; library files live under `Fixtures/<band>/`; operators/syntax are Language; USTRUCT/UCLASS are Definitions; TArray/handles are Containers; mixin/Delegates/DefaultComponent/Attach/`asset … of`/class-body `default`/custom `access` are Feature; Input/Physics/`FMath::` are Gameplay (GameplayTags stays `Optional.GameplayTags`); `world-story` keeps those **full names** when running in a real World (do not dump into `World.Actor`); `World.Actor` is only Actor host lifecycle; `FAngelscriptTestScriptCorpus` is lookup not a ninth suite; do not cartesian every question; `class AFoo : AActor` without spawn is `Definitions.UClass`. Keep the existing layer matrix as “which C++ driver owns the question.” Fix the stale UE-functional path list that still says `Actor/` at repo root — owner is `Functional/<Theme>/`.

- [ ] 1.2 <!-- Non-TDD --> In `Documents/UnitTest/UnitTest.md`, add a short section immediately before the Bindings-vs-Coverage paragraphs (~line 145): “New tests name one subject and one question.” Include the USTRUCT vs Actor worked examples from `design.md` Decision 1. Restate Decision 3 (Syntax MUST NOT add new packed execute duplicating Coverage). Restate Decision 11–12: CQTest is the incubator; after the feature is stable, move `.as` to `Fixtures/`, put catalog-expressible oracles on the catalog enumerator, and World/Blueprint on `Session.World()` / `Session.Blueprint()`. Do not rewrite CQTest formatting rules.

- [ ] 1.3 <!-- Non-TDD --> In `Plugins/Angelscript/Source/AngelscriptTest/TESTING_GUIDE.md`, add “Step 0 — pick subject then question” above the current FAngelscriptEngine / World / Editor questions. Point to `TestConventions.md` §0 and `research/subject-ladder.md`.

- [ ] 1.4 <!-- Non-TDD --> Update `Documents/Knowledges/ZH/Test_Layering.md` 概览: add the subject ladder and eight-question table in Chinese and a link to `openspec/changes/docs-as-test-direction-map/`. Do not recount every cpp file.

- [ ] 1.5 <!-- Non-TDD --> In `Documents/Guides/Test.md` suite list (~line 533), add `- Coverage` with prefix `Angelscript.TestModule.Coverage` and note it is Heavy. Mention `Tools\RunTestSuite.ps1 -Suite Coverage`.

- [ ] 1.6 <!-- Non-TDD --> Add one paragraph to `AGENTS_ZH.md` (Chinese first) and a matching pointer in `AGENTS.md` under testing: authors pick a library subject (USTRUCT/UCLASS vs Actor/Component) and a question id from `docs-as-test-direction-map` before adding tests.

## 2. Suite discoverability

- [ ] 2.1 <!-- Non-TDD --> In `Tools/Shared/TestSuiteDefinitions.ps1`, add:

```powershell
Coverage = @(
    @{ Prefix = 'Angelscript.TestModule.Coverage'; Label = 'Coverage'; Tier = 'Heavy' }
)
```

Insert in `$script:AngelscriptTestSuiteDefinitions` after `CachePackage` (or alphabetically next to Cache). Do not add DataDriven (not implemented).

- [ ] 2.2 <!-- Non-TDD --> In the same file’s `All` array, add `@{ Prefix = 'Angelscript.TestModule.Coverage'; Label = 'Coverage'; Tier = 'Heavy' }` after the `Core` entry so All is still roughly grouped. Do not remove existing prefixes.

- [ ] 2.3 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -ListSuites`. Require the output to list suite `Coverage` with prefix `Angelscript.TestModule.Coverage`, and `All` to include that prefix. Do not run the Coverage tests in this task.

## 3. Point siblings at the map

- [x] 3.1 <!-- Non-TDD --> Append to `openspec/changes/test-as-data-driven-engine-harness/research/current-test-layers.md`: DataDriven is direction `same-as-profile`; Syntax extraction is `surface-form`; see `docs-as-test-direction-map`.

- [x] 3.2 <!-- Non-TDD --> Append to `openspec/changes/test-as-data-driven-engine-harness/research/syntax-refactor-map.md` and `test-authoring-refactor-backlog.md`: Syntax is `surface-form`; no new packed execute; DataDriven is not the Syntax driver.

- [x] 3.3 <!-- Non-TDD --> In `openspec/changes/test-as-hotreload-script-corpus/proposal.md` Impact (or a one-line note at the top of `design.md` if present), state direction id `reload-generation`. In `openspec/changes/test-as-script-corpus-and-functional-coverage/proposal.md`, state `world-story` for `Script/Tests/` and teaching `Script/`.

## 4. Close

- [x] 4.1 <!-- Non-TDD --> Run `openspec validate docs-as-test-direction-map --strict` and fix any spec SHALL/scenario issues.

- [ ] 4.2 <!-- Non-TDD --> If `TESTING_GUIDE.md` was edited, commit the Angelscript submodule first, then parent gitlink + OpenSpec + docs + `TestSuiteDefinitions.ps1`. Do not commit unless the user asks.

## 5. Math (deferred — FMath first)

- [ ] 5.1 <!-- Non-TDD --> After `improve-as-library-namespace-canonicalization` is archived, replace any remaining `Gameplay.Math` / `Math::` wording in applied guides with `Gameplay.FMath` and `FMath::`. Do not start this task while that change is still active. Math struct ids are `Gameplay.FVector` / `FRotator` / `FQuat` / `FTransform` / `FLinearColor` / `FVector2D`. Fixture extract of those subjects is a later sibling mover, not this change’s apply.
