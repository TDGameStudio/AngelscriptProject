# Wave D 9.5 — F2 mixed publisher (Build CodeGen, CompileFunction COMPILER)

Worktree: `D:\as-cta`. Read-only package **D-95-f2-next**.
Do **not** edit `Plugins/`, tests, `tasks.md`, specs, proposal, or `design.md`.
Do **not** run UBT / `RunBuild` / `RunTests`.
Do **not** implement CANONICAL `CompileFunction`.
Do **not** check `tasks.md` 10.1 / 10.3 / 10.4 / 13.1 (or 9.5 / 9.1 / 13.6 / 10.2).

Fifth-pass F2 (`reviews/implementation-rereview-2026-08-22-fifth-pass.md`): CANONICAL module `Build()` already routes to CodeGen, but public `CompileFunction()` still uses legacy `asCBuilder` / `asCCompiler`, and Cutover tests **accept** that mixed publisher. That is a product/spec conflict, not a silent implement-now bug.

`attachments/async-work.md` §5 F2 row: research yes, implement no. Document; do not silently make `CompileFunction` CANONICAL.

---

## Live fact (quote, not fifth-pass line numbers)

Fifth-pass cited `as_module.cpp:1930-1981`. Live public `CompileFunction` is **1946–2011**. CANONICAL `Build()` branch is **397–445**.

### CANONICAL `Build()` already calls CodeGen

`Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_module.cpp` 397–415:

```text
if( engine->GetCompilerPipeline() == asCOMPILER_PIPELINE_CANONICAL )
{
    ...
    r = codegen.Generate(*pending, this);
```

Success path skips `BuildGenerateTypes` / `BuildGenerateFunctions` / `BuildLayout*` / `BuildCompileCode` (those remain the LEGACY arm at 446–457). `asCBytecodeCodeGen::Commit` sets `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` (`as_bytecode_codegen.cpp` 2208).

### Public `CompileFunction()` has no CANONICAL branch

`as_module.cpp` 1980–1993 still always:

```text
asCBuilder funcBuilder(engine, this);
...
r = funcBuilder.CompileFunction(sectionName, str.AddressOf(), lineOffset, compileFlags, &func);
```

`asCBuilder::CompileFunction` (`as_builder.cpp` 1058–1225) may `AttachCanonicalSemaIfNeeded()`, then parses one `snFunction` node and, unless artifact restore hits, constructs `asCCompiler` and calls `compiler.CompileFunction(...)` (`as_builder.cpp` 1182–1185). `asCCompiler` then stamps the **module** last publisher:

```text
builder->module->SetLastBytecodePublisher(asBYTECODE_PUBLISHER_COMPILER);
```

(`as_compiler.cpp` 3280–3283.) There is no `Generate()` on this path.

Consequence: a CANONICAL-selected Engine can `Build()` a module as `CANONICAL_CODEGEN`, then `CompileFunction(asCOMP_ADD_TO_MODULE)` appends a live function whose Bytecode is `COMPILER`. After that append, `GetLastBytecodePublisher()` is **COMPILER** (module-level last stamp), even if the original `Build()` functions still came from CodeGen. `CompileFunction` also does not republish a complete retained snapshot (Cutover already locks the old generation key).

The Cutover “single-function compile” purpose never even `Build()`s: it `GetModule(..., asGM_ALWAYS_CREATE)` then only `CompileFunction`. A CANONICAL-selected Engine can therefore own a module whose **only** publisher is COMPILER.

---

## Live Cutover assertion that accepts the mix

File: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTCutoverTests.cpp`

Prefix: `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover`

`SourceBuildPurposesSelectCanonicalAndExecute` (lines 138–173) sets `bModuleBuild = false` only for `"single-function compile"` / `SingleFnCutover`. After each purpose runs, it asserts:

```cpp
ASSERT_THAT(AreEqual(
    Purpose.bModuleBuild
        ? asBYTECODE_PUBLISHER_CANONICAL_CODEGEN
        : asBYTECODE_PUBLISHER_COMPILER,
    Concrete->GetLastBytecodePublisher(),
    *FString::Printf(
        TEXT("%hs CANONICAL module Build must record CodeGen; CompileFunction stays Compiler"),
        Purpose.Name)));
