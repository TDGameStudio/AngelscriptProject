# Next work — after review Request changes

Worktree: `D:\as-cta`. Specs stay the complete cutover. Do not archive. Do not re-check section 10 from All-suite green.

Companion: `record-reconciliation.md` (why it drifted), `reviews/implementation-review-2026-08-21.md` (gates), `tasks.md` sections 10 and 13 (reopened items), **`attachments/async-work.md` (current 梳理 + async packages, 2026-08-22 after construct-init: SemaAuthority 250/250, CanonicalAST 321/321, Compiler 511/511)**. Next exclusive UBT is Wave B **B-packed-exec** (`attachments/wave-b-packed-exec-next.md`), **not** Wave G. Construct-init landed; packed execute 1934 OPEN. SemaAuthority **250/250** is not 13.2.

> **Third-pass rereview (2026-08-21):** still **Request changes**. R11 teardown AV is **closed** (CodeGen 24/24). The B→C→D→E→F→G spine is still correct. Do not mark 13.2 / 5.9 / section 10 from CanonicalAST greens or SemaAuthority **25/25**. Do not archive. Do not restore default CANONICAL.

> **Current implement order:** Live exclusive UBT is **B-packed-exec** (`attachments/wave-b-packed-exec-next.md`). Do **not** start Wave E/F/G. Dual-repo. Commands only from `D:\as-cta`. Only one UBT user. Live 梳理: `attachments/async-work.md`.

**Goal of the remaining change:** sealed AST is the semantic and Bytecode authority. The scaffold stays; the false cutover does not.

**Architecture now:** two pipeline values remain (`LEGACY=0`, `CANONICAL=1`). Default production is **LEGACY**. CANONICAL module `Build()` publishes from `asCBytecodeCodeGen::Generate()`. `IsCanonicalBytecodeCodeGenReady()` is true as that binary capability. Script value objects fail closed on CANONICAL. `CompileFunction` still uses `asCCompiler`. Every successful compile records an observable publisher. No third dual-compiler enum.

**Tech stack:** maintained fork under `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source`, Native SDK tests under `AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/`, Standalone CTest `AngelscriptStandaloneCanonicalASTTests.cpp`.

## Global constraints

- No Unreal types in `as_ast_*`, `as_sema*`, `as_bytecode_codegen`, `as_source_manager`.
- No Clang/LLVM link.
- Do not default `canonicalCompilerPipeline` to true until Wave G.
- Do not treat Compiler/Cache/StaticJIT/All prefix counts as cutover evidence.
- Keep `asCCompiler` until Wave D actually replaces it; do not rewrite tasks to call that “done”.
- Do not insert more virtuals into the middle of `asIScriptModule` (Wave E will move the ones already there).

---

## Problem (what later work is correcting)

Current production path:

```text
Parser → asCScriptNode → asCBuilder/asCCompiler → VM Bytecode
                 └─ optional Sema walk → incomplete AST (shadow)
```

Required path (`design.md` / specs):

```text
SourceManager → Parser Sema actions → sealed AST
  → asCBytecodeCodeGen / TypedASTJIT / Cache DTO / public snapshot
```

The 2026-08-21 cutover flipped `ep.canonicalCompilerPipeline` and `IsCanonicalBytecodeCodeGenReady()` without moving `Build()` onto `Generate()`. Tests asserted the flag. Tasks 10.4–10.7 were rewritten to lock leftovers. That is the 虚标. All 3632/3632 is compatibility of the old path.

## What not to do next

- Do not delete the scaffold to “start over”.
- Do not implement Sema, Cache DTOs, or production CodeGen *before* Wave A provenance. Later greens would still be attributed to the wrong backend.
- Do not add `asCOMPILER_PIPELINE_DUAL`.
- Do not keep the current default-canonical tests by changing task text again.
- Do not archive.

## Wave order

| Wave | Tasks | Why this order |
| --- | --- | --- |
| **A — honesty** | 13.1, 11.3 (docs only) | Flag/Ready/docs currently lie. Every later test is untrustworthy until publisher is visible. |
| **B — Sema + identity** | 13.2, 13.3, 2.6, 4.2–4.6, 5.2–5.9 | Without real Sema facts, CodeGen/JIT/Cache would freeze first-name/`int` graphs. |
| **C — arena + verifier** | 13.4, 13.5, 2.4, 2.8 | Seal must be a firewall before production consumers. |
| **D — production CodeGen** | 13.6, 9.1, 9.5–9.7, 10.4 | `Build()` calls `Generate()`; failure rolls back; subset grows to the active SDK surface. |
| **E — public snapshot** | 13.7, 13.8, 3.2, 3.4, 3.7, 11.4 | ABI and leases after the graph is real enough to publish. |
| **F — Cache + SourceManager** | 13.9, 13.10, 6.3, 6.4, 6.6, 2.2 | DTO and coordinates need complete nodes and types from B/C. |
| **G — cutover default** | 10.1–10.3, 10.5–10.7, 10.9, 13.11, 13.12, 11.3/11.4, 12.2, 12.4 | Default CANONICAL only after D. Then adversarial tests and All. |

