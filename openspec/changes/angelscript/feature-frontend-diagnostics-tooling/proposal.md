## Why

The reconstructed frontend now has an engine-independent Builder and one typed AST, but its diagnostic payload is richer than its actual producers. Many parser and semantic failures still share generic IDs and preformatted text; related ranges and fixes are mainly exercised as constructed records. Builder failure wrapping can duplicate root causes or invent a first-token location. These limitations prevent precise explanations, trustworthy fixes, and reuse by editor tooling.

The repository already has a TypeScript language server with an independent parser and type database. It does not consume the reconstructed native frontend. Future native-backed LSP work needs authoritative semantic queries, not another interpretation of diagnostic strings or an activation of the dormant debug bridge.

## What Changes

- Migrate every current Lexer, preprocessor, Parser, Sema, CompilationSession and staged Builder diagnostic producer to concrete catalogued causes, typed arguments, accurate optional source locations, grouped notes and deterministic output.
- Add centralized warning/error policy, controlled recovery and separate analysis-completeness, language-error, build-failure and publication states.
- Provide source-aware Clang-style text rendering, lossless structured JSON and revision-bound atomic fix alternatives. Safe edits are proposals; tests apply them to memory, never automatically to user files.
- Extract side-effect-free semantic candidate assessment shared by ordinary compilation, typo correction, completion and signature help.
- Add owning native analysis results and real completion, signature-help, hover and definition queries. Cursor parsing handles incomplete code without modifying a published AST or its diagnostics.
- Expose an in-process `asCLanguageService` SDK facade so a failed compilation can format diagnostic groups, inspect notes/fixes as structured data and apply a selected alternative in memory without creating an Engine or starting a language-server process.
- Preserve UTF-8 byte coordinates internally; add explicit UTF-8/UTF-16 presentation conversion and revision-safe, lifetime-safe result boundaries for later LSP integration.

"Clang-level" means the diagnostic quality, recovery and tooling contracts for the currently maintained AS language. It does not promise the complete C++ feature set, all Clang diagnostic IDs, static analysis, or all clangd infrastructure.

## Capabilities

### New Capabilities

- `angelscript/language/frontend/tooling`: engine-independent, snapshot-bound semantic queries, incomplete-source behavior, candidate assessment, result ownership, cancellation and an in-process language-service facade for compile-time diagnostic formatting and suggestion query.

### Modified Capabilities

- `angelscript/language/frontend/source-diagnostics`: concrete diagnostic catalog, semantic payloads, atomic groups, policy, presentation and safe edits.
- `angelscript/language/frontend/builder`: source-less failures, nonduplicating diagnostic aggregation and explicit completion/publication states.
- `angelscript/language/frontend/declarations`: source-accurate declaration explanations and recovery of independent declarations.
- `angelscript/language/frontend/bodies`: shared candidate rejection explanations and noncascading body diagnostics.
- `angelscript/language/ast/core`: ownership-safe read-only partial analysis without weakening valid-AST or runtime publication gates.

Existing lexing and preprocessing semantics remain unchanged; their producers migrate under the source-diagnostics contract, rather than gaining duplicate capability policies.

## Impact

The creation delivery changes only this parent-repository OpenSpec Change directory. All product tasks remain unchecked. Current durable specs, Skills, other active Changes, archived history, plugin code, tests, generated files and Git state are not modified by creation.

Future implementation belongs to the `Plugins/Angelscript` submodule: maintained ThirdParty frontend/Builder and replacement tests under `Source/AngelscriptTest/NewVersion/NativeEngine/`. The parent owns this record and eventual deliberate spec synchronization. Public native diagnostic, tooling and in-process language-service interfaces change; no Harness route, portable CLI schema, existing TypeScript LSP protocol, JSON-RPC transport or runtime executor API changes are proposed.

Use the completed `angelscript/refactor-builder-engine-independent` baseline. Keep canonical declarations in `BEGIN_AS_NAMESPACE`, the existing stable-key system, explicit frozen host definitions, and current legacy dormancy. The separate planning-only `angelscript/refactor-testing-unified-framework` is not a prerequisite: use today's supported CQTest inputs, not its unimplemented helpers.

## Non-goals

- No LSP/JSON-RPC server, stdio/pipe language-server process, extension migration, background workspace index, incremental scheduler/cache, workspace rename/references, semantic tokens, inlay hints, or refactoring framework. The in-process `asCLanguageService` is not a protocol endpoint.
- No Standalone target, LLVM link dependency, ambient AS Engine, VM/JIT activation, old runtime/test restoration, or new C++ preprocessing system.
- No restoration of removed `import` or `asset` syntax, no annotation-to-wrapper rewriting, and no nested `frontend` namespace.
- No product implementation, UE execution, spec synchronization, archive, commit, push or worktree operation in this creation delivery.

## Acceptance

Creation plus the accepted in-process language-service replan is complete when proposal, design, capability deltas, indexed research/migration evidence and the nine-feature-group Task DAG pass strict record validation and task-readiness inspection. Structural validity is not product verification.

Future completion requires producer-by-producer migration evidence, independently asserted diagnostic/query/language-service cases, grouped RED/GREEN, fresh mapped NativeEngine regression and the Baseline dormancy check. All future build/test operations use Harness; unrelated aggregate Harness profiles and legacy/full UE suites are not default gates.
