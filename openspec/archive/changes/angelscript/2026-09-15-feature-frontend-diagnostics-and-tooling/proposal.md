## Why

The reconstructed frontend now has an engine-independent Builder and one typed AST, but its diagnostic payload is richer than its actual producers. Many parser and semantic failures still share generic IDs and preformatted text; related ranges and fixes are mainly exercised as constructed records. Builder failure wrapping can duplicate root causes or invent a first-token location. These limitations prevent precise explanations, trustworthy fixes, and reuse by editor tooling.

The repository already has a TypeScript language server with an independent parser and type database. It does not consume the reconstructed native frontend. Future native-backed LSP work needs authoritative semantic queries, not another interpretation of diagnostic strings or an activation of the dormant debug bridge.

The selected draft also establishes a unified Diag production API and queued, same-thread Lex/PP. This successor absorbs the planning-only predecessor without losing its accepted diagnostics or query behavior.

## What Changes

- Introduce fragment-bound move-only asCDiagnostic from ordinary phase Diag helpers, with typed streaming payloads and explicit phase submission.
- Add X fixed workers using WorkerCount, K-file queue batches using LexBatchSize (default 4), a locked shared identifier table, same-thread PP behind a per-file lexical gate, and deterministic merge after all work completes.
- Migrate every current Lexer, preprocessor, Parser, Sema, CompilationSession and staged Builder diagnostic producer, including the existing bytecode-emission failure boundary, to concrete catalogued causes, typed arguments, accurate optional source locations, grouped notes and deterministic output.
- Add centralized warning/error policy, controlled recovery and separate analysis-completeness, language-error, build-failure and publication states.
- Provide source-aware Clang-style text rendering, lossless structured JSON and revision-bound atomic fix alternatives. Safe edits are proposals; tests apply them to memory, never automatically to user files.
- Extract side-effect-free semantic candidate assessment shared by ordinary compilation, typo correction, completion and signature help.
- Retain one immutable diagnostic snapshot across CompileOutput and language-service attachment; explicitly own the transitive definition-input closure needed by tooling.
- Add owning native analysis results and real completion, signature-help, hover and definition queries. Cursor parsing handles incomplete code without modifying a published AST or its diagnostics.
- Expose an in-process `asCLanguageService` SDK facade so a failed compilation can format diagnostic groups, inspect notes/fixes as structured data and apply a selected alternative in memory without creating an Engine or starting a language-server process.
- Preserve UTF-8 byte coordinates internally; add explicit UTF-8/UTF-16 presentation conversion and revision-safe, lifetime-safe result boundaries for later LSP integration.

"Clang-level" means the diagnostic quality, recovery and tooling contracts for the currently maintained AS language. It does not promise the complete C++ feature set, all Clang diagnostic IDs, static analysis, or all clangd infrastructure.

## Capabilities

### New Capabilities

- `angelscript/language/frontend/tooling`: engine-independent, snapshot-bound semantic queries, incomplete-source behavior, candidate assessment, result ownership, cancellation and an in-process language-service facade for compile-time diagnostic formatting and suggestion query.

### Modified Capabilities

- `angelscript/language/frontend/source-diagnostics`: concrete diagnostic catalog, semantic payloads, atomic groups, policy, presentation and safe edits.
- `angelscript/language/frontend/builder`: joined Lex/PP execution, local failure gating, exactly-once stage advancement, source-less failures, nonduplicating aggregation and explicit completion/publication states.
- `angelscript/language/frontend/lexing`: concurrent session interning, deterministic lexical projections and per-file failure facts.
- `angelscript/language/frontend/declarations`: source-accurate declaration explanations and recovery of independent declarations.
- `angelscript/language/frontend/bodies`: shared candidate rejection explanations and noncascading body diagnostics.
- `angelscript/language/ast/core`: ownership-safe read-only partial analysis without weakening valid-AST or runtime publication gates.

Tokenization rules and PP directive semantics remain unchanged. Scheduling and failure observation change: clean files complete PP even when another source has a lexical error; a failed wave does not authorize later publication.

## Impact

The parent repository owns the successor records and the explicitly authorized superseded closure of angelscript/feature-frontend-diagnostics-tooling. The original sixteen product nodes retain historical completion evidence. User-requested Reviews identified unmet tooling acceptance; the applied replan adds nine follow-up nodes. This planning update does not modify product code/tests, durable current specs, Skills or unrelated Changes.

Future implementation belongs to the `Plugins/Angelscript` submodule: maintained runtime-owned angelscript/frontend and Builder and replacement tests under `Source/AngelscriptTest/NewVersion/NativeEngine/`. The parent owns this record and eventual deliberate spec synchronization. Public native diagnostic, tooling and in-process language-service interfaces change; no Harness route, portable CLI schema, existing TypeScript LSP protocol, JSON-RPC transport or runtime executor API changes are proposed.

Use the completed `angelscript/refactor-builder-engine-independent` baseline. Keep canonical declarations in `BEGIN_AS_NAMESPACE`, the existing stable-key system, explicit frozen host definitions, and current legacy dormancy. The separate planning-only `angelscript/refactor-testing-unified-framework` is not a prerequisite: use today's supported CQTest inputs, not its unimplemented helpers.

## Non-goals

- No LSP/JSON-RPC server, stdio/pipe language-server process, extension migration, background workspace index, incremental scheduler/cache, workspace rename/references, semantic tokens, inlay hints, or refactoring framework. The in-process `asCLanguageService` is not a protocol endpoint.
- No Standalone target, LLVM link dependency, ambient AS Engine, VM/JIT activation, old runtime/test restoration, or new C++ preprocessing system.
- No restoration of removed `import` or `asset` syntax, no annotation-to-wrapper rewriting, and no nested `frontend` namespace.
- No product implementation, UE execution, durable-spec synchronization, commit, push or worktree operation in this delivery. Only the named predecessor is archived as superseded.

## Acceptance

Creation is complete when the English handoff/carryover, proposal, design, seven capability deltas, migration evidence and sixteen-node Task DAG pass strict record validation, attachment audit and readiness inspection, and the predecessor is explicitly superseded. Structural validity is not product verification.

Future completion requires producer-by-producer migration evidence, independently asserted diagnostic/query/language-service cases, grouped RED/GREEN, fresh mapped NativeEngine regression and the Baseline dormancy check. All future build/test operations use Harness; unrelated aggregate Harness profiles and legacy/full UE suites are not default gates.
