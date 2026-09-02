# Waves C–G file map (ready to execute)

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Fork root: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source`.
Public header: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h`.
Do **not** start C–G implementation until Wave B `SemaAuthority` is green. Wave B is writing Sema files in this same worktree.

This attachment is the implementer map. Do not edit production code from this package. Do not rewrite remaining `tasks.md` boxes down. Do not archive. Do not default `canonicalCompilerPipeline` until Wave G. Dual-repo: plugin submodule first.

Commands always from `D:\as-cta`. Only `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1`. `ProjectFile` comes from `AgentConfig.ini`. No Unreal types in `as_ast_*` / `as_sema*` / `as_bytecode_codegen` / `as_source_manager`. No Clang/LLVM. No new virtuals in the middle of `asIScriptModule`.

Wave order after B is green: **C → D sequential**. After D, **E and F may overlap only if they obey the split below**. **G last**.

---

## Hard gate (read before any C–G edit)

Wave B must already have:

- `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` **2/2**
- dumps with `key=F(int)` / `callee=F(int)` / `kind=Conversion` (not first-name / `int`)
- Cutover provenance still honest: LEGACY default, `Ready()` false, CANONICAL `Build()` publisher `COMPILER`
- record in `attachments/wave-b-results.md`

If that prefix is still red, **stop**. Do not start arena, CodeGen routing, vtable, Cache DTO, or default-CANONICAL work.

Confirm B before C:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-c-preflight-sema -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" -Label wave-c-preflight-cutover -TimeoutMs 600000
```

---

## Shared-file collision matrix

`W` = this wave writes the file. `R` = reads / must not regress. Blank = leave it.

| File | B (running) | C | D | E | F | G |
| --- | --- | --- | --- | --- | --- | --- |
| `as_sema.cpp` / `as_sema.h` / `as_sema_decl.*` / `as_sema_expr.*` / `as_sema_stmt.*` / `as_sema_lifetime.*` | **W** | R | R | | | R |
| `as_ast_type.cpp` / `as_ast_type.h` | **W** | **W after B** | R | | R | |
| `as_runtime_type_bridge.*` / `as_ast_dump.cpp` | **W** | | R | | R | |
| `as_ast_context.h` / `as_ast_context.cpp` | maybe intern | **W** | R | R const | R | |
| `as_decl.h` / `as_stmt.h` / `as_expr.h` | | **W** | R | R | R | |
| `as_ast_verifier.cpp` / `as_ast_verifier.h` / `as_ast_kind.h` | | **W** | R | | R | |
| `as_ast_arena.h` / `as_ast_arena.cpp` (new) | | **W** | R | R | R | |
| `as_ast_public_view.h` / `as_ast_public_view.cpp` | | **W** `GetContext` const | | **W** fill/atomic | **W** ranges | |
| `as_bytecode_codegen.cpp` / `as_bytecode_codegen.h` | | | **W** | | | R |
| `as_builder.cpp` / `as_builder.h` | attach | | **W** compile routing | CompileFunction policy only via module API | **W** `WriteError*` / `WriteInfo*` | R |
| `as_module.cpp` / `as_module.h` | snapshot fabricate | | **W** `Build()` / publisher | **W** Acquire/publish/atomic | call E’s install API only | R |
| `Core/angelscript.h` | | | | **W** | view fields if E left them | 11.4 notes |
| `as_ast_fwd.h` | publisher enums | | Ready comment | | | pipeline default notes |
| `as_scriptengine.h` / `as_scriptengine.cpp` | | | **W** `Ready()` | | | **W** default CANONICAL |
| `as_compiler.cpp` | | | LEGACY publisher only | | **W** diagnostics coords | 10.5/10.6 removal |
| `as_parser.cpp` / `as_scriptcode.cpp` | ActOnParsedScript | | | | **W** diagnostics | 10.6 recovery-only |
| `as_source_manager.cpp` / `as_source_manager.h` | | | | | **W** | |
| `as_ast_sidecar.cpp` / `as_ast_sidecar.h` | keys | | | | **W** | |
| `Cache/AngelscriptCacheASTBodySidecar.*` / `AngelscriptCacheExactStartup.cpp` / `AngelscriptCacheRestore.cpp` | | | | | **W** | |
| `StaticJIT/AngelscriptStaticJITGenerationSnapshot.cpp` / `.h` | **W** identity | | | **W** `asIASTSnapshot` lease | | |
| `Standalone/CMakeLists.txt` + `AngelscriptStandaloneArchitectureTests.cpp` | | **W** arena TU | | | | |
| Cutover / Context / Verifier / CodeGen / Snapshot / Cache sidecar tests | B SemaAuthority | **W** | **W** | **W** | **W** | **W** |

### Collision rules (non-negotiable)

1. **`as_module.cpp` is single-writer per wave.** D writes `Build()` / `SetLastBytecodePublisher` / stop fabricating empty TU snapshots from the production CodeGen path. E then rewrites `AcquireASTSnapshot` / `PublishCanonicalASTSnapshot` / `ReleaseCanonicalASTSnapshot` and adds one atomic install entry that F may **call**. F must not rewrite Acquire/publish. G must not rewrite `as_module.cpp` unless a D/E rereview left a documented hole.
2. **`as_builder.cpp` is D then F.** D owns `BuildCompileCode` / `CompileFunctions` / factories / `CompileFunction` routing onto `Generate()`. F only changes diagnostic helpers (`WriteError` / `WriteWarning` / `WriteInfo` near the file end) and Parser/SourceManager wiring. Do not run D and F writers together.
3. **`as_ast_context.*` is C-owned.** D/E/F consume the sealed const API. Do not start D until C’s arena/seal rereview is green.
4. **`as_ast_public_view.*` is C then E then F.** C makes `GetContext()` const and removes public reseal. E owns `structSize` / `apiVersion` / atomic `currentGeneration` / ID generation. F adds source-range/child fields only if E already reserved them in `Core/angelscript.h`.
5. **`Core/angelscript.h` is E-owned.** No other wave inserts virtuals.
6. **`as_ast_type.*` and `AngelscriptStaticJITGenerationSnapshot.cpp` are B-owned until B is green.** C then extends `asASTQualifiersAreValid`. E then replaces `SealedAST` raw pointer with an `asIASTSnapshot` lease.
7. **Wave G does not share writers with C–F.** G flips the default, expands adversarial tests, and runs All as CodeGen evidence.

Hottest collisions: `as_module.cpp`, `as_builder.cpp`, `as_ast_context.h/.cpp`, `Core/angelscript.h`.

---

## Path aliases

| Alias | Absolute / repo path |
| --- | --- |
| `Fork/` | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/` |
| `Public/` | `Plugins/Angelscript/Source/AngelscriptRuntime/Core/` |
| `Cache/` | `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/` |
| `StaticJIT/` | `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/` |
| `SDK/CanonicalAST/` | `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/` |
| `SDK/FrontendAST/` | `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/` |
| `SDK/Module/` | `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Module/` |
| `Test/Cache/` | `Plugins/Angelscript/Source/AngelscriptTest/Cache/` |
| `Test/HotReload/` | `Plugins/Angelscript/Source/AngelscriptTest/HotReload/` |
| `Standalone/` | `Plugins/Angelscript/Standalone/` |