```

That message is the live contract: **module Build = CodeGen, `CompileFunction` = Compiler**. Green Cutover **5/5** proves the tests match this mix. It does not close 10.1 / 10.3 / 10.4 / 13.1.

`CompileFunctionDoesNotReplaceRetainedModuleSnapshot` (229–273) asserts `CANONICAL_CODEGEN` **after `Build()` and before `CompileFunction`**. The assertion message also says “CompileFunction extra stays Compiler”, but the test never re-reads `GetLastBytecodePublisher()` after the extra. After extra, the stamp is COMPILER (`as_compiler.cpp` 3282). The test only locks snapshot generation key unchanged — 10.3’s “stale/incomplete snapshot is current” hole, not a CodeGen append.

`CommandletLike` / `StandaloneLike` (and Hot Reload / generation) are same-process native helpers that call `CompileNativeModule` + execute. They are not commandlet, Standalone frontend, HotReload, or generation host paths. They remain helper aliases.

---

## Four OpenSpec tasks this mix currently fails

Keep every box `[ ]`. Do **not** shrink these texts in `tasks.md` this wave. Quote of why they fail today:

### 10.1 (cutover matrix)

> Add a cutover test matrix proving canonical Parser/Sema/Bytecode is selected for **every source build purpose** (primary, Hot Reload, **single-function compile**, generation, commandlet, Standalone) and that no production `dual` selection is registered.

Why still open (live `tasks.md`): Cutover asserts pipeline CANONICAL, `Ready() == true`, and execute. Integer `F()` / value-object assert `CANONICAL_CODEGEN`. Dual enum rejection is real. **`CompileFunction` is still `COMPILER`.** Commandlet/Standalone/HotReload cases are native-helper aliases, not host paths. Selection-without-full-language is not 10.1 close.

### 10.3 (attach for Build **and** CompileFunction)

> Attach Parser+Sema canonical actions for module `Build()` **and public `CompileFunction`**. `CompileFunction` must not replace a retained module snapshot unless a documented complete-snapshot policy republishes one.

Why still open: attach is a post-parse walk. `CompileFunction` tests lock “generation key unchanged” without checking that the snapshot contains the new function. Parser nodes remain the semantic input. Public `CompileFunction` still emits via `asCCompiler`.

### 10.4 (one publisher on a canonical-selected Engine)

> Production Bytecode for a **canonical-selected Engine SHALL be published by `asCBytecodeCodeGen`** from the same sealed AST. Sema/AST/CodeGen sources must not include `as_compiler.h`.

Why still open: CANONICAL `Build()` now calls `Generate()` for a language **slice** (not 9.5). Public `CompileFunction` on that same Engine still publishes COMPILER. Integer/subset routing is not full-language production CodeGen.

### 13.1 (provenance)

> Production selection must not claim canonical Bytecode while `asCCompiler` emits it. … **Cutover tests fail if `asCCompiler` is invoked for a canonical-selected Engine** and must show `asCBytecodeCodeGen` published the Bytecode from the same sealed snapshot.

Why still open (`tasks.md` 13.1 progress): CANONICAL module `Build()` calls `Generate()`; integer `F()` is `CANONICAL_CODEGEN`; **`CompileFunction` stays `COMPILER`**; default pipeline LEGACY; `Ready()` is a binary capability. **Still `[ ]`**: 9.5 remainder **and CompileFunction provenance**. Cutover currently **must pass** when `asCCompiler` is invoked on a CANONICAL Engine (`single-function compile`). That is the opposite of 13.1’s test sentence.

Related later work, not this brief’s implement list: 13.8 still requires a **documented CompileFunction completeness** policy. Today’s retain test encodes “stale generation stays current”.

---

## One later product choice (recommend 1)

Do not pick 2 or 3 in this change until 9.5 is honest. Exclusive UBT this wave is imports (`CALLBND`), not `as_builder.cpp` CompileFunction routing. Making `CompileFunction` CANONICAL would compete with import/lifecycle for CodeGen files and needs a sealed incremental attach + snapshot completeness policy that does not exist.

### 1. Keep mixed — **recommended until 9.5 is honest**

Treat public `CompileFunction` as **LEGACY append** on a module that may already have been CANONICAL-`Build()`’d (or as the sole publisher when the purpose never `Build()`s).

- Document that honesty in this attachment and in later Cutover comments. Do **not** rewrite 10.1 / 10.3 / 10.4 / 13.1 down to “Ready true + Build CodeGen”.
- Keep those four tasks `[ ]`. Green Cutover 5/5 is the mixed contract, not their close.
- Do not implement CANONICAL `CompileFunction` this UBT.
- `Ready() == true` remains “CANONICAL `Build()` calls `Generate()`”, not “every public compile on a CANONICAL Engine is CodeGen”.

Trade-off: tests stay green while the OpenSpec cutover sentence stays unmet. That is acceptable **only** as an explicit interim, with the four boxes open. Silent check-off would be 虚标.

If the product later wants this mix **permanently**, that is a spec/proposal/design/tasks revision (capability name + provenance for LEGACY append). Not this wave, and not a local test-message edit.

### 2. Make `CompileFunction` CANONICAL — later, not this UBT

Requires:

- Sealed incremental attach of the extra function into the module AST (not a second `asCCompiler` walk of `snFunction`).
- `asCBytecodeCodeGen` publish for that function (or a documented whole-module re-Generate).
- Snapshot completeness policy (13.8 / 10.3): either republish a **complete** sealed snapshot that includes Extra, or refuse `asCOMP_ADD_TO_MODULE` under `asAST_RETAIN_SNAPSHOT` until merge exists. Do not keep “stale generation is current” as success.
- Detached install / no Engine slot reservation during emit (9.1) is still a separate gate; do not pretend CompileFunction CodeGen closes 9.1.

Trade-off: this is the spec meaning of 10.1 / 10.3 / 10.4 / 13.1. It is real compiler work, not a publisher-enum flip. It will collide with the import/lifecycle exclusive UBT on `as_bytecode_codegen.cpp` / builder routing.

### 3. Reject `CompileFunction` on CANONICAL engines — also a spec change

Fail-closed: canonical-selected Engine (or CANONICAL-built module) returns an error from public `CompileFunction` and does not append. No silent COMPILER Bytecode.

Trade-off: honest provenance, but it **narrows** the public API for CANONICAL engines. Specs/tasks today require CompileFunction to **use** canonical Parser/Sema/Bytecode, not to forbid the API. Option 3 needs an explicit OpenSpec overturn (and embedding migration notes). Not silent.

---

## Later RED/GREEN tests (do **not** add now)

Prefix stays `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover`.
File: `AngelscriptNativeCanonicalASTCutoverTests.cpp`.
Do not add ProductionCodeGen methods for F2. Do not flip default CANONICAL.

### If option 2 is chosen later

1. **Change** `SourceBuildPurposesSelectCanonicalAndExecute` so `"single-function compile"` expects `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, not `COMPILER`. Drop or rewrite the message `CANONICAL module Build must record CodeGen; CompileFunction stays Compiler`. **Today this is RED** (live `SingleFn` path stamps COMPILER).

