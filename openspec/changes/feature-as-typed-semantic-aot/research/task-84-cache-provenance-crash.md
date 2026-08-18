# 8.4 Cache source-provenance crash

Date: 2026-08-18

## Symptom

Official `Suite All` prefix 09 `Angelscript.TestModule.Cache` crashed
(editor exit 3) in
`FingerprintedPreprocessInputChangesCompiledContentWithOwnerSourceStable`
at `AngelscriptEngine.cpp:7281`:

`Invalid processed source provenance range` for `CleanOracleInput.as`.

## Root cause

`class FCachePayload` emits a trailing `StaticClassHelper` generated
range. The Cache test's `OnPostProcessCode` hook then
`ReplaceInline("CACHE_EXTERNAL_VALUE", "7"|"8")`, which shortens
`ProcessedCode` by 20 TCHARs. Provenance offsets were recorded *before*
the hook, so the helper range no longer fit `Section.Code`.

## Fix

After `OnPostProcessCode`, remap existing ranges through a longest
common prefix / suffix edit of the pre/post hook `ProcessedCode`, then
drop any range that still does not fit. Production hooks do not need to
know about provenance.

## Proof

- RED: `Preprocessor.SourceProvenance` 1/2
  (`PostProcessCodeReplacementKeepsTrailingGeneratedRangesInBounds`)
  `Saved/Tests/semantic-aot-84-prov-red/20260818_105023_088_68483986`
- GREEN: same prefix 2/2
  `Saved/Tests/semantic-aot-84-prov-green/20260818_105127_531_65107ab2`
- Cache prefix 549/549
  `Saved/Tests/semantic-aot-84-cache-green/20260818_105220_833_c310b4c9`
- All rerun Cache 549/549
  `Saved/Tests/semantic-aot-all-final_09_Cache/20260818_112708_622_0f28ae5b`

## Follow-on All stop: Compiler.Events TypeIdMapCount

After Cache passed, All stopped at prefix 11 Compiler **80/81**.
`SuccessfulCompileEmitsOrderedStageEvents` required
`TypeIdMapCount` `Changed`. Compiling a script module updates
`AllScriptDeclaredTypeCount` (0→1) and does not grow
`mapTypeIdToTypeInfo` until a type id is interned. Fixture now includes
`FCompilationEventsStagesType`; assertion watches
`AllScriptDeclaredTypeCount`.

- RED: Compiler.Events 6/7
  `Saved/Tests/semantic-aot-84-compiler-events/20260818_114434_640_f087c609`
- GREEN: Compiler.Events 7/7
  `Saved/Tests/semantic-aot-84-compiler-events-green2/20260818_114805_778_938cc392`