---

## Wave C — arena / slab, sealed const traversal, verifier firewall

**Tasks:** 13.4, 13.5, 2.4, 2.8. Review **R07, R08**.

**Do not:** route `Build()` through `Generate()`; set `Ready()` true; default CANONICAL; move vtable; implement Cache DTO; rewrite Sema.

### Current wrong functions / behavior

| Location | Function | What is wrong |
| --- | --- | --- |
| `Fork/as_ast_context.cpp:17` | `asCASTContext::DestroyAll` | Public. Per-node `asDELETE`. Sets `sealed = false` so a sealed graph can be resurrected. |
| `Fork/as_ast_context.cpp:73,106,125,162` | `CreateDecl` / `CreateStmt` / `CreateExpr` / `InternType` | Each node is `asNEW` (independent heap), forbidden by `design.md` arena/batch lifetime. |
| `Fork/as_ast_context.h:18,29-34,51` | `GetSourceManager()` non-const; non-const `GetDecl`/`GetStmt`/`GetExpr`; public `DestroyAll` | Sealing only blocks `Create*`. Direct field/child/type/range mutation remains. Snapshot surfaces can reach a mutable context. |
| `Fork/as_ast_public_view.h:28` | `asCASTSnapshot::GetContext()` | Returns `asCASTContext*` (mutable) to backends/snapshots. |
| `Fork/as_ast_verifier.cpp:13` | `asCASTVerify` | Table hygiene only: dangling parent/child IDs, invalid kinds, coarse break/continue/switch duplicates. Does **not** check stmt/expr id vs table index, operand kinds, bidirectional owner/body, cycles, multiple owners, ancestor/nearest-control-target, return/fallthrough/switch order, mandatory exact types/value categories, resolved signature compatibility, cleanup/live-value plans, sealed publication invariants. |
| `Fork/as_ast_type.cpp:5` | `asASTQualifiersAreValid` | Accepts any direction mask in `{0, IN, OUT, INOUT}`. Does not reject unknown bits, direction-without-reference, auto-handle-without-handle, illegal void qualifiers. |
| `SDK/FrontendAST/AngelscriptNativeCanonicalASTContextTests.cpp:18` | `ArenaOwnershipSealAndForeignIds` | Named “arena” but only checks allocation + empty second context + `Create*` after seal. Never inspects slab/bump ownership. |
| `SDK/FrontendAST/AngelscriptNativeCanonicalASTContextTests.cpp:38` | `BulkDestructionClearsTables` | Calls public `DestroyAll` and treats reseal-from-empty as success. |

`asCASTContext::Seal` (`as_ast_context.cpp:285`) already calls `asCASTVerify` before setting `sealed`. That is the right hook — the verifier body is the gap.

### Files to create

- `Fork/as_ast_arena.h`
- `Fork/as_ast_arena.cpp` — bump/slab allocator owned by `asCASTContext`. Placement-new nodes. Batch release in context destructor. No per-node `asNEW`/`asDELETE`. No Unreal types.
- `SDK/FrontendAST/AngelscriptNativeCanonicalASTArenaTests.cpp` — inspect allocator: many nodes, one owner slab, foreign context does not free creator’s bytes, destructor batch-frees, no public reseal.

### Files to modify

- `Fork/as_ast_context.h` / `as_ast_context.cpp`
  - Store nodes in the arena. Pointer tables may remain 1-based IDs into arena memory.
  - Construction APIs stay on the **unsealed** context: `CreateTranslationUnit` / `CreateDecl` / `CreateStmt` / `CreateExpr` / `Intern*` / `AddDeclChild` / `SetBody` / `SetTarget` (unsealed only).
  - Remove public `DestroyAll`. Destructor is the only batch teardown. Do not clear `sealed` except by destroying the context.
  - After seal, only const accessors: `const asCDecl* GetDecl(...) const` and the stmt/expr/type equivalents. Delete or private the non-const overloads. `asCSema` gets a friend or an `asCASTUnsealedBuilder` handle.
  - `GetSourceManager()` non-const is construction-only; sealed/snapshot path uses const.
- `Fork/as_decl.h` / `as_stmt.h` / `as_expr.h` — fields stay POD for arena placement-new, but backends must not write them. No public mutators. Tests that currently do `Context.GetDecl(id)->children.PushLast(...)` must switch to unsealed `AddDeclChild`.
- `Fork/as_ast_verifier.h` / `as_ast_verifier.cpp` / `Fork/as_ast_kind.h` — extend `asEASTVerifyCategory` if a new stable category is required; keep existing tokens. Cover every R08 bullet. Seal must fail closed; no consumer (CodeGen, snapshot, sidecar, JIT) may see an incomplete graph.
- `Fork/as_ast_type.cpp` / `as_ast_type.h` — **after B**. Tighten `asASTQualifiersAreValid`. `InternType` already calls it (`as_ast_context.cpp:141`); verifier must call it on every QualType.
- `Fork/as_ast_public_view.h` — `const asCASTContext* GetContext() const` only. No mutable Context on snapshot surfaces.
- `Standalone/CMakeLists.txt` — add `as_ast_arena.cpp` to `ANGELSCRIPT_MAINTAINED_FORK_SOURCES`.
- `Standalone/Tests/AngelscriptStandaloneArchitectureTests.cpp` — add `"as_ast_arena.cpp"` to the maintained-source list (~line 233).

### Files to test (modify existing)

- `SDK/FrontendAST/AngelscriptNativeCanonicalASTContextTests.cpp` — drop public `DestroyAll` test; assert post-seal const traversal; foreign IDs still fail; `Create*` after seal still fails.
- `SDK/FrontendAST/AngelscriptNativeCanonicalASTVerifierTests.cpp` — add firewall cases: stmt/expr index mismatch, operand wrong kind, parent/child not bidirectional, cycle, two owners, break target not ancestor, skipped nearer loop, switch fallthrough order, missing expr type/value category, resolved decl kind/signature mismatch, missing cleanup plan on a live temporary, unsealed publication.
- `SDK/FrontendAST/AngelscriptNativeCanonicalASTTypeTests.cpp` — currently `BadDir = InternPrimitive(ttInt, asAST_QUAL_IN)` expects **valid**. After C, direction-without-reference must fail. Unknown bits, auto-handle-without-handle, `void` + handle/reference must fail.
- `SDK/FrontendAST/AngelscriptNativeCanonicalASTDumpTests.cpp` — dumps stay address-free and deterministic after arena move.

### Interfaces later waves rely on

- Sealed `const asCASTContext&` is the only CodeGen/JIT/Cache/public input (Wave D `Generate`, Wave E snapshot, Wave F DTO).
- `asCASTVerify` is a real firewall: D/E/F may not “best-effort” skip it.
- Arena lifetime: snapshot destructor frees the slab; Acquire leases keep that slab alive (Wave E).
- QualType intern rejects illegal qualifier combinations so Cache remap cannot rehydrate them.