Waves B–G stay in `tasks.md`. **Wave A is landed** (Cutover 5/5, publisher observable, Ready false, LEGACY default). **Wave B SemaAuthority is 77/77** and still not 13.2/5.9. **R11 is landed** (CodeGen 24/24). **2.4 / 13.4 / 2.8 / 13.5 / 2.6 are landed**. **Wave D Task 1 is landed** (Transaction 3/3). The next exclusive-UBT session is **Wave D isolated Tasks 2–5**, stop before production `Build()`. See `attachments/async-work.md`.

---

## Wave A — naming, Ready(), publisher, honest docs

### Files

- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_fwd.h`
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.h` (`IsCanonicalBytecodeCodeGenReady`, optional publisher query)
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.cpp` (`ep.canonicalCompilerPipeline = false`)
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_module.h` / `as_module.cpp` (record last Bytecode publisher per module)
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_compiler.cpp` (set publisher `COMPILER` when it publishes function Bytecode)
- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp` (`Generate` sets publisher `CANONICAL_CODEGEN`)
- Modify: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTCutoverTests.cpp`
- Modify: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalCompilerDifferentialTests.cpp` (Ready/default assertions)
- Modify: `Plugins/Angelscript/Standalone/Tests/AngelscriptStandaloneCanonicalASTTests.cpp`
- Modify: `Documents/Guides/AngelscriptCanonicalAST.md` and the ForkStrategy/Cache/StaticJIT sentences that claim production canonical Bytecode or HIR removal (task 11.3)

### Interfaces

Add to the maintained fork (not mid-vtable public SDK):

```cpp
enum asEBytecodePublisher
{
	asBYTECODE_PUBLISHER_NONE = 0,
	asBYTECODE_PUBLISHER_COMPILER = 1,
	asBYTECODE_PUBLISHER_CANONICAL_CODEGEN = 2,
};

// asCModule, test-visible via cast in Native SDK tests:
asEBytecodePublisher GetLastBytecodePublisher() const;

// asCScriptEngine:
bool IsCanonicalBytecodeCodeGenReady() const; // true only when Build/CompileFunction production path calls Generate()
```

`IsCanonicalBytecodeCodeGenReady()` in Wave A returns **false**. Do not invent a “ready” true that means “class exists”. After Wave D it returns true because builder actually calls `Generate()`.

Default:

```cpp
ep.canonicalCompilerPipeline = false; // LEGACY
```

`SetCompilerPipeline(CANONICAL)` still allowed: attach shadow AST, execute via `asCCompiler`, publisher must be `COMPILER` until Wave D.

### Task A1 — failing provenance tests

In `AngelscriptNativeCanonicalASTCutoverTests.cpp`:

- Rename/replace `DefaultPipelineIsCanonicalAndRejectsDual`:
  - new engines: `GetCompilerPipeline() == LEGACY`
  - `IsCanonicalBytecodeCodeGenReady() == false`
  - `SetCompilerPipeline((asECompilerPipeline)2) == false` and selection stays LEGACY
- Replace `CanonicalDefaultStillCompilesValueObjectsThroughInternalCompiler`:
  - default remains LEGACY
  - after `SetCompilerPipeline(CANONICAL)` and a successful value-object `Build()`, `GetLastBytecodePublisher() == COMPILER`
  - `IsCanonicalBytecodeCodeGenReady()` still false
- Add: isolated `asCBytecodeCodeGen.Generate` on a sealed subset AST sets publisher `CANONICAL_CODEGEN` (existing isolated CodeGen tests can record this)
- Add: a CANONICAL-selected Engine `Build()` of `int F() { return 7; }` executes **and** publisher is `COMPILER` (proves flag ≠ backend)
- Keep dual `#ifdef asCOMPILER_PIPELINE_DUAL` compile failure

Standalone `AngelscriptStandaloneCanonicalASTTests.cpp` must not require default CANONICAL or Ready() true. It may still `Build()` a script (legacy emitter) and reject dual.

### Task A2 — run tests red

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" -Label wave-a-provenance-red -TimeoutMs 600000
```

Expect: current defaults (`CANONICAL`, Ready true) fail the new assertions.

### Task A3 — implement default, Ready(), publisher

- Default pipeline LEGACY in `as_scriptengine.cpp`.
- `IsCanonicalBytecodeCodeGenReady()` returns false (Wave A). After Wave D, implement as “builder production compile used Generate for this engine/module policy”, not an unconditional true.
- On successful function Bytecode publication in `asCCompiler`, set module publisher `COMPILER`.
- On successful `asCBytecodeCodeGen::Generate`, set `CANONICAL_CODEGEN`.
- Do not route `Build()` through `Generate()` in Wave A.

### Task A4 — run tests green + Standalone CanonicalAST

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-a-provenance-green -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix wave-a-standalone -TimeoutMs 600000
```

