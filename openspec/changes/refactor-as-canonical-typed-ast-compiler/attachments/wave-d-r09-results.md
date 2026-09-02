# Wave D R09 production routing results

Worktree: `D:\as-cta`. Do not mark `tasks.md` 9.1 / 9.5 / 13.6 / 10.4.

| Prefix | Label | Result |
| --- | --- | --- |
| ProductionCodeGen | r09-prod-ready | **3/3** PASS |
| Cutover | r09-cutover-green | **5/5** PASS |
| Differential | r09-differential-publisher | **2/2** PASS |

Logs: `{SCRATCH}/production-codegen.log`, `{SCRATCH}/cutover.log`, `{SCRATCH}/differential.log`.

## What is true

- CANONICAL `asCModule::Build()` calls `asCBytecodeCodeGen::Generate()` after parse+seal. No `BuildCompileCode` on that path.
- Integer `int F() { return 7; }` executes 7 with publisher `CANONICAL_CODEGEN`.
- Script value objects fail closed (not silent `asCCompiler`).
- LEGACY `Build()` still publishes `COMPILER`.
- `CompileFunction` still `COMPILER`.
- Default pipeline LEGACY. `Ready()` true because CANONICAL `Build()` calls `Generate()`.

## What is not true

- 9.5 full-language CodeGen
- Fully detached install (engine function slots still reserved during emit)
- Default CANONICAL (Wave G)
- 13.2 / 13.3 close