### Verification (from `D:\as-cta`)

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label wave-c-arena-verifier -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Context" -Label wave-c-context -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Verifier" -Label wave-c-verifier -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Type" -Label wave-c-type -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" -Label wave-c-frontend-canonical -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" -Label wave-c-cutover-honest -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix wave-c-standalone -TimeoutMs 600000
```

Force a full Runtime rebuild if UBT adaptive-skips (Wave A already hit stale DLLs). Cutover must stay 5/5 with publisher `COMPILER` and `Ready()` false.

### Stay `[ ]` until C rereview

Keep **13.4, 13.5, 2.4, 2.8** unchecked until:

- nodes are slab/bump-owned (test inspects strategy, not just `OwnsDecl`)
- no public `DestroyAll` reseal
- snapshot/backend surfaces have no mutable `asCASTContext*`
- verifier rejects the R08 incomplete-graph cases and `Seal()` fails before any consumer

Do **not** check 9.x / 10.x / 13.6+ from a green Frontend prefix.

### Wave C collision warning

Writes `as_ast_context.*` (also consumed by D/E/F), `as_ast_public_view.h` (E/F), `as_ast_type.*` (B then C), `as_ast_verifier.*`. Does not write `as_module.cpp` / `as_builder.cpp` / `Core/angelscript.h`.

---

## Wave D — production `Build()` → `Generate()`, transactional install, Ready may become true

**Tasks:** 13.6, 9.1, 9.5–9.7, 10.4. Review **R01 leftover + R09**. 13.1’s rereview gate is also this wave.

**Blocked on:** Wave C rereview green (CodeGen must consume a sealed const graph). Wave B Sema facts must already be in that graph.

**Do not:** default `canonicalCompilerPipeline` to true (Wave G). Do not rewrite 10.5–10.7 as “locks”. Do not treat Compiler 203/203 as CodeGen evidence.

### Current wrong functions / behavior

| Location | Function | What is wrong |
| --- | --- | --- |
| `Fork/as_module.cpp:394-406` | `asCModule::Build` | Production path is `builder->BuildCompileCode()` then `AdoptPendingCanonicalAST`. Never calls `asCBytecodeCodeGen::Generate`. |
| `Fork/as_builder.cpp:863` | `asCBuilder::BuildCompileCode` | Instantiates `asCCompiler` for factories (`:885`). |
| `Fork/as_builder.cpp:1508` | `asCBuilder::CompileFunctions` | Instantiates `asCCompiler` for functions/ctors/dtors/`__InitDefaults` (`:1563`, `:1595`, `:1614`, `:1632`). |
| `Fork/as_builder.cpp:1015` | `asCBuilder::CompileFunction` | Public `CompileFunction` still `asCCompiler` (`:1135`). Leave **snapshot completeness** to E; D must not claim Ready while *module Build* still uses Compiler. |
| `Fork/as_builder.cpp:3056` / `:3267` | `RegisterGlobalVariables` / other `asCCompiler` sites | Global init and generated bodies still Compiler. |
| `Fork/as_bytecode_codegen.cpp:1362` | `asCBytecodeCodeGen::Generate` | Test-only production caller. Isolated tests call it; `Build()` does not. |
| `Fork/as_bytecode_codegen.cpp:1409` | `module->AddFuncDef` | Mutates live module before emission succeeds. |
| `Fork/as_bytecode_codegen.cpp:1426` | `module->AllocateGlobalProperty` | Same: globals stick on later `asNOT_SUPPORTED` / OOM. |
| `Fork/as_bytecode_codegen.cpp:1447-1476` | `DiscardPending` | Rolls back pending `asCScriptFunction` only. Funcdef/global mutations remain. |
| `Fork/as_scriptengine.h:249` | `asCScriptEngine::IsCanonicalBytecodeCodeGenReady` | Unconditionally `return false` (Wave A honesty). After D it may become true **because** `Build()` actually calls `Generate()`, not because the class exists. |
| `Fork/as_compiler.cpp:3282` | `asCCompiler` Bytecode publish | Sets publisher `COMPILER`. Correct for LEGACY; CANONICAL `Build()` must not reach this. |
| `SDK/CanonicalAST/AngelscriptNativeCanonicalASTCutoverTests.cpp` | several methods | Honest today: CANONICAL `Build()` asserts publisher `COMPILER`. After D those assertions **must flip** or the wave is not done. `CompileFunctionDoesNotReplaceRetainedModuleSnapshot` (`:227`) still locks stale generation — E’s policy, not D’s pass criterion. |
| `SDK/FrontendAST/AngelscriptNativeCanonicalASTCodeGenTests.cpp:163` | `CodeGenDoesNotPublishPartialFunctionsOnUnsupportedBody` | Asserts no leftover **functions**. Does not assert funcdef/global rollback. |

### Files to create

- `Fork/as_bytecode_codegen_artifact.h` (optional, keep in CodeGen TU if smaller) — detached install record: funcdefs, globals, functions, `ScriptFunctionData`, dependencies. Nothing is visible on the target `asCModule` until commit.
- `SDK/FrontendAST/AngelscriptNativeCanonicalASTCodeGenTransactionTests.cpp` — failure after `AddFuncDef` would-have-happened and after global allocate: module function count, funcdef count, global count unchanged; retry on the same module is safe.
- `SDK/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp` — CANONICAL `Engine.Build()` of `int F() { return 7; }` executes **and** `GetLastBytecodePublisher() == CANONICAL_CODEGEN`. Fail the test if publisher is `COMPILER`.

### Files to modify

- `Fork/as_module.cpp` / `as_module.h`
  - CANONICAL `Build()`: after parse/types/layout, take sealed AST, call `asCBytecodeCodeGen::Generate(const asCASTContext&, asCModule*)`, set publisher only on full success.
  - LEGACY `Build()`: keep `BuildCompileCode()` / `asCCompiler`.
  - Stop using `PublishCanonicalASTSnapshot`’s empty-TU fabricate (`as_module.cpp:2088-2096`) on the CANONICAL success path. If retain policy is on and Context is missing, fail closed rather than publish a fake graph. (Atomic *swap* of snapshots is Wave E; D must not introduce a new fabricate.)
- `Fork/as_builder.cpp` / `as_builder.h`
  - New path e.g. `BuildCanonicalCodeGen()` used when `engine->GetCompilerPipeline() == CANONICAL`.
  - `BuildCompileCode` / `CompileFunctions` remain LEGACY-only. Do not delete `asCCompiler` in this wave.
  - `TakeCanonicalAST()` still transfers the sealed graph into the module; CodeGen reads it const.
  - `AttachCanonicalSemaIfNeeded` (`:652`) must not silently continue after Context/Sema allocation failure on the CANONICAL path — fail the build.
- `Fork/as_bytecode_codegen.cpp` / `as_bytecode_codegen.h`
  - `Generate` emits into a detached artifact, then installs atomically.
  - On any `asNOT_SUPPORTED` / OOM / verify failure: roll back **type / funcdef / global / function / dependency / metadata** mutations (task 9.1).
  - Success: `module->SetLastBytecodePublisher(asBYTECODE_PUBLISHER_CANONICAL_CODEGEN)` (already at `:1490`).
  - Signature stays `int Generate(const asCASTContext& context, asCModule* module)`. Context must be sealed; do not mutate nodes.
- `Fork/as_scriptengine.h` — `IsCanonicalBytecodeCodeGenReady()` returns true only after this routing exists (capability of this binary: CANONICAL `Build()` uses `Generate()`). Not an unconditional “class exists”.
- `Fork/as_compiler.cpp` — keep publisher `COMPILER` for LEGACY. CANONICAL `Build()` must not call it.
- `SDK/CanonicalAST/AngelscriptNativeCanonicalASTCutoverTests.cpp`
  - CANONICAL `Build()` of `int F() { return 7; }` must fail the test if publisher is `COMPILER`.
  - `IsCanonicalBytecodeCodeGenReady()` may now be true.
  - Default pipeline **stays LEGACY** until Wave G. Do not revive `DefaultPipelineIsCanonical...`.
  - Value-object test (`CanonicalSelectionStillPublishesValueObjectsThroughCompiler`, `:272`): after 9.5, either publisher is `CANONICAL_CODEGEN` or the fixture is explicitly out of subset and fails closed — **not** silent Compiler success under CANONICAL.
- `SDK/CanonicalAST/AngelscriptNativeCanonicalCompilerDifferentialTests.cpp` — Ready assertions; isolated Engines compare VM behavior of CodeGen vs Compiler.
- `SDK/CanonicalAST/AngelscriptNativeCanonicalASTIsolatedDifferentialTests.cpp` + `SDK/FrontendAST/AngelscriptNativeCanonicalASTCodeGenTests.cpp` — grow 9.5–9.7 surface (value objects, handles, containers, delegates, lambdas, globals/imports, lifecycle, exception/suspend, debug/coverage metadata).
- `SDK/CanonicalAST/Semantics/AngelscriptNativeCanonicalASTVmMatrixTests.cpp` — traces must come from CodeGen in the CANONICAL Engine, not from a second Engine that still runs Compiler.
- `Standalone/Tests/AngelscriptStandaloneCanonicalASTTests.cpp` — Ready may be true; default still LEGACY; CANONICAL `Build()` publisher `CANONICAL_CODEGEN` for the subset Standalone compiles.

### Files to test (prefixes)

Existing isolated CodeGen tests stay; they are not the production gate. The production gate is Cutover + Compiler.CanonicalAST + (for 9.7) SDK Compiler/Runtime/Module/TypeSystem/Language/Embedding/Conformance **on a CANONICAL Engine whose publisher is CodeGen**.

### Interfaces later waves rely on

- Observable publisher `CANONICAL_CODEGEN` on successful CANONICAL `Build()` (E/F/G tests).
- `Ready() == true` means production `Build()` uses `Generate()` (G may default CANONICAL).
- Transactional install: E’s failed snapshot publish and F’s ExactStartup can assume a failed CodeGen leaves the module unmutated.
- Sealed AST is the Bytecode authority; Sema/AST/CodeGen still must not `#include "as_compiler.h"` (scan already in Cutover).