2. **Add** `CompileFunctionAfterCanonicalBuildPublishesCodeGen` (name may vary; keep this intent):
   - Select `asCOMPILER_PIPELINE_CANONICAL`.
   - `Build()` `int F() { return 1; }` → publisher `CANONICAL_CODEGEN`, execute 1.
   - `CompileFunction(..., "int Extra() { return 11; }", ..., asCOMP_ADD_TO_MODULE, ...)`.
   - Extra executes 11.
   - **After Extra**, `GetLastBytecodePublisher() == asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` (today RED: COMPILER overwrite).
   - GREEN only if Extra Bytecode came from CodeGen on a sealed attach, not from `asCCompiler`.

3. **Replace** the success contract of `CompileFunctionDoesNotReplaceRetainedModuleSnapshot` with the documented completeness policy:
   - Either Extra appears in the retained current snapshot (new generation after successful complete republish), **or** `asCOMP_ADD_TO_MODULE` is refused while `asAST_RETAIN_SNAPSHOT` is set.
   - Today GREEN on “generation key unchanged” is the **wrong** bar for option 2.

Option 2 is not GREEN until (1)+(2) pass and (3) matches the written policy. Do not mark 10.1/10.3/10.4/13.1 from (1) alone if Commandlet/Standalone remain helper aliases, or if 9.5 is still a slice.

### If option 3 is chosen later (after spec overturn)

**Add** `CanonicalEngineRejectsPublicCompileFunction`:

- Select CANONICAL, `Build()` `int F() { return 1; }`, publisher `CANONICAL_CODEGEN`.
- `CompileFunction(..., "int Extra() { return 11; }", ..., asCOMP_ADD_TO_MODULE, &Extra)` returns `< 0`, `Extra == nullptr`.
- `GetFunctionByDecl("int Extra()")` is null; `int F()` still executes 1.
- Publisher remains `CANONICAL_CODEGEN`.
- Retained snapshot generation key unchanged **and** Extra is absent from the snapshot.

Then **change** `SourceBuildPurposesSelectCanonicalAndExecute` so the `"single-function compile"` purpose is either removed or rewritten as this rejection (it must not execute Extra == 11 via COMPILER). `CompileFunctionDoesNotReplaceRetainedModuleSnapshot` must not require Extra to execute.

Today both option-2 and option-3 tests would be RED against live Cutover. That is the point of later TDD. **Do not add them in this wave.**

---

## What this wave must not do

- Implement option 2 or 3.
- Check 10.1 / 10.3 / 10.4 / 13.1.
- Shrink those tasks to “Build-only CodeGen”.
- Treat Cutover 5/5, ProductionCodeGen 16/16, or `Ready() == true` as F2 closure.
- Flip default `canonicalCompilerPipeline` / Wave G because F2 exists. **F2 is not a reason to flip default CANONICAL.** Default stays LEGACY until 9.5/9.7 and rereview (task 10.2).
- Treat `CommandletLike` / `StandaloneLike` as host-path evidence. They remain helper aliases.

F2 stays open as mixed authority, documented here, until a later explicit product choice (keep mixed with a spec revision, or option 2, or option 3).
