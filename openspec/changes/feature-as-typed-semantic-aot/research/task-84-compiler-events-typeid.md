# 8.4 Compiler.Events TypeIdMapCount miss

Date: 2026-08-18. Companion to
`research/task-84-cache-provenance-crash.md`.

## Symptom

After Cache prefix passed, official `Suite All` stopped at prefix 11
`Angelscript.TestModule.Compiler` **80/81**. Editor exit 255, suite exit 1.

Failed case:
`Angelscript.TestModule.Compiler.Events.FAngelscriptCompilerEventsTests.SuccessfulCompileEmitsOrderedStageEvents`

Message: `Compiler event state diff should include AS engine type-id map impact`
at `AngelscriptCompilerEventsTests.cpp:454`.

Isolated reproduce: `Angelscript.TestModule.Compiler.Events` **6/7**.

Report:
`Saved/Tests/semantic-aot-all-final_11_Compiler/20260818_114215_159_1d08d6e4`

## Root cause

The test compiled a function-only module (`int Entry() { return 17; }`)
on the shared class engine and required `TypeIdMapCount` to be
`Changed`. That field is `asCScriptEngine::mapTypeIdToTypeInfo.Num()`.
Compiling a script type updates `allScriptDeclaredTypes` and dumps as
`AllScriptDeclaredTypeCount` (observed 0→1). `mapTypeIdToTypeInfo`
grows only when a type id is interned, so `TypeIdMapCount` stayed out
of the diff. The dump artifact showed `Added=67 Removed=58 Changed=6`
without a `TypeIdMapCount` row.

This is not the Cache provenance crash. Production compile still
succeeds; the assertion named the wrong dump field for script-declared
types.

## Fix

Test-only:

1. Fixture adds `class FCompilationEventsStagesType { int Value; }` so
   a script-declared type is part of the compile under test.
2. Assertion watches `AllScriptDeclaredTypeCount` `Changed` instead of
   `TypeIdMapCount`.

Files:
`Plugins/Angelscript/Source/AngelscriptTest/Compiler/AngelscriptCompilerEventsTests.cpp`

## Proof

- RED: Compiler.Events 6/7
  `Saved/Tests/semantic-aot-84-compiler-events/20260818_114434_640_f087c609`
- GREEN: Compiler.Events 7/7
  `Saved/Tests/semantic-aot-84-compiler-events-green2/20260818_114805_778_938cc392`