### Verification (from `D:\as-cta`)

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label wave-d-codegen -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" -Label wave-d-cutover -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" -Label wave-d-codegen-frontend -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-d-canonical-ast -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label wave-d-compiler -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Runtime" -Label wave-d-runtime -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Module" -Label wave-d-module -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.TypeSystem" -Label wave-d-typesystem -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Language" -Label wave-d-language -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Embedding" -Label wave-d-embedding -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Conformance" -Label wave-d-conformance -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix wave-d-standalone -TimeoutMs 600000
```

9.7 requires those SDK prefixes to be run with CANONICAL selected **and** publisher `CANONICAL_CODEGEN`. A green Compiler prefix under LEGACY default is regression only. Do **not** run All as a Wave D gate.

### Stay `[ ]` until D rereview

Keep **13.6, 9.1, 9.5, 9.6, 9.7, 10.4, 13.1** unchecked until:

- a cutover test fails if `asCCompiler` published Bytecode for a CANONICAL-selected `Build()`
- `Generate()` is the production backend for that `Build()`
- CodeGen failure leaves no type/funcdef/global/function/module mutation
- `Ready()` is true only because that routing exists
- default pipeline is still LEGACY

Do **not** check 10.1, 10.2, 10.7, 12.4. Do not flip `ep.canonicalCompilerPipeline`.

### Wave D collision warning

Writes `as_module.cpp` (`Build`), `as_builder.cpp` (compile routing), `as_bytecode_codegen.*`, `as_scriptengine.h` (`Ready`). After D, E may take `as_module.cpp` snapshot protocol; F may take `as_builder.cpp` `WriteError*` only. Do not start E/F writers until D’s `Build()` routing has landed.

---

## Wave E — public AST methods off mid-vtable; honor `structSize`; atomic leases

**Tasks:** 13.7, 13.8, 3.2, 3.4, 3.7, 11.4. Review **R05, R06**.

**Blocked on:** Wave D (3.4 “every source build owns AST through Bytecode CodeGen” is false until `Generate()` is production). C’s const snapshot context.

**Overlap with F:** allowed **only if** E owns `Core/angelscript.h` + `as_ast_public_view.*` + `as_module.cpp` snapshot protocol, and F does **not** edit those files except calling `InstallVerifiedASTSnapshot`.

### Current wrong functions / behavior

| Location | Function | What is wrong |
| --- | --- | --- |
| `Public/angelscript.h:1058-1060` | `asIScriptModule::SetASTRetentionPolicy` / `GetASTRetentionPolicy` / `AcquireASTSnapshot` | Inserted **between** `CompileFunction` and `SetAccessMask`. Every later vtable slot moved. `Angelscript.uplugin` still `1.0.0` / `10000`. |
| `Fork/as_ast_public_view.cpp:64,87,105,126` | `asCASTSnapshot::GetDecl` / `GetStmt` / `GetExpr` / `GetType` | Never reads caller `structSize` / `apiVersion`. Always writes the full current struct (`outView->structSize = sizeof(...)`). Older smaller caller buffers are overwritten. |
| `SDK/Module/AngelscriptNativeASTSnapshotAPITests.cpp:50-53` | `RetainPolicyPublishesImmutableV1Snapshot` | Zero-inits `asSASTDeclView` and expects the implementation to fill `apiVersion`, masking negotiation. |
| `Public/angelscript.h:980-1025` | `asSASTDeclView` / `Stmt` / `Expr` / `Type` | V1 lacks source ranges, children/operands, value category, resolved decls/calls, statement owners/targets, stable dependencies. IDs are 1-based integers with no generation cookie. |
| `Fork/as_module.cpp:1999` | `asCModule::AcquireASTSnapshot` | Loads raw `astSnapshot`, then `AddRef()`, no lock/atomic retain. Publisher can `Release`/delete between the two. |
| `Fork/as_ast_public_view.h:36` | `asCASTSnapshot::currentGeneration` | Plain `bool`. `IsCurrentGeneration()` (`as_ast_public_view.cpp:54`) data-races with Hot Reload writers. `SetCurrentGeneration` (`:27`) is unsynchronized. |
| `Fork/as_module.cpp:2056` | `asCModule::PublishCanonicalASTSnapshot` | Invalidates and `Release`s the previous snapshot **before** seal/alloc of the replacement (`:2058-2064`). Failed seal (`:2097`) loses the last good generation. Fabricates TranslationUnit-only snapshot when Context is null (`:2088-2096`). |
| `Fork/as_builder.cpp:1015` + Cutover `:227` | `CompileFunction` + `CompileFunctionDoesNotReplaceRetainedModuleSnapshot` | `asCOMP_ADD_TO_MODULE` adds an executable function; old snapshot stays current and incomplete. Test **locks** unchanged generation key. |
| `StaticJIT/AngelscriptStaticJITGenerationSnapshot.h:54` | `FAngelscriptStaticJITGenerationFunction::SealedAST` | Raw `const asCASTContext*`. Construction in `AngelscriptStaticJITGenerationSnapshot.cpp:1139-1142` does not acquire `asIASTSnapshot`. |
| `StaticJIT/TypedASTJIT/AngelscriptTypedASTJITEligibility.h:55` | `SealedAST` | Same raw pointer. |

### ABI strategy (do this, do not invent a fourth)

1. **Remove** the three virtuals from the middle of `asIScriptModule` so `CompileFunction` is again immediately followed by `SetAccessMask` (`Public/angelscript.h:1057` → `:1061`).
2. **Append** the three methods on `asIScriptModule` immediately before `protected: virtual ~asIScriptModule()` (after `ClearImports()`, currently `:1115`). Trailing slots keep original 1.0.0 clients matching. Do **not** insert `QueryInterface` in the middle.
3. This worktree’s mid-vtable insertion has **not** shipped as a compatible 1.0.0 ABI. Keep product version `1.0.0` / `10000`. 11.4 must say: never compile embedding clients against the mid-vtable tree; trailing append is the V1 layout.
4. Callers initialize `structSize` and `apiVersion`. Implementation writes `min(caller.structSize, sizeof(current view))` bytes and **must not** touch a trailing canary. Reject `apiVersion != asAST_API_VERSION_1`. Reject `structSize <` the V1 header (`structSize + apiVersion`).
5. Snapshot-local IDs are valid only for the snapshot that issued them. `GetDecl` on snapshot B with snapshot A’s id of the same numeric index fails closed (not “TU of B”).

### Files to create

- `SDK/Module/AngelscriptNativeASTSnapshotNegotiationTests.cpp` — smaller-view canary (extra `uint32` after the struct, must be `0xA5A5A5A5` after `GetDecl`); incompatible version → null/error; zero `structSize` rejected; two non-empty snapshots, same-index foreign ID fails.
- `SDK/Module/AngelscriptNativeASTSnapshotConcurrencyTests.cpp` — Acquire-vs-publish race; reader-vs-`IsCurrentGeneration`; failed publish keeps previous generation current; module discard with live lease; CompileFunction completeness policy.
- Do **not** add more mid-vtable methods. If V1 views need ranges/children, grow the POD structs with `structSize` gating (append fields; old callers keep old size).

### Files to modify

- `Public/angelscript.h` — move the three methods; keep `asIASTSnapshot` and view PODs; add V1 fields required for read-only traversal (range, children, value category, resolved target, dependencies) **appended** after current members.
- `Fork/as_module.h` / `as_module.cpp`
  - Virtual declarations follow the interface order (trailing AST methods).
  - `AcquireASTSnapshot`: atomic load of `astSnapshot` + `AddRef` in one protocol (UE atomics are allowed **here**; `as_module.cpp` is already UE-contaminated).
  - `PublishCanonicalASTSnapshot`: construct + verify the new `asCASTSnapshot` fully; then atomic exchange; then `SetCurrentGeneration(false)` + `Release` on the previous. Failure keeps the previous pointer current.
  - Add `InstallVerifiedASTSnapshot(asCASTSnapshot*)` (internal) for Wave F ExactStartup. F calls this; F does not rewrite the function.
  - Documented `CompileFunction` policy: either republish a **complete** sealed snapshot that includes the new function, or refuse `asCOMP_ADD_TO_MODULE` under `asAST_RETAIN_SNAPSHOT` until that merge exists. Do not keep “stale generation is current” as the success contract.
- `Fork/as_ast_public_view.h` / `as_ast_public_view.cpp`
  - `currentGeneration` → `asCAtomic` (or equivalent in `as_atomic.h`). `IsCurrentGeneration` / `SetCurrentGeneration` use it.
  - `GetDecl`/`GetStmt`/`GetExpr`/`GetType` honor `structSize`/`apiVersion`.
  - `GetContext()` stays const (from C).
- `Fork/as_builder.cpp` `CompileFunction` — only as needed to implement the completeness policy. Prefer module-side republish after the function exists so F is not blocked. If this edit conflicts with D’s routing, wait until D has landed and touch only the post-compile snapshot call.
- `StaticJIT/AngelscriptStaticJITGenerationSnapshot.h` / `.cpp` — **after B**. Replace `const asCASTContext* SealedAST` with `asIASTSnapshot*` (AddRef on construct, Release on snapshot destroy). Bind FunctionKey ↔ AST decl using B’s exact signature keys; do not revert to name-first.
- `StaticJIT/TypedASTJIT/AngelscriptTypedASTJITEligibility.h` and call sites in `AngelscriptTypedASTJITBackend.cpp` / `AngelscriptTypedASTJITCanonical.cpp` / `AngelscriptTypedASTJITCallClosure.cpp` / `AngelscriptBytecodeJIT.cpp` — consume the lease, not a raw context pointer.
- `Public/AngelscriptEngine.cpp` (~`:7264`) — keep copying retain policy across replacement; do not race Acquire.
- `SDK/Module/AngelscriptNativeASTSnapshotAPITests.cpp` — callers set `structSize`/`apiVersion` before `GetDecl`. Zero-init overwrite test must die.
- `Test/HotReload/AngelscriptCanonicalASTSnapshotReloadTests.cpp` — race Acquire with publish; failed replacement preserves generation A as current.
- `SDK/CanonicalAST/AngelscriptNativeCanonicalASTCutoverTests.cpp` `CompileFunctionDoesNotReplaceRetainedModuleSnapshot` — replace “generation key unchanged” with the documented complete-snapshot policy.
- `Documents/Guides/AngelscriptCanonicalAST.md` — 11.4 migration notes: trailing vtable, caller size/version, null acquisition, leases, no concrete node ABI. Do not claim this until the tests exist.

### Interfaces later waves rely on

- Safe V1 views + atomic Acquire (F ExactStartup publish, G adversarial matrix).
- `InstallVerifiedASTSnapshot` (F).
- Generation holds `asIASTSnapshot` (G must not see raw `asCASTContext*` in Provider bindings).

### Verification (from `D:\as-cta`)

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label wave-e-snapshot-abi -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Module.CanonicalAST.Snapshot" -Label wave-e-snapshot-api -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Module" -Label wave-e-module -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.CanonicalAST.Snapshot" -Label wave-e-hotreload-snapshot -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload" -Label wave-e-hotreload -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" -Label wave-e-cutover -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT" -Label wave-e-staticjit -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix wave-e-standalone -TimeoutMs 600000
```

