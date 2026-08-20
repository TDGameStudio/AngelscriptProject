# HotReload pipeline refactor map

Offline map for `refactor-as-hotreload-pipeline`. Production policy stays in ClassGenerator; this file is the workstream index.

## Already done (do not redo)

- ClassGenerator split: `_Analyze`, `_SoftReload`, `_FullReload`, `_ReloadPlanning`, `_Reinstancing`, `AngelscriptClassReloadPlanner`.
- Engine-owned reload delegates (`GetOnClassReload`, etc.) after deglobalization; Editor `FClassReloadHelperExtension` subscribes per engine.
- JIT reloadable wrappers reread current binding (`ASFunction_JITDispatch.cpp`).
- Large HotReload CQTest suite + Generator `ReloadPlanning` planner-graph tests.
- Wiki: `reload-pipeline-internals`, `change-classification`, `source-tests-maintenance`, `RT_HotReload.md`.

## Still messy

| Item | Where | Do not “fix” by |
|---|---|---|
| Inline v1/v2 AS | `AngelscriptTest/HotReload/*.cpp` | Adding DataDriven `vm` profiles |
| Static `FReloadState` | `ClassReloadHelper.h` | Moving it into Runtime |
| Helper header mix | UnrealEd + ClassGenerator in one `.h` | Merging modules |
| Editor branches in Runtime | ClassGenerator `WITH_EDITOR` / `GIsEditor` | Teaching Runtime to refresh BP action DB |
| Short `Filename` vs TestCorpus path | `AnalyzeReloadFromMemory` | Packing JSON into Automation `Parameters` |
| 2026-06-30 audit sizes | `RuntimeArchitectureAudit` §D | Assuming `AngelscriptClassGenerator.cpp` is still 5000 lines |

## Apply order

1. `FAngelscriptTestScriptCorpus` (engine-harness change task 2)
2. `test-as-hotreload-script-corpus` Wave A goldens
3. Identity audit (`filename` vs virtual path)
4. ClassReloadHelper include split / `FReloadState` partition
5. ClassGenerator editor-branch moves, one at a time

## Related prefixes

- `Angelscript.TestModule.HotReload`
- `Angelscript.TestModule.HotReload.Corpus` (sibling)
- `Angelscript.TestModule.Generator.ReloadPlanning`
