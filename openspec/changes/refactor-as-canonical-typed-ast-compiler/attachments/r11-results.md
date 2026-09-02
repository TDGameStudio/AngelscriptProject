# R11 results — funcdef/handle/lambda CodeGen teardown

Worktree: `D:\as-cta`. Do **not** mark `tasks.md` 9.5 / 13.6 / 13.2. Isolated `Generate()` only. Production `Build()` still `asCCompiler`.

## Gate

`Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen`

- Label `r11-codegen-prefix2`
- Report: `D:\as-cta\Saved\Tests\r11-codegen-prefix2\20260821_153809_574_2c2034f8\Report\index.json`
- Scratch copy: `{SCRATCH}/r11-codegen-prefix2.json`
- **total=24 passed=24 failed=0 skipped=0**

Includes:

- `CodeGenEmitsFuncdefCallAndLambda` (execute `11`, `Discard()`, `Engine.Destroy()`)
- `CodeGenFuncdefHandleTeardownSurvivesEngineDestroy` (`Invoke(Double,3)==6`)
- `CodeGenLambdaTeardownSurvivesEngineDestroy` (`L(4)==5`)
- `CodeGenFuncPtrStoreTeardownSurvivesEngineDestroy` (`Callback L = Double`)
- `CodeGenIndirectCallTeardownSurvivesEngineDestroy` (`F(Callback)`)
- `CodeGenDumpsFuncdefHandleConversionAndOpcodes` (diagnostic dump)
- `CodeGenEmitsCallInReverseFormalOrder` (`Sub(3,4)==-1`)

Dump-only gate `r11-codegen-dump`: **1/1**.

## Confirmed causes (in order)

1. **Sema `Conversion` of a function to host `Callback` was treated as a numeric convert.** `EmitConversion` failed (`asNOT_SUPPORTED`, line ~1077). `Invoke(Double, 3)` never lowered. First seen as Generate `-7` after lookup-only funcdef typing.
2. **`asCScriptFunction::funcdefType` is a process-wide static in this fork.** `asNEW` of any script function zeros it. Lookup must walk `engine->funcDefs` / `registeredFuncDefs` by return+parameter types, not `callee->funcdefType`.
3. **Wave B `ActOnCall` stores reverse-formal children; `EmitCall` also reversed.** `Sub(3,4)` became `1`. Combined CallPtr then executed a garbage function pointer (`ExecuteNext` `as_context.cpp:3947`, read `0xffffffffffffffff`). Fix: push stored child order (already reverse-formal).
4. **Teardown AV (`ReleaseAllFunctions` `:723` ← dtor `:987`)** after execute-correct. Remaining ownership match vs compiler: lookup-only existing funcdef as the *variable* type; `REFCPY`/`FREE` operand is `$func`; no `ObjInfo(INIT)` on handle store; do not `FindMatchingFuncdef(..., module)` (creates funcdefs); do not `CreateType($func)`; `DiscardPending` clears bytecode before `ReleaseInternal` so unmatched `ReleaseReferences` cannot extra-release host `Callback`.

## Debug tools landed (companion, not a cutover)

Production (fork, no Unreal types):

- `asCBytecodeCodeGen::GetError()` / `GetLastFailLine()` — real `asERetCodes` plus the `FailAt` source line.
- `asCBytecodeCodeGenDumpFunction` / `asCBytecodeCodeGenDumpModule` — function id, `objVariablesOnHeap`, objvar names/flags/pos, bytecode names, `FuncPtr` callee, `REFCPY`/`FREE` type operand (`$func` vs `Callback`).

Tests:

- `GenerateCanonicalFromSource(..., Test)` dumps sealed AST + error + fail line on Generate failure.
- `CodeGenDumpsFuncdefHandleConversionAndOpcodes` asserts the module dump contains `FuncPtr`, `REFCPY`, and `$func` or `Callback`.

## Not done

- Production `Build()` is not routed to `Generate()`. `Ready()` stays false. Default stays `LEGACY`.
- 9.5 / 13.6 stay `[ ]`. Language coverage is still the isolated subset.
- 13.2 / 5.9 stay `[ ]` (SemaAuthority 22/22 dumps are not authority).
- R09 transactional install is inventoried in `r09-codegen-transaction.md`, not implemented.