Expect: Cutover/CanonicalAST SDK tests pass; Standalone still 21/21 after the default/Ready assertion change. If other tests assumed default CANONICAL, fix them to `SetCompilerPipeline(CANONICAL)` explicitly **without** asserting Ready() or CodeGen publisher.

### Task A5 — docs (11.3 honesty only)

Rewrite `Documents/Guides/AngelscriptCanonicalAST.md` (and the matching sentences in ForkStrategy / Cache / StaticJIT / Test.md) to:

- default pipeline is LEGACY
- CANONICAL attach is shadow/capture until Wave D
- Ready() is false
- full-language Bytecode is `asCCompiler`
- HIR oracles remain; capture stays off
- LLVM is a non-goal

Do not describe V1 size/version negotiation as implemented (that is Wave E / 11.4).

### Wave A done when

- Cutover tests fail if they claim default canonical Bytecode or Ready() true.
- A CANONICAL `Build()` reports publisher `COMPILER`.
- Isolated `Generate()` reports `CANONICAL_CODEGEN`.
- Standalone CTest matches the same story.
- Product docs no longer say new engines default to canonical Bytecode.
- `tasks.md` 13.1 stays `[ ]` until Wave D rereview (canonical `Build()` must publish CodeGen). 11.3 stays `[ ]` until ZH/Standalone leftover sentences match LEGACY default. Section 10 stays open.

---

## Wave A status

Landed in this worktree: LEGACY default, `Ready()` false, `GetLastBytecodePublisher()`, Cutover tests fail on flag-as-product, isolated `Generate()` is `CANONICAL_CODEGEN`, EN/ZH/Standalone notes are honest. **13.1 stays `[ ]`** until Wave D (canonical `Build()` must not publish `COMPILER`). **11.3 is `[x]`**.

## R11 — current implementation (do this next)

Isolated CodeGen can execute `Invoke(Double,3)+L(4) == 11` and then AVs in `asCObjectType::ReleaseAllFunctions` during `Engine.Destroy()` (`as_objecttype.cpp:723` ← dtor `:987`). Four lifecycle tests already exist. Do not expand CodeGen language coverage. Do not route production `Build()`. Details and failed experiments: `attachments/async-work.md` §3 and §6.

## Wave B status (dumps landed, authority not)

SemaAuthority **25/25**. Methods 23–25: enum kind on compile→seal (`ETeam::Red`), `T::F()` vs `T::F() const`, `kind=Index` (not yet `opIndex` callee). Parser incremental `NotifySema`, import route, list-pattern origin, generated accessors, `array<int>` type key (parse→seal), property get/set, reverse-formal children, destructor callee, namespace/`opAdd`/default-arg/continue/break are dump-green.

**13.2 / 5.9 / 4.x stay `[ ]`.** Sema is still a conversion over `asCScriptNode`. Production Bytecode is still `asCCompiler`. Hidden args, index single-eval, fallthrough target, 4.6 shadow mismatch, and complete StaticJIT identity remain.

Do not re-diagnose attach/FinishDecl/`float`→`double`; those are fixed.

Wave C arena/stmt-id already started; **do not grow the verifier** until R11 is green. Do not re-add CALL-without-callee as a seal firewall.

## Later waves

R11, Wave C 2.4/2.6/2.8/13.4/13.5, and Wave D isolated Task 1 are green. Do not re-open them.

**Wave D remainder** — detached CodeGen artifact then isolated FuncPtr/retry (plan Tasks 2–5). Production `BuildCompileCode()` replacement is Tasks 6+ and is **gated** on Sema dump remainder + isolated transaction. Then Ready() can become true. Cutover tests must fail if `asCCompiler` still published that module. Do not mark 9.1/13.6 from Task 1.

**Wave E** — move the three AST methods off the mid-vtable; honor `structSize`; atomic snapshot publish/Acquire; generation holds `asIASTSnapshot`.

**Wave F** — real ASTBodySidecar DTO + ExactStartup; SourceManager owns diagnostics.

**Wave G** — default CANONICAL, 10.x, adversarial matrix, All suite as *CodeGen* evidence.

## Verification cheat sheet

Always from `D:\as-cta`:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label <label> -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "<prefix>" -Label <label> -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix <label> -TimeoutMs 600000
```

Wave A prefix: `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover` then `...CanonicalAST`. Do not run All as a Wave A gate.