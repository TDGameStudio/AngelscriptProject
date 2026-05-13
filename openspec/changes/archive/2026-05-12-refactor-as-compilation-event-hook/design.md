## Context

`Plugins/Angelscript` is the actual deliverable for this repository. The runtime module currently owns preprocessing, AngelScript module compilation, hot reload integration, class generation handoff, diagnostics, precompiled data application, StaticJIT handoff, and compatibility delegates.

The current preprocessing path is useful but tightly coupled to the runtime engine singleton. `FAngelscriptPreprocessor` builds its flags and defaults by reading current engine/editor/cook state and `UAngelscriptSettings`, and `Preprocess()` reaches back into `FAngelscriptEngine` for config. Its two existing hooks, `OnProcessChunks` and `OnPostProcessCode`, pass the whole mutable preprocessor instance to consumers, encouraging direct reads of `Files`, `ChunkedCode`, macros, and generated code internals.

The current compile path is even larger. `FAngelscriptEngine::CompileModules()` coordinates changed module queues, import resolution, Stage1 module assembly, parallel parse, type generation, Stage2 function generation, hot reload reference analysis, class/function/global layout, Stage3 bytecode/JIT, Stage4 globals/coverage, class generator setup, module swap, rollback, diagnostics, and post-compile delegates. Existing runtime delegates are coarse (`GetPreCompile()`, `GetPostCompile()`, `GetPreGenerateClasses()`) and do not expose stable stage or half-step observation points.

This change uses a staged refactor. It makes preprocessing inputs explicit and adds structured, default-quiet observation before attempting the larger `ICompilationPhase` / pipeline split described in `Documents/Plans/Plan_CompilationPipelineRefactor.md`.

## Goals / Non-Goals

**Goals:**

- Make preprocessor configuration explicit and testable through a value object while preserving current default behavior.
- Provide stable read-only preprocessing summaries so event listeners and tests do not depend on mutable internal data layout.
- Provide a runtime-level compilation events API with structured UE-style events and no output or behavior changes when unused.
- Add minimal compile-stage event emission at existing stable boundaries in `CompileModules()` and Stage1-4.
- Introduce a thin per-run compilation context only where it clarifies shared compile-state summaries and future phase extraction.
- Keep this change compatible with existing callers and test helpers.

**Non-Goals:**

- Do not replace `CompileModules()` with a full phase pipeline in this change.
- Do not rename or remove the existing Stage1/2/3 precompiled data API.
- Do not implement VM execution events, JIT wrapper events, DebugServer rewrite, or bytecode disassembly.
- Do not expose mutable preprocessor internals or AS builder/module internals as long-lived event data.
- Do not add `LearningGuide` or `LearningTrace` names to runtime APIs.

## Decisions

### Decision 1: Use a staged hook-friendly refactor before a phase pipeline

This change chooses the incremental path: explicit preprocessor context, summary API, compilation events, and thin compile context. The alternative was to immediately introduce `ICompilationPhase` classes and move the whole compile flow into `Core/Compilation/Phases/`. That larger rewrite would mix hook API design with hot reload, precompiled data, ClassGenerator, and rollback migration risk. The staged approach creates the stable interfaces first, then lets a later pipeline refactor move implementation behind those interfaces.

### Decision 2: Keep default preprocessor construction compatible

`FAngelscriptPreprocessor` will gain an explicit context/options constructor, but the default constructor remains. The default constructor should delegate to a factory such as `FAngelscriptPreprocessorContext::CreateFromCurrentEngineContext()` so existing call sites keep their behavior while tests and future tools can pass explicit inputs.

### Decision 3: Summaries, not internal references, are the event contract

Preprocessor and compilation events should carry value-style summaries: phase, compile type, module/file names, counts, result flags, and stable messages. Events must not expose mutable `FAngelscriptPreprocessor::Files`, chunk arrays, AS builders, `asCModule*` internals, or data that listeners can store and later mutate. If implementation needs access to internals, it should compute a summary inside runtime code and emit only that summary.

### Decision 4: Preserve existing delegates and adapt them rather than replacing them

`FAngelscriptPreprocessor::OnProcessChunks`, `OnPostProcessCode`, `FAngelscriptRuntimeModule::GetPreCompile()`, `GetPostCompile()`, and `GetPreGenerateClasses()` remain valid. The new compilation events API broadcasts structured events around them and may adapt existing preprocessor hook points, but it does not remove or change the existing delegate contracts.

### Decision 5: Compilation events are default quiet and cheap when unused

The compilation events API must be safe as a production runtime facility. Without listeners it must not log, allocate heavy snapshots, export files, run formatting logic, or change compile behavior. Event construction at high-frequency or expensive points should be guarded by a cheap `HasListeners()` style fast path.

### Decision 6: Thin compilation context only captures per-run shared state

`FAngelscriptCompilationContext` is not a new engine singleton and not an external mutation API. It should start as a short-lived object for one compile run, holding only state that is actually shared across multiple compile steps or needed for structured event summaries. Local stage temporaries stay local. This prevents the context from becoming a new god object while still preparing a future `Execute(Context)` phase interface.

## Risks / Trade-offs

- Compile event names can become a semi-public diagnostic contract -> choose semantic names such as `Parse`, `GenerateTypes`, `Layout`, `CompileCode`, and `ClassGenerationHandoff` rather than temporary local variable names.
- Parallel parse can make event order nondeterministic -> collect per-module parse summaries in worker paths and broadcast deterministic summary events from the main compile flow.
- Event listeners could accidentally mutate compile state -> event payloads must be read-only value data and API docs/tests must treat listeners as observation-only.
- Summary fields can be too shallow for diagnostics -> start with stable counts and names; add deeper data only when a concrete consumer/test requires it.
- Default constructor compatibility can hide remaining global coupling -> tests must verify explicit context construction and default-context equivalence separately.
- Touching `CompileModules()` can regress hot reload or rollback -> keep first pass to minimal event emission and context extraction, then validate with focused compiler/preprocessor tests plus smoke build/test runners.

## Migration Plan

1. Add tests that describe explicit preprocessor context, preprocessor summary, and no-listener compilation event behavior.
2. Add `FAngelscriptPreprocessorContext` and route the existing default constructor through a current-engine factory.
3. Add preprocessor summary APIs and update hook/learning tests to use summaries instead of direct internals for new assertions.
4. Add compilation events model and listener registry with no-op fast path.
5. Adapt existing preprocessor hook points to emit structured compilation events.
6. Add minimal compile-stage compilation events and a thin per-run compilation context inside the current compile flow.
7. Update docs and run the standard build/test entry points.

Rollback is straightforward while this remains additive: remove event listeners, keep the compatibility preprocessor constructor, and revert event emission without changing script semantics. If any stage event causes instability, disable that event emission while preserving the context and summary APIs.

## Open Questions

- The exact C++ file split can be decided during implementation: `Core/Compilation/AngelscriptCompilationEvents.*` best matches the later pipeline refactor, while a flat `Core/AngelscriptCompilationEvents.*` is simpler.
- The initial event enum names should be finalized with tests before implementation. Prefer stable semantic names over Stage1/2/3-only names.
- Whether LearningGuide output should be updated in this change or only tests should validate compilation events can be decided during task execution; runtime API names must remain generic either way.