### Stay `[ ]` until E rereview

Keep **13.7, 13.8, 3.2, 3.4, 3.7, 11.4** unchecked until:

- mid-vtable insertion is gone (scan `asIScriptModule`: `CompileFunction` then `SetAccessMask`)
- smaller-view canary / incompatible version / foreign same-index ID tests pass
- Acquire-vs-publish race tests pass
- failed publish keeps the previous generation
- CompileFunction completeness is documented **and** tested
- generation/JIT holds `asIASTSnapshot`, not raw `asCASTContext*`

Do not check 10.1/10.3 from “Acquire returns non-null”.

### Wave E collision warning

Writes `Core/angelscript.h` (unique owner), `as_ast_public_view.*`, `as_module.cpp` snapshot protocol. Must not overlap a D writer on `as_module.cpp::Build` or an F writer on `as_module.cpp`. After D, E takes the file; F only calls `InstallVerifiedASTSnapshot`.

---

## Wave F — real ASTBodySidecar DTO + ExactStartup + SourceManager diagnostics

**Tasks:** 13.9, 13.10, 6.3, 6.4, 6.6, 2.2. Review **R04, R10**.

**Blocked on:** B (stable keys + types), C (sealed verified graph), D (production AST exists to persist). E’s install/Acquire APIs if F publishes a public snapshot on restore — call them, do not rewrite them.

