# Current HotReload tests vs this corpus

## What already exists

`Plugins/Angelscript/Source/AngelscriptTest/HotReload/` is EditorContext CQTest, prefix `Angelscript.TestModule.HotReload`, suite **HotReload** (Heavy). Representative files:

- `AngelscriptHotReloadChangeClassificationTests.cpp` — 22 methods, `CompileAnnotatedModuleFromMemory` then `AnalyzeReloadFromMemory` (`Shared/AngelscriptTestEngineHelper.*`). This is the decision matrix.
- `AngelscriptHotReloadTests.cpp` — functional spawn (`AngelscriptFunctionalTestUtils`, `FActorTestSpawner`), e.g. property preserved across body change.
- Blueprint child, PIE, networking, file removal, delegates, components, version chain — keep CQTest.

Analyzer mapping (`AnalyzeReloadFromMemory`):

| `ECompileResult` | `EReloadRequirement` |
|---|---|
| FullyHandled | SoftReload |
| PartiallyHandled | FullReloadSuggested (`bWantsFullReload`) |
| ErrorNeedFullReload | FullReloadRequired (`bWantsFull` + `bNeedsFull`) |
| Error | Error (analyze fails)

## Pain

Each method inlines `ScriptV1` / `ScriptV2`. That source cannot be fetched by `/Angelscript/Memory/TestCorpus/...`, shared with World tests, or expanded as COMPLEX leaves without copying strings.

## What this change copies

From `test-as-data-driven-engine-harness`: corpus files, COMPLEX snapshot `GetTests`, command as key, per-leaf session, driver card, dump-on-failure.

## What this change must not copy

Engine profiles (`vm`, cache two-phase, typed-ast generate, runtime-jit). `executeInt` as the HotReload oracle. `FAngelscriptDataDrivenAutomation`. Host `Script/` teaching corpus.

## Apply order

`FAngelscriptTestScriptCorpus` (`test-as-data-driven-engine-harness` task 2) first. This change's pair helper calls `TryGetByRelativePath`; it does not open `Fixtures/` with a private reader.