### Current wrong functions / behavior

| Location | Function | What is wrong |
| --- | --- | --- |
| `Fork/as_ast_sidecar.cpp:62` | `asCASTEncodeSidecar` | Encodes textual `asCASTDump` plus a declaration table (kind/parent/quals/traits/name/typeKey). No SourceManager tables, interned types, Stmt/Expr, bodies, children, resolved refs, cleanup, provenance. |
| `Fork/as_ast_sidecar.cpp:116` | `asCASTDecodeSidecar` | Reads then **ignores** the dump. Rebuilds decls only. `InternNamedType(asAST_TYPE_VALUE_OBJECT, ...)` then falls back to `int`. Does not require complete byte consumption. `Seal()` on that incomplete graph. |
| `Cache/AngelscriptCacheASTBodySidecar.cpp:39` | `AngelscriptEncodeASTBodySidecar` | Requires `CanonicalAstBytes` non-empty, then **ignores those bytes**, `CreateTranslationUnit` + `Seal` + encode empty TU. |
| `Cache/AngelscriptCacheASTBodySidecar.cpp:75` | `AngelscriptDecodeASTBodySidecar` | Copies envelope bytes back into `CanonicalAstBytes`; does not restore a module graph. |
| `Test/Cache/AngelscriptCacheASTBodySidecarTests.cpp:126` | `DiscardIgnoresSidecarAndRuntimeWrapperRejectsEmpty` | Uses `{1}` as AST bytes; does not assert payload fidelity. |
| `Cache/AngelscriptCacheExactStartup.cpp:69` | `RestoreAngelscriptCacheExactStartup` | VM/module ExactStartup only. No FunctionBody→ASTBodySidecar reconstruct. Counters already have `ParseCalls` / `ModuleCompilerCalls` — retain-policy restore must keep them at 0 while publishing a complete verified AST. |
| `Cache/AngelscriptCacheRestore.cpp:2353` | `FFunctionRestoreInput` add | Restores FunctionBody + DebugSidecar; AST sidecar is not in the restore input. |
| `Fork/as_source_manager.cpp:192` | `asCSourceManager::RemapLogical` | `FindFile(logicalKey, origin)` then reuse. No compare of bytes, byte count, or line offset. Changed content keeps stale buffer/line table. |
| `Fork/as_builder.cpp:6438` / `:6447` | `asCBuilder::WriteError` | `asCScriptCode::ConvertPosToRowCol` + `engine->WriteMessage`. Not SourceManager. |
| `Fork/as_parser.cpp:1022` / `:1036` | `asCParser::Error` / `Warning` | Same `ConvertPosToRowCol` (`:1030`, `:1039`). |
| `Fork/as_compiler.cpp` (many) | `ConvertPosToRowCol` | LEGACY diagnostics also bypass SourceManager (`as_compiler.cpp:83,2822,4703,...`). Task 2.2 / R10: Lexer/Parser/Sema/diagnostics/backend coordinates. |
| Public views / sidecar | — | Do not persist the source-coordinate model (FileID 0 invalid, `{fileID, offset}`, half-open ranges, authored/processed/generated). |

### Files to create

- Keep DTO types in `Fork/as_ast_sidecar.h` (pointer-free, versioned, per-function). Prefer extending the existing codec over a second format.
- `Test/Cache/AngelscriptCacheASTExactStartupTests.cpp` — retain-policy ExactStartup: `ParseCalls==0`, `ModuleCompilerCalls==0`, no `asCParser`/`asCSema`/`asCBytecodeCodeGen::Generate`; one complete verified module AST; public `AcquireASTSnapshot` traversable (bodies, types, ranges); missing/corrupt/wrong-profile/unremappable/verifier-invalid → miss **before** Engine mutation.
- `SDK/FrontendAST/AngelscriptNativeSourceManagerRemapTests.cpp` if remap cases do not fit the existing SourceManager test file.

### Files to modify

- `Fork/as_ast_sidecar.h` / `as_ast_sidecar.cpp`
  - Encode: SourceManager sections (logical key, origin, bytes, lineOffset, lineStarts), interned types, decls with children/body/stableKey/signature, stmt/expr nodes, resolved refs, cleanup/live-value plans, provenance. Pointer-free. Stable keys from Wave B. Complete byte consumption on decode.
  - Decode: new target-Engine `asCASTContext`, `RemapLogical` with **content identity**, resolve types via `asCRuntimeTypeBridge`, `asCASTVerify`, `Seal`, then E’s `InstallVerifiedASTSnapshot`.
  - Reject dumps, `.hir.txt`, `.hir.json`, live pointers, Engine-local numeric IDs.
- `Cache/AngelscriptCacheASTBodySidecar.h` / `.cpp`
  - `AngelscriptEncodeASTBodySidecar` must persist the caller’s `CanonicalAstBytes` (or encode the sealed context those bytes represent). **Never** ignore the payload and emit an empty TU.
  - Decode must round-trip bytes **and** rebuild a graph whose dump/keys match.
- `Cache/AngelscriptCacheTypes.h` — only if FunctionBody needs an optional AST sidecar content hash / record id link. Do not change FunctionBody VM bytes or `SaveByteCode`.
- `Cache/AngelscriptCacheArchive.cpp` — kind 8 already known; keep envelope wrapping the real DTO.
- `Cache/AngelscriptCacheRestore.cpp` / `AngelscriptCacheExactStartup.cpp` / `.h` — FunctionBody optional ASTBodySidecar link; retain-policy restore publishes one verified module AST; discard-policy ignores sidecars (6.5 already exists — do not break it).
- Incremental: `asCASTPlanIncrementalSidecars` already exists in `as_ast_sidecar.h:40`. Wire it so one changed function rebuilds its FunctionBody+ASTBodySidecar; unchanged reuse record IDs; type/decl/global/import changes invalidate the right closure; module activation stays atomic (6.6).
- `Fork/as_source_manager.h` / `as_source_manager.cpp`
  - `RemapLogical`: reuse FileID only when logical key **and** origin **and** byte count **and** bytes **and** lineOffset match. Otherwise allocate a new snapshot-local FileID. Never reuse stale lineStarts.
  - Add authored→processed→generated mapping if section state still has origin metadata only (`design.md` SourceManager).
- `Fork/as_builder.cpp` — `WriteError` / `WriteWarning` / `WriteInfo` derive row/col from `asCSourceManager::GetLineColumn` without changing maintained message **text**. Touch only these helpers if D already owns compile routing.
- `Fork/as_parser.cpp` — `Error`/`Warning` use SourceManager coordinates.
- `Fork/as_compiler.cpp` — LEGACY diagnostics same coordinate authority (messages unchanged).
- `Fork/as_scriptcode.cpp` / `.h` — optional adapter: script sections register with the module SourceManager so Parser/Builder do not keep a second line table as truth.
- `Fork/as_ast_public_view.cpp` — persist/expose source ranges once E appended the fields.
- `Test/Cache/AngelscriptCacheASTBodySidecarTests.cpp` — delete `{1}` as a fidelity oracle. Byte-exact round trip, cross-Engine remap, corruption/mismatch rejection.
- `SDK/FrontendAST/AngelscriptNativeSourceManagerTests.cpp` — `DeterministicRemapAssignsNewLocalIds` currently expects reuse on same key+bytes (`:69`). Add a case: same logical key, **different bytes** → **new** FileID, old buffer unchanged.
- `Standalone/Tests/AngelscriptStandaloneCanonicalASTTests.cpp` — host-neutral DTO round-trip if the sidecar codec is fork-only.

### Interfaces later waves rely on

- Cache V2 can reconstruct a sealed verified AST without Parser/Sema (G cutover; retain-policy ExactStartup).
- SourceManager is the coordinate authority for diagnostics and public/cache views (G must not reintroduce `ConvertPosToRowCol` as truth).
- Incremental sidecar plan (G must not treat VM FunctionBody reuse as AST reuse).

### Verification (from `D:\as-cta`)

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label wave-f-cache-source -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.ASTBodySidecar" -Label wave-f-sidecar -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.SourceManager" -Label wave-f-source-manager -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache" -Label wave-f-cache -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend" -Label wave-f-frontend -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-f-canonical-ast -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.CanonicalAST.Snapshot" -Label wave-f-hotreload-snapshot -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix wave-f-standalone -TimeoutMs 600000
```

Cache `556/556` under the old envelope is **not** 6.4. ExactStartup tests must assert zero Parser/Sema/CodeGen and payload fidelity.

### Stay `[ ]` until F rereview

Keep **13.9, 13.10, 6.3, 6.4, 6.6, 2.2** unchecked until:

- sidecar round trip preserves complete function-body payload and stable identities (not dump text, not `{1}`)
- ExactStartup reconstructs one complete verified module AST without Parser/Sema
- remap cannot reuse stale bytes/line offsets
- Parser/Builder/Compiler diagnostics go through SourceManager without changing maintained messages
- incremental AST sidecar reuse is real DTO identity, not VM FunctionBody identity

Do not check 10.9 from Cache prefix counts.

### Wave F collision warning

Writes `as_ast_sidecar.*`, Cache DTO/ExactStartup/Restore, `as_source_manager.*`, Parser/Builder/Compiler **diagnostic** helpers. Must **not** rewrite `as_module.cpp` Acquire/publish (call E). Must **not** rewrite `BuildCompileCode` (D). `as_builder.cpp` `WriteError*` is the overlap with D — F starts after D, edits only those functions. `as_ast_public_view.cpp` range fill starts after E’s `structSize` work.

---

## Wave G — default CANONICAL only after D; adversarial matrix; All as CodeGen evidence

**Tasks:** 10.1–10.3, 10.5–10.7, 10.9, 13.11–13.12, 12.2, 12.4, plus 11.3 leftover / 11.4 if still open.

**Blocked on:** D rereview (Ready true, `Build()` publisher `CANONICAL_CODEGEN`). C/E/F adversarial tests should already exist per-wave; G collects the matrix and flips the default.

**Do not:** check section 10 because All went green while publisher was `COMPILER`. Do not rewrite 10.4–10.7 into residual “locks”.

### Current wrong functions / behavior

| Location | Function | What is wrong |
| --- | --- | --- |
| `Fork/as_scriptengine.cpp:787` | engine property init | `ep.canonicalCompilerPipeline = false` (Wave A). G may set `true` **only after D**. |
| Cutover tests (Wave A) | default LEGACY | Must invert default assertions **after** the production backend is CodeGen, not before. |
| `Fork/as_sema_decl.cpp:752` | `asCSema::ActOnParsedScript` | Still a semantic walk of `asCScriptNode` (10.3/10.6). Parser nodes may remain recovery input; sealed graph must already contain every backend decision. |
| HIR accessors / tests | `asCTypedSemanticFunction` | 10.5: remove production HIR capture/builder/accessors only after TypedASTJIT/tests do not consult them. Kind 8 exists; that is not HIR deletion. |
| Docs leftover (11.3) | ZH + Standalone | `Documents/Knowledges/ZH/AS_CanonicalTypedAST.md`, `Documents/Knowledges/ZH/AS_Compiler.md`, `Documents/Guides/AngelscriptStandaloneOfflineBundle.md` still say new engines default to CANONICAL — they were wrong under Wave A and must match **post-G** truth when the default actually flips. |
| All-suite 3632/3632 | — | Compatibility of `asCCompiler`. G re-runs All only as **CodeGen** evidence (publisher `CANONICAL_CODEGEN` on canonical-selected modules). |

### Files to create

- `SDK/CanonicalAST/AngelscriptNativeCanonicalASTAdversarialTests.cpp` — rereview matrix (13.11), aggregating cases that D/E/F did not already own:
  - same-index foreign IDs
  - smaller public views + canary
  - concurrent Acquire/publish
  - failed publication keeps previous generation
  - CodeGen failure leaves no module mutation
  - sidecar corruption/mismatch miss-before-mutation
  - source remap stale-byte rejection
- `attachments/wave-g-results.md` (implementer record; not a checkbox)

### Files to modify

- `Fork/as_scriptengine.cpp` — `ep.canonicalCompilerPipeline = true` **after** D’s gate.
- `Fork/as_scriptengine.h` — comments: CANONICAL is production; LEGACY is opt-out; dual still rejected.
- `SDK/CanonicalAST/AngelscriptNativeCanonicalASTCutoverTests.cpp` — 10.1 matrix: primary `Build`, Hot Reload, `CompileFunction`, generation, commandlet, Standalone all select canonical Parser/Sema/Bytecode; no `asCOMPILER_PIPELINE_DUAL`; publisher `CANONICAL_CODEGEN` for executable results.
- `SDK/CanonicalAST/AngelscriptNativeCanonicalCompilerDifferentialTests.cpp` — default CANONICAL; LEGACY opt-out still works.
- `Standalone/Tests/AngelscriptStandaloneCanonicalASTTests.cpp` — default CANONICAL + Ready true + publisher CodeGen.
- Parser/Sema: 10.3 attach for `Build()` and `CompileFunction`; `CompileFunction` uses E’s complete-snapshot policy.
- 10.5 HIR: TypedASTJIT production reads of `GetTypedSemanticFunction()` removed only after 7.x oracles are unused. Keep `captureTypedSemanticIR` default off.
- 10.6: no production semantic use of `asCScriptNode`; `ScriptFunctionData` does not store parser nodes (already true) — Sema attach must not be the semantic authority.
- Docs 11.3 / 11.4: English + ZH + Standalone + ForkStrategy + Cache + StaticJIT + plugin README. After G they may say default CANONICAL **because it is true**.
- `Documents/Guides/AngelscriptCanonicalAST.md` — production CodeGen, V1 trailing vtable, leases, Cache DTO, SourceManager.

### Files **not** to treat as done via prefix reuse

Do not check 10.9 / 12.2 / 12.4 from `attachments/final-results.md` (3632/3632 under Compiler publisher). Re-run and quote publisher/Ready.

### Verification (from `D:\as-cta`)

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label canonical-ast-cutover -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" -Label wave-g-cutover -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend" -Label wave-g-frontend -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label wave-g-compiler -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Runtime" -Label wave-g-runtime -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Module" -Label wave-g-module -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.TypeSystem" -Label wave-g-typesystem -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Language" -Label wave-g-language -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Embedding" -Label wave-g-embedding -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Conformance" -Label wave-g-conformance -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache" -Label wave-g-cache -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload" -Label wave-g-hotreload -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT" -Label wave-g-staticjit -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Debugger" -Label wave-g-debugger -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CodeCoverage" -Label wave-g-codecoverage -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix wave-g-standalone -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite StandaloneRelease -LabelPrefix wave-g-standalone-release -TimeoutMs 1200000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite All -LabelPrefix canonical-ast-final-all -TimeoutMs 3600000
```

All is a Wave G gate **only** when canonical-selected modules record publisher `CANONICAL_CODEGEN`. Quote that in `attachments/wave-g-results.md` / `attachments/final-results.md`. Zero failures/skips/timeouts except repo-baselined Disabled (`#ue57-headless`).

### Stay `[ ]` until G rereview

Keep **10.1, 10.2, 10.3, 10.5, 10.6, 10.7, 10.9, 13.11, 13.12, 12.2, 12.4** (and 11.3/11.4 if still open) unchecked until:

- default pipeline is CANONICAL **and** production Bytecode is `asCBytecodeCodeGen`
- LEGACY remains opt-out; dual rejected
- adversarial matrix from the 2026-08-21 rereview list is green
- focused SDK/Cache/HotReload/StaticJIT/Debugger/CodeCoverage + Standalone Debug/Release + All are **CodeGen** evidence
- HIR production capture/builder/accessors are gone only if tests no longer consult them
- no production semantic body walk of `asCScriptNode`

10.8 (forbidden-symbol scan) stays checked. 10.4 should already have been checked at D rereview, not here.

Do not archive unless the user asks.

### Wave G collision warning

Writes `as_scriptengine.cpp` default, Cutover/Standalone tests, docs. Should not take `as_module.cpp` / `as_builder.cpp` / `as_ast_context.*` / `Core/angelscript.h` unless a prior wave left a hole. If 10.3 still needs Parser attach changes, that is `as_parser.cpp` / `as_sema_decl.cpp` — confirm Wave B is long done.

---

## Cross-wave checkbox discipline

| Until this rereview | These boxes stay `[ ]` |
| --- | --- |
| B SemaAuthority | 13.2, 13.3, 2.6, 4.2–4.6, 5.2–5.9, 7.2, 7.4 (B’s list; C–G do not check them) |
| C | 13.4, 13.5, 2.4, 2.8 |
| D | 13.6, 9.1, 9.5–9.7, 10.4, 13.1 |
| E | 13.7, 13.8, 3.2, 3.4, 3.7, 11.4 |
| F | 13.9, 13.10, 6.3, 6.4, 6.6, 2.2 |
| G | 10.1–10.3, 10.5–10.7, 10.9, 13.11–13.12, 12.2, 12.4, leftover 11.3 |

Implementers may add tests and land code in a wave without checking the box. Checking is a **rereview** action against the spec meaning, not against a green legacy prefix.

---

## Evidence functions (line map as of this attachment)

Use these when starting a wave; re-grep if B moved lines.

- `asCASTContext::DestroyAll` — `Fork/as_ast_context.cpp:17`; public decl `as_ast_context.h:51`
- per-node `asNEW` — `as_ast_context.cpp:73` (Decl), `:106` (Stmt), `:125` (Expr), `:162` (Type)
- `asCASTVerify` — `Fork/as_ast_verifier.cpp:13`
- `asASTQualifiersAreValid` — `Fork/as_ast_type.cpp:5`
- `asCBytecodeCodeGen::Generate` — `Fork/as_bytecode_codegen.cpp:1362`; `AddFuncDef` `:1409`; `AllocateGlobalProperty` `:1426`; publisher `:1490`
- `asCModule::Build` → `BuildCompileCode` — `Fork/as_module.cpp:406`
- `asCBuilder::BuildCompileCode` / `CompileFunctions` / `CompileFunction` — `as_builder.cpp:863`, `:1508`, `:1015`
- `asIScriptModule` mid-vtable — `Public/angelscript.h:1058-1060` (between `CompileFunction` `:1057` and `SetAccessMask` `:1061`)
- `asCModule::AcquireASTSnapshot` — `Fork/as_module.cpp:1999`
- `asCModule::PublishCanonicalASTSnapshot` — `Fork/as_module.cpp:2056`; fabricate empty TU `:2088`
- `asCASTSnapshot::GetDecl` size ignore — `Fork/as_ast_public_view.cpp:64`
- `asCASTEncodeSidecar` / `asCASTDecodeSidecar` — `Fork/as_ast_sidecar.cpp:62`, `:116`
- `AngelscriptEncodeASTBodySidecar` ignores payload — `Cache/AngelscriptCacheASTBodySidecar.cpp:39-72`
- `asCSourceManager::RemapLogical` — `Fork/as_source_manager.cpp:192`
- `asCBuilder::WriteError` — `as_builder.cpp:6438`
- `asCParser::Error` — `as_parser.cpp:1022`
- `IsCanonicalBytecodeCodeGenReady` — `Fork/as_scriptengine.h:249` (`return false`)
- default pipeline — `Fork/as_scriptengine.cpp:787` (`false`)
- StaticJIT raw `SealedAST` — `StaticJIT/AngelscriptStaticJITGenerationSnapshot.h:54` / `.cpp:1142`
